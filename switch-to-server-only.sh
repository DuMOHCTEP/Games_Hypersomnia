#!/bin/bash

echo "🔄 Переключение на режим только сервера"

# Проверяем что есть бэкап server-only конфигурации
if [[ ! -f "railway-server-only.toml" ]]; then
    echo "❌ Ошибка: файл railway-server-only.toml не найден"
    echo "Создаем базовую server-only конфигурацию..."
    
    cat > railway-server-only.toml << EOF
[build]
dockerfile = "Dockerfile.railway"

[deploy]
startCommand = "./start-railway.sh"
restartPolicyType = "always"

[experimental]
incrementalBuilds = false

[environments.production.variables]
SERVER_NAME = "[Railway] Hypersomnia Server"
MAX_PLAYERS = "20"
RCON_PASSWORD = "secure_railway_password_2024"
DEFAULT_ARENA = "de_cyberaqua"
SYNC_ARENAS = "true"
DAILY_AUTOUPDATE = "false"
CASUAL_SERVERS = "1"
RANKED_SERVERS = "0"
WEBRTC_PORT = "9000"
EOF
fi

# Бэкапим fullstack конфигурацию
if [[ -f "railway.toml" ]]; then
    echo "📂 Создаем бэкап fullstack конфигурации..."
    cp railway.toml railway-fullstack-backup.toml
fi

# Переключаем на server-only
echo "🔄 Переключение на server-only конфигурацию..."
cp railway-server-only.toml railway.toml
echo "✅ Активирован режим только сервера"

# Добавляем изменения в git
echo "📦 Коммит изменений..."
git add -A
git commit -m "switch: возврат к server-only режиму (только сервер)"

# Пуш в production
echo "🚀 Деплой на Railway..."
git push origin production

echo ""
echo "✅ ГОТОВО!"
echo ""
echo "🔙 Теперь используется режим только сервера:"
echo "   • Веб-клиенты: hypersomnia.io → ваш сервер"  
echo "   • Нативные клиенты: ваш-railway-домен:8412"
echo ""
echo "⏱️ Деплой займет ~3-5 минут"
echo "📊 Мониторинг: railway logs --follow"
