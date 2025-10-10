# encoding: utf-8
Rozario::Admin.controllers :slideshows do

  get :index do
    @title = "Slideshows"
    #@slideshows = Slideshow.all
    @slideshows = Slideshow.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
    render 'slideshows/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'slideshow')
    @slideshow = Slideshow.new
    render 'slideshows/new'
  end

  post :create do
    @slideshow = Slideshow.new(params[:slideshow])
    if @slideshow.save
      @title = pat(:create_title, :model => "slideshow #{@slideshow.id}")
      flash[:success] = pat(:create_success, :model => 'Slideshow')
      params[:save_and_continue] ? redirect(url(:slideshows, :index)) : redirect(url(:slideshows, :edit, :id => @slideshow.id))
    else
      @title = pat(:create_title, :model => 'slideshow')
      flash.now[:error] = pat(:create_error, :model => 'slideshow')
      render 'slideshows/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "slideshow #{params[:id]}")
    @slideshow = Slideshow.find(params[:id])
    if @slideshow
      render 'slideshows/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'slideshow', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "slideshow #{params[:id]}")
    @slideshow = Slideshow.find(params[:id])
    if @slideshow
      if @slideshow.update_attributes(params[:slideshow])
        flash[:success] = pat(:update_success, :model => 'Slideshow', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:slideshows, :index)) :
          redirect(url(:slideshows, :edit, :id => @slideshow.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'slideshow')
        render 'slideshows/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'slideshow', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Slideshows"
    slideshow = Slideshow.find(params[:id])
    if slideshow
      if slideshow.destroy
        flash[:success] = pat(:delete_success, :model => 'Slideshow', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'slideshow')
      end
      redirect url(:slideshows, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'slideshow', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Slideshows"
    unless params[:slideshow_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'slideshow')
      redirect(url(:slideshows, :index))
    end
    ids = params[:slideshow_ids].split(',').map(&:strip).map(&:to_i)
    slideshows = Slideshow.find(ids)
    
    if Slideshow.destroy slideshows
      flash[:success] = pat(:destroy_many_success, :model => 'Slideshows', :ids => "#{ids.to_sentence}")
    end
    redirect url(:slideshows, :index)
  end
end
