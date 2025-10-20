#!/bin/bash

# Script de redémarrage forcé pour Tempo
# Usage: ./force-restart.sh

set -e

echo "🔄 Redémarrage forcé Tempo"
echo "========================="

# Variables
APP_NAME="poc-trace"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${BLUE}🔧 $1${NC}"
}

# 1. Arrêter complètement l'application
log_step "Arrêt complet de l'application..."
scalingo --app "$APP_NAME" scale web:0 tcp:0

# Attendre que l'application s'arrête complètement
sleep 15

# 2. Redémarrer l'application
log_step "Redémarrage de l'application..."
scalingo --app "$APP_NAME" scale web:1 tcp:1

# Attendre que l'application démarre
sleep 45

# 3. Vérifier le statut
log_step "Vérification du statut..."
scalingo --app "$APP_NAME" ps

# 4. Vérifier les logs récents
log_step "Vérification des logs récents..."
scalingo --app "$APP_NAME" logs -n 10

# 5. Test des endpoints
log_step "Test des endpoints..."
BASE_URL="https://poc-trace.osc-fr1.scalingo.io"

# Test de santé
echo "Test de l'endpoint /ready..."
if curl -s -f "$BASE_URL/ready" > /dev/null; then
    log_info "✅ Endpoint /ready accessible"
else
    log_error "❌ Endpoint /ready non accessible"
fi

# Test de l'API
echo "Test de l'endpoint principal..."
if curl -s -f "$BASE_URL/" > /dev/null; then
    log_info "✅ Endpoint principal accessible"
else
    log_error "❌ Endpoint principal non accessible"
fi

# Test des métriques
echo "Test de l'endpoint /metrics..."
if curl -s -f "$BASE_URL/metrics" | grep -q "tempo_"; then
    log_info "✅ Métriques Tempo disponibles"
else
    log_warn "⚠️  Métriques Tempo non disponibles"
fi

echo ""
log_info "Redémarrage forcé terminé !"
