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
    
    // Propriétés exposées qui peuvent être liées au modèle
    property alias fftSize: fftSizeField.value
    property alias overlap: overlapField.value
    property alias minFreq: minFreqField.value
    property alias maxFreq: maxFreqField.value
    property alias writingSpeed: writingSpeedField.value
    property alias dynamicRange: dynamicRangeField.value
    property alias gammaCorrection: gammaCorrectionField.value
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
        columns: spectrogramParametersSection.width < 500 ? 1 : 2
        Layout.fillWidth: true
        columnSpacing: AppStyles.Theme.spacing * 3 // Espacement plus large entre les colonnes
        rowSpacing: AppStyles.Theme.spacing / 2

        // FFT Size
        ParameterField {
            id: fftSizeField
            label: "FFT Size:"
            value: "8192"
            isNumeric: true
            allowDecimals: false
            minValue: 1
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            onValueEdited: parametersChanged()
        }

        // Overlap
        ParameterField {
            id: overlapField
            label: "Overlap (0..1):"
            value: "0.85"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            maxValue: 1.0
            Layout.fillWidth: true
            Layout.columnSpan: parametersGrid.columns
            onValueEdited: parametersChanged()
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
        Label {
            text: "Enable Normalization:"
            color: AppStyles.Theme.primaryTextColor
        }
        ToggleSwitch {
            id: normalizationToggle
            Layout.preferredWidth: 80
            Layout.preferredHeight: 30
            checked: true
            onToggled: parametersChanged()
        }
        
        // Dithering Toggle
        Label {
            text: "Enable Dithering:"
            color: AppStyles.Theme.primaryTextColor
        }
        ToggleSwitch {
            id: ditheringToggle
            Layout.preferredWidth: 80
            Layout.preferredHeight: 30
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
        Label {
            text: "High Boost Filter:"
            color: AppStyles.Theme.primaryTextColor
        }
        ToggleSwitch {
            id: highBoostToggle
            Layout.preferredWidth: 80
            Layout.preferredHeight: 30
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
        Label {
            text: "High-Pass Filter:"
            color: AppStyles.Theme.primaryTextColor
        }
        ToggleSwitch {
            id: highPassToggle
            Layout.preferredWidth: 80
            Layout.preferredHeight: 30
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
        Label {
            text: "Filter Order (1-8):"
            color: AppStyles.Theme.primaryTextColor
            enabled: highPassToggle.checked
        }
        ComboBox {
            id: highPassOrderCombo
            model: ["1", "2", "3", "4", "5", "6", "7", "8"]
            currentIndex: 1  // Ordre 2 par défaut
            Layout.preferredWidth: 80
            enabled: highPassToggle.checked
            
            onCurrentIndexChanged: parametersChanged()
            
            background: Rectangle {
                color: AppStyles.Theme.fieldBackground
                radius: AppStyles.Theme.borderRadius / 2
            }
            
            contentItem: Text {
                text: highPassOrderCombo.displayText
                color: AppStyles.Theme.fieldText
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
                    color: AppStyles.Theme.fieldBackground
                    border.color: AppStyles.Theme.borderColor
                    radius: AppStyles.Theme.borderRadius / 2
                }
            }
        }
    }
    
    // Champs cachés pour la compatibilité
    Item {
        id: durationField
        visible: false
        property string text: "4.0"
    }
    
    Item {
        id: sampleRateField
        visible: false
        property string text: "0" // Sera remplacé par la fréquence native du fichier
    }
}
