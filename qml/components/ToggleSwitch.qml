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
    property int preferredWidth: AppStyles.Theme.controlWidth
    property int preferredHeight: AppStyles.Theme.controlHeight
    
    // Signal émis lors du changement d'état
    signal toggled(bool checked)
    
    // Dimensions
    implicitWidth: preferredWidth
    implicitHeight: preferredHeight
    width: preferredWidth
    height: preferredHeight
    
    // Rectangle de fond
    Rectangle {
        id: background
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        radius: height / 2
        color: "transparent"
        border.width: 1
        border.color: AppStyles.Theme.toggleBorderColor
        opacity: enabled ? 1.0 : 0.5
        clip: true
        
        // Indicateur (partie mobile)
        Rectangle {
            id: indicator
            width: parent.width / 2
            height: parent.height - 4
            radius: height / 2
            x: toggleSwitch.checked ? background.width - width - 2 : 2
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
    
    // Mise à jour de l'état visuel lorsque l'état d'activation change
    onEnabledChanged: {
        background.opacity = enabled ? 1.0 : 0.5
    }
}
