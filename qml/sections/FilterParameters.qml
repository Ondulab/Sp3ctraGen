import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"
import "../styles" as AppStyles

/**
 * Section des paramètres de filtrage et traitement
 *
 * Cette section contient tous les contrôles pour configurer
 * les paramètres de traitement du signal et les filtres.
 */
SectionContainer {
    id: filterParametersSection
    title: "Signal Processing"
    
    property bool isSmall: false
    property var generator // Référence au générateur de spectrogrammes
    
    // Propriétés exposées
    property alias dynamicRange: dynamicRangeField.value
    property alias dynamicRangeNumeric: dynamicRangeField.numericValue
    
    property alias gammaCorrection: gammaCorrectionField.value
    property alias gammaCorrectionNumeric: gammaCorrectionField.numericValue
    property bool normalizationEnabled: true  // Valeur par défaut remplaçant le toggle supprimé
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
        id: filterGrid
        columns: 2
        Layout.fillWidth: true
        columnSpacing: AppStyles.Theme.spacing
        rowSpacing: AppStyles.Theme.spacing
        
        // Dynamic Range
        ParameterField {
            id: dynamicRangeField
            label: "Dynamic Range (dB):"
            value: "60.0"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            Layout.fillWidth: true
            Layout.columnSpan: filterGrid.columns
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
            Layout.columnSpan: filterGrid.columns
            onValueEdited: parametersChanged()
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
            Layout.columnSpan: filterGrid.columns
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
            Layout.columnSpan: filterGrid.columns
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
            value: "100.0"
            isNumeric: true
            allowDecimals: true
            minValue: 1.0
            Layout.fillWidth: true
            Layout.columnSpan: filterGrid.columns
            enabled: highPassToggle.checked
            onValueEdited: parametersChanged()
        }
        
        // High-Pass Filter Order
        ThemedLabel {
            text: "Filter Order (1-8):"
            enabled: highPassToggle.checked
            Layout.alignment: Qt.AlignRight
        }
        FilterComboBox {
            id: highPassOrderCombo
            model: [ "1", "2", "3", "4", "5", "6", "7", "8" ]
            currentIndex: 1  // "2" par défaut
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.alignment: Qt.AlignLeft
            enabled: highPassToggle.checked
            
            onCurrentIndexChanged: {
                parametersChanged()
            }
        }
    }
}