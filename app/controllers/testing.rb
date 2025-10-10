# encoding: utf-8
Rozario::App.controllers :test do

  @bug_finder = true

  get :index do
    puts "get :index do testing.rb"
    erb :'test'
  end

  # get "/test/:data/" do
  #   # require 'msgpack'
  #   # @data = params[:data]
  #   # @wtf = MessagePack.unpack(params[:wtf])
  #   # erb :'test2'
  #   @params = params
  #   erb :'test2'
  # end

  get :product, :with => :id do
    puts "get :product, :with => :id do sessions.rb"
    @params = params
    @dsc = DscntClass.new.some_method
    @id = params[:id].to_i
    erb :'test/product'
  end

  get ('/log/availability/?') do
    puts "get ('/log/availability/?') do testing.rb"
    erb :'test/logs'
  end

  get ('/sitemap/generation/?') do
    puts "get ('/sitemap/generation/?') do testing.rb"
    erb :'test/sitemap/generation'
  end

  get ('/sitemap/create-link-lists/?') do
    puts "get ('/sitemap/create-link-lists/?') do testing.rb"
    erb :'test/sitemap/create-link-lists'
  end

  get :catcherr, :with => :id do
    puts "get :catcherr, :with => :id do testing.rb"
    @area_id = params[:id]
    erb :'test/catcherr'
  end

  get :lab do
    puts "get :lab do testing.rb"
    @params = params
    erb :'test/lab'
  end

  get :vueadm do
    puts "get :vueadm do testing.rb"
    @params = params
    erb :'test/vueadm'
  end

end
