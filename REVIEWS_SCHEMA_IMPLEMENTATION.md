# Schema.org Reviews Markup Implementation

## Обзор

Внедрена Schema.org разметка для отзывов клиентов в соответствии со стандартами микроразметки Google.

## Реализованные функции

### 1. Helper методы в `app/helpers/schema_helper.rb`

- **`generate_reviews_schema(comments = nil)`** - генерирует полную разметку отзывов для основных страниц
- **`generate_sidebar_reviews_schema(comments = nil)`** - генерирует упрощенную разметку для сайдбара (ограничена 3 отзывами)

### 2. Динамические данные

Вся разметка использует динамические данные из базы данных:

- **Организация**: название "Розарио.Цветы"
- **URL**: автоматически формируется с учетом поддомена города
  - Для обычных городов: `https://city.rozarioflowers.ru`
  - Для Мурманска: `https://rozarioflowers.ru` (без поддомена)
- **Отзывы**: берутся из модели `Comment`
- **Рейтинги**: автоматически рассчитываются средние значения

### 3. Структура Schema.org разметки

```json
{
  "@context": "http://schema.org",
  "@type": "Organization",
  "name": "Розарио.Цветы",
  "url": "https://[subdomain.]rozarioflowers.ru",
  "aggregateRating": {
    "@type": "AggregateRating",
    "itemReviewed": {
      "@type": "Organization", 
      "name": "Розарио.Цветы"
    },
    "ratingValue": "4.3",
    "reviewCount": "10"
  },
  "review": [
    {
      "@type": "Review",
      "itemReviewed": {
        "@type": "Organization",
        "name": "Розарио.Цветы"
      },
      "author": "Имя автора",
      "datePublished": "2025-09-20",
      "description": "Текст отзыва", 
      "reviewRating": {
        "@type": "Rating",
        "bestRating": "5",
        "ratingValue": "5",
        "worstRating": "1"
      }
    }
  ]
}
```

## Места внедрения

### 1. Страница отзывов (`app/views/comment/index.haml`)

```haml
-# Schema.org Reviews markup for SEO
= generate_reviews_schema(@comments)
```

Внедрена полная разметка всех отзывов на главной странице отзывов `/feedback`.

### 2. Сайдбар (`app/views/layouts/parts/_sidebarrr.haml`)

```haml
-# Schema.org Reviews markup for sidebar  
= generate_sidebar_reviews_schema(@cmts.first(3))
```

Внедрена ограниченная разметка (первые 3 отзыва) в сайдбаре всех страниц.

## Особенности реализации

### Поддержка поддоменов

Используется константа `CURRENT_DOMAIN` из приложения для формирования корректных URL:
- Мурманск (murmansk) → `https://rozarioflowers.ru` 
- Другие города → `https://город.rozarioflowers.ru`

### Обработка дат

Даты отзывов берутся из полей:
1. `comment.date` (если заполнено)
2. `comment.created_at` (fallback)

Формат даты: ISO 8601 (`YYYY-MM-DD`)

### Рейтинги

- **Средний рейтинг**: автоматически рассчитывается как среднее арифметическое всех оценок
- **Диапазон оценок**: от 1 до 5 (стандарт для звездной системы)
- **Количество отзывов**: общее количество комментариев

### Производительность

- Количество отзывов в разметке ограничено 10 (для основной страницы) и 3 (для сайдбара)
- При отсутствии отзывов возвращается пустая строка
- Используется `JSON.pretty_generate` для читаемого вывода

## SEO эффекты

Разметка позволяет:

1. **Отображать рейтинги в поисковой выдаче Google**
2. **Показывать количество отзывов** 
3. **Улучшить CTR** благодаря богатым сниппетам
4. **Повысить доверие пользователей** к сайту

## Валидация

Разметку можно проверить через:
- [Google Rich Results Test](https://search.google.com/test/rich-results)
- [Schema.org Validator](https://validator.schema.org/)

## Совместимость

Разметка полностью совместима с:
- Google Search Console
- Яндекс.Вебмастер
- Другими поисковыми системами, поддерживающими Schema.org
