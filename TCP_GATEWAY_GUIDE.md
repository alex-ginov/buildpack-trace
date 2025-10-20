# Guide TCP Gateway pour Tempo sur Scalingo

## 🎯 **Objectif**
Utiliser le TCP Gateway de Scalingo pour exposer les endpoints Tempo (traces + API) de manière optimale.

## 🔧 **Configuration TCP Gateway**

### 1. **Variables d'Environnement Requises**

```bash
# Variables essentielles pour TCP Gateway
scalingo --app poc-trace env-set \
    PORT=3200 \
    TCP_GRPC_PORT=4317 \
    TEMPO_VERSION=2.4.0
```

### 2. **Endpoints Disponibles**

Avec le TCP Gateway configuré, vous aurez :

#### **HTTP Endpoints (Port ${PORT})**
- **API Tempo** : `https://poc-trace.osc-fr1.scalingo.io/`
- **Health Check** : `https://poc-trace.osc-fr1.scalingo.io/ready`
- **Metrics** : `https://poc-trace.osc-fr1.scalingo.io/metrics`
- **Search API** : `https://poc-trace.osc-fr1.scalingo.io/api/search`

#### **gRPC Endpoints (Port ${TCP_GRPC_PORT})**
- **OTLP gRPC** : `poc-trace.osc-fr1.scalingo.io:4317`
- **Tempo gRPC** : `poc-trace.osc-fr1.scalingo.io:4317`

## 📡 **Utilisation des Endpoints**

### **1. Envoi de Traces (OTLP HTTP)**
```bash
# Endpoint pour l'envoi de traces
curl -X POST https://poc-trace.osc-fr1.scalingo.io/v1/traces \
  -H "Content-Type: application/json" \
  -d '{"resourceSpans": [...]}'
```

### **2. Envoi de Traces (OTLP gRPC)**
```javascript
// Configuration OpenTelemetry
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-grpc');

const exporter = new OTLPTraceExporter({
  url: 'https://poc-trace.osc-fr1.scalingo.io:4317',
  headers: {
    'Content-Type': 'application/grpc',
  },
});
```

### **3. Recherche de Traces**
```bash
# Recherche de traces
curl "https://poc-trace.osc-fr1.scalingo.io/api/search?tags=service.name=my-service"
```

### **4. Métriques Tempo**
```bash
# Métriques de Tempo
curl https://poc-trace.osc-fr1.scalingo.io/metrics
```

## 🔍 **Configuration Client**

### **Node.js avec OpenTelemetry**
```javascript
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: 'https://poc-trace.osc-fr1.scalingo.io/v1/traces',
  }),
});

sdk.start();
```

### **Python avec OpenTelemetry**
```python
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Configuration
otlp_exporter = OTLPSpanExporter(
    endpoint="https://poc-trace.osc-fr1.scalingo.io:4317",
    insecure=False,
)

trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

span_processor = BatchSpanProcessor(otlp_exporter)
trace.get_tracer_provider().add_span_processor(span_processor)
```

## 🚀 **Déploiement et Test**

### **1. Déployer la Configuration**
```bash
cd scalingo/POC/tempo-buildpack
git add .
git commit -m "Fix: TCP Gateway configuration"
git push scalingo main
```

### **2. Vérifier le Démarrage**
```bash
# Vérifier les logs
scalingo --app poc-trace logs -f

# Vérifier l'endpoint de santé
curl https://poc-trace.osc-fr1.scalingo.io/ready
```

### **3. Tester les Endpoints**
```bash
# Test de l'API Tempo
curl https://poc-trace.osc-fr1.scalingo.io/

# Test des métriques
curl https://poc-trace.osc-fr1.scalingo.io/metrics

# Test de recherche
curl "https://poc-trace.osc-fr1.scalingo.io/api/search"
```

## 🔧 **Configuration Grafana**

### **Data Source Tempo**
```yaml
# Configuration dans Grafana
url: https://poc-trace.osc-fr1.scalingo.io
auth:
  noAuth: true
```

### **Configuration Prometheus pour Tempo**
```yaml
# Dans prometheus.yml
- job_name: 'tempo'
  static_configs:
    - targets: ['poc-trace.osc-fr1.scalingo.io']
  metrics_path: /metrics
  scheme: https
```

## 📊 **Monitoring et Debugging**

### **Métriques Clés à Surveiller**
- `tempo_distributor_spans_received_total`
- `tempo_ingester_traces_created_total`
- `tempo_querier_queries_total`
- `tempo_compactor_blocks_compacted_total`

### **Logs de Debug**
```bash
# Vérifier les erreurs de connexion
scalingo --app poc-trace logs | grep -i error

# Vérifier les connexions gRPC
scalingo --app poc-trace logs | grep -i grpc
```

## 🎯 **Avantages du TCP Gateway**

1. **Double Exposition** : HTTP + gRPC sur des ports différents
2. **Sécurité** : HTTPS automatique pour HTTP
3. **Performance** : gRPC pour les traces, HTTP pour l'API
4. **Compatibilité** : Support des clients OTLP standard

## 🚨 **Dépannage**

### **Erreur : Connection Refused**
```bash
# Vérifier que le TCP Gateway est actif
scalingo --app poc-trace env-get TCP_GRPC_PORT

# Vérifier les ports
scalingo --app poc-trace logs | grep -i port
```

### **Erreur : Frontend Not Found**
```bash
# Vérifier la configuration du querier
scalingo --app poc-trace run "cat /app/config/tempo.yaml | grep querier"
```

### **Erreur : OTLP Rejected**
```bash
# Vérifier les récepteurs
scalingo --app poc-trace logs | grep -i otlp
```

## 📝 **Notes Importantes**

1. **Ports** : HTTP sur `${PORT}`, gRPC sur `${TCP_GRPC_PORT}`
2. **Sécurité** : HTTPS automatique sur Scalingo
3. **Performance** : gRPC plus rapide pour les traces
4. **Compatibilité** : Support OpenTelemetry standard
