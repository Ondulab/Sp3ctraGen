pragma Singleton
import QtQuick 2.15

QtObject {
    // Propriétés pour la responsivité
    readonly property bool isNarrow: Qt.application.screens[0].width < 600
    readonly property bool isSmall: Qt.application.screens[0].width < 400
    
    // Dimensions et espacements
    readonly property int spacing: 10
    readonly property int margin: 20
    readonly property int padding: 10
    readonly property int borderRadius: 8
    readonly property int borderWidth: 1
    
    // Typographie
    readonly property int titleFontSize: 20
    readonly property int labelFontSize: 16
    readonly property int textFontSize: 14
    
    // Palette de couleurs (inspirée de la charte graphique)
    readonly property color backgroundColor: "#222"
    readonly property color primaryTextColor: "#D4AF37"
    readonly property color fieldBackground: "#333"
    readonly property color fieldText: "#BBB"
    readonly property color buttonBackground: "#555"
    readonly property color buttonText: "#000"
    readonly property color buttonHoverBackground: "#333"
    readonly property color buttonHoverText: "#FFF"
    readonly property color borderColor: "#D4AF37"
    readonly property color separatorColor: "#444"
    
    // Couleurs d'état
    readonly property color successColor: "#4CAF50"
    readonly property color errorColor: "#F44336"
    readonly property color warningColor: "#FFC107"
    readonly property color infoColor: "#2196F3"
    
    // Animations
    readonly property int animationDuration: 200
}
