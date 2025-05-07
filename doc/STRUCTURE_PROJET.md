# Structure du projet SpectroGen

Ce document décrit la structure du projet SpectroGen après les améliorations d'organisation.

## Organisation des dossiers

Le projet est maintenant organisé de manière plus structurée avec les dossiers suivants:

- `src/` - Fichiers source C/C++
- `include/` - Fichiers d'en-tête C/C++
- `qml/` - Fichiers QML pour l'interface utilisateur
- `scripts/` - Scripts utilitaires pour la compilation, l'exécution et le débogage
- `build/` - Fichiers générés lors de la compilation
  - `obj/` - Fichiers objets (.o)
  - `moc/` - Fichiers générés par le Meta-Object Compiler
  - `rcc/` - Fichiers de ressources compilés
  - `ui/` - Fichiers générés par l'UI compiler
- `doc/` - Documentation du projet
  - `user/` - Documentation utilisateur
  - `dev/` - Documentation développeur
  - `assets/` - Images et autres ressources pour la documentation
- `assets/` - Ressources non-code
- `config/` - Fichiers de configuration
- `fonts/` - Polices utilisées par l'application

## Fichiers de configuration

- `SpectroGen.pro` - Fichier de projet Qt, configuré pour diriger les fichiers générés vers le dossier `build/`

## Scripts utilitaires

Les scripts suivants ont été déplacés dans le dossier `scripts/` et mis à jour pour fonctionner avec la nouvelle structure:

- `scripts/build.sh` - Compile l'application
- `scripts/run.sh` - Lance l'application
- `scripts/debug.sh` - Débogue l'application avec LLDB
- `scripts/debug_config.sh` - Génère une configuration LLDB améliorée
- `scripts/debug_enhanced.sh` - Débogue l'application avec la configuration LLDB améliorée
- `scripts/setup_macos.sh` - Configure l'environnement de développement sur macOS

## Documentation

La documentation a été organisée dans le dossier `doc/`:

- `doc/README.md` - Documentation principale du projet
- `doc/dev/DEBUGGING.md` - Guide de débogage
- `doc/dev/Charte_Graphique_SpectroGen.md` - Charte graphique
- `doc/dev/README_CHARTE_GRAPHIQUE.md` - Guide d'implémentation de la charte graphique

Des liens symboliques ont été créés à la racine du projet pour maintenir la compatibilité:

- `README.md` -> `doc/README.md`
- `Charte_Graphique_SpectroGen.md` -> `doc/dev/Charte_Graphique_SpectroGen.md`
- `README_CHARTE_GRAPHIQUE.md` -> `doc/dev/README_CHARTE_GRAPHIQUE.md`

## Avantages de cette structure

1. **Séparation claire des préoccupations**:
   - Code source séparé des fichiers générés
   - Documentation séparée du code
   - Scripts utilitaires regroupés

2. **Répertoire racine plus propre**:
   - Moins de fichiers à la racine
   - Meilleure visibilité des fichiers importants

3. **Maintenance facilitée**:
   - Les fichiers générés sont isolés dans `build/`
   - Nettoyage simplifié (`rm -rf build/*`)
   - Organisation logique des fichiers

4. **Évolutivité**:
   - Structure prête à accueillir de nouveaux composants
   - Organisation adaptée à la croissance du projet

## Utilisation

Pour utiliser le projet avec cette nouvelle structure:

1. **Compilation**:
   ```bash
   scripts/build.sh
   ```

2. **Exécution**:
   ```bash
   scripts/run.sh
   ```

3. **Débogage**:
   ```bash
   scripts/debug.sh
   ```

4. **Configuration de l'environnement**:
   ```bash
   scripts/setup_macos.sh
   ```
