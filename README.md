# Tempo Buildpack for Scalingo

Ce buildpack permet de déployer [Tempo](https://grafana.com/oss/tempo/), un backend de traces distribué, sur Scalingo.

## Prérequis

- Un compte Scalingo
- L'[interface en ligne de commande Scalingo](https://doc.scalingo.com/platform/cli/start) installée

## Installation

1. Clonez le dépôt Tempo :
   ```bash
   git clone https://github.com/grafana/tempo.git
   cd tempo
   ```

2. Créez une nouvelle application sur Scalingo :
   ```bash
   scalingo create my-tempo-app
   ```

3. Configurez le buildpack pour votre application :
   ```bash
   scalingo env-set BUILDPACK_URL=https://github.com/your-username/tempo-buildpack.git
   ```

4. Configurez les variables d'environnement nécessaires :
   ```bash
   scalingo env-set TEMPO_CONFIG_FILE=/app/tempo.yaml
   ```

5. Déployez votre application :
   ```bash
   git push scalingo main
   ```

## Configuration

Vous pouvez personnaliser la configuration de Tempo en modifiant le fichier `tempo.yaml` à la racine de votre projet ou en définissant des variables d'environnement.

## Variables d'environnement

- `TEMPO_CONFIG_FILE`: Chemin vers le fichier de configuration Tempo (par défaut: `/app/tempo.yaml`)
- `PORT`: Port sur lequel Tempo écoute (par défaut: 3000)

## Personnalisation

Pour personnaliser la configuration de Tempo, créez un fichier `tempo.yaml` à la racine de votre projet ou modifiez le fichier dans `tempo-buildpack/opt/tempo.yaml`.

## Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus d'informations.
