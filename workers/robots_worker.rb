# encoding: utf-8

require_relative 'helper_functions'

# find . -type f -name "*.txt" -size +500k # Рекомендуется не допускать для файла `robots.txt` превышения размера 500 КБ (512 000 байт)

class RobotsWorker # Класс `RobotsWorker` для создания файла `robots.txt` для каждого поддомена
  include Sidekiq::Worker # Инклюдит модуль `Worker` из библиотеки `Sidekiq`, чтобы класс мог выполнять асинхронные задачи
  def perform(name, count, disallow_all=false) # Основной метод для выполнения задачи. Параметры `name` и `count` не используются в этом примере.
    default_values = [ # Список значений, которые по умолчанию будут добавлены в `robots.txt`
      'Disallow: /admin',
      'Disallow: /cart',
      'Disallow: /checkout',
      'Disallow: /search',
      'Disallow: /user',
      'Disallow: /favorites',
      'Disallow: /sessions',
      'Disallow: /*?*',
      # CRUTCH FOR YANDEX FEVER (begin)
      'Disallow: /index',
      'Disallow: /unsubscribe',
      'Disallow: /smile/page',
      'Disallow: /smiles/*',
      'Disallow: /category/802',
      'Disallow: /category/62',
      'Disallow: /cotegory/page',
      'Disallow: /category/10',
      'Disallow: /corporate ',
      'Disallow: /help ',
      'Disallow: /temp ',
      'Disallow: /page/about ',
      'Disallow: /cities ',
      'Disallow: /vozvrat ',
      'Disallow: /rveffervervee ',
      'Disallow: /product/tsvetochnyy-kalendar-1 ',
      'Disallow: /policy ',
      'Disallow: /opl ',
      'Disallow: /category/konfety-rafaello ',
      'Disallow: /category/raznoe ',
      'Disallow: /unsubscribe ',
      'Disallow: /product/85 ',
      'Disallow: /product/668 ',
      'Disallow: /category/katalog ',
      # CRUTCH FOR YANDEX FEVER (end)
      # 'Allow: /icons',
      # 'Allow: /sitemap.xml',
      # 'Allow: /javascripts',
      # 'Allow: /stylesheets',
      # 'Allow: /images',
      # 'Allow: /uploads'
    ]
    default_values.unshift('Disallow: /') if disallow_all
    pages = [ # Список страниц для индексации
      { name: 'article',  type: Article  },
      { name: 'page',     type: Page     },
      { name: 'category', type: Category },
      { name: 'product',  type: Product  },
      { name: 'news',     type: News     },
      { name: 'smile',    type: Smile    }
    ]
    Subdomain.all.each do |s| # Выполнить для каждого субдомена
      begin
        fpath = "public/robots/#{s.url}/robots.txt" # fpath = ENV['RACK_ENV'] === 'development' ? "public/robots/#{s.url}/robots.development.txt" : "public/robots/#{s.url}/robots.txt" # Определяем путь к файлу robots.txt для текущего субдомена
        dpath = File.dirname(fpath) # Определяем путь к файлу robots.txt для текущего субдомена
        FileUtils.mkdir_p(dpath) unless File.directory?(dpath) # Создаем директорию, если она не существует
        file = File.open(fpath, 'w') # Открываем файл robots.txt для записи

        # Записываем в файл правила для поисковика Yandex
        file.puts "User-agent: Yandex\n"
        default_values.each { |v| file.puts "#{v}\n" }
        # file.puts main_pages()
        # indexed(pages).each { |page| file.puts "Allow: /#{page}\n" }
        # indexed(pages, allow: false).each { |page| file.puts "Disallow: /#{page}\n" } if !disallow_all
        file.puts "\n"

        # Записываем правила для всех других поисковых систем
        file.puts "User-agent: *\n"
        default_values.each { |v| file.puts "#{v}\n" }
        # file.puts main_pages()
        # indexed(pages).each { |page| file.puts "Allow: /#{page}\n" }
        # indexed(pages, allow: false).each { |page| file.puts "Disallow: /#{page}\n" } if !disallow_all
        file.puts "\n"

        # Указываем хост и путь к файлу sitemap.xml для текущего субдомена
        pt_url =  s.url != 'murmansk' ? "#{s.url}." : ''
        file.puts "Host: #{pt_url}rozarioflowers.ru"
        file.puts "Sitemap: https://#{pt_url}rozarioflowers.ru/sitemap.xml" 
        file.close # Закрываем файл
      rescue StandardError => e
        logger.error "Error occurred (#{s.url}): #{e.message}\n#{e.backtrace}"
      end
    end
  end
end
