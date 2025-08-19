# 🔧 Исправление ошибки 502 на Railway

## ❌ Проблема
Railway выдавал ошибку **502 Bad Gateway** при запуске сервера Hypersomnia.

## 🔍 Причина
- **Hypersomnia** - это UDP игровой сервер (порты 8412, 9000)
- **Railway** ожидал HTTP endpoint для health check
- Переменные окружения не передавались в конфигурацию сервера

## ✅ Решение

### 1. Добавлен HTTP Health Check Сервер
Создан `health_server.py` - Python HTTP сервер который:
- Слушает на `$PORT` (Railway переменная) 
- Отвечает JSON статусом сервера
- Проверяет что процесс Hypersomnia запущен

### 2. Исправлена передача переменных
В `start-railway.sh`:
- Правильно создается конфигурационный файл
- Переменные окружения корректно подставляются
- Добавлена диагностика запуска

### 3. Обновлен Dockerfile
Добавлены необходимые пакеты:
- `python3` - для health check сервера  
- `netcat-openbsd` - для сетевых утилит
- `procps` - для мониторинга процессов

## 🚀 Как перезапустить

### В Railway панели:
1. Перейдите к вашему проекту
2. **Redeploy** - пересобрать из обновленного кода
3. Установите переменные окружения:
   ```
   SERVER_NAME="[Railway] Мой Сервер"
   RCON_PASSWORD="ваш_пароль"
   MAX_PLAYERS="20"
   ```

### Через Railway CLI:
```bash
railway redeploy
railway logs  # Проверить логи
```

## 📊 Проверка работы

### Ожидаемые логи при успешном запуске:
```
=== Запуск сервера Hypersomnia на Railway ===
Starting Hypersomnia Health Check Server on port 12345
Health check server started on port 12345
Используемые порты:
  HTTP Health Check: 12345
  Нативные клиенты (UDP): 8412  
  Веб клиенты (WebRTC UDP): 9000
Конфигурация создана:
{
  "server": {
    "server_name": "[Railway] Мой Сервер"
  }
}
server listening on 0.0.0.0:8412
Server name: [Railway] Мой Сервер
```

### Проверка health endpoint:
```bash
curl http://your-railway-domain.railway.app/
```

Ответ:
```json
{
  "status": "healthy",
  "service": "hypersomnia-server", 
  "uptime": "45.3 seconds",
  "pids": ["123"]
}
```

## 🎮 Подключение игроков

### Веб-клиенты:
1. Откройте [hypersomnia.io](https://hypersomnia.io)
2. **Browse Servers** → найдите ваш сервер в списке
3. **Connect to Server** → введите `your-railway-domain:8412`

### Нативные клиенты:
1. Скачайте игру с [hypersomnia.xyz](https://hypersomnia.xyz)
2. **Connect to Server** → введите `your-railway-domain:8412`

## 🛠️ Дальнейшее администрирование

### RCON панель:
1. В настройках клиента установите ваш RCON пароль
2. Подключитесь к серверу
3. `ESC` → откроется админ панель

### Мониторинг в Railway:
- **Metrics** - использование CPU/RAM/сети
- **Logs** - логи в реальном времени
- **Variables** - изменение переменных окружения

---

## 🎉 Готово!
Сервер должен работать без ошибки 502 и принимать подключения как веб, так и нативных клиентов!
