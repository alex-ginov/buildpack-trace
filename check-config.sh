#!/bin/bash

# Script de vérification simple pour la configuration Tempo

echo "🔍 VÉRIFICATION DE LA CONFIGURATION"
echo "===================================="

# 1. Vérifier les fichiers essentiels
echo "📁 Vérification des fichiers..."
if [ -f "config/tempo.yaml" ]; then
    echo "✅ config/tempo.yaml - OK"
else
    echo "❌ config/tempo.yaml - MANQUANT"
fi

if [ -f "bin/start-tempo" ]; then
    echo "✅ bin/start-tempo - OK"
else
    echo "❌ bin/start-tempo - MANQUANT"
fi

if [ -f "bin/start-tempo-grpc" ]; then
    echo "✅ bin/start-tempo-grpc - OK"
else
    echo "❌ bin/start-tempo-grpc - MANQUANT"
fi

if [ -f "Procfile" ]; then
    echo "✅ Procfile - OK"
else
    echo "❌ Procfile - MANQUANT"
fi

# 2. Vérifier le contenu de tempo.yaml
echo ""
echo "📋 Vérification du contenu de tempo.yaml..."

# Vérifier les sections principales
if grep -q "server:" config/tempo.yaml; then
    echo "✅ Section 'server' - OK"
else
    echo "❌ Section 'server' - MANQUANTE"
fi

if grep -q "storage:" config/tempo.yaml; then
    echo "✅ Section 'storage' - OK"
else
    echo "❌ Section 'storage' - MANQUANTE"
fi

if grep -q "distributor:" config/tempo.yaml; then
    echo "✅ Section 'distributor' - OK"
else
    echo "❌ Section 'distributor' - MANQUANTE"
fi

if grep -q "compactor:" config/tempo.yaml; then
    echo "✅ Section 'compactor' - OK"
else
    echo "❌ Section 'compactor' - MANQUANTE"
fi

# Vérifier les variables d'environnement
if grep -q "\${PORT}" config/tempo.yaml; then
    echo "✅ Variable \${PORT} - OK"
else
    echo "⚠️  Variable \${PORT} - NON UTILISÉE"
fi

if grep -q "\${TCP_GRPC_PORT:-4317}" config/tempo.yaml; then
    echo "✅ Variable \${TCP_GRPC_PORT:-4317} - OK"
else
    echo "⚠️  Variable \${TCP_GRPC_PORT:-4317} - NON UTILISÉE"
fi

# 3. Vérifier les scripts
echo ""
echo "🔧 Vérification des scripts..."

if grep -q "exec.*tempo" bin/start-tempo; then
    echo "✅ Script start-tempo - OK"
else
    echo "❌ Script start-tempo - PROBLÈME"
fi

if grep -q "exec.*tempo" bin/start-tempo-grpc; then
    echo "✅ Script start-tempo-grpc - OK"
else
    echo "❌ Script start-tempo-grpc - PROBLÈME"
fi

# 4. Vérifier le Procfile
echo ""
echo "📄 Vérification du Procfile..."

if grep -q "web:" Procfile; then
    echo "✅ Processus 'web' - OK"
else
    echo "❌ Processus 'web' - MANQUANT"
fi

if grep -q "tcp:" Procfile; then
    echo "✅ Processus 'tcp' - OK"
else
    echo "❌ Processus 'tcp' - MANQUANT"
fi

# 5. Afficher le contenu de la configuration
echo ""
echo "📄 Contenu de la configuration tempo.yaml:"
echo "=========================================="
cat config/tempo.yaml

echo ""
echo "📄 Contenu du Procfile:"
echo "======================"
cat Procfile

echo ""
echo "📄 Contenu du script start-tempo:"
echo "================================="
cat bin/start-tempo

echo ""
echo "📄 Contenu du script start-tempo-grpc:"
echo "======================================"
cat bin/start-tempo-grpc

echo ""
echo "✅ Vérification terminée !"
echo ""
echo "🚀 Si tout est OK, vous pouvez déployer avec:"
echo "   git add ."
echo "   git commit -m 'FIX: Valid Tempo configuration'"
echo "   git push scalingo main"
