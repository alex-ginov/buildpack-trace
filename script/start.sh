#!/bin/bash
set -euo pipefail

echo "🚀 Preparing environment..."

# ------------------------------------------------------------
# Directories needed by Jaeger and NGINX
# ------------------------------------------------------------
mkdir -p /app/bin
mkdir -p /app/nginx/{body,tmp,fastcgi,uwsgi,scgi,logs}

# Create log files
touch /app/nginx/logs/error.log /app/nginx/logs/access.log
chmod -R 777 /app/nginx

# ------------------------------------------------------------
# Install Jaeger All-in-One (if not already present)
# ------------------------------------------------------------
JAEGER_VERSION="1.60.0"
JAEGER_BIN="/app/bin/jaeger-all-in-one"

if [ ! -f "$JAEGER_BIN" ]; then
    echo "🚀 Downloading Jaeger $JAEGER_VERSION..."
    wget -q https://github.com/jaegertracing/jaeger/releases/download/v$JAEGER_VERSION/jaeger-$JAEGER_VERSION-linux-amd64.tar.gz -O /tmp/jaeger.tar.gz
    tar -xzf /tmp/jaeger.tar.gz -C /tmp
    mv /tmp/jaeger-$JAEGER_VERSION-linux-amd64/jaeger-all-in-one $JAEGER_BIN
    chmod +x $JAEGER_BIN
    echo "✅ Jaeger installed at $JAEGER_BIN"
fi

# ------------------------------------------------------------
# Generate nginx.conf
# ------------------------------------------------------------
NGINX_PORT=${PORT:-8080}
cat > /app/nginx.conf <<EOL
user root;
pid /tmp/nginx.pid;

error_log /app/nginx/logs/error.log;
worker_processes auto;

events {
    worker_connections 1024;
}

http {
    include /app/mime.types;
    default_type application/octet-stream;

    access_log /app/nginx/logs/access.log;

    client_body_temp_path /app/nginx/body;
    proxy_temp_path /app/nginx/tmp;
    fastcgi_temp_path /app/nginx/tmp;
    uwsgi_temp_path /app/nginx/tmp;
    scgi_temp_path /app/nginx/tmp;

    sendfile on;
    keepalive_timeout 65;
    client_max_body_size 10M;

    upstream jaeger_ui    { server 127.0.0.1:16686; }
    upstream jaeger_collector { server 127.0.0.1:14268; }
    upstream jaeger_otlp  { server 127.0.0.1:4318; }

    server {
        listen $NGINX_PORT;
        server_name _;

        # Jaeger UI
        location / {
            proxy_pass http://jaeger_ui/;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Jaeger Collector (HTTP Thrift)
        location /api/traces {
            proxy_pass http://jaeger_collector/api/traces;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # OTLP endpoint (HTTP)
        location /v1/traces {
            proxy_pass http://jaeger_otlp/v1/traces;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }
}
EOL

echo "✅ NGINX config generated"

# ------------------------------------------------------------
# Start Jaeger in background
# ------------------------------------------------------------
echo "🚀 Starting Jaeger..."
$JAEGER_BIN --collector.zipkin.http-port=9411 &
JAEGER_PID=$!

# Give Jaeger a few seconds to start
sleep 3

# ------------------------------------------------------------
# Start NGINX as main foreground process
# ------------------------------------------------------------
echo "🚀 Starting NGINX on port $NGINX_PORT..."
nginx -c /app/nginx.conf -g "daemon off;"

# Wait for Jaeger if NGINX exits
wait $JAEGER_PID
