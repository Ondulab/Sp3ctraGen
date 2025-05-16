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
        
        // Titre et contrôles de la prévisualisation
        RowLayout {
            Layout.fillWidth: true
            spacing: AppStyles.Theme.spacing
            
            ThemedLabel {
                text: "Preview"
                font.pixelSize: AppStyles.Theme.labelFontSize
                Layout.fillWidth: true
            }
            
                // Bouton de contrôle du zoom
            Button {
                width: 30
                height: 24
                visible: previewImage && previewImage.status === Image.Ready
                
                onClicked: {
                    zoomToFit()
                }
                
                contentItem: Text {
                    text: "Fit"
                    color: parent.hovered ? AppStyles.Theme.buttonHoverText : AppStyles.Theme.buttonText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: AppStyles.Theme.smallFontSize
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
            
            // Indicateur de zoom
            Text {
                text: previewImage && previewImage.status === Image.Ready ? 
                      Math.round(previewImage.zoomLevel * 100) + "%" : ""
                color: AppStyles.Theme.fieldText
                font.pixelSize: AppStyles.Theme.smallFontSize
                visible: previewImage && previewImage.status === Image.Ready
                width: 50
                horizontalAlignment: Text.AlignRight
            }
            
            // Affichage des dimensions de l'image et résolution
            Text {
                id: resolutionText
                text: ""
                color: AppStyles.Theme.fieldText
                font.pixelSize: AppStyles.Theme.smallFontSize
                visible: previewImage && previewImage.status === Image.Ready
                horizontalAlignment: Text.AlignRight
                Layout.fillWidth: true
            }
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
                    
                    // Double-clic pour adapter l'image à la fenêtre
                    onDoubleClicked: {
                        zoomToFit()
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
            
            // L'image de prévisualisation - Complètement redéfinie pour éviter les erreurs
            Image {
                id: previewImage
                
                // Définir des propriétés de base
                x: 0
                y: 0
                
                // Propriétés standard avant toute personnalisation
                smooth: true
                mipmap: true
                cache: false
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                
                // Source simplifiée pour réduire les problèmes potentiels
                source: generator && generator.previewCounter > 0 ? 
                        "image://preview/" + generator.previewCounter : 
                        "image://preview/init"
                
                // Définir des propriétés explicitement numériques
                property real zoomLevel: 1.0
                property real minZoom: 0.1
                property real maxZoom: 5.0
                
                // Dimensions simplifiées
                width: viewportContainer.width
                height: viewportContainer.height
                
                // Log des problèmes potentiels
                Component.onCompleted: {
                    console.log("PreviewImage: reconstruction complète");
                    console.log("  - dimensions initiales:", width, "x", height);
                    console.log("  - minZoom initial:", minZoom);
                }
                
                // Gérer les erreurs et le chargement
                onStatusChanged: {
                    console.log("PreviewImage: onStatusChanged:", status);
                    console.log("  - generator disponible:", generator ? "oui" : "non");
                    console.log("  - sourceSize:", sourceSize.width, "x", sourceSize.height);
                    console.log("  - minZoom:", minZoom);
                    
                    if (status === Image.Error) {
                        statusText.showError("Error loading preview image")
                        console.error("PreviewImage: Error loading image");
                    } else if (status === Image.Ready) {
                        console.log("PreviewImage: Image is ready, calculating minZoom...");
                        try {
                            // Calculer le niveau de zoom minimum pour adapter l'image à la fenêtre
                            calculateMinZoom()
                            // Centrer l'image au chargement
                            viewportMouseArea.centerImage()
                            
                            console.log("PreviewImage: minZoom calculated:", minZoom);
                            console.log("PreviewImage: zoomLevel set to:", zoomLevel);
                            
                            // Mettre à jour l'affichage des informations de résolution en utilisant notre fonction robuste
                            updateResolutionText()
                        } catch (e) {
                            console.error("PreviewImage: Error in onStatusChanged when Image.Ready:", e);
                        }
                    }
                }
                
                // Recalculer le zoom minimum lorsque les dimensions changent
                onSourceSizeChanged: {
                    console.log("PreviewImage: onSourceSizeChanged:", sourceSize.width, "x", sourceSize.height);
                    if (sourceSize.width > 0 && sourceSize.height > 0) {
                        try {
                            // Calculer les ratios pour adapter l'image à la fenêtre
                            var widthRatio = viewportContainer.width / sourceSize.width;
                            var heightRatio = viewportContainer.height / sourceSize.height;
                            
                            // Calculer le zoom minimum et l'appliquer
                            minZoom = Math.min(widthRatio, heightRatio);
                            zoomLevel = minZoom;
                            
                            // Mettre à jour les dimensions APRÈS avoir calculé les ratios
                            width = sourceSize.width * zoomLevel;
                            height = sourceSize.height * zoomLevel;
                            
                            console.log("PreviewImage: dimensions mises à jour:", width, "x", height);
                            console.log("PreviewImage: minZoom recalculé:", minZoom);
                        } catch (e) {
                            console.error("PreviewImage: Erreur dans onSourceSizeChanged:", e);
                        }
                    }
                }
                
                // Calculer le niveau de zoom minimum pour adapter l'image à la fenêtre
                function calculateMinZoom() {
                    if (sourceSize.width <= 0 || sourceSize.height <= 0) return
                    
                    var widthRatio = viewportContainer.width / sourceSize.width
                    var heightRatio = viewportContainer.height / sourceSize.height
                    
                    // Le zoom minimum permet d'adapter l'image à la fenêtre (fit)
                    minZoom = Math.min(widthRatio, heightRatio)
                    
                    // Toujours utiliser le zoom minimum (fit) comme valeur initiale
                    zoomLevel = minZoom
                    
                    // Mettre à jour les dimensions pour qu'elles correspondent au niveau de zoom
                    width = sourceSize.width * zoomLevel
                    height = sourceSize.height * zoomLevel
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

    // Fonction pour mettre à jour le texte de résolution
    function updateResolutionText() {
        // Ensure generator is available and preview image is ready before accessing its properties
        if (generator && previewImage && previewImage.status === Image.Ready) {
            try {
                // Utiliser une approche purement textuelle pour éviter tout problème d'assignation
                var displayText = "";
                
                try {
                    // Récupérer et vérifier les valeurs directement dans des conditions, sans assignation intermédiaire
                    if (typeof generator.getPreviewImageWidth === "function" && 
                        typeof generator.getPreviewImageHeight === "function" && 
                        typeof generator.getPreviewImageDPI === "function" &&
                        typeof generator.getPreviewImageWidthCM === "function" &&
                        typeof generator.getPreviewImageHeightCM === "function") {
                        
                        // Tenter d'appeler ces fonctions mais capturer immédiatement dans des variables locales
                        var w = generator.getPreviewImageWidth() || 0;
                        var h = generator.getPreviewImageHeight() || 0;
                        var d = generator.getPreviewImageDPI() || 0;
                        var wcm = generator.getPreviewImageWidthCM() || 0;
                        var hcm = generator.getPreviewImageHeightCM() || 0;
                        
                        // Vérifier que toutes les valeurs sont valides
                        if (w > 0 && h > 0 && d > 0) {
                            displayText = w + "×" + h + " px";
                            
                            if (wcm > 0 && hcm > 0) {
                                displayText += " (" + wcm.toFixed(1) + "×" + hcm.toFixed(1) + " cm)";
                            }
                            
                            if (d > 0) {
                                displayText += " @ " + d + " DPI";
                            }
                        }
                    }
                } catch (innerError) {
                    console.warn("Erreur lors de l'accès aux méthodes de générator:", innerError);
                }
                
                // Définir un texte par défaut si aucune information n'a été récupérée
                if (!displayText) {
                    displayText = "Resolution: information non disponible";
                }
                
                // Assigner le texte final
                resolutionText.text = displayText;
            } catch (e) {
                console.warn("Erreur dans updateResolutionText:", e);
                resolutionText.text = "Resolution: N/A";
            }
        } else {
            // Clear the text if the image is not ready or generator is not available
            resolutionText.text = "";
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
