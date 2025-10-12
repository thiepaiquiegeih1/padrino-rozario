#!/usr/bin/env ruby
# encoding: utf-8

# Скрипт для очистки HTML-тегов из поля body в таблице comments
# Удаляет все HTML-теги и сохраняет только чистый текст

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

puts "Очистка HTML-тегов в комментариях..."
puts "=" * 50

# Просим подтверждение перед модификацией
print "Этот скрипт будет МОДИФИЦИРОВАТЬ текст комментариев (удалит HTML). Продолжить? (yes/нет): "
confirmation = gets.chomp.downcase
unless ['yes', 'y', 'да', 'д'].include?(confirmation)
  puts "Операция отменена."
  exit
end

# Функция для очистки HTML и извлечения только текстового содержимого
def clean_html(text)
  return text if text.blank?
  
  cleaned = text.dup
  
  # Заменяем блочные теги на переносы строк для сохранения структуры
  block_tags = ['p', 'div', 'br', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'blockquote', 'li', 'ul', 'ol']
  block_tags.each do |tag|
    # Заменяем закрывающие теги на перенос строки
    cleaned = cleaned.gsub(/<\/#{tag}>/i, "\n")
    # Удаляем открывающие теги
    cleaned = cleaned.gsub(/<#{tag}[^>]*>/i, '')
  end
  
  # Заменяем одиночные <br> на переносы строк
  cleaned = cleaned.gsub(/<br\s*\/?>/i, "\n")
  
  # Удаляем все остальные HTML-теги
  cleaned = cleaned.gsub(/<[^>]*>/, '')
  
  # Заменяем HTML-сущности на обычные символы
  html_entities = {
    '&nbsp;' => ' ',
    '&amp;' => '&',
    '&lt;' => '<',
    '&gt;' => '>',
    '&quot;' => '"',
    '&apos;' => "'",
    '&#39;' => "'",
    '&#34;' => '"',
    '&#38;' => '&',
    '&#60;' => '<',
    '&#62;' => '>',
    '&mdash;' => '—',
    '&ndash;' => '–',
    '&ldquo;' => '“',
    '&rdquo;' => '”',
    '&lsquo;' => '‘',
    '&rsquo;' => '’',
    '&hellip;' => '...',
    '&copy;' => '©',
    '&reg;' => '®',
    '&trade;' => '™'
  }
  
  html_entities.each do |entity, replacement|
    cleaned = cleaned.gsub(entity, replacement)
  end
  
  # Очищаем от лишних переносов строк и пробелов
  # Удаляем многократные переносы строк
  cleaned = cleaned.gsub(/\n\s*\n+/, "\n")
  # Очищаем лишние пробелы внутри строк
  cleaned = cleaned.gsub(/ +/, ' ')
  # Убираем пробелы в начале и конце каждой строки
  cleaned = cleaned.split("\n").map(&:strip).join("\n")
  # Убираем пустые строки
  cleaned = cleaned.split("\n").reject(&:empty?).join(" ")
  
  cleaned.strip
end

found_html_comments = []
cleaned_comments = []
total_processed = 0
modified_count = 0

# Обрабатываем все комментарии
Comment.find_each do |comment|
  total_processed += 1
  
  # Проверяем наличие HTML-тегов в тексте
  if comment.body.present? && (comment.body.include?('<') || comment.body.include?('&'))
    original_body = comment.body.dup
    cleaned_body = clean_html(comment.body)
    
    # Проверяем, есть ли различия после очистки
    if original_body != cleaned_body
      found_html_comments << {
        comment_id: comment.id,
        original_body: original_body,
        cleaned_body: cleaned_body,
        comment_name: comment.name || '(без имени)'
      }
      
      begin
        # Обновляем комментарий
        comment.body = cleaned_body
        
        if comment.save
          modified_count += 1
          
          cleaned_comments << {
            comment_id: comment.id,
            original_preview: original_body[0..100] + (original_body.length > 100 ? '...' : ''),
            cleaned_preview: cleaned_body[0..100] + (cleaned_body.length > 100 ? '...' : '')
          }
          
          puts "✅ ID: #{comment.id} | Очищен от HTML"
          puts "   Автор: #{comment.name || '(без имени)'}"
          puts "   Было: #{original_body[0..80]}#{original_body.length > 80 ? '...' : ''}"
          puts "   Стало: #{cleaned_body[0..80]}#{cleaned_body.length > 80 ? '...' : ''}"
        else
          puts "❌ Ошибка сохранения ID: #{comment.id} - #{comment.errors.full_messages.join(', ')}"
        end
        
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
puts "Найдено комментариев с HTML: #{found_html_comments.length}"
puts "ОЧИЩЕНО комментариев: #{modified_count}"

if found_html_comments.any?
  puts "\nСписок всех ID комментариев с HTML:"
  found_html_comments.each do |item|
    puts "#{item[:comment_id]} (Автор: #{item[:comment_name]})"
  end
  
  if cleaned_comments.any?
    puts "\nОЧИЩЕННЫЕ комментарии:"
    cleaned_comments.each do |item|
      puts "ID #{item[:comment_id]}: HTML-теги удалены, текст очищен"
      puts "  Превью: #{item[:cleaned_preview]}"
    end
  end
  
else
  puts "Комментарии с HTML-тегами не найдены."
end

puts "=" * 50
if modified_count > 0
  puts "✅ Очистка завершена. Очищено #{modified_count} комментариев."
else
  puts "Очистка завершена. Никакие изменения не внесены."
end
