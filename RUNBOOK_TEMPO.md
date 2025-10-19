# Runbook Tempo avec TCP Gateway sur Scalingo

## Architecture

```mermaid
graph TD
    A[Client] -->|OTLP/HTTP :4318| B[TCP Gateway]
    A -->|OTLP/gRPC :4317| B
    B -->|HTTP :4318| C[Tempo OTLP HTTP]
    B -->|gRPC :4317| D[Tempo OTLP gRPC]
    B -->|HTTP :${PORT}| E[Tempo Web UI/API]
    
    C --> F[(Stockage Local)]
    D --> F
    E --> F
```

## Configuration des Ports

| Service | Port | Protocole | Description |
|---------|------|-----------|-------------|
| Web UI/API | ${PORT} | HTTP | Interface utilisateur et API REST |
| OTLP HTTP | 4318 | HTTP | Réception des traces OTLP sur HTTP |
| OTLP gRPC | 4317 | gRPC | Réception des traces OTLP sur gRPC |

## Fichier de Configuration (tempo.yaml)

```yaml
server:
  http_listen_address: "0.0.0.0"
  http_listen_port: ${PORT}

storage:
  trace:
    backend: local
    local:
      path: /tmp/tempo-data/blocks
    wal:
      path: /tmp/tempo-data/wal

distributor:
  receivers:
    otlp:
      protocols:
        http:
          endpoint: "0.0.0.0:4318"
        grpc:
          endpoint: "0.0.0.0:4317"

query_frontend:
  trace:
    pool_max_idle_streams: 100

compactor:
  compaction:
    block_retention: 24h
    compacted_block_retention: 1h
```

## Fichier Procfile

```plaintext
web: /app/bin/start-tempo
http-receiver: /app/bin/start-tempo-http
grpc-receiver: /app/bin/start-tempo-grpc
```

## Scripts de Démarrage

### 1. bin/start-tempo (Web UI/API)
```bash
#!/bin/bash
set -e
exec /app/bin/tempo \
  --config.file=/app/config/tempo.yaml \
  --config.expand-env=true \
  --target=query-frontend \
  --server.http-listen-address=0.0.0.0 \
  --server.http-listen-port=${PORT}
```

### 2. bin/start-tempo-http (OTLP HTTP Receiver)
```bash
#!/bin/bash
set -e
exec /app/bin/tempo \
  --config.file=/app/config/tempo.yaml \
  --target=all \
  --server.http-listen-address=0.0.0.0 \
  --server.http-listen-port=4318 \
  --server.grpc-listen-address=""
```

### 3. bin/start-tempo-grpc (OTLP gRPC Receiver)
```bash
#!/bin/bash
set -e
exec /app/bin/tempo \
  --config.file=/app/config/tempo.yaml \
  --target=all \
  --server.grpc-listen-address=0.0.0.0 \
  --server.grpc-listen-port=4317 \
  --server.http-listen-address=""
```

## Déploiement sur Scalingo

1. **Ajouter le TCP Gateway** :
   ```bash
   scalingo --app votre-app addons-add tcp-gateway
   ```

2. **Configurer les variables d'environnement** :
   ```bash
   scalingo --app votre-app env-set \
     TEMPO_HTTP_PORT=4318 \
     TEMPO_GRPC_PORT=4317
   ```

3. **Déployer l'application** :
   ```bash
   git add .
   git commit -m "Configuration Tempo avec TCP Gateway"
   git push scalingo main
   ```

## Dépannage

### Vérifier les logs
```bash
scalingo --app votre-app logs
```

### Vérifier les variables d'environnement
```bash
scalingo --app votre-app env
```

### Tester la réception de traces

#### HTTP
```bash
curl -X POST http://votre-app.osc-fr1.scalingo.io:4318/v1/traces \
  -H "Content-Type: application/json" \
  -d @trace.json
```

#### gRPC (avec grpcurl)
```bash
grpcurl -plaintext -d @ \
  -import-path ./proto \
  -proto opentelemetry/proto/collector/trace/v1/trace_service.proto \
  -proto opentelemetry/proto/trace/v1/trace.proto \
  -proto opentelemetry/proto/common/v1/common.proto \
  -proto opentelemetry/proto/resource/v1/resource.proto \
  votre-app.osc-fr1.scalingo.io:4317 \
  opentelemetry.proto.collector.trace.v1.TraceService/Export \
  < trace.json
```

## Notes Importantes

1. **Stockage** : Le stockage local dans `/tmp` est éphémère. Pour la production, envisagez un stockage persistant.
2. **Sécurité** : Les ports TCP sont exposés publiquement. Ajoutez une authentification si nécessaire.
3. **Performance** : Surveillez l'utilisation des ressources et ajustez la configuration selon vos besoins.
4. **Rétention** : La rétention est configurée pour 24h. Ajustez selon vos besoins en stockage.
