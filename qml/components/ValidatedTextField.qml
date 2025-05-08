import QtQuick 2.15
import QtQuick.Controls 2.15
import com.spectrogen.constants 1.0

/**
 * Champ de texte avec validation et conversion de valeurs
 * 
 * Ce composant fournit un champ de texte avec validation intégrée
 * et conversion de valeurs pour les types numériques.
 */
TextField {
    id: validatedField
    
    property var validator: null
    property string defaultValue: ""
    property bool isNumeric: true
    property bool allowDecimals: true
    property double minValue: 0.0
    property double maxValue: Number.MAX_VALUE
    
    text: defaultValue
    color: Constants.fieldText
    font.family: orbitronFont.name
    horizontalAlignment: Text.AlignHCenter
    
    // Appliquer le validateur approprié
    Component.onCompleted: {
        if (isNumeric) {
            if (allowDecimals) {
                validator = doubleValidator
            } else {
                validator = intValidator
            }
        }
    }
    
    // Validateurs
    IntValidator {
        id: intValidator
        bottom: validatedField.minValue
        top: validatedField.maxValue
    }
    
    DoubleValidator {
        id: doubleValidator
        bottom: validatedField.minValue
        top: validatedField.maxValue
        decimals: 2
        notation: DoubleValidator.StandardNotation
        locale: "en_US" // Use English locale to accept decimal point
    }
    
    // Fonction pour obtenir la valeur numérique
    function getValue() {
        if (isNumeric) {
            if (allowDecimals) {
                return parseFloat(text.replace(',', '.'));
            } else {
                return parseInt(text);
            }
        }
        return text;
    }
    
    // Style
    background: Rectangle {
        color: Constants.fieldBackground
        radius: Constants.borderRadius / 2
        border.width: 1
        border.color: validatedField.activeFocus ? Constants.borderColor : "transparent"
        
        Behavior on border.color {
            ColorAnimation { duration: Constants.animationDuration }
        }
    }
    
    // Animation de focus
    Rectangle {
        id: focusIndicator
        anchors.fill: parent
        anchors.margins: -2
        radius: parent.background.radius + 2
        color: "transparent"
        border.width: 1
        border.color: Constants.borderColor
        opacity: 0
        
        Behavior on opacity {
            NumberAnimation { duration: Constants.animationDuration }
        }
    }
    
    onActiveFocusChanged: {
        focusIndicator.opacity = activeFocus ? 0.5 : 0
    }
    
    // Validation à la fin de l'édition
    onEditingFinished: {
        if (isNumeric) {
            // Vérifier si la valeur est dans les limites
            var value = getValue()
            if (value < minValue) {
                text = minValue.toString()
            } else if (value > maxValue) {
                text = maxValue.toString()
            }
        }
    }
}