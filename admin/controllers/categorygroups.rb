# encoding: utf-8
Rozario::Admin.controllers :categorygroups do
  get :index do
    @title = "Categorygroups"
    @categorygroups = Categorygroup.order('id desc').paginate(:page => params[:page], :per_page => 20)
    render 'categorygroups/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'categorygroup')
    @categorygroup = Categorygroup.new
    @categories = Category.all
    render 'categorygroups/new'
  end

  post :create do
    pdata = params[:categorygroup]

    if pdata["category_id"]
      pdata[:categories] = Category.find(pdata["category_id"])
    end

    pdata.delete "category_id"

    @categorygroup = Categorygroup.new(pdata)
    if @categorygroup.save
      @title = pat(:create_title, :model => "categorygroup #{@categorygroup.id}")
      flash[:success] = pat(:create_success, :model => 'Categorygroup')
      params[:save_and_continue] ? redirect(url(:categorygroups, :index)) : redirect(url(:categorygroups, :edit, :id => @categorygroup.id))
    else
      @title = pat(:create_title, :model => 'categorygroup')
      flash.now[:error] = pat(:create_error, :model => 'categorygroup')
      render 'categorygroups/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "categorygroup #{params[:id]}")
    @categorygroup = Categorygroup.find(params[:id])
    @categories = Category.all
    @cat_ids = @categorygroup.categories.map {|s| "'" + s.id.to_s + "'"}.compact
    @cat_ids = @cat_ids.join(", ")
    if @categorygroup
      render 'categorygroups/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'categorygroup', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    pdata = params[:categorygroup]

    if !pdata["category_ids"]
        pdata["category_ids"] = []
    end

    pdata.delete "category_id"

    @title = pat(:update_title, :model => "categorygroup #{params[:id]}")
    @categorygroup = Categorygroup.find(params[:id])
    if @categorygroup
      if @categorygroup.update_attributes(pdata)
        flash[:success] = pat(:update_success, :model => 'Categorygroup', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:categorygroups, :index)) :
          redirect(url(:categorygroups, :edit, :id => @categorygroup.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'categorygroup')
        render 'categorygroups/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'categorygroup', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Categorygroups"
    categorygroup = Categorygroup.find(params[:id])
    if categorygroup
      if categorygroup.destroy
        flash[:success] = pat(:delete_success, :model => 'Categorygroup', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'categorygroup')
      end
      redirect url(:categorygroups, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'categorygroup', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Categorygroups"
    unless params[:categorygroup_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'categorygroup')
      redirect(url(:categorygroups, :index))
    end
    ids = params[:categorygroup_ids].split(',').map(&:strip).map(&:to_i)
    categorygroups = Categorygroup.find(ids)

    if Categorygroup.destroy categorygroups

      flash[:success] = pat(:destroy_many_success, :model => 'Categorygroups', :ids => "#{ids.to_sentence}")
    end
    redirect url(:categorygroups, :index)
  end
end
