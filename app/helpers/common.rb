# encoding: utf-8

require 'logger'

def matches_cron?(cron_expression) # https://crontab.guru/
  current_time = Time.now # Получаем текущую дату и время
  minute, hour, day_of_month, month, day_of_week = cron_expression.split(' ') # Разбиваем cron выражение на компоненты
  
  # Проверяем каждую часть cron выражения с текущими значениями времени
  match_minute = match_value?(current_time.min, minute)
  match_hour = match_value?(current_time.hour, hour)
  match_day_of_month = match_value?(current_time.day, day_of_month)
  match_month = match_value?(current_time.month, month)
  match_day_of_week = match_value?(current_time.wday, day_of_week)

  return match_minute && match_hour && match_day_of_month && match_month && match_day_of_week # Возвращаем true, если все части совпадают
end
def match_value?(current_value, cron_value) # Вспомогательная функция для сравнения cron-значений с текущими значениями
  cron_value == '*' || cron_value.to_i == current_value
end

def convert_to_utc_plus_3(date_str) # Функция для преобразования строки в нужный формат
  # time = Time.strptime(date_str, "%d-%m-%YT%H:%M:%SZ") # Преобразуем строку в объект Time (в UTC)
  time = Time.strptime(date_str, "%Y-%m-%dT%H:%M:%SZ") # Используем правильный формат
  time = time + (3 * 60 * 60) # Переводим время в UTC+3 (добавляем 3 часа (время в секундах))
  return time # Возвращаем время в нужном формате
end

def gauge(msg)
  # https://www.youtube.com/shorts/vGyc29v-hhU?feature=share
  logger = Logger.new('/srv/log/test.log') # Создаём объект логгера, указывая имя файла
  logger.level = Logger::DEBUG # Указываем уровень логирования (опционально)
  # Примеры записи сообщений в лог:
  # - `logger.debug("Это сообщение DEBUG")`
  # - `logger.info("Это сообщение INFO")`
  # - `logger.warn("Это сообщение WARN")`
  # - `logger.error("Это сообщение ERROR")`
  # - `logger.fatal("Это сообщение FATAL")`
  logger.debug(msg)
  logger.close # Закрыть логгер (опционально)
end

# def markdown_to_html(x) # For Commonmarker 2.3.2
#   require 'commonmarker' unless defined?(Commonmarker)
#   options = {
#     parse: { # https://github.com/gjtorikian/commonmarker?tab=readme-ov-file#parse-options
#       smart:                     false, # Знаки препинания (кавычки, точки и дефисы) преобразуются в «умные» знаки препинания. Default: `false`.
#       default_info_string:       "",    # Информационная строка по умолчанию для огражденных блоков кода. Default: "".
#       relaxed_tasklist_matching: false, # Позволяет ослабить сопоставление расширений списка задач, разрешая использовать для состояния «отмечено» любой символ, не являющийся пробелом, а не только `x` и `X`. Default: `false`.
#       relaxed_autolinks:         true   # Включить ослабление анализа расширения autolink, позволяя распознавать ссылки в скобках, а также разрешая любую схему URL. Default: `false`.
#     },
#     extension: { # https://github.com/gjtorikian/commonmarker?tab=readme-ov-file#extension-options
#       strikethrough:               true, # Включает расширение зачеркивания из спецификации GFM.                         Default: `true`.
#       tagfilter:                   true, # Включает расширение tagfilter из спецификации GFM.                            Default: `true`.
#       table:                       true, # Включает расширение таблицы из спецификации GFM.                              Default: `true`.
#       autolink:                    true, # Включает расширение автоссылки из спецификации GFM.                           Default: `true`.
#       tasklist:                    true, # Включает расширение списка задач из спецификации GFM.                         Default: `true`.
#       superscript:                 true, # Включает расширение Comrak с надстрочным индексом.                            Default: `false`.
#       header_ids:                  ""  , # Включает расширение идентификаторов заголовков Comrak из спецификации GFM.    Default: `""`.
#       footnotes:                   true, # Включает расширение сносок для каждого cmark-gfmфайла.                        Default: `false`.
#       description_lists:           true, # Включает расширение списков описаний.                                         Default: `false`.
#       front_matter_delimiter:      ""  , # Включает расширение вступительной части.                                      Default: `""`.
#       multiline_block_quotes:      true, # Включает расширение многострочных блоковых цитат.                             Default: `false`.
#       math_dollars:                true, # Включает математическое расширение.                                           Default: `false`.
#       math_code:                   true, # Включает математическое расширение.                                           Default: `false`.
#       shortcodes:                  true, # Включает расширение коротких кодов.                                           Default: `true`.
#       wikilinks_title_before_pipe: true, # Включает расширение wikilinks, помещая заголовок перед разделительной чертой. Default: `false`.
#       wikilinks_title_after_pipe:  true, # Включает расширение wikilinks, размещая заголовок после разделительной черты. Default: `false`.
#       underline:                   true, # Включает расширение подчеркивания.                                            Default: `false`.
#       spoiler:                     true, # Включает расширение спойлера.                                                 Default: `false`.
#       greentext:                   true, # Включает расширение greentext.                                                Default: `false`.
#       subscript:                   true, # Включает расширение нижнего индекса.                                          Default: `false`.
#       alerts:                      true, # Включает расширение оповещений.                                               Default: `false`.
#       cjk_friendly_emphasis:       true  # Включает расширение, поддерживающее акцент CJK.                               Default: `false`.
#     },
#     render: { # https://github.com/gjtorikian/commonmarker?tab=readme-ov-file#render-options
#       hardbreaks:         true,  # Мягкие переносы строк преобразуются в жесткие переносы строк.                                   Default: `true`.
#       github_pre_lang:    true,  # Стиль GitHub <pre lang="xyz">используется для огражденных блоков кода с информационными тегами. Default: `true`.
#       full_info_string:   true,  # Выводит данные строки информации после пробела в `data-meta` атрибуте в блоках кода.            Default: `false`.
#       width:              80,    # Столбец переноса при выводе CommonMark.                                                         Default: `80`.
#       unsafe:             true,  # Разрешить отображение необработанного HTML и потенциально опасных ссылок.                       Default: `false`.
#       escape:             false, # Экранируйте сырой HTML вместо того, чтобы затирать его.                                         Default: `false`.
#       sourcepos:          false, # Включать атрибут исходной позиции в выходные данные HTML и XML.                                 Default: `false`.
#       escaped_char_spans: true,  # Оберните экранированные символы в теги `span`.                                                  Default: `true`.
#       ignore_setext:      false, # Игнорирует заголовки в стиле setext.                                                            Default: `false`.
#       ignore_empty_links: true,  # Игнорирует пустые ссылки, оставляя текст Markdown на месте.                                     Default: `false`.
#       gfm_quirks:         false, # Выводит HTML с особенностями стиля GFM, а именно, без вложенных `<strong>` строк.               Default: `false`.
#       prefer_fenced:      false, # Всегда выводите огражденные блоки кода, даже там, где можно использовать отступ.                Default: `false`.
#       tasklist_classes:   true   # Добавьте классы CSS в HTML-вывод расширения списка задач.                                       Default: `false`.
#     }
#   }
#   return Commonmarker.to_html( # https://github.com/gjtorikian/commonmarker?tab=readme-ov-file#usage
#     x || "",
#     options: options, # https://github.com/gjtorikian/commonmarker?tab=readme-ov-file#options-and-plugins
#     plugins: { syntax_highlighter: { theme: nil } } # https://github.com/gjtorikian/commonmarker?tab=readme-ov-file#plugins
#   )
# end

def markdown_to_html(markdown_text, parse_options: [], render_options: []) # For Commonmarker 0.21.1
  # Убедитесь, что CommonMarker загружен
  require 'commonmarker' unless defined?(CommonMarker)

  # --- Подготовка опций парсинга ---
  # CommonMarker.render_doc ожидает массив символов для опций.
  # Если parse_options пуст, используем только :DEFAULT.
  # Иначе, объединяем :DEFAULT с переданными опциями и убираем дубликаты.
  actual_parse_options = []
  actual_parse_options << :DEFAULT unless parse_options.include?(:DEFAULT)
  actual_parse_options.concat(parse_options)
  actual_parse_options.uniq! # Удаляем возможные дубликаты

  # Парсим Markdown в объект CommonMarker::Node
  # Передаем массив опций как второй аргумент.
  doc = CommonMarker.render_doc(markdown_text, actual_parse_options)

  # --- Подготовка опций рендеринга ---
  # Если render_options не заданы, используем те же, что и для парсинга.
  actual_render_options = render_options.empty? ? actual_parse_options : render_options
  actual_render_options.uniq! # Удаляем возможные дубликаты

  # Рендерим Node в HTML.
  # Передаем массив опций как единственный аргумент.
  doc.to_html(actual_render_options)
end

# def html_to_markdown(html_text)
#   require 'reverse_markdown' unless defined?(ReverseMarkdown)
#   return ReverseMarkdown.convert(html_text, unknown_tags: :bypass) # Настройки конвертера (чтобы результат был ближе к "чистому" Markdown)
# end
# Simple HTML tag stripper method
# Removes HTML tags from text, similar to Rails' strip_tags helper
def strip_tags(html_text)
  return "" if html_text.nil?
  return html_text unless html_text.is_a?(String)
  
  # Remove all HTML tags first
  text = html_text.gsub(/<[^>]*>/, '')
  
  # Then handle common HTML entities
  text = text.gsub(/&nbsp;/i, ' ')
             .gsub(/&amp;/i, '&')
             .gsub(/&lt;/i, '<')
             .gsub(/&gt;/i, '>')
             .gsub(/&quot;/i, '"')
             .gsub(/&#39;/i, "'")
             .gsub(/&apos;/i, "'")
  
  # Clean up extra whitespace
  text = text.gsub(/\s+/, ' ').strip
  
  return text
end

# Extend String class with strip_tags method for compatibility
class String
  def strip_tags
    return "" if self.nil?
    
    # Remove all HTML tags first
    text = self.gsub(/<[^>]*>/, '')
    
    # Then handle common HTML entities
    text = text.gsub(/&nbsp;/i, ' ')
               .gsub(/&amp;/i, '&')
               .gsub(/&lt;/i, '<')
               .gsub(/&gt;/i, '>')
               .gsub(/&quot;/i, '"')
               .gsub(/&#39;/i, "'")
               .gsub(/&apos;/i, "'")
    
    # Clean up extra whitespace
    text = text.gsub(/\s+/, ' ').strip
    
    return text
  end
end
# Helper для обработки MySQL BIT полей (скопирован из админки)
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