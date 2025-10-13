#!/bin/bash
set -e

# Configuration par défaut
TEMPO_CONFIG=${TEMPO_CONFIG:-"/app/config/tempo.yaml"}
TEMPO_ARGS=${TEMPO_ARGS:-""}

# Vérifier si le fichier de configuration existe
if [ ! -f "$TEMPO_CONFIG" ]; then
  echo "Erreur: Le fichier de configuration $TEMPO_CONFIG n'existe pas." >&2
  exit 1
fi

# Démarrer Tempo
exec /app/bin/tempo --config.file="$TEMPO_CONFIG" $TEMPO_ARGS