#!/bin/bash

echo "🔄 Переключение на полную связку веб-клиент + сервер"

# Проверяем что мы в правильной директории
if [[ ! -f "railway-fullstack.toml" ]]; then
    echo "❌ Ошибка: файл railway-fullstack.toml не найден"
    exit 1
fi

# Бэкапим текущую конфигурацию
if [[ -f "railway.toml" ]]; then
    echo "📂 Создаем бэкап текущей конфигурации..."
    cp railway.toml railway-server-only.toml
    echo "✅ Сохранено как railway-server-only.toml"
fi

# Переключаем на fullstack
echo "🔄 Переключение на fullstack конфигурацию..."
cp railway-fullstack.toml railway.toml
echo "✅ Активирована полная связка"

# Добавляем изменения в git
echo "📦 Коммит изменений..."
git add -A
git commit -m "switch: переход на fullstack архитектуру (веб-клиент + сервер)"

# Пуш в production
echo "🚀 Деплой на Railway..."
git push origin production

echo ""
echo "✅ ГОТОВО!"
echo ""
echo "🌐 После деплоя ваш игровой портал будет доступен:"
echo "   https://ваш-railway-домен.railway.app/"
echo ""
echo "🎮 Игроки смогут играть через ВАШ веб-клиент!"
echo ""
echo "⏱️ Деплой займет ~10-15 минут (сборка WebAssembly)"
echo "📊 Мониторинг: railway logs --follow"
