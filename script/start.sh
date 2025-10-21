#!/bin/bash
set -euo pipefail

echo "🚀 Preparing environment..."

# ------------------------------------------------------------
# Directories needed by Tempo and NGINX
# ------------------------------------------------------------
mkdir -p /tmp/tempo-data/wal /tmp/tempo-data/blocks
touch /tmp/error.log /tmp/access.log

mkdir -p /app/nginx/body
mkdir -p /app/nginx/proxy
chmod -R 777 /app/nginx/proxy

echo "✅ Directories created"

# ------------------------------------------------------------
# Set NGINX port (Scalingo injecte $PORT)
# ------------------------------------------------------------
NGINX_PORT=${PORT:-8080}

# ------------------------------------------------------------
# Generate nginx.conf from template
# ------------------------------------------------------------
sed "s/{{PORT}}/$NGINX_PORT/" /app/nginx.template.conf > /app/nginx.conf

# ------------------------------------------------------------
# Start Tempo in background
# ------------------------------------------------------------
echo "🚀 Starting Tempo..."
tempo -config.expand-env=true -config.file=/app/tempo.yaml &
TEMPO_PID=$!

# Wait a few seconds for Tempo to initialize
sleep 2

# ------------------------------------------------------------
# Start NGINX as main foreground process
# ------------------------------------------------------------
echo "🚀 Starting NGINX proxy on port $NGINX_PORT..."
nginx -c /app/nginx.conf -g "daemon off;"

# ------------------------------------------------------------
# Wait for Tempo if NGINX exits
# ------------------------------------------------------------
wait $TEMPO_PID
