require 'etc'
require 'redis'
require 'connection_pool'
require 'uri'

unless defined?(Padrino)
  module Padrino
    def self.logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end

REDIS_CONFIG = {
  # url: ENV.fetch('REDIS_URL', "redis://#{ENV['REDIS_PASSWORD']}@#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/#{ENV['REDIS_DB']}") || 'redis://foobared@127.0.0.1:6379/0'
  host:               ENV.fetch('REDIS_HOST', '127.0.0.1'),
  port:               ENV.fetch('REDIS_PORT', 6379).to_i,
  db:                 ENV.fetch('REDIS_DB', 0).to_i,
  password:           ENV.fetch('REDIS_PASSWORD', 'foobared'),
  namespace:          ENV.fetch('RACK_ENV', 'development'),
  reconnect_attempts: ENV.fetch('REDIS_RECONNECT_ATTEMPTS', 3).to_i,
  timeout:            ENV.fetch('REDIS_TIMEOUT', 5).to_i,
  inherit_socket: true # Используется для первой инициализации, которая останентся, если не сработают хуки, например в среде, где не используются форки или предусмотренные веб-серверы. Опция `inherit_socket` в Redis-клиенте действительно предназначена для того, чтобы использовать одно соединение между процессами после форка. Однако это не всегда гарантирует корректную работу в многозадачных средах, особенно при использовании `ConnectionPool` или когда Redis подключается в рамках нескольких процессов или потоков. Вместо того чтобы полагаться на `inherit_socket`, более надежным подходом будет переинициализация соединений с Redis после форка.  
}

# ENV['REDIS_SSL_ENABLED'] = (ENV['RACK_ENV'] == 'production').to_s if ENV['REDIS_SSL'].nil?
# REDIS_CONFIG.merge!( # Add SSL parameters if connecting to cloud Redis providers
#   ssl: ENV['REDIS_SSL'] == 'true' || true,
#   ssl_params: {
#     ca_file: ENV['REDIS_SSL_CA_PATH'] || '/etc/ssl/certs/ca-certificates.crt',
#     verify_mode: OpenSSL::SSL::VERIFY_PEER || OpenSSL::SSL::VERIFY_NONE
#   },
#   driver: :ruby
# ) if ENV['REDIS_SSL_ENABLED'] == 'true'

begin

  if REDIS_CONFIG.has_key?(:url)
    begin
      uri = URI.parse(REDIS_CONFIG[:url])
      raise ArgumentError, "Invalid Redis URL scheme" unless uri.scheme == 'redis'
      Padrino.logger.info("Redis config validated: #{uri.host}:#{uri.port}")
      # Если используется URL, парсим его и обновляем REDIS_CONFIG
      REDIS_CONFIG[:host] = uri.host if uri.host
      REDIS_CONFIG[:port] = uri.port if uri.port
      REDIS_CONFIG[:db] = uri.path[1..-1].to_i if uri.path && uri.path.length > 1
      REDIS_CONFIG[:password] = uri.password if uri.password
    rescue => e
      Padrino.logger.error("Redis config error: #{e.message}")
      raise
    end
  end

  raise ArgumentError, 'Redis password missing' unless REDIS_CONFIG[:password]
  REDIS_CONFIG.freeze

  def ensure_redis_connection(conn, max_retries: 3, retry_delay: 1) # heuristic method
    retries = 0
    begin
      conn.ping
      Padrino.logger.debug('Redis connection is OK')
    rescue Redis::CannotConnectError => e
      Padrino.logger.debug("Redis connection error: #{e.message}. Retrying...")
      retries += 1
      if retries <= max_retries
        sleep retry_delay
        Padrino.logger.debug("Attempting to reconnect to Redis (attempt #{retries}/#{max_retries})")
        # conn.reconnect # В контексте пула это может быть излишне или некорректно. В `ConnectionPool` `reconnect` вызывается на уровне пула при использовании `with`, но явный вызов здесь может помочь при первой проверке. Однако, при использовании пула, `ConnectionPool` сам управляет переподключениями. Для первой проверки `ping` достаточно. Если `ping` падает, `ConnectionPool` при следующем `with` попытается переподключиться.
        retry # Повторить попытку `ping`
      else
        Padrino.logger.error("Failed to reconnect to Redis after #{max_retries} attempts")
        raise # Пробросить исключение выше, если не удалось переподключиться
      end
    rescue => e
      Padrino.logger.error("Unexpected Redis connection error: #{e.message}")
      raise # Пробросить исключение выше
    end
  end

  # def get_redis_pool(redis_config, redis_pool_size) # semi-heuristic method
  #   return nil unless redis_config
  #   redis_pool_size = calculate_pool_size() unless redis_pool_size
  #   redis_pool = ConnectionPool.new(size: redis_pool_size, timeout: 5) { Redis.new(redis_config) } # Инициализация пула соединений Redis
  #   redis_pool.with { |conn|
  #     ensure_redis_connection(conn)
  #     Padrino.logger.debug("Redis client: #{conn.class}"); Padrino.logger.debug("Redis PING: #{conn.ping}")
  #   }
  #   Padrino.logger.debug 'Redis pool initialized successfully'
  #   return redis_pool
  # rescue => e
  #   Padrino.logger.error "Failed to initialize Redis pool: #{e.class} - #{e.message}"
  #   return nil
  # end

  # def reinitialize_redis_pool(redis_pool, redis_config, redis_pool_size) # determinate method
  #   return nil unless redis_pool
  #   Padrino.logger.debug 'Reconnecting to Redis...'
  #   redis_config[:inherit_socket] = false # Убедитесь, что inherit_socket выключен
  #   new_redis_pool = get_redis_pool(redis_config, redis_pool_size)
  #   if new_redis_pool&.is_a?(ConnectionPool)
  #     Padrino.logger.debug 'Redis reconnected successfully!'
  #     redis_pool.shutdown(&:close) if redis_pool&.is_a?(ConnectionPool)
  #     return new_redis_pool
  #   else; raise 'Error when reconnecting to Redis!'; end
  # rescue => e
  #   Padrino.logger.error "Failed to reconnect to Redis: #{e.class} - #{e.message}"
  #   return nil
  # end

  # Эта функция теперь только создает и возвращает новый пул
  def create_redis_pool(redis_config, redis_pool_size)
    return nil unless redis_config
    redis_pool_size = calculate_pool_size() unless redis_pool_size # Убедимся, что размер пула определен
    Padrino.logger.debug("Creating Redis pool with size: #{redis_pool_size}")

    # Создаем новый пул соединений Redis
    redis_pool = ConnectionPool.new(size: redis_pool_size, timeout: 5) do
      # Redis.new здесь будет вызываться в каждом дочернем процессе после форка
      # для создания новых соединений.
      Redis.new(redis_config)
    end

    # Проверяем одно соединение из нового пула
    begin
      redis_pool.with { |conn| ensure_redis_connection(conn) }
      Padrino.logger.debug('New Redis pool initialized successfully and connection checked.')
      return redis_pool
    rescue => e
      Padrino.logger.error "Failed to initialize new Redis pool or check connection: #{e.class} - #{e.message}"
      # Важно вернуть nil или пробросить исключение, если инициализация не удалась
      raise e # Пробрасываем исключение, чтобы было видно, что инициализация провалилась
    end
  end

  def calculate_pool_size()

    # Priority 1: Explicit value from environment variables
    result = ENV['REDIS_POOL_SIZE'].to_i if ENV['REDIS_POOL_SIZE']

    # Priority 2: Definition via specific variables and server configuration
    unless result
      if defined?(PhusionPassenger) # Получить максимальное число процессов из конфига Passenger
        Padrino.logger.debug 'Calculating pool size for Passenger...'
        if PhusionPassenger.respond_to?(:concurrency_model) && PhusionPassenger.concurrency_model == 'thread' # Multithreading (can be used in Passenger Enterprise)
          threads = PhusionPassenger.thread_count || 1
          processes = PhusionPassenger.max_pool_size || 6
          result = (processes * threads * 1.5).to_i
        else # Process model
          max_processes = PhusionPassenger::AppPool::DEFAULT_MAX_POOL_SIZE || PhusionPassenger.max_pool_size.to_i # Fallback
          result = [max_processes * 2, 5].max # heuristic: 2 conn per proc
        end
      elsif defined?(Puma) # NOT TESTED # Для Puma используем формулу: worker_processes * threads_per_worker
        Padrino.logger.debug 'Calculating pool size for Puma...'
        begin # Попытка получить конфиг из Puma
          workers = Puma.cli_config.options.fetch(:workers, ENV.fetch('WEB_CONCURRENCY', 1)).to_i rescue ENV.fetch('WEB_CONCURRENCY', 1).to_i
          threads = Puma.cli_config.options.fetch(:threads, ENV.fetch('RAILS_MAX_THREADS', 5)).map(&:to_i).max rescue ENV.fetch('RAILS_MAX_THREADS', 5).to_i
          result = (workers * threads * 1.2).ceil
        rescue => e
          Padrino.logger.warn "Could not get Puma config for pool size: #{e.message}. Using fallback."
          result = (ENV.fetch('WEB_CONCURRENCY', 1).to_i * ENV.fetch('RAILS_MAX_THREADS', 5).to_i * 1.2).ceil rescue 5
        end
      elsif defined?(Unicorn::Worker) # NOT TESTED # Unicorn (процессная модель) + возможные треды внутри
        Padrino.logger.debug 'Calculating pool size for Unicorn...'
        begin # Попытка прочитать конфиг Unicorn или использовать ENV
          worker_processes = ENV['WEB_CONCURRENCY'].to_i.nonzero? || (File.read(ENV['UNICORN_CONFIG'] || 'config/unicorn.rb')[/worker_processes (\d+)/, 1] || 4).to_i rescue 4
          rails_threads = ENV['RAILS_MAX_THREADS'].to_i.nonzero? || 1 rescue 1 # Unicorn обычно процессный, но могут быть треды в приложении
          result = (worker_processes * rails_threads * 1.5).to_i
        rescue => e
          Padrino.logger.warn "Could not get Unicorn config for pool size: #{e.message}. Using fallback."
          result = (ENV['WEB_CONCURRENCY'].to_i.nonzero? || 4) * (ENV['RAILS_MAX_THREADS'].to_i.nonzero? || 1) * 1.5 rescue 5
        end
      elsif File.exist?('/etc/nginx/nginx.conf') # Проверка конфига Nginx (для Passenger)
        Padrino.logger.debug 'Checking Nginx config for Passenger pool size...'
        begin
          config = File.read('/etc/nginx/nginx.conf')
          processes = config[/passenger_max_pool_size\s+(\d+)/, 1] || 5
          result = processes.to_i * 2
        rescue => e
          Padrino.logger.warn "Could not read Nginx config for pool size: #{e.message}. Using fallback."
          result = 5 * 2 # Fallback
        end
      else # Общий расчет без специфики сервера
        Padrino.logger.debug 'Calculating pool size based on CPU cores...'
        cpu_cores = Etc.nprocessors.nonzero? || 4 
        result = [(cpu_cores * 4), 5].max
      end
    end

    return (result.to_i rescue 5).clamp(3, 17) # Threshold & insurance...
  rescue => e
    Padrino.logger.error("Error calculating Redis pool size: #{e.class} - #{e.message}. Using fallback.")
    return 5 # Fallback
  end

  $redis_pool = nil
  redis_pool_size = calculate_pool_size() # Размер пула можно рассчитать один раз
  Padrino.logger.debug "Calculated pool size for Redis (ConnectionPool): #{redis_pool_size}"
  # redis_pool = get_redis_pool(REDIS_CONFIG, redis_pool_size)

  # Redis.current.quit # Закрыть старые соединения Redis
  # Redis.current = Redis.new(REDIS_CONFIG)         # Установка глобального соединения Redis (опционально)
  # Redis.current = redis_pool.with { |conn| conn } # Установка глобального соединения Redis (опционально)

  # Hooks for reinitialization after a fork

  if defined?(PhusionPassenger) # For Phusion Passenger: reinitialize connection of Redis after fork
    Padrino.logger.debug 'Registering PhusionPassenger hook in config/initializers/redis.rb'
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      Padrino.logger.debug "PhusionPassenger worker process starting (forked: #{forked})"
      if forked
        Padrino.logger.debug 'Creating new Redis pool after Passenger fork...'
        # redis_pool = reinitialize_redis_pool(redis_pool, REDIS_CONFIG.dup, redis_pool_size)
        $redis_pool = create_redis_pool(REDIS_CONFIG.dup, redis_pool_size); raise "Failed to create Redis pool after Passenger fork" unless $redis_pool
      else
        Padrino.logger.debug 'Not a forked Passenger process, skipping Redis pool creation.'
        # Возможно, здесь нужно создать пул для мастера, если он тоже использует Redis
        # $redis_pool = create_redis_pool(REDIS_CONFIG.dup, redis_pool_size) rescue nil
      end
    end
  elsif defined?(Unicorn) # NOT TESTED # For Unicorn: reinitialize connection of Redis after fork
    Padrino.logger.debug 'Registering Unicorn hook in config/initializers/redis.rb'
    Unicorn.after_fork { |server, worker|
      Padrino.logger.debug 'Creating new Redis pool after Unicorn fork...'
      # redis_pool = reinitialize_redis_pool(redis_pool, REDIS_CONFIG.dup, redis_pool_size)
      $redis_pool = create_redis_pool(REDIS_CONFIG.dup, redis_pool_size); raise "Failed to create Redis pool after Unicorn fork" unless $redis_pool
    }
    # if Unicorn.inherited?
    #   # ...
    # else
    #   Padrino.logger.debug 'Not a Unicorn worker process. Skipping Redis reconnection.'
    # end
  elsif defined?(Puma) # NOT TESTED # For Puma: reinitialize connection of Redis on worker boot
    Padrino.logger.debug 'Registering Puma hook in config/initializers/redis.rb'
    Puma.on_worker_boot { |worker_index|
      Padrino.logger.debug "Creating new Redis pool after Puma worker boot (worker #{worker_index})..."
      # redis_pool = reinitialize_redis_pool(redis_pool, REDIS_CONFIG.dup, redis_pool_size)
      $redis_pool = create_redis_pool(REDIS_CONFIG.dup, redis_pool_size); raise "Failed to create Redis pool after Puma worker boot" unless $redis_pool
    }
    # if Puma.respond_to?(:on_worker_boot)
    #   # ...
    # elsif Puma.respond_to?(:cli_config) && Puma.cli_config # legacy
    #   # ...
    # else
    #   # ...
    # end
  else
    Padrino.logger.debug 'PhusionPassenger, Unicorn, Puma not defined. Skipping specific hook registration...'
  end

  if $redis_pool.nil?
    Padrino.logger.debug 'Redis pool is not initialized yet. Attempting initial creation...'
    begin
      $redis_pool = create_redis_pool(REDIS_CONFIG.dup, redis_pool_size)
      if $redis_pool
        Padrino.logger.debug 'Initial Redis pool created successfully.'
      else
        Padrino.logger.error('Failed to create initial Redis pool')
        raise
      end
    rescue => e
      Padrino.logger.error("An error occurred during initial Redis pool creation: #{e.message}")
      raise
    end
  end

rescue => e; puts 'Oops!'; end

# Not tested OOP alternative:

# # ----------------------------------------------------------
# # Поведение подключения (усовершенствовано)
# # ----------------------------------------------------------
# module RedisConnectionHandling
#   MAX_RETRIES = ENV.fetch('REDIS_MAX_RETRIES', 3).to_i
#   RETRY_DELAY = ENV.fetch('REDIS_RETRY_DELAY', 1).to_f
#
#   def self.ensure_connection(conn) # heuristic method
#     retries = 0
#     begin
#       conn.ping
#       Padrino.logger.debug("Redis connection OK: #{conn.id}")
#     rescue Redis::BaseError => e # Redis::CannotConnectError => e
#       handle_connection_error(e, retries += 1)
#       retry if retries <= MAX_RETRIES
#       raise Redis::CannotConnectError, "Failed after #{MAX_RETRIES} attempts"
#     # rescue => e
#     #   Padrino.logger.error("Unexpected Redis connection error: #{e.message}")
#     #   raise # Пробросить исключение выше
#     end
#   end
#
#   def self.handle_connection_error(error, attempt)
#     Padrino.logger.warn("Redis connection error (#{attempt}/#{MAX_RETRIES}): #{error.class}")
#     sleep(RETRY_DELAY * (1.5 ** attempt)) # exponential delay
#   end
# end
#
# # ----------------------------------------------------------
# # Управление пулом соединений
# # ----------------------------------------------------------
# class RedisPoolManager
#   class << self
#     def create_pool
#       size = calculate_pool_size.clamp(3, 30)
#       ConnectionPool.new(size: size, timeout: 5) do
#         Redis.new(REDIS_CONFIG).tap do |conn|
#           RedisConnectionHandling.ensure_connection(conn)
#         end
#       end.tap do |pool|
#         Padrino.logger.info("Redis pool initialized (#{size} connections)")
#         register_shutdown_hook(pool)
#       end
#     end
#
#     private
#
#     def calculate_pool_size
#       return ENV['REDIS_POOL_SIZE'].to_i if ENV['REDIS_POOL_SIZE']
#
#       case detect_server
#       when :passenger
#         (PhusionPassenger.max_pool_size.to_i * 1.5).ceil
#       when :puma
#         workers = ENV.fetch('WEB_CONCURRENCY', 1).to_i
#         threads = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
#         (workers * threads * 1.2).ceil
#       when :unicorn
#         workers = ENV.fetch('UNICORN_WORKERS', 4).to_i
#         (workers * 1.5).ceil
#       else
#         Etc.nprocessors * 2
#       end
#     rescue => e
#       Padrino.logger.error("Pool calculation error: #{e.message}")
#       5 # Fallback
#     end
#
#     def detect_server
#       return :passenger if defined?(PhusionPassenger)
#       return :puma if defined?(Puma)
#       return :unicorn if defined?(Unicorn)
#       :unknown
#     end
#
#     def register_shutdown_hook(pool)
#       at_exit { pool.shutdown(&:close) }
#     end
#   end
# end
#
# # ----------------------------------------------------------
# # Инициализация и хуки серверов
# # ----------------------------------------------------------
# redis_pool = RedisPoolManager.create_pool
#
# if defined?(PhusionPassenger)
#   PhusionPassenger.on_event(:starting_worker_process) do |forked|
#     next unless forked
#     Padrino.logger.info("Passenger worker spawned")
#     redis_pool = RedisPoolManager.create_pool
#   end
# elsif defined?(Puma)
#   Puma.on_worker_boot { redis_pool = RedisPoolManager.create_pool }
# elsif defined?(Unicorn)
#   Unicorn.after_fork { redis_pool = RedisPoolManager.create_pool }
# end
#
# # ----------------------------------------------------------
# # Глобальный доступ (опционально)
# # ----------------------------------------------------------
# Redis.current = redis_pool
