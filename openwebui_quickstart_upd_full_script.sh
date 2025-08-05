#!/bin/bash

# ============================================
# Скрипт установки OpenWebUI
# Версия: 1.0
# Описание: Автоматическая установка корпоративного AI-чата
# ============================================

# ============================================
# chmod +x openwebui_quickstart_upd_full_script.sh
# ./openwebui_quickstart_upd_full_script.sh
# ============================================

# ============================================
# КОНФИГУРАЦИОННЫЕ ПАРАМЕТРЫ
# Измените эти значения перед запуском скрипта
# ============================================

# Основные параметры
SERVER_ADDRESS="your-domain.com"  # Домен или IP-адрес сервера (например: openwebui.company.com)

# OAuth параметры (оставьте пустыми если не используете OAuth)
ENABLE_OAUTH="false"  # true/false - включить OAuth аутентификацию
OAUTH_PROVIDER="keycloak"  # keycloak/google/microsoft/okta
OAUTH_CLIENT_ID="openwebui"
OAUTH_CLIENT_SECRET=""  # Секретный ключ из вашего OAuth провайдера
OAUTH_KEYCLOAK_URL=""  # URL вашего Keycloak сервера (например: https://keycloak.company.com)
OAUTH_REALM=""  # Название realm в Keycloak

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================
# ФУНКЦИИ
# ============================================

print_step() {
    echo -e "\n${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Этот скрипт не должен запускаться от root!"
        exit 1
    fi
}

# ============================================
# НАЧАЛО УСТАНОВКИ
# ============================================

clear
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Установка OpenWebUI - AI для всех    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "Этот скрипт установит:"
echo "• Docker и Docker Compose"
echo "• OpenWebUI - веб-интерфейс для AI"
echo "• Caddy - веб-сервер с автоматическим HTTPS"
if [[ "$ENABLE_OAUTH" == "true" ]]; then
    echo "• OAuth аутентификацию через $OAUTH_PROVIDER"
fi
echo ""
echo "Сервер будет доступен по адресу: https://$SERVER_ADDRESS"
echo ""
read -p "Продолжить установку? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Проверка запуска не от root
check_root

# ============================================
# ШАГ 1: УСТАНОВКА DOCKER
# ============================================

print_step "Шаг 1: Установка Docker и Docker Compose"
echo "Docker позволит запускать приложения в изолированных контейнерах"

# Обновление пакетов
print_step "Обновление списка пакетов..."
sudo apt update

# Установка Docker
if command -v docker &> /dev/null; then
    print_success "Docker уже установлен (версия: $(docker --version))"
else
    print_step "Установка Docker..."
    sudo apt install -y docker.io
    print_success "Docker установлен"
fi

# Установка Docker Compose
if command -v docker-compose &> /dev/null; then
    print_success "Docker Compose уже установлен (версия: $(docker-compose --version))"
else
    print_step "Установка Docker Compose..."
    sudo apt install -y docker-compose
    print_success "Docker Compose установлен"
fi

# Настройка Docker
print_step "Настройка Docker..."
sudo systemctl enable docker
print_success "Docker добавлен в автозагрузку"

# Добавление пользователя в группу docker
if groups $USER | grep -q '\bdocker\b'; then
    print_success "Пользователь уже в группе docker"
else
    print_step "Добавление пользователя в группу docker..."
    sudo usermod -aG docker $USER
    print_warning "Добавлен в группу docker. Может потребоваться перелогиниться"
fi

# ============================================
# ШАГ 2: НАСТРОЙКА ВРЕМЕНИ
# ============================================

print_step "Шаг 2: Настройка системного времени"
echo "Установка часового пояса на Москву для корректной работы логов"

sudo timedatectl set-timezone Europe/Moscow
print_success "Часовой пояс установлен: $(timedatectl | grep "Time zone" | awk '{print $3, $4}')"

# ============================================
# ШАГ 3: СОЗДАНИЕ РАБОЧЕЙ ДИРЕКТОРИИ
# ============================================

print_step "Шаг 3: Создание рабочей директории"
echo "Все файлы конфигурации будут храниться в ~/openwebui"

if [ -d ~/openwebui ]; then
    print_warning "Директория ~/openwebui уже существует"
    read -p "Продолжить и перезаписать файлы? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    mkdir ~/openwebui
    print_success "Создана директория ~/openwebui"
fi

cd ~/openwebui

# ============================================
# ШАГ 4: СОЗДАНИЕ КОНФИГУРАЦИИ
# ============================================

print_step "Шаг 4: Создание конфигурационных файлов"
echo "Создаем docker-compose.yml и Caddyfile для автоматического HTTPS"

# Создание docker-compose.yml
print_step "Создание docker-compose.yml..."

if [[ "$ENABLE_OAUTH" == "true" ]]; then
    # Версия с OAuth
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  openwebui:
    image: ghcr.io/open-webui/open-webui:latest
    container_name: openwebui
    environment:
      - ENABLE_OAUTH=true
      - OAUTH_PROVIDER=$OAUTH_PROVIDER
      - OAUTH_CLIENT_ID=$OAUTH_CLIENT_ID
      - OAUTH_CLIENT_SECRET=$OAUTH_CLIENT_SECRET
EOF

    # Добавляем URL-ы в зависимости от провайдера
    if [[ "$OAUTH_PROVIDER" == "keycloak" ]]; then
        cat >> docker-compose.yml << EOF
      - OAUTH_AUTHORIZATION_URL=$OAUTH_KEYCLOAK_URL/auth/realms/$OAUTH_REALM/protocol/openid-connect/auth
      - OAUTH_TOKEN_URL=$OAUTH_KEYCLOAK_URL/auth/realms/$OAUTH_REALM/protocol/openid-connect/token
      - OAUTH_USERINFO_URL=$OAUTH_KEYCLOAK_URL/auth/realms/$OAUTH_REALM/protocol/openid-connect/userinfo
EOF
    fi

    cat >> docker-compose.yml << EOF
      - ENABLE_OAUTH_SIGNUP=true
      - OAUTH_MERGE_ACCOUNTS_BY_EMAIL=true
    ports:
      - "8080:8080"
    volumes:
      - openwebui-data:/app/backend/data
    restart: unless-stopped
    networks:
      - openwebui-network
EOF
else
    # Версия без OAuth
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  openwebui:
    image: ghcr.io/open-webui/open-webui:latest
    container_name: openwebui
    ports:
      - "8080:8080"
    volumes:
      - openwebui-data:/app/backend/data
    restart: unless-stopped
    networks:
      - openwebui-network
EOF
fi

# Добавляем службу Caddy
cat >> docker-compose.yml << EOF

  caddy:
    image: caddy:2-alpine
    container_name: caddy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy-data:/data
      - caddy-config:/config
    environment:
      - SERVER_ADDRESS=$SERVER_ADDRESS
    restart: unless-stopped
    networks:
      - openwebui-network

volumes:
  openwebui-data:
  caddy-data:
  caddy-config:

networks:
  openwebui-network:
    driver: bridge
EOF

print_success "docker-compose.yml создан"

# Создание Caddyfile
print_step "Создание Caddyfile..."
cat > Caddyfile << 'EOF'
{$SERVER_ADDRESS} {
    reverse_proxy openwebui:8080
    log {
        output file /var/log/caddy/openwebui.log
        format json
    }
}
EOF

print_success "Caddyfile создан"

# Проверка файлов
print_step "Проверка созданных файлов..."
ls -la docker-compose.yml Caddyfile
print_success "Конфигурационные файлы готовы"

# ============================================
# ШАГ 5: ЗАПУСК КОНТЕЙНЕРОВ
# ============================================

print_step "Шаг 5: Запуск контейнеров"
echo "Docker загрузит образы и запустит OpenWebUI и Caddy"

print_step "Проверка Docker..."
if ! docker info &> /dev/null; then
    print_warning "Docker daemon не запущен. Запускаем..."
    sudo systemctl start docker
    sleep 2
fi

print_step "Запуск контейнеров (это может занять несколько минут)..."
docker-compose up -d

# Проверка статуса
print_step "Проверка статуса контейнеров..."
sleep 5
docker-compose ps

# ============================================
# ЗАВЕРШЕНИЕ УСТАНОВКИ
# ============================================

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Установка успешно завершена!      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Что дальше:${NC}"
echo ""
echo "1. Откройте браузер и перейдите по адресу:"
echo -e "   ${GREEN}https://$SERVER_ADDRESS${NC}"
echo ""
echo "2. Зарегистрируйте первого пользователя"
echo "   ${YELLOW}Важно: первый зарегистрированный пользователь становится администратором!${NC}"
echo ""
echo "3. Настройте подключение к AI моделям:"
echo "   • Войдите в Admin Panel"
echo "   • Добавьте API подключение (например, ai-mediator.ru)"
echo "   • Активируйте нужные модели"
echo ""
echo -e "${BLUE}Полезные команды:${NC}"
echo "• Просмотр логов: docker-compose logs -f"
echo "• Остановка: docker-compose down"
echo "• Перезапуск: docker-compose restart"
echo "• Обновление: docker-compose pull && docker-compose up -d"
echo ""

if [[ "$ENABLE_OAUTH" == "true" ]]; then
    echo -e "${YELLOW}OAuth настроен для $OAUTH_PROVIDER${NC}"
    echo "Пользователи смогут входить через корпоративную учетную запись"
    echo ""
fi

print_warning "Если вы добавляли текущего пользователя в группу docker,"
print_warning "может потребоваться выйти и зайти снова или выполнить: newgrp docker"

echo ""
echo "Документация: https://github.com/open-webui/open-webui"
echo ""