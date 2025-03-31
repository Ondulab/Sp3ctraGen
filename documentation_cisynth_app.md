# Documentation CISYNTH_App

## Table des matières

1. [Structure et architecture globale](#1-structure-et-architecture-globale)
2. [Description de l'interface utilisateur](#2-description-de-linterface-utilisateur)
3. [Dépendances et bibliothèques](#3-dépendances-et-bibliothèques)
4. [Appels systèmes et APIs Apple](#4-appels-systèmes-et-apis-apple)
5. [Fonctionnalités métier](#5-fonctionnalités-métier)
6. [Composants critiques](#6-composants-critiques)
7. [Conseils de portage vers Qt](#7-conseils-de-portage-vers-qt)
8. [Points de vigilance](#8-points-de-vigilance)

## 1. Structure et architecture globale

### Vue d'ensemble

CISYNTH_App est une application macOS conçue pour générer des spectrogrammes à partir de fichiers audio WAV. L'application utilise une architecture hybride combinant Swift pour l'interface utilisateur et C pour le traitement du signal et la génération d'images.

### Structure du projet

```
CISYNTH_App/
├── CISYNTH_App.entitlements      # Fichier d'autorisations macOS
├── CISYNTH_AppApp.swift          # Point d'entrée de l'application SwiftUI
├── ContentView.swift             # Interface utilisateur principale
├── Assets.xcassets/              # Ressources graphiques
├── Inc/                          # Fichiers d'en-tête C/C++
│   ├── CISYNTH_App-Bridging-Header.h  # En-tête de pont Swift-C
│   └── spectral_generator.h      # Interface C pour le générateur de spectrogrammes
├── Src/                          # Code source C/C++
│   └── spectral_generator.c      # Implémentation du générateur de spectrogrammes
└── Preview Content/              # Ressources pour l'aperçu SwiftUI
```

### Architecture logicielle

L'application suit une architecture en couches :

1. **Couche présentation** (Swift/SwiftUI) :
   - `CISYNTH_AppApp.swift` : Point d'entrée de l'application
   - `ContentView.swift` : Interface utilisateur principale

2. **Couche intermédiaire** (Bridging) :
   - `CISYNTH_App-Bridging-Header.h` : Pont entre Swift et C

3. **Couche métier/traitement** (C) :
   - `spectral_generator.h/.c` : Traitement du signal et génération de spectrogrammes

### Flux de données

1. L'utilisateur configure les paramètres du spectrogramme via l'interface SwiftUI
2. Les paramètres sont collectés dans une structure `SpectrogramSettings`
3. La fonction C `spectral_generator` est appelée avec ces paramètres
4. Le fichier WAV est chargé et traité
5. Un spectrogramme est généré sous forme d'image PNG
6. Le résultat est sauvegardé dans le dossier spécifié par l'utilisateur

## 2. Description de l'interface utilisateur

### Composants d'interface

L'interface utilisateur est construite avec SwiftUI et se compose des éléments suivants :

#### Paramètres du spectrogramme
- Champs de texte pour configurer :
  - Taille FFT (`fftSize`) : Taille de la transformée de Fourier
  - Chevauchement (`overlap`) : Pourcentage de chevauchement entre les fenêtres d'analyse
  - Fréquence minimale (`minFreq`) : Limite inférieure du spectrogramme en Hz
  - Fréquence maximale (`maxFreq`) : Limite supérieure du spectrogramme en Hz
  - Durée (`duration`) : Durée de l'audio à analyser en secondes
  - Taux d'échantillonnage (`sampleRate`) : Fréquence d'échantillonnage en Hz
  - Plage dynamique (`dynamicRangeDB`) : Plage dynamique en dB
  - Correction gamma (`gammaCorrection`) : Facteur de correction gamma
  - Facteur de contraste (`contrastFactor`) : Facteur d'ajustement du contraste
  - Alpha High Boost (`highBoostAlpha`) : Paramètre pour le filtre d'accentuation des hautes fréquences

- Interrupteurs (Toggle) pour :
  - Activation du dithering (`enableDithering`)
  - Activation du filtre High Boost (`enableHighBoost`)

#### Sélection de fichiers
- Champ de texte pour afficher le chemin du fichier d'entrée
- Bouton "Browse..." pour sélectionner un fichier WAV
- Champ de texte pour afficher le chemin du dossier de sortie
- Bouton "Browse..." pour sélectionner un dossier de sortie

#### Actions
- Bouton "Generate Spectrogram" pour lancer le traitement

### Événements gérés

- **Entrée clavier** : Saisie des valeurs numériques dans les champs de texte
- **Clics souris** :
  - Boutons "Browse..." pour ouvrir les dialogues de sélection de fichiers
  - Interrupteurs pour activer/désactiver les options
  - Bouton "Generate Spectrogram" pour lancer le traitement
- **Dialogues système** :
  - `NSOpenPanel` pour la sélection de fichiers et dossiers

### Navigation

L'application utilise une interface à page unique sans navigation complexe. Tous les contrôles sont présentés dans une seule vue verticale défilante.

## 3. Dépendances et bibliothèques

### Dépendances Swift/macOS
- **SwiftUI** : Framework d'interface utilisateur déclaratif d'Apple
- **AppKit** : Utilisé spécifiquement pour `NSOpenPanel` (sélection de fichiers)

### Dépendances C/C++
- **FFTW3** : Bibliothèque pour le calcul de la transformée de Fourier rapide
- **Cairo** : Bibliothèque pour la génération d'images
- **libsndfile** : Bibliothèque pour la lecture de fichiers audio
- **Bibliothèques standard C** : 
  - `stdio.h`, `stdlib.h`, `math.h`, `time.h`, `string.h` pour les opérations de base
  - `unistd.h` pour les fonctions système comme `getcwd`

## 4. Appels systèmes et APIs Apple

### SwiftUI
- `App` : Protocole principal pour définir l'application
- `Scene` : Définition de la scène principale
- `WindowGroup` : Conteneur de fenêtre standard
- `View` : Protocole de base pour les composants d'interface
- Composants d'interface : `VStack`, `HStack`, `Text`, `TextField`, `Toggle`, `Button`, `Divider`, `Spacer`
- Modificateurs : `padding`, `frame`, `font`

### AppKit
- `NSOpenPanel` : Dialogue de sélection de fichiers/dossiers
  - Méthodes : `runModal`, `allowedContentTypes`, `allowsMultipleSelection`, `canChooseDirectories`
  - Propriétés : `url`, `title`

### Foundation
- `NSString` : Utilisé pour la manipulation de chemins de fichiers
- Méthodes : `appendingPathComponent`

### Appels système C
- `getcwd` : Obtenir le répertoire de travail courant
- Opérations sur les fichiers via libsndfile et Cairo

## 5. Fonctionnalités métier

### Traitement du signal audio
- **Chargement et normalisation audio** : 
  - Lecture de fichiers WAV via libsndfile
  - Conversion stéréo vers mono si nécessaire
  - Normalisation de l'amplitude
  
- **Analyse spectrale** :
  - Calcul de la transformée de Fourier rapide (FFT)
  - Fenêtrage (window function) avec la fenêtre de Hann
  - Options de zero-padding pour améliorer la résolution fréquentielle
  - FFT hybride pour les basses fréquences (optionnel)
  
- **Traitement du spectrogramme** :
  - Calcul des magnitudes spectrales
  - Conversion en échelle logarithmique (dB)
  - Filtrage par plage de fréquences
  - Correction gamma
  - Ajustement du contraste
  - Dithering (optionnel)
  - Filtre d'accentuation des hautes fréquences (optionnel)

### Génération d'images
- Création d'images PNG via Cairo
- Mapping fréquentiel (linéaire ou logarithmique)
- Rendu du spectrogramme avec échelle de gris
- Flou optionnel pour lisser l'image

## 6. Composants critiques

### Sécurité
- Pas de mécanismes de sécurité particuliers identifiés
- Validation basique des entrées utilisateur

### Gestion des erreurs
- Vérification des allocations mémoire
- Gestion des erreurs d'ouverture de fichiers
- Codes de retour pour indiquer le succès ou l'échec des opérations

### Accès réseau
- Aucun accès réseau identifié

### Stockage de données
- Lecture de fichiers WAV
- Écriture d'images PNG
- Pas de stockage persistant de configuration

### Compatibilité système
- Application spécifique à macOS
- Dépendances sur des bibliothèques externes (FFTW3, Cairo, libsndfile)

### Performance et mémoire
- Allocation dynamique de mémoire pour les buffers audio et le spectrogramme
- Optimisations pour le calcul FFT (zero-padding, FFT hybride)
- Libération explicite des ressources

## 7. Conseils de portage vers Qt

### Choix de la technologie Qt

Pour le portage de CISYNTH_App, deux technologies principales sont disponibles dans l'écosystème Qt :

#### Qt Widgets (Recommandé pour cette application)

**Avantages pour ce projet :**
- Parfaitement adapté aux interfaces de type formulaire comme CISYNTH_App
- Intégration directe et naturelle avec le code C++ existant
- Widgets prédéfinis correspondant exactement aux besoins (QLineEdit, QCheckBox, etc.)
- Meilleure prise en charge des dialogues système (QFileDialog pour remplacer NSOpenPanel)
- Technologie mature avec documentation abondante et exemples
- Performance optimale pour les applications de bureau

**Inconvénients :**
- Paradigme impératif différent de l'approche déclarative de SwiftUI
- Aspect visuel moins moderne par défaut (peut être amélioré avec des feuilles de style)

#### Qt Quick (QML)

**Avantages :**
- Paradigme déclaratif similaire à SwiftUI
- Meilleures capacités pour les interfaces dynamiques et les animations
- Aspect visuel moderne par défaut
- Séparation plus claire entre la logique et la présentation

**Inconvénients pour ce projet :**
- Intégration plus complexe avec le code C++ existant
- Moins adapté aux interfaces de type formulaire avec nombreux champs
- Courbe d'apprentissage plus importante

**Conclusion :** Étant donné la nature de l'application (formulaire statique avec traitement intensif), **Qt Widgets** est recommandé pour ce portage. L'interface ne nécessite pas d'animations complexes ou d'interactions sophistiquées qui justifieraient l'utilisation de Qt Quick.

### Équivalences d'interface utilisateur (Qt Widgets)

| Composant SwiftUI | Équivalent Qt Widgets |
|-------------------|---------------|
| `App` | `QApplication` |
| `WindowGroup` | `QMainWindow` |
| `VStack` | `QVBoxLayout` |
| `HStack` | `QHBoxLayout` |
| `Text` | `QLabel` |
| `TextField` | `QLineEdit` |
| `Toggle` | `QCheckBox` |
| `Button` | `QPushButton` |
| `Divider` | `QFrame` (avec `setFrameShape(QFrame::HLine)`) |
| `Spacer` | `QSpacerItem` |
| `NSOpenPanel` | `QFileDialog` |

### Structure proposée pour Qt Widgets

```cpp
// Fenêtre principale
class MainWindow : public QMainWindow {
    Q_OBJECT
    
public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();
    
private slots:
    void selectInputFile();
    void selectOutputFolder();
    void generateSpectrogram();
    
private:
    // Widgets pour les paramètres
    QLineEdit *fftSizeEdit;
    QLineEdit *overlapEdit;
    // ... autres widgets ...
    
    QCheckBox *ditheringCheckBox;
    QCheckBox *highBoostCheckBox;
    
    // Widgets pour les fichiers
    QLineEdit *inputFileEdit;
    QLineEdit *outputFolderEdit;
    
    // Mise en page
    QVBoxLayout *mainLayout;
};
```

### Alternative avec Qt Quick (QML)

Si une approche plus moderne est souhaitée malgré les inconvénients mentionnés, voici un exemple de structure QML :

```qml
// MainWindow.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

ApplicationWindow {
    title: "CISYNTH Spectrogram Generator"
    width: 500
    height: 700
    visible: true
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10
        
        Label { text: "Spectrogram Settings"; font.bold: true }
        
        GridLayout {
            columns: 2
            
            Label { text: "FFT Size:" }
            TextField { id: fftSizeField; text: "8192"; Layout.preferredWidth: 80 }
            
            // ... autres paramètres ...
            
            CheckBox { id: ditheringCheckBox; text: "Enable Dithering" }
            CheckBox { id: highBoostCheckBox; text: "High Boost Filter"; checked: true }
        }
        
        // ... autres éléments d'interface ...
        
        Button {
            text: "Generate Spectrogram"
            onClicked: backend.generateSpectrogram()
        }
    }
}
```

### Intégration C/C++

L'intégration du code C avec Qt sera plus simple qu'avec Swift, car Qt est basé sur C++. Les étapes recommandées sont :

1. Convertir la structure `SpectrogramSettings` en classe C++ avec des getters/setters
2. Adapter la fonction `spectral_generator` pour utiliser des types C++ (std::string, etc.)
3. Connecter les signaux Qt aux slots qui appellent la fonction de génération

### Gestion des fichiers

Remplacer `NSOpenPanel` par `QFileDialog` :

```cpp
void MainWindow::selectInputFile() {
    QString fileName = QFileDialog::getOpenFileName(
        this, tr("Select WAV file"), QDir::homePath(), tr("Audio Files (*.wav)"));
    if (!fileName.isEmpty()) {
        inputFileEdit->setText(fileName);
    }
}

void MainWindow::selectOutputFolder() {
    QString dir = QFileDialog::getExistingDirectory(
        this, tr("Select Output Folder"), QDir::homePath());
    if (!dir.isEmpty()) {
        outputFolderEdit->setText(dir);
    }
}
```

## 8. Points de vigilance

### Intégration C/Swift
- Le bridging header (`CISYNTH_App-Bridging-Header.h`) devra être remplacé par une intégration C++/Qt
- La structure `SpectrogramSettings` devra être adaptée pour C++

### Dépendances externes
- Les bibliothèques FFTW3, Cairo et libsndfile devront être intégrées au projet Qt
- Vérifier la compatibilité des versions et les options de compilation

### Gestion de la mémoire
- Le code C utilise des allocations manuelles (`malloc`/`free`) qui pourraient être remplacées par des conteneurs C++ (`std::vector`)
- Utiliser des smart pointers pour éviter les fuites mémoire

### Optimisations spécifiques
- Le code contient des optimisations comme le zero-padding et la FFT hybride qui devront être préservées
- Les macros de configuration (`#define`) devraient être converties en constantes ou options configurables

### Interface utilisateur
- SwiftUI utilise un paradigme déclaratif différent de l'approche impérative de Qt
- La mise à jour réactive des états (`@State`) devra être remplacée par des signaux/slots Qt

### Multithreading
- Le code actuel ne semble pas utiliser de multithreading explicite
- Pour Qt, envisager d'utiliser `QThread` ou `QtConcurrent` pour déplacer le traitement intensif hors du thread UI

### Spécificités macOS
- L'application utilise `NSOpenPanel` qui est spécifique à macOS
- Les chemins de fichiers peuvent nécessiter une adaptation selon la plateforme cible

### Performances
- Le traitement FFT et la génération d'images sont des opérations intensives
- Tester les performances sur différentes plateformes et optimiser si nécessaire
