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
        columns: outputFormatSection.width < 500 ? 1 : 2
        Layout.fillWidth: true
        columnSpacing: AppStyles.Theme.spacing * 3 // Espacement plus large entre les colonnes
        rowSpacing: AppStyles.Theme.spacing / 2
        
        // Format de page
        Label { 
            text: "Page Format:" 
            color: AppStyles.Theme.primaryTextColor
            Layout.fillWidth: formatGrid.columns === 1
        }
        ComboBox {
            id: pageFormatCombo
            model: ["A4 Portrait", "A3 Landscape"]
            Layout.preferredWidth: 120
            
            onCurrentIndexChanged: formatChanged()
            
            background: Rectangle {
                color: AppStyles.Theme.fieldBackground
                radius: AppStyles.Theme.borderRadius / 2
            }
            
            contentItem: Text {
                text: pageFormatCombo.displayText
                color: AppStyles.Theme.fieldText
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
                    color: AppStyles.Theme.fieldBackground
                    border.color: AppStyles.Theme.borderColor
                    radius: AppStyles.Theme.borderRadius / 2
                }
            }
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
        Label {
            text: "Vertical Scale:"
            color: AppStyles.Theme.primaryTextColor
            Layout.fillWidth: formatGrid.columns === 1
        }
        ToggleSwitch {
            id: verticalScaleToggle
            Layout.preferredWidth: 80
            Layout.preferredHeight: 30
            checked: true
            onToggled: formatChanged()
        }
        
        // Ligne de référence inférieure
        Label {
            text: "Bottom Reference Line:"
            color: AppStyles.Theme.primaryTextColor
            Layout.fillWidth: formatGrid.columns === 1
        }
        ToggleSwitch {
            id: bottomReferenceLineToggle
            Layout.preferredWidth: 80
            Layout.preferredHeight: 30
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
        Label {
            text: "Top Reference Line:"
            color: AppStyles.Theme.primaryTextColor
            Layout.fillWidth: formatGrid.columns === 1
        }
        ToggleSwitch {
            id: topReferenceLineToggle
            Layout.preferredWidth: 80
            Layout.preferredHeight: 30
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
        Label {
            text: "Show Parameters:"
            color: AppStyles.Theme.primaryTextColor
            Layout.fillWidth: formatGrid.columns === 1
        }
        ToggleSwitch {
            id: displayParametersToggle
            Layout.preferredWidth: 80
            Layout.preferredHeight: 30
            checked: false
            onToggled: formatChanged()
        }
    }
}
