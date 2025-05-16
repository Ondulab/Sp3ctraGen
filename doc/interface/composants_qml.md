# Architecture des composants QML

## Introduction

Ce document détaille l'architecture des composants QML utilisés dans l'interface utilisateur de Sp3ctraGen. Il explique comment ces composants sont organisés, comment ils interagissent entre eux et comment les étendre ou les modifier.

## Organisation générale

L'interface utilisateur de Sp3ctraGen est construite avec Qt Quick (QML) et suit une architecture modulaire basée sur des composants réutilisables. Les fichiers QML sont organisés selon la structure suivante :

```
qml/
├── components/         # Composants réutilisables
├── sections/           # Sections fonctionnelles de l'interface
├── styles/             # Définitions de styles et thèmes
├── main.qml            # Point d'entrée de l'interface
├── qml.qrc             # Fichier de ressources Qt
└── SavePreviewDialog.qml # Dialogue spécifique
```

## Hiérarchie des composants

### 1. Point d'entrée

`main.qml` est le point d'entrée de l'interface utilisateur. Il est responsable de :

- Créer la fenêtre principale de l'application
- Organiser les sections dans un layout général
- Gérer les interactions globales
- Initialiser les fournisseurs de données (providers)
- Configurer les boîtes de dialogue communes

### 2. Sections fonctionnelles

Les sections sont des unités fonctionnelles indépendantes qui encapsulent une partie spécifique de l'interface. Chaque section est contenue dans un fichier séparé dans le dossier `sections/`.

Sections principales :

- **FileSettings.qml** : Sélection des fichiers d'entrée et de sortie
- **SpectrogramParameters.qml** : Paramètres d'analyse du spectrogramme
- **FilterParameters.qml** : Options de filtrage du signal
- **OutputFormat.qml** : Configuration du format de sortie
- **PreviewSection.qml** : Prévisualisation du spectrogramme
- **AudioWaveformSection.qml** : Visualisation et manipulation de la forme d'onde

Chaque section hérite du composant `SectionContainer`, qui fournit une apparence visuelle cohérente.

### 3. Composants réutilisables

Les composants réutilisables sont des éléments d'interface plus petits et génériques, utilisés dans différentes sections. Ils sont définis dans le dossier `components/`.

Composants clés :

- **AudioWaveform.qml** : Visualisation interactive de la forme d'onde audio
- **ParameterField.qml** : Champ de saisie avec validation pour les paramètres numériques
- **ToggleSwitch.qml** : Interrupteur personnalisé pour les options binaires
- **StatusText.qml** : Affichage de messages de statut et d'erreur
- **SectionContainer.qml** : Conteneur avec style uniforme pour les sections

### 4. Styles et thèmes

Les styles et thèmes sont centralisés dans le dossier `styles/` :

- **Theme.qml** : Définition des couleurs, espacements, et autres constantes visuelles
- **Fonts.qml** : Configuration des polices utilisées dans l'application

## Exemple détaillé : AudioWaveformSection

Pour illustrer l'architecture des composants, examinons en détail la section `AudioWaveformSection` :

### Structure et organisation

```qml
// En-tête et imports
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import "../components"
import "../styles" as AppStyles

// Documentation du composant
/**
 * Section de la forme d'onde audio
 * 
 * Cette section affiche la forme d'onde du fichier audio et permet
 * de sélectionner un segment pour la génération du spectrogramme.
 */
SectionContainer {
    id: audioWaveformSection
    title: "Audio Waveform"
    preferredHeight: 200
    
    // Propriétés et fonctionnalités...
}
```

### Propriétés et dépendances

Les propriétés définissent l'état et les connexions externes du composant :

```qml
// Références aux dépendances externes
property var waveformProvider: null  // Fournisseur de données
property var generator: null         // Générateur de spectrogramme
property var inputFileDialog: null   // Dialogue de sélection de fichier

// Propriétés internes
property bool isAudioNormalized: false
property real normalizationFactor: 1.0

// Propriétés exposées (API publique)
property alias audioWaveform: audioWaveform
property alias cursorPosition: audioWaveform.cursorPosition
property alias segmentStart: audioWaveform.segmentStart
property alias segmentDuration: audioWaveform.segmentDuration
property string audioFilePath: ""
```

### Signaux (API d'événements)

Les signaux permettent la communication entre les composants :

```qml
// Signaux
signal audioFileLoaded(bool success, real duration, int sampleRate)
signal segmentSelected(double startPosition, double duration)
signal requestGenerateSpectrogram()
signal audioPlaybackStarted()
signal audioPlaybackStopped()
```

### Handlers et observateurs

Les handlers réagissent aux événements et les observateurs surveillent les changements de propriétés :

```qml
// Observer les changements de vitesse d'écriture
onWritingSpeedChanged: {
    // Recalculer le segment lorsque la vitesse d'écriture change
    if (waveformProvider && waveformProvider.getTotalDuration() > 0 && audioWaveform) {
        var numericSpeed = parseFloat(writingSpeed)
        _updateSegmentWithNumericSpeed(numericSpeed)
    }
}

// Handler pour le chargement de fichier
function onFileLoaded(success, durationSeconds, sampleRate) {
    if (success) {
        // Actions à effectuer lorsqu'un fichier est chargé avec succès
        // ...
    }
}
```

### Layout et organisation visuelle

L'organisation visuelle utilise les layouts Qt Quick pour un placement flexible :

```qml
// Mise en page
ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: AppStyles.Theme.spacing
    
    // Composant de visualisation de forme d'onde
    AudioWaveform {
        id: audioWaveform
        Layout.fillWidth: true
        Layout.fillHeight: true
        // ...
    }
    
    // Boutons pour la forme d'onde
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: AppStyles.Theme.spacing
        
        Button { /* ... */ }
        Button { /* ... */ }
        // ...
    }
    
    // Texte de statut
    StatusText {
        id: statusText
        // ...
    }
}
```

### API publique

L'API publique définit les fonctions accessibles depuis l'extérieur :

```qml
// Méthodes publiques
function loadAudioFile(filePath) {
    // ...
}

function extractCurrentSegment() {
    // ...
}

function getAudioFileName() {
    // ...
}

function toggleAudioPlayback() {
    // ...
}

function normalizeAudio() {
    // ...
}
```

## Principes de communication entre composants

### 1. Propriétés liées (Binding)

Les propriétés peuvent être liées entre composants pour maintenir la synchronisation :

```qml
// Liaison directe
property alias cursorPosition: audioWaveform.cursorPosition

// Liaison avec expression
Rectangle {
    color: isSelected ? "blue" : "gray"
}
```

### 2. Signaux et slots

Les signaux permettent de notifier les autres composants d'événements :

```qml
// Définition d'un signal
signal segmentSelected(double startPosition, double duration)

// Émission d'un signal
segmentSelected(segment.startPosition, segment.duration)

// Connexion à un signal (dans un autre composant)
Connections {
    target: audioWaveformSection
    function onSegmentSelected(startPos, duration) {
        // Traiter l'événement
    }
}
```

### 3. Accès direct aux objets

Les objets QML peuvent être accessibles directement par ID :

```qml
// Référence directe
audioWaveform.waveformData = newData
```

### 4. Appels de méthodes

Les méthodes peuvent être appelées directement :

```qml
// Appel de méthode
if (statusText) {
    statusText.showSuccess("Audio normalized")
}
```

## Interaction avec la couche C++

L'interface QML interagit avec la couche C++ via plusieurs mécanismes :

### 1. Objets C++ exposés à QML

Les classes C++ sont exposées comme types QML :

```cpp
// Dans le fichier C++
qmlRegisterType<SpectrogramGenerator>("com.cisynth.backend", 1, 0, "SpectrogramGenerator");
```

```qml
// Dans le fichier QML
import com.cisynth.backend 1.0

SpectrogramGenerator {
    id: spectrogramGenerator
    // ...
}
```

### 2. Propriétés notifiables

Les propriétés C++ notifiables sont accessibles en QML :

```qml
// Accès à une propriété C++
Text {
    text: "FFT Size: " + spectrogramGenerator.fftSize
}
```

### 3. Slots et signaux

Les slots et signaux C++ sont accessibles en QML :

```qml
// Connexion à un signal C++
Connections {
    target: spectrogramGenerator
    function onGenerationComplete(success) {
        // Traiter le signal
    }
}

// Appel d'un slot C++
Button {
    onClicked: spectrogramGenerator.generateSpectrogram()
}
```

### 4. Fournisseurs de données (Providers)

Les fournisseurs de données spécialisés font le pont entre QML et les données C++ :

- **WaveformProvider** : Fournit les données de forme d'onde à l'interface
- **PreviewImageProvider** : Fournit les images de prévisualisation
- **VectorPrintProvider** : Gère l'impression vectorielle

## Bonnes pratiques

### Organisation du code QML

1. **Structuration claire** :
   - Diviser le code en sections logiques
   - Déclarer les propriétés au début
   - Organiser les handlers et méthodes par fonctionnalité

2. **Documentation** :
   - Documenter chaque composant avec un commentaire d'en-tête
   - Expliquer les propriétés complexes et les méthodes publiques

3. **Nommage cohérent** :
   - Suivre les conventions de nommage (camelCase)
   - Préfixer les propriétés et méthodes privées par "_"

### Performance

1. **Optimisation des liaisons** :
   - Éviter les liaisons excessives ou circulaires
   - Privilégier les liaisons directes (alias) quand possible

2. **Gestion de la mémoire** :
   - Nettoyer les ressources dans Component.onDestruction
   - Éviter les références cycliques

3. **Délégation de traitement** :
   - Déléguer les opérations intensives à C++
   - Utiliser QtConcurrent pour les tâches en arrière-plan

### Extension des composants

Pour étendre ou modifier les composants existants :

1. **Création d'un composant dérivé** :
   ```qml
   // Étendre un composant existant
   AudioWaveform {
       id: enhancedWaveform
       property bool showMarkers: true
       
       // Surcharger le comportement
       onCursorMoved: {
           // Comportement personnalisé
           if (showMarkers) {
               // ...
           }
           // Appeler l'implémentation originale
           super.onCursorMoved(position)
       }
   }
   ```

2. **Modification par composition** :
   ```qml
   // Composer avec un composant existant
   Item {
       id: customWaveformControl
       
       AudioWaveform {
           id: innerWaveform
           anchors.fill: parent
       }
       
       // Ajouter des éléments supplémentaires
       Rectangle {
           // Marqueur personnalisé
       }
   }
   ```

## Conclusion

L'architecture des composants QML de Sp3ctraGen est conçue pour être modulaire, réutilisable et maintenable. En suivant les principes et pratiques décrits dans ce document, les développeurs peuvent étendre et améliorer l'interface utilisateur de manière cohérente et efficace.

Chaque composant a une responsabilité unique et communique avec les autres composants à travers des interfaces bien définies, assurant ainsi une séparation claire des préoccupations et une maintenance facilitée.
