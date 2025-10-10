# VideoObject Schema.org Implementation

## Обзор

Внедрена Schema.org разметка VideoObject для видео, встроенных в новости и статьи на сайте rozarioflowers.ru. Система автоматически обнаруживает HTML5 видео-теги в содержимом и генерирует соответствующую микроразметку.

## Реализованные функции

### 1. Helper методы в `app/helpers/schema_helper.rb`

- **`generate_video_schemas_from_content(html_content, page_title = nil, page_date = nil)`** - основной метод для извлечения и разметки видео
- **`extract_videos_from_html(html_content)`** - парсит HTML для поиска видео-тегов
- **`generate_single_video_schema(video_data, page_title, page_date, video_index = 1)`** - создает индивидуальную схему для одного видео

### 2. Автоматическое обнаружение видео

Система автоматически находит в HTML-контенте:

```html
<video controls poster="/images/poster.jpg">
  <source src="/videos/sample.mp4" type="video/mp4">
  <source src="/videos/sample.webm" type="video/webm">
</video>
```

**Поддерживаемые форматы видео:**
- MP4 (video/mp4)
- WebM (video/webm)  
- OGG (video/ogg)
- AVI (video/avi)
- MOV (video/mov)

### 3. Динамическое формирование схемы

**Для одного видео:**
- Название = название страницы
- Описание = "Видео к статье: {название страницы}"

**Для нескольких видео:**
- Название = "{название страницы} - Видео {номер}"
- Описание = "Видео к статье: {название страницы}"

### 4. Обработка URL

- **Относительные URL** автоматически конвертируются в абсолютные
- **Поддержка поддоменов** с особой обработкой 'murmansk'
- **Poster изображения** извлекаются из атрибута poster

**Примеры URL преобразования:**
```
/videos/test.mp4 → https://spb.rozarioflowers.ru/videos/test.mp4
/images/poster.jpg → https://moscow.rozarioflowers.ru/images/poster.jpg

# Для Мурманска (особый случай):
/videos/test.mp4 → https://rozarioflowers.ru/videos/test.mp4
```

## Интеграция в шаблоны

### 1. Новости (`app/views/news/show.haml`)

```haml
-# VideoObject Schema.org markup for videos in content
= generate_video_schemas_from_content(@news.body, @news.title, @news.created_at)
```

### 2. Статьи (`app/views/article/show.haml`)

```haml
-# VideoObject Schema.org markup for videos in content
= generate_video_schemas_from_content(@article.body, @article.title, @article.created_at)
```

## Пример генерируемой схемы

```json
{
  "@context": "https://schema.org",
  "@type": "VideoObject",
  "name": "Доставка цветов в Санкт-Петербурге",
  "description": "Видео к статье: Доставка цветов в Санкт-Петербурге",
  "contentUrl": "https://spb.rozarioflowers.ru/videos/delivery.mp4",
  "thumbnailUrl": "https://spb.rozarioflowers.ru/images/delivery-poster.jpg",
  "uploadDate": "2024-01-15",
  "publisher": {
    "@type": "Organization",
    "name": "Rozario Flowers"
  }
}
```

## Архитектурные особенности

### 1. Мультидоменная поддержка

```ruby
current_domain = CURRENT_DOMAIN
base_url = @subdomain.url != 'murmansk' ? 
           "https://#{@subdomain.url}.#{current_domain}" : 
           "https://#{current_domain}"
```

### 2. Обработка ошибок

- Graceful degradation - при ошибке возвращается пустая строка
- Не ломает отображение страницы
- Логирует ошибки для мониторинга

### 3. Парсинг HTML

**Поддерживаемые форматы видео-тегов:**

```html
<!-- С source элементами -->
<video controls>
  <source src="/video.mp4" type="video/mp4">
</video>

<!-- С прямым src атрибутом -->
<video src="/video.mp4" controls></video>

<!-- С poster изображением -->
<video controls poster="/poster.jpg">
  <source src="/video.mp4" type="video/mp4">
</video>
```

## Производительность

- **Кэширование**: результат генерируется при каждом запросе (можно оптимизировать)
- **Ленивая загрузка**: schema генерируется только при наличии видео в контенте
- **Лимиты**: нет ограничений на количество видео (можно добавить при необходимости)

## SEO преимущества

1. **Rich Snippets** - видео могут отображаться в результатах поиска
2. **Video Search** - индексация в Google Video Search
3. **Structured Data** - улучшенное понимание контента поисковыми системами
4. **Click-through Rate** - повышение CTR благодаря превью видео

## Тестирование

Для проверки корректности схемы используйте:

- **Google Rich Results Test**: https://search.google.com/test/rich-results
- **Schema.org Validator**: https://validator.schema.org/
- **JSON-LD Playground**: https://json-ld.org/playground/

## Возможные улучшения

1. **Извлечение длительности видео** из метаданных файла
2. **Кэширование генерируемых схем** для повышения производительности
3. **Автоматическое создание превью** для видео без poster
4. **Поддержка внешних видео** (YouTube, Vimeo)
5. **Batch обработка** для страниц с множеством видео

## Совместимость

- **Ruby**: 2.7+
- **Padrino**: 0.15+
- **HAML**: 5.0+
- **Browsers**: все современные браузеры с поддержкой HTML5 video

## Мониторинг

Рекомендуется отслеживать:

- Количество страниц с VideoObject разметкой
- Ошибки парсинга HTML в логах
- Индексацию видео в Google Search Console
- Показы Rich Snippets в поиске

---

*Документация актуальна на: 20.09.2025*
*Версия реализации: 1.0*