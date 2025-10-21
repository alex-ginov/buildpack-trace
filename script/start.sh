#!/bin/bash
set -euo pipefail

echo "🚀 Preparing environment..."

# ------------------------------------------------------------
# Directories needed by Tempo and NGINX
# ------------------------------------------------------------
mkdir -p /tmp/tempo-data/wal /tmp/tempo-data/blocks
touch /tmp/nginx_error.log
touch /tmp/nginx_access.log;


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
