# encoding: utf-8
require 'active_record'
require 'active_support'
require File.expand_path('../boot.rb', __FILE__)

Dir[File.expand_path('../workers/*.rb', __dir__)].each { |file| require file }
