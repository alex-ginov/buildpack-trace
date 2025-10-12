#!/bin/bash

set -e

# Définition des chemins
TEMPO_BIN_DIR=$1
TEMPO_CONFIG_DIR=$2

# Vérification de l'existence des binaires
if [ ! -f "$TEMPO_BIN_DIR/tempo" ]; then
  echo "Erreur: Le binaire Tempo n'a pas été trouvé dans $TEMPO_BIN_DIR"
  exit 1
fi

# Vérification de la configuration
if [ ! -f "$TEMPO_CONFIG_DIR/tempo.yaml" ]; then
  echo "Erreur: Le fichier de configuration tempo.yaml est introuvable dans $TEMPO_CONFIG_DIR"
  exit 1
fi

# Exécution de Tempo
echo "Démarrage de Tempo avec la configuration de $TEMPO_CONFIG_DIR/tempo.yaml"
cd "$TEMPO_BIN_DIR"
exec "./tempo" --config.file="$TEMPO_CONFIG_DIR/tempo.yaml"
