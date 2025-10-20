#!/bin/bash

# Script de diagnostic pour Tempo sur Scalingo
# Usage: ./diagnose.sh

set -e

echo "🔍 Diagnostic Tempo sur Scalingo"
echo "==============================="

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

# Variables
APP_NAME="poc-trace"

echo "📋 Vérification de l'état de l'application..."

# 1. Vérifier le statut de l'application
log_step "Statut de l'application"
scalingo --app "$APP_NAME" ps

echo ""
log_step "Logs récents (dernières 20 lignes)"
scalingo --app "$APP_NAME" logs -n 20

echo ""
log_step "Logs d'erreur"
scalingo --app "$APP_NAME" logs -n 100 | grep -i "error\|failed\|panic" | tail -10

echo ""
log_step "Variables d'environnement"
scalingo --app "$APP_NAME" env

echo ""
log_step "Test de connectivité"
BASE_URL="https://poc-trace.osc-fr1.scalingo.io"

# Test de santé
echo "Test de l'endpoint /ready..."
if curl -s -f "$BASE_URL/ready" > /dev/null; then
    log_info "Endpoint /ready accessible"
else
    log_error "Endpoint /ready non accessible"
fi

# Test de l'API
echo "Test de l'endpoint principal..."
if curl -s -f "$BASE_URL/" > /dev/null; then
    log_info "Endpoint principal accessible"
else
    log_error "Endpoint principal non accessible"
fi

# Test des métriques
echo "Test de l'endpoint /metrics..."
if curl -s -f "$BASE_URL/metrics" | grep -q "tempo_"; then
    log_info "Métriques Tempo disponibles"
else
    log_warn "Métriques Tempo non disponibles"
fi

echo ""
echo "📊 Résumé du diagnostic:"
echo "======================="

# Vérifier si l'application est en cours d'exécution
if scalingo --app "$APP_NAME" ps | grep -q "web.*up"; then
    log_info "Application web en cours d'exécution"
else
    log_error "Application web non en cours d'exécution"
fi

if scalingo --app "$APP_NAME" ps | grep -q "tcp.*up"; then
    log_info "Application TCP Gateway en cours d'exécution"
else
    log_warn "Application TCP Gateway non en cours d'exécution"
fi

echo ""
echo "🔧 Actions recommandées:"
echo "1. Vérifier les logs pour des erreurs spécifiques"
echo "2. Redémarrer l'application si nécessaire"
echo "3. Vérifier la configuration Tempo"
echo "4. Tester les endpoints manuellement"

log_info "Diagnostic terminé !"
