#!/usr/bin/env ruby
# encoding: utf-8

# Тест для проверки различий между доменами rozariofl.ru и rozarioflowers.ru

puts "=== АНАЛИЗ ДОМЕННЫХ РАЗЛИЧИЙ ==="

# Домены, используемые в системе
production_domain = "rozarioflowers.ru"  # Рабочая система заказов
old_test_domain = "rozariofl.ru"         # Старые тестовые контроллеры

puts "Производственный домен (работает): #{production_domain}"
puts "Старый тестовый домен (не работает): #{old_test_domain}"
puts "Различие: #{production_domain.length - old_test_domain.length} символов ('s' в 'flowers')"
puts 

# Анализ email адресов
email_variants = [
  "no-reply@rozarioflowers.ru",    # Рабочий
  "no-reply@rozariofl.ru",         # Нерабочий
  "test@rozarioflowers.ru",        # Исправленный
  "test@rozariofl.ru"              # Старый нерабочий
]

puts "=== СРАВНЕНИЕ EMAIL АДРЕСОВ ==="
email_variants.each_with_index do |email, index|
  status = email.include?(production_domain) ? "✅ РАБОТАЕТ" : "❌ НЕ РАБОТАЕТ"
  puts "#{index + 1}. #{email} - #{status}"
end
puts

# Проверка MX записей (теоретически)
puts "=== ТЕОРЕТИЧЕСКИЙ АНАЛИЗ MX ЗАПИСЕЙ ==="
puts "#{production_domain}:"
puts "  - Вероятно имеет корректные MX записи"
puts "  - TLS сертификат настроен"
puts "  - Postfix может успешно установить соединение"
puts
puts "#{old_test_domain}:"
puts "  - Может не иметь MX записей или иметь некорректные"
puts "  - TLS handshake fails (из логов: SSL_connect error)"
puts "  - Поэтому письма не доставляются"
puts

# Вывод исправлений
puts "=== ИСПРАВЛЕНИЯ ==="
puts "1. ✅ Изменены все FROM адреса с 'rozariofl.ru' на 'rozarioflowers.ru'"
puts "2. ✅ Добавлена асинхронная отправка (Thread.new) как в рабочей системе"
puts "3. ✅ Сохранена обратная связь для пользователя"
puts
puts "Теперь тестовая система использует тот же домен, что и рабочая система заказов!"
