# Исправление ошибки кодировки

## Ошибка

```
Encoding::UndefinedConversionError at /
"\xD0" from ASCII-8BIT to UTF-8
```

**Причина**: Наличие BOM (Byte Order Mark) `EF BB BF` в начале файла `app/views/layouts/parts/_sidebarrr.haml`

## Выполненные исправления

### 1. Удален BOM из `_sidebarrr.haml`

**До**: 
```
EF BB BF 2E 63 6F 6C 2D 6D 64 2D 34  (.col-md-4)
```

**После**:
```
2E 63 6F 6C 2D 6D 64 2D 34  (.col-md-4)
```

**Команда**: `sed -i '1s/^\xEF\xBB\xBF//' app/views/layouts/parts/_sidebarrr.haml`

### 2. Добавлена корректная encoding директива

В начало обоих файлов добавлено:
```haml
- # encoding: utf-8
```

### 3. Добавлено принудительное кодирование UTF-8 для кириллицы

Использован метод `.force_encoding('UTF-8')` как в остальных частях проекта:

```haml
%meta{:content => "Улыбки получателей #{fname}".force_encoding('UTF-8'), :itemprop => 'name'}/
%meta{:content => "Фотография...".force_encoding('UTF-8'), :itemprop => 'description'}/
%img{alt: (@post.alt ? @post.alt.force_encoding('UTF-8') : '')}
```

Это решение:
- ✅ Сохраняет кириллицу в читаемом виде
- ✅ Соответствует существующим практикам в проекте
- ✅ Обеспечивает корректное отображение

## Проверка кодировки

### До исправления:
```bash
$ file app/views/layouts/parts/_sidebarrr.haml
app/views/layouts/parts/_sidebarrr.haml: UTF-8 Unicode (with BOM) text
```

### После исправления:
```bash
$ file app/views/layouts/parts/_sidebarrr.haml  
app/views/layouts/parts/_sidebarrr.haml: UTF-8 Unicode text

$ file app/views/layouts/parts/sidebarrr/_smile.haml
app/views/layouts/parts/sidebarrr/_smile.haml: UTF-8 Unicode text
```

## Причина ошибки

BOM (Byte Order Mark) в UTF-8 файлах может вызывать проблемы с кодировкой в Ruby приложениях, особенно при:

1. **Обработке HAML шаблонов**
2. **Компиляции Ruby кода**
3. **Обработке кириллических символов**

## Рекомендации

1. **Использовать UTF-8 без BOM** для всех HAML/ERB файлов
2. **Добавлять encoding директиву** в начало файлов с кириллицей
3. **Проверять кодировку** через `file` команду
4. **Настраивать редакторы** на сохранение без BOM

## Результат

- ✅ Ошибка `Encoding::UndefinedConversionError` устранена
- ✅ Сайдбар с улыбками теперь работает корректно
- ✅ Квадратные области с размытым фоном работают
- ✅ Никакого влияния на остальную функциональность
