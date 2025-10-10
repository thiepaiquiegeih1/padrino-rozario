# encoding: utf-8
Rozario::App.controllers :news do

  before do

    require 'yaml'
    # redis_settings = YAML::load_file("config/redis.yml")
    # REDIS = Redis.new(redis_settings[@environment['type']])

  end

  get :index do
    puts "get :index do news.rb"
    @news = News.all(:order => 'created_at desc')
    @canonical = "https://" + request.env['HTTP_HOST'] + '/news'
    get_seo_data('news_page', nil, true)
    render "news/index"
  end

  get :index, :with => :slug do
    puts "get :index, :with => :id do news.rb"
    @news = News.find_by_slug(params[:slug])
    @news = News.find_by_id(params[:slug]) if @news.nil?
    if @news.blank?
      error 404
    end
    @canonical = 'https://' + request.env['HTTP_HOST'] + '/news/' + @news.slug if @news.slug
    get_seo_data('news', @news.seo_id)
    render 'news/show'
  end

  # get :index do
  #   if REDIS.get @subdomain.url + ':news' && @redis_enable; REDIS.get @subdomain.url + ':news'
  #   else;
  #     @news = News.all(:order => 'created_at desc')
  #     page = render "news/index"
  #     REDIS.setnx @subdomain.url + ':news', page; page;
  #   end
  # end

  # get :index, :with => :id do

  #   @news = News.find_by_id(params[:id])
  #   if @news.blank?
  #     if REDIS.get @subdomain.url + ':404' && @redis_enable; REDIS.get @subdomain.url + ':404'
  #     else; page = error 404; REDIS.setnx @subdomain.url + ':404', page; page; end
  #   else
  #     if REDIS.get @subdomain.url + ':news'+params[:id]; REDIS.get @subdomain.url + ':news'+params[:id]
  #     else;
  #       @news = News.all(:order => 'created_at desc')
  #       page = render 'news/show'
  #       REDIS.setnx @subdomain.url + ':news'+params[:id], page; page;
  #     end
  #   end

  # end

end
