#!/bin/bash

# Fonction pour obtenir la dernière version
get_latest_version() {
    # Récupère le dernier tag commençant par 'v' suivi de chiffres
    local latest_tag=$(git tag -l "v[0-9]*" --sort=-v:refname | head -n 1)
    
    if [ -z "$latest_tag" ]; then
        echo "0"
    else
        # Extrait le numéro de version (enlève le 'v' au début)
        echo "${latest_tag#v}"
    fi
}

# Obtenir la dernière version et incrémenter
LAST_VERSION=$(get_latest_version)
NEW_VERSION=$((LAST_VERSION + 1))
TAG_NAME="v$NEW_VERSION"

echo "🚀 Dernière version détectée: v$LAST_VERSION"
echo "🚀 Nouvelle version à déployer: $TAG_NAME"

# Vérifier s'il y a des modifications non commitées
if ! git diff-index --quiet HEAD --; then
    echo "⏳ Commit des modifications en cours..."
    git add .
    git commit -m "Préparation du déploiement $TAG_NAME"
fi

# Créer un tag pour la version
echo "🏷️  Création du tag $TAG_NAME..."
git tag -a "$TAG_NAME" -m "Version $TAG_NAME"

# Pousser les modifications et les tags
echo "📤 Envoi des modifications vers le dépôt distant..."
git push origin main

# Déploiement sur Scalingo
echo "☁️  Déploiement sur Scalingo..."
git push scalingo main

# Récupération des logs
echo "📋 Récupération des logs..."
scalingo --app poc-trace logs -n 1000 > "deploy_${TAG_NAME}_$(date +%Y%m%d_%H%M%S).log"

echo "✅ Déploiement de la version $TAG_NAME terminé avec succès !"