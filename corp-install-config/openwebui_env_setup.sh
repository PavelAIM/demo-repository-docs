#!/bin/bash
set -e

# === OpenWebUI ENV-Ready Folder Bootstrapper ===
# This script sets up the folder structure and .env files only (no GitHub config)

read -rp "Root path for deployment (e.g. /opt/openwebui): " ROOT_PATH
ROOT_PATH=${ROOT_PATH:-/opt/openwebui}

read -rp "Enable authentication? (true/false) [default=true]: " AUTH_ENABLED
AUTH_ENABLED=${AUTH_ENABLED:-true}

read -rp "Allow user registration? (true/false) [default=true]: " ALLOW_REG
ALLOW_REG=${ALLOW_REG:-true}

read -rp "Port for DEV environment [default=3001]: " DEV_PORT
DEV_PORT=${DEV_PORT:-3001}

read -rp "Port for PROD environment [default=3000]: " PROD_PORT
PROD_PORT=${PROD_PORT:-3000}

read -rp "AI-Mediator API key for DEV: " OPENAI_DEV_KEY
read -rp "AI-Mediator API key for PROD: " OPENAI_PROD_KEY

mkdir -p "$ROOT_PATH/dev" "$ROOT_PATH/prod"

cat > "$ROOT_PATH/dev/.env" <<EOF
OPENWEBUI_HOST=0.0.0.0
OPENWEBUI_PORT=$DEV_PORT
OPENWEBUI_AUTH=$AUTH_ENABLED
OPENWEBUI_ALLOW_REGISTRATION=$ALLOW_REG
OPENWEBUI_LOG_LEVEL=debug
OPENAI_API_KEY=$OPENAI_DEV_KEY
OPENAI_API_BASE_URL=https://api.ai-mediator.ru/v1
OPENAI_MODEL=gpt-4
ENABLE_TELEMETRY=false
EOF

echo "✅ DEV .env written to $ROOT_PATH/dev/.env"

cat > "$ROOT_PATH/prod/.env" <<EOF
OPENWEBUI_HOST=0.0.0.0
OPENWEBUI_PORT=$PROD_PORT
OPENWEBUI_AUTH=$AUTH_ENABLED
OPENWEBUI_ALLOW_REGISTRATION=$ALLOW_REG
OPENWEBUI_LOG_LEVEL=info
OPENAI_API_KEY=$OPENAI_PROD_KEY
OPENAI_API_BASE_URL=https://api.ai-mediator.ru/v1
OPENAI_MODEL=gpt-4
ENABLE_TELEMETRY=false
EOF

echo "✅ PROD .env written to $ROOT_PATH/prod/.env"

cat > "$ROOT_PATH/dev/docker-compose.yml" <<EOF
version: '3.8'
services:
  openwebui:
    image: ghcr.io/open-webui/open-webui:main
    ports:
      - "${DEV_PORT}:${DEV_PORT}"
    env_file:
      - .env
    volumes:
      - openwebui-dev-data:/app/backend/data
    restart: always
volumes:
  openwebui-dev-data:
EOF

echo "✅ DEV docker-compose.yml written"

cat > "$ROOT_PATH/prod/docker-compose.yml" <<EOF
version: '3.8'
services:
  openwebui:
    image: ghcr.io/open-webui/open-webui:main
    ports:
      - "${PROD_PORT}:${PROD_PORT}"
    env_file:
      - .env
    volumes:
      - openwebui-prod-data:/app/backend/data
    restart: always
volumes:
  openwebui-prod-data:
EOF

echo "✅ PROD docker-compose.yml written"

echo "\nDone. You can now manually launch with:"
echo "  cd $ROOT_PATH/dev && docker compose up -d"
echo "  cd $ROOT_PATH/prod && docker compose up -d"
