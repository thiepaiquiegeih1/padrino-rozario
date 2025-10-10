# encoding: utf-8

# Defines our constants

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

PADRINO_ENV  = ENV['PASSENGER_APP_ENV'].to_s ||= 'development' # ENV['PADRINO_ENV'].to_s ||= ENV['RACK_ENV'].to_s ||= 'development' unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, PADRINO_ENV)

CarrierWave.root = File.join(Padrino.root, "public")

# require 'rack/session/redis'
# Padrino.use Rack::Session::Redis, 
#   redis_server: "redis://:#{ENV['REDIS_PASSWORD'].to_s}@localhost:6379/0",
#   expire_after: 3600 * 24 * 7,
#   secure: Padrino.env == :production, # Включить secure только в продакшене
#   httponly: true

# Padrino.cache = Padrino::Cache::Store::Redis.new(
#   redis: Redis.new(url: ENV['REDIS_URL'].to_s || "redis://:#{ENV['REDIS_PASSWORD'].to_s}@localhost:6379/0")
# )

require 'rack/cache'
Padrino.use Rack::Cache,
  verbose: true,
  metastore:   "redis://:#{ENV['REDIS_PASSWORD'].to_s}@localhost:6379/0/metastore",
  entitystore: "redis://:#{ENV['REDIS_PASSWORD'].to_s}@localhost:6379/0/entitystore"

# ## Configure your I18n
#
I18n.default_locale = :ru
#
# ## Configure your HTML5 data helpers
#
# Padrino::Helpers::TagHelpers::DATA_ATTRIBUTES.push(:dialog)
# text_field :foo, :dialog => true
# Generates: <input type="text" data-dialog="true" name="foo" />
#
# ## Add helpers to mailer
#
# Mail::Message.class_eval do
#   include Padrino::Helpers::NumberHelpers
#   include Padrino::Helpers::TranslationHelpers
# end

##
# Add your before (RE)load hooks here
#
Padrino.before_load do
  I18n.locale = :ru
  require 'sinatra/simple-navigation'
  require 'will_paginate'
  require 'will_paginate/active_record'
  require 'will_paginate/view_helpers/sinatra'
  include WillPaginate::Sinatra::Helpers
  Padrino.dependency_paths << Padrino.root('workers/*.rb')
  Padrino.set_load_paths('workers')

  # require 'logger'

  # formatter = proc do |severity, datetime, progname, msg|
  #   "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} [#{severity}] #{msg}\n"
  # end

  # filepath = "/srv/log/rozarioflowers.ru.#{Padrino.env}.log"
  # Padrino::Logger::Config[Padrino.env][:log_level]  = Padrino.env == :development ? :debug : :info
  # Padrino::Logger::Config[Padrino.env][:stream] = File.new(filepath, 'a+') # Padrino::Logger::Config[:production][:stream] = :to_file
  # Padrino::Logger::Config[Padrino.env][:log_static] = true
  # Padrino::Logger::Config[Padrino.env][:log_file] = filepath
  # Padrino::Logger.setup!
end

##
# Add your after (RE)load hooks here
#
Padrino.after_load do
  Time.zone = 'Europe/Moscow'
  ActiveRecord::Base.send(:include, Sidekiq::Extensions::ActiveRecord)
end

# Load Initializers
require File.join(Padrino.root, 'lib/core_extensions')
Dir[File.expand_path('../../config/initializers/**/*.rb', __FILE__)].each do |file|
  require file
end

Padrino.load!

configure do
  mime_type :rtf, "text/richtext"
end