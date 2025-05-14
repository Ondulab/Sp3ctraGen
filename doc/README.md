# Documentation de Sp3ctraGen

Bienvenue dans la documentation de Sp3ctraGen, une application de génération de spectrogrammes haute qualité basée sur Qt Quick.

## Présentation

Sp3ctraGen est un portage de l'application CISYNTH_App originale développée en SwiftUI. Elle permet de générer des spectrogrammes optimisés pour l'impression et la numérisation, avec un contrôle précis sur les paramètres de génération.

## Structure de la documentation

La documentation est organisée en plusieurs sections :

### Documentation utilisateur

- [Guide d'installation](guide_utilisateur/installation.md) - Instructions pour installer l'application
- [Guide de démarrage rapide](guide_utilisateur/prise_en_main.md) - Premiers pas avec Sp3ctraGen
- [Documentation des fonctionnalités](guide_utilisateur/fonctionnalites.md) - Description détaillée des fonctionnalités

### Documentation technique

- [Vue d'ensemble](vue_ensemble.md) - Vue d'ensemble du projet et de son architecture
- [Spécification du spectrogramme](technique/specification_spectrogramme.md) - Spécifications techniques détaillées
- [Bins par seconde](technique/description_bins_par_seconde.md) - Explication du paramètre Bins/s
- [Flux de données](technique/flux_donnees.md) - Description du flux de données dans l'application
- [Traitement du signal](technique/traitement_signal.md) - Détails sur les algorithmes de traitement du signal

### Documentation pour développeurs

- [Architecture](developpement/architecture.md) - Description de l'architecture du projet
- [Guide de débogage](developpement/debugging.md) - Guide pour déboguer l'application
- [Guide de style](developpement/guide_style.md) - Standards de code et conventions

## Prérequis

Pour compiler et exécuter cette application sur macOS, vous aurez besoin des éléments suivants:

1. **Qt 5.15 ou supérieur**
   ```bash
   brew install qt@5
   ```

2. **Bibliothèques de traitement du signal et d'image**
   ```bash
   brew install fftw cairo libsndfile
   ```

3. **Outils de développement**
   ```bash
   brew install bear # Optionnel, pour générer compile_commands.json
   ```

## Compilation

Vous pouvez compiler l'application de plusieurs façons:

### Avec les scripts fournis

Le projet inclut plusieurs scripts pour faciliter la compilation et l'exécution:

1. **scripts/build.sh**: Compile l'application
   ```bash
   scripts/build.sh
   ```

2. **scripts/run.sh**: Lance l'application
   ```bash
   scripts/run.sh
   ```

3. **scripts/debug.sh**: Lance l'application avec le débogueur
   ```bash
   scripts/debug.sh
   ```

### En ligne de commande

```bash
cd Sp3ctraGen
/opt/homebrew/opt/qt@5/bin/qmake -spec macx-clang CONFIG+=debug CONFIG+=qml_debug
make -j8
```

### Avec VSCode

1. Ouvrez le dossier `Sp3ctraGen` dans VSCode
2. Appuyez sur `Ctrl+Shift+B` ou sélectionnez `Terminal > Run Build Task...` pour lancer la compilation
3. La tâche par défaut exécutera `qmake` puis `make`

## Architecture

L'architecture du projet est basée sur une séparation claire entre:

1. **Interface utilisateur** (QML)
   - Interface principale et composants réutilisables
   - Constantes exposées via `QmlConstants`

2. **Logique métier** (C++)
   - `SpectrogramGenerator` (classe intermédiaire)
   - Stratégies de visualisation (Pattern Strategy)
   - Gestionnaires (`FileManager`, `PathManager`, `TaskManager`)

3. **Moteur de traitement** (C)
   - `spectral_generator.c` (moteur principal)
   - `spectral_fft.c` (traitement FFT)
   - `spectral_raster.c` et `spectral_vector.c` (génération d'images)

Pour une description détaillée de l'architecture, consultez le fichier [Architecture détaillée](developpement/architecture.md).

## Fonctionnalités principales

- Configuration des paramètres du spectrogramme
- Sélection des fichiers d'entrée/sortie
- Génération de spectrogrammes haute qualité (raster PNG et vectoriel PDF)
- Traitement multithreadé
- Interface utilisateur réactive avec composants réutilisables
- Prévisualisation du spectrogramme
- Visualisation de la forme d'onde audio
- Paramètres de filtrage avancés
- Optimisation pour l'impression et la numérisation

Pour plus de détails sur ces fonctionnalités, consultez la [documentation des fonctionnalités](guide_utilisateur/fonctionnalites.md).

## Dépannage

Pour résoudre les problèmes courants, veuillez consulter :

- [Guide de débogage](developpement/debugging.md) pour les problèmes de compilation et d'exécution
- [Guide d'installation](guide_utilisateur/installation.md) pour les problèmes d'installation
- [Bugs connus et limitations](technique/bugs_connus.md) pour les problèmes identifiés

## Contribution

Les contributions au projet sont les bienvenues. Veuillez consulter notre [guide de style](developpement/guide_style.md) pour les conventions de code et le processus de contribution.

## Licence

Sp3ctraGen est distribué sous licence [insérer licence]. Voir le fichier LICENSE pour plus de détails.
