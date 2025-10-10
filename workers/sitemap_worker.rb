# encoding: utf-8

require_relative 'helper_functions'

class SitemapWorker # Класс SitemapWorker выполняет создание карты сайта в фоновом процессе с использованием библиотеки Sidekiq.
  include Sidekiq::Worker # Инклюдит модуль Worker из Sidekiq, чтобы класс мог выполнять асинхронные задачи.
  def perform(_name, _count) # Метод perform будет вызван для выполнения задачи. Параметры _name и _count не используются.

    pages = [ # Список страниц с их параметрами для генерации ссылок на сайте
      { name: 'article',  type: Article,  update: 'weekly',  priority: 0.7 },
      { name: 'page',     type: Page,     update: 'yearly',  priority: 0.8 },
      { name: 'category', type: Category, update: 'daily',   priority: 0.9 },
      { name: 'product',  type: Product,  update: 'monthly', priority: 0.9 },
      { name: 'news',     type: News,     update: 'weekly',  priority: 0.7 },
      { name: 'smile',    type: Smile,    update: 'never',   priority: 0.5 }
    ]

    Subdomain.all.each do |s| # Выполнить для каждого имени хоста 3 уровня.
      begin
        pt_url =  s.url != 'murmansk' ? "#{s.url}." : ''
        SitemapGenerator::Sitemap.default_host = "https://#{pt_url}rozarioflowers.ru" # Установка основного хоста # Субдомен murmansk не используется, т.к. вместо него есть корневой домен
        SitemapGenerator::Sitemap.sitemaps_path = "robots/#{s.url}"                   # Путь для сохранения карт сайта (пустой путь, корневой)
        SitemapGenerator::Sitemap.create_index = false                                # Отключение создания индекса карты сайта
        SitemapGenerator::Sitemap.compress = false                                    # Отключение сжатия карты сайта
        SitemapGenerator::Sitemap.filename = 'sitemap'                                # Имя файла для карты сайта
        SitemapGenerator::Sitemap.create do # Собственно, создание карты сайта
          SeoGeneral.where(index: true).all.each { |g| # Проходим по всем объектам SeoGeneral, у которых стоит флаг `index: true`
            unless g.name == 'home_page' # Пропускаем элемент с именем 'home_page'
              add g.url, lastmod: g.updated_at, changefreq: 'weekly', priority: 0.85 # Добавляем URL страницы в карту сайта
            end
          }
          pages.each { |page| # Выполнить для каждой страницы из списка `pages`
            page[:type].includes(:seo).where(seos: { index: true }).all.each { |x| # Генерация пути для страницы категории с учетом уровня
              add get_path(page, x), lastmod: x.updated_at, changefreq: page[:update], priority: page[:priority] # Добавление страницы в карту сайта с данными о дате последнего изменения, частоте обновления и приоритетом
            }
          }
        end
      rescue StandardError => e
        logger.error "Error occurred: #{e.message}"
      end
    end

    # require 'nokogiri'
    # file_path = 'public/robots/murmansk/sitemap.xml'
    # doc = Nokogiri::XML(File.open(file_path))
    # doc.css('loc').each { |loc| loc.content = loc.content.sub('https://murmansk.rozarioflowers.ru', 'https://rozarioflowers.ru') }
    # File.write(file_path, doc.to_xml)
  
  end
end
