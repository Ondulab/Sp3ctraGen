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
    
    // Propriétés de la loupe
    property bool magnifyingGlassEnabled: true   // Active/désactive la fonctionnalité de loupe
    property real magnificationFactor: 10.0      // Facteur d'agrandissement (10:1 par défaut)
    property int magnifyingGlassSize: 200        // Taille de la loupe en pixels - augmentée à 200px
    property int magnifyingGlassOffset: 20       // Décalage de la loupe par rapport au curseur
    
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
                            
                            // Propriété pour déterminer si le point se trouve à l'intérieur de l'image réelle
                            // et non sur les bords noirs
                            function isPointInRealImage(ptX, ptY) {
                                // Calculer les limites réelles de l'image (pas les bords noirs)
                                var realImageRect = {
                                    x: x + (width - paintedWidth) / 2,
                                    y: y + (height - paintedHeight) / 2,
                                    width: paintedWidth,
                                    height: paintedHeight
                                }
                                
                                return ptX >= realImageRect.x && 
                                       ptX <= realImageRect.x + realImageRect.width &&
                                       ptY >= realImageRect.y &&
                                       ptY <= realImageRect.y + realImageRect.height
                            }
                            
                            // MouseArea pour suivre la position du curseur
                            MouseArea {
                                id: previewMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onPositionChanged: {
                                    // Calculer si le curseur est sur l'image réelle
                                    var isOnRealImage = previewImageItem.isPointInRealImage(mouseX, mouseY)
                                    
                                    // Afficher la loupe uniquement si activée et sur l'image
                                    if (previewSection.magnifyingGlassEnabled && isOnRealImage) {
                                        // Marges dues au PreserveAspectFit
                                        var imageMarginX = (previewImageItem.width - previewImageItem.paintedWidth) / 2
                                        var imageMarginY = (previewImageItem.height - previewImageItem.paintedHeight) / 2
                                        
                                        // Position relative à l'image réelle (en pixels)
                                        var relX = mouseX - imageMarginX
                                        var relY = mouseY - imageMarginY
                                        
                                        // Positionner la loupe à côté du curseur avec un décalage
                                        var offsetX = previewSection.magnifyingGlassOffset
                                        var offsetY = previewSection.magnifyingGlassOffset
                                        
                                        var newX = Math.min(mouseX + offsetX, parent.width - magnifyingGlass.width)
                                        var newY = Math.min(mouseY + offsetY, parent.height - magnifyingGlass.height)
                                        
                                        // Position de la loupe
                                        magnifyingGlass.x = newX
                                        magnifyingGlass.y = newY
                                        
                                        // Convertir en coordonnées normalisées pour le shader (0 à 1)
                                        // Ces coordonnées représentent précisément la position dans l'image source
                                        var normX = relX / previewImageItem.paintedWidth
                                        var normY = relY / previewImageItem.paintedHeight
                                        
                                        // Mettre à jour les coordonnées pour le shader
                                        magnifyingGlassEffect.sourceX = normX
                                        magnifyingGlassEffect.sourceY = normY
                                        
                                        magnifyingGlass.visible = true
                                    } else {
                                        magnifyingGlass.visible = false
                                    }
                                }
                                
                                onExited: {
                                    magnifyingGlass.visible = false
                                }
                            }
                            
                            // Loupe avec ShaderEffect pour contenu parfaitement rond
                            Rectangle {
                                id: magnifyingGlass
                                width: previewSection.magnifyingGlassSize
                                height: previewSection.magnifyingGlassSize
                                radius: width / 2  // Cercle parfait
                                color: "black"
                                border.width: 3
                                border.color: AppStyles.Theme.borderColor
                                visible: false
                                z: 100
                                
                                // Effet de shader amélioré pour un zoom précis
                                ShaderEffect {
                                    id: magnifyingGlassEffect
                                    anchors.fill: parent
                                    anchors.margins: 3  // Tient compte de la bordure
                                    
                                    // Coordonnées normalisées (0-1) du point à agrandir
                                    property real sourceX: 0.5
                                    property real sourceY: 0.5
                                    
                                    // Facteur de zoom
                                    property real zoomFactor: previewSection.magnificationFactor
                                    
                                    // Source de l'image
                                    property var source: ShaderEffectSource {
                                        sourceItem: previewImageItem
                                        hideSource: false
                                        live: true
                                        // Utilisation de la taille réelle de l'image pour maximiser la qualité
                                        sourceRect: Qt.rect(
                                            (previewImageItem.width - previewImageItem.paintedWidth) / 2,
                                            (previewImageItem.height - previewImageItem.paintedHeight) / 2,
                                            previewImageItem.paintedWidth,
                                            previewImageItem.paintedHeight
                                        )
                                    }
                                    
                                    // Shader pour masque circulaire et zoom centré
                                    fragmentShader: "
                                        varying highp vec2 qt_TexCoord0;
                                        uniform sampler2D source;
                                        uniform highp float qt_Opacity;
                                        uniform highp float sourceX;
                                        uniform highp float sourceY;
                                        uniform highp float zoomFactor;
                                        
                                        void main() {
                                            // Masque circulaire: refuser les pixels en dehors du cercle
                                            highp float dist = distance(vec2(0.5, 0.5), qt_TexCoord0);
                                            if (dist > 0.5) {
                                                gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
                                                return;
                                            }
                                            
                                            // Coordonnées zoomées exactement centrées sur sourceX, sourceY
                                            highp vec2 coord;
                                            
                                            // qt_TexCoord0 varie de 0 à 1 sur toute la superficie de la loupe
                                            // On centre le zoom sur le point sourceX, sourceY
                                            // et on applique le facteur de zoom
                                            coord.x = sourceX + (qt_TexCoord0.x - 0.5) / zoomFactor;
                                            coord.y = sourceY + (qt_TexCoord0.y - 0.5) / zoomFactor;
                                            
                                            // Limiter aux bords de l'image
                                            coord = clamp(coord, 0.0, 1.0);
                                            
                                            // Échantillonner l'image source à la position calculée
                                            gl_FragColor = texture2D(source, coord) * qt_Opacity;
                                        }
                                    "
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
        
        // Contrôles de la loupe
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: AppStyles.Theme.spacing
            visible: generator && generator.previewCounter > 0 // Uniquement visible quand il y a une prévisualisation
            
            // Switch pour activer/désactiver la loupe
            CheckBox {
                id: magnifyingGlassSwitch
                text: "Loupe"
                checked: previewSection.magnifyingGlassEnabled
                
                onCheckedChanged: {
                    previewSection.magnifyingGlassEnabled = checked
                }
                
                contentItem: Text {
                    text: magnifyingGlassSwitch.text
                    color: AppStyles.Theme.fieldText
                    leftPadding: magnifyingGlassSwitch.indicator.width + magnifyingGlassSwitch.spacing
                    verticalAlignment: Text.AlignVCenter
                }
                
                indicator: Rectangle {
                    implicitWidth: 16
                    implicitHeight: 16
                    x: 0
                    y: parent.height / 2 - height / 2
                    radius: 3
                    color: AppStyles.Theme.fieldBackground
                    border.color: magnifyingGlassSwitch.checked ? AppStyles.Theme.borderColor : AppStyles.Theme.separatorColor
                    
                    Rectangle {
                        width: 10
                        height: 10
                        x: 3
                        y: 3
                        radius: 2
                        color: AppStyles.Theme.borderColor
                        visible: magnifyingGlassSwitch.checked
                    }
                }
            }
            
            // Slider pour ajuster le facteur de zoom
            Slider {
                id: zoomFactorSlider
                from: 0
                to: 15
                stepSize: 1
                value: previewSection.magnificationFactor
                
                Layout.preferredWidth: 100
                
                onValueChanged: {
                    // Utiliser une valeur minimale de 1 pour éviter un facteur d'agrandissement de 0
                    previewSection.magnificationFactor = Math.max(1, value)
                }
                
                ToolTip {
                    parent: zoomFactorSlider.handle
                    visible: zoomFactorSlider.pressed
                    text: Math.max(1, zoomFactorSlider.value).toFixed(0) + ":1"
                }
                
                background: Rectangle {
                    x: zoomFactorSlider.leftPadding
                    y: zoomFactorSlider.topPadding + zoomFactorSlider.availableHeight / 2 - height / 2
                    width: zoomFactorSlider.availableWidth
                    height: 4
                    radius: 2
                    color: AppStyles.Theme.fieldBackground
                    
                    Rectangle {
                        width: zoomFactorSlider.visualPosition * parent.width
                        height: parent.height
                        color: AppStyles.Theme.borderColor
                        radius: 2
                    }
                }
                
                handle: Rectangle {
                    x: zoomFactorSlider.leftPadding + zoomFactorSlider.visualPosition * (zoomFactorSlider.availableWidth - width)
                    y: zoomFactorSlider.topPadding + zoomFactorSlider.availableHeight / 2 - height / 2
                    width: 16
                    height: 16
                    radius: 8
                    color: zoomFactorSlider.pressed ? AppStyles.Theme.borderColor : AppStyles.Theme.buttonBackground
                    border.color: AppStyles.Theme.borderColor
                }
            }
            
            // Valeur du zoom actuel
            Text {
                text: Math.max(1, previewSection.magnificationFactor).toFixed(0) + ":1"
                color: AppStyles.Theme.fieldText
                Layout.preferredWidth: 30
                horizontalAlignment: Text.AlignHCenter
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
                
                // Plus de tracking d'état local, nous gérons l'état autrement
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
}
