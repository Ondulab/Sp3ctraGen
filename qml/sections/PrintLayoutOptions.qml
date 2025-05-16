import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"
import "../styles" as AppStyles

/**
 * Section des options de mise en page d'impression
 * 
 * Cette section contient tous les contrôles pour configurer
 * la mise en page du spectrogramme imprimé (marges, annotations, etc).
 */
SectionContainer {
    id: printLayoutSection
    title: "Print Layout Options"
    
    property bool isSmall: false
    
    // Propriétés exposées
    property alias bottomMargin: bottomMarginField.value
    property alias spectroHeight: spectroHeightField.value
    property alias verticalScaleEnabled: verticalScaleToggle.checked
    property alias bottomReferenceLineEnabled: bottomReferenceLineToggle.checked
    property alias bottomReferenceLineOffset: bottomReferenceLineOffsetField.value
    property alias topReferenceLineEnabled: topReferenceLineToggle.checked
    property alias topReferenceLineOffset: topReferenceLineOffsetField.value
    property alias displayParametersEnabled: displayParametersToggle.checked
    
    // Signal émis lorsque la mise en page change
    signal layoutChanged()
    
    GridLayout {
        id: layoutGrid
        columns: 2
        Layout.fillWidth: true
        columnSpacing: AppStyles.Theme.spacing
        rowSpacing: AppStyles.Theme.spacing
        
        // Marge inférieure
        ParameterField {
            id: bottomMarginField
            label: "Bottom Margin (mm):"
            value: "60.0"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            Layout.fillWidth: true
            Layout.columnSpan: layoutGrid.columns
            onValueEdited: layoutChanged()
        }
        
        // Hauteur du spectrogramme
        ParameterField {
            id: spectroHeightField
            label: "Spectrogram Height (mm):"
            value: "216.7"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            Layout.fillWidth: true
            Layout.columnSpan: layoutGrid.columns
            onValueEdited: layoutChanged()
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
            onToggled: layoutChanged()
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
            onToggled: layoutChanged()
        }
        
        // Décalage de la ligne de référence inférieure
        ParameterField {
            id: bottomReferenceLineOffsetField
            label: "Bottom Offset (mm):"
            value: "34.75"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            maxValue: 100.0
            Layout.fillWidth: true
            Layout.columnSpan: layoutGrid.columns
            enabled: bottomReferenceLineToggle.checked
            onValueEdited: layoutChanged()
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
            onToggled: layoutChanged()
        }
        
        // Décalage de la ligne de référence supérieure
        ParameterField {
            id: topReferenceLineOffsetField
            label: "Top Offset (mm):"
            value: "12.55"
            isNumeric: true
            allowDecimals: true
            minValue: 0.0
            Layout.fillWidth: true
            Layout.columnSpan: layoutGrid.columns
            enabled: topReferenceLineToggle.checked
            onValueEdited: layoutChanged()
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
            onToggled: layoutChanged()
        }
    }
}
