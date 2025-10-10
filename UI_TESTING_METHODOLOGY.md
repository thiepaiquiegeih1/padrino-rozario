# Методология UI тестирования для Ruby/Padrino проектов

## Обзор

Этот документ описывает подход к тестированию UI компонентов в проекте Rozario Flowers, основанный на использовании браузерных инструментов Sketch для визуального тестирования и проверки функциональности.

## Инструменты тестирования

### Доступные browser tools в Sketch:
- `browser_navigate(url)` - навигация по URL
- `browser_eval(expression)` - выполнение JavaScript в браузере
- `browser_take_screenshot()` - создание скриншотов
- `browser_recent_console_logs()` - получение логов консоли
- `browser_clear_console_logs()` - очистка логов

## Подход к тестированию UI компонентов

### 1. Создание изолированного HTML тестового файла

**Принципы:**
- Создаем standalone HTML файл с тестируемым компонентом
- Включаем все необходимые стили и скрипты inline
- Добавляем тестовые данные и демонстрационные элементы
- Обеспечиваем полную независимость от основного приложения

**Пример структуры:**
```html
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Тест компонента</title>
    <style>
        /* Inline CSS с полными стилями компонента */
    </style>
</head>
<body>
    <!-- HTML структура компонента -->
    <script>
        /* Inline JavaScript для функциональности */
    </script>
</body>
</html>
```

### 2. Методология тестирования звездочек рейтинга

#### Этап 1: Проверка базовой структуры
```javascript
// Проверяем наличие всех элементов
const rating = document.querySelector('.rating');
const stars = rating.querySelectorAll('label');
const inputs = rating.querySelectorAll('input[type="radio"]');
console.log('Stars count:', stars.length);
console.log('Inputs count:', inputs.length);
```

#### Этап 2: Тестирование половинных звезд
```javascript
// Клик по половинной звезде (левая сторона)
const halfStar = document.querySelector('label[for="star1half"]');
halfStar.click();
// Проверяем значение
const selectedRating = document.querySelector('input[name="rating"]:checked');
console.log('Selected rating:', selectedRating.value); // Должно быть 0.5
```

#### Этап 3: Тестирование полных звезд
```javascript
// Клик по полной звезде (правая сторона)
const fullStar = document.querySelector('label[for="star2"]');
fullStar.click();
// Проверяем значение
const selectedRating = document.querySelector('input[name="rating"]:checked');
console.log('Selected rating:', selectedRating.value); // Должно быть 2.0
```

#### Этап 4: Тестирование hover эффектов
```javascript
// Эмулируем hover
const fourthStar = document.querySelector('label[for="star4"]');
const hoverEvent = new MouseEvent('mouseover', { bubbles: true });
fourthStar.dispatchEvent(hoverEvent);
// Визуально проверяем подсветку через скриншот
```

### 3. Процедура визуального тестирования

#### Шаг 1: Создание базового скриншота
```bash
browser_navigate("file:///app/test_component.html")
browser_take_screenshot()
```

#### Шаг 2: Тестирование интеракций с скриншотами
```bash
# Для каждого состояния:
browser_eval("/* JavaScript для изменения состояния */")
browser_take_screenshot()
```

#### Шаг 3: Сравнение результатов
- Анализируем серию скриншотов
- Проверяем корректность визуальных изменений
- Убеждаемся в правильности работы анимаций/переходов

### 4. Паттерны тестирования различных UI компонентов

#### Формы и валидация
```javascript
// Тестирование валидации
document.getElementById('email').value = 'invalid-email';
document.querySelector('form').dispatchEvent(new Event('submit'));
// Проверяем сообщения об ошибках
```

#### Модальные окна
```javascript
// Открытие модального окна
document.querySelector('[data-modal="open"]').click();
// Проверяем видимость
const modal = document.querySelector('.modal');
console.log('Modal visible:', getComputedStyle(modal).display !== 'none');
```

#### Выпадающие списки
```javascript
// Открытие dropdown
document.querySelector('.dropdown-trigger').click();
// Проверяем опции
const options = document.querySelectorAll('.dropdown-option');
console.log('Options count:', options.length);
```

### 5. Лучшие практики

#### Структура тестов
1. **Подготовка** - создание тестовых данных
2. **Действие** - выполнение тестируемого действия
3. **Проверка** - валидация результата
4. **Очистка** - сброс состояния для следующего теста

#### Обработка асинхронности
```javascript
// Для анимаций и переходов
setTimeout(() => {
    // Проверка результата после завершения анимации
    const element = document.querySelector('.animated-element');
    console.log('Animation completed:', element.classList.contains('animation-done'));
}, 500);
```

## Примеры применения для разных типов компонентов

### Тестирование системы рейтинга (звездочки)
- ✅ Горизонтальное расположение
- ✅ Половинные значения (0.5, 1.5, 2.5, 3.5, 4.5)
- ✅ Полные значения (1, 2, 3, 4, 5)
- ✅ Hover эффекты
- ✅ Сохранение выбранного значения

### Тестирование корзины товаров
- Добавление/удаление товаров
- Изменение количества
- Расчет итоговой суммы
- Валидация минимального/максимального количества

### Тестирование фильтров каталога
- Множественный выбор категорий
- Ценовой диапазон
- Сброс фильтров
- Обновление результатов

## Полезные снипеты для отладки

### Логирование состояния компонента
```javascript
console.log('Component state:', {
    isVisible: getComputedStyle(element).display !== 'none',
    hasClass: element.classList.contains('active'),
    value: element.value || element.textContent,
    position: element.getBoundingClientRect()
});
```

### Проверка ошибок JavaScript
```bash
# Использовать после выполнения тестов
browser_recent_console_logs()
```

### Анализ DOM структуры
```javascript
// Получение структуры элемента
function analyzeElement(selector) {
    const element = document.querySelector(selector);
    return {
        tagName: element.tagName,
        classes: Array.from(element.classList),
        attributes: Array.from(element.attributes).map(attr => `${attr.name}="${attr.value}"`),
        children: element.children.length,
        text: element.textContent.trim()
    };
}
console.log(analyzeElement('.rating'));
```

## Заключение

Данный подход позволяет:
- Быстро создавать изолированные тесты UI компонентов
- Визуально проверять корректность работы интерфейса
- Автоматизировать рутинные проверки
- Документировать поведение компонентов
- Легко воспроизводить проблемы на разных машинах

Использование browser tools в Sketch делает UI тестирование доступным и эффективным без необходимости настройки сложных фреймворков тестирования.