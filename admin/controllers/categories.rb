# encoding: utf-8
Rozario::Admin.controllers :categories do
  get :index do
    @title = "Categories"
    #@categories = Category.all
    @categories = Category.order('id desc').paginate(:page => params[:page], :per_page => 20)
    render 'categories/index'
  end

  post :showcase do
    error(404) if params[:products].nil? || params[:products].empty?
    JSON.parse(params[:products]).each do |x|
      product = Product.find(x["id"])
      product.orderp = x["order"]
      product.save
    end
    'OK'
  end

  get :showcase do
    @category = params[:id].nil? ? Category.first : Category.find(params[:id])
    @categories = Category.all
    @products = @category.products.sort_by {|x| x.orderp }
    render 'categories/showcase'
  end

  get :new do
    @title = pat(:new_title, :model => 'category')
    @category = Category.new
    @categories = Category.all(:select => 'title, id')
    @categorygroups = Categorygroup.all
    @slideshows = Slideshow.order('created_at ASC').all(:select => 'title, id')
    @category.seo = Seo.new
    render 'categories/new'
  end

  post :create do
    pdata = params[:category]

    if pdata["categorygroup_id"]
        pdata[:categorygroups] = Categorygroup.find(pdata["categorygroup_id"])
    end

    pdata.delete "categorygroup_id"
    @category = Category.new(pdata)
    @category[:slug] = @category[:title].to_lat unless @category[:slug].present?
    if @category.save
      @title = pat(:create_title, :model => "category #{@category.id}")
      flash[:success] = pat(:create_success, :model => 'Category')
      params[:save_and_continue] ? redirect(url(:categories, :index)) : redirect(url(:categories, :edit, :id => @category.id))
    else
      @title = pat(:create_title, :model => 'category')
      flash.now[:error] = pat(:create_error, :model => 'category')
      render 'categories/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "category #{params[:id]}")
    @category = Category.find(params[:id])
    @categories = Category.all(:select => 'title, id')
    @categorygroups = Categorygroup.all
    @slideshows = Slideshow.order('created_at ASC').all(:select => 'title, id')
    @group_ids = @category.categorygroups.map {|s| "'" + s.id.to_s + "'"}.compact
    @group_ids = @group_ids.join(", ")
    @category.seo = Seo.new unless @category.seo.present?
    @enable_seo_texts = true
    if @category
      render 'categories/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'category', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "category #{params[:id]}")
    @category = Category.find(params[:id])
    if @category
      pdata = params[:category]

      if pdata["categorygroup_id"]
        pdata[:categorygroups] = Categorygroup.find(pdata["categorygroup_id"])
      end

      pdata.delete "categorygroup_id"
      if @category.update_attributes(pdata)
        unless params[:change2].blank?
          if params[:change1] == "Увеличить на" && params[:change3] == "процентов"
            @category.products.update_all("price = price + (price * #{params[:change2].to_i} / 100)")
            @category.products.update_all("small_price = small_price + (small_price * #{params[:change2].to_i} / 100)")
            @category.products.update_all("lux_price = lux_price + (lux_price * #{params[:change2].to_i} / 100)")
          end
          if params[:change1] == "Уменьшить на" && params[:change3] == "процентов"
            @category.products.update_all("price = price - (price * #{params[:change2].to_i} / 100)")
            @category.products.update_all("small_price = small_price - (small_price * #{params[:change2].to_i} / 100)")
            @category.products.update_all("lux_price = lux_price - (lux_price * #{params[:change2].to_i} / 100)")
          end
          if params[:change1] == "Увеличить на" && params[:change3] == "рублей"
            @category.products.update_all("price = price + #{params[:change2].to_i}")
            @category.products.update_all("small_price = small_price + #{params[:change2].to_i}")
            @category.products.update_all("lux_price = lux_price + #{params[:change2].to_i}")
          end
          if params[:change1] == "Уменьшить на" && params[:change3] == "рублей"
            @category.products.update_all("price = price - #{params[:change2].to_i}")
            @category.products.update_all("small_price = small_price - #{params[:change2].to_i}")
            @category.products.update_all("lux_price = lux_price - #{params[:change2].to_i}")
          end
        end
        flash[:success] = pat(:update_success, :model => 'Category', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:categories, :index)) :
          redirect(url(:categories, :edit, :id => @category.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'category')
        render 'categories/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'category', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Categories"
    category = Category.find(params[:id])
    if category
      if category.destroy
        flash[:success] = pat(:delete_success, :model => 'Category', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'category')
      end
      redirect url(:categories, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'category', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Categories"
    unless params[:category_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'category')
      redirect(url(:categories, :index))
    end
    ids = params[:category_ids].split(',').map(&:strip).map(&:to_i)
    categories = Category.find(ids)

    if Category.destroy categories

      flash[:success] = pat(:destroy_many_success, :model => 'Categories', :ids => "#{ids.to_sentence}")
    end
    redirect url(:categories, :index)
  end

  get :search do
    type = params['type']
    query = strip_tags(params[:query]).mb_chars.downcase

    if params[:query].length > 0
      @categories = Category.where("#{type} like ?", "%#{query}%").all.paginate(:page => params[:page], :per_page => 20)
      if @categories.first.nil?
        flash[:error] = "Ничего не найдено :("
        redirect back
      else
        flash[:success] = "Найдено"
        render 'categories/index'
      end
    else
      @categories = Category.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
      flash[:error] = "Введите запрос"
      render 'categories/index'
    end
  end
end
