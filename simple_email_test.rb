#!/usr/bin/env ruby
# encoding: utf-8

# Простой тест для проверки логики обработки параметров
require 'cgi'

def simulate_email_form_response(params)
  puts "Тестируем параметры: #{params.inspect}"
  
  # Логика как в контроллере
  status_message = ''
  if params[:success] == 'sent'
    status_message = "✅ Письмо успешно отправлено! Получатель: #{params[:to]}"
  elsif params[:error]
    error_text = case params[:error]
    when 'no_recipient'
      'Не указан получатель и ORDER_EMAIL не установлена'
    when 'missing_fields'
      'Не заполнены обязательные поля (тема или текст)'
    when 'send_failed'
      "Ошибка отправки: #{params[:message]}"
    else
      'Неизвестная ошибка'
    end
    
    status_message = "❌ Ошибка отправки письма: #{error_text}"
  else
    status_message = "ℹ️ Обычное состояние формы"
  end
  
  puts "Результат: #{status_message}"
  puts "---"
end

# Тестируем различные сценарии
puts "=== ТЕСТИРОВАНИЕ ЛОГИКИ ОБРАТНОЙ СВЯЗИ ==="

# Успешная отправка
simulate_email_form_response({
  success: 'sent',
  to: 'user@example.com'
})

# Ошибка - нет получателя
simulate_email_form_response({
  error: 'no_recipient'
})

# Ошибка - не заполнены поля
simulate_email_form_response({
  error: 'missing_fields'
})

# Ошибка отправки
simulate_email_form_response({
  error: 'send_failed',
  message: 'Connection timeout'
})

# Обычное состояние
simulate_email_form_response({})

puts "\n=== ТЕСТИРОВАНИЕ CGI ЭКРАНИРОВАНИЯ ==="

# Тестируем CGI.escape для различных символов
test_emails = [
  'user@example.com',
  'test+user@domain.com',
  'пользователь@домен.рф',
  'user with spaces@example.com'
]

test_emails.each do |email|
  escaped = CGI.escape(email)
  puts "Исходный: #{email}"
  puts "Экранированный: #{escaped}"
  puts "---"
end

puts "\nТесты завершены! ✅"
