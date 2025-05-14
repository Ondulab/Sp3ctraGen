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
    
    // Propriétés de compatibilité avec le code existant
    property string binsPerSecond: binsPerSecondValue.toFixed(1)
    property double binsPerSecondNumeric: binsPerSecondValue
    
    // Compatibilité : fonction émulant le comportement du champ binsPerSecond supprimé
    function getDisplayBinsPerSecond() {
        return binsPerSecondValue.toFixed(1);
    }
    
    // Simulation d'overlap_preset maintenant géré par le curseur
    property int overlapPreset: {
        if (resolutionSlider.value < 0.25) return 0;      // Low
        else if (resolutionSlider.value < 0.75) return 1; // Medium
        else return 2;                                     // High
    }
    
    // Valeur interne pour bins/s calculée à partir du curseur
    property double binsPerSecondValue: 150.0
    
    // Propriété pour le tag de limitation
    property bool isResolutionLimited: false
    
    // Propriété pour la durée audio calculée
    property double audioDuration: 0.0
    
    // Les propriétés pour les paramètres de filtre ont été déplacées vers FilterParameters.qml
    
    // Signaux émis lorsque les paramètres changent
    signal parametersChanged()
    
    // Pas besoin de champ caché, l'ancien composant est complètement remplacé par le curseur
    
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
                    
                    // Calculer la durée audio
                    audioDuration = generator.calculateAudioDuration();
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
            spacing: AppStyles.Theme.spacing
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            
            // Titre simplifié
            ThemedLabel {
                text: "Resolution:"
            }
            
            // Message d'avertissement pour la limitation de résolution
            ThemedLabel {
                id: resolutionLimitedLabel
                text: "Limited by print horizontal resolution"
                color: "orange"
                font.italic: true
                font.pixelSize: smallFontSize
                visible: isResolutionLimited
                width: parent.width
            }
            
            // Étiquettes Temporal/Spectral au-dessus du curseur
            Row {
                width: parent.width
                
                ThemedLabel {
                    text: "Temporal"
                    font.pixelSize: smallFontSize
                    color: Qt.rgba(0.9, 0.9, 0.9, 0.9) // Blanc moins intense
                    width: 75
                }
                
                Item { width: parent.width - 155; height: 1 } // Spacer
                
                ThemedLabel {
                    text: "Spectral"
                    font.pixelSize: smallFontSize
                    color: Qt.rgba(0.9, 0.9, 0.9, 0.9) // Blanc moins intense
                    width: 75
                    horizontalAlignment: Text.AlignRight
                }
            }
            
            // Slider personnalisé avec poignée centrée
            Item {
                id: customSlider
                width: parent.width
                height: 30
                property double value: 0.5  // La valeur du slider (0.0 - 1.0)
                property double visualPos: width * value  // Position visuelle
                
                // Fond sombre du slider
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: 4
                    radius: 2
                    color: "#333333"
                }
                
                // Partie active du slider (ligne blanche) - partant du centre
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    height: 4
                    
                    // Calcul de la position et largeur en fonction de la position du curseur
                    width: Math.abs(customSlider.visualPos - parent.width / 2)
                    x: customSlider.visualPos > parent.width / 2 ? parent.width / 2 : customSlider.visualPos
                    color: "#ffffff"
                    radius: 2
                }
                
                // Poignée du slider (curseur)
                Rectangle {
                    id: handle
                    width: 16
                    height: 16
                    radius: 8
                    color: "#ffffff"
                    border.color: "#cccccc"
                    border.width: 1
                    
                    // Position centrée sur la valeur
                    x: customSlider.visualPos - width/2
                    y: customSlider.height/2 - height/2
                    
                    // Animation pour un déplacement fluide
                    Behavior on x {
                        NumberAnimation { duration: 50 }
                    }
                }
                
                // Marques pour les trois positions de référence
                Rectangle {
                    width: 2
                    height: 8
                    color: Qt.rgba(0.9, 0.9, 0.9, 0.7) // Blanc moins intense
                    x: 0
                    anchors.bottom: parent.bottom
                }
                
                Rectangle {
                    width: 2
                    height: 8
                    color: Qt.rgba(0.9, 0.9, 0.9, 0.7) // Blanc moins intense
                    x: parent.width * 0.5 - 1
                    anchors.bottom: parent.bottom
                }
                
                Rectangle {
                    width: 2
                    height: 8
                    color: Qt.rgba(0.9, 0.9, 0.9, 0.7) // Blanc moins intense
                    x: parent.width - 2
                    anchors.bottom: parent.bottom
                }
                
                // Zone de détection pour le drag
                MouseArea {
                    anchors.fill: parent
                    drag.target: handle
                    drag.axis: Drag.XAxis
                    drag.minimumX: -handle.width/2
                    drag.maximumX: parent.width - handle.width/2
                    
                    // Permet de cliquer n'importe où sur le slider
                    onPressed: {
                        handle.x = mouse.x - handle.width/2
                        updateSliderValue()
                    }
                    
                    onPositionChanged: {
                        if (pressed) updateSliderValue()
                    }
                    
                    // Fonction pour mettre à jour la valeur du slider (0.0-1.0)
                    function updateSliderValue() {
                        var newValue = (handle.x + handle.width/2) / customSlider.width
                        // Limiter entre 0 et 1
                        newValue = Math.max(0, Math.min(1, newValue))
                        customSlider.value = newValue
                        resolutionSlider.value = newValue  // Mise à jour du slider caché
                    }
                }
            }
            
            // Slider invisible pour compatibilité avec le reste du code
            Slider {
                id: resolutionSlider
                visible: false
                from: 0
                to: 1
                value: customSlider.value
                stepSize: 0.01
                
                onValueChanged: {
                    if (value !== customSlider.value) {
                        customSlider.value = value
                        customSlider.visualPos = customSlider.width * value
                    }
                    
                    if (generator) {
                        // Calculer le bps en fonction de la position du curseur
                        binsPerSecondValue = generator.calculateBpsFromSlider(value, writingSpeedNumeric);
                        
                        // Vérifier si la limitation est atteinte
                        isResolutionLimited = generator.isResolutionLimited();
                        
                        // Calculer la durée audio
                        audioDuration = generator.calculateAudioDuration();
                        
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
                    text: binsPerSecondNumeric.toFixed(1)
                    font.pixelSize: smallFontSize
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredWidth: parent.width / 2 - 10
                }
                
                // FFT Size calculée
                ThemedLabel {
                    text: "FFT Size:"
                    font.pixelSize: smallFontSize
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: parent.width / 2 - 10
                }
                ThemedLabel {
                    id: fftSizeCalculatedLabel
                    text: "8192" // Valeur initiale
                    font.pixelSize: smallFontSize
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredWidth: parent.width / 2 - 10
                }
                
                // Overlap effectif calculé
                ThemedLabel {
                    text: "Effective Overlap:"
                    font.pixelSize: smallFontSize
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: parent.width / 2 - 10
                }
                ThemedLabel {
                    id: overlapEffectifLabel
                    text: "0.922" // Valeur initiale
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
    
    // Méthode pour calculer et mettre à jour les paramètres dérivés
    function updateCalculatedParameters() {
        if (generator) {
            // Calculer l'overlap à partir de la position du curseur
            var newOverlap = generator.calculateOverlapFromSlider(resolutionSlider.value);
        } else {
            console.error("Generator not available for overlap calculation");
            var newOverlap = 0.75; // Valeur par défaut
        }
        
        // Calculer la FFT size et l'overlap effectif
        var sampleRate = 192000; // Valeur par défaut (sera remplacée par le vrai sample rate)
        var hopSize = sampleRate / binsPerSecondValue;
        var diviseur = 1.0 - newOverlap;
        var calculatedFft = hopSize / diviseur;
        
        // Arrondir à la puissance de 2 supérieure
        var powerOf2 = 1;
        while (powerOf2 < calculatedFft) {
            powerOf2 *= 2;
        }
        
        // Mettre à jour l'affichage de la FFT calculée
        fftSizeCalculatedLabel.text = powerOf2.toString();
        
        // Calculer l'overlap effectif
        var effectiveOverlap = 1.0 - (hopSize / powerOf2);
        overlapEffectifLabel.text = effectiveOverlap.toFixed(4);
        
        // Mettre à jour l'affichage de la durée audio
        audioDurationLabel.text = audioDuration.toFixed(2);
    }
    
    // Méthode pour mettre à jour les paramètres FFT calculés depuis le backend
    function updateCalculatedFftParameters(calculatedFftSize, effectiveOverlap) {
        // Mettre à jour les labels avec les valeurs calculées
        fftSizeCalculatedLabel.text = calculatedFftSize.toString();
        overlapEffectifLabel.text = effectiveOverlap.toFixed(4);
        
        console.log("Mise à jour des paramètres FFT calculés dans l'interface: FFT=" +
                    calculatedFftSize + ", Overlap effectif=" + effectiveOverlap.toFixed(4));
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
            isResolutionLimited = false;
        }
    }
}
