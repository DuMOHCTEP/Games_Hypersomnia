# 🌐 Развертывание веб-клиента Hypersomnia

## 📋 Обзор

В проекте ЕСТЬ полноценный веб-клиент, но наш Railway деплой включает только серверную часть.

### Текущая архитектура:
```
Веб-клиент (hypersomnia.io) → [Railway Server] ← Ваш деплой 
Нативные клиенты           →  UDP:8412 + 9000
```

## 🎯 Варианты развертывания веб-клиента:

### 1. Использовать официальный (рекомендуется)
- **Веб-клиент**: [hypersomnia.io](https://hypersomnia.io)
- **Ваш сервер**: Railway бэкенд
- **Преимущества**: Готовый, обновляемый, не требует настройки

### 2. Развернуть свой веб-клиент 

#### A) Сборка веб-версии из исходников:
```bash
# Требования: Emscripten SDK
git clone https://github.com/DuMOHCTEP/Games_Hypersomnia.git
cd Games_Hypersomnia

# Установка Emscripten SDK
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh

# Сборка веб-клиента
mkdir build-web
cd build-web
emcmake cmake .. -DARCHITECTURE=Web -DCMAKE_BUILD_TYPE=Release
emmake make -j$(nproc)
```

#### B) Развертывание веб-клиента на отдельном сервисе:

**Vercel/Netlify:**
```yaml
# vercel.json или netlify.toml
build:
  command: "emmake make"
  output: "build-web/"
```

**GitHub Pages:**
```yaml
# .github/workflows/web-client.yml  
name: Build Web Client
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Emscripten
        run: |
          # Установка Emscripten и сборка
      - name: Deploy to GitHub Pages
        # Развертывание
```

**Docker для веб-клиента:**
```dockerfile
FROM emscripten/emsdk:latest
WORKDIR /app
COPY . .
RUN emcmake cmake -DARCHITECTURE=Web .
RUN emmake make
EXPOSE 3000
CMD ["python3", "-m", "http.server", "3000"]
```

## 🔧 Конфигурация веб-клиента

### В файле default_config.json:
```json
{
  "server_list_provider": "http://masterserver.hypersomnia.xyz:8410",
  "webrtc_signalling_server_url": "wss://masterserver.hypersomnia.xyz:8000"
}
```

### Для подключения к вашему Railway серверу:
```json
{
  "client_connect": "your-railway-domain:8412"
}
```

## 🌐 Варианты веб-платформ

Проект поддерживает сборку для:

### 1. Обычный веб-клиент
```bash
cmake -DARCHITECTURE=Web -DCMAKE_BUILD_TYPE=Release
```

### 2. itch.io версия
```bash  
cmake -DARCHITECTURE=Web -DBUILD_ITCH=ON
```

### 3. CrazyGames версия
```bash
cmake -DARCHITECTURE=Web -DBUILD_CRAZYGAMES=ON  
```

## 📊 Рекомендации

### ✅ Простое решение:
1. **Используйте [hypersomnia.io](https://hypersomnia.io)** как веб-клиент
2. **Railway сервер** как бэкенд
3. **Игроки подключаются** через Browse Servers

### 🔧 Если нужен свой веб-клиент:
1. **Соберите WebAssembly версию** с Emscripten
2. **Разместите на Vercel/Netlify/GitHub Pages**
3. **Настройте подключение** к вашему Railway серверу

### 💡 Промо-возможности:
- Свой домен для веб-клиента
- Кастомизация интерфейса  
- Интеграция с вашими системами
- Брендинг и реклама

## 🆘 Поддержка

Если нужна помощь с развертыванием веб-клиента:
1. Изучите документацию в `BUILDING.md`
2. Проверьте примеры в `cmake/web/`
3. Обратитесь в Discord сообщество Hypersomnia

---

**💡 Вывод**: Для большинства случаев достаточно использовать официальный веб-клиент [hypersomnia.io](https://hypersomnia.io) + ваш Railway сервер!
