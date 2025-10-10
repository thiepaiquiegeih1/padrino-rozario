#!/usr/bin/env ruby
# encoding: utf-8

# Отладка reviewBody в микроразметке smiles
require_relative 'config/boot'

def test_review_body_generation
  puts "=== Отладка reviewBody ==="
  
  # Найти первую улыбку с данными
  smile = Smile.where("json_order IS NOT NULL AND json_order != ''").first
  
  if smile
    puts "Найдена smile ID: #{smile.id}"
    puts "Title: #{smile.title}"
    
    # Проверить наличие записи в seo_generals
    seo_general = SeoGeneral.find_by_name('smiles')
    if seo_general
      puts "\nSeoGeneral найден:"
      puts "  H2 (review_body): '#{seo_general.h2}'"
      puts "  H1 (author_name): '#{seo_general.h1}'"
      puts "  Description: '#{seo_general.description}'"
    else
      puts "\nSeoGeneral НЕ найден - создаем..."
      seo_general = SeoGeneral.create!(
        name: 'smiles',
        h2: 'Тестовый текст отзыва для микроразметки',
        h1: 'Довольный покупатель',
        description: 'Посмотрите фотографии наших работ - реальные отзывы клиентов'
      )
      puts "Создан SeoGeneral ID: #{seo_general.id}"
    end
    
    # Эмуляция логики из контроллера
    puts "\n=== Эмуляция get_seo_data ==="
    
    class TestApp
      include Rozario::App.helpers
      
      def initialize
        @subdomain = Subdomain.first
        @general_seo_data = nil
      end
      
      def test_seo_flow
        puts "Вызываем get_seo_data('smiles', #{smile.seo_id})"
        get_seo_data('smiles', smile.seo_id)
        
        puts "@seo: #{@seo.inspect}"
        puts "@general_seo_data: #{@general_seo_data.inspect}"
        
        # Эмуляция логики из представления
        seo_data = {}
        if @general_seo_data
          seo_data[:review_body] = @general_seo_data[:h2] if @general_seo_data[:h2] && !@general_seo_data[:h2].empty?
          seo_data[:author_name] = @general_seo_data[:h1] if @general_seo_data[:h1] && !@general_seo_data[:h1].empty?
          seo_data[:breadcrumb_title] = @general_seo_data[:description] if @general_seo_data[:description] && !@general_seo_data[:description].empty?
        end
        
        puts "\nПодготовленные seo_data:"
        puts "  review_body: '#{seo_data[:review_body]}'"
        puts "  author_name: '#{seo_data[:author_name]}'"
        puts "  breadcrumb_title: '#{seo_data[:breadcrumb_title]}'"
        
        # Генерация схемы
        puts "\n=== Генерация Review Schema ==="
        
        # Диагностика перед генерацией
        puts "smile.json_order: #{smile.json_order ? 'present' : 'missing'}"
        puts "seo_data: #{seo_data.inspect}"
        
        schema = generate_smile_review_schema(smile, seo_data)
        puts "Результат генерации: #{schema ? ("длина " + schema.length.to_s) : 'nil/empty'}"
        if schema && !schema.empty?
          puts "Успешно сгенерировано:"
          # Извлекаем JSON из script тега
          json_match = schema.match(/<script[^>]*>\s*(.+?)\s*<\/script>/m)
          if json_match
            begin
              parsed = JSON.parse(json_match[1])
              puts "  reviewBody: '#{parsed['reviewBody']}'"
              puts "  author.name: '#{parsed['author']['name']}'"
              puts "  itemReviewed.name: '#{parsed['itemReviewed']['name']}'"
            rescue => e
              puts "Ошибка парсинга JSON: #{e.message}"
              puts "Raw schema: #{schema}"
            end
          else
            puts "Не удалось извлечь JSON из схемы"
            puts "Raw schema: #{schema}"
          end
        else
          puts "Схема пуста или не сгенерирована!"
        end
      end
    end
    
    app = TestApp.new
    app.test_seo_flow
    
  else
    puts "Не найдено ни одной smile с json_order"
  end
end

begin
  test_review_body_generation
rescue => e
  puts "Ошибка: #{e.message}"
  puts e.backtrace.first(5).join("\n")
end
