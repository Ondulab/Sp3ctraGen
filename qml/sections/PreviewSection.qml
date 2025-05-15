import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"
import "../styles" as AppStyles

/**
 * Section de prévisualisation du spectrogramme
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
    
    // Signaux
    signal saveRequested(string format)
    signal printRequested()
    
    // Gestion des événements du générateur
    function onPreviewGenerated(success, errorMessage) {
        if (success) {
            // Incrémenter le compteur pour forcer un nouveau chargement
            if (generator) {
                generator.previewCounter++
            }
            
            statusText.showSuccess("Preview updated")
        } else {
            statusText.showError("Error generating preview: " + errorMessage)
        }
    }
    
    function onSegmentPreviewGenerated(success, errorMessage) {
        if (success) {
            // Incrémenter le compteur pour forcer un nouveau chargement
            if (generator) {
                generator.previewCounter++
            }
            
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
    
    // Fonctions pour le zoom et le déplacement de l'image
    function zoomImage(newZoom, centerX, centerY) {
        if (!previewImage || previewImage.status !== Image.Ready) return
        
        // Stocker l'ancien niveau de zoom
        var oldZoom = previewImage.zoomLevel
        
        // Appliquer le nouveau niveau de zoom avec limites
        previewImage.zoomLevel = Math.min(Math.max(newZoom, previewImage.minZoom), previewImage.maxZoom)
        
        // Si centerX et centerY sont fournis, effectuer un zoom centré sur cette position
        if (centerX !== undefined && centerY !== undefined) {
            // Calculer le point relatif sur l'image
            var relativeX = centerX - previewImage.x
            var relativeY = centerY - previewImage.y
            
            // Ratio de changement de taille
            var ratio = previewImage.zoomLevel / oldZoom
            
            // Calculer la nouvelle position pour maintenir le point de focal
            previewImage.x = centerX - relativeX * ratio
            previewImage.y = centerY - relativeY * ratio
            
            // S'assurer que l'image reste visible
            viewportMouseArea.limitPan()
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
        
        // Zone de prévisualisation simplifiée et robuste
        Item {
            id: viewportContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
                // Rectangle pour montrer que le zoom sur le fond fonctionne
            Rectangle {
                anchors.fill: parent
                color: "#1A1A1A"
                
                // Références aux propriétés de l'image pour le zoom
                property alias zoomFactor: previewImage.zoomLevel
                property alias minZoom: previewImage.minZoom
                property alias maxZoom: previewImage.maxZoom
                property int lastMouseX: 0
                property int lastMouseY: 0
                property bool isDragging: false
                
                // Zone pour capturer les événements sur tout le viewport
                MouseArea {
                    id: viewportMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    acceptedButtons: Qt.LeftButton
                    
                    // Double-clic pour réinitialiser le zoom
                    onDoubleClicked: {
                        zoomImage(1.0)
                        centerImage()
                    }
                    
                    // Commencer le pan
                    onPressed: {
                        parent.lastMouseX = mouse.x
                        parent.lastMouseY = mouse.y
                        parent.isDragging = false
                    }
                    
                    // Effectuer le pan
                    onPositionChanged: {
                        if (pressed) {
                            var deltaX = mouse.x - parent.lastMouseX
                            var deltaY = mouse.y - parent.lastMouseY
                            
                            if (!parent.isDragging && (Math.abs(deltaX) > 3 || Math.abs(deltaY) > 3)) {
                                parent.isDragging = true
                            }
                            
                            if (parent.isDragging) {
                                // Appliquer le déplacement de manière fluide
                                previewImage.x += deltaX
                                previewImage.y += deltaY
                                
                                // Limiter les déplacements
                                limitPan()
                            }
                            
                            // Mettre à jour les coordonnées de référence
                            parent.lastMouseX = mouse.x
                            parent.lastMouseY = mouse.y
                        }
                    }
                    
                    // Finir le pan
                    onReleased: {
                        limitPan() // S'assurer que l'image reste en vue
                    }
                    
                    // Zoom avec la molette n'importe où dans le viewport
                    onWheel: {
                        if (previewImage.status !== Image.Ready) return
                        
                        // Enregistrer la position du curseur
                        var cursorX = wheel.x
                        var cursorY = wheel.y
                        
                        // Calculer le nouveau facteur de zoom
                        var oldZoom = parent.zoomFactor
                        var newZoom = wheel.angleDelta.y > 0 
                            ? oldZoom * 1.15 
                            : oldZoom / 1.15
                        
                        // Appliquer les limites min/max
                        newZoom = Math.min(Math.max(newZoom, parent.minZoom), parent.maxZoom)
                        
                        // Effectuer le zoom centré sur la position du curseur
                        zoomImage(newZoom, cursorX, cursorY)
                    }
                    
                    // Assurer que l'image reste toujours dans les limites visibles
                    function limitPan() {
                        var img = previewImage
                        
                        // Si l'image est plus grande que le conteneur, assurer qu'elle reste partiellement visible
                        if (img.width > viewportContainer.width) {
                            // Empêcher l'image de disparaître à droite
                            if (img.x > 0) {
                                img.x = 0
                            }
                            // Empêcher l'image de disparaître à gauche
                            if (img.x + img.width < viewportContainer.width) {
                                img.x = viewportContainer.width - img.width
                            }
                        } else {
                            // Si l'image est plus petite, la centrer horizontalement
                            img.x = (viewportContainer.width - img.width) / 2
                        }
                        
                        // Même logique pour la verticale
                        if (img.height > viewportContainer.height) {
                            if (img.y > 0) {
                                img.y = 0
                            }
                            if (img.y + img.height < viewportContainer.height) {
                                img.y = viewportContainer.height - img.height
                            }
                        } else {
                            img.y = (viewportContainer.height - img.height) / 2
                        }
                    }
                    
                    // Centrer l'image dans le viewport
                    function centerImage() {
                        var img = previewImage
                        img.x = (viewportContainer.width - img.width) / 2
                        img.y = (viewportContainer.height - img.height) / 2
                    }
                }
            }
            
            // L'image de prévisualisation
            Image {
                id: previewImage
                smooth: true
                mipmap: true
                cache: false
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                // Position à la 0,0 par défaut, sera centrée au chargement
                x: 0
                y: 0
                
                // Propriétés pour le zoom
                property real zoomLevel: 1.0
                property real minZoom: 0.5 // Minimum pour toujours remplir une bonne partie de l'écran
                property real maxZoom: 5.0 // Maximum pour éviter les performances dégradées
                
                // Dimensions - toujours au moins aussi grandes que le viewport
                width: sourceSize.width > 0 ? Math.max(sourceSize.width * zoomLevel, viewportContainer.width * minZoom) : viewportContainer.width
                height: sourceSize.height > 0 ? Math.max(sourceSize.height * zoomLevel, viewportContainer.height * minZoom) : viewportContainer.height
                
                // Source de l'image
                source: {
                    if (generator && generator.previewCounter > 0) {
                        return "image://preview/" + generator.previewCounter
                    } else {
                        return "image://preview/init"
                    }
                }
                
                // Gérer les erreurs et le chargement
                onStatusChanged: {
                    if (status === Image.Error) {
                        statusText.showError("Error loading preview image")
                    } else if (status === Image.Ready) {
                        // Calculer le niveau de zoom minimum pour adapter l'image à la fenêtre
                        calculateMinZoom()
                        // Centrer l'image au chargement
                        viewportMouseArea.centerImage()
                    }
                }
                
                // Recalculer le zoom minimum lorsque les dimensions changent
                onSourceSizeChanged: {
                    if (sourceSize.width > 0 && sourceSize.height > 0) {
                        calculateMinZoom()
                    }
                }
                
                // Calculer le niveau de zoom minimum pour adapter l'image à la fenêtre
                function calculateMinZoom() {
                    if (sourceSize.width <= 0 || sourceSize.height <= 0) return
                    
                    var widthRatio = viewportContainer.width / sourceSize.width
                    var heightRatio = viewportContainer.height / sourceSize.height
                    
                    // Le zoom minimum permet d'adapter l'image à la fenêtre (fit)
                    minZoom = Math.min(widthRatio, heightRatio)
                    
                    // Si l'image vient d'être chargée, adapter son zoom à la fenêtre
                    if (zoomLevel < minZoom || zoomLevel === 1.0) {
                        zoomLevel = minZoom
                    }
                }
            }
            
            // Message si aucune prévisualisation n'est disponible
            Text {
                anchors.centerIn: parent
                text: "Use 'Generate Spectrogram' to generate a preview"
                color: AppStyles.Theme.fieldText
                visible: !generator || generator.previewCounter === 0 || previewImage.status === Image.Null
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
                    // Récupérer le format sélectionné (en minuscules)
                    var format = exportFormatCombo.currentText.toLowerCase()
                    
                    text = "Saving..."
                    
                    // Émission du signal pour demander la sauvegarde
                    previewSection.saveRequested(format)
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
    
    // Méthodes publiques pour le zoom (pour maintenir la compatibilité)
    function zoomToFit() {
        if (previewImage && previewImage.status === Image.Ready) {
            previewImage.calculateMinZoom()
            previewImage.zoomLevel = previewImage.minZoom
            viewportMouseArea.centerImage()
        }
    }

    function zoomToActualSize() {
        if (previewImage) {
            previewImage.zoomLevel = 1.0
            viewportMouseArea.centerImage()
        }
    }

    function zoomIn() {
        if (previewImage) {
            var newZoom = previewImage.zoomLevel * 1.25
            previewImage.zoomLevel = Math.min(newZoom, previewImage.maxZoom)
            viewportMouseArea.limitPan()
        }
    }

    function zoomOut() {
        if (previewImage) {
            var newZoom = previewImage.zoomLevel / 1.25
            previewImage.zoomLevel = Math.max(newZoom, previewImage.minZoom)
            viewportMouseArea.limitPan()
        }
    }
}
