#!/bin/bash
set -euo pipefail

echo "🚀 Preparing environment..."

# ------------------------------------------------------------
# Directories needed by Tempo and NGINX
# ------------------------------------------------------------
mkdir -p /tmp/tempo-data/wal /tmp/tempo-data/blocks

# --- NEW NGINX DIRECTORIES dans app---
mkdir -p /app/nginx/{body,tmp,fastcgi,uwsgi,scgi,logs}
chmod -R 777 /app/nginx
touch /app/nginx/logs/error.log /app/nginx/logs/access.log
chmod -R 777 /var/log/
mkdir -p /var/log/nginx/
touch /var/log/nginx/error.log" /var/log/nginx/acces.log"

# Assurez-vous que les permissions sont maximales (pour le test)
chmod -R 777 /app/nginx/logs /app/nginx/tmp /app/nginx/body


# Avant le démarrage de NGINX, ajoutez :
echo "🚀 Creating NGINX required directories..."

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