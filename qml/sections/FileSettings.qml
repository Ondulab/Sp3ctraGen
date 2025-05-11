import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import "../components"
import "../styles" as AppStyles

/**
 * Section des paramètres de fichiers
 * 
 * Cette section gère les chemins d'entrée et de sortie pour la génération du spectrogramme.
 */
SectionContainer {
    id: fileSettingsSection
    title: "Output Settings"
    
    // Propriétés exposées
    property alias outputFolder: outputFolderField.text
    property bool useDefaultOutput: outputFolderField.text === ""
    
    // Signaux
    signal folderPathChanged(string path)  // Renommé pour éviter le conflit avec la propriété
    signal requestSelectOutputFolder()
    
    // Références aux dialogues (à créer dans main.qml et passer en propriétés)
    property var outputFolderDialog: null
    
    // Mise en page
    ColumnLayout {
        spacing: AppStyles.Theme.spacing
        Layout.fillWidth: true
        
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            columnSpacing: AppStyles.Theme.spacing
            rowSpacing: AppStyles.Theme.spacing
            
            ThemedLabel { 
                text: "Output Folder:" 
            }
            
            Button {
                id: browseButton
                text: "Browse..."
                Layout.preferredWidth: AppStyles.Theme.rightColumnWidth
                Layout.preferredHeight: AppStyles.Theme.fieldHeight
                Layout.alignment: Qt.AlignVCenter
                
                onClicked: {
                    if (fileSettingsSection.outputFolderDialog) {
                        fileSettingsSection.outputFolderDialog.open()
                    } else {
                        fileSettingsSection.requestSelectOutputFolder()
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: parent.hovered ? AppStyles.Theme.buttonHoverText : AppStyles.Theme.buttonText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                background: Rectangle {
                    color: parent.hovered ? AppStyles.Theme.buttonHoverBackground : AppStyles.Theme.buttonBackground
                    radius: AppStyles.Theme.borderRadius / 2
                    
                    Behavior on color {
                        ColorAnimation { duration: AppStyles.Theme.animationDuration }
                    }
                }
            }
        }
        
        TextField {
            id: outputFolderField
            Layout.fillWidth: true
            placeholderText: "Default output path will be used if empty"
            readOnly: true
            color: AppStyles.Theme.fieldText
            
            background: Rectangle {
                color: AppStyles.Theme.fieldBackground
                radius: AppStyles.Theme.borderRadius / 2
            }
            
            onTextChanged: {
                fileSettingsSection.folderPathChanged(text)
            }
        }
    }
    
    // Méthodes
    function setOutputFolder(path) {
        outputFolderField.text = path
    }
    
    function clearOutputFolder() {
        outputFolderField.text = ""
    }
}
