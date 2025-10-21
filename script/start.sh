#!/bin/sh
set -e

# Create data directories
mkdir -p /tmp/tempo-data/wal
mkdir -p /tmp/tempo-data/blocks

echo "🚀 Starting Tempo..."
tempo -config.expand-env=true -config.file=/app/tempo.yaml &
TEMPO_PID=$!

# Wait for Tempo to be ready
echo "⏳ Waiting for Tempo..."
sleep 5

echo "🚀 Starting NGINX..."
nginx -c /app/nginx.conf &
NGINX_PID=$!

# Keep script running and handle shutdown
trap "kill $TEMPO_PID $NGINX_PID 2>/dev/null" EXIT
wait