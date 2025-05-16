# Guide d'installation de Sp3ctraGen

Ce guide détaille les étapes nécessaires pour installer Sp3ctraGen sur macOS.

## Prérequis système

Sp3ctraGen est actuellement optimisé pour macOS et requiert :

- macOS 10.14 (Mojave) ou version ultérieure
- Au moins 4 Go de RAM
- Environ 500 Mo d'espace disque disponible
- Processeur Intel ou Apple Silicon (M1/M2)

## Installation des dépendances

Sp3ctraGen dépend de plusieurs bibliothèques externes pour fonctionner correctement. La méthode recommandée pour les installer est via Homebrew.

### 1. Installer Homebrew (si ce n'est pas déjà fait)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Suivez les instructions à l'écran pour terminer l'installation de Homebrew.

### 2. Installer Qt 5.15 ou supérieur

```bash
brew install qt@5
```

Cette commande installe Qt 5.15, qui est la version minimale requise par Sp3ctraGen.

### 3. Installer les bibliothèques de traitement du signal et d'image

```bash
brew install fftw cairo libsndfile
```

Ces bibliothèques sont essentielles pour le fonctionnement de Sp3ctraGen :
- **FFTW** : Utilisé pour les calculs de transformée de Fourier rapide
- **Cairo** : Utilisé pour le rendu des spectrogrammes
- **libsndfile** : Utilisé pour le chargement et l'analyse des fichiers audio

### 4. Installer les outils de développement (optionnel)

Si vous prévoyez de contribuer au développement de l'application ou de compiler depuis les sources :

```bash
brew install bear cmake
```

- **bear** : Utile pour générer des fichiers de configuration pour les éditeurs de code
- **cmake** : Système de construction alternatif (en plus de qmake)

## Méthodes d'installation de Sp3ctraGen

### Option 1 : Installation via le fichier DMG (recommandé pour les utilisateurs)

1. Téléchargez le dernier fichier `.dmg` depuis la [page des releases](https://github.com/votre-repo/Sp3ctraGen/releases)
2. Double-cliquez sur le fichier DMG téléchargé
3. Faites glisser l'icône Sp3ctraGen vers le dossier Applications
4. Sp3ctraGen est maintenant installé et accessible depuis votre dossier Applications

### Option 2 : Installation via Homebrew (alternativement)

Si une formule Homebrew est disponible pour Sp3ctraGen, vous pouvez l'installer simplement avec :

```bash
brew tap votre-repo/sp3ctragen
brew install sp3ctragen
```

### Option 3 : Compilation depuis les sources

Pour les utilisateurs avancés ou développeurs qui souhaitent compiler l'application depuis les sources :

1. Clonez le dépôt :
   ```bash
   git clone https://github.com/votre-repo/Sp3ctraGen.git
   cd Sp3ctraGen
   ```

2. Compilez l'application :
   ```bash
   scripts/build.sh
   ```

3. Installez l'application (optionnel) :
   ```bash
   scripts/package.sh
   open Sp3ctraGen.dmg
   ```

## Premier lancement

Lors du premier lancement, vous pourriez rencontrer un avertissement de sécurité macOS. Pour résoudre ce problème :

1. Ouvrez les Préférences Système > Sécurité et confidentialité
2. Dans l'onglet "Général", cliquez sur "Ouvrir quand même" à côté du message concernant Sp3ctraGen
3. Confirmez que vous souhaitez ouvrir l'application

## Vérification de l'installation

Pour vérifier que Sp3ctraGen fonctionne correctement :

1. Lancez l'application depuis le Launchpad ou le dossier Applications
2. L'interface principale devrait s'afficher sans erreur
3. Essayez de charger un fichier audio test (WAV) pour confirmer que les bibliothèques de traitement audio fonctionnent
4. Tentez de générer un spectrogramme de test

## Résolution des problèmes courants

### Erreur "Impossible d'ouvrir l'application"

Si macOS refuse d'ouvrir l'application avec un message du type "l'application est endommagée" :

```bash
xattr -d com.apple.quarantine /Applications/Sp3ctraGen.app
```

### Bibliothèques Qt introuvables

Si vous rencontrez des erreurs concernant des bibliothèques Qt manquantes :

```bash
# Vérifiez que Qt est bien installé
brew list qt@5

# Assurez-vous que Qt est dans votre PATH
echo 'export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Problèmes avec les bibliothèques externes

En cas de problèmes avec FFTW, Cairo ou libsndfile :

```bash
# Vérifiez que les bibliothèques sont installées
brew list fftw cairo libsndfile

# Réinstallez-les si nécessaire
brew reinstall fftw cairo libsndfile
```

## Désinstallation

Si vous souhaitez désinstaller Sp3ctraGen :

### Si installé via DMG
```bash
rm -rf /Applications/Sp3ctraGen.app
```

### Si installé via Homebrew
```bash
brew uninstall sp3ctragen
```

## Mise à jour

Pour mettre à jour Sp3ctraGen vers la dernière version :

### Si installé via DMG
Téléchargez et installez la dernière version comme décrit précédemment.

### Si installé via Homebrew
```bash
brew update
brew upgrade sp3ctragen
```

### Si compilé depuis les sources
```bash
cd Sp3ctraGen
git pull
scripts/build.sh
scripts/package.sh
```

## Conclusion

L'installation de Sp3ctraGen est maintenant terminée. Pour apprendre à utiliser l'application, veuillez consulter le [Guide de démarrage rapide](prise_en_main.md) ou la [Documentation des fonctionnalités](fonctionnalites.md).

Si vous rencontrez des problèmes qui ne sont pas couverts par ce guide, veuillez consulter la [section de dépannage](../developpement/debugging.md) ou ouvrir une issue sur le dépôt GitHub du projet.
