#!/usr/bin/env rackup
# encoding: utf-8

# This file can be used to start Padrino,
# just execute it from the command line.

# Load sidekiq web interface
require 'sidekiq/web' 
if ENV['PADRINO_ENV'] == 'development'
  map('/admin/sidekiq') { run Sidekiq::Web }
else
  map('/admin/sidekiq') { run Sidekiq::Web }
end

require File.expand_path("../config/boot.rb", __FILE__)
use Rack::Cors do
  allow do
    origins 'localhost:3000', '127.0.0.1:3000',
            /\Ahttp:\/\/192\.168\.0\.\d{1,3}(:\d+)?\z/
            # regular expressions can be used here

    resource '/file/list_all/', :headers => 'x-domain-token'
    resource '/file/at/*',
        methods: [:get, :post, :delete, :put, :patch, :options, :head],
        headers: 'x-domain-token',
        expose: ['Some-Custom-Response-Header'],
        max_age: 600
        # headers to expose
  end

  allow do
    origins '*'
    resource '*', headers: :any, methods: :post
    resource '*', headers: :any, methods: :get
  end
end

use Rack::Config do |env|
  env['X-Powered-By'] = nil
  env['server'] = nil
end

run Padrino.application
