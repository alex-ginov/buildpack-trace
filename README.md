# Tempo Buildpack for Scalingo

Ce buildpack permet de déployer [Tempo](https://grafana.com/oss/tempo/), un backend de traces distribué, sur Scalingo.

## Fonctionnalités

- Installation automatique de Tempo
- Configuration optimisée pour Scalingo
- Support des protocoles OTLP (HTTP et gRPC)
- Gestion du stockage local des traces
- Génération de métriques à partir des traces

## Prérequis

- Un compte [Scalingo](https://scalingo.com/)
- L'[interface en ligne de commande Scalingo](https://doc.scalingo.com/platform/cli/start) installée
- Git pour gérer le dépôt

## Installation rapide

1. Créez un nouveau dépôt pour votre application Tempo :

   ```bash
   mkdir my-tempo-app
   cd my-tempo-app
   git init
   ```

2. Ajoutez ce dépôt comme sous-module :

   ```bash
   git submodule add https://github.com/your-username/tempo-buildpack.git .buildpacks/tempo
   ```

3. Créez une application sur Scalingo :

   ```bash
   scalingo create my-tempo-app
   ```

4. Configurez les buildpacks :

   ```bash
   scalingo env-set BUILDPACK_URL=https://github.com/Scalingo/multi-buildpack.git
   echo 'buildpacks = [
     { url = "https://github.com/Scalingo/multi-buildpack.git" }
   ]' > app.toml
   ```

5. Créez un fichier `.buildpacks` à la racine de votre projet :

   ```text
   file:///app/.buildpacks/tempo
   ```

6. Déployez votre application :

   ```bash
   git add .
   git commit -m "Initial commit"
   git push scalingo main
   ```

## Configuration

### Fichier de configuration

Le buildpack fournit une configuration par défaut dans `config/tempo.yaml`. Vous pouvez la personnaliser en créant votre propre fichier `config/tempo.yaml` à la racine de votre projet.

### Variables d'environnement

- `PORT`: Port d'écoute HTTP (obligatoire, défini automatiquement par Scalingo)
- `TEMPO_CONFIG_FILE`: Chemin vers le fichier de configuration (par défaut: `/app/config/tempo.yaml`)
- `TEMPO_VERSION`: Version de Tempo à installer (par défaut: "2.3.1")

### Stockage

Par défaut, les traces sont stockées localement dans `/app/storage`. Pour une utilisation en production, il est recommandé d'utiliser un stockage externe comme S3 ou GCS en configurant la section `storage` dans le fichier de configuration.

## Dépannage

### Voir les logs

```bash
scalingo logs -f
```

### Accéder au shell de l'application

```bash
scalingo run bash
```

### Vérifier la configuration

```bash
scalingo run /app/bin/tempo --config.file=/app/config/tempo.yaml --check-config
```

## Personnalisation avancée

### Utiliser une version spécifique de Tempo

Définissez la variable d'environnement `TEMPO_VERSION` avec la version souhaitée :

```bash
scalingo env-set TEMPO_VERSION=2.3.1
```

### Configurer le stockage externe

Modifiez la section `storage` dans votre fichier `config/tempo.yaml` pour utiliser un stockage externe. Par exemple, pour S3 :

```yaml
storage:
  trace:
    backend: s3
    s3:
      bucket: your-bucket-name
      endpoint: s3.region.amazonaws.com
      access_key: ${AWS_ACCESS_KEY_ID}
      secret_key: ${AWS_SECRET_ACCESS_KEY}
      region: your-region
```

## Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus d'informations.
