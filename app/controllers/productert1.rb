# encoding: utf-8



Rozario::App.controllers :product do

  before do

    require 'yaml'
    redis_settings = YAML::load_file("config/redis.yml")
    REDIS = Redis.new(redis_settings[@environment['type']])

  end

  get :ssp, :with => :id do
    @product = Product.find_by_id(params[:id])
    @product_compl = ProductComplect.where(product_id: params[:id])
    product_compl = JSON.parse(@product_compl.to_json)

    @product_tags = TagComplect.where(product_id: params[:id])

    sql = "SELECT product_complects.product_id, product_complects.price_1990, categories_products.category_id, product_complects.complect_id, product_complects.over_1990, product_complects.over_2890,product_complects.over_3790 FROM ((product_complects INNER JOIN categories_products ON product_complects.product_id=categories_products.product_id) INNER JOIN products ON product_complects.product_id=products.id) WHERE categories_products.category_id = 733 AND product_complects.complect_id = 1;"
    records_array = ActiveRecord::Base.connection.execute(sql)
    puts records_array.to_json
    product_tags1 = JSON.parse(@product_tags.to_json)
    product_tags1.each do |child|





      puts child['tag_id']
      ff = child['tag_id']
      @tag = Tag.where(id: ff)
      tagparse = JSON.parse(@tag.to_json)
      puts tagparse.to_s
      puts child['complect_id']
      puts child['count']

    end




    par_st = product_compl[0]
    par_sm = product_compl[1]
    par_lx = product_compl[2]
    p par_st
    p par_sm
    p par_lx

    st_compl_id     = par_st["complect_id"].to_s
    st_price        = par_st["price"].to_s
    st_url          = par_st["image"]["url"].to_s
    st_price1990    = par_st["price_1990"].to_s
    st_price2890    = par_st["price_2890"].to_s
    st_price3790    = par_st["price_3790"].to_s

    sm_compl_id     = par_sm["complect_id"].to_s
    sm_price        = par_sm["price"].to_s
    sm_url          = par_sm["image"]["url"].to_s
    sm_price1990    = par_sm["price_1990"].to_s
    sm_price2890    = par_sm["price_2890"].to_s
    sm_price3790    = par_sm["price_3790"].to_s

    lx_compl_id     = par_lx["complect_id"].to_s
    lx_price        = par_lx["price"].to_s
    lx_url          = par_lx["image"]["url"].to_s
    lx_price1990    = par_lx["price_1990"].to_s
    lx_price2890    = par_lx["price_2890"].to_s
    lx_price3790    = par_lx["price_3790"].to_s

    #product_compl3 = product_compl2['complect_id']
    #product_compl2 = product_compl2.values
    #product_compl2.each do |shop|
    #  dd = p shop["complect_id"].to_s
    #end
    #product_compl2 = product_compl2['complect_id']
    #product_compl2 = product_compl1["complect_id".to_i]
    return product_tags1.to_s
  end


  get "/sspc1/:title" do
    require 'translit'
    tt1 = @product = Product.find_by_slug(params[:title])
    #tt1 = @product.header
    tt = Translit.convert(tt1.to_s, :english)

    
    #@product_compl = ProductComplect.where(product_id: params[:id])
    return tt1.to_json
    #return tt

  end


  post :index3 do
    puts "Юзер интересуется ценой post :index3 product.rb"
    @curr_date = Overprice.create(
      date: params[:name]
    )
    session[:mdata] = params[:name]
    
    if (!params[:name].empty?)
      msg_body = "Интересуются: " + params[:name] + "\n" + request.user_agent + "\n" + request.cookies.to_s
        email do
          from "no-reply@rozariofl.ru"
          to "a.krit@rozariofl.ru"
          subject "Интересуются 22ценой"
          body msg_body
        end
    else
      flash[:error] = 'Пожалуйста, введите дату'
    end
    redirect '/product/'+params[:id]+'/'
  end

  get :ssd, :with => :id do
    puts 'ddd'
    @product = Product.find_by_id(params[:id])
    @product_compl = ProductComplect.where(product_id: params[:id])
    render 'layouts/applicationpr', :layout => 'applicationpr'
  end

  #get "/:id/:title" do
  get :index, :with => :id do
    puts "Запрос в сессии даты юзера get :index, :with => :id product.rb"
    product_ids = Product.find_by_id(params[:id])
    product_idss = product_ids.id
    product_slug = product_ids.slug
    redirect url("/product/#{product_idss}/#{product_slug}")  
  end

  get "/:id/:slug" do
      if request.session[:mdata].nil? 
        current_date = Date.current
        session[:mdata] = Date.current
      else
        current_date = request.session[:mdata]
      end
      date_begin = Date.new(2018,3,23).to_s
      date_end = Date.new(2018,3,25).to_s
      value = ''
      if current_date.to_s >= date_begin and current_date.to_s <= date_end
        value = 'true'
        ProductComplect.check(value)
      else
        value = 'false'
        ProductComplect.check(value)
        #@change = ProductComplect.new()
        #@change.check(value)
      end
    @sess = session[:mdata]
    


    @product = Product.find_by_id(params[:id])
    @product_compl = ProductComplect.where(product_id: params[:id])
    product_compl = JSON.parse(@product_compl.to_json)

    par_st = product_compl[0]
    #par_sm = product_compl[1]
    #par_lx = product_compl[2]
    p par_st
    #p par_sm
    #p par_lx

    @st_compl_id     = par_st["complect_id"].to_s
    @st_price        = par_st["price"].to_s
    @st_url          = par_st["image"]["url"].to_s

    @st_price1990    = par_st["price_1990"].to_s
    @st_price2890    = par_st["price_2890"].to_s
    @st_price3790    = par_st["price_3790"].to_s




    #@sm_compl_id     = par_sm["complect_id"].to_s
    #@sm_price        = par_sm["price"].to_s
    #@sm_url          = par_sm["image"]["url"].to_s
    #@sm_price1990    = par_sm["price_1990"].to_s
    #@sm_price2890    = par_sm["price_2890"].to_s
    #@sm_price3790    = par_sm["price_3790"].to_s

    #@lx_compl_id     = par_lx["complect_id"].to_s
    #@lx_price        = par_lx["price"].to_s
    #@lx_url          = par_lx["image"]["url"].to_s
    #@lx_price1990    = par_lx["price_1990"].to_s
    #@lx_price2890    = par_lx["price_2890"].to_s
    #@lx_price3790    = par_lx["price_3790"].to_s

    if @product.blank?
      if REDIS.get @subdomain.url + ':404' && @redis_enable; REDIS.get @subdomain.url + ':404'
      else; page = error 404; REDIS.setnx @subdomain.url + ':404', page; page; end
    else
      if @subdomain && @subdomain.enable_categories; @cross_cats = Category.where(id: @subdomain.category_ids.to_s.split(','), show_in_crosssell: true)
      else; @cross_cats = Category.where(:show_in_crosssell => true); end
      page = render 'layouts/applicationpr', :layout => 'applicationpr'
      page
    end
  end


  get :sspc, :with => :id do
    require 'translit'
    @product = Product.find_by_id(params[:id])
    idss = @product.id
    str = @product.header
    tt1 = @product.header
    tt = Translit.convert(str, :english).to_s.gsub("'", "").downcase


    #@product_compl = ProductComplect.where(product_id: params[:id])
    #return @product_compl.to_json
    #return tt
    redirect url("/product/#{idss}/#{tt}")

  end




#  get :ss, :with => :id do
#    puts "get :product, :with => :id do sessions.rb"
#    @params = params
#    @dsc = DscntClass.new.some_method
#    @id = params[:id].to_i
#    erb :'test/product'
#  end

end

