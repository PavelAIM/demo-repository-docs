#!/bin/bash

# OpenWebUI Installation Script (No Caddy Version)
# Based on instructions from openwui-no-caddy-version.md
# 
# This script automates the installation of OpenWebUI for corporate AI deployment
# Time required: 15-20 minutes
# Requirements: Ubuntu/Debian server with sudo access

set -e  # Exit on any error

echo "=========================================="
echo "OpenWebUI Installation Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
    print_error "sudo is required but not installed. Please install sudo first."
    exit 1
fi

print_step "Step 1: Installing Docker and Docker Compose"
print_status "Updating package list..."
sudo apt update

print_status "Installing Docker and Docker Compose..."
sudo apt install -y docker.io docker-compose

print_status "Enabling Docker service..."
sudo systemctl enable docker

print_status "Adding current user to docker group..."
sudo usermod -aG docker $USER

print_status "Activating docker group membership..."
newgrp docker << EONG
echo "Docker group activated"
EONG

print_step "Step 2: Setting up system timezone"
print_status "Setting timezone to Europe/Moscow..."
sudo timedatectl set-timezone Europe/Moscow

print_status "Current time configuration:"
timedatectl

print_step "Step 3: Creating working directory"
print_status "Creating ~/openwebui directory..."
mkdir -p ~/openwebui
cd ~/openwebui

print_status "Creating docker-compose.yml file..."
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

volumes:
  openwebui-data:
EOF

print_status "Verifying docker-compose.yml file was created..."
ls -la docker-compose.yml

print_step "Step 4: Starting containers"
print_status "Starting OpenWebUI container..."
sudo docker-compose up -d

print_status "Waiting for container to start..."
sleep 10

print_status "Checking container status..."
sudo docker-compose ps

print_step "Installation completed successfully!"
echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo ""
echo "1. Open your web browser and navigate to:"
echo "   http://$(hostname -I | awk '{print $1}'):8080"
echo "   or"
echo "   http://localhost:8080 (if accessing locally)"
echo ""
echo "2. Register the first user (will become administrator)"
echo ""
echo "3. Configure administrative settings:"
echo "   - Go to Admin Panel (profile icon → Admin Panel)"
echo "   - Set 'Default User Role' to 'user'"
echo "   - Disable 'Enable New Users Signup'"
echo "   - Configure users and groups as needed"
echo ""
echo "4. Connect AI models:"
echo "   - Go to Settings → Connections"
echo "   - Add OpenAI API connection:"
echo "     * API Base URL: https://api.ai-mediator.ru/v1"
echo "     * API Key: Your corporate API key from ai-mediator.ru"
echo "   - Go to Settings → Models to manage available models"
echo "   - Configure model names, descriptions, and permissions"
echo ""
echo "5. Test the installation:"
echo "   - Create a new chat"
echo "   - Select a model"
echo "   - Ask your first question"
echo ""
echo "=========================================="
echo "Important Security Notes:"
echo "=========================================="
echo ""
print_warning "Remember to:"
print_warning "- Disable new user signup after creating admin accounts"
print_warning "- Configure proper firewall rules"
print_warning "- Set up HTTPS for production use"
print_warning "- Regular backup of openwebui-data volume"
echo ""
echo "Installation log can be found in the terminal output above."
echo "For troubleshooting, check: sudo docker-compose logs"
echo ""
print_status "OpenWebUI installation completed successfully!"
