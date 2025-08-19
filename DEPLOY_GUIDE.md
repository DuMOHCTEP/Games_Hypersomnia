# 🚀 Гайд по деплою на Railway

## 📦 Деплой скрипты

### 1. `./quick-deploy.sh` - Быстрый деплой
Автоматически коммитит все изменения и пушит в production:
```bash
./quick-deploy.sh
```

### 2. `./deploy.sh` - Полный деплой
Подробный деплой с проверками и настройкой Railway CLI:
```bash
# С автоматическим commit message
./deploy.sh

# С кастомным commit message  
./deploy.sh "fix: исправлена конфигурация сервера"
```

## ⚙️ Первоначальная настройка

### 1. Установка Railway CLI (опционально)
```bash
npm install -g @railway/cli
railway login
```

### 2. Настройка переменных окружения в Railway
В Railway панели установите:
```bash
SERVER_NAME="[Railway] Ваше Имя Сервера"
RCON_PASSWORD="ваш_безопасный_пароль_2024"  
MAX_PLAYERS="20"
DEFAULT_ARENA="de_cyberaqua"
SYNC_ARENAS="true"
```

### 3. Опциональные переменные
```bash
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."
CASUAL_SERVERS="1" 
RANKED_SERVERS="0"
```

## 🔍 Диагностика

### Проверка логов
```bash
railway logs --follow
```

### Проверка переменных
```bash
railway variables
```

### Проверка статуса
```bash  
railway status
```

### Ручной redeploy
```bash
railway redeploy
```

## 🎮 Подключение игроков

### Веб-клиенты
1. Откройте [hypersomnia.io](https://hypersomnia.io)
2. **Browse Servers** - найдите ваш сервер в списке
3. **Connect to Server** - введите адрес Railway сервера

### Нативные клиенты
1. Скачайте игру: [hypersomnia.xyz](https://hypersomnia.xyz/builds/latest/)
2. **Connect to Server** - введите: `your-railway-domain:8412`

## 🔧 Админка

### Настройка RCON
1. В игровом клиенте: `Settings → Client → RCON Password`
2. Введите ваш `RCON_PASSWORD` 
3. Подключитесь к серверу
4. Нажмите `ESC` → откроется админ панель

### Команды RCON
- `/map de_silo` - сменить карту
- `/restart` - перезапуск матча
- `/kick player_name` - кикнуть игрока
- `/rcon_password new_password` - смена пароля

## 🐛 Решение проблем

### Ошибка 502 Bad Gateway
```bash
# Проверьте логи на наличие HTTP health check сервера
railway logs | grep "Health check"

# Должно быть:
# Starting Hypersomnia Health Check Server on port 12345
# Health check server started on port 12345
```

### Переменные не применяются
```bash
# В логах должно быть:
# SERVER_NAME: '[Railway] Ваш Сервер' (не 'НЕ УСТАНОВЛЕН')
# RCON_PASSWORD: 'ваш_пароль' (не 'НЕ УСТАНОВЛЕН')

# Если показывает НЕ УСТАНОВЛЕН:
railway variables set SERVER_NAME="[Railway] Мой Сервер"
railway variables set RCON_PASSWORD="мой_пароль"
railway redeploy
```

### Игроки не могут подключиться
1. **Проверьте логи**: `railway logs | grep "server listening"`
2. **Должно быть**: `server listening on 0.0.0.0:8412`
3. **Проверьте WebRTC**: `railway logs | grep "Web UDP port"`
4. **Должно быть**: `Web port range: 9000`

### Сервер не появляется в списке
```bash
# Проверьте регистрацию в мастер-сервере
railway logs | grep "server_list"

# Должно быть:
# Requesting resolution of server_list address at masterserver.hypersomnia.xyz:8430
```

## 📊 Мониторинг производительности

### Метрики Railway
- **CPU Usage** - должно быть < 80%
- **Memory Usage** - должно быть < 512MB  
- **Network** - UDP трафик на портах 8412, 9000

### Оптимизация
```bash
# Уменьшить нагрузку:
MAX_PLAYERS="10"          # Меньше игроков
SYNC_ARENAS="false"       # Отключить загрузку карт
DAILY_AUTOUPDATE="false"  # Отключить автообновления
```

---

## 🎉 Готово!

После успешного деплоя ваш сервер будет доступен для игры через:
- **Веб**: [hypersomnia.io](https://hypersomnia.io) 
- **Нативный клиент**: `your-railway-domain:8412`

**Удачного геймплея! 🎮🚂**
