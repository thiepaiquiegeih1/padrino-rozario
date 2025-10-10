# encoding: utf-8
Rozario::App.controllers :page do

  before do
    require 'yaml'
    redis_settings = YAML::load_file("config/redis.yml")
    REDIS = Redis.new(redis_settings[@environment['type']])
  end

  get '/predopl' do
    get_seo_data('pages')
    render 'page/predopl'
  end

  get '/confidentiality' do
    get_seo_data('pages')
    @seo[:title] = 'Политика конфиденциальности - Rozario Flowers'
    @seo[:description] = 'Узнайте, как Rozario Flowers собирает, использует и защищает ваши персональные данные. Прозрачная политика конфиденциальности для безопасных покупок.'
    @seo[:h1] = 'Политика конфиденциальности'
    render 'page/confidentiality'
  end

  get "/dostavka" do
    get_seo_data('pages')
    @seo[:title] = 'Доставка цветов в Мурманске - условия и сроки | Rozario Flowers'
    @seo[:description] = 'Узнайте подробности доставки букетов по Мурманску и области: стоимость, сроки, способы оплаты. Rozario Flowers - быстрая и надёжная доставка цветов.'
    @seo[:h1] = 'Условия доставки'
    return erb :'page/dostavka'
  end

  get :index, :with => :uri do
    # puts "  get :index, :with => :uri do page.rb"
    @page = Page.find_by_slug(params[:uri].force_encoding("UTF-8"))
    if @page.blank?
      error 404
    end
    @canonical = "https://#{@subdomain.url != 'murmansk' ? "#{@subdomain.url}.#{CURRENT_DOMAIN}" : CURRENT_DOMAIN}/#{@page.uri}"
    get_seo_data('pages', @page.seo, true)
    return render @page.uri == 'contacts' ? 'page/contacts' : 'page/show'
  end

  post :index, :with => :uri do
    # puts "  post :index, :with => :uri do page.rb"
    if params[:uri] == 'contacts' # contact form
      if (!params[:name].empty? && !params[:msg].empty?)
        if recaptcha_valid?
          msg_body = "Имя: " + params[:name] + "\n" + "Эл. почта: " + params[:email] + "\n" + "Вопрос: " + params[:msg]
          email do
            from "no-reply@#{CURRENT_DOMAIN}"
            to ENV['ORDER_EMAIL'].to_s
            subject "Сообщение с сайта"
            body msg_body
          end
          flash.now[:notice] = 'Спасибо, Ваше сообщение отправлено.'
        else
          flash.now[:error] = 'Ошибка: неверный проверочный код.'
        end
      else; flash.now[:error] = 'Пожалуйста, заполните все поля формы.'; end
      #redirect(url(:page, :index, 'contacts'))
      @page = Page.find_by_uri(params[:uri])
      get_seo_data('pages', @page.seo, true)
      return render 'page/contacts'
    end
  end

end
