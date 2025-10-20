#!/bin/bash

# Script de test pour le TCP Gateway Tempo
# Usage: ./test-tcp-gateway.sh

set -e

echo "🧪 Test du TCP Gateway Tempo"
echo "=========================="

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour logger
log_info() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_test() {
    echo -e "${BLUE}🧪 $1${NC}"
}

# Variables
APP_NAME="poc-trace"
BASE_URL="https://poc-trace.osc-fr1.scalingo.io"

echo "📋 Vérification des variables d'environnement..."

# Vérifier les variables d'environnement
check_env_var() {
    local var=$1
    echo -n "Variable $var... "
    
    if scalingo --app "$APP_NAME" env-get "$var" > /dev/null 2>&1; then
        local value=$(scalingo --app "$APP_NAME" env-get "$var")
        log_info "$var = $value"
    else
        log_error "$var non configurée"
        return 1
    fi
}

check_env_var "PORT"
check_env_var "TCP_GRPC_PORT"
check_env_var "TEMPO_VERSION"

echo ""
echo "🌐 Test des endpoints HTTP..."

# Test de l'endpoint de santé
test_health() {
    log_test "Test de l'endpoint /ready"
    
    if curl -s -f "$BASE_URL/ready" > /dev/null; then
        log_info "Endpoint /ready accessible"
    else
        log_error "Endpoint /ready non accessible"
        return 1
    fi
}

# Test de l'endpoint principal
test_main() {
    log_test "Test de l'endpoint principal"
    
    if curl -s -f "$BASE_URL/" > /dev/null; then
        log_info "Endpoint principal accessible"
    else
        log_error "Endpoint principal non accessible"
        return 1
    fi
}

# Test des métriques
test_metrics() {
    log_test "Test de l'endpoint /metrics"
    
    if curl -s -f "$BASE_URL/metrics" | grep -q "tempo_"; then
        log_info "Métriques Tempo disponibles"
    else
        log_warn "Métriques Tempo non disponibles"
    fi
}

# Test de l'API de recherche
test_search() {
    log_test "Test de l'API de recherche"
    
    if curl -s -f "$BASE_URL/api/search" > /dev/null; then
        log_info "API de recherche accessible"
    else
        log_warn "API de recherche non accessible"
    fi
}

# Test d'envoi de trace (simulation)
test_trace_send() {
    log_test "Test d'envoi de trace (simulation)"
    
    # Créer une trace de test simple
    local trace_data='{
        "resourceSpans": [{
            "resource": {
                "attributes": [{
                    "key": "service.name",
                    "value": {"stringValue": "test-service"}
                }]
            },
            "scopeSpans": [{
                "spans": [{
                    "traceId": "12345678901234567890123456789012",
                    "spanId": "1234567890123456",
                    "name": "test-span",
                    "startTimeUnixNano": "'$(date +%s)000000000'",
                    "endTimeUnixNano": "'$(date +%s)000000000'",
                    "status": {"code": "STATUS_CODE_OK"}
                }]
            }]
        }]
    }'
    
    if curl -s -X POST "$BASE_URL/v1/traces" \
        -H "Content-Type: application/json" \
        -d "$trace_data" > /dev/null; then
        log_info "Envoi de trace réussi"
    else
        log_warn "Envoi de trace échoué"
    fi
}

# Exécuter les tests
test_health
test_main
test_metrics
test_search
test_trace_send

echo ""
echo "🔍 Vérification des logs Tempo..."

# Vérifier les logs pour des erreurs
check_logs() {
    log_test "Vérification des logs pour erreurs"
    
    local error_count=$(scalingo --app "$APP_NAME" logs -n 50 | grep -i "error" | wc -l)
    
    if [ "$error_count" -eq 0 ]; then
        log_info "Aucune erreur dans les logs récents"
    else
        log_warn "$error_count erreurs trouvées dans les logs"
        echo "Dernières erreurs :"
        scalingo --app "$APP_NAME" logs -n 20 | grep -i "error" | tail -5
    fi
}

check_logs

echo ""
echo "📊 Résumé des tests :"
echo "===================="

# Test final de connectivité
log_test "Test final de connectivité"

if curl -s -f "$BASE_URL/ready" > /dev/null && \
   curl -s -f "$BASE_URL/" > /dev/null; then
    log_info "✅ TCP Gateway fonctionnel"
    echo ""
    echo "🎯 Endpoints disponibles :"
    echo "  - API Tempo: $BASE_URL/"
    echo "  - Health: $BASE_URL/ready"
    echo "  - Metrics: $BASE_URL/metrics"
    echo "  - Search: $BASE_URL/api/search"
    echo "  - OTLP HTTP: $BASE_URL/v1/traces"
    echo "  - OTLP gRPC: poc-trace.osc-fr1.scalingo.io:4317"
else
    log_error "❌ TCP Gateway non fonctionnel"
    echo ""
    echo "🔧 Actions recommandées :"
    echo "  1. Vérifier les variables d'environnement"
    echo "  2. Redémarrer l'application"
    echo "  3. Vérifier les logs pour erreurs"
fi

echo ""
log_info "Test terminé !"
