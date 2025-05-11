import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles" as AppStyles

ComboBox {
    id: control
    
    // Propriétés de hauteur et de style standardisées
    height: AppStyles.Theme.fieldHeight
    implicitHeight: AppStyles.Theme.fieldHeight
    
    // Pour l'alignement correct dans les layouts
    Layout.alignment: Qt.AlignVCenter
    
    // Police et taille identiques aux autres champs
    font.family: AppStyles.Theme.fontFamily
    font.pixelSize: AppStyles.Theme.fontSizeSmall
    
    // Texte centré avec couleur identique aux champs ParameterField
    contentItem: Text {
        text: control.displayText
        font: control.font
        color: AppStyles.Theme.fieldText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        leftPadding: 6
        rightPadding: 6
    }
    
    // Fond identique aux autres champs
    background: Rectangle {
        implicitWidth: AppStyles.Theme.rightColumnWidth
        implicitHeight: AppStyles.Theme.fieldHeight
        anchors.centerIn: parent
        color: AppStyles.Theme.fieldBackground
        border.color: control.activeFocus ? AppStyles.Theme.borderColor : "transparent"
        border.width: control.activeFocus ? 1 : 0
        radius: AppStyles.Theme.borderRadius / 2
    }
    
    // Indicateur (flèche)
    indicator: Canvas {
        id: canvas
        x: control.width - width - 5
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"
        
        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = AppStyles.Theme.fieldText;
            context.fill();
        }
    }
    
    // Popup redessiné
    popup: Popup {
        y: control.height
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 1
        
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOff
            }
            
            currentIndex: control.highlightedIndex
        }
        
        background: Rectangle {
            color: AppStyles.Theme.fieldBackground
            border.color: AppStyles.Theme.borderColor
            border.width: 1
            radius: AppStyles.Theme.borderRadius / 2
        }
    }
    
    // Délégué pour les éléments de la liste
    delegate: ItemDelegate {
        width: control.width
        height: AppStyles.Theme.fieldHeight
        padding: 0
        
        contentItem: Text {
            text: modelData
            color: hovered || control.highlightedIndex === index ? AppStyles.Theme.fieldBackground : AppStyles.Theme.fieldText
            font: control.font
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        background: Rectangle {
            color: hovered || control.highlightedIndex === index ? AppStyles.Theme.primaryTextColor : AppStyles.Theme.fieldBackground
        }
        
        highlighted: control.highlightedIndex === index
    }
}
