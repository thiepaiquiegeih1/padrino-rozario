# encoding: utf-8
Rozario::Admin.controllers :photos do
  get :index do
    @title = "Photos"
    #@photos = Photo.all
    @photos = Photo.order('id desc').paginate(:page => params[:page], :per_page => 20)
    render 'photos/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'photo')
    @photo = Photo.new
    @albums = Album.all(:select => 'title, id')
    render 'photos/new'
  end

  post :create do
    @photo = Photo.new(params[:photo])
    if @photo.save
      @title = pat(:create_title, :model => "photo #{@photo.id}")
      flash[:success] = pat(:create_success, :model => 'Photo')
      params[:save_and_continue] ? redirect(url(:photos, :index)) : redirect(url(:photos, :edit, :id => @photo.id))
    else
      @title = pat(:create_title, :model => 'photo')
      flash.now[:error] = pat(:create_error, :model => 'photo')
      render 'photos/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "photo #{params[:id]}")
    @photo = Photo.find(params[:id])
    @albums = Album.all(:select => 'title, id')
    if @photo
      render 'photos/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'photo', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "photo #{params[:id]}")
    @photo = Photo.find(params[:id])
    if @photo
      if @photo.update_attributes(params[:photo])
        flash[:success] = pat(:update_success, :model => 'Photo', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:photos, :index)) :
          redirect(url(:photos, :edit, :id => @photo.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'photo')
        render 'photos/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'photo', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Photos"
    photo = Photo.find(params[:id])
    if photo
      if photo.destroy
        flash[:success] = pat(:delete_success, :model => 'Photo', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'photo')
      end
      redirect url(:photos, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'photo', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Photos"
    unless params[:photo_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'photo')
      redirect(url(:photos, :index))
    end
    ids = params[:photo_ids].split(',').map(&:strip).map(&:to_i)
    photos = Photo.find(ids)
    
    if Photo.destroy photos
    
      flash[:success] = pat(:destroy_many_success, :model => 'Photos', :ids => "#{ids.to_sentence}")
    end
    redirect url(:photos, :index)
  end
end
