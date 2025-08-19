#!/bin/bash

# Простая проверка здоровья сервера для Railway
# Проверяем что процесс Hypersomnia запущен

PROCESS_NAME="Hypersomnia-Headless.AppImage"

# Проверка что процесс запущен
if pgrep -f "$PROCESS_NAME" > /dev/null; then
    echo "OK: Сервер Hypersomnia запущен"
    exit 0
else
    echo "ERROR: Сервер Hypersomnia не запущен"
    exit 1
fi
