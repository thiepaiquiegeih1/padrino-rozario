# encoding: utf-8
Rozario::Admin.controllers :comments do

  get :index do
    @title = "Comments"
    @comments = Comment.order('id desc').paginate(:page => params[:page], :per_page => 20)
    @filter_type = 'all'
    render 'comments/index'
  end
  
  # Новая вкладка для неопубликованных отзывов
  get :unpublished do
    @title = "Unpublished Comments"
    @comments = Comment.where(published: 0).order('id desc').paginate(:page => params[:page], :per_page => 20)
    @filter_type = 'unpublished'
    render 'comments/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'comment')
    @lang = { 'language' => 'Russian',
              'months' => [ 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь' ],
              'monthsAbbr' => [ 'Янв', 'Февр', 'Март', 'Апр', 'Май', 'Июнь', 'Июль', 'Авг', 'Сент', 'Окт', 'Нояб', 'Дек' ],
              'days' => [ 'Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб' ],
              'rtl' => false,
              'ymd' => false,
              'yearSuffix' => '' }
    @comment = Comment.new
    render 'comments/new'
  end

  post :create do
    comment_params = params[:comment]
    # Разрешаем поле order_eight_digit_id и published
    allowed_params = comment_params.select { |k, v| ['name', 'body', 'title', 'rating', 'date', 'order_eight_digit_id', 'published'].include?(k) }
    
    # Обработка BIT поля published для MySQL
    published_value = comment_params.has_key?('published') ? comment_params['published'] : '0'
    published_int = (published_value == '1' || published_value == 1) ? 1 : 0
    allowed_params['published'] = published_int
    
    # Debug info
    puts "DEBUG CREATE: published checkbox #{comment_params.has_key?('published') ? 'checked' : 'unchecked'}, raw: #{published_value.inspect}, final: #{published_int}"
    
    # Автоматически заполняем поле date текущей датой, если не указано
    allowed_params['date'] = Time.now if allowed_params['date'].blank?
    
    @comment = Comment.new(allowed_params)
    if @comment.save
      @title = pat(:create_title, :model => "comment #{@comment.id}")
      flash[:success] = pat(:create_success, :model => 'Comment')
      params[:save_and_continue] ? redirect(url(:comments, :index)) : redirect(url(:comments, :edit, :id => @comment.id))
    else
      @title = pat(:create_title, :model => 'comment')
      flash.now[:error] = pat(:create_error, :model => 'comment')
      render 'comments/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "comment #{params[:id]}")
    @lang = { 'language' => 'Russian',
              'months' => [ 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь' ],
              'monthsAbbr' => [ 'Янв', 'Февр', 'Март', 'Апр', 'Май', 'Июнь', 'Июль', 'Авг', 'Сент', 'Окт', 'Нояб', 'Дек' ],
              'days' => [ 'Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб' ],
              'rtl' => false,
              'ymd' => false,
              'yearSuffix' => '' }
    @comment = Comment.find(params[:id])
    if @comment
      render 'comments/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'comment', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "comment #{params[:id]}")
    comment_params = params[:comment]
    @comment = Comment.find(params[:id])
    if @comment
      # Разрешаем поле order_eight_digit_id и published
      allowed_params = comment_params.select { |k, v| ['name', 'body', 'title', 'rating', 'date', 'order_eight_digit_id', 'published'].include?(k) }
      
      # Обработка чекбокса published: если не отмечен, браузер не отправляет параметр
      # Поэтому явно устанавливаем published = 0, если параметр отсутствует
      # Обработка BIT поля published для MySQL
      published_value = comment_params.has_key?('published') ? comment_params['published'] : '0'
      published_int = (published_value == '1' || published_value == 1) ? 1 : 0
      allowed_params['published'] = published_int
      
      # Debug info
      puts "DEBUG UPDATE: published checkbox #{comment_params.has_key?('published') ? 'checked' : 'unchecked'}, raw: #{published_value.inspect}, final: #{published_int}"
      
      # Автоматически заполняем поле date, если не указано и если у комментария нет даты
      if allowed_params["date"].blank? && @comment.date.blank?
        allowed_params["date"] = Time.now
      end
      
      update_params = allowed_params["date"].present? ? allowed_params : allowed_params.except("date")
      
      if @comment.update_attributes(update_params)
        # Для BIT поля может потребоваться прямой SQL запрос
        if update_params.has_key?('published')
          sql = "UPDATE comments SET published = #{published_int} WHERE id = #{@comment.id}"
          ActiveRecord::Base.connection.execute(sql)
          puts "DEBUG UPDATE: executed direct SQL: #{sql}"
        end
        
        # Проверяем что фактически сохранилось
        @comment.reload
        puts "DEBUG UPDATE: comment after save: #{@comment.published.inspect} (#{@comment.published.class})"
        flash[:success] = pat(:update_success, :model => 'Comment', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:comments, :index)) :
          redirect(url(:comments, :edit, :id => @comment.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'comment')
        render 'comments/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'comment', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Comments"
    comment = Comment.find(params[:id])
    if comment
      if comment.destroy
        flash[:success] = pat(:delete_success, :model => 'Comment', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'comment')
      end
      redirect url(:comments, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'comment', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Comments"
    unless params[:comment_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'comment')
      redirect(url(:comments, :index))
    end
    ids = params[:comment_ids].split(',').map(&:strip).map(&:to_i)
    comments = Comment.find(ids)

    if Comment.destroy comments

      flash[:success] = pat(:destroy_many_success, :model => 'Comments', :ids => "#{ids.to_sentence}")
    end
    redirect url(:comments, :index)
  end
end
