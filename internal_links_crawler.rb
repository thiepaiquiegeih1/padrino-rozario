require 'nokogiri'
require 'open-uri'
require 'set'
require 'json'

# Функция для получения всех URL из sitemap.xml
def parse_sitemap(sitemap_url)
  urls = []
  begin
    # Загружаем sitemap с пользовательским User-Agent
    response = open(sitemap_url, 'User-Agent' => 'Ruby/2.3.8 Crawler')
    sitemap_content = response.read
    
    # Выводим содержимое sitemap
    # puts "\n=== Содержимое sitemap (#{sitemap_url}) ===\n"
    # puts sitemap_content
    # puts "\n=== Конец содержимого sitemap ===\n"

    doc = Nokogiri::XML(sitemap_content)
    
    # Проверяем ошибки парсинга XML
    if doc.errors.any?
      puts "Ошибки при парсинге XML: #{doc.errors.join(', ')}"
      return urls
    end

    doc.css('loc').each do |loc|
      puts "Найден URL: #{loc.text.strip}"
      url = loc.text.strip
      urls << url unless url.empty?
    end

    puts "Успешно найдено #{urls.size} URL в sitemap"
  rescue OpenURI::HTTPError => e
    puts "HTTP ошибка при загрузке sitemap #{sitemap_url}: #{e.message}"
  rescue StandardError => e
    puts "Ошибка при парсинге sitemap #{sitemap_url}: #{e.message}"
  end
  urls
end

# Функция для сбора ссылок с одной страницы
def collect_links_from_page(page_url, domain)
  links = Set.new
  begin
    response = open(page_url, 'User-Agent' => 'Ruby/2.3.8 Crawler')
    doc = Nokogiri::HTML(response.read)
    doc.css('a[href]').each do |link|
      href = link['href']
      absolute_url = URI.join(page_url, href).to_s
      links.add(absolute_url) if URI.parse(absolute_url).host == domain
    end
  rescue OpenURI::HTTPError => e
    puts "HTTP ошибка при загрузке страницы #{page_url}: #{e.message}"
  rescue StandardError => e
    puts "Ошибка при обработке страницы #{page_url}: #{e.message}"
  end
  links.to_a
end

# Основная функция для обхода sitemap и сбора ссылок
def crawl_sitemap(sitemap_url)
  link_data = {}
  begin
    domain = URI.parse(sitemap_url).host
  rescue URI::InvalidURIError
    puts "Некорректный URL sitemap: #{sitemap_url}"
    return link_data
  end

  # Получаем все URL из sitemap
  urls = parse_sitemap(sitemap_url)
  if urls.empty?
    puts "Sitemap пуст или не удалось загрузить. Прерывание."
    return link_data
  end

  # Обходим каждую страницу
  urls.each_with_index do |url, index|
    puts "Обработка #{index + 1}/#{urls.size}: #{url}"
    link_data[url] = collect_links_from_page(url, domain)
  end

  link_data
end

# Функция для сохранения данных в JSON
def save_to_json(data, filename = 'links_data.json')
  File.open(filename, 'w') do |file|
    file.write(JSON.pretty_generate(data))
  end
  puts "Данные сохранены в #{filename}"
end

# Обработка прерывания (Ctrl+C)
def with_interrupt_handling
  yield
rescue Interrupt
  puts "\nПрерывание работы скрипта..."
  throw :interrupted
end

# Основной блок
begin
  sitemap_url = ARGV[0] || 'https://rozarioflowers.ru/sitemap.xml'
  link_data = nil

  # Выполняем обход с обработкой прерывания
  catch :interrupted do
    with_interrupt_handling do
      link_data = crawl_sitemap(sitemap_url)
    end
  end

  # Сохраняем данные, если они были собраны
  save_to_json(link_data) if link_data && !link_data.empty?
rescue StandardError => e
  puts "Произошла ошибка: #{e.message}"
end
