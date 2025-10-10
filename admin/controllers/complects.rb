# encoding: utf-8
Rozario::Admin.controllers :complects do
  get :index do
    @title = "Complects"
    @complects = Complect.all
    render 'complects/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'complect')
    @complect = Complect.new
    render 'complects/new'
  end

  post :create do
    @complect = Complect.new(params[:complect])
    if @complect.save
      @title = pat(:create_title, :model => "complect #{@complect.id}")
      flash[:success] = pat(:create_success, :model => 'Complect')
      params[:save_and_continue] ? redirect(url(:complects, :index)) : redirect(url(:complects, :edit, :id => @complect.id))
    else
      @title = pat(:create_title, :model => 'complect')
      flash.now[:error] = pat(:create_error, :model => 'complect')
      render 'complects/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "complect #{params[:id]}")
    @complect = Complect.find(params[:id])
    if @complect
      render 'complects/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'complect', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "complect #{params[:id]}")
    @complect = Complect.find(params[:id])
    if @complect
      if @complect.update_attributes(params[:complect])
        flash[:success] = pat(:update_success, :model => 'Complect', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:complects, :index)) :
          redirect(url(:complects, :edit, :id => @complect.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'complect')
        render 'complects/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'complect', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Complects"
    complect = Complect.find(params[:id])
    if complect
      if complect.destroy
        flash[:success] = pat(:delete_success, :model => 'Complect', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'complect')
      end
      redirect url(:complects, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'complect', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Complects"
    unless params[:complect_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'complect')
      redirect(url(:complects, :index))
    end
    ids = params[:complect_ids].split(',').map(&:strip).map(&:to_i)
    complects = Complect.find(ids)
    
    if Complect.destroy complects
    
      flash[:success] = pat(:destroy_many_success, :model => 'Complects', :ids => "#{ids.to_sentence}")
    end
    redirect url(:complects, :index)
  end
end
