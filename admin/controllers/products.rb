# encoding: utf-8
Rozario::Admin.controllers :products do

  get :index do
    cache_control :no_cache
    @title = "Products"
    @products = Product.order('id desc').paginate(:page => params[:page], :per_page => 20)
    @categories = Category.all(:select => 'title, id')
    @category_id = nil
    render 'products/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'product')
    @product = Product.new
    @product.trick_price = true
    @categories = Category.all(:select => 'title, id')
    @complects = Complect.all(:select => 'title, id')
    @tags = Tag.all(:select => 'title, id')
    @tag_complects = "[]"
    @product_complects = "[]"
    @product.seo = Seo.new
    render 'products/new'
  end

  post :create do

    pdata = params[:product]

    if pdata[:category_id]
      pdata["categories"] = Category.find(pdata[:category_id])
    end

    complects = pdata[:complect_id] ? Complect.find(pdata[:complect_id]) : []
    tags = pdata[:tag_id] ? Tag.find(pdata[:tag_id]) : []

    pdata.delete "tag_id"
    pdata.delete "complect_id"
    pdata.delete "category_id"

    @product = Product.new(pdata)
    @product[:slug] = @product[:header].to_lat unless @product[:slug].present?
    if @product.save

      complects.each do |c|
        ProductComplect.create(
          product_id: @product.id,
          complect_id: c.id,
          price: params[:prices][c.id.to_s],
          price_1990: nil,
          price_2890: nil,
          price_3790: nil,
          image: params[:images][c.id.to_s]
        )
        tags.each do |t|
          TagComplect.create(
            product_id: @product.id,
            complect_id: c.id,
            tag_id: t.id,
            count: params[:counts][c.id.to_s][t.id.to_s]
          )
        end
      end
      params[:save_and_continue] ? redirect(url(:products, :index)) : redirect(url(:products, :edit, :id => @product.id))
    else
      @title = pat(:create_title, :model => 'product')
      flash.now[:error] = pat(:create_error, :model => 'product')
      render 'products/new'
    end

  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "product #{params[:id]}")

    @product = Product.find(params[:id])
    @pc_ids = ''
    @product.seo = Seo.new unless @product.seo.present?
    @product.categories.each do |cat|
      @pc_ids += "'" + cat.id.to_s + "',"
    end
    @pt_ids = ''
    @product.tags.each do |tag|
      @pt_ids += "'" + tag.id.to_s + "',"
    end
    @pct_ids = ''
    @product.complects.each do |complect|
      @pct_ids += "'" + complect.id.to_s + "',"
    end

    @categories = Category.all(:select => 'title, id')
    @tags = Tag.all(:select => 'title, id')
    @complects = Complect.all(:select => 'title,id')

    @tag_complects = @product.tag_complects.to_json
    @product_complects = @product.product_complects.to_json

    if @product
      render 'products/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'product', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "product #{params[:id]}")

    @product = Product.find(params[:id])

    existed_complects = @product.product_complects
    existed_tags = @product.tag_complects

    pdata = params[:product]

    #pdata["price"] = pdata["price"].sub(",", ".")
    
    pdata["categories"] = Category.find(pdata[:category_id]) if pdata[:category_id]

    complects = pdata[:complect_id] ? Complect.find(pdata[:complect_id]) : []

    tags = pdata[:tag_id] ? Tag.find(pdata[:tag_id]) : []
    #tags = Tag.find(pdata[:tag_id])
    #complects = Complect.find(pdata[:complect_id])
    images = params[:images].nil? ? {} : params[:images]

    pdata.delete "category_id"
    pdata.delete "tag_id"
    pdata.delete "complect_id"

    if @product
      if @product.update_attributes(pdata)
    if complects
      complects.each do |complect|
      if (pc = @product.product_complects.where(complect_id: complect.id).first)
        pc.update_attributes(
        price: params[:prices][complect.id.to_s],
        image: images[complect.id.to_s]
        )
      else
        ProductComplect.create(
        product_id: @product.id,
        complect_id: complect.id,
        price: params[:prices][complect.id.to_s],
        image: images[complect.id.to_s]
        )
      end
      tags.each do |tag|
        if (pt = @product.tag_complects.where(tag_id: tag.id, complect_id: complect.id).first)
        pt.update_attributes(count: params[:counts][complect.id.to_s][tag.id.to_s])
        else
        TagComplect.create(
          product_id: @product.id,
          tag_id: tag.id,
          complect_id: complect.id,
          count: params[:counts][complect.id.to_s][tag.id.to_s]
        )
        end
      end
      end
      #   p existed_complects
      #   p @product.product_complects
      existed_complects.select {|x| !complects.map {|x| x.id }.include? x.complect_id }.each {|x| x.destroy }
      #(existed_complects-@product.product_complects).each {|x| x.destroy }
      existed_tags.select {|x| !tags.map {|x| x.id }.include? x.tag_id }.each {|x| x.destroy }
      # (existed_tags-@product.tag_complects).each {|x| x.destroy }
    end



        flash[:success] = pat(:update_success, :model => 'Product', :id =>  "#{params[:id]}")

        params[:save_and_continue] ?
        redirect(url(:products, :index)) :
        redirect(url(:products, :edit, :id => @product.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'product')
        render 'products/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'product', :id => "#{params[:id]}")
      halt 404
    end
  end


#   put :update, :with => :id do
#     @title = pat(:update_title, :model => "product #{params[:id]}")
#     @product = Product.find(params[:id])
#     pdata = params[:product]
#     pdata["price"] = pdata["price"].sub(",", ".")
#     pdata["categories"] = Category.find(pdata[:category_id])
#     if pdata[:tag_id].blank?
#       pdata["tags"] = []
#     else
#       pdata["tags"] = Tag.find(pdata[:tag_id])
#     end
#     pdata.delete "category_id"
#     pdata.delete "tag_id"
#     if params[:price_from_standart] == "1"
#       pdata["small_price"] = pdata["price"].to_f * 0.6
#       pdata["lux_price"] = pdata["price"].to_f * 1.4
#     end
#     if @product
#       if @product.update_attributes(pdata)
#         flowers = params[:flower].present? ? params[:flower] : []
#         @product.add_flowers(flowers, params[:flowers_from_standarts] == "1")
#         flash[:success] = pat(:update_success, :model => 'Product', :id =>  "#{params[:id]}")
#         params[:save_and_continue] ?
#           redirect(url(:products, :index)) :
#           redirect(url(:products, :edit, :id => @product.id))
#       else
#         flash.now[:error] = pat(:update_error, :model => 'product')
#         render 'products/edit'
#       end
#     else
#       flash[:warning] = pat(:update_warning, :model => 'product', :id => "#{params[:id]}")
#       halt 404
#     end
#   end

  delete :destroy, :with => :id do
    @title = "Products"
    product = Product.find(params[:id])
    if product
      if product.destroy
        flash[:success] = pat(:delete_success, :model => 'Product', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'product')
      end
      redirect url(:products, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'product', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Products"
    unless params[:product_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'product')
      redirect(url(:products, :index))
    end
    ids = params[:product_ids].split(',').map(&:strip).map(&:to_i)
    products = Product.find(ids)
    if Product.destroy products
      flash[:success] = pat(:destroy_many_success, :model => 'Products', :ids => "#{ids.to_sentence}")
    end
    redirect url(:products, :index)
  end

  get :search do
    cache_control :no_cache
    query = strip_tags(params[:query]).mb_chars.downcase
    query = query.strip # удаление пробелов в начале и конце
    query = query.gsub(/\s+/, ' ') # замена нескольких пробелов на один
    if query.length >= 3
      #@products = Product.where("lower(title) like ?", "%#{query}%").all
      #@products = Product.where("title COLLATE utf8_general_ci LIKE ?", "%#{query}%").all
      #@products = Product.where("title COLLATE utf8_general_ci = ?", query).all
      require 'fuzzystringmatch'
      jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
      # jarow = FuzzyStringMatch::JaroWinkler.create(:native)
      @products = Product.all # Фильтруем и сортируем продукты
        .map { |product| [product, jarow.getDistance(product.header, query)] } # Создаем массив пар [продукт, расстояние]
        .select { |product, distance| distance > 0.5 }                         # Фильтруем по значению расстояния
        .sort_by { |product, distance| -distance }                             # Сортируем по убыванию расстояния
        .map(&:first)                                                          # Извлекаем только продукты из массива пар
        .take(128)                                                             # Ограничиваем количество результатов
      if @products.first.nil?
        flash[:error] = "Ничего не найдено :("
        redirect back
      else
        render 'products/search'
      end
    else
      flash[:error] = "Короткий запрос :("
      redirect back
    end
  end

  # get :test do
  #   # content_type :html
  #   # content_type :plain
  #   # content_type :json
  #   query = "Чистый лист" # query = strip_tags(params[:query]).mb_chars.downcase
  #   #@products = Product.where("lower(title) like ?", "%#{query}%").all
  #   #@products = Product.where("title COLLATE utf8_general_ci LIKE ?", "%#{query}%").all
  #   #@products = Product.where("title COLLATE utf8_general_ci = ?", query).all
  #   require 'fuzzystringmatch'
  #   jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
  #   # jarow = FuzzyStringMatch::JaroWinkler.create(:native)
  #   @products = Product.all # Фильтруем и сортируем продукты
  #     .map { |product| [product, jarow.getDistance(product.header, query)] } # Создаем массив пар [продукт, расстояние]
  #     .select { |product, distance| distance > 0.7 }                         # Фильтруем по значению расстояния
  #     .sort_by { |product, distance| -distance }                             # Сортируем по убыванию расстояния
  #     .map(&:first)                                                          # Извлекаем только продукты из массива пар
  #     .take(128)                                                             # Ограничиваем количество результатов
  #   render 'products/search'
  # end

  get :category do
    if params[:category_id].blank?
      redirect url(:products, :index)
    else
      ids = params[:category_id].map {|a| a.to_i}
      joins = "INNER JOIN categories_products ON products.id = categories_products.product_id"
      @products = Product.joins(joins).where('categories_products.category_id' => ids).order('id desc').paginate(:page => params[:page], :per_page => 20)
      @categories = Category.all(:select => 'title, id')
      render 'products/index'
    end
  end

end
