#!/usr/bin/bash

# https://www.shellcheck.net/

# rm -rf /srv/development_rozarioflowers.ru/{*,.*} && cp -r /srv/development_rozarioflowers.ru/. /srv/development_rozarioflowers.ru/
# sudo nginx -t && sudo nginx -s reload && sudo systemctl status nginx

set -e

DIR=${1:-.} # Путь к папке, которую нужно проверить (по умолчанию текущая папка)

echo "Проверка файлов в папке: $DIR"

# Поиск и вывод файлов в кодировках несовместимых с UTF-8
#
# find "$DIR" -type f -exec file -i {} \; | grep -Ev  'charset=(us-ascii|iso-8859-1|iso-8859-15|windows-1252|utf-8)' | while read -r line; do # Поиск файлов в кодировках несовместимых с UTF-8
#   echo "Несовместим с UTF-8: $line" # Вывод файлов с некорректной кодировкой
# done

# Поиск и конвертирование файлов в кодировках несовместимых с UTF-8
#
convert_to_utf8() { # Функция для конвертации файла в UTF-8. Файлы будут конвертированы в UTF-8 без BOM (Byte Order Mark), т.к. iconv по умолчанию не добавляет BOM.
  local file="$1"
  echo "Конвертация файла: $file"
  encoding=$(file -i "$file" | grep -oP 'charset=\K\S+') # Определение кодировки файла
  if [[ "$encoding" == "us-ascii"    || "$encoding" == "ascii"  || \
        "$encoding" == "iso-8859-1"  || "$encoding" == "latin1" || \
        "$encoding" == "iso-8859-15" || "$encoding" == "latin9" || \
        "$encoding" == "cp1252"      || "$encoding" == "windows-1252" ]]; then
    echo "Файл совместим с UTF-8: $file (кодировка $encoding)" # find . -type f -exec file -i {} \; | grep -E 'charset=(us-ascii|iso-8859-1|iso-8859-15|windows-1252|utf-8)'
  else
    cp "$file" "$file.bak" # Создание резервной копии файла перед конвертацией
    iconv -f "$encoding" -t utf-8 "$file" -o "$file.converted" && mv "$file.converted" "$file" # Конвертация в UTF-8
    echo "Файл успешно конвертирован: $file"
  fi
}
find "$DIR" -type f -exec file -i {} \; | grep -v 'charset=utf-8' | while read -r line; do # Поиск файлов, не являющихся UTF-8, и их конвертация
  file=$(echo "$line" | cut -d: -f1) # Извлечение имени файла из строки
  convert_to_utf8 "$file" # Преобразование файла в UTF-8
done
find "$DIR" -type f -name "*.bak" -delete # Чистка бэкапов
#
echo "Все файлы обработаны."

# Удалить все строки подобные `# encoding: utf-8` из файлов *.rb, кроме самой `# encoding: utf-8` 
#
# shopt -s nocasematch # Включить режим, в котором сравнение строк будет игнорировать регистр
find "$DIR" -type f -name "*.rb" | while read -r file; do # Рекурсивно найти все файлы .rb в директории и обработать их
  sed -i '1s/^\xEF\xBB\xBF//' "$file" # Убираем BOM из файла (если присутствует)
  frst_line=$(head -n 1 "$file" |             tr -d ' ' | tr '[:upper:]' '[:lower:]') # Получить первую строку файла без пробелов в нижнем регистре
  scnd_line=$(head -n 2 "$file" | tail -n 1 | tr -d ' ' | tr '[:upper:]' '[:lower:]') # Получить вторую строку файла без пробелов в нижнем регистре
  if [[ "$frst_line" =~ ^\#encoding\:utf\-8 || "$frst_line" =~ ^\#coding\:utf\-8 ]]; then # Если первая строка соответствует одному из шаблонов
    if [[ "$scnd_line" =~ ^\#encoding\:utf\-8 || "$scnd_line" =~ ^\#coding\:utf\-8 ]]; then # Если вторая строка соответствует одному из шаблонов
      sed -i '1,2d' "$file" # Удаляем первую и вторую строку и сохраняем изменения в файл
      echo "Удалена первая и вторая строка из файла: $file"
    else
      # if grep -qi "# encoding: utf-8" "$file"; then
      if [[ "$(head -n 1 "$file")" =~ ^\#\ encoding\:\ utf\-8 ]]; then
        echo "Файл $file уже содержит строку \`# encoding: utf-8\`"
        continue
      else
        sed -i '1d' "$file" # Удаляем первую строку и сохраняем изменения в файл
        echo "Удалена первая строка из файла: $file"
      fi
    fi
  fi
  echo "Добавляю строку \`# encoding: utf-8\` в файл: $file"
  (echo "# encoding: utf-8"; cat "$file") > "$file.tmp" # Создать временный файл с новой первой строкой
  mv "$file.tmp" "$file" # Перемещаем временный файл обратно в исходный
done
# shopt -u casematch # Включить режим, в котором сравнение строк НЕ будет игнорировать регистр
#
echo "Все файлы *.rb обработаны."

# Проверка и исправление наличия строки `- # coding: utf-8` в начале всех .haml файлов, за исключением файлов, включаемых в другие файлы (_*.haml)
#
find "$DIR" -type f -name "*.haml" ! -name "_*.haml" | while read -r file; do # Найти все файлы .rb
  sed -i '1s/^\xEF\xBB\xBF//' "$file" # Убираем BOM из файла (если присутствует)
  frst_line=$(head -n 1 "$file" |             tr -d ' ' | tr '[:upper:]' '[:lower:]') # Получить первую строку файла без пробелов в нижнем регистре
  scnd_line=$(head -n 2 "$file" | tail -n 1 | tr -d ' ' | tr '[:upper:]' '[:lower:]') # Получить вторую строку файла без пробелов в нижнем регистре
  if [[ "$frst_line" =~ ^\-\#encoding\:utf\-8 || "$frst_line" =~ ^\-\#coding\:utf\-8 ]]; then # Если первая строка соответствует одному из шаблонов
    if [[ "$scnd_line" =~ ^\-\#encoding\:utf\-8 || "$scnd_line" =~ ^\-\#coding\:utf\-8 ]]; then # Если вторая строка соответствует одному из шаблонов
      sed -i '1,2d' "$file" # Удаляем первую и вторую строку и сохраняем изменения в файл
      echo "Удалена первая и вторая строка из файла: $file"
    else
      # if grep -qi "- # encoding: utf-8" "$file"; then
      if [[ "$(head -n 1 "$file")" =~ ^\-\ \#\ encoding\:\ utf\-8 ]]; then
        echo "Файл $file уже содержит строку \`- # encoding: utf-8\`"
        continue
      else
        sed -i '1d' "$file" # Удаляем первую строку и сохраняем изменения в файл
        echo "Удалена первая строка из файла: $file"
      fi
    fi
    echo "Добавляю строку \`- # encoding: utf-8\` в файл: $file"
    (echo "- # encoding: utf-8"; cat "$file") > "$file.tmp" # Создаем временный файл с новой первой строкой
    mv "$file.tmp" "$file" # Перемещаем временный файл обратно в исходный
  fi
done
#
echo "Все файлы *.haml (кроме _*.haml) обработаны."

# Очистка от мусора
#
find . -type f -name "*.swp" -exec rm -v {} \;

echo "Обработка завершена."
