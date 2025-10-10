# encoding: utf-8
Rozario::Admin.controllers :discounts do
  get :index do
    redirect url('discounts/subdomains', :index)
  end
end

Rozario::Admin.controllers :'discounts/subdomains' do

  get :index do
    @title = "Поддомены"
    @subdomains = Subdomain.order('id desc').paginate(:page => params[:page], :per_page => 20)
    @search = false
    render 'discounts/subdomains/index'
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "subdomain #{params[:id]}")
    @subdomain = Subdomain.find(params[:id])

    categories_by_cg_ids = CategoriesCategorygroup.where(categorygroup_id: @subdomain.categorygroup_ids).pluck(:category_id)
    tmp_ids = categories_by_cg_ids + @subdomain.category_ids
    @cat_collection = Category.where(id: tmp_ids.uniq)

    if @subdomain
      render 'discounts/subdomains/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'subdomain', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "subdomain #{params[:id]}")
    @subdomain = Subdomain.find(params[:id])
    if @subdomain
      fcategories = params[:subdomain][:categories_subdomains_attributes]
      fcategories.each do |index, c|
        c[:discount_status] = (["on", "true"].include? c[:discount_status]) ? 1 : 0
        catsub = CategoriesSubdomain.where(subdomain_id: @subdomain.id, category_id: c[:category_id])
        if !catsub.empty?
          catsub.update_all(c)
        else
          if c[:discount_in_rubles].to_i != 0 || c[:discount_in_percents].to_i != 0
            catsub = CategoriesSubdomain.create(
              :subdomain_id => @subdomain.id,
              :category_id => c[:category_id],
              :discount_status => c[:discount_status],
              :discount_period_id => c[:discount_period_id],
              :discount_in_rubles => c[:discount_in_rubles],
              :discount_in_percents => c[:discount_in_percents]
            )
          end
        end
      end
      flash[:success] = pat(:update_success, :model => 'Subdomain', :id =>  "#{params[:id]}")
      params[:save_and_continue] ?
        redirect(url(:'discounts/subdomains', :index)) :
        redirect(url(:'discounts/subdomains', :edit, :id => @subdomain.id))
    else
      flash[:warning] = pat(:update_warning, :model => 'subdomain', :id => "#{params[:id]}")
      halt 404
    end
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
        render 'discounts/subdomains/index'
      end
    end
  end
end

Rozario::Admin.controllers :'discounts/subdomain_pools' do

  get :index do
    @title = "Subdomain_pools"
    @subdomain_pools = SubdomainPool.order('id desc').paginate(:page => params[:page], :per_page => 20)
    render 'discounts/subdomain_pools/index'
  end

  get :search do
    query = strip_tags(params[:query]).mb_chars.downcase
    if query.length >= 3
      @subdomain_pools = SubdomainPool.where("lower(name) like ?", "%#{query}%").all
      if @subdomain_pools.first.nil?
        flash[:error] = "Ничего не найдено :("
        redirect back
      else
        @search = true
        render 'discounts/subdomain_pools/index'
      end
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "subdomain_pool #{params[:id]}")
    @subdomain_pool = SubdomainPool.find(params[:id])

    if @subdomain_pool
        render 'discounts/subdomain_pools/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'subdomain_pool', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "subdomain #{params[:id]}")
    @subdomain_pool = SubdomainPool.find(params[:id])
    if @subdomain_pool
      fcategories = params[:subdomain_pool][:categories_subdomain_pools_attributes]
      fcategories.each do |index, c|
        c[:discount_status] = (["on", "true"].include? c[:discount_status]) ? 1 : 0
        catsub = CategoriesSubdomainPool.where(subdomain_pool_id: @subdomain_pool.id, category_id: c[:category_id])
        if !catsub.empty?
          catsub.update_all(c)
        else
          if c[:discount_in_rubles].to_i != 0 || c[:discount_in_percents].to_i != 0
            catsub = CategoriesSubdomainPool.create(
              :subdomain_pool_id => @subdomain_pool.id,
              :category_id => c[:category_id],
              :discount_status => c[:discount_status],
              :discount_period_id => c[:discount_period_id],
              :discount_in_rubles => c[:discount_in_rubles],
              :discount_in_percents => c[:discount_in_percents]
            )
          end
        end
      end
      flash[:success] = pat(:update_success, :model => 'subdomain_pool', :id =>  "#{params[:id]}")
      params[:save_and_continue] ?
        redirect(url(:'discounts/subdomain_pools', :index)) :
        redirect(url(:'discounts/subdomain_pools', :edit, :id => @subdomain_pool.id))
    else
      flash[:warning] = pat(:update_warning, :model => 'subdomain_pool', :id => "#{params[:id]}")
      halt 404
    end
  end

end

Rozario::Admin.controllers :'discounts/categories' do
  get :index do
    @title = "Categories"
    @categories = Category.order('title')
    render 'discounts/categories/index'
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "category #{params[:id]}")
    @category = Category.find(params[:id])
    if @category
      render 'discounts/categories/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'category', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update do
    @title = pat(:update_title, :model => "category #{params[:id]}")
    fcategories = params[:category]
    fcategories.each do |index, c|
      category = Category.find(c[:id])
      if category
        category.update_attributes(c)
      else
        flash.now[:error] = pat(:update_error, :model => 'category')
        render 'discounts/categories/index'
      end
    end
    redirect(url(:'discounts/categories', :index))
  end

  Rozario::Admin.controllers :'discounts/discount_periods' do
    get :index do
      @title = "Discount_periods"
      @discount_periods = DiscountPeriods.all
      render 'discounts/discount_periods/index'
    end

    get :new do
      @title = pat(:new_title, :model => 'discount_periods')
      @discount_periods = DiscountPeriods.new
      render 'discounts/discount_periods/new'
    end

    post :create do
      @discount_periods = DiscountPeriods.new(params[:discount_periods])
      if @discount_periods.save
        @title = pat(:create_title, :model => "discount_periods #{@discount_periods.id}")
        flash[:success] = pat(:create_success, :model => 'DiscountPeriods')
        params[:save_and_continue] ? redirect(url(:'discounts/discount_periods', :index)) : redirect(url(:'discounts/discount_periods', :edit, :id => @discount_periods.id))
      else
        @title = pat(:create_title, :model => 'discount_periods')
        flash.now[:error] = pat(:create_error, :model => 'discount_periods')
        render 'discounts/discount_periods/new'
      end
    end

    get :edit, :with => :id do
      @title = pat(:edit_title, :model => "discount_periods #{params[:id]}")
      @discount_periods = DiscountPeriods.find(params[:id])
      if @discount_periods
        render 'discounts/discount_periods/edit'
      else
        flash[:warning] = pat(:create_error, :model => 'discount_periods', :id => "#{params[:id]}")
        halt 404
      end
    end

    put :update, :with => :id do
      @title = pat(:update_title, :model => "discount_periods #{params[:id]}")
      @discount_periods = DiscountPeriods.find(params[:id])
      if @discount_periods
        if @discount_periods.update_attributes(params[:discount_periods])
          flash[:success] = pat(:update_success, :model => 'Discount_periods', :id =>  "#{params[:id]}")
          params[:save_and_continue] ?
            redirect(url(:'discounts/discount_periods', :index)) :
            redirect(url(:'discounts/discount_periods', :edit, :id => @discount_periods.id))
        else
          flash.now[:error] = pat(:update_error, :model => 'discount_periods')
          render 'discounts/discount_periods/edit'
        end
      else
        flash[:warning] = pat(:update_warning, :model => 'discount_periods', :id => "#{params[:id]}")
        halt 404
      end
    end

    delete :destroy, :with => :id do
      @title = "Discount_periods"
      discount_periods = DiscountPeriods.find(params[:id])
      if discount_periods
        if discount_periods.destroy
          flash[:success] = pat(:delete_success, :model => 'Discount_periods', :id => "#{params[:id]}")
        else
          flash[:error] = pat(:delete_error, :model => 'discount_periods')
        end
        redirect url(:'discounts/discount_periods', :index)
      else
        flash[:warning] = pat(:delete_warning, :model => 'discount_periods', :id => "#{params[:id]}")
        halt 404
      end
    end

    delete :destroy_many do
      @title = "Discount_periods"
      unless params[:discount_periods_ids]
        flash[:error] = pat(:destroy_many_error, :model => 'discount_periods')
        redirect(url(:'discounts/discount_periods', :index))
      end
      ids = params[:discount_periods_ids].split(',').map(&:strip).map(&:to_i)
      discount_periods = DiscountPeriods.find(ids)

      if DiscountPeriods.destroy discount_periods

        flash[:success] = pat(:destroy_many_success, :model => 'Discount_periods', :ids => "#{ids.to_sentence}")
      end
      redirect url(:'discounts/discount_periods', :index)
    end
  end

end
