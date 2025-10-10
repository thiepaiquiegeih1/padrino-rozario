# encoding: utf-8
Rozario::App.controllers :product do

  before do
    require 'yaml'
    redis_settings = YAML::load_file("config/redis.yml")
    REDIS = Redis.new(redis_settings[@environment['type']])
  end

  # post :index3 do
  #   puts "Юзер интересуется ценой post :index3 product.rb"
  #   @curr_date = Overprice.create(date: params[:name])
  #   session[:mdata] = params[:name]
    
  #   if (!params[:name].empty?)
  #     msg_body = "Интересуются: " + params[:name] + "\n" + request.user_agent + "\n" + request.cookies.to_s
  #       email do
  #         from "no-reply@rozariofl.ru"
  #         to "a.krit@rozariofl.ru"
  #         subject "Интересуются 22ценой"
  #         body msg_body
  #       end
  #   else
  #     flash[:error] = 'Пожалуйста, введите дату'
  #   end
  #   redirect '/product/'+params[:id]+'/'
  # end

  get :index, :with => :slug do

    response['Cache-Control'] = 'no-store, no-cache, must-revalidate, proxy-revalidate'
    response['Pragma'] = 'no-cache'
    response['Expires'] = '0'

    if params['brdcrmbs_lvl1'] && params['brdcrmbs_lvl2'] # Костыль для решения проблемы обработки ссылки с параметрами во Vue: прячем все параметры в сессию, редиректим на url без параметров, чтобы там уже вытащить их из неё. Кэширование отключено, потому что мешает этому процессу. Це ля ви...
      session[:brdcrmbs_lvl1] = params['brdcrmbs_lvl1']; session[:brdcrmbs_lvl2] = params['brdcrmbs_lvl2']
      return redirect "/product/#{params[:slug].force_encoding('UTF-8')}", 301 # Редирект на чистый URL без параметров
    else
      if session[:brdcrmbs_lvl1] && session[:brdcrmbs_lvl2]
        @brdcrmbs_lvl1 = session[:brdcrmbs_lvl1]; @brdcrmbs_lvl2 = session[:brdcrmbs_lvl2]
        session[:brdcrmbs_lvl1] = nil; session[:brdcrmbs_lvl2] = nil
      else; @brdcrmbs_lvl1 = nil; @brdcrmbs_lvl2 = nil; end

      if Product.find_by_slug(params[:slug].force_encoding('UTF-8')).present?; x = Product.find_by_slug(params[:slug].force_encoding('UTF-8'))
      else;                                                                    x = Product.find_by_id(params[:slug].force_encoding('UTF-8')); end
      halt 404 if x.nil?
      params[:id] = x.id.to_s
      @canonical = "https://#{request.env['HTTP_HOST']}/product/#{Product.find_by_id(params[:id]).slug.force_encoding('UTF-8')}" if Product.find_by_id(params[:id]).slug
      if params[:slug].match(/\A-?\d+\z/) # Если в качестве `slug` используется ID, то перенаправляем на каноническую страницу
        redirect @canonical, 301
      end
      if request.session[:mdata].nil? 
        current_date = Date.current
        session[:mdata] = Date.current
      else; current_date = request.session[:mdata]; end
      date_begin = Date.new(2018,3,3).to_s
      date_end = Date.new(2018,3,10).to_s
      value = ''
      subd = session[:subdomain]
      if current_date.to_s >= date_begin and current_date.to_s <= date_end
        value = 'true'
        ProductComplect.check(value)
        Product.subd(subd)
      else
        value = 'false'
        ProductComplect.check(value)
        Product.subd(subd)
        #@change = ProductComplect.new()
        #@change.check(value)
      end
      @sess = session[:mdata]
      
      @product = Product.find_by_id(params[:id])
      @id_array = []
      count = 0
      image = ProductComplect.where(product_id: params[:id]).pluck(:image).to_a
      id_image = ProductComplect.where(product_id: params[:id]).pluck(:id).to_a
      @price = ProductComplect.where(product_id: params[:id])
      while count < image.size
        @id_array.push(id_image[count].to_s + '/' + image[count].to_s) 
        count += 1
      end
      if @product.blank?
        get_seo_data('products', nil, true)
        if REDIS.get @subdomain.url + ':404' && @redis_enable; REDIS.get @subdomain.url + ':404'
        else; page = error 404; REDIS.setnx @subdomain.url + ':404', page; page; end
      else
        get_seo_data('products', @product.seo_id)
        if @subdomain && @subdomain.enable_categories; @cross_cats = Category.where(id: @subdomain.category_ids.to_s.split(','), show_in_crosssell: true)
        else; @cross_cats = Category.where(:show_in_crosssell => true); end
        if REDIS.get @subdomain.url + ':product'+params[:id]; REDIS.get @subdomain.url + ':product'+params[:id]
        else
          page = render 'product/show'
          REDIS.setnx @subdomain.url + ':product/'+params[:id], page
          page
        end
      end
    end
  end

end
