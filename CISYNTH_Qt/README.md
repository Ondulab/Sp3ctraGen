# SpectroGen

Application de génération de spectrogrammes basée sur Qt Quick. Cette application est un portage de l'application CISYNTH_App originale développée en SwiftUI.

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

## Configuration de VSCode

Le projet inclut une configuration VSCode complète pour macOS:

- `.vscode/c_cpp_properties.json`: Configuration de l'IntelliSense
- `.vscode/tasks.json`: Tâches de compilation
- `.vscode/launch.json`: Configuration de débogage

## Compilation

Vous pouvez compiler l'application de plusieurs façons:

### Avec VSCode

1. Ouvrez le dossier `SpectroGen` dans VSCode
2. Appuyez sur `Ctrl+Shift+B` ou sélectionnez `Terminal > Run Build Task...` pour lancer la compilation
3. La tâche par défaut exécutera `qmake` puis `make`

### En ligne de commande

```bash
cd SpectroGen
/opt/homebrew/opt/qt@5/bin/qmake -spec macx-clang CONFIG+=debug CONFIG+=qml_debug
make -j8
```

### Avec les scripts fournis

Le projet inclut deux scripts pour faciliter la compilation et l'exécution:

1. **build.sh**: Compile l'application
   ```bash
   ./build.sh
   ```

2. **run.sh**: Lance l'application
   ```bash
   ./run.sh
   ```

## Débogage

Pour déboguer l'application dans VSCode:

1. Placez des points d'arrêt dans votre code en cliquant dans la marge à gauche du numéro de ligne
2. Appuyez sur F5 ou sélectionnez `Run > Start Debugging` pour lancer le débogueur
3. Le débogueur s'arrêtera automatiquement au point d'entrée du programme (fonction main)
4. Utilisez les contrôles de débogage pour naviguer dans le code:
   - F10: Pas à pas principal (Step Over) - exécute la ligne actuelle sans entrer dans les fonctions
   - F11: Pas à pas détaillé (Step Into) - entre dans les fonctions appelées
   - Shift+F11: Pas à pas sortant (Step Out) - sort de la fonction actuelle
   - F5: Continuer l'exécution jusqu'au prochain point d'arrêt

Pour des instructions détaillées sur le débogage, consultez le fichier [DEBUGGING.md](DEBUGGING.md).

## Structure du projet

- `SpectroGen.pro`: Fichier de projet Qt
- `qml/`: Fichiers QML pour l'interface utilisateur
- `include/`: Fichiers d'en-tête C/C++
- `src/`: Fichiers source C/C++

## Fonctionnalités

- Configuration des paramètres du spectrogramme
- Sélection des fichiers d'entrée/sortie
- Génération de spectrogrammes haute qualité
- Traitement multithreadé

## Remarques sur le portage

Cette application est un portage de l'application CISYNTH_App originale développée en SwiftUI. Le portage a été réalisé en:

1. Recréant l'interface utilisateur en QML
2. Créant une classe C++ pour faire le pont entre QML et le code C existant
3. Intégrant le code C existant sans modification
4. Ajoutant un système de threading pour éviter de bloquer l'interface

## Dépannage

### Problèmes de compilation

Si vous rencontrez des problèmes de compilation, vérifiez:

1. Que Qt 5 est correctement installé et accessible
   ```bash
   ls -la /opt/homebrew/opt/qt@5/bin/qmake
   ```

2. Que les bibliothèques FFTW, Cairo et libsndfile sont installées
   ```bash
   brew list fftw cairo libsndfile
   ```

3. Essayez de nettoyer et recompiler
   ```bash
   make clean
   /opt/homebrew/opt/qt@5/bin/qmake -spec macx-clang CONFIG+=debug CONFIG+=qml_debug
   make -j8
   ```

### Problèmes de débogage

Si le débogueur ne se lance pas correctement:

1. Vérifiez que l'application a été compilée avec succès
2. Vérifiez que le chemin dans `launch.json` correspond à l'emplacement de l'exécutable
3. Assurez-vous que LLDB est installé (il est généralement inclus avec les outils de ligne de commande Xcode)

### Problèmes avec le débogage pas à pas

Si vous rencontrez des problèmes avec le débogage pas à pas:

1. **Pas de surbrillance dans les fichiers source**:
   ```bash
   # Générer une configuration LLDB améliorée
   ./debug_config.sh
   
   # Utiliser le script de débogage amélioré
   ./debug_enhanced.sh
   ```

2. **Problèmes avec les points d'arrêt**:
   ```bash
   # Utiliser le script de débogage standard
   ./debug.sh
   ```

3. **Si vous préférez utiliser VSCode**:
   - Lancez VSCode depuis le terminal: `open -a 'Visual Studio Code' .`
   - Assurez-vous que l'option `"externalConsole": false` est définie dans `.vscode/launch.json`
   - Vérifiez que `"stopAtEntry": true` est défini pour que le débogueur s'arrête au début du programme

4. **Si l'interface graphique de l'application s'ouvre mais que le débogueur ne semble pas répondre**:
   - Fermer l'application
   - Ajouter un point d'arrêt au début de la fonction `main()` dans `src/main.cpp`
   - Redémarrer le débogueur

5. Pour les Mac avec Apple Silicon (M1, M2, etc.), consultez la section spécifique dans `DEBUGGING.md`
