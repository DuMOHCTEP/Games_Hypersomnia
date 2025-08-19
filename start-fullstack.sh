#!/bin/bash

echo "🚀🌐 === ЗАПУСК ПОЛНОЙ СВЯЗКИ HYPERSOMNIA НА RAILWAY ==="

# Проверяем переменные окружения
echo "=== ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ ==="
echo "PORT (Railway HTTP): ${PORT:-НЕ УСТАНОВЛЕН}"
echo "SERVER_NAME: '${SERVER_NAME:-НЕ УСТАНОВЛЕН}'"
echo "RCON_PASSWORD: '${RCON_PASSWORD:-НЕ УСТАНОВЛЕН}'"
echo "MAX_PLAYERS: '${MAX_PLAYERS:-НЕ УСТАНОВЛЕН}'"
echo "=================================="

# Установка значений по умолчанию
export SERVER_NAME="${SERVER_NAME:-[Portal] Hypersomnia Game Server}"
export RCON_PASSWORD="${RCON_PASSWORD:-portal_admin_password}"
export MAX_PLAYERS="${MAX_PLAYERS:-20}"
export DEFAULT_ARENA="${DEFAULT_ARENA:-de_cyberaqua}"
export SYNC_ARENAS="${SYNC_ARENAS:-true}"
export CASUAL_SERVERS="${CASUAL_SERVERS:-1}"
export RANKED_SERVERS="${RANKED_SERVERS:-0}"
export DAILY_AUTOUPDATE="${DAILY_AUTOUPDATE:-false}"

echo "=== ФИНАЛЬНЫЕ ЗНАЧЕНИЯ ==="
echo "SERVER_NAME: '$SERVER_NAME'"
echo "RCON_PASSWORD: '$RCON_PASSWORD'"
echo "MAX_PLAYERS: '$MAX_PLAYERS'"
echo "=================================="

# Порты
export NATIVE_PORT=8412
export WEB_PORT=9000
export NGINX_PORT=80

echo "=== АРХИТЕКТУРА СВЯЗКИ ==="
echo "  Railway HTTP (health): $PORT"
echo "  Nginx веб-клиент: $NGINX_PORT"
echo "  Игровой сервер (UDP): $NATIVE_PORT"  
echo "  WebRTC (UDP): $WEB_PORT"
echo "=================================="

# 1. Запуск HTTP health check сервера для Railway
echo "🔧 Запуск HTTP health check сервера..."
python3 /home/hypersomniac/health_server.py &
HEALTH_PID=$!
echo "Health check server запущен с PID: $HEALTH_PID на порту $PORT"

# 2. Запуск Nginx для веб-клиента  
echo "🌐 Запуск Nginx веб-сервера..."
nginx -t && nginx -g "daemon off;" &
NGINX_PID=$!
echo "Nginx запущен с PID: $NGINX_PID на порту $NGINX_PORT"

# Проверяем что nginx запустился
sleep 2
if ! kill -0 $NGINX_PID 2>/dev/null; then
    echo "❌ ОШИБКА: Nginx не запустился!"
    nginx -t
    exit 1
fi

# 3. Создание конфигурации игрового сервера
echo "📝 Создание конфигурации игрового сервера..."
cat > /home/hypersomniac/.config/Hypersomnia/user/conf.d/portal-runtime.json << EOF
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
cat /home/hypersomniac/.config/Hypersomnia/user/conf.d/portal-runtime.json
echo "=================================="

# 4. Переключение на пользователя hypersomniac для игрового сервера  
echo "👤 Переключение на пользователя hypersomniac..."
chown -R hypersomniac:hypersomniac /home/hypersomniac/.config/Hypersomnia

# 5. Запуск игрового сервера Hypersomnia
echo "🎮 Запуск игрового сервера Hypersomnia..."
echo "Команда: su hypersomniac -c './Hypersomnia-Headless.AppImage --appimage-extract-and-run --as-service --appdata-dir $APPDATA_DIR'"

# Запускаем игровой сервер в фоне как hypersomniac
su hypersomniac -c "cd /home/hypersomniac && ./Hypersomnia-Headless.AppImage --appimage-extract-and-run --as-service --appdata-dir $APPDATA_DIR" &
GAME_PID=$!
echo "Игровой сервер запущен с PID: $GAME_PID"

# 6. Мониторинг всех процессов
echo "🔄 Мониторинг процессов..."

# Функция для проверки процессов
check_processes() {
    local failed=0
    
    if ! kill -0 $HEALTH_PID 2>/dev/null; then
        echo "❌ Health check сервер остановлен!"
        failed=1
    fi
    
    if ! kill -0 $NGINX_PID 2>/dev/null; then
        echo "❌ Nginx остановлен!"
        failed=1
    fi
    
    if ! kill -0 $GAME_PID 2>/dev/null; then
        echo "❌ Игровой сервер остановлен!"
        failed=1
    fi
    
    return $failed
}

# Ожидаем несколько секунд для запуска всех сервисов
sleep 5

# Проверяем что все запустилось
if check_processes; then
    echo "✅ Все сервисы запущены успешно!"
    echo ""
    echo "🌐 ВЕБ-КЛИЕНТ: http://localhost:$NGINX_PORT"
    echo "🎮 ИГРОВОЙ СЕРВЕР: localhost:$NATIVE_PORT"  
    echo "📊 HEALTH CHECK: http://localhost:$PORT"
    echo ""
    echo "🚀 ИГРОВОЙ ПОРТАЛ ГОТОВ К РАБОТЕ!"
else
    echo "❌ Некоторые сервисы не запустились"
    exit 1
fi

# Основной цикл мониторинга
while true; do
    sleep 30
    
    if ! check_processes; then
        echo "💀 Критическая ошибка: один или несколько сервисов остановились"
        echo "Завершаем работу..."
        kill $HEALTH_PID $NGINX_PID $GAME_PID 2>/dev/null || true
        exit 1
    fi
    
    # Логируем статус каждые 5 минут  
    if (( $(date +%s) % 300 == 0 )); then
        echo "⏰ $(date): Все сервисы работают нормально"
        echo "  Health Check PID: $HEALTH_PID"  
        echo "  Nginx PID: $NGINX_PID"
        echo "  Game Server PID: $GAME_PID"
    fi
done
