# Guide de débogage pour SpectroGen

Ce document fournit des instructions détaillées pour déboguer efficacement l'application SpectroGen avec Visual Studio Code.

## Configuration du débogage

La configuration de débogage a été mise à jour pour faciliter le débogage pas à pas:

1. Le terminal intégré de VSCode est utilisé au lieu d'un terminal externe
2. Le débogueur s'arrête automatiquement au point d'entrée du programme
3. Des commandes LLDB supplémentaires ont été configurées pour améliorer l'expérience de débogage

## Points d'arrêt recommandés

Pour un débogage efficace, placez des points d'arrêt aux endroits stratégiques suivants:

### Dans `src/main.cpp`

```cpp
int main(int argc, char *argv[])
{
    // Point d'arrêt ici pour le démarrage de l'application
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    // Point d'arrêt ici pour l'enregistrement du type C++ pour QML
    qmlRegisterType<SpectrogramGenerator>("com.spectrogen.backend", 1, 0, "SpectrogramGenerator");

    // ...

    // Point d'arrêt ici pour le chargement du fichier QML principal
    engine.load(url);

    // Point d'arrêt ici pour l'exécution de la boucle d'événements
    return app.exec();
}
```

### Dans `src/spectrogramgenerator.cpp`

Placez des points d'arrêt dans les méthodes importantes de la classe `SpectrogramGenerator`, en particulier:

- Le constructeur
- Les méthodes appelées depuis QML
- Les méthodes de traitement du signal

## Techniques de débogage pas à pas

### 1. Démarrer le débogage

#### Méthode 1: Utiliser VSCode

1. Ouvrez VSCode et chargez le projet SpectroGen
2. Placez des points d'arrêt dans votre code en cliquant dans la marge à gauche du numéro de ligne
3. Appuyez sur F5 ou sélectionnez `Run > Start Debugging`
4. Le débogueur s'arrêtera automatiquement au début de la fonction `main()`

#### Méthode 2: Utiliser le script de débogage (recommandé)

Si vous rencontrez des problèmes avec le débogage dans VSCode, utilisez le script de débogage fourni:

1. Ouvrez un terminal dans le dossier du projet
2. Exécutez le script de débogage:
   ```bash
   ./debug.sh
   ```
3. Le débogueur LLDB s'ouvrira et s'arrêtera automatiquement au début de la fonction `main()`
4. Utilisez les commandes LLDB pour naviguer dans le code:
   - `n` ou `next` - Pas à pas principal (sans entrer dans les fonctions)
   - `s` ou `step` - Pas à pas détaillé (entre dans les fonctions)
   - `finish` - Sortir de la fonction actuelle
   - `c` ou `continue` - Continuer l'exécution jusqu'au prochain point d'arrêt
   - `bt` - Afficher la pile d'appels
   - `frame variable` - Afficher les variables locales
   - `q` ou `quit` - Quitter le débogueur

### 2. Navigation dans le code

Utilisez les contrôles de débogage pour naviguer dans le code:

- **F10**: Pas à pas principal (Step Over)
  - Exécute la ligne actuelle sans entrer dans les fonctions
  - Utile pour sauter les appels de fonction dont vous n'avez pas besoin d'examiner les détails

- **F11**: Pas à pas détaillé (Step Into)
  - Entre dans la fonction appelée sur la ligne actuelle
  - Utilisez cette option pour suivre l'exécution dans les fonctions qui vous intéressent

- **Shift+F11**: Pas à pas sortant (Step Out)
  - Sort de la fonction actuelle et revient à l'appelant
  - Utile lorsque vous avez terminé d'examiner une fonction

- **F5**: Continuer
  - Continue l'exécution jusqu'au prochain point d'arrêt
  - Utilisez cette option pour avancer rapidement jusqu'au prochain point d'intérêt

### 3. Inspection des variables

Pendant le débogage, vous pouvez inspecter les valeurs des variables de plusieurs façons:

- **Panneau Variables**: Affiche toutes les variables locales et leurs valeurs
- **Survol**: Passez la souris sur une variable dans le code pour voir sa valeur
- **Panneau Watch**: Ajoutez des expressions à surveiller pour suivre des variables spécifiques
- **Console de débogage**: Exécutez des commandes LLDB manuellement pour des inspections avancées

### 4. Débogage de Qt et QML

Pour déboguer efficacement une application Qt:

- Utilisez des points d'arrêt dans le code C++ pour suivre la logique métier
- Examinez les signaux et les slots pour comprendre le flux d'événements
- Utilisez `qDebug()` pour ajouter des messages de débogage temporaires
- Pour le débogage QML, utilisez `console.log()` dans vos fichiers QML

## Résolution des problèmes courants

### L'application se lance mais le débogueur ne s'arrête pas

1. Assurez-vous que les points d'arrêt sont placés dans des fichiers qui sont effectivement compilés
2. Vérifiez que le code est compilé en mode debug (`CONFIG+=debug` dans qmake)
3. Essayez de placer un point d'arrêt au tout début de la fonction `main()`
4. Utilisez le script `debug.sh` qui configure correctement LLDB pour l'architecture ARM64

### Le débogueur s'arrête mais les contrôles pas à pas ne fonctionnent pas

1. Vérifiez que l'option `"externalConsole": false` est définie dans `.vscode/launch.json`
2. Assurez-vous que les symboles de débogage sont correctement générés
3. Essayez de redémarrer VSCode et le débogueur

### Problèmes spécifiques à Apple Silicon (ARM64)

Si vous utilisez un Mac avec puce Apple Silicon (M1, M2, etc.), vous pourriez rencontrer des problèmes avec le débogueur:

1. **Mauvaise détection d'architecture**: VSCode peut incorrectement détecter l'architecture comme x86_64 au lieu d'ARM64
   - Solution: Utilisez le script `debug_enhanced.sh` qui définit explicitement l'architecture ARM64

2. **Points d'arrêt non activés**: Les points d'arrêt peuvent être ajoutés mais ne pas s'activer
   - Solution: Utilisez les commandes LLDB directement dans le terminal avec `./debug_enhanced.sh`
   - Vérifiez que les points d'arrêt sont bien définis avec `breakpoint list` dans LLDB

3. **Problèmes de chargement des symboles**: Les symboles de débogage peuvent ne pas être correctement chargés
   - Solution: Recompilez le projet avec `./build.sh` puis utilisez `./debug_enhanced.sh`

4. **Pas de surbrillance dans les fichiers source**: Le débogueur s'arrête mais ne met pas en surbrillance la ligne courante
   - Solution: Utilisez le script `debug_config.sh` pour générer une configuration LLDB qui aide à localiser les fichiers source
   - Exécutez VSCode depuis le terminal dans le répertoire du projet: `open -a 'Visual Studio Code' .`
   - Utilisez le script `debug_enhanced.sh` qui utilise cette configuration

### Configuration avancée du débogage

Pour résoudre les problèmes de localisation des fichiers source et de surbrillance pendant le débogage:

1. **Générer une configuration LLDB**:
   ```bash
   ./debug_config.sh
   ```
   Ce script crée:
   - Un fichier `.lldbinit` avec des paramètres pour aider LLDB à localiser les fichiers source
   - Un script `debug_enhanced.sh` qui utilise cette configuration

2. **Utiliser le script de débogage amélioré**:
   ```bash
   ./debug_enhanced.sh
   ```
   Ce script:
   - Charge la configuration LLDB
   - Configure correctement les chemins des fichiers source
   - Affiche des informations détaillées sur les symboles de débogage

3. **Lancer VSCode depuis le terminal**:
   ```bash
   open -a 'Visual Studio Code' .
   ```
   Cela permet à VSCode d'hériter des variables d'environnement et des configurations du terminal

### L'interface graphique se fige pendant le débogage

C'est un comportement normal pour les applications GUI lors du débogage. Lorsque le débogueur est arrêté sur un point d'arrêt, la boucle d'événements de l'interface graphique est également arrêtée, ce qui fait que l'interface semble figée. L'interface redeviendra réactive lorsque vous continuerez l'exécution.

## Commandes LLDB utiles

Dans la console de débogage, vous pouvez utiliser ces commandes LLDB:

- `p variable` - Affiche la valeur d'une variable
- `bt` - Affiche la pile d'appels (backtrace)
- `frame variable` - Affiche toutes les variables dans la frame actuelle
- `watchpoint set variable myVar` - Crée un point d'observation sur une variable
- `thread list` - Liste tous les threads
- `thread select 2` - Sélectionne le thread 2

## Ressources supplémentaires

- [Documentation officielle de Qt sur le débogage](https://doc.qt.io/qt-5/debug.html)
- [Guide de débogage C++ avec VSCode](https://code.visualstudio.com/docs/cpp/cpp-debug)
- [Documentation LLDB](https://lldb.llvm.org/use/tutorial.html)
