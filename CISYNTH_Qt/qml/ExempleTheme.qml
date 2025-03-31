import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.cisynth.ui 1.0

ApplicationWindow {
    id: window
    title: "CISYNTH - Exemple de Thème"
    width: 500
    height: 700
    visible: true
    color: Theme.backgroundColor

    // Police Orbitron
    FontLoader {
        id: orbitronFont
        source: "qrc:/fonts/Orbitron-Regular.ttf"
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        
        ColumnLayout {
            width: parent.width
            anchors.margins: Theme.margin
            spacing: Theme.spacing

            // Titre principal
            Label {
                text: "CISYNTH - Exemple de Thème"
                font.bold: true
                font.pixelSize: Theme.titleFontSize
                font.family: Theme.fontFamily
                color: Theme.primaryTextColor
                Layout.topMargin: Theme.margin
                Layout.alignment: Qt.AlignHCenter
            }

            // Conteneur avec bordure
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: parametresLayout.implicitHeight + 2 * Theme.padding
                color: "transparent"
                border.width: Theme.borderWidth
                border.color: Theme.borderColor
                radius: Theme.borderRadius

                ColumnLayout {
                    id: parametresLayout
                    anchors.fill: parent
                    anchors.margins: Theme.padding
                    spacing: Theme.spacing

                    Label {
                        text: "Paramètres du Spectrogramme"
                        font.bold: true
                        font.pixelSize: Theme.labelFontSize
                        font.family: Theme.fontFamily
                        color: Theme.primaryTextColor
                    }

                    // Grille de paramètres
                    GridLayout {
                        columns: 2
                        Layout.fillWidth: true
                        columnSpacing: Theme.spacing
                        rowSpacing: Theme.spacing / 2

                        Label { 
                            text: "Taille FFT:" 
                            font.family: Theme.fontFamily
                            color: Theme.primaryTextColor
                        }
                        TextField {
                            text: "8192"
                            Layout.preferredWidth: 80
                            color: Theme.fieldText
                            font.family: Theme.fontFamily
                            background: Rectangle {
                                color: Theme.fieldBackground
                                radius: Theme.borderRadius / 2
                            }
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Label { 
                            text: "Chevauchement:" 
                            font.family: Theme.fontFamily
                            color: Theme.primaryTextColor
                        }
                        TextField {
                            text: "0.85"
                            Layout.preferredWidth: 80
                            color: Theme.fieldText
                            font.family: Theme.fontFamily
                            background: Rectangle {
                                color: Theme.fieldBackground
                                radius: Theme.borderRadius / 2
                            }
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Label { 
                            text: "Activer Dithering:" 
                            font.family: Theme.fontFamily
                            color: Theme.primaryTextColor
                        }
                        CheckBox {
                            checked: false
                            contentItem: Text {
                                text: "Activé"
                                color: Theme.primaryTextColor
                                font.family: Theme.fontFamily
                                leftPadding: 5
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }

            // Séparateur
            Rectangle {
                height: 1
                color: Theme.separatorColor
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing
                Layout.bottomMargin: Theme.spacing
            }

            // Exemple de boutons
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.spacing

                // Bouton principal
                Button {
                    text: "Générer"
                    font.family: Theme.fontFamily
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: Theme.fontFamily
                        color: parent.hovered ? Theme.buttonHoverText : Theme.buttonText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.hovered ? Theme.buttonHoverBackground : Theme.buttonBackground
                        radius: Theme.borderRadius / 2
                        
                        // Animation de transition
                        Behavior on color {
                            ColorAnimation { 
                                duration: Theme.animationDuration
                            }
                        }
                    }
                }

                // Bouton secondaire
                Button {
                    text: "Annuler"
                    font.family: Theme.fontFamily
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: Theme.fontFamily
                        color: parent.hovered ? Theme.buttonHoverText : Theme.buttonText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.hovered ? Theme.buttonHoverBackground : Theme.fieldBackground
                        radius: Theme.borderRadius / 2
                        
                        // Animation de transition
                        Behavior on color {
                            ColorAnimation { 
                                duration: Theme.animationDuration
                            }
                        }
                    }
                }
            }

            // Exemple de message d'état
            Text {
                text: "Exemple de message de succès"
                color: Theme.successColor
                font.family: Theme.fontFamily
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: "Exemple de message d'erreur"
                color: Theme.errorColor
                font.family: Theme.fontFamily
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
