# encoding: utf-8

Rozario::Admin.controllers :seo do
  get :index do
    redirect url('seo/general', :index)
  end
end

Rozario::Admin.controllers :'seo/general' do
  get :index do
    @title = 'Общие настройки'
    @general = SeoGeneral.order('id ASC').paginate(:page => params[:general], :per_page => 20)
    render 'seo/general/index'
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "seo_general #{params[:id]}")

    @general = SeoGeneral.find(params[:id])

    if @general
      render 'seo/general/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'seo_general', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "seo_general #{params[:id]}")
    @general = SeoGeneral.find(params[:id])
    if @general
      if @general.update_attributes(params[:seo_general])
        flash[:success] = pat(:update_success, :model => 'SeoGeneral', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:'seo/general', :index)) :
          redirect(url(:'seo/general', :edit, :id => @general.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'seo_general')
        render 'seo/general/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'seo_general', :id => "#{params[:id]}")
      halt 404
    end
  end
end

Rozario::Admin.controllers :'seo/sitemap_generator' do
  get :index do
    render 'seo/sitemap_generator/index'
  end

  get :show do
    render 'seo/sitemap_generator/show'
  end

  post :generate do
    Sidekiq::Queue.new.clear        # Очистить все задачи в очереди
    Sidekiq::RetrySet.new.clear     # Очистить очередь повторных задач
    Sidekiq::ScheduledSet.new.clear # Очистить очередь запланированных задач
    Sidekiq::Queue.new.each { |job| job.delete } # Удаление задачи
    RobotsWorker.perform_async('robots', 1)
    SitemapWorker.perform_async('sitemap', 2)
    flash[:success] = 'Обновление может занять некоторое время.'
    redirect back
  end
  post :generate_sitemap do
    SitemapWorker.perform_async('only_sitemap', 3)
    flash[:success] = 'Обновление может занять некоторое время.'
    redirect back
  end
  post :generate_robots do
    RobotsWorker.perform_async('only_robots', 4)
    flash[:success] = 'Обновление может занять некоторое время.'
    redirect back
  end
  get :reset do
    content_type :text
    Sidekiq::Queue.new.clear        # Очистить все задачи в очереди
    Sidekiq::RetrySet.new.clear     # Очистить очередь повторных задач
    Sidekiq::ScheduledSet.new.clear # Очистить очередь запланированных задач
    Sidekiq::Queue.new.each { |job| job.delete } # Удаление задачи
    return 'OK'
  end
end

Rozario::Admin.controllers :'seo/sitemap_generator/pages' do
  get :index do
    @title = 'pages'
    @type = 'page'
    @data = Page.order('id DESC').paginate(:page => params[:page], :per_page => 25)
    render 'seo/sitemap_generator/pages/index'
  end

  get :search do
    @title = 'pages'
    @type = 'page'
    type = params['type']
    @data_type = Page.new
    query = strip_tags(params[:query]).mb_chars.downcase

    if params[:query].length > 0
      @data = Page.where("#{type} like ?", "%#{query}%").all.paginate(:page => params[:page], :per_page => 20)
      if @data.first.nil?
        flash[:error] = "Ничего не найдено :("
        redirect back
      else
        flash[:success] = "Найдено"
        render 'seo/sitemap_generator/pages/index'
      end
    else
      @data = Page.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
      flash[:error] = "Введите запрос"
      render 'seo/sitemap_generator/pages/index'
    end
  end
end

Rozario::Admin.controllers :'seo/sitemap_generator/articles' do
  get :index do
    @title = 'articles'
    @type = 'article'
    @data = Article.order('id DESC').paginate(:page => params[:page], :per_page => 25)
    render 'seo/sitemap_generator/articles/index'
  end

  get :search do
    @title = 'articles'
    @type = 'article'
    type = params['type']
    @data_type = Article.new
    query = strip_tags(params[:query]).mb_chars.downcase

    if params[:query].length > 0
      @data = Article.where("#{type} like ?", "%#{query}%").all.paginate(:page => params[:page], :per_page => 20)
      if @data.first.nil?
        flash[:error] = "Ничего не найдено :("
        redirect back
      else
        flash[:success] = "Найдено"
        render 'seo/sitemap_generator/articles/index'
      end
    else
      @data = Article.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
      flash[:error] = "Введите запрос"
      render 'seo/sitemap_generator/articles/index'
    end
  end
end

Rozario::Admin.controllers :'seo/sitemap_generator/news' do
  get :index do
    @title = 'news'
    @type = 'news'
    @data = News.order('id DESC').paginate(:page => params[:page], :per_page => 25)
    render 'seo/sitemap_generator/news/index'
  end

  get :search do
    @title = 'news'
    @type = 'news'
    type = params['type']
    @data_type = News.new
    query = strip_tags(params[:query]).mb_chars.downcase

    if params[:query].length > 0
      @data = News.where("#{type} like ?", "%#{query}%").all.paginate(:page => params[:page], :per_page => 20)
      if @data.first.nil?
        flash[:error] = "Ничего не найдено :("
        redirect back
      else
        flash[:success] = "Найдено"
        render 'seo/sitemap_generator/news/index'
      end
    else
      @data = News.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
      flash[:error] = "Введите запрос"
      render 'seo/sitemap_generator/news/index'
    end
  end
end

Rozario::Admin.controllers :'seo/sitemap_generator/categories' do
  get :index do
    @title = 'categories'
    @type = 'category'
    @data = Category.order('id DESC').paginate(:page => params[:page], :per_page => 25)
    render 'seo/sitemap_generator/categories/index'
  end

  get :search do
    @title = 'categories'
    @type = 'category'
    @data_type = Category.new
    type = params['type']
    query = strip_tags(params[:query]).mb_chars.downcase

    if params[:query].length > 0
      @data = Category.where("#{type} like ?", "%#{query}%").all.paginate(:page => params[:page], :per_page => 20)
      if @data.first.nil?
        flash[:error] = "Ничего не найдено :("
        redirect back
      else
        flash[:success] = "Найдено"
        render 'seo/sitemap_generator/categories/index'
      end
    else
      @data = Category.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
      flash[:error] = "Введите запрос"
      render 'seo/sitemap_generator/categories/index'
    end
  end
end

Rozario::Admin.controllers :'seo/sitemap_generator/products' do
  get :index do
    @title = 'products'
    @type = 'product'
    @data = Product.order('id DESC').paginate(:page => params[:page], :per_page => 25)
    render 'seo/sitemap_generator/products/index'
  end

  get :search do
    @title = 'products'
    @type = 'product'
    @data_type = Product.new
    type = params['type']
    query = strip_tags(params[:query]).mb_chars.downcase

    if params[:query].length > 0
      @data = Product.where("#{type} like ?", "%#{query}%").all.paginate(:page => params[:page], :per_page => 20)
      if @data.first.nil?
        flash[:error] = "Ничего не найдено :("
        redirect back
      else
        flash[:success] = "Найдено"
        render 'seo/sitemap_generator/products/index'
      end
    else
      @data = Product.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
      flash[:error] = "Введите запрос"
      render 'seo/sitemap_generator/products/index'
    end
  end
end

Rozario::Admin.controllers :'seo/sitemap_generator/smiles' do
  get :index do
    @title = 'smiles'
    @type = 'smile'
    @data = Smile.order('id DESC').paginate(:page => params[:page], :per_page => 25)
    render 'seo/sitemap_generator/smiles/index'
  end

  get :search do
    @title = 'smiles'
    @type = 'smile'
    @data_type = Smile.new
    type = params['type']
    query = strip_tags(params[:query]).mb_chars.downcase

    if params[:query].length > 0
      @data = Smile.where("#{type} like ?", "%#{query}%").all.paginate(:page => params[:page], :per_page => 20)
      if @data.first.nil?
        flash[:error] = "Ничего не найдено :("
        redirect back
      else
        flash[:success] = "Найдено"
        render 'seo/sitemap_generator/smiles/index'
      end
    else
      @data = Smile.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
      flash[:error] = "Введите запрос"
      render 'seo/sitemap_generator/smiles/index'
    end
  end
end
