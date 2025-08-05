#!/bin/bash

echo "=== OpenWebUI Installation Verification Script ==="
echo "This script will check if all components are properly installed and running"
echo ""

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "✗ docker-compose.yml not found in current directory"
    echo "Please run this script from the OpenWebUI installation directory"
    exit 1
fi

echo "✓ Found docker-compose.yml in current directory"
echo ""

echo "1. Checking Docker installation..."
if command -v docker &> /dev/null; then
    echo "✓ Docker is installed"
    echo "  Docker version: $(docker --version)"
else
    echo "✗ Docker is NOT installed"
    echo "  Install with: sudo apt update && sudo apt install -y docker.io"
fi

echo ""
echo "2. Checking Docker Compose installation..."
if command -v docker-compose &> /dev/null; then
    echo "✓ Docker Compose is installed"
    echo "  Docker Compose version: $(docker-compose --version)"
else
    echo "✗ Docker Compose is NOT installed"
    echo "  Install with: sudo apt install -y docker-compose"
fi

echo ""
echo "3. Checking Docker service status..."
if systemctl is-active --quiet docker; then
    echo "✓ Docker service is running"
else
    echo "✗ Docker service is NOT running"
    echo "  Start with: sudo systemctl start docker"
fi

echo ""
echo "4. Checking if user is in docker group..."
if groups $USER | grep -q docker; then
    echo "✓ User is in docker group"
else
    echo "✗ User is NOT in docker group"
    echo "  Fix with: sudo usermod -aG docker $USER && newgrp docker"
fi

echo ""
echo "5. Checking Docker containers status..."
echo "  Container status:"
docker-compose ps

echo ""
echo "6. Checking if containers are running..."
if docker-compose ps | grep -q "Up"; then
    echo "✓ Containers are running"
    echo "  Running containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo "✗ Containers are NOT running"
    echo "  Start with: docker-compose up -d"
fi

echo ""
echo "7. Checking network connectivity..."
echo "  Testing local access to OpenWebUI..."
if curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo "✓ OpenWebUI is accessible at http://localhost:8080"
else
    echo "✗ OpenWebUI is NOT accessible at http://localhost:8080"
    echo "  Container logs:"
    docker-compose logs --tail=5 openwebui
fi

echo ""
echo "8. Checking Caddy reverse proxy..."
if curl -s http://localhost:80 > /dev/null 2>&1; then
    echo "✓ Caddy is listening on port 80"
else
    echo "✗ Caddy is NOT listening on port 80"
fi

if curl -s https://localhost:443 > /dev/null 2>&1; then
    echo "✓ Caddy is listening on port 443 (HTTPS)"
else
    echo "✗ Caddy is NOT listening on port 443 (HTTPS)"
fi

echo ""
echo "9. Checking disk space..."
echo "  Available disk space:"
df -h . | tail -1

echo ""
echo "10. Checking Docker disk usage..."
echo "  Docker disk usage:"
docker system df

echo ""
echo "11. Checking container resource usage..."
echo "  Container resource usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

echo ""
echo "12. Checking for any error logs..."
echo "  Recent error logs from containers:"
docker-compose logs --tail=10 | grep -i error || echo "  No recent errors found"

echo ""
echo "=== Verification Summary ==="
echo "✓ marks indicate everything is working correctly"
echo "✗ marks indicate issues that need attention"
echo ""
echo "Troubleshooting commands:"
echo "- View all logs: docker-compose logs -f"
echo "- Restart containers: docker-compose restart"
echo "- Rebuild and restart: docker-compose down && docker-compose up -d"
echo "- Check specific container: docker-compose logs [container-name]"
echo ""
echo "Access URLs:"
echo "- Local: http://localhost:8080"
echo "- With Caddy: https://[your-domain-or-ip]" 