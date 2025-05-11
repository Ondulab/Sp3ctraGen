import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"
import "../styles" as AppStyles

/**
 * Section des paramètres de format de sortie
 * 
 * Cette section contient tous les contrôles pour configurer
 * le format de sortie du spectrogramme (dimensions, échelles, etc).
 */
SectionContainer {
    id: outputFormatSection
    title: "Output Format"
    
    property bool isSmall: false
    
    // Propriétés exposées
    property alias pageFormat: pageFormatCombo.currentIndex
    property alias pageFormatText: pageFormatCombo.currentText
    property alias bottomMargin: bottomMarginField.value
    property alias spectroHeight: spectroHeightField.value
    property alias verticalScaleEnabled: verticalScaleToggle.checked
    property alias bottomReferenceLineEnabled: bottomReferenceLineToggle.checked
    property alias bottomReferenceLineOffset: bottomReferenceLineOffsetField.value
    property alias topReferenceLineEnabled: topReferenceLineToggle.checked
    property alias topReferenceLineOffset: topReferenceLineOffsetField.value
    property alias displayParametersEnabled: displayParametersToggle.checked
    
    // Signal émis lorsque le format change
    signal formatChanged()
    
    GridLayout {
        id: formatGrid
        columns: 2
        Layout.fillWidth: true
        columnSpacing: AppStyles.Theme.spacing
        rowSpacing: AppStyles.Theme.spacing
        
        // Format de page
        ThemedLabel {
            text: "Page Format:"
        }
        FilterComboBox {
            id:             pageFormatCombo
            model:          ["A4 Portrait", "A3 Landscape"]
            currentIndex:   0
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.alignment: Qt.AlignLeft
            onCurrentIndexChanged: formatChanged()
        }
        
        // Marge inférieure
        ParameterField {
            id: bottomMarginField
            label: "Bottom Margin (mm):"
            value: "50,0"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            Layout.fillWidth: true
            Layout.columnSpan: formatGrid.columns
            onValueEdited: formatChanged()
        }
        
        // Hauteur du spectrogramme
        ParameterField {
            id: spectroHeightField
            label: "Spectrogram Height (mm):"
            value: "216,7"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            Layout.fillWidth: true
            Layout.columnSpan: formatGrid.columns
            onValueEdited: formatChanged()
        }
        
        // Échelle verticale
        ThemedLabel {
            text: "Vertical Scale:"
            Layout.alignment: Qt.AlignRight
        }
        ToggleSwitch {
            id: verticalScaleToggle
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.preferredHeight: AppStyles.Theme.controlHeight
            Layout.alignment: Qt.AlignLeft
            checked: true
            onToggled: formatChanged()
        }
        
        // Ligne de référence inférieure
        ThemedLabel {
            text: "Bottom Reference Line:"
            Layout.alignment: Qt.AlignRight
        }
        ToggleSwitch {
            id: bottomReferenceLineToggle
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.preferredHeight: AppStyles.Theme.controlHeight
            Layout.alignment: Qt.AlignLeft
            checked: false
            onToggled: formatChanged()
        }
        
        // Décalage de la ligne de référence inférieure
        ParameterField {
            id: bottomReferenceLineOffsetField
            label: "Bottom Offset (mm):"
            value: "34,75"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            maxValue: 100.0
            Layout.fillWidth: true
            Layout.columnSpan: formatGrid.columns
            enabled: bottomReferenceLineToggle.checked
            onValueEdited: formatChanged()
        }
        
        // Ligne de référence supérieure
        ThemedLabel {
            text: "Top Reference Line:"
            Layout.alignment: Qt.AlignRight
        }
        ToggleSwitch {
            id: topReferenceLineToggle
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.preferredHeight: AppStyles.Theme.controlHeight
            Layout.alignment: Qt.AlignLeft
            checked: false
            onToggled: formatChanged()
        }
        
        // Décalage de la ligne de référence supérieure
        ParameterField {
            id: topReferenceLineOffsetField
            label: "Top Offset (mm):"
            value: "12,55"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            Layout.fillWidth: true
            Layout.columnSpan: formatGrid.columns
            enabled: topReferenceLineToggle.checked
            onValueEdited: formatChanged()
        }
        
        // Affichage des paramètres
        ThemedLabel {
            text: "Show Parameters:"
            Layout.alignment: Qt.AlignRight
        }
        ToggleSwitch {
            id: displayParametersToggle
            Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
            Layout.preferredHeight: AppStyles.Theme.controlHeight
            Layout.alignment: Qt.AlignLeft
            checked: false
            onToggled: formatChanged()
        }
    }
}
