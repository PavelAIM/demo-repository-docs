#!/bin/bash

# Этот скрипт для свежей Ubuntu VM в Multipass (запустите внутри VM: multipass shell <new-vm-name>).
# Убедитесь, что VM свежая; скрипт устанавливает всё аккуратно, без конфликтов.

# Шаг 1: Обновляем пакеты и устанавливаем Docker, Docker Compose, Nginx
sudo apt update
sudo apt install -y docker.io docker-compose nginx
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker  # Применяем группу без логаута

# Шаг 2: Устанавливаем часовой пояс на Москву
sudo timedatectl set-timezone Europe/Moscow

# Шаг 3: Создаем рабочую директорию для OpenWebUI
mkdir ~/openwebui
cd ~/openwebui

# Шаг 4: Создаем docker-compose.yml с минимальной конфигурацией (ports на 3000 для proxy)
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

# Шаг 5: Запускаем OpenWebUI
docker-compose up -d

# Шаг 6: Генерируем self-signed сертификат для HTTPS
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/openwebui.key \
    -out /etc/nginx/ssl/openwebui.crt \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=OpenWebUI/CN=openwebui.local"

# Шаг 7: Создаём конфигурацию Nginx для reverse proxy с HTTPS и redirect
sudo bash -c 'cat > /etc/nginx/sites-available/openwebui << EOF
server {
    listen 80;
    server_name openwebui.local;
    return 301 https://\$host\$request_uri;  # Redirect to HTTPS
}

server {
    listen 443 ssl;
    server_name openwebui.local;

    ssl_certificate /etc/nginx/ssl/openwebui.crt;
    ssl_certificate_key /etc/nginx/ssl/openwebui.key;

    location / {
        proxy_pass http://localhost:3000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF'

# Шаг 8: Отключаем дефолтный сайт Nginx для предотвращения конфликтов
if [ -f /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

# Шаг 9: Активируем наш config и проверяем
sudo ln -s /etc/nginx/sites-available/openwebui /etc/nginx/sites-enabled/
sudo nginx -T  # Показать полный config для debug
sudo nginx -t && sudo systemctl restart nginx

# Шаг 10: Инструкция для MacBook: Добавьте в /etc/hosts и проверьте
echo "На вашем MacBook выполните: sudo bash -c 'echo \"<VM-IP> openwebui.local\" >> /etc/hosts' (узнайте IP: multipass info <vm-name>)"
echo "Готово! Доступ по https://openwebui.local (примите cert warning в браузере)."
