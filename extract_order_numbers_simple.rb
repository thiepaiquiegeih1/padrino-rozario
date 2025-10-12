#!/usr/bin/env ruby
# encoding: utf-8

# Простой скрипт для поиска номеров заказов в тексте комментариев
# Ищет фрагменты вида "Заказ №89054541" или "Заказ № 89054541"

require 'mysql2'

puts "Ищем номера заказов в комментариях..."
puts "=" * 50

# Подключение к базе данных
begin
  client = Mysql2::Client.new(
    host: '127.0.0.1',
    username: 'admin', 
    password: ENV['MYSQL_PASSWORD'] || 'password',
    database: 'admin_rozario',
    encoding: 'utf8'
  )
  
  puts "Успешно подключились к базе данных."
rescue => e
  puts "Ошибка подключения к базе: #{e.message}"
  exit 1
end

# Регулярное выражение для поиска номеров заказов
order_regex = /Заказ\s*№\s*(\d{8})/i

found_comments = []
total_processed = 0

# Получаем все комментарии с непустым текстом
query = "SELECT id, name, body FROM comments WHERE body IS NOT NULL AND body != ''"
results = client.query(query)

puts "Начинаем обработку #{results.count} комментариев..."

results.each do |row|
  total_processed += 1
  comment_id = row['id']
  comment_name = row['name'] || '(без имени)'
  comment_body = row['body'] || ''
  
  # Проверяем наличие номера заказа в тексте
  matches = comment_body.scan(order_regex)
  
  unless matches.empty?
    matches.each do |match|
      order_number = match[0]  # Извлекаем номер заказа
      
      # Находим полный фрагмент
      match_data = comment_body.match(order_regex)
      text_fragment = match_data ? match_data[0] : "Заказ №#{order_number}"
      
      found_comments << {
        comment_id: comment_id,
        order_number: order_number,
        text_fragment: text_fragment,
        comment_name: comment_name,
        comment_body_preview: comment_body[0..100] + (comment_body.length > 100 ? '...' : '')
      }
      
      puts "ID: #{comment_id} | Номер заказа: #{order_number} | Фрагмент: '#{text_fragment}'"
      puts "  Автор: #{comment_name}"
      puts "  Текст: #{comment_body[0..100]}#{comment_body.length > 100 ? '...' : ''}"
      puts "-" * 50
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

client.close
