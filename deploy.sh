#!/bin/bash

set -e  # Выход при любой ошибке

echo "🚂 === СКРИПТ АВТОМАТИЧЕСКОГО ДЕПЛОЯ HYPERSOMNIA НА RAILWAY ==="
echo ""

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m' 
RED='\033[0;31m'
NC='\033[0m' # No Color

# Функция для цветного вывода
log_info() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Проверяем что мы в правильной директории
if [[ ! -f "Dockerfile.railway" ]] || [[ ! -f "railway.toml" ]]; then
    log_error "Ошибка: Запустите скрипт из корневой директории проекта Hypersomnia"
    log_error "Должны быть файлы: Dockerfile.railway, railway.toml"
    exit 1
fi

# Получаем commit message от пользователя или используем дефолтный
COMMIT_MSG="$1"
if [[ -z "$COMMIT_MSG" ]]; then
    COMMIT_MSG="deploy: обновление конфигурации Railway сервера $(date '+%Y-%m-%d %H:%M:%S')"
    log_warning "Использован автоматический commit message: $COMMIT_MSG"
else
    log_info "Используем пользовательский commit message: $COMMIT_MSG"
fi

echo ""
echo "🔍 === ПРОВЕРКА СТАТУСА GIT ==="

# Проверяем статус git
git_status=$(git status --porcelain)
if [[ -z "$git_status" ]]; then
    log_info "Git репозиторий чистый, нет изменений для коммита"
    log_warning "Перезапускаем последний коммит на Railway..."
else
    log_info "Найдены изменения для коммита:"
    git status --short
fi

echo ""
echo "📦 === ПОДГОТОВКА К ДЕПЛОЮ ==="

# Убеждаемся что мы на ветке production
current_branch=$(git branch --show-current)
if [[ "$current_branch" != "production" ]]; then
    log_warning "Переключаемся с ветки '$current_branch' на 'production'"
    git checkout production
else
    log_info "Уже находимся на ветке 'production'"
fi

# Если есть изменения - коммитим
if [[ -n "$git_status" ]]; then
    echo ""
    echo "📝 === КОММИТ ИЗМЕНЕНИЙ ==="
    
    # Добавляем все изменения
    log_info "Добавляем все изменения в git..."
    git add -A
    
    # Показываем что будет закоммичено
    echo ""
    log_info "Изменения для коммита:"
    git diff --cached --stat || true
    
    # Коммитим
    log_info "Создаем коммит..."
    git commit -m "$COMMIT_MSG"
    log_info "Коммит создан успешно"
fi

echo ""
echo "🚀 === PUSH В PRODUCTION ВЕТКУ ==="

# Пушим в production ветку
log_info "Отправляем изменения в origin/production..."
git push origin production
log_info "Push выполнен успешно"

echo ""
echo "🔧 === ПРОВЕРКА RAILWAY CLI ==="

# Проверяем наличие Railway CLI
if command -v railway >/dev/null 2>&1; then
    log_info "Railway CLI найден"
    
    # Проверяем что мы залогинены
    if railway status >/dev/null 2>&1; then
        log_info "Railway CLI авторизован"
        
        echo ""
        echo "🔄 === АВТОМАТИЧЕСКИЙ REDEPLOY ==="
        log_info "Запускаем redeploy на Railway..."
        
        # Запускаем redeploy
        railway redeploy
        
        log_info "Redeploy запущен!"
        
        echo ""
        log_info "🎉 Для просмотра логов выполните: railway logs --follow"
        log_info "🌐 Для просмотра переменных: railway variables"
        log_info "📊 Для открытия панели Railway: railway open"
        
    else
        log_warning "Railway CLI не авторизован"
        log_warning "Выполните: railway login"
        log_warning "Затем запустите вручную: railway redeploy"
    fi
else
    log_warning "Railway CLI не установлен"
    log_warning "Установите: npm install -g @railway/cli"
    log_warning "Затем: railway login && railway redeploy"
fi

echo ""
echo "📋 === ИНСТРУКЦИИ ПО НАСТРОЙКЕ ==="
echo ""
echo "1. 🌐 Откройте Railway панель: https://railway.app/dashboard"
echo "2. ⚙️  Перейдите в Variables и установите:"
echo "   SERVER_NAME='[Railway] Ваш Сервер'"
echo "   RCON_PASSWORD='ваш_безопасный_пароль'"
echo "   MAX_PLAYERS='20'"
echo ""
echo "3. 🎮 Подключение к серверу:"
echo "   • Веб: https://hypersomnia.io → Browse Servers"
echo "   • Нативный клиент: your-railway-domain:8412"
echo ""
echo "4. 🔧 Админка:"
echo "   • Установите RCON пароль в настройках клиента"
echo "   • Нажмите ESC в игре → откроется админ панель"
echo ""

# Показываем текущий коммит и ветку
echo "📊 === ИНФОРМАЦИЯ О ДЕПЛОЕ ==="
log_info "Текущая ветка: $(git branch --show-current)"
log_info "Последний коммит: $(git log --oneline -1)"
log_info "Удаленная ветка обновлена: origin/production"

echo ""
log_info "🎉 ДЕПЛОЙ ЗАВЕРШЕН!"
log_info "Railway автоматически пересобирает проект при изменениях в production ветке"

# Опционально открываем Railway панель в браузере
read -p "🌐 Открыть Railway панель в браузере? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v railway >/dev/null 2>&1; then
        railway open
    else
        log_info "Откройте вручную: https://railway.app/dashboard"
    fi
fi

echo ""
log_info "✨ Готово! Удачного геймплея!"
