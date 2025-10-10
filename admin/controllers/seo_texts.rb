# encoding: utf-8
Rozario::Admin.controllers :seo_texts do

  get :edit, :with => :slug do
    content_type :html
    begin
      category = Category.find_by_slug(params[:slug].force_encoding('UTF-8'))
      x = ActiveRecord::Base.connection.execute("SELECT * from texts WHERE category=#{category.id.to_s}").to_a
      if x.present?
        # text = x[0][1].gsub(/%morph_datel%/, @subdomain.morph_datel).gsub(/%morph_predl%/, @subdomain.morph_predl).gsub(/%city%/, @subdomain.city).gsub(/%morph_rodit%/, @subdomain.morph_rodit).html_safe
        begin;  h1 = x[0][2].html_safe
        rescue; h1 = nil; end
        begin;  markdown = x[0][3]
        rescue; markdown = nil; end
      end
      @content = markdown
      # return markdown_to_html(markdown)
      render 'seo_texts/index', :layout => false
    rescue => e
      content_type :json
      status 500
      return { success: false, error: e.message }.to_json
    end
  end

  post :update, :with => :slug do
    content_type :json
    category = Category.find_by_slug(params[:slug].force_encoding('UTF-8')) # Находим категорию по `slug`

    unless category # Если категория не найдена, возвращаем ошибку 404
      status 404 # Not Found
      return { success: false, error: "Category not found for `slug`: #{params[:slug]}" }.to_json
    end

    begin
      request_payload = JSON.parse(request.body.read) # Парсим тело запроса
      content = request_payload["content"].to_s.gsub("'", "''").split("\n").map(&:lstrip).join("\n") # Извлекаем и обрабатываем `content`, сохраняя логику очистки от начальных пробелов в каждой строке # В SQL одиночная кавычка (`'`) используется для заключения строковых значений, и если в строке встречается одиночная кавычка, её нужно экранировать, чтобы избежать синтаксической ошибки. Обычно для этого используется две одиночные кавычки (`''`), чтобы представить одну кавычку в строке.
      existing_record = ActiveRecord::Base.connection.execute( # Ищем запись в таблице texts по category.id
        "SELECT 1 FROM texts WHERE category = #{category.id}"
      ).first # .first вернет nil, если записей нет, или хэш первой записи
      if existing_record # Если запись существует, обновляем её поле 'md'
        ActiveRecord::Base.connection.execute( # Обновляем текст в базе данных
          "UPDATE texts SET md = '#{content}' WHERE category = #{category.id}"
        )
      else # Если запись не существует, то создаем новую
        ActiveRecord::Base.connection.execute(
          "INSERT INTO texts (category, md, text, h1) VALUES (#{category.id}, '#{content}', NULL, NULL)"
        )
      end
      return { success: true }.to_json # Возвращаем успешный ответ
    rescue JSON::ParserError => e # Обработка ошибок парсинга JSON
      status 400 # Bad Request
      return { success: false, error: "Invalid JSON payload: #{e.message}" }.to_json
    rescue ActiveRecord::RecordInvalid => e # Обработка ошибок валидации ActiveRecord (если update! или create! не прошли)
      status 422 # Unprocessable Entity
      return { success: false, error: "Validation failed: #{e.message}" }.to_json
    rescue => e # Общая обработка других исключений
      status 500 # Internal Server Error
      return { success: false, error: e.message }.to_json
    end
  end

  # get :temp do
  #   content_type :json
  #   path = '/srv/development_rozarioflowers.ru/public/+/md/*.md'
  #   files = Dir.glob(path)
  #   # files = files.map { |x| File.basename(x).split('.')[0] }
  #   x = []
  #   files.each { |path|
  #     slug = File.basename(path).split('.')[0]
  #     content = File.read(path).to_s.gsub("'", "''").split("\n").map(&:lstrip).join("\n")
  #     category = Category.find_by_slug(slug.force_encoding('UTF-8'))
  #     ActiveRecord::Base.connection.execute( # Обновляем текст в базе данных
  #       "UPDATE texts SET md = '#{content}' WHERE category = #{category.id}"
  #     )
  #   }
  #   return files.to_json
  # end

  # get :temp do
  #   content_type :json
  #   x = ActiveRecord::Base.connection.execute("SELECT * FROM texts;").to_a
  #   return x.to_json
  # end

  # get :html, :with => :slug do
  #   content_type :html
  #   begin
  #     category = Category.find_by_slug(params[:slug].force_encoding('UTF-8'))
  #     x = ActiveRecord::Base.connection.execute("SELECT * from texts WHERE category=#{category.id.to_s}").to_a
  #     if x.present?
  #       # text = x[0][1].gsub(/%morph_datel%/, @subdomain.morph_datel).gsub(/%morph_predl%/, @subdomain.morph_predl).gsub(/%city%/, @subdomain.city).gsub(/%morph_rodit%/, @subdomain.morph_rodit).html_safe
  #       h1 = x[0][2].html_safe
  #       markdown = x[0][3]
  #     end
  #     @content = markdown
  #     # return markdown_to_html(markdown)
  #     render 'seo_texts/index', :layout => false
  #   rescue => e
  #     content_type :json
  #     status 500
  #     return { success: false, error: e.message }.to_json
  #   end
  # end

  # get :test do
  #   content_type :json
  #   existing_record = ActiveRecord::Base.connection.execute( # Ищем запись в таблице texts по category.id
  #     "SELECT 1 FROM texts WHERE category = 819"
  #   ).first # .first вернет nil, если записей нет, или хэш первой записи
  #   return existing_record.to_json
  # end

end