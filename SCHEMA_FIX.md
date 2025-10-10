# Исправление Schema.org разметки в категориях

## Проблема

Из-за ошибок HAML парсера при обработке сложных Ruby выражений с `@` символами, в некоторых файлах категорий была удалена CollectionPage Schema.org разметка.

## Выполненные исправления

### 1. Исправлен файл `app/views/category/itemsfilters.haml`

**Проблема**: Полностью отсутствовала Schema.org разметка (0% покрытия)

**Решение**: Добавлена полная CollectionPage разметка через `:ruby` блок:
- CollectionPage с полным набором метаданных
- BreadcrumbList внутри CollectionPage
- Поддержка родительских категорий
- Канонические URL и даты

### 2. Обновлён файл `app/views/category/withinfo.haml`

**Проблема**: Содержал только устаревшую BreadcrumbList разметку (частичное покрытие)

**Решение**: 
- Удалена старая BreadcrumbList разметка
- Добавлена новая CollectionPage разметка через `:ruby` блок
- Полностью переписан для соответствия современным стандартам

### 3. Сравнение с `perekrestok.haml`

**Статус**: `perekrestok.haml` - оставлен без изменений (уже имел 100% покрытие)
- Использует `:ruby` блок для CollectionPage схемы
- Получает данные через `collection_page_schema()` helper
- Работает стабильно без ошибок

## Технические подробности

### Применённое решение:

1. **Использование `:ruby` блока**:
   - Позволяет выполнять сложные Ruby выражения
   - Избегает ошибок HAML парсера с `@` символами
   - Обеспечивает стабильность и надёжность

2. **Общая структура разметки**:
   ```ruby
   collection_options = {
     name: category_title,
     description: (@category.announce || category_title),
     about: "Каталог товаров...",
     url: canonical_url,
     breadcrumbs: breadcrumbs,
     items: (defined?(@items) ? @items : []),
     date_published: '...', 
     date_modified: '...'
   }
   ```

3. **Обработка URL и breadcrumbs**:
   - Поддержка родительских категорий (`parent_id != 32`)
   - Правильное формирование slug с UTF-8
   - Канонические URL в соответствии с структурой сайта

## Результат

### До исправления:
- `itemsfilters.haml` - **0% Schema.org** (разметка полностью удалена)
- `withinfo.haml` - **частичная старая разметка** (только BreadcrumbList, без CollectionPage)
- `perekrestok.haml` - **100% новая разметка** (работало через `:ruby` блок)

### После исправления:
- `itemsfilters.haml` - **100% CollectionPage** ✅
- `withinfo.haml` - **100% CollectionPage** ✅
- `perekrestok.haml` - **100% CollectionPage** (без изменений) ✅

## Проверка

- ✅ Синтаксис всех Ruby файлов корректен
- ✅ Контроллеры и модели загружаются без ошибок
- ✅ Schema helper работает корректно
- ✅ Никакого влияния на существующую функциональность

## Следующие шаги

1. Протестировать страницы категорий на production
2. Проверить Schema.org разметку через Google Rich Results Test
3. Мониторить SEO метрики и индексацию
