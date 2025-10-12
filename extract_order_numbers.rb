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

puts "Ищем номера заказов в комментариях и сохраняем их..."
puts "=" * 50

# Просим подтверждение перед модификацией
print "Этот скрипт будет МОДИФИЦИРОВАТЬ данные в базе. Продолжить? (yes/нет): "
confirmation = gets.chomp.downcase
unless ['yes', 'y', 'да', 'д'].include?(confirmation)
  puts "Операция отменена."
  exit
end

# Регулярное выражение для поиска номеров заказов
# Ищет "Заказ №" или "Заказ № " с последующим 8-значным числом
order_regex = /Заказ\s*№\s*(\d{8})/i

found_comments = []
updated_comments = []
total_processed = 0
modified_count = 0

# Обрабатываем все комментарии
Comment.find_each do |comment|
  total_processed += 1
  
  # Проверяем поле body на наличие номера заказа
  if comment.body.present?
    original_body = comment.body.dup
    matches = comment.body.scan(order_regex)
    
    unless matches.empty?
      # Берем первый найденный номер заказа
      first_match = matches.first
      order_number = first_match[0]
      
      # Находим полный фрагмент
      match_data = comment.body.match(order_regex)
      text_fragment = match_data[0] if match_data
      
      # Удаляем все вхождения номеров заказов из текста
      cleaned_body = comment.body.gsub(order_regex, '').strip
      # Удаляем лишние пробелы и переносы строк
      cleaned_body = cleaned_body.gsub(/\s+/, ' ').strip
      
      begin
        # Обновляем комментарий только если поле order_eight_digit_id пустое
        if comment.order_eight_digit_id.blank?
          comment.order_eight_digit_id = order_number.to_i
          comment.body = cleaned_body
          
          if comment.save
            modified_count += 1
            
            updated_comments << {
              comment_id: comment.id,
              order_number: order_number,
              text_fragment: text_fragment,
              original_body: original_body[0..100] + (original_body.length > 100 ? '...' : ''),
              cleaned_body: cleaned_body[0..100] + (cleaned_body.length > 100 ? '...' : '')
            }
            
            puts "✅ ID: #{comment.id} | Обновлен | Номер заказа: #{order_number}"
            puts "   Удален фрагмент: '#{text_fragment}'"
            puts "   Новый текст: #{cleaned_body[0..100]}#{cleaned_body.length > 100 ? '...' : ''}"
          else
            puts "❌ Ошибка сохранения ID: #{comment.id} - #{comment.errors.full_messages.join(', ')}"
          end
        else
          puts "⚠️  ID: #{comment.id} | Пропущен (номер заказа уже заполнен: #{comment.order_eight_digit_id})"
        end
        
        found_comments << {
          comment_id: comment.id,
          order_number: order_number,
          text_fragment: text_fragment,
          comment_name: comment.name,
          comment_body_preview: original_body[0..100] + (original_body.length > 100 ? '...' : '')
        }
        
      rescue => e
        puts "❌ Ошибка обработки ID: #{comment.id} - #{e.message}"
      end
      
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
puts "МОДИФИЦИРОВАНО комментариев: #{modified_count}"

if found_comments.any?
  puts "\nСписок всех ID комментариев с номерами заказов:"
  found_comments.each do |item|
    puts "#{item[:comment_id]} -> заказ #{item[:order_number]}"
  end
  
  if updated_comments.any?
    puts "\nОБНОВЛЕННЫЕ комментарии:"
    updated_comments.each do |item|
      puts "ID #{item[:comment_id]}: номер #{item[:order_number]} сохранен, удален '#{item[:text_fragment]}'"
    end
  end
  
  puts "\nУникальные номера заказов:"
  unique_orders = found_comments.map { |item| item[:order_number] }.uniq.sort
  unique_orders.each { |order| puts order }
  
  puts "\nВсего уникальных номеров заказов: #{unique_orders.length}"
else
  puts "Комментарии с номерами заказов не найдены."
end

puts "=" * 50
if modified_count > 0
  puts "✅ Обработка завершена. Модифицировано #{modified_count} комментариев."
else
  puts "Обработка завершена. Никакие изменения не внесены."
end
