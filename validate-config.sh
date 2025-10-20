#!/bin/bash

# Script de validation de la configuration Tempo
# Vérifie la syntaxe YAML et la compatibilité

set -e

echo "🔍 VALIDATION DE LA CONFIGURATION TEMPO"
echo "======================================="

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 1. Vérifier l'existence des fichiers
log_step "Vérification des fichiers..."

if [ -f "config/tempo.yaml" ]; then
    log_info "✅ config/tempo.yaml existe"
else
    log_error "❌ config/tempo.yaml manquant"
    exit 1
fi

if [ -f "bin/start-tempo" ]; then
    log_info "✅ bin/start-tempo existe"
else
    log_error "❌ bin/start-tempo manquant"
    exit 1
fi

if [ -f "bin/start-tempo-grpc" ]; then
    log_info "✅ bin/start-tempo-grpc existe"
else
    log_error "❌ bin/start-tempo-grpc manquant"
    exit 1
fi

if [ -f "Procfile" ]; then
    log_info "✅ Procfile existe"
else
    log_error "❌ Procfile manquant"
    exit 1
fi

# 2. Vérifier la syntaxe YAML
log_step "Vérification de la syntaxe YAML..."

# Test avec Python pour valider la syntaxe YAML
if python3 -c "import yaml; yaml.safe_load(open('config/tempo.yaml'))" 2>/dev/null; then
    log_info "✅ Syntaxe YAML valide"
else
    log_error "❌ Erreur de syntaxe YAML"
    echo "Détails de l'erreur :"
    python3 -c "import yaml; yaml.safe_load(open('config/tempo.yaml'))" 2>&1 || true
    exit 1
fi

# 3. Vérifier le contenu de la configuration
log_step "Vérification du contenu de la configuration..."

# Vérifier les champs obligatoires
if grep -q "server:" config/tempo.yaml; then
    log_info "✅ Section 'server' présente"
else
    log_error "❌ Section 'server' manquante"
fi

if grep -q "storage:" config/tempo.yaml; then
    log_info "✅ Section 'storage' présente"
else
    log_error "❌ Section 'storage' manquante"
fi

if grep -q "distributor:" config/tempo.yaml; then
    log_info "✅ Section 'distributor' présente"
else
    log_error "❌ Section 'distributor' manquante"
fi

# Vérifier les variables d'environnement
if grep -q "\${PORT}" config/tempo.yaml; then
    log_info "✅ Variable \${PORT} utilisée"
else
    log_warn "⚠️  Variable \${PORT} non utilisée"
fi

if grep -q "\${TCP_GRPC_PORT:-4317}" config/tempo.yaml; then
    log_info "✅ Variable \${TCP_GRPC_PORT:-4317} utilisée"
else
    log_warn "⚠️  Variable \${TCP_GRPC_PORT:-4317} non utilisée"
fi

# 4. Vérifier les scripts de démarrage
log_step "Vérification des scripts de démarrage..."

# Vérifier que les scripts sont exécutables
if [ -x "bin/start-tempo" ]; then
    log_info "✅ bin/start-tempo est exécutable"
else
    log_warn "⚠️  bin/start-tempo n'est pas exécutable"
fi

if [ -x "bin/start-tempo-grpc" ]; then
    log_info "✅ bin/start-tempo-grpc est exécutable"
else
    log_warn "⚠️  bin/start-tempo-grpc n'est pas exécutable"
fi

# Vérifier le contenu des scripts
if grep -q "exec.*tempo" bin/start-tempo; then
    log_info "✅ Script start-tempo contient la commande tempo"
else
    log_error "❌ Script start-tempo ne contient pas la commande tempo"
fi

if grep -q "exec.*tempo" bin/start-tempo-grpc; then
    log_info "✅ Script start-tempo-grpc contient la commande tempo"
else
    log_error "❌ Script start-tempo-grpc ne contient pas la commande tempo"
fi

# 5. Vérifier le Procfile
log_step "Vérification du Procfile..."

if grep -q "web:" Procfile; then
    log_info "✅ Processus 'web' défini dans Procfile"
else
    log_error "❌ Processus 'web' manquant dans Procfile"
fi

if grep -q "tcp:" Procfile; then
    log_info "✅ Processus 'tcp' défini dans Procfile"
else
    log_error "❌ Processus 'tcp' manquant dans Procfile"
fi

# 6. Vérifier les permissions
log_step "Vérification des permissions..."

# Rendre les scripts exécutables si nécessaire
chmod +x bin/start-tempo 2>/dev/null || true
chmod +x bin/start-tempo-grpc 2>/dev/null || true

log_info "✅ Permissions des scripts mises à jour"

# 7. Résumé de la validation
echo ""
echo "📊 Résumé de la validation:"
echo "=========================="

# Compter les erreurs
ERRORS=0
WARNINGS=0

# Vérifier les erreurs critiques
if ! grep -q "server:" config/tempo.yaml; then
    ((ERRORS++))
fi

if ! grep -q "storage:" config/tempo.yaml; then
    ((ERRORS++))
fi

if ! grep -q "distributor:" config/tempo.yaml; then
    ((ERRORS++))
fi

if [ $ERRORS -eq 0 ]; then
    log_info "✅ Configuration valide - Prêt pour le déploiement"
    echo ""
    echo "🚀 Actions recommandées:"
    echo "1. git add ."
    echo "2. git commit -m 'FIX: Valid Tempo configuration'"
    echo "3. git push scalingo main"
else
    log_error "❌ $ERRORS erreur(s) critique(s) détectée(s)"
    echo "Veuillez corriger les erreurs avant de déployer"
fi

echo ""
log_info "Validation terminée !"
