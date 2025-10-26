#!/bin/bash
set -euo pipefail

echo "🚀 Preparing environment..."

# ------------------------------------------------------------
# Directories needed by Tempo and NGINX
# ------------------------------------------------------------

mkdir -p /app/tempo-data/wal /app/tempo-data/traces

# --- NGINX DIRECTORIES dans app: Simplifié ---
mkdir -p /app/nginx
chmod -R 777 /app/nginx
mkdir -p /app/nginx/{body,tmp,fastcgi,uwsgi,scgi,logs}

# Créez les fichiers de logs.
touch /app/nginx/logs/error.log /app/nginx/logs/access.log


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