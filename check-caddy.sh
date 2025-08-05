#!/bin/bash

echo "=== Caddy Reverse Proxy Verification Script ==="
echo "This script will check Caddy installation, configuration, and available addresses"
echo ""

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "✗ docker-compose.yml not found in current directory"
    echo "Please run this script from the OpenWebUI installation directory"
    exit 1
fi

echo "✓ Found docker-compose.yml in current directory"
echo ""

echo "1. Checking Caddy container status..."
echo "  Caddy container status:"
docker-compose ps caddy

echo ""
echo "2. Checking if Caddy container is running..."
if docker-compose ps caddy | grep -q "Up"; then
    echo "✓ Caddy container is running"
else
    echo "✗ Caddy container is NOT running"
    echo "  Start with: docker-compose up -d caddy"
fi

echo ""
echo "3. Checking Caddy configuration file..."
if [ -f "Caddyfile" ]; then
    echo "✓ Caddyfile exists"
    echo "  Caddyfile contents:"
    cat Caddyfile
else
    echo "✗ Caddyfile NOT found"
fi

echo ""
echo "4. Checking Caddy configuration syntax..."
if docker-compose exec caddy caddy validate --config /etc/caddy/Caddyfile 2>/dev/null; then
    echo "✓ Caddy configuration is valid"
else
    echo "✗ Caddy configuration has errors"
    echo "  Checking configuration inside container:"
    docker-compose exec caddy caddy validate --config /etc/caddy/Caddyfile
fi

echo ""
echo "5. Checking Caddy ports and listening addresses..."
echo "  Caddy container port mappings:"
docker port caddy

echo ""
echo "6. Testing Caddy HTTP access (port 80)..."
if curl -s -I http://localhost:80 > /dev/null 2>&1; then
    echo "✓ Caddy is accessible on HTTP (port 80)"
    echo "  HTTP Response:"
    curl -s -I http://localhost:80 | head -5
else
    echo "✗ Caddy is NOT accessible on HTTP (port 80)"
fi

echo ""
echo "7. Testing Caddy HTTPS access (port 443)..."
if curl -s -I https://localhost:443 > /dev/null 2>&1; then
    echo "✓ Caddy is accessible on HTTPS (port 443)"
    echo "  HTTPS Response:"
    curl -s -I https://localhost:443 | head -5
else
    echo "✗ Caddy is NOT accessible on HTTPS (port 443)"
fi

echo ""
echo "8. Checking Caddy logs for errors..."
echo "  Recent Caddy logs:"
docker-compose logs --tail=10 caddy

echo ""
echo "9. Checking Caddy certificate status..."
echo "  Caddy certificates (if any):"
docker-compose exec caddy ls -la /data/caddy/certificates/acme/ 2>/dev/null || echo "  No certificates found or directory not accessible"

echo ""
echo "10. Checking network connectivity between Caddy and OpenWebUI..."
echo "  Testing if Caddy can reach OpenWebUI container:"
if docker-compose exec caddy ping -c 1 openwebui > /dev/null 2>&1; then
    echo "✓ Caddy can reach OpenWebUI container"
else
    echo "✗ Caddy cannot reach OpenWebUI container"
fi

echo ""
echo "11. Checking available network interfaces..."
echo "  Available network interfaces:"
ip addr show | grep -E "inet.*scope global" | awk '{print "  " $2}'

echo ""
echo "12. Checking firewall status for ports 80 and 443..."
echo "  Checking if ports are open:"
if netstat -tlnp 2>/dev/null | grep -E ":80|:443"; then
    echo "✓ Ports 80 and/or 443 are listening"
else
    echo "✗ Ports 80 and 443 are not listening"
fi

echo ""
echo "=== Caddy Address Information ==="
echo ""
echo "Available Caddy addresses:"
echo "- Local HTTP:  http://localhost"
echo "- Local HTTPS: https://localhost"
echo "- Local HTTP (port):  http://localhost:80"
echo "- Local HTTPS (port): https://localhost:443"
echo ""
echo "To access from external network:"
echo "- Replace 'localhost' with your server's IP address or domain name"
echo "- Example: https://your-server-ip or https://your-domain.com"
echo ""
echo "Current server IP addresses:"
hostname -I | tr ' ' '\n' | grep -v '^$' | while read ip; do
    echo "- HTTP:  http://$ip"
    echo "- HTTPS: https://$ip"
done

echo ""
echo "=== Caddy Troubleshooting ==="
echo "If Caddy is not working:"
echo "1. Check container logs: docker-compose logs caddy"
echo "2. Restart Caddy: docker-compose restart caddy"
echo "3. Rebuild Caddy: docker-compose up -d --force-recreate caddy"
echo "4. Check configuration: docker-compose exec caddy caddy validate --config /etc/caddy/Caddyfile"
echo "5. Check network: docker network ls && docker network inspect openwebui-network" 