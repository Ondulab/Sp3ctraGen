import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles" as AppStyles

/**
 * Champ de paramètre standardisé
 * 
 * Ce composant combine un libellé et un champ de saisie dans une disposition
 * standard pour tous les paramètres de l'application.
 * 
 * Supporte à la fois les formats de nombre avec point décimal et virgule
 * pour être compatible avec l'interface simple_ui.qml.
 */
RowLayout {
    id: parameterField
    
    // Propriétés de configuration
    property string label: "Parameter:"
    property string value: ""
    property bool isNumeric: true
    property bool allowDecimals: true
    property double minValue: 0.0
    property double maxValue: Number.MAX_VALUE
    property int preferredWidth: 80
    property bool readOnly: false
    
    // Signal émis lorsque la valeur change
    signal fieldValueChanged(string newValue)  // Renommé pour éviter le conflit avec la propriété value
    signal valueEdited(string newValue)
    
    // Espacement standard
    spacing: AppStyles.Theme.spacing
    
    // Libellé du paramètre
    Label {
        id: parameterLabel
        text: parameterField.label
        font.family: AppStyles.Fonts.orbitron
        color: AppStyles.Theme.primaryTextColor
        Layout.fillWidth: true
    }
    
    // Champ de saisie
    TextField {
        id: valueField
        text: parameterField.value
        Layout.preferredWidth: parameterField.preferredWidth
        readOnly: parameterField.readOnly
        
        // Valider selon le type
        validator: {
            if (parameterField.isNumeric) {
                if (parameterField.allowDecimals) {
                    doubleValidator
                } else {
                    intValidator
                }
            } else {
                null
            }
        }
        
        // Style standard
        color: AppStyles.Theme.fieldText
        font.family: AppStyles.Fonts.orbitron
        horizontalAlignment: Text.AlignHCenter
        
        background: Rectangle {
            color: AppStyles.Theme.fieldBackground
            radius: AppStyles.Theme.borderRadius / 2
            border.width: valueField.activeFocus ? 1 : 0
            border.color: AppStyles.Theme.borderColor
            
            // Animation de la bordure
            Behavior on border.color {
                ColorAnimation { duration: AppStyles.Theme.animationDuration }
            }
        }
        
        // Indicateur de focus
        Rectangle {
            id: focusIndicator
            anchors.fill: parent
            anchors.margins: -2
            radius: parent.background.radius + 2
            color: "transparent"
            border.width: 1
            border.color: AppStyles.Theme.borderColor
            opacity: 0
            
            // Animation de l'indicateur
            Behavior on opacity {
                NumberAnimation { duration: AppStyles.Theme.animationDuration }
            }
        }
        
        // Gestion du focus
        onActiveFocusChanged: {
            focusIndicator.opacity = activeFocus ? 0.5 : 0
        }
        
        // Validation à la fin de l'édition
        onEditingFinished: {
            if (parameterField.isNumeric) {
                // Vérifier si la valeur est dans les limites
                var value = getValue()
                if (value < parameterField.minValue) {
                    text = parameterField.minValue.toString()
                } else if (value > parameterField.maxValue) {
                    text = parameterField.maxValue.toString()
                }
            }
            
            parameterField.valueEdited(text)
        }
        
        // Signaler les changements de valeur
        onTextChanged: {
            parameterField.fieldValueChanged(text)
        }
    }
    
    // Validateurs
    IntValidator {
        id: intValidator
        bottom: parameterField.minValue
        top: parameterField.maxValue
    }
    
    DoubleValidator {
        id: doubleValidator
        bottom: parameterField.minValue
        top: parameterField.maxValue
        decimals: 2
        notation: DoubleValidator.StandardNotation
        locale: "fr_FR" // Locale française pour accepter la virgule comme séparateur décimal
    }
    
    // Fonction pour obtenir la valeur numérique
    function getValue() {
        if (isNumeric) {
            if (allowDecimals) {
                // Accepte à la fois la virgule et le point comme séparateur décimal
                return parseFloat(valueField.text.replace(',', '.'))
            } else {
                return parseInt(valueField.text)
            }
        }
        return valueField.text
    }
    
    // Fonction publique pour obtenir une valeur compatible avec l'interface
    function getDisplayValue() {
        if (isNumeric && allowDecimals) {
            // Retourne la valeur avec virgule pour l'affichage
            return valueField.text.replace('.', ',')
        }
        return valueField.text
    }
    
    // Fonction pour définir la valeur
    function setValue(newValue) {
        valueField.text = newValue.toString()
    }
}
