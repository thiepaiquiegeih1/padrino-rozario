# encoding: utf-8

Rozario::Admin.controllers :regions do
  get :index do
    redirect url('regions/subdomains', :index)
  end
end

Rozario::Admin.controllers 'regions/subdomains' do
  get :index do
    @title = "Поддомены"
    @subdomains = Subdomain.order('id desc').paginate(:page => params[:page], :per_page => 20)
    @search = false
    render 'regions/subdomains/index'
  end

  get :new do
    @title = "Добавить поддомен"
    @subdomain = Subdomain.new
    render 'regions/subdomains/new'
  end

  post :create do
    @subdomain = Subdomain.new(params[:subdomain])
    if @subdomain.save
      @title = pat(:create_title, :model => "subdomain #{@subdomain.id}")
      flash[:success] = pat(:create_success, :model => 'Subdomain')
      params[:save_and_continue] ? redirect(url(:'regions/subdomains', :index)) : redirect(url(:'regions/subdomains', :edit, :id => @subdomain.id))
    else
      @title = pat(:create_title, :model => 'subdomain')
      flash.now[:error] = pat(:create_error, :model => 'subdomain')
      render 'regions/subdomains/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "subdomain #{params[:id]}")
    @subdomain = Subdomain.find(params[:id])

    sbd_cgs= CategoriesCategorygroup.where(categorygroup_id: @subdomain.categorygroup_ids).pluck(:category_id)
    #sbdp_cgs = CategoriesCategorygroup.where(categorygroup_id: sbdp.categorygroup_ids).pluck(:category_id)
    c_cg_ids = sbd_cgs + Category.where(id: @subdomain.subdom_cat_ids) # + sbdp_cgs
    @cat_collection = Category.where(id: c_cg_ids.uniq)
    @group_collection = Categorygroup.where(:id => @subdomain.categorygroup_ids)
    @cat_display = @cat_collection + LeftmenuCats.where(leftmenu_id: Leftmenu.where(id: @subdomain.leftmenu_id).first)
    cat_display1 = @cat_collection.pluck(:id) + LeftmenuCats.where(leftmenu_id: Leftmenu.where(id: @subdomain.leftmenu_id).first).pluck(:category_id)
    @cat_display = Category.where(id: cat_display1.uniq)

    if @subdomain
      render 'regions/subdomains/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'subdomain', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    pdata = params[:subdomain]

    if !pdata["categorygroup_ids"]
        pdata["categorygroup_ids"] = []
    end

    if !pdata["category_ids"]
        pdata["category_ids"] = []
    end

    if !pdata["leftmenu_id"]
        pdata["leftmenu_id"] = nil
    end

    if !pdata["default_category_id"]
        pdata["default_category_id"] = nil
    end

    @title = pat(:update_title, :model => "subdomain #{params[:id]}")
    @subdomain = Subdomain.find(params[:id])
    if @subdomain
      if @subdomain.update_attributes(pdata)
        flash[:success] = pat(:update_success, :model => 'Subdomain', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:'regions/subdomains', :index)) :
          redirect(url(:'regions/subdomains', :edit, :id => @subdomain.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'subdomain')
        render 'regions/subdomains/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'subdomain', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Subdomains"
    subdomain = Subdomain.find(params[:id])
    if subdomain
      if subdomain.destroy
        flash[:success] = pat(:delete_success, :model => 'Subdomain', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'subdomain')
      end
      redirect url('regions/subdomains', :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'subdomain', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Subdomains"
    unless params[:subdomains_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'subdomain')
      redirect(url(:'regions/subdomains', :index))
    end
    ids = params[:subdomains_ids].split(',').map(&:strip).map(&:to_i)
    subdomains = Subdomain.find(ids)

    if Subdomain.destroy subdomains

      flash[:success] = pat(:destroy_many_success, :model => 'Subdomains', :ids => "#{ids.to_sentence}")
    end
    redirect url('regions/subdomains', :index)
  end

  get :search do
    query = strip_tags(params[:query]).mb_chars.downcase
    if query.length >= 3
      @subdomains = Subdomain.where("lower(city) like ?", "%#{query}%").all
      if @subdomains.first.nil?
        flash[:error] = "Ничего не найдено :("
        redirect back
      else
        @search = true
        render 'regions/subdomains/index'
      end
    end
  end

end

Rozario::Admin.controllers 'regions/subdomain_pools' do
  get :index do
    @title = "Subdomain_pools"
    @subdomain_pools = SubdomainPool.order('id desc').paginate(:page => params[:page], :per_page => 20)
    render 'regions/subdomain_pools/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'subdomain_pool')
    @subdomain_pool = SubdomainPool.new
    render 'regions/subdomain_pools/new'
  end

  post :create do
    @subdomain_pool = SubdomainPool.new(params[:subdomain_pool])
    if @subdomain_pool.save
      @title = pat(:create_title, :model => "subdomain_pool #{@subdomain_pool.id}")
      flash[:success] = pat(:create_success, :model => 'SubdomainPool')
      params[:save_and_continue] ? redirect(url(:'regions/subdomain_pools', :index)) : redirect(url(:'regions/subdomain_pools', :edit, :id => @subdomain_pool.id))
    else
      @title = pat(:create_title, :model => 'subdomain_pool')
      flash.now[:error] = pat(:create_error, :model => 'subdomain_pool')
      render 'regions/subdomain_pools/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "subdomain_pool #{params[:id]}")
    @subdomain_pool = SubdomainPool.find(params[:id])

    categories_by_cg_ids = CategoriesCategorygroup.where(categorygroup_id: @subdomain_pool.categorygroup_ids).pluck(:category_id)
    tmp_ids = categories_by_cg_ids + @subdomain_pool.category_ids
    @cat_collection = Category.where(id: tmp_ids.uniq)
    @subdompool_collection = @cat_collection + Categorygroup.where(:id => @subdomain_pool.categorygroup_ids)
    @group_collection = Categorygroup.where(:id => @subdomain_pool.categorygroup_ids)
    cat_display1 = @cat_collection.pluck(:id) + LeftmenuCats.where(leftmenu_id: Leftmenu.where(id: @subdomain_pool.leftmenu_id).first).pluck(:category_id)
    @cat_display = Category.where(id: cat_display1.uniq)

    if @subdomain_pool
        @subdomain_ids = @subdomain_pool.subdomains.map {|s| "'" + s.id.to_s + "'"}.compact
        @subdomain_ids = @subdomain_ids.join(", ")
        render 'regions/subdomain_pools/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'subdomain_pool', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    pdata = params[:subdomain_pool]

    if !pdata["categorygroup_ids"]
        pdata["categorygroup_ids"] = []
    end

    if !pdata["category_ids"]
        pdata["category_ids"] = []
    end

    if !pdata["leftmenu_id"]
        pdata["leftmenu_id"] = nil
    end

    if !pdata["default_category_id"]
        pdata["default_category_id"] = nil
    end

    if !pdata["crosssel_categorygroup_id"]
        pdata["crosssel_categorygroup_id"] = nil
    end

    @title = pat(:update_title, :model => "subdomain_pool #{params[:id]}")
    @subdomain_pool = SubdomainPool.find(params[:id])
    if @subdomain_pool
      if @subdomain_pool.update_attributes(pdata)
        flash[:success] = pat(:update_success, :model => 'Subdomain_pool', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:'regions/subdomain_pools', :index)) :
          redirect(url(:'regions/subdomain_pools', :edit, :id => @subdomain_pool.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'subdomain_pool')
        render 'regions/subdomain_pools/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'subdomain_pool', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Subdomain_pools"
    subdomain_pool = SubdomainPool.find(params[:id])
    if subdomain_pool
      if subdomain_pool.destroy
        flash[:success] = pat(:delete_success, :model => 'Subdomain_pool', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'subdomain_pool')
      end
      redirect url('regions/subdomain_pools', :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'subdomain_pool', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Subdomain_pools"
    unless params[:subdomain_pool_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'subdomain_pool')
      redirect(url(:'regions/subdomain_pools', :index))
    end
    ids = params[:subdomain_pool_ids].split(',').map(&:strip).map(&:to_i)
    subdomain_pools = SubdomainPool.find(ids)

    if SubdomainPool.destroy subdomain_pools

      flash[:success] = pat(:destroy_many_success, :model => 'Subdomain_pools', :ids => "#{ids.to_sentence}")
    end
    redirect url('regions/subdomain_pools', :index)
  end
end
