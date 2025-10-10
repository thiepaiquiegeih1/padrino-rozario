# encoding: utf-8
# Количество потоков на воркер
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 32)
threads threads_count, threads_count

# Количество процессов (воркеров)
workers Integer(ENV['WEB_CONCURRENCY'] || 8)

# Порт или сокет
port ENV.fetch('PORT') { 8080 }
environment ENV.fetch('RACK_ENV') { 'development' }

# Preload app для экономии памяти (используйте с осторожностью, может повлиять на многопоточность)
preload_app!

# Код для управления воркерами при форке
on_worker_boot do
  # Код для повторного подключения к базе данных
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Время ожидания для graceful shutdown
# shutdown_timeout 30
worker_timeout 60 # Тайм-аут для воркеров в секундах

# Управление системой сокетов (необязательно, если используется UNIX сокет)
bind 'unix:///tmp/puma.sock' # для сокетов
