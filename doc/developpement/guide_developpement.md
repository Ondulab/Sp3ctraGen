# Guide de développement et débogage

## Introduction

Ce guide fournit des informations détaillées sur la configuration de l'environnement de développement, le processus de compilation, les techniques de débogage et les bonnes pratiques pour le développement de Sp3ctraGen. Il est destiné aux développeurs qui souhaitent contribuer au projet ou le modifier pour leurs propres besoins.

## Configuration de l'environnement de développement

### Prérequis

Pour développer Sp3ctraGen, vous aurez besoin des éléments suivants:

#### 1. Qt 5.15 ou supérieur

Qt est le framework principal utilisé pour l'interface utilisateur et la logique métier.

**Installation sur macOS:**
```bash
brew install qt@5
```

**Installation sur Linux:**
```bash
sudo apt-get install qt5-default qtdeclarative5-dev qml-module-qtquick-controls2
```

**Installation sur Windows:**
Téléchargez et installez Qt depuis le [site officiel](https://www.qt.io/download).

#### 2. Bibliothèques de traitement du signal et d'image

Sp3ctraGen utilise plusieurs bibliothèques pour le traitement du signal et la génération d'images.

**Installation sur macOS:**
```bash
brew install fftw cairo libsndfile
```

**Installation sur Linux:**
```bash
sudo apt-get install libfftw3-dev libcairo2-dev libsndfile1-dev
```

**Installation sur Windows:**
Téléchargez et installez les bibliothèques depuis leurs sites officiels respectifs:
- [FFTW](http://www.fftw.org/download.html)
- [Cairo](https://www.cairographics.org/download/)
- [libsndfile](http://www.mega-nerd.com/libsndfile/#Download)

#### 3. Outils de développement

**Installation sur macOS:**
```bash
brew install bear # Optionnel, pour générer compile_commands.json
```

**Installation sur Linux:**
```bash
sudo apt-get install build-essential bear
```

**Installation sur Windows:**
Installez Visual Studio ou MinGW.

### Configuration de VSCode

Sp3ctraGen inclut une configuration VSCode complète pour faciliter le développement:

1. **Ouvrez le dossier Sp3ctraGen dans VSCode**

2. **Installez les extensions recommandées:**
   - C/C++ (ms-vscode.cpptools)
   - Qt tools (tonka3000.qtvsctools)
   - CMake Tools (ms-vscode.cmake-tools)
   - Clang-Format (xaver.clang-format)

3. **Configurez les chemins Qt:**
   - Ouvrez les paramètres VSCode (Ctrl+,)
   - Recherchez "Qt"
   - Définissez le chemin vers votre installation Qt (par exemple, `/opt/homebrew/opt/qt@5` sur macOS)

4. **Vérifiez la configuration IntelliSense:**
   - Ouvrez `.vscode/c_cpp_properties.json`
   - Assurez-vous que les chemins d'inclusion sont corrects pour votre système

## Processus de compilation

### Compilation avec VSCode

1. Ouvrez le dossier `Sp3ctraGen` dans VSCode
2. Appuyez sur `Ctrl+Shift+B` ou sélectionnez `Terminal > Run Build Task...` pour lancer la compilation
3. La tâche par défaut exécutera `qmake` puis `make`

### Compilation en ligne de commande

#### macOS

```bash
cd Sp3ctraGen
/opt/homebrew/opt/qt@5/bin/qmake -spec macx-clang CONFIG+=debug CONFIG+=qml_debug
make -j8
```

#### Linux

```bash
cd Sp3ctraGen
qmake CONFIG+=debug CONFIG+=qml_debug
make -j8
```

#### Windows

```bash
cd Sp3ctraGen
C:\Qt\5.15.2\msvc2019_64\bin\qmake.exe CONFIG+=debug CONFIG+=qml_debug
nmake
```

### Compilation avec les scripts fournis

Le projet inclut plusieurs scripts pour faciliter la compilation et l'exécution:

```bash
# Compiler l'application
scripts/build.sh

# Exécuter l'application
scripts/run.sh

# Déboguer l'application
scripts/debug.sh
```

### Génération de compile_commands.json

Pour une meilleure intégration avec les outils d'analyse de code, vous pouvez générer un fichier `compile_commands.json`:

```bash
cd Sp3ctraGen
bear -- make clean all
```

Ce fichier sera utilisé par les outils comme clangd pour fournir une meilleure complétion de code et analyse statique.

## Techniques de débogage

### Débogage avec VSCode

1. Placez des points d'arrêt dans votre code en cliquant dans la marge à gauche du numéro de ligne
2. Appuyez sur F5 ou sélectionnez `Run > Start Debugging` pour lancer le débogueur
3. Le débogueur s'arrêtera automatiquement au point d'entrée du programme (fonction main)
4. Utilisez les contrôles de débogage pour naviguer dans le code:
   - F10: Pas à pas principal (Step Over) - exécute la ligne actuelle sans entrer dans les fonctions
   - F11: Pas à pas détaillé (Step Into) - entre dans les fonctions appelées
   - Shift+F11: Pas à pas sortant (Step Out) - sort de la fonction actuelle
   - F5: Continuer l'exécution jusqu'au prochain point d'arrêt

### Débogage avec LLDB/GDB en ligne de commande

#### LLDB (macOS)

```bash
cd Sp3ctraGen
lldb ./Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen
```

Commandes LLDB utiles:
- `breakpoint set --file main.cpp --line 42` - Définir un point d'arrêt
- `run` - Exécuter le programme
- `next` - Pas à pas principal
- `step` - Pas à pas détaillé
- `finish` - Pas à pas sortant
- `continue` - Continuer l'exécution
- `frame variable` - Afficher les variables locales
- `quit` - Quitter LLDB

#### GDB (Linux)

```bash
cd Sp3ctraGen
gdb ./Sp3ctraGen
```

Commandes GDB utiles:
- `break main.cpp:42` - Définir un point d'arrêt
- `run` - Exécuter le programme
- `next` - Pas à pas principal
- `step` - Pas à pas détaillé
- `finish` - Pas à pas sortant
- `continue` - Continuer l'exécution
- `print variable` - Afficher la valeur d'une variable
- `quit` - Quitter GDB

### Débogage avec les scripts fournis

Le projet inclut des scripts pour faciliter le débogage:

```bash
# Déboguer l'application avec LLDB
scripts/debug.sh

# Générer une configuration LLDB améliorée
scripts/debug_config.sh

# Déboguer avec la configuration LLDB améliorée
scripts/debug_enhanced.sh
```

### Débogage de l'interface QML

Pour déboguer l'interface QML, vous pouvez utiliser l'inspecteur QML:

1. Ajoutez l'option `-qmljsdebugger=port:1234,block` lors du lancement de l'application
2. Connectez-vous à l'inspecteur QML via le port 1234

Vous pouvez également utiliser `console.log()` dans votre code QML pour afficher des informations de débogage dans la console.

### Débogage des problèmes de mémoire

Pour déboguer les problèmes de mémoire, vous pouvez utiliser Valgrind:

```bash
cd Sp3ctraGen
valgrind --leak-check=full ./Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen
```

### Débogage spécifique pour Apple Silicon (M1, M2, etc.)

Si vous développez sur un Mac avec Apple Silicon, vous pourriez rencontrer des problèmes spécifiques. Voici quelques solutions:

1. **Problèmes de compilation:**
   - Assurez-vous d'utiliser la version de Qt compilée pour ARM64
   - Vérifiez que toutes les dépendances sont également compilées pour ARM64

2. **Problèmes de débogage:**
   - Utilisez le script `scripts/debug_enhanced.sh` qui contient des configurations spécifiques pour Apple Silicon
   - Si le débogueur ne s'arrête pas aux points d'arrêt, essayez d'ajouter `process launch --stop-at-entry` dans votre configuration LLDB

## Bonnes pratiques et conventions de code

### Structure du code

- **Séparation des préoccupations**: Respectez la séparation entre l'interface utilisateur (QML), la logique métier (C++) et le moteur de traitement (C)
- **Organisation des fichiers**: Placez les fichiers d'en-tête dans `include/` et les fichiers source dans `src/`
- **Composants QML**: Placez les composants QML réutilisables dans `qml/components/`

### Conventions de nommage

- **Classes C++**: PascalCase (ex: `SpectrogramGenerator`)
- **Fonctions et méthodes C++**: camelCase (ex: `generateSpectrogram`)
- **Variables C++**: camelCase avec préfixe `m_` pour les membres de classe (ex: `m_isGenerating`)
- **Constantes C++**: SNAKE_CASE_MAJUSCULE (ex: `MAX_FFT_SIZE`)
- **Fichiers QML**: PascalCase pour les composants (ex: `AnimatedButton.qml`), camelCase pour les autres (ex: `main.qml`)
- **Propriétés QML**: camelCase (ex: `property bool isGenerating`)
- **Fonctions C**: snake_case (ex: `apply_hann_window`)
- **Variables C**: snake_case (ex: `sample_rate`)
- **Constantes C**: SNAKE_CASE_MAJUSCULE (ex: `MAX_FFT_SIZE`)

### Style de code

- **Indentation**: 4 espaces (pas de tabulations)
- **Accolades**: Nouvelle ligne pour les accolades ouvrantes en C++, même ligne en QML
- **Longueur de ligne**: Maximum 100 caractères
- **Commentaires**: Utilisez `//` pour les commentaires en ligne et `/* */` pour les commentaires multi-lignes
- **Documentation**: Utilisez le format Doxygen pour documenter les classes, méthodes et fonctions

Exemple de documentation Doxygen:

```cpp
/**
 * @brief Génère un spectrogramme à partir d'un fichier audio
 * 
 * Cette fonction prend un fichier audio en entrée et génère un spectrogramme
 * en utilisant les paramètres spécifiés.
 * 
 * @param settings Paramètres du spectrogramme
 * @param inputFile Fichier audio d'entrée
 * @param outputFile Fichier de sortie pour le spectrogramme
 * @return true si la génération a démarré avec succès
 */
bool generateSpectrogram(const SpectrogramSettingsCpp& settings,
                        const QString& inputFile,
                        const QString& outputFile);
```

### Gestion des erreurs

- **Vérification des entrées**: Validez toujours les entrées utilisateur avant de les utiliser
- **Gestion des exceptions**: Utilisez les exceptions C++ pour les erreurs exceptionnelles, mais préférez les codes de retour pour les erreurs attendues
- **Journalisation**: Utilisez `qDebug()`, `qInfo()`, `qWarning()` et `qCritical()` pour journaliser les informations, avertissements et erreurs

### Tests

- **Tests unitaires**: Écrivez des tests unitaires pour les composants critiques
- **Tests d'intégration**: Testez l'interaction entre les différentes couches
- **Tests manuels**: Testez l'interface utilisateur et les fonctionnalités complètes

### Optimisation des performances

- **Profilage**: Utilisez des outils comme Qt Creator Profiler ou Instruments (macOS) pour identifier les goulots d'étranglement
- **Multithreading**: Utilisez `TaskManager` pour exécuter les opérations longues dans des threads séparés
- **Optimisation mémoire**: Évitez les copies inutiles, utilisez des références et des pointeurs intelligents

## Processus de développement

### Ajout d'une nouvelle fonctionnalité

1. **Planification**: Définissez clairement la fonctionnalité et son impact sur l'architecture existante
2. **Implémentation**: Suivez les bonnes pratiques et conventions de code
3. **Tests**: Testez la fonctionnalité pour vous assurer qu'elle fonctionne correctement
4. **Documentation**: Mettez à jour la documentation pour refléter les changements

### Modification d'une fonctionnalité existante

1. **Analyse**: Comprenez comment la fonctionnalité est actuellement implémentée
2. **Planification**: Définissez les changements nécessaires
3. **Implémentation**: Effectuez les modifications en suivant les bonnes pratiques
4. **Tests**: Testez les modifications pour vous assurer qu'elles fonctionnent correctement
5. **Documentation**: Mettez à jour la documentation pour refléter les changements

### Correction d'un bug

1. **Reproduction**: Assurez-vous de pouvoir reproduire le bug de manière fiable
2. **Analyse**: Identifiez la cause du bug
3. **Correction**: Corrigez le bug en suivant les bonnes pratiques
4. **Tests**: Vérifiez que le bug est corrigé et qu'aucun nouveau bug n'a été introduit
5. **Documentation**: Documentez la correction si nécessaire

## Ressources utiles

### Documentation Qt

- [Documentation Qt](https://doc.qt.io/)
- [Qt Quick Controls 2](https://doc.qt.io/qt-5/qtquickcontrols-index.html)
- [QML Reference](https://doc.qt.io/qt-5/qmlreference.html)

### Documentation des bibliothèques

- [FFTW](http://www.fftw.org/doc/)
- [Cairo](https://www.cairographics.org/documentation/)
- [libsndfile](http://www.mega-nerd.com/libsndfile/api.html)

### Outils de développement

- [VSCode](https://code.visualstudio.com/docs)
- [LLDB](https://lldb.llvm.org/use/tutorial.html)
- [GDB](https://www.gnu.org/software/gdb/documentation/)
- [Valgrind](https://valgrind.org/docs/)

## Conclusion

Ce guide fournit les informations nécessaires pour configurer l'environnement de développement, compiler, déboguer et contribuer au projet Sp3ctraGen. En suivant les bonnes pratiques et conventions décrites ici, vous pouvez maintenir et faire évoluer le projet de manière efficace et cohérente.

Si vous rencontrez des problèmes ou avez des questions, n'hésitez pas à consulter la documentation existante ou à contacter l'équipe de développement.