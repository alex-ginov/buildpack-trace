#!/bin/bash
set -euo pipefail

echo "🚀 Preparing environment..."

# Directories
mkdir -p /app/bin
mkdir -p /app/nginx/{body,tmp,logs}
touch /app/nginx/logs/{access,error}.log
chmod -R 777 /app/nginx

# Jaeger download
JAEGER_VER="1.60.0"
JAEGER_BIN="/app/bin/jaeger-all-in-one"

if [ ! -f "$JAEGER_BIN" ]; then
    wget -q https://github.com/jaegertracing/jaeger/releases/download/v$JAEGER_VER/jaeger-$JAEGER_VER-linux-amd64.tar.gz -O /tmp/jaeger.tar.gz
    tar -xzf /tmp/jaeger.tar.gz -C /tmp
    mv /tmp/jaeger-$JAEGER_VER-linux-amd64/jaeger-all-in-one $JAEGER_BIN
    chmod +x $JAEGER_BIN
fi

# NGINX port
NGINX_PORT=${PORT:-8080}

# Generate nginx.conf
cat > /app/nginx.conf <<EOL
pid /tmp/nginx.pid;
error_log /app/nginx/logs/error.log;
worker_processes auto;

events { worker_connections 1024; }

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

        location / {
            proxy_pass http://jaeger_ui/;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        location /api/traces {
            proxy_pass http://jaeger_collector/api/traces;
        }

        location /v1/traces {
            proxy_pass http://jaeger_otlp/v1/traces;
        }
    }
}
EOL

# Start Jaeger
$JAEGER_BIN \
  --http-server.host-port=:16686 \
  --collector.otlp.http.host-port=:4318 \
  --query.http-server.host-port=:16686 &
JAEGER_PID=$!

sleep 3

# Start NGINX
nginx -c /app/nginx.conf -g "daemon off;"

wait $JAEGER_PID
