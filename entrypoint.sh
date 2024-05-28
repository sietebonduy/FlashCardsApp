#!/bin/bash
set -e

# Подготовка базы данных (выполнение миграций)
echo "Running database migrations..."
bundle exec rails db:prepare

# Запуск основного процесса (например, сервера)
exec "$@"
