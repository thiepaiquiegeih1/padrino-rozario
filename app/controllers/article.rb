# encoding: utf-8
Rozario::App.controllers :article do

  get :index do
    @articles = Article.all(:order => 'created_at desc')
    @canonical = "https://" + request.env['HTTP_HOST'] + '/article'
    get_seo_data('articles_page', nil, true)
    render 'article/index'
  end

  get :index, with: :slug do
    @article = Article.find_by_slug(params[:slug].force_encoding("UTF-8"))
    @article = Article.find_by_id(params[:slug].force_encoding("UTF-8")) if @article.nil?
    return error 404 if @article.blank?
    @canonical = "https://" + request.env['HTTP_HOST'] +  '/article/' + @article.slug if @article.slug
    get_seo_data('articles', @article.seo_id)
    render 'article/show'
  end

end
