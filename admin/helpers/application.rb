# encoding: utf-8
Rozario::Admin.helpers do

  def menu_entries
    #p project_modules
    show_in_menu = ["/complects","/pages","/categories","/products","/news","/articles","/contacts","/delivery","/regions","/clients","/tags","/seo", "/payment", "/grunt"]
    project_modules.select { |x| show_in_menu.include? x.path }
  end

  # Helper для обработки MySQL BIT полей
  def bit_field_to_bool(value)
    case value
    when nil, false
      false
    when true, 1
      true
    when String
      # MySQL BIT поле может возвращать строку с битовыми данными
      return true if value == '1'
      return true if value.bytes.first == 1 # бинарная единица
      false
    when Integer
      value == 1
    else
      # Любое другое значение - проверяем на "truthy"
      !!value
    end
  rescue => e
    # При ошибке - возвращаем false
    false
  end

end
