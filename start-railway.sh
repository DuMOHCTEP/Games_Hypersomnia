#!/bin/bash

echo "=== Запуск сервера Hypersomnia на Railway ===" 

# Проверяем переменные окружения Railway
echo "PORT (Railway): ${PORT:-не установлен}"
echo "RAILWAY_ENVIRONMENT: ${RAILWAY_ENVIRONMENT:-не установлен}"
echo "RAILWAY_PROJECT_NAME: ${RAILWAY_PROJECT_NAME:-не установлен}"

# Railway использует PORT для HTTP, но нам нужны UDP порты
export NATIVE_PORT=8412
export WEB_PORT=9000

# Запускаем HTTP health check сервер для Railway
echo "Запускаем HTTP health check сервер на порту $PORT"
python3 ./health_server.py &
sleep 2  # Даем время серверу запуститься

echo "Используемые порты:"
echo "  HTTP Health Check: $PORT"
echo "  Нативные клиенты (UDP): $NATIVE_PORT"  
echo "  Веб клиенты (WebRTC UDP): $WEB_PORT"

# Создание динамической конфигурации для Railway
cat > /home/hypersomniac/.config/Hypersomnia/user/conf.d/railway-runtime.json << EOF
{
  "server_start": {
    "port": $NATIVE_PORT,
    "slots": ${MAX_PLAYERS:-20}
  },
  "server": {
    "server_name": "${SERVER_NAME:-[Railway] Hypersomnia Server}",
    "webrtc_udp_mux": true,
    "webrtc_port_range_begin": $WEB_PORT,
    "sync_all_external_arenas_on_startup": ${SYNC_ARENAS:-true},
    "daily_autoupdate": ${DAILY_AUTOUPDATE:-false},
    "arena": "${DEFAULT_ARENA:-de_cyberaqua}",
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
    "master_rcon_password": "${RCON_PASSWORD:-railway_admin}",
    "discord_webhook_url": "${DISCORD_WEBHOOK_URL:-}"
  },
  "num_casual_servers": ${CASUAL_SERVERS:-1},
  "num_ranked_servers": ${RANKED_SERVERS:-0}
}
EOF

echo "Конфигурация создана:"
cat /home/hypersomniac/.config/Hypersomnia/user/conf.d/railway-runtime.json

# Запуск сервера с правильными флагами для Railway
echo "Запускаем сервер Hypersomnia..."
exec ./Hypersomnia-Headless.AppImage \
    --appimage-extract-and-run \
    --as-service \
    --appdata-dir "${APPDATA_DIR}" \
    ${EXTRA_FLAGS:-}
