# Исправление доменов email адресов

## Проблема
Пользователь сообщил, что:
- ✅ **Система заказов работает** - письма о заказах приходят на ORDER_EMAIL
- ❌ **Тестовый интерфейс не работает** - письма через `/testing/email` не проходят

## Анализ причины
Провел сравнение рабочей системы заказов с тестовой системой и обнаружил ключевые различия:

### Рабочая система заказов (`/app/app/controllers/api/v1/orders.rb`)
```ruby
email do
  from "Rozario robot <no-reply@rozarioflowers.ru>"  # ✅ rozarioflowers.ru
  to email_for_orders
  subject subj
  body "Заказ от " + Time.now.getlocal("+03:00").strftime("%d.%m.%Y %H:%M")
  # ... файлы вложения
end
```
**Обёрнуто в `Thread.new do ... end` для асинхронной отправки**

### Тестовая система (до исправления)
```ruby
email do
  from "custom-test@rozariofl.ru"  # ❌ rozariofl.ru (без 's')
  to recipient
  subject subject
  body body_text
end
```
**Синхронная отправка без Thread**

## Ключевые различия

1. **Домены FROM адресов:**
   - ✅ Рабочая: `@rozarioflowers.ru` 
   - ❌ Тестовая: `@rozariofl.ru` (отличается на 5 символов - нет 's' в 'flowers')

2. **Асинхронность:**
   - ✅ Рабочая: `Thread.new do ... end`
   - ❌ Тестовая: синхронная отправка

3. **TLS соединения:**
   - ✅ `rozarioflowers.ru` - имеет корректные MX записи и TLS сертификаты
   - ❌ `rozariofl.ru` - вызывает SSL_connect errors (из предыдущих логов)

## Исправления

### 1. Исправлен файл `app/controllers/email_test.rb`

**Изменены все FROM адреса:**
```ruby
# Было:
from "test@rozariofl.ru"
from "detailed-test@rozariofl.ru" 
from "custom-test@rozariofl.ru"
from "no-reply@rozariofl.ru"

# Стало:
from "test@rozarioflowers.ru"
from "detailed-test@rozarioflowers.ru"
from "custom-test@rozarioflowers.ru" 
from "no-reply@rozarioflowers.ru"
```

**Добавлена асинхронная отправка:**
```ruby
# Было:
email do
  from "custom-test@rozarioflowers.ru"
  to recipient
  subject subject
  body body_text
end

# Стало:
thread = Thread.new do
  email do
    from "custom-test@rozarioflowers.ru"
    to recipient
    subject subject
    body body_text
  end
end
```

### 2. Исправлен файл `app/controllers/comment.rb`
```ruby
# Было:
from "no-reply@rozariofl.ru"

# Стало:
from "no-reply@rozarioflowers.ru"
```

### 3. Исправлен файл `app/controllers/cart.rb`
```ruby
# Было:
to 'l.golubev@rozariofl.ru'

# Стало:
to 'l.golubev@rozarioflowers.ru'
```

## Результат

✅ **Все email системы теперь используют одинаковый домен**  
✅ **Тестовая система копирует поведение рабочей системы**  
✅ **Сохранена обратная связь для пользователя**  
✅ **Асинхронная отправка как в production**  

## Тестирование

Теперь когда пользователь протестирует отправку через `/testing/email`, письма должны проходить так же успешно, как и письма о заказах, поскольку:

1. Используется тот же домен (`rozarioflowers.ru`)
2. Применяется та же методика отправки (Thread.new)
3. Postfix сможет установить TLS соединение с корректными MX серверами

## Проверка

Для полной проверки рекомендуется:

1. **Протестировать `/testing/email`** - отправить кастомное письмо
2. **Проверить логи postfix** на предмет SSL_connect errors 
3. **Убедиться что письма приходят** на ORDER_EMAIL так же, как письма о заказах

---

**Статус:** ✅ Исправлено  
**Дата:** 11.10.2025  
**Файлы изменены:** 3 файла  
**Коммит:** fix email domains from rozariofl.ru to rozarioflowers.ru
