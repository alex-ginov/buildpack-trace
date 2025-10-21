#!/bin/bash
set -ex

# Create data directories
mkdir -p /tmp/tempo-data/{wal,blocks}

# Start Tempo
echo "🚀 Starting Tempo..."
exec tempo -config.expand-env=true -config.file=/app/tempo.yaml