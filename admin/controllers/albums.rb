# encoding: utf-8
Rozario::Admin.controllers :albums do
  get :index do
    @title = "Albums"
    #@albums = Album.all
    @albums = Album.order('id desc').paginate(:page => params[:page], :per_page => 20)
    render 'albums/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'album')
    @album = Album.new
    render 'albums/new'
  end

  post :create do
    @album = Album.new(params[:album])
    if @album.save
      @title = pat(:create_title, :model => "album #{@album.id}")
      flash[:success] = pat(:create_success, :model => 'Album')
      params[:save_and_continue] ? redirect(url(:albums, :index)) : redirect(url(:albums, :edit, :id => @album.id))
    else
      @title = pat(:create_title, :model => 'album')
      flash.now[:error] = pat(:create_error, :model => 'album')
      render 'albums/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "album #{params[:id]}")
    @album = Album.find(params[:id])
    if @album
      render 'albums/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'album', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "album #{params[:id]}")
    @album = Album.find(params[:id])
    if @album
      if @album.update_attributes(params[:album])
        flash[:success] = pat(:update_success, :model => 'Album', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:albums, :index)) :
          redirect(url(:albums, :edit, :id => @album.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'album')
        render 'albums/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'album', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Albums"
    album = Album.find(params[:id])
    if album
      if album.destroy
        flash[:success] = pat(:delete_success, :model => 'Album', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'album')
      end
      redirect url(:albums, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'album', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Albums"
    unless params[:album_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'album')
      redirect(url(:albums, :index))
    end
    ids = params[:album_ids].split(',').map(&:strip).map(&:to_i)
    albums = Album.find(ids)
    
    if Album.destroy albums
    
      flash[:success] = pat(:destroy_many_success, :model => 'Albums', :ids => "#{ids.to_sentence}")
    end
    redirect url(:albums, :index)
  end
end
