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
    property int preferredWidth: AppStyles.Theme.fieldWidth
    property bool readOnly: false
    
    // Propriété exposant la valeur numérique
    property double numericValue: getValue()
    
    // Signal émis lorsque la valeur change
    signal fieldValueChanged(string newValue)  // Renommé pour éviter le conflit avec la propriété value
    signal valueEdited(string newValue)
    // Note: numericValueChanged est généré automatiquement par la propriété numericValue
    
    // Espacement standard
    spacing: AppStyles.Theme.spacing
    Layout.alignment: Qt.AlignVCenter
    
    // Libellé du paramètre
    ThemedLabel {
        id: parameterLabel
        text: parameterField.label
    }
    
    // Champ de saisie
    TextField {
        id: valueField
        text: parameterField.value
        Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
        Layout.preferredHeight: AppStyles.Theme.fieldHeight
        Layout.alignment: Qt.AlignVCenter
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
        
        // Intercepter les touches pour standardiser sur les points décimaux uniquement
        Keys.onPressed: function(event) {
            if (parameterField.isNumeric && parameterField.allowDecimals) {
                // Accepter uniquement le point décimal
                if (event.key === Qt.Key_Period) {
                    // Ne pas ajouter si déjà un séparateur
                    if (text.indexOf('.') === -1) {
                        var pos = cursorPosition;
                        var beforeText = text.substring(0, cursorPosition);
                        var afterText = text.substring(cursorPosition);
                        text = beforeText + '.' + afterText;
                        cursorPosition = pos + 1;
                    }
                    event.accepted = true;
                }
                // Ignorer les virgules pour standardiser sur le point
                else if (event.key === Qt.Key_Comma) {
                    event.accepted = true;
                }
            }
        }
        
        // Style standard
        color: AppStyles.Theme.fieldText
        font.family: AppStyles.Fonts.orbitron
        horizontalAlignment: Text.AlignHCenter
        
        background: Rectangle {
            anchors.fill: parent
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
            
            // Mettre à jour la propriété value pour qu'elle reflète le texte actuel
            parameterField.value = text
            
            parameterField.valueEdited(text)
        }
        
        // Signaler les changements de valeur et appliquer immédiatement
        onTextChanged: {
            // Émettre le signal de changement
            parameterField.fieldValueChanged(text)
            
            // Mettre à jour immédiatement la valeur numérique
            if (parameterField.isNumeric) {
                parameterField.numericValue = parameterField.getValue()
                
                // Appliquer immédiatement les contraintes min/max sans attendre la fin d'édition
                var value = parameterField.getValue()
                if (value < parameterField.minValue || value > parameterField.maxValue) {
                    // Ne pas corriger pendant la saisie, uniquement à la fin pour éviter les interruptions
                    // La correction se fera dans onEditingFinished
                }
                else {
                    // Si la valeur est valide, émettre également valueEdited
                    parameterField.valueEdited(text)
                }
            }
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
        decimals: 6  // Augmenter la précision pour plus de flexibilité
        notation: DoubleValidator.StandardNotation
        locale: "en_US" // Locale américaine pour utiliser le point comme séparateur décimal
    }
    
    // Fonction pour obtenir la valeur numérique
    function getValue() {
        if (isNumeric) {
            if (allowDecimals) {
                // Ne pas faire de conversion, utiliser directement le texte
                // (qui doit maintenant contenir des points)
                return parseFloat(valueField.text);
            } else {
                return parseInt(valueField.text);
            }
        }
        return valueField.text;
    }
    
    // Fonction publique pour obtenir une valeur compatible avec l'interface
    function getDisplayValue() {
        // Retourne la valeur avec la convention utilisée par l'interface
        return valueField.text;
    }
    
    // Fonction pour définir la valeur
    function setValue(newValue) {
        valueField.text = newValue.toString()
        
        // Mettre à jour la valeur numérique
        if (isNumeric) {
            numericValue = getValue()
        }
    }
    
    // Mettre à jour la valeur numérique lorsque l'édition est terminée
    onValueEdited: {
        if (isNumeric) {
            numericValue = getValue()
        }
    }
}
