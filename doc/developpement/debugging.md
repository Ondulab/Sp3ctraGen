# Guide de débogage de Sp3ctraGen

Ce guide fournit des instructions détaillées pour déboguer efficacement l'application Sp3ctraGen.

## Prérequis

Pour un débogage efficace, assurez-vous d'avoir installé :

1. **LLDB** - Le débogueur standard pour macOS, généralement inclus avec les outils de ligne de commande Xcode
2. **Qt Creator** (optionnel) - Peut être utilisé comme environnement de débogage alternatif
3. **VSCode** avec l'extension C/C++ - Pour le débogage via VSCode

## Configuration du débogage dans VSCode

Le projet inclut une configuration de débogage préconfigurée pour VSCode :

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug Sp3ctraGen",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build/Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen",
            "args": [],
            "stopAtEntry": true,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "lldb",
            "preLaunchTask": "Build Debug"
        }
    ]
}
```

Cette configuration :
- Lance automatiquement l'application compilée
- S'arrête au point d'entrée du programme (fonction `main()`)
- Utilise LLDB comme débogueur
- Exécute la tâche de compilation en mode debug avant le lancement

## Techniques de débogage

### 1. Débogage via VSCode

1. Placez des points d'arrêt en cliquant dans la marge à gauche du numéro de ligne
2. Appuyez sur F5 ou sélectionnez `Run > Start Debugging`
3. Utilisez les contrôles de débogage pour naviguer dans le code :
   - F10 : Pas à pas principal (Step Over)
   - F11 : Pas à pas détaillé (Step Into)
   - Shift+F11 : Pas à pas sortant (Step Out)
   - F5 : Continuer l'exécution

### 2. Débogage via les scripts fournis

Le projet inclut plusieurs scripts pour faciliter le débogage :

1. **scripts/debug.sh** - Lance l'application avec LLDB attaché
   ```bash
   scripts/debug.sh
   ```

2. **scripts/debug_config.sh** - Génère une configuration LLDB améliorée
   ```bash
   scripts/debug_config.sh
   ```

3. **scripts/run_with_logs.sh** - Lance l'application avec journalisation détaillée
   ```bash
   scripts/run_with_logs.sh
   ```

### 3. Débogage de la partie C

La partie C du code (moteur de traitement) peut être déboguée efficacement en :

1. Ajoutant des points d'arrêt dans les fichiers C (`spectral_generator.c`, `spectral_fft.c`, etc.)
2. Utilisant la commande `expr` de LLDB pour inspecter les variables :
   ```
   (lldb) expr -f x -- total_frames  # Affiche la valeur en hexadécimal
   (lldb) expr -f d -- sample_rate   # Affiche la valeur en décimal
   ```

3. Visualisant les tableaux avec la commande `memory read` :
   ```
   (lldb) memory read -f float -c 10 signal  # Affiche 10 valeurs du tableau signal au format float
   ```

### 4. Débogage de la partie C++

Pour déboguer la couche C++ (logique métier) :

1. Utilisez les points d'arrêt dans les méthodes clés des classes principales :
   - `SpectrogramGenerator::generateSpectrogram()`
   - `VisualizationStrategy::generate()`
   - `TaskManager::runTask()`

2. Inspectez les objets C++ avec les commandes LLDB :
   ```
   (lldb) expr -O -- *this  # Affiche tous les membres de l'objet courant
   (lldb) expr m_settings   # Affiche l'objet m_settings
   ```

### 5. Débogage de la partie QML

Pour déboguer l'interface QML :

1. Activez la journalisation QML en définissant des variables d'environnement :
   ```bash
   export QT_LOGGING_RULES="qt.qml.binding=true;qt.quick=true"
   ```

2. Utilisez `console.log()` dans le code QML pour afficher des informations :
   ```qml
   Component.onCompleted: {
       console.log("Propriétés :", JSON.stringify({
           width: width,
           height: height,
           visible: visible
       }))
   }
   ```

3. Observez la sortie de la console Qt pour les messages de débogage

## Débogage sur Apple Silicon (M1, M2, etc.)

Pour les Mac avec puce Apple Silicon (ARM) :

1. Assurez-vous que les bibliothèques sont compilées pour ARM64 :
   ```bash
   otool -L build/Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen | grep -i arm
   ```

2. Si vous rencontrez des problèmes avec les bibliothèques Intel, utilisez Rosetta :
   ```bash
   arch -x86_64 scripts/debug.sh
   ```

3. Vérifiez que vos bibliothèques externes (FFTW, Cairo, libsndfile) sont également compilées pour ARM64

## Résolution des problèmes courants

### 1. Points d'arrêt non déclenchés

Si les points d'arrêt ne se déclenchent pas :

1. Vérifiez que vous utilisez une compilation en mode debug :
   ```bash
   scripts/build.sh debug
   ```

2. Essayez de définir les points d'arrêt par leur nom de fonction :
   ```
   (lldb) breakpoint set --name SpectrogramGenerator::generateSpectrogram
   ```

3. Vérifiez que les symboles de débogage sont inclus :
   ```bash
   dsymutil build/Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen
   ```

### 2. Crash lors du chargement de fichiers audio

Si l'application plante lors du chargement de fichiers audio :

1. Placez un point d'arrêt dans `spectral_wav_processing.c`
2. Vérifiez les chemins de fichiers et les permissions
3. Inspectez les variables `sfinfo` et `sndfile` pour identifier le problème

### 3. Problèmes avec l'interface graphique

Si l'interface ne s'affiche pas correctement pendant le débogage :

1. Lancez avec la variable d'environnement QSG_INFO :
   ```bash
   QSG_INFO=1 scripts/run.sh
   ```

2. Vérifiez les erreurs dans la sortie du terminal
3. Essayez de désactiver temporairement les animations ou les effets complexes

### 4. Problèmes de mémoire

Pour détecter les fuites de mémoire ou problèmes similaires :

1. Utilisez Instruments (inclus avec Xcode) pour le profilage :
   ```bash
   xcrun instruments -t "Leaks" build/Sp3ctraGen.app
   ```

2. Ou utilisez Valgrind pour une analyse plus détaillée (nécessite une installation séparée) :
   ```bash
   valgrind --leak-check=full build/Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen
   ```

## Conseils avancés

### 1. Création de points d'arrêt conditionnels

Vous pouvez créer des points d'arrêt qui ne se déclenchent que sous certaines conditions :

```
(lldb) breakpoint set --file spectral_generator.c --line 245 --condition "fft_size > 8192"
```

### 2. Automatisation du débogage avec les fichiers .lldbinit

Le projet inclut un fichier `.lldbinit` à la racine qui configure automatiquement l'environnement LLDB. Vous pouvez ajouter vos propres commandes à ce fichier.

### 3. Débogage des threads multiples

Pour déboguer efficacement le code multithreadé :

1. Utilisez la commande `thread list` pour voir tous les threads actifs
2. Passez d'un thread à l'autre avec `thread select <id>`
3. Utilisez `thread backtrace all` pour voir la pile d'appels de tous les threads

### 4. Commandes LLDB utiles

Voici quelques commandes LLDB particulièrement utiles pour Sp3ctraGen :

```
# Afficher les informations sur les threads
(lldb) thread list

# Afficher la pile d'appels
(lldb) bt

# Afficher les variables locales
(lldb) frame variable

# Évaluer une expression
(lldb) expr calculation_result = fft_size * overlap

# Modifier une variable
(lldb) expr overlap = 0.75

# Continuer jusqu'à un certain point
(lldb) thread until 245

# Définir un alias pour une commande fréquemment utilisée
(lldb) command alias sf frame select

# Surveiller une variable (s'arrête quand la valeur change)
(lldb) watchpoint set variable global_max
```

## Conclusion

Le débogage efficace de Sp3ctraGen nécessite de comprendre les différentes couches de l'application et d'utiliser les outils appropriés pour chacune. En combinant les techniques de débogage pour C, C++ et QML, vous pouvez rapidement identifier et résoudre les problèmes dans l'application.

N'hésitez pas à consulter la documentation LLDB complète pour des fonctionnalités de débogage avancées : [LLDB Documentation](https://lldb.llvm.org/use/tutorial.html)
