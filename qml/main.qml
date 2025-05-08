import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import com.spectrogen.backend 1.0

ApplicationWindow {
    id: window
    title: "SpectroGen"
    width: 900
    height: 700
    visible: true
    color: "#222"
    
    // Orbitron Font
    FontLoader {
        id: orbitronFont
        source: "qrc:/fonts/Orbitron-Regular.ttf"
    }
    
    // Responsive properties
    property bool isNarrow: width < 600
    property bool isSmall: width < 400
    property bool showPreview: width >= 800
    
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
    
    // Adapt layout based on window size
    onWidthChanged: {
        isNarrow = width < 600
        isSmall = width < 400
    }
    
    // Allow window resizing
    minimumWidth: 800
    minimumHeight: 600

    // C++ backend references
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
        
        // Compteur pour forcer le rechargement de l'image
        property int previewCounter: 0
        
        onPreviewGenerated: {
            console.log("Signal previewGenerated received: success=" + success + ", errorMessage=" + errorMessage);
            
            if (success) {
                // Incrémenter le compteur pour forcer un nouveau chargement
                previewCounter++;
                
                // Forcer le rechargement de l'image avec un identifiant unique
                previewImageLoader.active = false;  // Désactiver le loader pour détruire l'image
                
                // Utiliser un timer pour laisser le temps au loader de se désactiver
                previewResetTimer.start();
                
                previewStatusText.text = "Preview updated"
                previewStatusText.color = successColor
            } else {
                previewStatusText.text = "Error generating preview: " + errorMessage
                previewStatusText.color = errorColor
            }
        }
        
        // Gestionnaire pour la prévisualisation du segment
        onSegmentPreviewGenerated: {
            console.log("Signal segmentPreviewGenerated received: success=" + success + ", errorMessage=" + errorMessage);
            
            if (success) {
                // Incrémenter le compteur pour forcer un nouveau chargement
                previewCounter++;
                
                // Forcer le rechargement de l'image avec un identifiant unique
                previewImageLoader.active = false;  // Désactiver le loader pour détruire l'image
                
                // Utiliser un timer pour laisser le temps au loader de se désactiver
                previewResetTimer.start();
                
                previewStatusText.text = "Segment preview updated"
                previewStatusText.color = successColor
                audioWaveformStatusText.text = "Segment preview generated successfully"
                audioWaveformStatusText.color = successColor
            } else {
                previewStatusText.text = "Error generating segment preview: " + errorMessage
                previewStatusText.color = errorColor
                audioWaveformStatusText.text = "Error generating segment preview: " + errorMessage
                audioWaveformStatusText.color = errorColor
            }
        }
        
        // Gestionnaire pour la sauvegarde de la prévisualisation
        onPreviewSaved: {
            console.log("Signal previewSaved received: success=" + success + ", outputPath=" + outputPath + ", format=" + format + ", errorMessage=" + errorMessage);
            
            // Réinitialiser le bouton de sauvegarde
            savePreviewButton.isProcessing = false;
            savePreviewButton.text = "Save Preview";
            
            if (success) {
                previewStatusText.text = "Preview saved successfully as " + format.toUpperCase() + ": " + outputPath;
                previewStatusText.color = successColor;
            } else {
                previewStatusText.text = "Error saving preview in " + format.toUpperCase() + " format: " + errorMessage;
                previewStatusText.color = errorColor;
            }
        }
    }
    
    // Fournisseur de données de forme d'onde
    WaveformProvider {
        id: waveformProvider
        
        onFileLoaded: {
            console.log("Audio file loaded: success=" + success + ", duration=" + durationSeconds + "s, sampleRate=" + sampleRate);
            
            if (success) {
                // Get waveform data for display
                var waveformWidth = audioWaveform.width;
                audioWaveform.waveformData = waveformProvider.getWaveformData(waveformWidth);
                
                // Calculate initial segment
                var segment = waveformProvider.calculateExtractionSegment(
                    audioWaveform.cursorPosition,
                    pageFormatCombo.currentIndex,
                    writingSpeedField.getValue()
                );
                
                // Update visual indicators
                audioWaveform.segmentStart = segment.startPosition / waveformProvider.getTotalDuration();
                audioWaveform.segmentDuration = segment.duration / waveformProvider.getTotalDuration();
                
                // Mettre à jour le champ sampleRateField avec la fréquence d'échantillonnage native
                sampleRateField.text = sampleRate.toString();
                
                audioWaveformStatusText.text = "Audio file loaded: " + durationSeconds.toFixed(2) + " seconds at " + sampleRate + " Hz";
                audioWaveformStatusText.color = successColor;
            } else {
                audioWaveformStatusText.text = "Error loading audio file";
                audioWaveformStatusText.color = errorColor;
            }
        }
    }
    
    // Timer pour réactiver le loader après un court délai
    Timer {
        id: previewResetTimer
        interval: 50
        onTriggered: {
            previewImageLoader.active = true;  // Réactiver le loader pour recréer l'image
        }
    }

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
                width: parametersScrollView.width - 20  // Marge pour la scrollbar
                spacing: window.spacing

                // Espace en haut pour l'équilibre visuel
                Item {
                    Layout.topMargin: margin / 2
                    Layout.preferredHeight: 1
                }
            
                // Parameters container with border
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parametersLayout.implicitHeight + 2 * padding
                    color: "transparent"
                    border.width: borderWidth
                    border.color: borderColor
                    radius: borderRadius
                    
                    ColumnLayout {
                        id: parametersLayout
                        anchors.fill: parent
                        anchors.margins: padding
                        spacing: window.spacing
                        
                        Label {
                            text: "Spectrogram Parameters"
                            font.bold: true
                            font.pixelSize: labelFontSize
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }

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

                            Label { 
                                text: "Overlap (0..1):" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: overlapField
                                text: "0.85"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { bottom: 0.0; top: 1.0 }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Label { 
                                text: "Min Frequency (Hz):" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: minFreqField
                                text: "65"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { bottom: 0.0 }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Label { 
                                text: "Max Frequency (Hz):" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: maxFreqField
                                text: "16640"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { bottom: 0.0 }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Label { 
                                text: "Writing Speed (cm/s):" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: writingSpeedField
                                text: "8.0"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { 
                                    bottom: 0.1
                                    decimals: 2
                                    notation: DoubleValidator.StandardNotation
                                    locale: "en_US" // Use English locale to accept decimal point
                                }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                                
                                // Function to handle decimal separator conversion if needed
                                function getValue() {
                                    return parseFloat(text.replace(',', '.'));
                                }
                            }
                            
                            // Champ de durée caché (conservé pour rétrocompatibilité)
                            Item {
                                id: durationField
                                visible: false
                                property string text: "4.0"
                            }

                            // Champ caché pour maintenir la compatibilité avec le code existant
                            Item {
                                id: sampleRateField
                                visible: false
                                property string text: "0" // Sera remplacé par la fréquence native du fichier
                            }

                            Label { 
                                text: "Dynamic Range (dB):" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: dynamicRangeField
                                text: "60.0"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { bottom: 0.0 }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Label { 
                                text: "Gamma Correction:" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: gammaCorrectionField
                                text: "0.8"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { bottom: 0.0 }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Label {
                                text: "Enable Normalization:"
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            Item {
                                id: normalizationToggle
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.preferredHeight: 30
                                Layout.fillWidth: window.isSmall
                                
                                property bool checked: true
                                
                                Rectangle {
                                    id: normalizationBackground
                                    anchors.fill: parent
                                    radius: height / 2
                                    color: "transparent"
                                    border.width: 1
                                    border.color: toggleBorderColor
                                    
                                    Rectangle {
                                        id: normalizationIndicator
                                        width: parent.width / 2
                                        height: parent.height - 4
                                        radius: height / 2
                                        x: normalizationToggle.checked ? parent.width - width - 2 : 2
                                        y: 2
                                        color: normalizationToggle.checked ? toggleActiveColor : toggleInactiveColor
                                        
                                        Behavior on x {
                                            NumberAnimation {
                                                duration: animationDuration
                                                easing.type: Easing.InOutQuad
                                            }
                                        }
                                        
                                        Behavior on color {
                                            ColorAnimation {
                                                duration: animationDuration
                                            }
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        normalizationToggle.checked = !normalizationToggle.checked
                                    }
                                }
                            }
                            
                            Label {
                                text: "Enable Dithering:"
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            Item {
                                id: ditheringToggle
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.preferredHeight: 30
                                Layout.fillWidth: window.isSmall
                                
                                property bool checked: false
                                
                                Rectangle {
                                    id: ditheringBackground
                                    anchors.fill: parent
                                    radius: height / 2
                                    color: "transparent"
                                    border.width: 1
                                    border.color: toggleBorderColor
                                    
                                    Rectangle {
                                        id: ditheringIndicator
                                        width: parent.width / 2
                                        height: parent.height - 4
                                        radius: height / 2
                                        x: ditheringToggle.checked ? parent.width - width - 2 : 2
                                        y: 2
                                        color: ditheringToggle.checked ? toggleActiveColor : toggleInactiveColor
                                        
                                        Behavior on x {
                                            NumberAnimation { 
                                                duration: animationDuration
                                                easing.type: Easing.InOutQuad
                                            }
                                        }
                                        
                                        Behavior on color {
                                            ColorAnimation { 
                                                duration: animationDuration
                                            }
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        ditheringToggle.checked = !ditheringToggle.checked
                                    }
                                }
                            }

                            Label { 
                                text: "Contrast Factor:" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: contrastFactorField
                                text: "1.9"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { bottom: 0.0 }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Label { 
                                text: "High Boost Filter:" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            Item {
                                id: highBoostToggle
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.preferredHeight: 30
                                Layout.fillWidth: window.isSmall
                                
                                property bool checked: true
                                
                                Rectangle {
                                    id: highBoostBackground
                                    anchors.fill: parent
                                    radius: height / 2
                                    color: "transparent"
                                    border.width: 1
                                    border.color: toggleBorderColor
                                    
                                    Rectangle {
                                        id: highBoostIndicator
                                        width: parent.width / 2
                                        height: parent.height - 4
                                        radius: height / 2
                                        x: highBoostToggle.checked ? parent.width - width - 2 : 2
                                        y: 2
                                        color: highBoostToggle.checked ? toggleActiveColor : toggleInactiveColor
                                        
                                        Behavior on x {
                                            NumberAnimation { 
                                                duration: animationDuration
                                                easing.type: Easing.InOutQuad
                                            }
                                        }
                                        
                                        Behavior on color {
                                            ColorAnimation { 
                                                duration: animationDuration
                                            }
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        highBoostToggle.checked = !highBoostToggle.checked
                                    }
                                }
                            }

                            Label { 
                                text: "High Boost Alpha:" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: highBoostAlphaField
                                text: "0.99"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { bottom: 0.0; top: 1.0 }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            // Contrôles du filtre passe-haut
                            Label { 
                                text: "High-Pass Filter:" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            Item {
                                id: highPassToggle
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.preferredHeight: 30
                                Layout.fillWidth: window.isSmall
                                
                                property bool checked: false
                                
                                Rectangle {
                                    id: highPassBackground
                                    anchors.fill: parent
                                    radius: height / 2
                                    color: "transparent"
                                    border.width: 1
                                    border.color: toggleBorderColor
                                    
                                    Rectangle {
                                        id: highPassIndicator
                                        width: parent.width / 2
                                        height: parent.height - 4
                                        radius: height / 2
                                        x: highPassToggle.checked ? parent.width - width - 2 : 2
                                        y: 2
                                        color: highPassToggle.checked ? toggleActiveColor : toggleInactiveColor
                                        
                                        Behavior on x {
                                            NumberAnimation { 
                                                duration: animationDuration
                                                easing.type: Easing.InOutQuad
                                            }
                                        }
                                        
                                        Behavior on color {
                                            ColorAnimation { 
                                                duration: animationDuration
                                            }
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        highPassToggle.checked = !highPassToggle.checked
                                    }
                                }
                            }
                            
                            Label { 
                                text: "Cutoff Frequency (Hz):" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                                enabled: highPassToggle.checked
                            }
                            TextField {
                                id: highPassCutoffField
                                text: "100"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { bottom: 1.0 }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                                enabled: highPassToggle.checked
                            }
                            
                            Label { 
                                text: "Filter Order (1-8):" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                                enabled: highPassToggle.checked
                            }
                            ComboBox {
                                id: highPassOrderCombo
                                model: ["1", "2", "3", "4", "5", "6", "7", "8"]
                                currentIndex: 1  // Ordre 2 par défaut
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                enabled: highPassToggle.checked
                                
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                
                                contentItem: Text {
                                    text: highPassOrderCombo.displayText
                                    font.family: orbitronFont.name
                                    color: fieldText
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                                
                                popup: Popup {
                                    y: highPassOrderCombo.height
                                    width: highPassOrderCombo.width
                                    implicitHeight: contentItem.implicitHeight
                                    padding: 1
                                    
                                    contentItem: ListView {
                                        clip: true
                                        implicitHeight: contentHeight
                                        model: highPassOrderCombo.popup.visible ? highPassOrderCombo.delegateModel : null
                                        
                                        ScrollBar.vertical: ScrollBar {
                                            active: highPassOrderCombo.popup.visible
                                        }
                                    }
                                    
                                    background: Rectangle {
                                        color: fieldBackground
                                        border.color: borderColor
                                        radius: borderRadius / 2
                                    }
                                }
                            }
                        }
                    }
                }

                // Separator
                Rectangle {
                    height: 1
                    color: separatorColor
                    Layout.fillWidth: true
                    Layout.topMargin: window.spacing
                    Layout.bottomMargin: window.spacing
                }
                
                // Format de sortie container with border
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: outputFormatLayout.implicitHeight + 2 * padding
                    color: "transparent"
                    border.width: borderWidth
                    border.color: borderColor
                    radius: borderRadius
                    
                    ColumnLayout {
                        id: outputFormatLayout
                        anchors.fill: parent
                        anchors.margins: padding
                        spacing: window.spacing
                        
                        Label {
                            text: "Output Format"
                            font.bold: true
                            font.pixelSize: labelFontSize
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        
                        GridLayout {
                            columns: window.isSmall ? 1 : 2
                            Layout.fillWidth: true
                            columnSpacing: window.spacing
                            rowSpacing: window.spacing / 2
                            
                            Label { 
                                text: "Page Format:" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            ComboBox {
                                id: pageFormatCombo
                                model: ["A4 Portrait", "A3 Landscape"]
                                Layout.preferredWidth: window.isSmall ? 120 : 120
                                Layout.fillWidth: window.isSmall
                                
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                
                                contentItem: Text {
                                    text: pageFormatCombo.displayText
                                    font.family: orbitronFont.name
                                    color: fieldText
                                    horizontalAlignment: Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    leftPadding: 5
                                }
                                
                                popup: Popup {
                                    y: pageFormatCombo.height
                                    width: pageFormatCombo.width
                                    implicitHeight: contentItem.implicitHeight
                                    padding: 1
                                    
                                    contentItem: ListView {
                                        clip: true
                                        implicitHeight: contentHeight
                                        model: pageFormatCombo.popup.visible ? pageFormatCombo.delegateModel : null
                                        
                                        ScrollBar.vertical: ScrollBar {
                                            active: pageFormatCombo.popup.visible
                                        }
                                    }
                                    
                                    background: Rectangle {
                                        color: fieldBackground
                                        border.color: borderColor
                                        radius: borderRadius / 2
                                    }
                                }
                            }
                            
                            Label { 
                                text: "Bottom Margin (mm):" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: bottomMarginField
                                text: "50,0"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { 
                                    bottom: 0.0 
                                    decimals: 2
                                    notation: DoubleValidator.StandardNotation
                                    locale: "en_US" // Use English locale to accept decimal point
                                }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                                
                                // Function to handle decimal separator conversion if needed
                                function getValue() {
                                    return parseFloat(text.replace(',', '.'));
                                }
                            }
                            
                            Label { 
                                text: "Spectrogram Height (mm):" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: spectroHeightField
                                text: "216,7"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { 
                                    bottom: 0.0 
                                    decimals: 2
                                    notation: DoubleValidator.StandardNotation
                                    locale: "en_US" // Use English locale to accept decimal point
                                }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                                
                                // Function to handle decimal separator conversion if needed
                                function getValue() {
                                    return parseFloat(text.replace(',', '.'));
                                }
                            }
                        }
                    }
                }
                
                // Separator
                Rectangle {
                    height: 1
                    color: separatorColor
                    Layout.fillWidth: true
                    Layout.topMargin: window.spacing
                    Layout.bottomMargin: window.spacing
                }

                // File selection container with border
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: filesLayout.implicitHeight + 2 * padding
                    color: "transparent"
                    border.width: borderWidth
                    border.color: borderColor
                    radius: borderRadius
                    
                    ColumnLayout {
                        id: filesLayout
                        anchors.fill: parent
                        anchors.margins: padding
                        spacing: window.spacing
                        
                        Label { 
                            text: "Output Settings" 
                            font.bold: true
                            font.pixelSize: labelFontSize
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        
                        // Note: Input File selection is now handled in the Audio Waveform section
                        
                        GridLayout {
                            columns: 2
                            Layout.fillWidth: true
                            
                            Label { 
                                text: "Output Folder:" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            
                            Button {
                                text: "Browse..."
                                font.family: orbitronFont.name
                                onClicked: outputFolderDialog.open()
                                
                                contentItem: Text {
                                    text: parent.text
                                    font.family: orbitronFont.name
                                    color: parent.hovered ? window.buttonHoverText : window.buttonText
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    color: parent.hovered ? buttonHoverBackground : buttonBackground
                                    radius: borderRadius / 2
                                    
                                    Behavior on color {
                                        ColorAnimation { 
                                            duration: animationDuration
                                        }
                                    }
                                }
                            }
                        }
                        
                        TextField {
                            id: outputFolderField
                            Layout.fillWidth: true
                            placeholderText: "Default output path will be used if empty"
                            readOnly: true
                            color: fieldText
                            font.family: orbitronFont.name
                            background: Rectangle {
                                color: fieldBackground
                                radius: borderRadius / 2
                            }
                        }
                        
                        // Hidden field to maintain compatibility
                        Item {
                            id: useDefaultOutputToggle
                            visible: false
                            property bool checked: outputFolderField.text === ""
                        }
                    }
                }
                
                // Separator
                Rectangle {
                    height: 1
                    color: separatorColor
                    Layout.fillWidth: true
                    Layout.topMargin: window.spacing
                    Layout.bottomMargin: window.spacing
                }
                
                // Audio Waveform container with border
                Rectangle {
                    id: audioWaveformContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    color: "transparent"
                    border.width: borderWidth
                    border.color: borderColor
                    radius: borderRadius
                    
                    ColumnLayout {
                        id: audioWaveformLayout
                        anchors.fill: parent
                        anchors.margins: padding
                        spacing: window.spacing
                        
                        Label {
                            text: "Audio Waveform"
                            font.bold: true
                            font.pixelSize: labelFontSize
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        
                        // Composant de visualisation de forme d'onde
                        AudioWaveform {
                            id: audioWaveform
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            waveColor: primaryTextColor
                            
                            onCursorMoved: {
                                // Calculer le segment à extraire
                                if (waveformProvider.getTotalDuration() > 0) {
                                    var segment = waveformProvider.calculateExtractionSegment(
                                        position,
                                        pageFormatCombo.currentIndex,
                                        writingSpeedField.getValue()
                                    );
                                    
                                    // Mettre à jour les indicateurs visuels
                                    audioWaveform.segmentStart = segment.startPosition / waveformProvider.getTotalDuration();
                                    audioWaveform.segmentDuration = segment.duration / waveformProvider.getTotalDuration();
                                    
                                    // Update information text
                                    var startSec = segment.startPosition.toFixed(2);
                                    var durationSec = segment.duration.toFixed(2);
                                    audioWaveformStatusText.text = "Position: " + startSec + "s, Segment duration: " + durationSec + "s";
                                }
                            }
                        }
                        
                        // Boutons pour la forme d'onde
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: window.spacing
                            
                            Button {
                                id: loadAudioButton
                                text: "Load Audio"
                                font.family: orbitronFont.name
                                
                                onClicked: {
                                    // Ouvrir un dialogue de sélection de fichier audio
                                    var fileDialog = inputFileDialog;
                                    fileDialog.open();
                                    
                                    // Connecter temporairement au signal accepted
                                    var connection = function() {
                                        var filePath = fileDialog.fileUrl.toString().replace("file://", "");
                                        waveformProvider.loadFile(filePath);
                                        fileDialog.accepted.disconnect(connection);
                                    };
                                    
                                    fileDialog.accepted.connect(connection);
                                }
                                
                                contentItem: Text {
                                    text: parent.text
                                    font.family: orbitronFont.name
                                    color: parent.hovered ? window.buttonHoverText : window.buttonText
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    color: parent.hovered ? buttonHoverBackground : buttonBackground
                                    radius: borderRadius / 2
                                    
                                    Behavior on color {
                                        ColorAnimation { 
                                            duration: animationDuration
                                        }
                                    }
                                }
                            }
                            
                            Button {
                                id: generateFromSegmentButton
                                text: "Generate Spectrogram"
                                font.family: orbitronFont.name
                                
                                onClicked: {
                                    if (waveformProvider.getTotalDuration() <= 0) {
                                        audioWaveformStatusText.text = "No audio file loaded";
                                        audioWaveformStatusText.color = errorColor;
                                        return;
                                    }
                                    
                                    // Calculer le segment à extraire
                                    var segment = waveformProvider.calculateExtractionSegment(
                                        audioWaveform.cursorPosition,
                                        pageFormatCombo.currentIndex,
                                        writingSpeedField.getValue()
                                    );
                                    
                                    // Extraire le segment audio
                                    var audioSegment = waveformProvider.extractSegment(
                                        segment.startPosition,
                                        segment.duration
                                    );
                                    
                                    // Générer la prévisualisation
                                    generator.generateSpectrogramFromSegment(
                                        parseInt(fftSizeField.text),
                                        parseFloat(overlapField.text),
                                        parseFloat(minFreqField.text),
                                        parseFloat(maxFreqField.text),
                                        segment.duration,
                                        parseInt(sampleRateField.text),
                                        parseFloat(dynamicRangeField.text),
                                        parseFloat(gammaCorrectionField.text),
                                        ditheringToggle.checked,
                                        parseFloat(contrastFactorField.text),
                                        highBoostToggle.checked,
                                        parseFloat(highBoostAlphaField.text),
                                        highPassToggle.checked,
                                        parseFloat(highPassCutoffField.text),
                                        parseInt(highPassOrderCombo.currentText),
                                        pageFormatCombo.currentIndex,
                                        bottomMarginField.getValue(),
                                        spectroHeightField.getValue(),
                                        writingSpeedField.getValue(),
                                        audioSegment
                                    );
                                    
                                    audioWaveformStatusText.text = "Generating segment preview...";
                                }
                                
                                contentItem: Text {
                                    text: parent.text
                                    font.family: orbitronFont.name
                                    color: parent.hovered ? window.buttonHoverText : window.buttonText
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    color: parent.hovered ? buttonHoverBackground : buttonBackground
                                    radius: borderRadius / 2
                                    
                                    Behavior on color {
                                        ColorAnimation { 
                                            duration: animationDuration
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Texte de statut pour la forme d'onde
                        Label {
                            id: audioWaveformStatusText
                            text: "No audio file loaded"
                            font.family: orbitronFont.name
                            color: fieldText
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                }
                
                // Separator
                Rectangle {
                    height: 1
                    color: separatorColor
                    Layout.fillWidth: true
                    Layout.topMargin: window.spacing
                    Layout.bottomMargin: window.spacing
                }
                
                // Note: Le bouton "Generate Spectrogram" a été supprimé car il était redondant avec "Save Preview"
                // qui utilise l'image déjà générée par "Preview Segment" sans recalcul
            }
        }
        
        // Partie droite - Prévisualisation
        Rectangle {
            id: previewContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#1A1A1A"
            visible: showPreview
            border.width: borderWidth
            border.color: borderColor
            radius: borderRadius
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: padding
                spacing: window.spacing
                
                // Titre de la prévisualisation
                Label {
                    text: "Preview"
                    font.bold: true
                    font.pixelSize: labelFontSize
                    font.family: orbitronFont.name
                    color: primaryTextColor
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Zone de prévisualisation avec ScrollView pour permettre le défilement
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    // Conteneur pour l'image de prévisualisation
                    Item {
                        id: previewImageContainer
                        anchors.fill: parent
                        
                        // Loader pour l'image de prévisualisation
                        Loader {
                            id: previewImageLoader
                            anchors.fill: parent
                            active: true
                            
                            sourceComponent: Component {
                                Image {
                                    id: previewImageItem
                                    anchors.centerIn: parent
                                    fillMode: Image.PreserveAspectFit
                                    width: parent.width
                                    height: parent.height
                                    cache: false
                                    asynchronous: true
                                    mipmap: true
                                    smooth: true
                                    
                                    // Utiliser le compteur pour forcer le rechargement
                                    source: "image://preview/" + (generator.previewCounter === 0 ? "init" : generator.previewCounter)
                                    
                                    // Gérer les erreurs de chargement
                                    Component.onCompleted: {
                                        console.log("Image component completed");
                                        console.log("Initial source: " + source);
                                    }
                                    
                                    onSourceChanged: {
                                        console.log("Image source changed: " + source);
                                        console.log("Image width: " + width + ", height: " + height);
                                        console.log("Parent width: " + parent.width + ", height: " + parent.height);
                                    }
                                    
                                    onStatusChanged: {
                                        console.log("Image status changed: " + status);
                                        if (status === Image.Ready) {
                                            console.log("Image loaded successfully: " + source);
                                            console.log("Image size: " + sourceSize.width + "x" + sourceSize.height);
                                            console.log("Image width: " + width + ", height: " + height);
                                            console.log("Image visible: " + visible);
                                            console.log("Image opacity: " + opacity);
                                        } else if (status === Image.Loading) {
                                            console.log("Image loading: " + source);
                                        } else if (status === Image.Error) {
                                            console.log("Error loading image: " + source);
                                            previewStatusText.text = "Error loading preview image"
                                            previewStatusText.color = errorColor
                                        }
                                    }
                                    
                                    onPaintedWidthChanged: {
                                        console.log("Image painted width changed: " + paintedWidth);
                                    }
                                    
                                    onPaintedHeightChanged: {
                                        console.log("Image painted height changed: " + paintedHeight);
                                    }
                                }
                            }
                        }
                        
                        // Afficher un message si aucune prévisualisation n'est disponible
                        Text {
                            anchors.centerIn: parent
                            text: "Use 'Generate Spectrogram' to generate a preview"
                            color: fieldText
                            font.family: orbitronFont.name
                            visible: !previewImageLoader.active || generator.previewCounter === 0
                        }
                    }
                }
                
                // Conteneur pour les contrôles d'exportation
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: window.spacing
                    
                    // Menu déroulant pour le format d'exportation
                    ComboBox {
                        id: exportFormatCombo
                        model: ["PNG", "PDF", "JPEG"]
                        currentIndex: 0
                        
                        background: Rectangle {
                            color: fieldBackground
                            radius: borderRadius / 2
                        }
                        
                        contentItem: Text {
                            text: exportFormatCombo.displayText
                            font.family: orbitronFont.name
                            color: fieldText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        
                        popup: Popup {
                            y: exportFormatCombo.height
                            width: exportFormatCombo.width
                            implicitHeight: contentItem.implicitHeight
                            padding: 1
                            
                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: exportFormatCombo.popup.visible ? exportFormatCombo.delegateModel : null
                                
                                ScrollBar.vertical: ScrollBar {
                                    active: exportFormatCombo.popup.visible
                                }
                            }
                            
                            background: Rectangle {
                                color: fieldBackground
                                border.color: borderColor
                                radius: borderRadius / 2
                            }
                        }
                    }
                    
                    // Bouton pour sauvegarder la prévisualisation
                    Button {
                        id: savePreviewButton
                        text: "Save Preview"
                        font.family: orbitronFont.name
                        enabled: generator.previewCounter > 0
                        
                        property bool isProcessing: false
                        
                        onClicked: {
                            if (isProcessing) return;
                            
                            isProcessing = true;
                            text = "Saving...";
                            
                            // Récupérer le format sélectionné (en minuscules)
                            var format = exportFormatCombo.currentText.toLowerCase();
                            
                            // Sauvegarder la prévisualisation actuelle dans le format sélectionné
                            generator.saveCurrentPreview(outputFolderField.text, format);
                        }
                    
                        contentItem: Text {
                            text: parent.text
                            font.family: orbitronFont.name
                            color: parent.hovered ? window.buttonHoverText : window.buttonText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            color: parent.hovered ? buttonHoverBackground : buttonBackground
                            radius: borderRadius / 2
                            
                            Behavior on color {
                                ColorAnimation {
                                    duration: animationDuration
                                }
                            }
                        }
                    }
                    
                    // Bouton pour imprimer la prévisualisation
                    Button {
                        id: printButton
                        text: "Imprimer"
                        font.family: orbitronFont.name
                        enabled: generator.previewCounter > 0
                        
                        onClicked: {
                            // Appeler la méthode d'impression du générateur
                            generator.printPreview();
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.family: orbitronFont.name
                            color: parent.hovered ? window.buttonHoverText : window.buttonText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            color: parent.hovered ? buttonHoverBackground : buttonBackground
                            radius: borderRadius / 2
                            
                            Behavior on color {
                                ColorAnimation {
                                    duration: animationDuration
                                }
                            }
                        }
                    }
                }
                
                // Texte de statut pour la prévisualisation
                Label {
                    id: previewStatusText
                    text: "No preview generated yet"
                    font.family: orbitronFont.name
                    color: fieldText
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
