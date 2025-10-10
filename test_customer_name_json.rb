#!/usr/bin/env ruby
# encoding: utf-8

# Тест функциональности customer_name через json_order

require 'json'
require 'date'

class MockUserAccount
  attr_accessor :id, :surname
  
  def initialize(id:, surname: nil)
    @id = id
    @surname = surname
  end
  
  def present?
    true
  end
end

class MockOrder
  attr_accessor :id, :useraccount_id, :cart, :created_at
  
  def initialize(id:, useraccount_id:, cart:, created_at:)
    @id = id
    @useraccount_id = useraccount_id
    @cart = cart
    @created_at = created_at
  end
  
  def present?
    true
  end
end

class MockSmile
  attr_accessor :json_order, :created_at
  
  def initialize(json_order:, created_at:)
    @json_order = json_order
    @created_at = created_at
  end
  
  def customer_name
    return "Покупатель" unless json_order && !json_order.empty?
    
    begin
      # Парсим json_order и берем первый элемент ("0")
      order_data = JSON.parse(json_order)
      first_item = order_data['0']
      return "Покупатель" unless first_item && first_item['id']
      
      # id в json_order - это ID заказа, а не товара
      order_id = first_item['id'].to_i
      return "Покупатель" unless order_id > 0
      
      # Поиск заказа по точному ID
      matching_order = @mock_orders&.find { |order| order.id == order_id }
      
      return "Покупатель" unless matching_order
      return "Покупатель" unless matching_order.useraccount_id && matching_order.useraccount_id > 0
      
      user_account = @mock_users&.find { |u| u.id == matching_order.useraccount_id }
      return "Покупатель" unless user_account
      
      if user_account.surname && !user_account.surname.empty? && user_account.surname.strip.length > 0
        user_account.surname.strip
      else
        "Покупатель"
      end
      
    rescue => e
      "Покупатель"
    end
  end
  
  # Мок-данные для тестов
  attr_accessor :mock_orders, :mock_users
end

# Тесты
puts "Тестирование customer_name через json_order (по точному ID)..."

# Мок-данные
users = [
  MockUserAccount.new(id: 5, surname: "Петров"),
  MockUserAccount.new(id: 10, surname: "")
]

orders = [
  MockOrder.new(
    id: 3027,  # id в json_order соответствует id заказа
    useraccount_id: 5,
    cart: nil,
    created_at: nil
  ),
  MockOrder.new(
    id: 3028,
    useraccount_id: 10,
    cart: nil,
    created_at: nil
  )
]

# Тест 1: Найден заказ по ID с валидным user_account и surname
smile1 = MockSmile.new(
  json_order: '{"0":{"id":"3027","complect":"standard"}}',
  created_at: nil
)
smile1.mock_orders = orders
smile1.mock_users = users

result1 = smile1.customer_name
expected1 = "Петров"
puts result1 == expected1 ? "✓ Тест 1 прошел: #{result1}" : "✗ Тест 1 не прошел: ожидали '#{expected1}', получили '#{result1}'"

# Тест 2: Найден заказ по ID, но surname пустое
smile2 = MockSmile.new(
  json_order: '{"0":{"id":"3028","complect":"small"}}',
  created_at: nil
)
smile2.mock_orders = orders
smile2.mock_users = users

result2 = smile2.customer_name
expected2 = "Покупатель"
puts result2 == expected2 ? "✓ Тест 2 прошел: #{result2}" : "✗ Тест 2 не прошел: ожидали '#{expected2}', получили '#{result2}'"

# Тест 3: Нет заказа с таким ID
smile3 = MockSmile.new(
  json_order: '{"0":{"id":"9999","complect":"unknown"}}',
  created_at: nil
)
smile3.mock_orders = orders
smile3.mock_users = users

result3 = smile3.customer_name
expected3 = "Покупатель"
puts result3 == expected3 ? "✓ Тест 3 прошел: #{result3}" : "✗ Тест 3 не прошел: ожидали '#{expected3}', получили '#{result3}'"

# Тест 4: Пустой json_order
smile4 = MockSmile.new(
  json_order: "",
  created_at: nil
)

result4 = smile4.customer_name
expected4 = "Покупатель"
puts result4 == expected4 ? "✓ Тест 4 прошел: #{result4}" : "✗ Тест 4 не прошел: ожидали '#{expected4}', получили '#{result4}'"

puts "\nТестирование завершено!"
