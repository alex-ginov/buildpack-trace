#!/bin/bash
set -euo pipefail

echo "🚀 Preparing environment..."

# ------------------------------------------------------------
# Directories needed by Tempo and NGINX
# ------------------------------------------------------------
mkdir -p /tmp/tempo-data/wal /tmp/tempo-data/blocks
touch /tmp/error.log
touch /tmp/access.log;


# Remplacer le port dans nginx.conf
NGINX_PORT=${PORT:-8080}
sed -i "s/listen <%= ENV\['PORT'\] %>/listen ${NGINX_PORT}/" /app/nginx.conf

echo "✅ Directories created (if missing)"

# ------------------------------------------------------------
# Start Tempo
# ------------------------------------------------------------
echo "🚀 Starting Tempo..."
tempo -config.expand-env=true -config.file=/app/tempo.yaml &
TEMPO_PID=$!

# Wait a bit for Tempo to initialize
sleep 2

# ------------------------------------------------------------
# Start NGINX as main foreground process
# ------------------------------------------------------------
echo "🚀 Starting NGINX proxy..."
nginx -c /app/nginx.conf

# ------------------------------------------------------------
# Wait for Tempo background process (if NGINX exits)
# ------------------------------------------------------------
wait $TEMPO_PID
