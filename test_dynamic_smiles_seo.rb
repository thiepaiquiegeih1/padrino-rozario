#!/usr/bin/env ruby
# encoding: utf-8

# Тест динамической SEO системы для smiles
# Этот файл проверяет работу новой функциональности

require_relative 'config/boot'

def test_seo_general_creation
  puts "\n=== Тест создания записи SeoGeneral для smiles ==="
  
  # Проверяем, существует ли запись
  smiles_seo = SeoGeneral.find_by_name('smiles')
  
  if smiles_seo
    puts "✓ Запись 'smiles' найдена в таблице seo_generals"
    puts "  Title: #{smiles_seo.title}"
    puts "  Description: #{smiles_seo.description[0..100]}..."
    puts "  H1: #{smiles_seo.h1}"
    puts "  H2: #{smiles_seo.h2}"
    puts "  Index: #{smiles_seo.index}"
  else
    puts "✗ Запись 'smiles' НЕ найдена в таблице seo_generals"
    
    # Создаем запись
    puts "Создаем запись..."
    smiles_seo = SeoGeneral.create!(
      name: 'smiles',
      title: 'Фото доставки цветов - Отзывы клиентов',
      description: 'Посмотрите фотографии наших работ - реальные отзывы клиентов с фото доставленных букетов.',
      keywords: 'фото доставки цветов, отзывы с фото',
      h1: 'Фото доставки цветов',
      h2: 'Отзывы наших клиентов',
      og_type: 'website',
      og_title: 'Фото доставки цветов - Отзывы клиентов с фотографиями',
      og_description: 'Посмотрите фотографии наших работ - реальные отзывы клиентов с фото доставленных букетов.',
      og_site_name: 'Rozario Flowers',
      twitter_title: 'Фото доставки цветов - Отзывы клиентов',
      twitter_description: 'Посмотрите фотографии наших работ - реальные отзывы клиентов.',
      twitter_site: '@rozarioflowers',
      twitter_image_alt: 'Фото доставки цветов',
      index: true,
      url: '/smiles/',
      page: true
    )
    puts "✓ Запись создана с ID: #{smiles_seo.id}"
  end
end

def test_smile_with_seo
  puts "\n=== Тест работы SEO для конкретной страницы smile ==="
  
  # Получаем первую улыбку с данными
  smile = Smile.where("json_order IS NOT NULL AND json_order != ''").first
  
  if smile
    puts "✓ Найдена smile с ID: #{smile.id}"
    puts "  Title: #{smile.title}"
    puts "  Customer name: #{smile.customer_name}"
    puts "  Rating: #{smile.rating}"
    
    # Проверяем парсинг json_order
    begin
      order_data = JSON.parse(smile.json_order)
      first_item = order_data['0']
      if first_item
        product_id = first_item['id'].to_i
        product = Product.find_by_id(product_id)
        puts "  Product ID: #{product_id}"
        puts "  Product found: #{product ? 'YES' : 'NO'}"
        puts "  Product name: #{product.header if product}"
      else
        puts "  ✗ Нет данных в json_order['0']"
      end
    rescue => e
      puts "  ✗ Ошибка парсинга JSON: #{e.message}"
    end
    
    # Тестируем get_seo_data
    puts "\n--- Тест функции get_seo_data ---"
    
    # Имитируем вызов как в контроллере
    class MockApp
      include Rozario::App.helpers
      
      def initialize
        @subdomain = Subdomain.first
        @general_seo_data = nil
      end
      
      def test_get_seo_data
        get_seo_data('smiles', smile.seo_id)
        puts "SEO data loaded:"
        puts "  Title: #{@seo[:title]}"
        puts "  Description: #{@seo[:description][0..100] if @seo[:description]}..."
        puts "  General SEO data available: #{@general_seo_data ? 'YES' : 'NO'}"
        
        if @general_seo_data
          puts "  H1 from general: #{@general_seo_data[:h1]}"
          puts "  H2 from general: #{@general_seo_data[:h2]}"
        end
      end
    end
    
    app = MockApp.new
    app.test_get_seo_data
    
  else
    puts "✗ Не найдено ни одной smile с данными json_order"
  end
end

def test_helper_functions
  puts "\n=== Тест вспомогательных функций ==="
  
  # Тестируем функции генерации SEO данных
  smile = Smile.first
  
  if smile
    puts "✓ Тестируем на smile ID: #{smile.id}"
    
    # Тест generate_smile_title
    puts "\n--- generate_smile_title ---"
    begin
      class MockHelper
        include Rozario::App.helpers
      end
      
      helper = MockHelper.new
      title = helper.generate_smile_title(smile.id)
      puts "Generated title: #{title || 'nil'}"
    rescue => e
      puts "✗ Ошибка: #{e.message}"
    end
    
    # Тест generate_smile_description
    puts "\n--- generate_smile_description ---"
    begin
      description = helper.generate_smile_description(smile.id, "Original description")
      puts "Generated description: #{description[0..100] if description}..."
    rescue => e
      puts "✗ Ошибка: #{e.message}"
    end
    
  else
    puts "✗ Не найдено ни одной smile для тестирования"
  end
end

def main
  puts "Тестирование динамической SEO системы для smiles"
  puts "=" * 60
  
  begin
    test_seo_general_creation
    test_smile_with_seo
    test_helper_functions
    
    puts "\n" + "=" * 60
    puts "✓ Тестирование завершено успешно"
  rescue => e
    puts "\n✗ Ошибка при тестировании: #{e.message}"
    puts e.backtrace.first(5).join("\n")
  end
end

main if __FILE__ == $0
