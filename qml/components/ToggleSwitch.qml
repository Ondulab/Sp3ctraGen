import QtQuick 2.15
import "../styles" as AppStyles

/**
 * Bascule (toggle) personnalisée
 * 
 * Ce composant fournit un interrupteur on/off stylisé et animé
 * pour activer ou désactiver des fonctionnalités dans l'application.
 */
Item {
    id: toggleSwitch
    
    // Propriétés de configuration
    property bool checked: false
    property bool enabled: true
    property int preferredWidth: 80
    property int preferredHeight: 30
    
    // Signal émis lors du changement d'état
    signal toggled(bool checked)
    
    // Dimensions
    implicitWidth: preferredWidth
    implicitHeight: preferredHeight
    
    // Rectangle de fond
    Rectangle {
        id: background
        anchors.fill: parent
        radius: height / 2
        color: "transparent"
        border.width: 1
        border.color: AppStyles.Theme.toggleBorderColor
        opacity: enabled ? 1.0 : 0.5
        
        // Indicateur (partie mobile)
        Rectangle {
            id: indicator
            width: parent.width / 2
            height: parent.height - 4
            radius: height / 2
            x: toggleSwitch.checked ? parent.width - width - 2 : 2
            y: 2
            color: toggleSwitch.checked ? AppStyles.Theme.toggleActiveColor : AppStyles.Theme.toggleInactiveColor
            
            // Animation de déplacement
            Behavior on x {
                NumberAnimation {
                    duration: AppStyles.Theme.animationDuration
                    easing.type: Easing.InOutQuad
                }
            }
            
            // Animation de changement de couleur
            Behavior on color {
                ColorAnimation {
                    duration: AppStyles.Theme.animationDuration
                }
            }
        }
    }
    
    // Zone cliquable
    MouseArea {
        anchors.fill: parent
        enabled: parent.enabled
        onClicked: {
            toggleSwitch.checked = !toggleSwitch.checked
            toggleSwitch.toggled(toggleSwitch.checked)
        }
    }
    
    // Mise à jour de l'état visuel lorsque l'état change
    onCheckedChanged: {
        if (checked) {
            indicator.x = background.width - indicator.width - 2
            indicator.color = AppStyles.Theme.toggleActiveColor
        } else {
            indicator.x = 2
            indicator.color = AppStyles.Theme.toggleInactiveColor
        }
    }
    
    // Mise à jour de l'état visuel lorsque l'état d'activation change
    onEnabledChanged: {
        background.opacity = enabled ? 1.0 : 0.5
    }
}