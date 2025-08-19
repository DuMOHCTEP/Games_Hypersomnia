# 🚀 Ручной деплой на Railway (если скрипты не работают)

## Простые команды для деплоя:

```bash
# 1. Переходим в директорию проекта
cd /var/www/neonpsh.ru/games/hypersomnia

# 2. Убеждаемся что на ветке production  
git checkout production

# 3. Добавляем все изменения
git add -A

# 4. Коммитим с сообщением
git commit -m "fix: улучшения конфигурации Railway"

# 5. Пушим в production ветку  
git push origin production
```

## После пуша:

1. **Railway автоматически перезапустится** (2-3 минуты)
2. **Проверьте переменные в Railway панели**:
   - `SERVER_NAME="[Railway] Мой Сервер"`  
   - `RCON_PASSWORD="безопасный_пароль"`
   - `MAX_PLAYERS="20"`

## Проверка работы:

### В логах Railway должно быть:
```
=== ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ ===
SERVER_NAME: '[Railway] Мой Сервер'  ✅
RCON_PASSWORD: 'безопасный_пароль'   ✅

Health check server запущен с PID: 123
server listening on 0.0.0.0:8412
Server name: [Railway] Мой Сервер    ✅
```

### Если показывает 'НЕ УСТАНОВЛЕН' ❌:
1. Зайдите в Railway панель
2. Variables → установите переменные
3. Redeploy (или пуш еще раз)

## Подключение игроков:
- **Веб**: [hypersomnia.io](https://hypersomnia.io) → Browse Servers
- **Нативный**: your-railway-domain:8412

---

## 🆘 Если нужна помощь:
1. Покажите логи Railway
2. Проверьте что переменные окружения установлены  
3. Убедитесь что health check server запустился
