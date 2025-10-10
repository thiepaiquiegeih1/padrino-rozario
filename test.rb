require 'benchmark'
require 'set'

def log_debug(x)
  puts x
end

@request_path = '/news/victory_day_2020'
@user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36"

FEATURES_OF_LEGITIMATE_ROBOTS = Regexp.union([ # `User-Agent` substrings for exclusion
  # 'OAI-SearchBot',       # OpenAI
  'googlebot',           # Google
  'yandexbot',           # Yandex
  'baiduspider',         # Baidu
  'duckduckbot',         # DuckDuckGo
  'slurp',               # Yahoo
  'SemrushBot',          # SemrushBot — бот от Semrush, инструмента для SEO-анализа и исследования ключевых слов
  'MJ12bot',             # MJ12bot — краулер Majestic, сервиса для анализа обратных ссылок
  'AhrefsBot',           # AhrefsBot — бот Ahrefs, платформы для SEO и анализа конкурентов
  'bingbot',             # bingbot — поисковый робот Bing от Microsoft
  'DotBot',              # DotBot — краулер от Moz, используемый для анализа SEO-метрик
  'PetalBot',            # PetalBot — бот от Huawei, связанный с их поисковой системой Petal Search
  'LinkpadBot',          # LinkpadBot — краулер Linkpad, сервиса анализа ссылок (в основном популярен в Рунете)
  'SputnikBot',          # SputnikBot — бот от Sputnik, российского поисковика и аналитического сервиса
  'statdom.ru',          # statdom.ru — краулер сервиса Statdom, собирающего статистику сайтов (Рунет)
  'MegaIndex.ru',        # MegaIndex.ru — бот MegaIndex, российской платформы для SEO и аналитики
  'WebDataStats',        # WebDataStats — краулер сервиса WebDataStats для сбора веб-статистики
  'Jooblebot',           # Jooblebot — бот Jooble, агрегатора вакансий
  'Baiduspider',         # Baiduspider — поисковый робот Baidu, крупнейшей поисковой системы Китая
  'BackupLand',          # BackupLand — вероятно, бот для анализа или резервного копирования сайтов (менее известен)
  'NetcraftSurveyAgent', # NetcraftSurveyAgent — краулер Netcraft, сервиса для анализа веб-безопасности и статистики
  'openstat.ru',         # openstat.ru — бот Openstat, российского сервиса веб-аналитики
].map(&:downcase)).freeze

EXCLUDED_STATIC_PATHS = Set.new([ # To exclude from processing
  '/javascripts', '/stylesheets', '/fonts', 
  '/favicon.ico', '/robots.txt', '/sitemap.xml',
]).freeze

EXCLUDED_REGEX_PATTERNS = [ # To exclude from processing # `Set` - это структура данных, которая хранит уникальные элементы и обеспечивает быстрый поиск (O(1) в среднем). Однако, `Set` может быть полезен только в том случае, если вы ищете точное соответствие пути, а не проверку `start_with?` или `include?`. В нашем случае, `Set` не подходит.
  /^\/api\//,
  /^\/assets\//,
  /\.(jpg|jpeg|png|gif|svg|ico|tiff)$/,
  /\.(woff|woff2|ttf|eot)$/,
  /\.(js|css|json|map)$/
].freeze

# start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
# if FEATURES_OF_LEGITIMATE_ROBOTS.match(@user_agent.downcase); nil; end # Exclusion for legitimate `User-Agent`-headers # Use `match?` instead of `match` in Ruby >= 2.4
# end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
# elapsed_time = end_time - start_time
# log_debug("Method `1` executed within #{elapsed_time} sec.")

# start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
# if EXCLUDED_STATIC_PATHS.include?(@request_path); nil; end
# end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
# elapsed_time = end_time - start_time
# log_debug("Method `2` executed within #{elapsed_time} sec.")

# start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
# if EXCLUDED_REGEX_PATTERNS.any? { |x| @request_path =~ x }; nil; end
# end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
# elapsed_time = end_time - start_time
# log_debug("Method `3` executed within #{elapsed_time} sec.")

n = 1000 # Количество итераций для усреднения

#Benchmark.bm do |x|
#  x.report("Method `1`:") do
#    n.times do
#      FEATURES_OF_LEGITIMATE_ROBOTS.match(@user_agent.downcase) # Exclusion for legitimate `User-Agent`-headers # Use `match?` instead of `match` in Ruby >= 2.4
#    end
#  end
#
#  x.report("Method `2`:") do
#    n.times do
#      EXCLUDED_STATIC_PATHS.include?(@request_path)
#    end
#  end
#
#  x.report("Method `3`:") do
#    n.times do
#      EXCLUDED_REGEX_PATTERNS.any? { |x| @request_path =~ x }
#    end
#  end
#end

def path_excluded?()
  is_excluded = (
    # %w[development test].include?(ENV['RACK_ENV']) || # Exclusion for non-production environments
    EXCLUDED_STATIC_PATHS.include?(@request_path) || # Exclusion for exact static path match
    EXCLUDED_REGEX_PATTERNS.any? { |x| @request_path =~ x } || # Exclusion for path matching regular expression
    @legitimate_robot === '1' || !(FEATURES_OF_LEGITIMATE_ROBOTS =~ @user_agent.downcase).nil? # Exclusion for legitimate `User-Agent`-headers # Use `match?` instead of `match` in Ruby >= 2.4
  )
  log_debug("Path is excluded: #{is_excluded.to_s}")
  return is_excluded
end

# path_excluded?()

require 'commonmarker'

multiline = <<~HELLO
## Купить букет цветов на день рождения с доставкой

Интернет-магазин «Розарио.Цветы» предлагает купить букет цветов на день рождения, чтобы порадовать именинника и создать по-настоящему праздничное настроение. У нас вы найдете не просто подарки, а тщательно продуманные флористические композиции: изысканные монобукеты из одного вида цветов и оригинальные авторские варианты. Подобрать и заказать букет можно для женщин, мужчин, мамы, бабушки, подруги, ребенка или любого близкого человека.
### **Ассортимент букетов и флористических композиций**
В каталоге представлены десятки готовых решений - от классических до нестандартных. Наш интернет-магазин позволяет быстро и удобно заказать букет на день рождения в любой район Мурманска. В составе композиций используются:

1. **Розы**, символизирующие любовь и восхищение;
2. **Хризантемы**, говорящие о дружбе и заботе;
3. **Герберы**, передающие радость и оптимизм;
4. **Ромашки** и другие сезонные цветы, придающие букетам свежесть и легкость.

**Вы можете выбрать композиции разного стиля и оформления:**

1. **Классические композиции** в яркой или пастельной упаковке -универсальный подарок, который подойдёт как для шумного торжества, так и для домашнего праздника.
2. **Букеты в шляпных коробках** - практичное и эффектное решение. Такие варианты не требуют вазы, так как внутри коробки располагается флористическая губка с питательным раствором.
3. **Цветочные и фруктовые корзины** - необычный выбор, особенно если вы хотите вручить сюрприз мужчине. Фрукты, сладости или даже безалкогольные напитки в корзине станут приятным дополнением.

Наши флористы помогут собрать уникальный **букет цветов на день рождения** по индивидуальному заказу. Также в наличии готовые варианты - можно выбрать **букеты** по фото и оформить покупку за пару кликов.

Если вас интересует не только покупка, но и бизнес - обратите внимание на нашу **франшизу**. Готовые концепции и обучение позволят быстро стартовать в сфере флористики.
### **Доставка букетов на день рождения день в день**
Мы предлагаем **доставку букетов цветов** на день рождения по Мурманску -быстро, аккуратно и точно ко времени. Наш курьер вручит композицию лично в руки адресату, при необходимости сделает фото получателя с подарком (по согласованию).

**Доставка** осуществляется в удобное для вас время - просто укажите адрес и желаемый интервал при оформлении заказа. Это идеальный способ поздравить близких, даже если вы находитесь в другом городе или стране.

**Чтобы купить букет цветов с доставкой, достаточно:**

1. Выбрать подходящий вариант в каталоге;
2. Заполнить форму на сайте или позвонить нам;
3. Указать точное время **доставки** и контактные данные получателя.

Мы ценим доверие клиентов, поэтому наша **доставка** всегда осуществляется вовремя, а сами **букеты** выглядят так же, как на фото.
### **Оригинальные идеи в букетах: от цветов до десертов**
Флористы «Розарио.Цветы» создают не просто подарки, а настоящие арт-объекты из буктов. Хотите чего-то необычного на день рождения? Мы оформим композицию с фруктами, макарунами или декоративными элементами. Индивидуальный подход позволяет реализовать самые смелые идеи подарков в букетах цветов.

Доставка таких уникальных решений в букете также доступна в пределах города на дом круглосуточно. Ваши близкие будут приятно удивлены вниманием и креативом - заказывайте и не думайте.
HELLO

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

puts markdown_to_html(multiline)
