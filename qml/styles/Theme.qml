pragma Singleton
import QtQuick 2.15
import "." as AppStyles

/**
 * Thème centralisé pour l'application
 * 
 * Ce fichier regroupe toutes les propriétés de style pour assurer
 * la cohérence visuelle et faciliter les modifications globales.
 */
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

    // Dimensions générales
    readonly property int spacing: 8
    readonly property int margin: 20
    readonly property int padding: 10
    readonly property int borderRadius: 8
    readonly property int borderWidth: 1

    // Typographie (style et taille)
    readonly property string fontFamily: AppStyles.Fonts.orbitron
    readonly property string fontFamilyFallback: "Arial"

    readonly property int fontSizeLarge: 20    // Titres principaux
    readonly property int fontSizeMedium: 16   // Labels, boutons
    readonly property int fontSizeSmall: 14    // Champs, légendes
    readonly property int fontSizeTiny: 12     // Infos secondaires
    readonly property int labelFontSize: 20    // Taille des polices pour les labels

    readonly property int fontWeightNormal: Font.Normal
    readonly property int fontWeightBold: Font.Bold

    // Hauteurs standardisées pour les éléments UI
    readonly property int controlHeight: 28    // Uniformisé à 28px pour tous les contrôles
    readonly property int controlWidth: 80
    readonly property int fieldWidth: 80       // Largeur standardisée pour les champs de saisie
    readonly property int labelWidth: 200      // Largeur standardisée pour les labels
    readonly property int rightColumnWidth: 100 // Largeur des éléments dans la colonne de droite
    readonly property int buttonHeight: 28     // Uniformisé avec controlHeight
    readonly property int fieldHeight: 28

    // Animation
    readonly property int animationDuration: 200

    // Responsivité
    readonly property int narrowWidthThreshold: 600
    readonly property int smallWidthThreshold: 400
    readonly property int previewWidthThreshold: 800
}
