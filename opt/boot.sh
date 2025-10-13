#!/bin/bash
set -e

# Configuration par défaut
TEMPO_CONFIG=${TEMPO_CONFIG:-"/app/config/tempo.yaml"}
TEMPO_ARGS=${TEMPO_ARGS:-""}

# Afficher les informations de débogage
echo "-----> Starting Tempo with config: $TEMPO_CONFIG"
echo "-----> Current directory: $(pwd)"
echo "-----> Contents of /app/bin/:"
ls -la /app/bin/

# Vérifier si le binaire Tempo existe
if [ ! -f "/app/bin/tempo" ]; then
  echo "Error: Tempo binary not found in /app/bin/" >&2
  exit 1
fi

# Vérifier si le fichier de configuration existe
if [ ! -f "$TEMPO_CONFIG" ]; then
  echo "Error: Configuration file $TEMPO_CONFIG not found" >&2
  exit 1
fi

# Démarrer Tempo
echo "-----> Launching Tempo..."
exec /app/bin/tempo --config.file="$TEMPO_CONFIG" $TEMPO_ARGS