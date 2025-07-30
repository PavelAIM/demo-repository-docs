#!/bin/bash

# Шаг 1. Установите Docker и Docker Compose
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker

# Шаг 2. Создайте рабочую директорию
mkdir ~/openwebui
cd ~/openwebui

# Шаг 3. Создайте файл docker-compose.yml с минимальной конфигурацией
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  openwebui:
    image: ghcr.io/open-webui/open-webui:latest
    container_name: openwebui
    ports:
      - "3000:8080"
    volumes:
      - openwebui-data:/app/backend/data
    restart: unless-stopped

volumes:
  openwebui-data:
EOF

# Проверка создания файла
ls -la docker-compose.yml

# Шаг 4. Запустите контейнер
docker-compose up -d

# Шаг 5. Откройте веб-интерфейс
# Узнать IP-адрес сервера
ip addr show

echo "Open the web interface at: http://<IP_ADDRESS>:3000"
echo "Первый пользователь, который зарегистрируется — станет администратором."

# Пошаговые инструкции заканчиваются здесь.
echo "Скрипт завершен. Теперь вы можете открыть веб-интерфейс и продолжить с настройкой модели GPT-4o от OpenAI."