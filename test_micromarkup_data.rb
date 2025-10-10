#!/usr/bin/env ruby
# encoding: utf-8

# Тест подстановки данных в микроразметку

require 'date'
require 'time'

class MockSmile
  attr_accessor :created_at, :rating
  
  def initialize(created_at:, rating:)
    @created_at = created_at
    @rating = rating
  end
  
  def formatted_date
    created_at.strftime('%Y-%m-%d')
  end
end

# Тесты
puts "Тестирование подстановки данных в микроразметку..."

# Тест 1: Форматирование даты в YYYY-MM-DD
test_date = Time.new(2023, 12, 25, 14, 30, 0)
smile1 = MockSmile.new(created_at: test_date, rating: 5)
result1 = smile1.formatted_date
expected1 = "2023-12-25"
puts result1 == expected1 ? "✓ Тест 1 (дата) прошел: #{result1}" : "✗ Тест 1 (дата) не прошел: ожидали '#{expected1}', получили '#{result1}'"

# Тест 2: Рейтинг = 5 (по умолчанию)
smile2 = MockSmile.new(created_at: test_date, rating: 5)
result2 = smile2.rating
expected2 = 5
puts result2 == expected2 ? "✓ Тест 2 (рейтинг=5) прошел: #{result2}" : "✗ Тест 2 (рейтинг=5) не прошел: ожидали '#{expected2}', получили '#{result2}'"

# Тест 3: Рейтинг = 4
smile3 = MockSmile.new(created_at: test_date, rating: 4)
result3 = smile3.rating
expected3 = 4
puts result3 == expected3 ? "✓ Тест 3 (рейтинг=4) прошел: #{result3}" : "✗ Тест 3 (рейтинг=4) не прошел: ожидали '#{expected3}', получили '#{result3}'"

# Тест 4: Другая дата
test_date2 = Time.new(2024, 1, 1, 0, 0, 0)
smile4 = MockSmile.new(created_at: test_date2, rating: 3)
result4 = smile4.formatted_date
expected4 = "2024-01-01"
puts result4 == expected4 ? "✓ Тест 4 (дата 2) прошел: #{result4}" : "✗ Тест 4 (дата 2) не прошел: ожидали '#{expected4}', получили '#{result4}'"

# Тест 5: Рейтинг = 3
result5 = smile4.rating
expected5 = 3
puts result5 == expected5 ? "✓ Тест 5 (рейтинг=3) прошел: #{result5}" : "✗ Тест 5 (рейтинг=3) не прошел: ожидали '#{expected5}', получили '#{result5}'"

puts "\nТестирование завершено!"
puts "Пример ERB кода для микроразметки:"
puts "  datePublished: <%=@post.created_at.strftime('%Y-%m-%d')%>"
puts "  ratingValue: <%=@post.rating%>"
