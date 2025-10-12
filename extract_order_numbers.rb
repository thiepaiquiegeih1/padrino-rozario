#!/usr/bin/env ruby
# encoding: utf-8

# Скрипт для поиска номеров заказов в тексте комментариев
# Ищет фрагменты вида "Заказ №89054541" или "Заказ № 89054541"

# Устанавливаем окружение
ENV['PADRINO_ENV'] ||= 'development'

begin
  require_relative 'config/boot'
rescue => e
  puts "Ошибка загрузки окружения: #{e.message}"
  puts "Попробуем альтернативный метод..."
  
  # Альтернативный способ загрузки
  require 'bundler/setup'
  require 'active_record'
  require 'mysql2'
  
  # Настройка соединения с базой
  ActiveRecord::Base.establish_connection(
    adapter: 'mysql2',
    host: '127.0.0.1',
    port: 3306,
    encoding: 'utf8',
    reconnect: true,
    database: 'admin_rozario',
    pool: 10,
    username: 'admin',
    password: ENV['MYSQL_PASSWORD'].to_s
  )
  
  # Определяем модель Comment
  class Comment < ActiveRecord::Base
    self.table_name = 'comments'
  end
  
  puts "Прямое соединение с базой установлено."
end

puts "Ищем номера заказов в комментариях..."
puts "=" * 50

# Регулярное выражение для поиска номеров заказов
# Ищет "Заказ №" или "Заказ № " с последующим 8-значным числом
order_regex = /Заказ\s*№\s*(\d{8})/i

found_comments = []
total_processed = 0

# Обрабатываем все комментарии
Comment.find_each do |comment|
  total_processed += 1
  
  # Проверяем поле body на наличие номера заказа
  if comment.body.present?
    matches = comment.body.scan(order_regex)
    
    unless matches.empty?
      matches.each do |match|
        order_number = match[0]  # Извлекаем номер заказа из группы регулярного выражения
        
        found_comments << {
          comment_id: comment.id,
          order_number: order_number,
          text_fragment: comment.body.match(order_regex)[0],  # Полный найденный фрагмент
          comment_name: comment.name,
          comment_body_preview: comment.body[0..100] + (comment.body.length > 100 ? '...' : '')
        }
        
        puts "ID: #{comment.id} | Номер заказа: #{order_number} | Фрагмент: '#{comment.body.match(order_regex)[0]}'"
        puts "  Автор: #{comment.name}"
        puts "  Текст: #{comment.body[0..100]}#{comment.body.length > 100 ? '...' : ''}"
        puts "-" * 50
      end
    end
  end
  
  # Выводим прогресс каждые 100 записей
  if total_processed % 100 == 0
    print "\rОбработано записей: #{total_processed}"
  end
end

print "\rОбработано записей: #{total_processed}\n"
puts "=" * 50
puts "ИТОГИ:"
puts "Всего обработано комментариев: #{total_processed}"
puts "Найдено комментариев с номерами заказов: #{found_comments.length}"

if found_comments.any?
  puts "\nСписок ID комментариев с номерами заказов:"
  found_comments.each do |item|
    puts "#{item[:comment_id]} -> заказ #{item[:order_number]}"
  end
  
  puts "\nУникальные номера заказов:"
  unique_orders = found_comments.map { |item| item[:order_number] }.uniq.sort
  unique_orders.each { |order| puts order }
  
  puts "\nВсего уникальных номеров заказов: #{unique_orders.length}"
else
  puts "Комментарии с номерами заказов не найдены."
end

puts "=" * 50
puts "Поиск завершён."
