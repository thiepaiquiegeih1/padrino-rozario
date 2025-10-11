# 📧 Настройка почтовой системы для Rozario Flowers

## 🔍 Проблема
Письма с отзывами не отправляются администратору.

## 🔧 Причины:
1. **Не установлена переменная окружения `ORDER_EMAIL`**
2. **Не настроен почтовый сервер (sendmail/postfix)**

## ⚙️ Решение:

### Шаг 1: Установить переменную окружения

**Для development/test:**
```bash
export ORDER_EMAIL="admin@rozarioflowers.ru"
# или добавить в .env файл:
echo "ORDER_EMAIL=admin@rozarioflowers.ru" >> .env
```

**Для production:**
```bash
# В systemd service файле или в конфигурации Passenger:
Environment=ORDER_EMAIL=a.krit@rozariofl.ru
```

### Шаг 2: Настроить почтовый сервер

**Опция A: Установить sendmail**
```bash
# Ubuntu/Debian:
sudo apt-get update
sudo apt-get install sendmail sendmail-cf
sudo sendmailconfig
sudo systemctl start sendmail
sudo systemctl enable sendmail
```

**Опция B: Настроить SMTP (рекомендуемо)**
Модифицировать `app/app.rb`:
```ruby
# Заменить:
set :delivery_method, :sendmail

# На:
if PADRINO_ENV == 'production'
  set :delivery_method, :smtp => {
    :address         => 'smtp.gmail.com',  # или ваш SMTP сервер
    :port            => 587,
    :user_name       => ENV['SMTP_USER'],
    :password        => ENV['SMTP_PASSWORD'],
    :authentication  => :plain,
    :enable_starttls_auto => true
  }
else
  # Для development - можно использовать логирование вместо отправки
  set :delivery_method, :test
end
```

И добавить переменные окружения:
```bash
export SMTP_USER="your-email@gmail.com"
export SMTP_PASSWORD="your-app-password"
```

### Шаг 3: Проверить настройки

Создайте тестовый скрипт:
```ruby
#!/usr/bin/env ruby
require 'bundler/setup' 
require File.expand_path('../config/boot.rb', __FILE__)

puts "ORDER_EMAIL: '#{ENV['ORDER_EMAIL']}'"
puts "Delivery method: #{Padrino.application.delivery_method}"

begin
  email do
    from "no-reply@rozariofl.ru"
    to ENV['ORDER_EMAIL'].to_s
    subject "Test email from Padrino"
    body "Test successful!"
  end
  puts "✅ Email sent successfully"
rescue => e
  puts "❌ Error: #{e.message}"
end
```

### Шаг 4: Проверить отзывы

После настройки:
1. Откройте `/comment` на сайте
2. Авторизуйтесь
3. Оставьте тестовый отзыв
4. Проверьте почту в `ORDER_EMAIL`

## 📝 Логи

Теперь в логах приложения будут отображаться:
- ✅ Успешная отправка email
- ❌ Ошибки отправки
- ⚠️ Предупреждения о ненастроенных переменных

## 🔍 Отладка

**Проверка переменных:**
```bash
echo "ORDER_EMAIL: $ORDER_EMAIL"
```

**Проверка sendmail:**
```bash
which sendmail
systemctl status sendmail
```

**Проверка логов:**
```bash
tail -f /var/log/mail.log
tail -f log/production.log  # логи Padrino
```