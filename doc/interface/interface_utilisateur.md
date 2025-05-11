# Interface utilisateur et composants QML

## Introduction

L'interface utilisateur de Sp3ctraGen est implémentée en QML (Qt Quick Markup Language), un langage déclaratif basé sur JavaScript qui fait partie du framework Qt. Cette documentation détaille la structure de l'interface utilisateur, les composants QML personnalisés, les interactions utilisateur et les mécanismes de prévisualisation.

## Structure de l'interface utilisateur

L'interface utilisateur de Sp3ctraGen est organisée en plusieurs fichiers QML principaux:

- `qml/main.qml` - Interface principale sans prévisualisation
- `qml/main_with_preview.qml` - Interface principale avec prévisualisation
- `qml/minimal_main.qml` - Interface simplifiée pour les cas d'utilisation basiques

### Interface principale avec prévisualisation

L'interface principale avec prévisualisation (`main_with_preview.qml`) est divisée en deux sections principales:

1. **Panneau de paramètres** (gauche) - Contient les contrôles pour configurer les paramètres du spectrogramme
2. **Zone de prévisualisation** (droite) - Affiche une prévisualisation du spectrogramme

```
┌─────────────────────────────────────────────────────────────┐
│                        Sp3ctraGen                           │
├───────────────────────────────┬─────────────────────────────┤
│                               │                             │
│                               │                             │
│                               │                             │
│     Panneau de paramètres     │    Zone de prévisualisation │
│                               │                             │
│                               │                             │
│                               │                             │
├───────────────────────────────┴─────────────────────────────┤
│                      Barre de statut                        │
└─────────────────────────────────────────────────────────────┘
```

Le code QML définit cette structure comme suit:

```qml
ApplicationWindow {
    id: window
    title: "Sp3ctraGen"
    width: 900
    height: 700
    visible: true
    color: "#222"
    
    // Layout principal avec division horizontale
    RowLayout {
        anchors.fill: parent
        anchors.margins: margin
        spacing: window.spacing
        
        // Partie gauche - Paramètres
        ScrollView {
            id: parametersScrollView
            Layout.fillHeight: true
            Layout.preferredWidth: showPreview ? parent.width * 0.5 : parent.width
            Layout.minimumWidth: 350
            contentWidth: parametersColumn.width
            
            ColumnLayout {
                id: parametersColumn
                // ...
            }
        }
        
        // Partie droite - Prévisualisation
        Rectangle {
            id: previewContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#1A1A1A"
            visible: showPreview
            // ...
        }
    }
}
```

### Adaptation responsive

L'interface utilisateur est conçue pour s'adapter à différentes tailles d'écran:

```qml
// Propriétés responsive
property bool isNarrow: width < 600
property bool isSmall: width < 400
property bool showPreview: width >= 800

// Adapter la mise en page en fonction de la taille de la fenêtre
onWidthChanged: {
    isNarrow = width < 600
    isSmall = width < 400
    showPreview = width >= 800
}
```

Ces propriétés sont utilisées pour ajuster la mise en page et la taille des composants en fonction de la taille de la fenêtre.

## Composants QML personnalisés

Sp3ctraGen utilise plusieurs composants QML personnalisés pour améliorer la réutilisabilité et la cohérence de l'interface utilisateur.

### AnimatedButton

Le composant `AnimatedButton` est un bouton personnalisé avec des animations pour améliorer l'expérience utilisateur:

```qml
Button {
    id: generateButton
    text: "Generate Spectrogram"
    font.family: orbitronFont.name
    font.pixelSize: labelFontSize
    
    property bool isAnimating: false
    property bool isProcessing: false
    property string originalText: "Generate Spectrogram"
    property string successText: "Generated!"
    property string processingText: "Processing..."
    property string buttonState: "normal" // "normal", "processing", "success", "error"
    
    // Fonctions pour gérer les différents états
    function startSuccessAnimation() { /* ... */ }
    function startProcessingAnimation() { /* ... */ }
    function stopProcessingAnimation() { /* ... */ }
    function resetState() { /* ... */ }
    
    // Animations
    SequentialAnimation { id: successAnimation /* ... */ }
    SequentialAnimation { id: returnToNormalAnimation /* ... */ }
    SequentialAnimation { id: clickAnimation /* ... */ }
    
    // Indicateur de progression
    BusyIndicator { id: progressIndicator /* ... */ }
    
    // Gestion des clics
    onClicked: {
        // Vérifier si le bouton n'est pas déjà en cours de traitement
        if (buttonState === "processing") return
        
        // Animation de clic avec retour visuel immédiat
        clickAnimation.start()
        
        // Vérification des champs requis
        // ...
        
        // Démarrer le timer pour retarder le démarrage du traitement
        clickDelayTimer.start()
    }
}
```

Ce composant offre plusieurs fonctionnalités avancées:
- Différents états visuels (normal, traitement, succès, erreur)
- Animations de transition entre les états
- Indicateur de progression pendant le traitement
- Retour visuel immédiat lors du clic

### ValidatedTextField

Le composant `ValidatedTextField` est un champ de texte avec validation intégrée:

```qml
TextField {
    id: validatedTextField
    
    property bool isValid: true
    property string validationError: ""
    property var validator: null
    
    onTextChanged: {
        if (validator) {
            var result = validator(text)
            isValid = result.valid
            validationError = result.error || ""
        }
    }
    
    background: Rectangle {
        border.color: validatedTextField.isValid ? "#555" : "#F44336"
        border.width: 1
        color: "#333"
        radius: 4
    }
}
```

Ce composant permet de valider les entrées utilisateur en temps réel et d'afficher des indications visuelles en cas d'erreur.

### AudioWaveform

Le composant `AudioWaveform` affiche la forme d'onde d'un fichier audio:

```qml
Rectangle {
    id: waveformView
    
    // Propriétés exposées
    property var waveformData: []
    property double cursorPosition: 0
    property double segmentStart: 0
    property double segmentDuration: 0
    property color waveColor: "#D4AF37"
    property color cursorColor: "#FFFFFF"
    property color segmentColor: "#80D4AF37"
    property color backgroundColor: "#1A1A1A"
    property bool showSegment: true
    property bool interactive: true
    
    // Signaux
    signal cursorMoved(double position)
    
    // Canvas pour dessiner la forme d'onde
    Canvas {
        id: waveformCanvas
        anchors.fill: parent
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            
            if (waveformData.length === 0) {
                return;
            }
            
            // Calculer le centre vertical
            var centerY = height / 2;
            var maxAmplitude = height / 2 * 0.9; // 90% de la moitié de la hauteur
            
            // Dessiner la forme d'onde
            // ...
        }
    }
    
    // Zone du segment à extraire
    Rectangle {
        id: segmentIndicator
        x: segmentStart * parent.width
        width: segmentDuration * parent.width
        height: parent.height
        color: segmentColor
        visible: showSegment
        z: -1
    }
    
    // Curseur mobile
    Rectangle {
        id: cursor
        width: 2
        height: parent.height
        x: cursorPosition * parent.width - width / 2
        color: cursorColor
        z: 10
        
        // Poignée du curseur pour faciliter la manipulation
        Rectangle {
            id: cursorHandle
            width: 14
            height: 14
            radius: 7
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 5
            color: cursorColor
            
            // Effet de brillance
            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: 5
                color: Qt.lighter(cursorColor, 1.5)
            }
        }
    }
    
    // Zone de détection des interactions souris/tactile
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: interactive
        
        onClicked: {
            if (!interactive) return;
            
            var newPos = Math.max(0, Math.min(1, mouseX / width));
            cursorPosition = newPos;
            cursorMoved(cursorPosition);
        }
        
        onPositionChanged: {
            if (!interactive || !pressed) return;
            
            var newPos = Math.max(0, Math.min(1, mouseX / width));
            cursorPosition = newPos;
            cursorMoved(cursorPosition);
        }
    }
}
```

Ce composant permet à l'utilisateur de visualiser la forme d'onde d'un fichier audio et de sélectionner une position ou un segment à traiter.

## Interactions utilisateur

### Sélection de fichiers

L'interface utilisateur permet à l'utilisateur de sélectionner des fichiers d'entrée et des dossiers de sortie:

```qml
// File selection dialog
FileDialog {
    id: inputFileDialog
    title: "Select WAV File"
    nameFilters: ["Audio files (*.wav)"]
    onAccepted: {
        inputFileField.text = fileUrl.toString().replace("file://", "")
        console.log("Input file selected: " + inputFileField.text);
        useDefaultInputToggle.checked = false;  // Désactiver l'option de chemin par défaut si un fichier est sélectionné
    }
}

// Folder selection dialog
FileDialog {
    id: outputFolderDialog
    title: "Select Output Folder"
    selectFolder: true
    onAccepted: {
        outputFolderField.text = fileUrl.toString().replace("file://", "")
        console.log("Output folder selected: " + outputFolderField.text);
        useDefaultOutputToggle.checked = false;  // Désactiver l'option de chemin par défaut si un dossier est sélectionné
    }
}
```

### Configuration des paramètres

Les paramètres du spectrogramme sont configurés via des champs de texte et des commutateurs:

```qml
// Spectrogram parameters
GridLayout {
    columns: window.isSmall ? 1 : 2
    Layout.fillWidth: true
    columnSpacing: window.spacing
    rowSpacing: window.spacing / 2

    Label { 
        text: "FFT Size:" 
        font.family: orbitronFont.name
        color: primaryTextColor
    }
    TextField {
        id: fftSizeField
        text: "8192"
        Layout.preferredWidth: window.isSmall ? 120 : 80
        Layout.fillWidth: window.isSmall
        validator: IntValidator { bottom: 1 }
        color: fieldText
        font.family: orbitronFont.name
        background: Rectangle {
            color: fieldBackground
            radius: borderRadius / 2
        }
        horizontalAlignment: Text.AlignHCenter
    }
    
    // Autres paramètres...
}
```

### Génération du spectrogramme

La génération du spectrogramme est déclenchée par le bouton "Generate Spectrogram":

```qml
Button {
    id: generateButton
    text: "Generate Spectrogram"
    // ...
    
    onClicked: {
        // Vérifier si le bouton n'est pas déjà en cours de traitement
        if (buttonState === "processing") return
        
        // Animation de clic avec retour visuel immédiat
        clickAnimation.start()
        
        // Vérification des champs requis
        if (inputFileField.text === "" && !useDefaultInputToggle.checked) {
            statusText.text = "Please select a WAV file or use default path"
            statusText.color = errorColor
            return
        }
        
        if (outputFolderField.text === "" && !useDefaultOutputToggle.checked) {
            statusText.text = "Please select an output folder or use default path"
            statusText.color = errorColor
            return
        }
        
        // Démarrer le timer pour retarder le démarrage du traitement
        clickDelayTimer.start()
    }
}

// Timer pour retarder le démarrage du traitement après l'animation de clic
Timer {
    id: clickDelayTimer
    interval: 150
    repeat: false
    onTriggered: {
        // Démarrer l'animation de traitement
        generateButton.startProcessingAnimation()
        
        // Appeler la fonction de génération
        generator.generateSpectrogram(
            parseInt(fftSizeField.text),
            parseFloat(overlapField.text),
            parseFloat(minFreqField.text),
            parseFloat(maxFreqField.text),
            parseFloat(durationField.text),
            parseInt(sampleRateField.text),
            parseFloat(dynamicRangeField.text),
            parseFloat(gammaCorrectionField.text),
            ditheringToggle.checked,
            parseFloat(contrastFactorField.text),
            highBoostToggle.checked,
            parseFloat(highBoostAlphaField.text),
            false, // enableHighPassFilter (désactivé par défaut)
            100.0, // highPassCutoffFreq (valeur par défaut)
            2,     // highPassFilterOrder (valeur par défaut)
            pageFormatCombo.currentIndex,
            bottomMarginField.getValue(),
            spectroHeightField.getValue(),
            writingSpeedField.getValue(),
            inputFileField.text,
            outputFolderField.text,
            normalizationToggle.checked
        )
    }
}
```

### Retour utilisateur

L'interface utilisateur fournit un retour visuel à l'utilisateur via des animations et des messages de statut:

```qml
// Status text
Label {
    id: statusText
    text: "Ready"
    font.family: orbitronFont.name
    color: fieldText
    Layout.topMargin: window.spacing
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: window.isSmall ? parent.width * 0.9 : 250
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.WordWrap
}

// Gestion des événements de génération
SpectrogramGenerator {
    id: generator
    onSpectrogramGenerated: {
        console.log("Signal spectrogramGenerated received: success=" + success + ", outputPath=" + outputPath + ", errorMessage=" + errorMessage);
        
        // Arrêter l'animation de traitement
        generateButton.stopProcessingAnimation()
        
        if (success) {
            statusText.text = "Spectrogram successfully generated: " + outputPath
            statusText.color = successColor
            generateButton.startSuccessAnimation()
        } else {
            statusText.text = "Error generating spectrogram: " + errorMessage
            statusText.color = errorColor
        }
    }
}
```

## Prévisualisation et affichage des résultats

### Prévisualisation du spectrogramme

La prévisualisation du spectrogramme est gérée par le composant `PreviewImageProvider`:

```qml
// Zone de prévisualisation avec ScrollView pour permettre le défilement
ScrollView {
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    // Image de prévisualisation
    Image {
        id: previewImage
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        width: parent.width
        height: parent.height
        cache: false
        asynchronous: true
        
        // Afficher un message si aucune prévisualisation n'est disponible
        Text {
            anchors.centerIn: parent
            text: "Click 'Refresh Preview' to generate a preview"
            color: fieldText
            font.family: orbitronFont.name
            visible: previewImage.status !== Image.Ready || previewImage.source === ""
        }
        
        // Gérer les erreurs de chargement
        onStatusChanged: {
            if (status === Image.Error) {
                previewStatusText.text = "Error loading preview image"
                previewStatusText.color = errorColor
            }
        }
    }
}

// Bouton de rafraîchissement de la prévisualisation
Button {
    id: refreshPreviewButton
    text: "Refresh Preview"
    // ...
    
    onClicked: {
        // Vérifier si le bouton n'est pas déjà en cours de traitement
        if (buttonState === "processing") return
        
        // Animation de clic avec retour visuel immédiat
        previewClickAnimation.start()
        
        // Vérification des champs requis
        if (inputFileField.text === "" && !useDefaultInputToggle.checked) {
            previewStatusText.text = "Please select a WAV file or use default path"
            previewStatusText.color = errorColor
            return
        }
        
        // Démarrer le timer pour retarder le démarrage du traitement
        previewClickDelayTimer.start()
    }
}

// Gestion des événements de prévisualisation
onPreviewGenerated: {
    console.log("Signal previewGenerated received: success=" + success + ", errorMessage=" + errorMessage);
    
    // Arrêter l'animation de traitement
    refreshPreviewButton.stopProcessingAnimation()
    
    if (success) {
        // Forcer le rechargement de l'image en utilisant un timestamp
        previewImage.source = ""  // Effacer l'image précédente
        previewImage.source = "image://preview/" + Date.now()  // Utiliser un timestamp pour éviter le cache
        previewStatusText.text = "Preview updated"
        previewStatusText.color = successColor
        refreshPreviewButton.startSuccessAnimation()
    } else {
        previewStatusText.text = "Error generating preview: " + errorMessage
        previewStatusText.color = errorColor
    }
}
```

Le `PreviewImageProvider` est une classe C++ qui implémente l'interface `QQuickImageProvider` pour fournir des images à QML:

```cpp
class PreviewImageProvider : public QQuickImageProvider
{
public:
    PreviewImageProvider();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
    void updateImage(const QImage &image);
    
    // Méthode pour récupérer l'image originale à haute résolution
    QImage getOriginalImage() const { return m_originalImage; }
    
    // Méthode pour sauvegarder l'image originale dans un fichier
    bool saveOriginalImage(const QString &filePath, const QString &format = "png") const;
    
    // Méthode pour imprimer l'image originale en haute résolution
    Q_INVOKABLE bool printImage() const;
    
private:
    QImage m_displayImage;  // Version redimensionnée pour l'affichage
    QImage m_originalImage; // Image originale à haute résolution
};
```

### Affichage de la forme d'onde

L'affichage de la forme d'onde est géré par le composant `AudioWaveform` et le fournisseur `WaveformProvider`:

```cpp
class WaveformProvider : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit WaveformProvider(QObject *parent = nullptr);
    virtual ~WaveformProvider();
    
    // Charge un fichier WAV et extrait les données
    Q_INVOKABLE bool loadFile(const QString &filePath);
    
    // Retourne les données pour l'affichage de la forme d'onde
    Q_INVOKABLE QVariantList getWaveformData(int width);
    
    // Calcule le segment à extraire en fonction des paramètres
    Q_INVOKABLE QVariantMap calculateExtractionSegment(
        double cursorPosition,
        int pageFormat,
        double writingSpeed
    );
    
    // Extrait le segment audio pour la génération
    Q_INVOKABLE QByteArray extractSegment(
        double startPosition, 
        double duration
    );
    
    // Retourne la durée totale du fichier audio en secondes
    Q_INVOKABLE double getTotalDuration() const;
    
    // Retourne le taux d'échantillonnage du fichier audio
    Q_INVOKABLE int getSampleRate() const;

signals:
    void fileLoaded(bool success, double durationSeconds, int sampleRate);

private:
    // Données du fichier audio
    SF_INFO m_fileInfo;
    SNDFILE* m_file;
    std::vector<float> m_audioData;
    QString m_filePath;
    bool m_fileLoaded;
    
    // Méthodes privées d'analyse
    void analyzeAudio();
    void resampleForDisplay(int targetWidth, QVariantList &result);
    void closeFile();
};
```

## Styles et thème

Sp3ctraGen utilise un thème sombre avec des accents dorés pour une interface élégante et professionnelle:

```qml
// Style properties
property color primaryTextColor: "#D4AF37"
property color fieldBackground: "#333"
property color fieldText: "#BBB"
property color buttonBackground: "#555"
property color buttonText: "#000"
property color buttonHoverBackground: "#333"
property color buttonHoverText: "#FFF"
property color borderColor: "#D4AF37"
property color toggleBorderColor: "#555"
property color toggleActiveColor: "#D4AF37"
property color toggleInactiveColor: "#555"
property color separatorColor: "#444"
property color successColor: "#4CAF50"
property color errorColor: "#F44336"
property int spacing: 10
property int margin: 20
property int padding: 10
property int borderRadius: 8
property int borderWidth: 1
property int titleFontSize: 20
property int labelFontSize: 16
property int textFontSize: 14
property int animationDuration: 200
```

La police Orbitron est utilisée pour un aspect moderne et technique:

```qml
// Orbitron Font
FontLoader {
    id: orbitronFont
    source: "qrc:/fonts/Orbitron-Regular.ttf"
}
```

## Conclusion

L'interface utilisateur de Sp3ctraGen est conçue pour être à la fois esthétique et fonctionnelle. Elle utilise des composants QML personnalisés pour améliorer l'expérience utilisateur et fournir un retour visuel clair. La séparation entre l'interface utilisateur et la logique métier permet une évolution indépendante de chaque couche.

Les principales caractéristiques de l'interface utilisateur sont:
- Une structure claire avec un panneau de paramètres et une zone de prévisualisation
- Des composants personnalisés avec des animations et des retours visuels
- Une adaptation responsive à différentes tailles d'écran
- Un thème sombre élégant avec des accents dorés
- Une prévisualisation en temps réel du spectrogramme
- Un affichage de la forme d'onde avec sélection interactive