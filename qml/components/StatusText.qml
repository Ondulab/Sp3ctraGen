import QtQuick 2.15
import QtQuick.Controls 2.15
import "../styles" as AppStyles

/**
 * Composant d'affichage des messages d'état
 * 
 * Ce composant affiche les messages d'état avec des couleurs
 * appropriées selon le type de message (succès, erreur, information).
 */
Label {
    id: statusText
    
    // Types de statut disponibles
    enum StatusType {
        Normal,
        Success,
        Error,
        Warning,
        Info
    }
    
    // Propriétés de configuration
    property int statusType: StatusText.StatusType.Normal
    property bool autoHide: false
    property int hideDelay: 5000 // 5 secondes par défaut
    
    // Déterminer la couleur en fonction du type de statut
    color: {
        switch (statusType) {
            case StatusText.StatusType.Success:
                return AppStyles.Theme.successColor
            case StatusText.StatusType.Error:
                return AppStyles.Theme.errorColor
            case StatusText.StatusType.Warning:
                return Qt.darker(AppStyles.Theme.primaryTextColor, 1.1)
            case StatusText.StatusType.Info:
                return AppStyles.Theme.primaryTextColor
            default:
                return AppStyles.Theme.fieldText
        }
    }
    
    // Style standard
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.WordWrap
    opacity: text.length > 0 ? 1.0 : 0.0
    
    // Animation de changement d'opacité
    Behavior on opacity {
        NumberAnimation { duration: AppStyles.Theme.animationDuration }
    }
    
    // Timer pour masquer automatiquement le message après un délai
    Timer {
        id: hideTimer
        interval: statusText.hideDelay
        repeat: false
        running: statusText.autoHide && statusText.text.length > 0
        onTriggered: {
            statusText.text = ""
        }
    }
    
    // Fonction pour définir un message de succès
    function showSuccess(message) {
        text = message
        statusType = StatusText.StatusType.Success
        if (autoHide) hideTimer.restart()
    }
    
    // Fonction pour définir un message d'erreur
    function showError(message) {
        text = message
        statusType = StatusText.StatusType.Error
        if (autoHide) hideTimer.restart()
    }
    
    // Fonction pour définir un message d'avertissement
    function showWarning(message) {
        text = message
        statusType = StatusText.StatusType.Warning
        if (autoHide) hideTimer.restart()
    }
    
    // Fonction pour définir un message d'information
    function showInfo(message) {
        text = message
        statusType = StatusText.StatusType.Info
        if (autoHide) hideTimer.restart()
    }
    
    // Fonction pour effacer le message
    function clear() {
        text = ""
    }
}
