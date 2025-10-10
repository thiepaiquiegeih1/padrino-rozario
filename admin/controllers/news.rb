# encoding: utf-8
Rozario::Admin.controllers :news do

  get :index do
    @title = "News"
    #@news = News.all
    @news = News.order('id desc').paginate(:page => params[:page], :per_page => 20)
    render 'news/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'news')
    @news = News.new
    @news.seo = Seo.new
    render 'news/new'
  end

  post :create do
    @news = News.new(params[:news])
    @news[:slug] = @news[:title].to_lat unless @news[:slug].present?
    if @news.save
      @title = pat(:create_title, :model => "news #{@news.id}")
      flash[:success] = pat(:create_success, :model => 'News')
      params[:save_and_continue] ? redirect(url(:news, :index)) : redirect(url(:news, :edit, :id => @news.id))
    else
      @title = pat(:create_title, :model => 'news')
      flash.now[:error] = pat(:create_error, :model => 'news')
      render 'news/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "news #{params[:id]}")
    @news = News.find(params[:id])
    @news.seo = Seo.new unless @news.seo.present?
    if @news
      render 'news/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'news', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "news #{params[:id]}")
    @news = News.find(params[:id])
    if @news
      if @news.update_attributes(params[:news])
        flash[:success] = pat(:update_success, :model => 'News', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:news, :index)) :
          redirect(url(:news, :edit, :id => @news.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'news')
        render 'news/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'news', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "News"
    news = News.find(params[:id])
    if news
      if news.destroy
        flash[:success] = pat(:delete_success, :model => 'News', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'news')
      end
      redirect url(:news, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'news', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "News"
    unless params[:news_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'news')
      redirect(url(:news, :index))
    end
    ids = params[:news_ids].split(',').map(&:strip).map(&:to_i)
    news = News.find(ids)

    if News.destroy news

      flash[:success] = pat(:destroy_many_success, :model => 'News', :ids => "#{ids.to_sentence}")
    end
    redirect url(:news, :index)
  end
end
