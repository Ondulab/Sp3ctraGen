import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles" as AppStyles

/**
 * Conteneur standardisé pour les sections de l'interface
 * 
 * Ce composant fournit un conteneur avec un cadre, un titre et un espacement
 * cohérent pour toutes les sections de l'application.
 */
Rectangle {
    id: container
    
    // Propriété pour le titre de la section
    property string title: ""
    
    // Propriété par défaut pour le contenu
    default property alias content: contentLayout.children
    
    // Propriété pour la hauteur préférée (facultative)
    property int preferredHeight: -1
    
    // Apparence
    color: "transparent"
    border.width: AppStyles.Theme.borderWidth
    border.color: AppStyles.Theme.borderColor
    radius: AppStyles.Theme.borderRadius
    
    // Hauteur basée sur le contenu ou sur la préférence
    implicitHeight: mainLayout.implicitHeight + 2 * AppStyles.Theme.padding
    Layout.preferredHeight: preferredHeight > 0 ? preferredHeight : implicitHeight
    
    // Layout principal
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: AppStyles.Theme.padding
        spacing: AppStyles.Theme.spacing
        
        // Titre de la section (visible uniquement si un titre est fourni)
        Label {
            id: titleLabel
            text: container.title
            font.bold: true
            font.pixelSize: AppStyles.Theme.labelFontSize
            font.family: "Orbitron"
            color: AppStyles.Theme.primaryTextColor
            visible: container.title !== ""
            Layout.fillWidth: true
        }
        
        // Conteneur pour le contenu enfant
        ColumnLayout {
            id: contentLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: AppStyles.Theme.spacing
        }
    }
}
