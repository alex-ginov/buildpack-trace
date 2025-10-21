#!/bin/bash
set -ex

# Dossiers temporaires (Tempo storage)
mkdir -p /tmp/tempo-data/{wal,blocks}

# Lancer Tempo en arrière-plan
echo "🚀 Starting Tempo..."
tempo -config.expand-env=true -config.file=/app/tempo.yaml &

# Attendre un court instant pour que Tempo démarre
sleep 2

# Lancer NGINX au premier plan (obligatoire pour Scalingo)
echo "🚀 Starting NGINX proxy..."
nginx -c /app/nginx.conf
