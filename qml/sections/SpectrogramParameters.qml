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
    
    property bool isSmall: false
    
    // Exposer directement les composants pour accès
    property alias minFreqField: minFreqField
    property alias maxFreqField: maxFreqField
    property alias writingSpeedField: writingSpeedField
    property alias binsPerSecondField: binsPerSecondField
    property alias dynamicRangeField: dynamicRangeField
    property alias gammaCorrectionField: gammaCorrectionField
    property alias highBoostAlphaField: highBoostAlphaField
    property alias highPassCutoffField: highPassCutoffField
    
    // Propriétés exposées qui peuvent être liées au modèle
    // Nouvelle propriété pour le préréglage d'overlap
    property alias overlapPreset: overlapPresetCombo.currentIndex
    
    property alias minFreq: minFreqField.value
    property alias minFreqNumeric: minFreqField.numericValue
    
    property alias maxFreq: maxFreqField.value
    property alias maxFreqNumeric: maxFreqField.numericValue
    
    property alias writingSpeed: writingSpeedField.value
    property alias writingSpeedNumeric: writingSpeedField.numericValue
    
    property alias binsPerSecond: binsPerSecondField.value
    property alias binsPerSecondNumeric: binsPerSecondField.numericValue
    
    property alias dynamicRange: dynamicRangeField.value
    property alias dynamicRangeNumeric: dynamicRangeField.numericValue
    
    property alias gammaCorrection: gammaCorrectionField.value
    property alias gammaCorrectionNumeric: gammaCorrectionField.numericValue
    property alias normalizationEnabled: normalizationToggle.checked
    property alias ditheringEnabled: ditheringToggle.checked
    property alias contrastFactor: contrastFactorField.value
    property alias highBoostEnabled: highBoostToggle.checked
    property alias highBoostAlpha: highBoostAlphaField.value
    property alias highPassEnabled: highPassToggle.checked
    property alias highPassCutoff: highPassCutoffField.value
    property alias highPassOrder: highPassOrderCombo.currentIndex
    
    // Signaux émis lorsque les paramètres changent
    signal parametersChanged()
    
    GridLayout {
        id: parametersGrid
        columns: 2
        Layout.fillWidth: true
        columnSpacing: AppStyles.Theme.spacing
        rowSpacing: AppStyles.Theme.spacing

        // Bins per second (nouveau paramètre)
        ParameterField {
            id: binsPerSecondField
            label: "Bins/s:"
            value: "150.0"
            isNumeric: true
            allowDecimals: true
            minValue: 10.0
            maxValue: 300.0
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            onValueEdited: {
                // Calculer dynamiquement la taille FFT en fonction du sample rate, bins/s et préréglage d'overlap
                var sampleRate = 192000; // Valeur par défaut (sera remplacée par le vrai sample rate)
                var hopSize = sampleRate / numericValue;
                
                // Obtenir la valeur d'overlap selon le préréglage
                var overlapValue;
                switch(overlapPresetCombo.currentIndex) {
                    case 0: overlapValue = 0.75; break; // Low
                    case 2: overlapValue = 0.95; break; // High
                    default: overlapValue = 0.85; break; // Medium
                }
                
                var diviseur = 1.0 - overlapValue;
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
                
                parametersChanged()
            }
        }
        
        // Overlap Preset
        ThemedLabel {
            text: "Overlap Preset:"
            Layout.alignment: Qt.AlignRight
        }
        FilterComboBox {
            id: overlapPresetCombo
            model: ["Low", "Medium", "High"]
            currentIndex: 1  // Medium par défaut
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.alignment: Qt.AlignLeft
            
            onCurrentIndexChanged: {
                // Recalculer la FFT et l'overlap effectif
                binsPerSecondField.valueEdited(binsPerSecondField.text);
                parametersChanged();
            }
        }
        
        // FFT Size calculée (affichage uniquement)
        ThemedLabel {
            text: "FFT Size calculée:"
            Layout.alignment: Qt.AlignRight
        }
        ThemedLabel {
            id: fftSizeCalculatedLabel
            text: "8192" // Valeur initiale
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.alignment: Qt.AlignLeft
        }
        
        // Overlap effectif calculé (affichage uniquement)
        ThemedLabel {
            text: "Overlap effectif:"
            Layout.alignment: Qt.AlignRight
        }
        ThemedLabel {
            id: overlapEffectifLabel
            text: "0.922" // Valeur initiale
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.alignment: Qt.AlignLeft
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

        // Writing Speed
        ParameterField {
            id: writingSpeedField
            label: "Writing Speed (cm/s):"
            value: "8.0"
            isNumeric: true
            allowDecimals: true
            minValue: 0.1
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            onValueEdited: parametersChanged()
        }

        // Dynamic Range
        ParameterField {
            id: dynamicRangeField
            label: "Dynamic Range (dB):"
            value: "60.0"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            onValueEdited: parametersChanged()
        }

        // Gamma Correction
        ParameterField {
            id: gammaCorrectionField
            label: "Gamma Correction:"
            value: "0.8"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            onValueEdited: parametersChanged()
        }

        // Normalization Toggle
        ThemedLabel {
            text: "Enable Normalization:"
        }
        ToggleSwitch {
            id: normalizationToggle
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.preferredHeight: AppStyles.Theme.controlHeight
            Layout.alignment: Qt.AlignLeft
            checked: true
            onToggled: parametersChanged()
        }
        
        // Dithering Toggle
        ThemedLabel {
            text: "Enable Dithering:"
            Layout.alignment: Qt.AlignRight
        }
        ToggleSwitch {
            id: ditheringToggle
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.preferredHeight: AppStyles.Theme.controlHeight
            Layout.alignment: Qt.AlignLeft
            checked: false
            onToggled: parametersChanged()
        }

        // Contrast Factor
        ParameterField {
            id: contrastFactorField
            label: "Contrast Factor:"
            value: "1.9"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            onValueEdited: parametersChanged()
        }

        // High Boost Filter
        ThemedLabel {
            text: "High Boost Filter:"
            Layout.alignment: Qt.AlignRight
        }
        ToggleSwitch {
            id: highBoostToggle
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.preferredHeight: AppStyles.Theme.controlHeight
            Layout.alignment: Qt.AlignLeft
            checked: true
            onToggled: parametersChanged()
        }

        // High Boost Alpha
        ParameterField {
            id: highBoostAlphaField
            label: "High Boost Alpha:"
            value: "0.99"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            maxValue: 1.0
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            onValueEdited: parametersChanged()
        }
        
        // High-Pass Filter Toggle
        ThemedLabel {
            text: "High-Pass Filter:"
            Layout.alignment: Qt.AlignRight
        }
        ToggleSwitch {
            id: highPassToggle
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.preferredHeight: AppStyles.Theme.controlHeight
            Layout.alignment: Qt.AlignLeft
            checked: false
            onToggled: parametersChanged()
        }
        
        // High-Pass Cutoff
        ParameterField {
            id: highPassCutoffField
            label: "Cutoff Frequency (Hz):"
            value: "100"
            isNumeric: true
            allowDecimals: true
            minValue: 1.0
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            enabled: highPassToggle.checked
            onValueEdited: parametersChanged()
        }
        
        // High-Pass Filter Order
        ThemedLabel {
            text: "Filter Order (1-8):"
            enabled: highPassToggle.checked
            Layout.alignment: Qt.AlignRight
        }
        FilterComboBox
        {
            id:               highPassOrderCombo
            model:            [ "1", "2", "3", "4", "5", "6", "7", "8" ]
            currentIndex:     1                    // "2" par défaut
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.alignment: Qt.AlignLeft
            enabled:          highPassToggle.checked

            onCurrentIndexChanged:
            {
                parametersChanged()
            }
        }
    }
    
    // Méthode pour mettre à jour les paramètres FFT calculés depuis le backend
    function updateCalculatedFftParameters(calculatedFftSize, effectiveOverlap) {
        // Mettre à jour les labels avec les valeurs calculées
        fftSizeCalculatedLabel.text = calculatedFftSize.toString();
        overlapEffectifLabel.text = effectiveOverlap.toFixed(4);
        
        console.log("Mise à jour des paramètres FFT calculés dans l'interface: FFT=" +
                    calculatedFftSize + ", Overlap effectif=" + effectiveOverlap.toFixed(4));
    }
    
    // Initialisation des valeurs calculées
    Component.onCompleted: {
        // Calculer les valeurs initiales
        binsPerSecondField.valueEdited(binsPerSecondField.value);
    }
}
