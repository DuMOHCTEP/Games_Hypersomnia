#!/bin/bash

echo "🚀 БЫСТРЫЙ ДЕПЛОЙ НА RAILWAY"
echo ""

# Добавляем файлы
git add -A

# Коммитим
git commit -m "deploy: обновление $(date '+%H:%M')" || true

# Пушим в production
git push origin production

echo ""
echo "✅ ГОТОВО! Railway перезапустится автоматически"
echo "🌐 Открыть: railway open"
echo "📋 Логи: railway logs --follow"
