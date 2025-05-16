import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"
import "../styles" as AppStyles

/**
 * Section des paramètres du spectrogramme
 *
 * Cette section contient tous les contrôles pour configurer
 * les paramètres de génération du spectrogramme.
 */
SectionContainer {
    id: spectrogramParametersSection
    title: "Spectrogram Parameters"
    
    // Valeurs par défaut pour le style
    readonly property int defaultFontSize: AppStyles.Theme.fontSizeTiny
    readonly property int smallFontSize: AppStyles.Theme.fontSizeTiny - 2
    readonly property color separatorColor: AppStyles.Theme.separatorColor
    
    property bool isSmall: false
    
    // Référence au générateur de spectrogrammes
    property var generator
    
    // Exposer directement les composants pour accès
    property alias minFreqField: minFreqField
    property alias maxFreqField: maxFreqField
    property alias writingSpeedField: writingSpeedField
    property alias pageFormatCombo: pageFormatCombo
    property alias printerDpiField: printerDpiField
    
    // Propriétés exposées qui peuvent être liées au modèle
    // Propriété pour le curseur de résolution
    property alias resolutionSliderValue: resolutionSlider.value
    
    property alias minFreq: minFreqField.value
    property alias minFreqNumeric: minFreqField.numericValue
    
    property alias maxFreq: maxFreqField.value
    property alias maxFreqNumeric: maxFreqField.numericValue
    
    property alias writingSpeed: writingSpeedField.value
    property alias writingSpeedNumeric: writingSpeedField.numericValue
    
    // Nouvelles propriétés pour le format de page et DPI (déplacées depuis OutputFormat)
    property alias pageFormat: pageFormatCombo.currentIndex
    property alias pageFormatText: pageFormatCombo.currentText
    property alias printerDpi: printerDpiField.value
    property alias printerDpiNumeric: printerDpiField.numericValue
    
    // Valeurs calculées directement à partir du curseur
    
    // Valeur interne pour bins/s calculée à partir du curseur
    property double binsPerSecondValue: 150.0
    
    // Propriétés pour afficher les valeurs calculées par le backend
    property int calculatedFftSize: 4096   // Valeur par défaut
    property double calculatedOverlap: 0.85 // Valeur par défaut
    
    // Propriété pour le tag de limitation
    property bool isResolutionLimited: false
    
    // Propriété pour la durée audio calculée à partir du ViewModel
    property double audioDuration: 0.0
    
    // Les propriétés pour les paramètres de filtre ont été déplacées vers FilterParameters.qml
    
    // Signaux émis lorsque les paramètres changent
    signal parametersChanged()
    signal formatChanged() // Signal pour les changements de format (déplacé depuis OutputFormat)
    
    // Configuration du layout de l'interface utilisateur
    
    GridLayout {
        id: parametersGrid
        columns: 2
        Layout.fillWidth: true
        columnSpacing: AppStyles.Theme.spacing
        rowSpacing: AppStyles.Theme.spacing

        // Format de page (ajouté depuis OutputFormat)
        ThemedLabel {
            text: "Page Format:"
        }
        FilterComboBox {
            id: pageFormatCombo
            model: ["A4 Portrait", "A3 Landscape"]
            currentIndex: 0
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.alignment: Qt.AlignLeft
            onCurrentIndexChanged: formatChanged()
        }
        
        // Résolution d'impression (DPI) (ajouté depuis OutputFormat)
        ParameterField {
            id: printerDpiField
            label: "Resolution (DPI):"
            value: "400.0"
            isNumeric: true
            allowDecimals: true
            minValue: 72.0
            maxValue: 1200.0
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            onValueEdited: formatChanged()
        }

        // Writing Speed - Déplacé en haut
        ParameterField {
            id: writingSpeedField
            label: "Writing Speed (cm/s):"
            value: "8.0"
            isNumeric: true
            allowDecimals: true
            minValue: 0.1
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            onValueEdited: {
                console.log("Valeur numérique changée: " + writingSpeedNumeric);
                
                if (generator && generator.parameters) {
                    // Utiliser le modèle de paramètres directement
                    generator.parameters.beginUpdate();
                    generator.parameters.writingSpeed = writingSpeedNumeric;
                    generator.parameters.endUpdate();
                    
                    // Note: Les valeurs binsPerSecond, audioDuration et isResolutionLimited 
                    // seront mises à jour par le signal calculatedParametersUpdated dans main.qml
                } else {
                    console.error("Generator or parameters not available");
                }
                
                parametersChanged();
            }
        }

        // Curseur de résolution (remplace bins/s et overlap)
        Column {
            spacing: 2 // Réduire considérablement l'espacement vertical entre éléments
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            
            // En-tête avec titre et description
            Column {
                width: parent.width
                spacing: 2
                
                // Titre principal
                ThemedLabel {
                    text: "Resolution:"
                }
            }
            
            // Conteneur pour les libellés et le slider
            Item {
                id: sliderContainer
                width: parent.width
                height: 36 // Hauteur réduite
                
                // Libellés
                Row {
                    width: parent.width
                    height: childrenRect.height
                    
                    Text {
                        text: "Temporel"
                        color: "white"
                        font.pixelSize: smallFontSize
                        font.bold: true
                        width: parent.width / 2
                    }
                    
                    Text {
                        text: "Spectral"
                        color: "white"
                        font.pixelSize: smallFontSize
                        font.bold: true
                        width: parent.width / 2
                        horizontalAlignment: Text.AlignRight
                    }
                }
                
                // Slider standard mais stylisé
                Slider {
                    id: resolutionSlider
                    anchors.top: parent.top
                    anchors.topMargin: 16 // Espace réduit
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 20
                    
                    // Propriétés par défaut
                    from: 0
                    to: 1
                    value: 0.5
                    stepSize: 0.01
                    
                    // Style personnalisé pour le fond du slider
                    background: Rectangle {
                        x: resolutionSlider.leftPadding
                        y: resolutionSlider.topPadding + resolutionSlider.availableHeight / 2 - height / 2
                        width: resolutionSlider.availableWidth
                        height: 4
                        radius: 2
                        color: "#333333"
                        
                        // Partie active du slider
                        Rectangle {
                            width: Math.abs(resolutionSlider.visualPosition * parent.width - parent.width / 2)
                            height: parent.height
                            color: "white"
                            radius: 2
                            x: resolutionSlider.visualPosition * parent.width < parent.width / 2 
                               ? resolutionSlider.visualPosition * parent.width 
                               : parent.width / 2
                        }
                        
                        // Points de repère
                        Rectangle {
                            width: 2
                            height: 8
                            color: Qt.rgba(0.9, 0.9, 0.9, 0.7) // Blanc moins intense
                            x: 0
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: -8
                        }
                        
                        Rectangle {
                            width: 2
                            height: 8
                            color: Qt.rgba(0.9, 0.9, 0.9, 0.7) // Blanc moins intense
                            x: parent.width * 0.5 - 1
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: -8
                        }
                        
                        Rectangle {
                            width: 2
                            height: 8
                            color: Qt.rgba(0.9, 0.9, 0.9, 0.7) // Blanc moins intense
                            x: parent.width - 2
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: -8
                        }
                    }
                    
                    // Style personnalisé pour le bouton du slider
                    handle: Rectangle {
                        x: resolutionSlider.leftPadding + resolutionSlider.visualPosition * (resolutionSlider.availableWidth - width)
                        y: resolutionSlider.topPadding + resolutionSlider.availableHeight / 2 - height / 2
                        width: 16
                        height: 16
                        radius: 8
                        color: "white"
                        border.color: "#cccccc"
                        border.width: 1
                    }
                    
                    // Mettre à jour les valeurs calculées lorsque le slider change
                    onValueChanged: {
                        console.log("*** onResolutionValueChanged triggered ***");
                        console.log("  - resolutionValue:", value);
                        
                        if (generator && generator.parameters) {
                            // Utiliser le modèle de paramètres directement
                            generator.parameters.beginUpdate();
                            generator.parameters.resolutionSliderValue = value;
                            generator.parameters.endUpdate();
                            
                            // Note: Les valeurs binsPerSecond, audioDuration, isResolutionLimited 
                            // et effectiveOverlap seront mises à jour par le signal 
                            // calculatedParametersUpdated dans main.qml
                        } else {
                            console.error("Generator or parameters not available");
                        }

                        parametersChanged();
                    }
                }
            }

            // Affichage des valeurs dérivées
            GridLayout {
                columns: 2
                width: parent.width
                columnSpacing: AppStyles.Theme.spacing
                rowSpacing: AppStyles.Theme.spacing / 2
                Layout.topMargin: 5
                
                // Bins par seconde
                ThemedLabel {
                    text: "Bins/s:"
                    font.pixelSize: smallFontSize
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: parent.width / 2 - 10
                }
                ThemedLabel {
                    id: binsPerSecondValueLabel
                    text: binsPerSecondValue.toFixed(1)
                    color: "white"
                    font.pixelSize: smallFontSize
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredWidth: parent.width / 2 - 10
                }
                
                // Taille FFT calculée
                ThemedLabel {
                    text: "FFT Size:"
                    font.pixelSize: smallFontSize
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: parent.width / 2 - 10
                }
                ThemedLabel {
                    id: fftSizeLabel
                    text: calculatedFftSize.toString()
                    color: "white"
                    font.pixelSize: smallFontSize
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredWidth: parent.width / 2 - 10
                }
                
                // Overlap calculé
                ThemedLabel {
                    text: "Overlap:"
                    font.pixelSize: smallFontSize
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: parent.width / 2 - 10
                }
                ThemedLabel {
                    id: overlapLabel
                    text: calculatedOverlap.toFixed(3)
                    color: "white"
                    font.pixelSize: smallFontSize
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredWidth: parent.width / 2 - 10
                }
                
                // Durée audio calculée
                ThemedLabel {
                    text: "Audio Duration (s):"
                    font.pixelSize: smallFontSize
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: parent.width / 2 - 10
                }
                ThemedLabel {
                    id: audioDurationLabel
                    text: audioDuration.toFixed(2) // Formaté avec 2 décimales
                    color: "white"
                    font.pixelSize: smallFontSize
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredWidth: parent.width / 2 - 10
                }
            }
        }

        // Min Frequency
        ParameterField {
            id: minFreqField
            label: "Min Frequency (Hz):"
            value: "65"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            onValueEdited: {
                // Mettre à jour les paramètres directement via le modèle parameters
                if (generator && generator.parameters) {
                    generator.parameters.beginUpdate();
                    generator.parameters.minFreq = minFreqNumeric;
                    generator.parameters.endUpdate();
                } else {
                    console.error("Generator or parameters not available");
                }
                parametersChanged(); // Signal that parameters have changed (for other components)
            }
        }

        // Max Frequency
        ParameterField {
            id: maxFreqField
            label: "Max Frequency (Hz):"
            value: "16640"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            onValueEdited: {
                // Mettre à jour les paramètres directement via le modèle parameters
                if (generator && generator.parameters) {
                    generator.parameters.beginUpdate();
                    generator.parameters.maxFreq = maxFreqNumeric;
                    generator.parameters.endUpdate();
                } else {
                    console.error("Generator or parameters not available");
                }
                parametersChanged(); // Signal that parameters have changed (for other components)
            }
        }

        // Les paramètres de filtre ont été déplacés vers une section séparée FilterParameters.qml
    }

    // Méthode pour mettre à jour toutes les valeurs calculées reçues du backend
    function updateAllCalculatedParameters(binsPerSecond, calculatedFftSize, effectiveOverlap, audioDuration, isResolutionLimited) {
        console.log("SpectrogramParameters: updateAllCalculatedParameters() called");
        // Update QML properties with values from backend
        spectrogramParametersSection.binsPerSecondValue = binsPerSecond;
        spectrogramParametersSection.calculatedFftSize = calculatedFftSize;
        spectrogramParametersSection.calculatedOverlap = effectiveOverlap;
        spectrogramParametersSection.audioDuration = audioDuration;
        spectrogramParametersSection.isResolutionLimited = isResolutionLimited;

        // Update labels (they are bound to the properties, but explicit update can ensure)
        binsPerSecondValueLabel.text = binsPerSecondValue.toFixed(1);
        fftSizeLabel.text = calculatedFftSize.toString();
        overlapLabel.text = calculatedOverlap.toFixed(3);
        audioDurationLabel.text = audioDuration.toFixed(2);

        console.log("SpectrogramParameters: UI updated with calculated values.");
    }

    // Timer pour réessayer l'initialisation des paramètres si generator.parameters n'est pas disponible immédiatement
    Timer {
        id: initializationTimer
        interval: 100 // 100ms entre les tentatives
        repeat: true
        running: false
        property int attemptCount: 0
        property int maxAttempts: 30 // Max 3 secondes (30 * 100ms)
        
        onTriggered: {
            attemptCount++;
            console.log("SpectrogramParameters - Tentative d'initialisation #" + attemptCount);
            
            if (generator) {
                console.log("  - parameters disponible:", generator.parameters ? "oui" : "non");
                
                if (generator.parameters) {
                    console.log("  - generator.parameters est maintenant disponible");
                    // Arrêter le timer
                    running = false;
                    
                    // Initialiser les paramètres
                    try {
                        generator.parameters.beginUpdate();
                        generator.parameters.minFreq = minFreqNumeric;
                        generator.parameters.maxFreq = maxFreqNumeric;
                        generator.parameters.resolutionSliderValue = resolutionSlider.value;
                        generator.parameters.writingSpeed = writingSpeedNumeric;
                        generator.parameters.pageFormat = pageFormatCombo.currentIndex;
                        generator.parameters.printerDpi = printerDpiField.numericValue;
                        generator.parameters.endUpdate();
                        console.log("  - initialisation terminée avec succès");
                    } catch (e) {
                        console.error("Exception lors de l'initialisation des paramètres:", e);
                    }
                } else if (attemptCount >= maxAttempts) {
                    console.error("Impossible d'initialiser les paramètres après " + maxAttempts + " tentatives");
                    running = false;
                }
            } else {
                console.warn("Generator toujours non disponible, tentative " + attemptCount);
                if (attemptCount >= maxAttempts) {
                    console.error("Impossible d'initialiser les paramètres après " + maxAttempts + " tentatives");
                    running = false;
                }
            }
        }
    }
    
    // Initialisation
    Component.onCompleted: {
        console.log("SpectrogramParameters - Component.onCompleted");
        console.log("  - generator disponible:", generator ? "oui" : "non");
        
        if (generator) {
            console.log("  - parameters disponible:", generator.parameters ? "oui" : "non");
        }
        
        // Initialiser les valeurs par défaut de toute façon
        binsPerSecondValue = 150.0;
        audioDuration = 2.625; // 21cm / 8cm/s (example based on default values)
        calculatedFftSize = 4096;
        calculatedOverlap = 0.85;
        isResolutionLimited = false;
        
        // Initialiser les paramètres du modèle si possible immédiatement
        if (generator && generator.parameters) {
            console.log("  - début initialisation avec generator.parameters");
            try {
                generator.parameters.beginUpdate();
                generator.parameters.minFreq = minFreqNumeric;
                generator.parameters.maxFreq = maxFreqNumeric;
                generator.parameters.resolutionSliderValue = resolutionSlider.value;
                generator.parameters.writingSpeed = writingSpeedNumeric;
                generator.parameters.pageFormat = pageFormatCombo.currentIndex;
                generator.parameters.printerDpi = printerDpiField.numericValue;
                generator.parameters.endUpdate();
                console.log("  - initialisation terminée avec succès");
            } catch (e) {
                console.error("Exception lors de l'initialisation des paramètres:", e);
            }
        } else {
            console.warn("Generator ou parameters non disponible lors de l'initialisation");
            console.log("  - démarrage du timer pour réessayer plus tard");
            // Démarrer le timer pour réessayer plus tard
            initializationTimer.running = true;
        }
    }
}
