#!/usr/bin/env ruby
# encoding: utf-8

# Тест функциональности customer_name

class MockUserAccount
  attr_accessor :surname
  
  def initialize(surname: nil)
    @surname = surname
  end
  
  def present?
    true
  end
end

class MockOrder
  attr_accessor :useraccount_id, :useraccount
  
  def initialize(useraccount_id: nil, useraccount: nil)
    @useraccount_id = useraccount_id
    @useraccount = useraccount
  end
  
  def present?
    true
  end
end

class MockSmile
  attr_accessor :order
  
  def initialize(order: nil)
    @order = order
  end
  
  def customer_name
    return "Покупатель" unless order && order.present?
    return "Покупатель" unless order.useraccount_id && order.useraccount_id > 0
    
    user_account = order.useraccount
    return "Покупатель" unless user_account && user_account.present?
    
    if user_account.surname && !user_account.surname.empty? && user_account.surname.strip.length > 0
      user_account.surname.strip
    else
      "Покупатель"
    end
  end
end

# Тесты
puts "Тестирование функциональности customer_name..."

# Тест 1: Есть user_account с surname
user1 = MockUserAccount.new(surname: "Петров")
order1 = MockOrder.new(useraccount_id: 5, useraccount: user1)
smile1 = MockSmile.new(order: order1)
result1 = smile1.customer_name
expected1 = "Петров"
puts result1 == expected1 ? "✓ Тест 1 прошел: #{result1}" : "✗ Тест 1 не прошел: ожидали '#{expected1}', получили '#{result1}'"

# Тест 2: Нет surname
user2 = MockUserAccount.new(surname: "")
order2 = MockOrder.new(useraccount_id: 5, useraccount: user2)
smile2 = MockSmile.new(order: order2)
result2 = smile2.customer_name
expected2 = "Покупатель"
puts result2 == expected2 ? "✓ Тест 2 прошел: #{result2}" : "✗ Тест 2 не прошел: ожидали '#{expected2}', получили '#{result2}'"

# Тест 3: useraccount_id = 0 (по умолчанию)
user3 = MockUserAccount.new(surname: "Иванов")
order3 = MockOrder.new(useraccount_id: 0, useraccount: user3)
smile3 = MockSmile.new(order: order3)
result3 = smile3.customer_name
expected3 = "Покупатель"
puts result3 == expected3 ? "✓ Тест 3 прошел: #{result3}" : "✗ Тест 3 не прошел: ожидали '#{expected3}', получили '#{result3}'"

# Тест 4: Нет заказа
smile4 = MockSmile.new
result4 = smile4.customer_name
expected4 = "Покупатель"
puts result4 == expected4 ? "✓ Тест 4 прошел: #{result4}" : "✗ Тест 4 не прошел: ожидали '#{expected4}', получили '#{result4}'"

# Тест 5: Пробелы в surname
user5 = MockUserAccount.new(surname: "  Сидоров  ")
order5 = MockOrder.new(useraccount_id: 10, useraccount: user5)
smile5 = MockSmile.new(order: order5)
result5 = smile5.customer_name
expected5 = "Сидоров"
puts result5 == expected5 ? "✓ Тест 5 прошел: #{result5}" : "✗ Тест 5 не прошел: ожидали '#{expected5}', получили '#{result5}'"

puts "\nТестирование завершено!"
