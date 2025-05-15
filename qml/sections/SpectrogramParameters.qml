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
    
    // Propriétés exposées qui peuvent être liées au modèle
    // Propriété pour le curseur de résolution
    property alias resolutionSliderValue: resolutionSlider.value
    
    property alias minFreq: minFreqField.value
    property alias minFreqNumeric: minFreqField.numericValue
    
    property alias maxFreq: maxFreqField.value
    property alias maxFreqNumeric: maxFreqField.numericValue
    
    property alias writingSpeed: writingSpeedField.value
    property alias writingSpeedNumeric: writingSpeedField.numericValue
    
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
    
    // Configuration du layout de l'interface utilisateur
    
    GridLayout {
        id: parametersGrid
        columns: 2
        Layout.fillWidth: true
        columnSpacing: AppStyles.Theme.spacing
        rowSpacing: AppStyles.Theme.spacing

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
                // Mettre à jour les paramètres calculés lorsque la vitesse d'écriture change
                
                if (generator) {
                    // Recalculer les bins/s car maxBps dépend de la vitesse d'écriture
                    binsPerSecondValue = generator.calculateBpsFromSlider(resolutionSlider.value, writingSpeedNumeric);
                    
                    // Vérifier si la limitation est atteinte
                    isResolutionLimited = generator.isResolutionLimited();
                    
                    // IMPORTANT: Recalculer la durée audio lorsque la vitesse d'écriture change
                    audioDuration = generator.calculateAudioDuration();
                    console.log("Vitesse d'écriture changée: " + writingSpeedNumeric + 
                              " cm/s, nouvelle durée audio: " + audioDuration.toFixed(2) + "s");
                } else {
                    console.error("Generator not available for calculations");
                }
                
                // Mettre à jour les autres paramètres calculés
                updateCalculatedParameters();
                
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
                        if (generator) {
                            // Calculer le bps en fonction de la position du curseur
                            binsPerSecondValue = generator.calculateBpsFromSlider(value, writingSpeedNumeric);
                            
                            // Vérifier si la limitation est atteinte
                            isResolutionLimited = generator.isResolutionLimited();
                            
                        // Calculer la durée audio et forcer sa mise à jour dans l'interface
                        audioDuration = generator.calculateAudioDuration();
                        console.log("Slider de résolution changé: valeur=" + value + 
                                  ", nouvelle durée audio: " + audioDuration.toFixed(2) + "s");
                        forceUpdateDisplay();
                            
                            // Calculer l'overlap en fonction de la position du curseur
                            var newOverlap = generator.calculateOverlapFromSlider(value);
                        } else {
                            console.error("Generator not available for calculations");
                        }
                        
                        // Recalculer la FFT size et l'overlap effectif
                        updateCalculatedParameters();
                        
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
            onValueEdited: parametersChanged()
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
            onValueEdited: parametersChanged()
        }

        // Les paramètres de filtre ont été déplacés vers une section séparée FilterParameters.qml
    }
    
    // Item pour contenir le Timer (nécessaire pour la structure QML)
    Item {
        id: timerContainer
        width: 0
        height: 0
        visible: false
        
        // Timer pour forcer le rafraîchissement de l'interface
        Timer {
            id: refreshTimer
            interval: 100
            repeat: false
            onTriggered: {
                // Force un rafraîchissement complet des valeurs
                audioDurationLabel.text = "";
                audioDurationLabel.text = audioDuration.toFixed(2);
                
                binsPerSecondValueLabel.text = "";
                binsPerSecondValueLabel.text = binsPerSecondValue.toFixed(1);
                
                fftSizeLabel.text = "";
                fftSizeLabel.text = calculatedFftSize.toString();
                
                overlapLabel.text = "";
                overlapLabel.text = calculatedOverlap.toFixed(3);
            }
        }
    }

    // Méthode pour mettre à jour les valeurs affichées
    function updateCalculatedParameters() {
        console.log("SpectrogramParameters: updateCalculatedParameters() appelé avec audioDuration=" + audioDuration);
        
        // Mettre à jour l'affichage de la durée audio
        audioDurationLabel.text = audioDuration.toFixed(2);
        
        // Mettre à jour l'affichage des bins/s
        binsPerSecondValueLabel.text = binsPerSecondValue.toFixed(1);
        
        // Mettre à jour l'affichage de la taille FFT et de l'overlap
        fftSizeLabel.text = calculatedFftSize.toString();
        overlapLabel.text = calculatedOverlap.toFixed(3);
    }
    
    // Fonction publique pour forcer une mise à jour externe
    function forceUpdateDisplay() {
        updateCalculatedParameters();
        // Déclencher le timer pour forcer un rafraîchissement complet
        refreshTimer.restart();
    }
    
    // Surveiller les changements de audioDuration pour mettre à jour l'affichage
    onAudioDurationChanged: {
        console.log("SpectrogramParameters: onAudioDurationChanged: nouvelle valeur=" + audioDuration);
        updateCalculatedParameters();
    }
    
    // Méthode pour mettre à jour les paramètres FFT calculés depuis le backend
    function updateCalculatedFftParameters(calculatedFftSize, effectiveOverlap) {
        // Mettre à jour les propriétés
        this.calculatedFftSize = calculatedFftSize;
        this.calculatedOverlap = effectiveOverlap;
        
        // Forcer une mise à jour des labels
        updateCalculatedParameters();
        
        console.log("FFT parameters updated: FFT Size = " + calculatedFftSize +
                    ", Overlap = " + effectiveOverlap.toFixed(3));
    }
    
    // Initialisation
    Component.onCompleted: {
        // Calculer les valeurs initiales
        if (generator) {
            binsPerSecondValue = generator.calculateBpsFromSlider(resolutionSlider.value, writingSpeedNumeric);
            audioDuration = generator.calculateAudioDuration();
            isResolutionLimited = generator.isResolutionLimited();
            updateCalculatedParameters();
        } else {
            console.warn("Generator not available during initialization");
            // Valeurs par défaut
            binsPerSecondValue = 150.0;
            audioDuration = 2.625; // 21cm / 8cm/s
            calculatedFftSize = 4096;
            calculatedOverlap = 0.85;
            isResolutionLimited = false;
        }
    }
}
