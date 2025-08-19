#!/bin/bash

echo "=== Запуск сервера Hypersomnia на Railway ===" 

# Проверяем и выводим все переменные окружения Railway
echo "=== ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ ==="
echo "PORT (Railway): ${PORT:-НЕ УСТАНОВЛЕН}"
echo "RAILWAY_ENVIRONMENT: ${RAILWAY_ENVIRONMENT:-НЕ УСТАНОВЛЕН}"
echo "RAILWAY_PROJECT_NAME: ${RAILWAY_PROJECT_NAME:-НЕ УСТАНОВЛЕН}"
echo ""
echo "=== ИГРОВЫЕ ПЕРЕМЕННЫЕ ==="
echo "SERVER_NAME: '${SERVER_NAME:-НЕ УСТАНОВЛЕН}'"
echo "RCON_PASSWORD: '${RCON_PASSWORD:-НЕ УСТАНОВЛЕН}'"
echo "MAX_PLAYERS: '${MAX_PLAYERS:-НЕ УСТАНОВЛЕН}'"
echo "DEFAULT_ARENA: '${DEFAULT_ARENA:-НЕ УСТАНОВЛЕН}'"
echo "SYNC_ARENAS: '${SYNC_ARENAS:-НЕ УСТАНОВЛЕН}'"
echo "DISCORD_WEBHOOK_URL: '${DISCORD_WEBHOOK_URL:-НЕ УСТАНОВЛЕН}'"
echo "=================================="

# Установка значений по умолчанию если переменные не заданы
export SERVER_NAME="${SERVER_NAME:-[Railway] Hypersomnia Server}"
export RCON_PASSWORD="${RCON_PASSWORD:-railway_default_password}"
export MAX_PLAYERS="${MAX_PLAYERS:-20}"
export DEFAULT_ARENA="${DEFAULT_ARENA:-de_cyberaqua}"
export SYNC_ARENAS="${SYNC_ARENAS:-true}"
export CASUAL_SERVERS="${CASUAL_SERVERS:-1}"
export RANKED_SERVERS="${RANKED_SERVERS:-0}"
export DAILY_AUTOUPDATE="${DAILY_AUTOUPDATE:-false}"

# Railway использует PORT для HTTP, но нам нужны UDP порты
export NATIVE_PORT=8412
export WEB_PORT=9000

echo "=== ФИНАЛЬНЫЕ ЗНАЧЕНИЯ ==="
echo "SERVER_NAME: '$SERVER_NAME'"
echo "RCON_PASSWORD: '$RCON_PASSWORD'"
echo "MAX_PLAYERS: '$MAX_PLAYERS'"
echo "=================================="

# Запускаем HTTP health check сервер для Railway в фоне
echo "Запуск HTTP health check сервера на порту $PORT..."
python3 ./health_server.py &
HEALTH_PID=$!
echo "Health check server запущен с PID: $HEALTH_PID"
sleep 2

echo "=== ИСПОЛЬЗУЕМЫЕ ПОРТЫ ==="
echo "  HTTP Health Check: $PORT"
echo "  Нативные клиенты (UDP): $NATIVE_PORT"  
echo "  Веб клиенты (WebRTC UDP): $WEB_PORT"

# Создание конфигурации с правильной подстановкой переменных
echo "Создание конфигурационного файла..."
cat > /home/hypersomniac/.config/Hypersomnia/user/conf.d/railway-runtime.json << EOF
{
  "server_start": {
    "port": $NATIVE_PORT,
    "slots": $MAX_PLAYERS
  },
  "server": {
    "server_name": "$SERVER_NAME",
    "webrtc_udp_mux": true,
    "webrtc_port_range_begin": $WEB_PORT,
    "sync_all_external_arenas_on_startup": $SYNC_ARENAS,
    "daily_autoupdate": $DAILY_AUTOUPDATE,
    "arena": "$DEFAULT_ARENA",
    "cycle": "LIST",
    "cycle_list": [
      "de_cyberaqua",
      "de_silo", 
      "de_metro",
      "de_duel_practice",
      "de_facing_worlds"
    ]
  },
  "server_private": {
    "master_rcon_password": "$RCON_PASSWORD",
    "discord_webhook_url": "${DISCORD_WEBHOOK_URL:-}"
  },
  "num_casual_servers": $CASUAL_SERVERS,
  "num_ranked_servers": $RANKED_SERVERS
}
EOF

echo "=== СОЗДАННАЯ КОНФИГУРАЦИЯ ==="
cat /home/hypersomniac/.config/Hypersomnia/user/conf.d/railway-runtime.json
echo "=================================="

# Проверяем что health check сервер работает
echo "Проверка health check сервера..."
sleep 1
if kill -0 $HEALTH_PID 2>/dev/null; then
    echo "✅ Health check сервер работает (PID: $HEALTH_PID)"
else
    echo "❌ Ошибка: Health check сервер не запустился!"
fi

# Запуск основного сервера Hypersomnia
echo "=== ЗАПУСК HYPERSOMNIA СЕРВЕРА ==="
echo "Команда: ./Hypersomnia-Headless.AppImage --appimage-extract-and-run --as-service --appdata-dir $APPDATA_DIR"

exec ./Hypersomnia-Headless.AppImage \
    --appimage-extract-and-run \
    --as-service \
    --appdata-dir "${APPDATA_DIR}" \
    ${EXTRA_FLAGS:-}
