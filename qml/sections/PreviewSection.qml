import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"
import "../styles" as AppStyles

/**
 * Section de prévisualisation du spectrogramme
 * 
 * Cette section affiche l'aperçu du spectrogramme généré et
 * fournit des contrôles pour l'enregistrer ou l'imprimer.
 */
Rectangle {
    id: previewSection
    color: "#1A1A1A"
    border.width: AppStyles.Theme.borderWidth
    border.color: AppStyles.Theme.borderColor
    radius: AppStyles.Theme.borderRadius
    
    // Références et propriétés exposées
    property var generator: null
    property alias savePreviewButton: savePreviewButton
    property alias statusText: statusText
    property alias previewImageLoader: previewImageLoader
    
    // Signaux
    signal saveRequested(string format)
    signal printRequested()
    
    // Gestion des événements du générateur
    function onPreviewGenerated(success, errorMessage) {
        if (success) {
            // Incrémenter le compteur pour forcer un nouveau chargement si nécessaire
            if (generator) {
                generator.previewCounter++
            }
            
            // Forcer le rechargement de l'image
            previewImageLoader.active = false
            previewResetTimer.start()
            
            statusText.showSuccess("Preview updated")
        } else {
            statusText.showError("Error generating preview: " + errorMessage)
        }
    }
    
    function onSegmentPreviewGenerated(success, errorMessage) {
        if (success) {
            // Incrémenter le compteur pour forcer un nouveau chargement si nécessaire
            if (generator) {
                generator.previewCounter++
            }
            
            // Forcer le rechargement de l'image
            previewImageLoader.active = false
            previewResetTimer.start()
            
            statusText.showSuccess("Segment preview updated")
        } else {
            statusText.showError("Error generating segment preview: " + errorMessage)
        }
    }
    
    function onPreviewSaved(success, outputPath, format, errorMessage) {
        // Réinitialiser le bouton de sauvegarde
        savePreviewButton.isProcessing = false
        savePreviewButton.text = "Save Preview"
        
        if (success) {
            statusText.showSuccess("Preview saved successfully as " + format.toUpperCase() + ": " + outputPath)
        } else {
            statusText.showError("Error saving preview in " + format.toUpperCase() + " format: " + errorMessage)
        }
    }
    
    // Timer pour réactiver le loader après un court délai
    Timer {
        id: previewResetTimer
        interval: 50
        onTriggered: {
            previewImageLoader.active = true  // Réactiver le loader pour recréer l'image
        }
    }
    
    // Mise en page
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppStyles.Theme.padding
        spacing: AppStyles.Theme.spacing
        
        // Titre de la prévisualisation
        ThemedLabel {
            text: "Preview"
            font.pixelSize: AppStyles.Theme.labelFontSize
        }
        
        // Zone de prévisualisation avec ScrollView pour permettre le défilement
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // Conteneur pour l'image de prévisualisation
            Item {
                id: previewImageContainer
                anchors.fill: parent
                
                // Loader pour l'image de prévisualisation
                Loader {
                    id: previewImageLoader
                    anchors.fill: parent
                    active: true
                    
                    sourceComponent: Component {
                        Image {
                            id: previewImageItem
                            anchors.centerIn: parent
                            fillMode: Image.PreserveAspectFit
                            width: parent.width
                            height: parent.height
                            cache: false
                            asynchronous: true
                            mipmap: true
                            smooth: true
                            
                            // Utiliser le compteur pour forcer le rechargement
                            source: {
                                if (generator && generator.previewCounter > 0) {
                                    return "image://preview/" + generator.previewCounter
                                } else {
                                    return "image://preview/init"
                                }
                            }
                            
                            // Gérer les erreurs de chargement
                            onStatusChanged: {
                                if (status === Image.Error) {
                                    statusText.showError("Error loading preview image")
                                }
                            }
                        }
                    }
                }
                
                // Afficher un message si aucune prévisualisation n'est disponible
                Text {
                    anchors.centerIn: parent
                    text: "Use 'Generate Spectrogram' to generate a preview"
                    color: AppStyles.Theme.fieldText
                    visible: !previewImageLoader.active || !generator || generator.previewCounter === 0
                }
            }
        }
        
        // Conteneur pour les contrôles d'exportation
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: AppStyles.Theme.spacing
            
            // Menu déroulant pour le format d'exportation
            ComboBox {
                id: exportFormatCombo
                model: ["PNG", "PDF", "JPEG"]
                currentIndex: 0
                
                background: Rectangle {
                    color: AppStyles.Theme.fieldBackground
                    radius: AppStyles.Theme.borderRadius / 2
                }
                
                contentItem: Text {
                    text: exportFormatCombo.displayText
                    color: AppStyles.Theme.fieldText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                
                popup: Popup {
                    y: exportFormatCombo.height
                    width: exportFormatCombo.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1
                    
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: exportFormatCombo.popup.visible ? exportFormatCombo.delegateModel : null
                        
                        ScrollBar.vertical: ScrollBar {
                            active: exportFormatCombo.popup.visible
                        }
                    }
                    
                    background: Rectangle {
                        color: AppStyles.Theme.fieldBackground
                        border.color: AppStyles.Theme.borderColor
                        radius: AppStyles.Theme.borderRadius / 2
                    }
                }
            }
            
            // Bouton pour sauvegarder la prévisualisation
            Button {
                id: savePreviewButton
                text: "Save Preview"
                enabled: generator && generator.previewCounter > 0
                
                property bool isProcessing: false
                
                onClicked: {
                    if (isProcessing) return
                    
                    isProcessing = true
                    text = "Saving..."
                    
                    // Récupérer le format sélectionné (en minuscules)
                    var format = exportFormatCombo.currentText.toLowerCase()
                    
                    if (generator) {
                        // Sauvegarder la prévisualisation actuelle dans le format sélectionné
                        previewSection.saveRequested(format)
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
                        ColorAnimation {
                            duration: AppStyles.Theme.animationDuration
                        }
                    }
                }
            }
            
            // Bouton pour imprimer la prévisualisation
            Button {
                id: printButton
                text: "Print"
                enabled: generator && generator.previewCounter > 0
                
                onClicked: {
                    previewSection.printRequested()
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
                        ColorAnimation {
                            duration: AppStyles.Theme.animationDuration
                        }
                    }
                }
            }
        }
        
        // Texte de statut pour la prévisualisation
        StatusText {
            id: statusText
            text: "No preview generated yet"
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
        }
    }
    
    // Connexion des signaux du générateur
    Component.onCompleted: {
        if (generator) {
            generator.previewGenerated.connect(onPreviewGenerated)
            generator.segmentPreviewGenerated.connect(onSegmentPreviewGenerated)
            generator.previewSaved.connect(onPreviewSaved)
        }
    }
    
    // Méthodes publiques
    function savePreview(outputFolder, format) {
        if (generator && generator.previewCounter > 0) {
            savePreviewButton.isProcessing = true
            savePreviewButton.text = "Saving..."
            generator.saveCurrentPreview(outputFolder, format)
        }
    }
}
