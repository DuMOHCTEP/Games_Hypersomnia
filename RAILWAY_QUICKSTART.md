# 🚂 Быстрый старт Railway - Hypersomnia Server

## 1️⃣ Подготовка (5 минут)

```bash
# Клонировать репозиторий (если еще не сделано)
git clone https://github.com/DuMOHCTEP/Games_Hypersomnia.git
cd Games_Hypersomnia
```

## 2️⃣ Развертывание на Railway (2 минуты)

### Вариант A: Через веб-интерфейс
1. Идите на [railway.app](https://railway.app)
2. Нажмите **"Deploy from GitHub repo"**
3. Выберите репозиторий `Games_Hypersomnia`
4. Railway автоматически найдет `railway.toml` и начнет сборку

### Вариант B: Через Railway CLI
```bash
npm install -g @railway/cli  # Установка CLI
railway login               # Авторизация
railway init                # Инициализация проекта
railway up                  # Развертывание
```

## 3️⃣ Настройка переменных (3 минуты)

### В веб-панели Railway:
Перейдите в **Variables** и установите:

```bash
SERVER_NAME="[Railway] Ваш Сервер"
RCON_PASSWORD="ваш_безопасный_пароль"  
MAX_PLAYERS="20"
```

### Или через CLI:
```bash
railway variables set SERVER_NAME="[Railway] Мой Сервер"
railway variables set RCON_PASSWORD="super_secret_password"
railway variables set MAX_PLAYERS="20"
```

## 4️⃣ Готово! 🎉

Ваш сервер теперь доступен по адресу, который Railway покажет в панели.

### Подключение к серверу:
1. Скачайте игру [Hypersomnia](https://hypersomnia.xyz/builds/latest/)
2. Найдите сервер в списке или подключитесь по IP
3. Для админки: установите RCON пароль в настройках клиента

## 📊 Мониторинг

В панели Railway доступны:
- 📈 Метрики CPU/RAM
- 📝 Логи в реальном времени
- 🌐 Статистика сетевой активности

## ⚙️ Дополнительные настройки

```bash
# Discord уведомления
railway variables set DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."

# Стартовая карта
railway variables set DEFAULT_ARENA="de_silo"

# Загрузка карт сообщества
railway variables set SYNC_ARENAS="true"
```

## 🆘 Быстрая помощь

### Сервер не запускается?
```bash
railway logs  # Смотрим логи
```

### Нужно изменить настройки?
```bash
railway variables  # Список переменных
railway redeploy   # Перезапуск после изменений
```

### Нужна админка?
1. В игре: `Settings → Client → RCON Password`
2. Подключитесь к серверу
3. Нажмите `ESC` → откроется админ панель

---

**🎮 Удачной игры!**

Подробная документация: [README_RAILWAY.md](README_RAILWAY.md)
