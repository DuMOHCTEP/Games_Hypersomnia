#!/bin/bash
set -e

echo "🚀 Простой деплой на Railway"

# Переходим на production ветку
git checkout production || true

# Добавляем изменения  
git add -A

# Коммитим (игнорируем если нет изменений)
git commit -m "deploy: $(date '+%Y-%m-%d %H:%M')" || echo "Нет новых изменений"

# Пушим
git push origin production

echo "✅ Отправлено! Railway перезапустится через 1-2 минуты"
echo ""
echo "Проверьте переменные в Railway панели:"
echo "  SERVER_NAME='[Railway] Мой Сервер'"
echo "  RCON_PASSWORD='ваш_пароль'"
echo "  MAX_PLAYERS='20'"
