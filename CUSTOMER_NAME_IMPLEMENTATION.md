# Реализация подстановки имени клиента в микроразметку

## Описание

Реализована подстановка реального имени клиента в микроразметку schema.org на страницах смайлов.

### Логика работы:

1. Проверяем наличие связанного заказа
2. Проверяем `order.useraccount_id` (> 0)
3. Получаем `user_account.surname` из таблицы `user_accounts`
4. Если surname не пустое - возвращаем его
5. Иначе возвращаем "Покупатель"

## Изменения

### Модифицированные файлы:

1. **app/models/smile.rb**
   - Добавлена связь `belongs_to :order`
   - Добавлен метод `customer_name`

2. **app/models/order.rb**
   - Добавлена связь `has_many :smiles`

3. **app/views/smiles/show.erb**
   - Обновлена микроразметка: `"name": "<%=@post.customer_name%>"`

### Новые файлы:

1. **db/migrate/089_add_order_id_to_smiles.rb** - миграция для добавления поля `order_id`
2. **test_customer_name.rb** - тесты функциональности
3. **link_smiles_to_orders.rb** - инструкции по связыванию

## Инструкция по развертыванию

### Шаг 1: Обновление базы данных

Выполнить в MySQL:

```sql
ALTER TABLE smiles ADD COLUMN order_id INT;
CREATE INDEX index_smiles_on_order_id ON smiles(order_id);
```

### Шаг 2: Связывание существующих smiles с orders

Используйте скрипт из `link_smiles_to_orders.rb`:

1. Запустить Padrino console: `bundle exec padrino console`
2. Скопировать и выполнить код скрипта

### Шаг 3: Проверка

Открыть любую страницу smile и проверить в исходном коде:

- Микроразметка `<script type="application/ld+json">`
- Поле `"name"` в `"author"` должно содержать реальную фамилию или "Покупатель"

### Шаг 4 (опционально): Тестирование

Запустить тесты:

```bash
ruby test_customer_name.rb
```

## Ограничения и особенности

1. Алгоритм поиска связи smile-order основан на сопоставлении товаров и дат
2. Может не сработать для сложных заказов с многими товарами
3. Для несвязанных smiles отображается "Покупатель"
4. При useraccount_id = 1 (по умолчанию) или 0 отображается "Покупатель"

## Откат изменений

Для отката:

1. Вернуть `"name": "Имя клиента"` в `app/views/smiles/show.erb`
2. Удалить поле: `ALTER TABLE smiles DROP COLUMN order_id;`
