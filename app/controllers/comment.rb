# encoding: utf-8

Rozario::App.controllers :feedback do

  # https://stackoverflow.com/questions/21262254/what-captcha-for-sinatra

  before do
    require 'yaml'
    @redis_enable = false
    redis_settings = YAML::load_file("config/redis.yml")
    REDIS = Redis.new(redis_settings['test'])
    
    # Важно: вызываем основную логику приложения
    load_subdomain
    
    if @subdomain.nil?
      halt 403, 'Forbidden'
    end
    
    prod_price if respond_to?(:prod_price)
  end

  get :index do

    @canonical = "https://#{@subdomain.url != 'murmansk' ? "#{@subdomain.url}.#{CURRENT_DOMAIN}" : CURRENT_DOMAIN}/comment"

    #@comments = Comment.all(:order => 'created_at desc')
    #get_seo_data('comments', nil, true)
    #render 'comment/index'

    puts "get :index do comment.rb"
    
    # Получаем список заказов для авторизованного пользователя
    user_account = current_account || (session[:user_id] ? UserAccount.find(session[:user_id]) : nil)
    @user_orders = []
    if user_account
      @user_orders = Order.where(useraccount_id: user_account.id)
                         .where('eight_digit_id IS NOT NULL AND eight_digit_id != ""')
                         .order('created_at DESC')
                         .select('eight_digit_id, created_at')
                         .map { |order| [order.eight_digit_id, order.created_at] }
    end
    
    # Возвращаем обычное кэширование как было
    if !user_account && REDIS.get(@subdomain.url + ':feedback') && @redis_enable
      REDIS.get @subdomain.url + ':feedback'
    else
      # Пагинация для ленивой загрузки
      @page = (params[:page] || 1).to_i
      @per_page = 10 # Количество отзывов на страницу
      @comments = Comment.order('created_at desc').limit(@per_page).offset((@page - 1) * @per_page)
      @total_comments = Comment.count
      @has_more = (@page * @per_page) < @total_comments
      get_seo_data('comments', nil, true)
      page = render 'comment/index'
      # Кешируем только версию для неавторизованных
      REDIS.setnx(@subdomain.url + ':feedback', page) if !user_account
      page
    end
  end

  post :submit do
    # Проверяем авторизацию
    user_account = current_account || (session[:user_id] ? UserAccount.find(session[:user_id]) : nil)
    unless user_account
      flash[:error] = 'Для оставления отзыва необходимо авторизоваться'
      redirect back
      return
    end
    
    recaptcha_token = params[:'g-recaptcha-response']
    secret_key = ENV['RECAPTCHA_V3_SECRET_KEY_2']
    max_score = 0.5 # Usually value: 0.5 (Probability that the user is a human and not a robot)
    response = Net::HTTP.post_form(
      URI.parse('https://www.google.com/recaptcha/api/siteverify'), {
        'secret' => secret_key,
        'response'   => recaptcha_token
      }
    )
    result = JSON.parse(response.body)
    if result['success'] && result['score'].to_f >= max_score then
      # Проверяем обязательные поля
      if params[:order_eight_digit_id].blank?
        flash[:error] = 'Ошибка: укажите номер заказа'
        redirect back
        return
      elsif params[:rating].nil?
        rating = '0'
        flash[:error] = 'Ошибка: установите оценку'
        redirect back
        return
      else
        rating = params[:rating]
        order_id = params[:order_eight_digit_id].to_i
        
        # Проверяем существование заказа если номер указан
        if order_id && !Order.exists?(:eight_digit_id => order_id)
          flash[:error] = "Ошибка: заказ с номером #{order_id} не найден"
          redirect back
          return
        end
        
        # Создаем комментарий с данными авторизованного пользователя
        begin
          # Используем данные из профиля пользователя
          user_name = user_account.name || user_account.surname || user_account.email.split('@').first
          
          comment = Comment.create!(
            :name => user_name,
            :body => params[:msg], 
            :rating => rating.to_f,
            :order_eight_digit_id => order_id
          )
          
          # Отправляем почту с данными авторизованного пользователя
          order_info = order_id ? "\nНомер заказа: #{order_id}" : ""
          user_email = user_account.email
          user_id_info = "\nID пользователя: #{user_account.id}"
          msg_body = "Имя: #{user_name}\nЭл. почта: #{user_email}\nОтзыв: #{params[:msg]}\nОценка: #{rating}#{order_info}#{user_id_info}"
          email do
            from "no-reply@rozariofl.ru"
            to ENV['ORDER_EMAIL'].to_s
            subject "Отзыв с сайта"
            body msg_body
          end
          
          flash[:notice] = "Спасибо! Ваш отзыв сохранен #{order_id ? 'и привязан к заказу' : ''}."
        rescue ActiveRecord::RecordInvalid => e
          flash[:error] = "Ошибка при сохранении отзыва: #{e.record.errors.full_messages.join(', ')}"
        end
      end
    else
      if result['score'].to_f >= max_score then
        flash[:error] = "Ошибка верификации reCAPTCHA."
      else
        flash[:error] = "Ошибка верификации reCAPTCHA. Score: #{result['score']} #{result['error-codes']}"
      end
    end
    redirect back
  end

  # AJAX endpoint для ленивой загрузки отзывов
  get :load_more do
    begin
      content_type :json
      
      @page = (params[:page] || 1).to_i
      @per_page = 10
      
      # Проверяем корректность параметра
      if @page < 1
        @page = 1
      end
      
      @comments = Comment.order('created_at desc').limit(@per_page).offset((@page - 1) * @per_page)
      @total_comments = Comment.count
      @has_more = (@page * @per_page) < @total_comments
      
      puts "Load more: page=#{@page}, per_page=#{@per_page}, comments_count=#{@comments.count}, has_more=#{@has_more}"
      
      # Рендерим HTML для каждого отзыва
      comments_html = ''
      if @comments.any?
        comments_html = @comments.map do |comment|
          begin
            render 'comment/comment', :locals => { :comment => comment }
          rescue => e
            puts "Error rendering comment #{comment.id}: #{e.message}"
            '' # Пропускаем проблемные отзывы
          end
        end.join
      end
      
      response = {
        :html => comments_html,
        :has_more => @has_more,
        :current_page => @page,
        :total_comments => @total_comments,
        :loaded_count => @comments.count
      }
      
      response.to_json
      
    rescue => e
      puts "Error in load_more: #{e.message}"
      puts e.backtrace.join("\n")
      
      content_type :json
      status 500
      {
        :error => 'Internal server error',
        :message => e.message,
        :has_more => false
      }.to_json
    end
  end

  get :test do
    @comments = Comment.all(:order => 'created_at desc')
    get_seo_data('comments', nil, true)
    page = render 'comment/indexxx'
  end
  
  get :debug do
    content_type :json
    debug_info = {
      current_account: current_account.inspect,
      current_account_nil: current_account.nil?,
      session_user_id: session[:user_id],
      session_keys: session.keys,
      session_full: session.to_hash,
      subdomain: @subdomain.inspect,
      request_host: request.host,
      request_subdomains: request.subdomains
    }
    debug_info.to_json
  end

  post :index do
    if (!params[:name].empty? && !params[:msg].empty?)
      if verify_recaptcha
        if params[:rating].nil?
          rating = '0'
          flash[:error] = 'Ошибка, установите оценку'
        else
          rating = params[:rating]
          msg_body = "Имя: #{params[:name]}\nЭл. почта: #{params[:email]}\nОтзыв: #{params[:msg]}\nОценка: #{rating}"
          email do
            from "no-reply@rozariofl.ru"
            to ENV['ORDER_EMAIL'].to_s
            subject "Отзыв с сайта"
            body msg_body
          end
          flash[:notice] = 'Спасибо, Ваш отзыв отправлен на модерацию.'
        end
        #Comment_premod.create(name: params[:name], body: params[:msg], rating: params[:rating])
      else
        flash[:error] = 'Ошибка: неверный проверочный код..'
      end
    else
      flash[:error] = 'Пожалуйста, заполните все поля формы.'
    end
    redirect(url(:feedback, :index))
  end

  post :indexxx do
    puts "post :index do comment.rb"
    if (!params[:name].empty? && !params[:msg].empty?)
      if verify_recaptcha
        if params[:rating].nil?
          rating = '0'
          flash[:error] = 'Ошибка, установите оценку'
        else
          rating = params[:rating]
          msg_body = "Имя: #{params[:name]}\nЭл. почта: #{params[:email]}\nОтзыв: #{params[:msg]}\nОценка: #{rating}"
          email do
            from "no-reply@rozariofl.ru"
            to ENV['ORDER_EMAIL'].to_s
            subject "Отзыв с сайта"
            body msg_body
          end
          flash[:notice] = 'Спасибо, Ваш отзыв отправлен на модерацию.'
        end
        #Comment_premod.create(name: params[:name], body: params[:msg], rating: params[:rating])
      else
        flash[:error] = 'Ошибка: неверный проверочный код..'
      end
    else
      flash[:error] = 'Пожалуйста, заполните все поля формы.'
    end
    redirect(url(:feedback, :index))
  end
end

# Alias controller for backward compatibility with Nginx redirects
Rozario::App.controllers :comment do
  
  before do
    require 'yaml'
    @redis_enable = false
    redis_settings = YAML::load_file("config/redis.yml")
    REDIS = Redis.new(redis_settings['test']) if defined?(Redis)
    
    # Важно: вызываем основную логику приложения
    load_subdomain if respond_to?(:load_subdomain)
    
    if @subdomain.nil? && respond_to?(:halt)
      halt 403, 'Forbidden'
    end
    
    prod_price if respond_to?(:prod_price)
  end
  get :index do
    redirect url(:feedback, :index), 301
  end
  
  # AJAX endpoint для ленивой загрузки отзывов (алиас для совместимости с Nginx)
  get :load_more do
    begin
      content_type 'application/json'
      
      @page = (params[:page] || 1).to_i
      @per_page = 10
      
      # Проверяем корректность параметра
      if @page < 1
        @page = 1
      end
      
      # Проверяем, что модель Comment существует
      unless defined?(Comment)
        raise "Comment model not found"
      end
      
      @comments = Comment.order('created_at desc').limit(@per_page).offset((@page - 1) * @per_page)
      @total_comments = Comment.count
      @has_more = (@page * @per_page) < @total_comments
      
      puts "[COMMENT ALIAS] Load more: page=#{@page}, per_page=#{@per_page}, comments_count=#{@comments.count}, has_more=#{@has_more}"
      
      # Создаем HTML для каждого отзыва (простое решение)
      comments_html = @comments.map do |comment|
        begin
          date = comment.date.present? ? comment.date.strftime("%d.%m.%Y") : comment.created_at.strftime("%d.%m.%Y")
          rating_stars = '★' * comment.rating.to_i + '☆' * (5 - comment.rating.to_i)
          order_info = comment.order_eight_digit_id.present? ? "<div style='font-size: 12px; color: #666; margin: 4px 0;'><small>Отзыв к заказу #{comment.order_eight_digit_id}</small></div>" : ''
          
          "<article class='comment-item' style='padding: 8px 0;' itemscope='' itemtype='http://schema.org/Rating'>
             <h3 class='name'>#{comment.name}</h3>
             <div class='date'>#{date}</div>
             #{order_info}
             <div class='body' itemprop='description'>#{comment.body}</div>
             <div class='star-rating' style='color: #FFD700;'>#{rating_stars}</div>
           </article>"
        rescue => e
          puts "Error creating HTML for comment #{comment.id}: #{e.message}"
          '' # Пропускаем проблемные отзывы
        end
      end.join
      
      response = {
        :html => comments_html,
        :has_more => @has_more,
        :current_page => @page,
        :total_comments => @total_comments,
        :loaded_count => @comments.count
      }
      
      response.to_json
      
    rescue => e
      puts "Error in load_more (comment alias): #{e.message}"
      puts e.backtrace.join("\n")
      
      content_type 'application/json'
      status 500
      {
        :error => 'Internal server error',
        :message => e.message,
        :has_more => false
      }.to_json
    end
  end
end