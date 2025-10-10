#!/usr/bin/bash

set -e

current_date=$(date +"%Y-%m-%dT%H:%M:%S")
source_directory="/srv/development_rozarioflowers.ru"
target_directory="/srv/rozarioflowers.ru"

cd "$source_directory"

if [ "$(pwd)" == "$source_directory" ]; then
  git add .
  git commit -m "$current_date"
  git push
  cd "$target_directory"
  git pull
  sudo nginx -t && sudo nginx -s reload && sudo systemctl status nginx
else
  echo "Вы не в директории $source_directory"
  exit 1
fi
