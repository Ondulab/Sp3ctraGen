import QtQuick 2.15

/**
 * Thème centralisé pour l'application
 * 
 * Ce fichier regroupe toutes les propriétés de style pour assurer
 * la cohérence visuelle et faciliter les modifications globales.
 */
pragma Singleton

QtObject {
    // Couleurs principales
    readonly property color primaryTextColor: "#D4AF37"
    readonly property color backgroundColor: "#222"
    readonly property color fieldBackground: "#333"
    readonly property color fieldText: "#BBB"
    
    // Couleurs des boutons
    readonly property color buttonBackground: "#555"
    readonly property color buttonText: "#000"
    readonly property color buttonHoverBackground: "#333"
    readonly property color buttonHoverText: "#FFF"
    
    // Couleurs des bordures et séparateurs
    readonly property color borderColor: "#D4AF37"
    readonly property color separatorColor: "#444"
    
    // Couleurs des bascules (toggles)
    readonly property color toggleBorderColor: "#555"
    readonly property color toggleActiveColor: "#D4AF37"
    readonly property color toggleInactiveColor: "#555"
    
    // Couleurs des statuts
    readonly property color successColor: "#4CAF50"
    readonly property color errorColor: "#F44336"
    
    // Dimensions
    readonly property int spacing: 10
    readonly property int margin: 20
    readonly property int padding: 10
    readonly property int borderRadius: 8
    readonly property int borderWidth: 1
    
    // Typographie
    readonly property int titleFontSize: 20
    readonly property int labelFontSize: 16
    readonly property int textFontSize: 14
    
    // Animations
    readonly property int animationDuration: 200
    
    // Propriétés responsives
    readonly property int narrowWidthThreshold: 600
    readonly property int smallWidthThreshold: 400
    readonly property int previewWidthThreshold: 800
}
