#!/bin/bash

echo "=== OpenWebUI Installation Script ==="
echo "This script will install Docker, Docker Compose, and deploy OpenWebUI with Caddy reverse proxy"
echo ""

# Шаг 1. Установите Docker и Docker Compose
echo "Step 1: Installing Docker and Docker Compose..."
echo "Updating package list..."
sudo apt update

echo "Installing Docker.io and Docker Compose..."
sudo apt install -y docker.io docker-compose

echo "Enabling Docker service..."
sudo systemctl enable docker

echo "Adding current user to docker group..."
sudo usermod -aG docker $USER

echo "Activating docker group membership..."
newgrp docker

echo "Step 1 completed: Docker and Docker Compose installed successfully"
echo ""

# Шаг 2. Создайте рабочую директорию
echo "\n\nStep 2: Creating working directory..."
echo "Creating ~/openwebui directory..."
echo "pwd..."
pwd
mkdir ~/openwebui


echo "pwd..."
pwd

echo "Changing to openwebui directory..."
cd ~/openwebui

echo "\nCurrent working directory: $(pwd)\n"
echo "Step 2 completed: Working directory created"
echo ""

# Шаг 3. Создайте файл docker-compose.yml с Caddy и HTTPS
echo "Step 3: Creating Docker Compose configuration..."
echo "Creating docker-compose.yml file with OpenWebUI and Caddy services..."

cat > docker-compose.yml << 'EOF'
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

echo "docker-compose.yml file created successfully"

echo "Creating Caddy configuration file..."
cat > Caddyfile << 'EOF'
[адрес сервера] {
    reverse_proxy openwebui:8080
    log {
        output file /var/log/caddy/openwebui.log
        format json
    }
}
EOF

echo "Caddyfile created successfully"

# Проверка создания файлов
echo "Verifying created files..."
echo "Files in current directory:"
ls -la docker-compose.yml Caddyfile

echo "Step 3 completed: Configuration files created"
echo ""

# Шаг 4. Запустите контейнеры
echo "Step 4: Starting Docker containers..."
echo "Pulling Docker images (this may take a few minutes)..."
docker-compose pull

echo "Starting containers in detached mode..."
docker-compose up -d

echo "Checking container status..."
echo "Running containers:"
docker-compose ps

echo "Container logs (last 10 lines):"
docker-compose logs --tail=10

echo "Step 4 completed: Containers started successfully"
echo ""

# Шаг 5. Откройте веб-интерфейс
echo "Step 5: Installation Summary"
echo "=================================="
echo "OpenWebUI has been successfully installed!"
echo ""
echo "Access URLs:"
echo "- Local access: http://localhost:8080"
echo "- With Caddy proxy: https://[адрес сервера]"
echo ""
echo "IMPORTANT: Replace [адрес сервера] in the Caddyfile with your domain or server IP address"
echo ""
echo "The first user to register will become the administrator."
echo ""
echo "Container management commands:"
echo "- View logs: docker-compose logs -f"
echo "- Stop services: docker-compose down"
echo "- Restart services: docker-compose restart"
echo "- Update to latest version: docker-compose pull && docker-compose up -d"
echo ""
echo "Step 5 completed: Installation finished"
echo ""

# Пошаговые инструкции заканчиваются здесь.
echo "=== Script completed successfully ==="
echo "You can now open the web interface and continue with model configuration."