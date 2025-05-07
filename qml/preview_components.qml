// Partie droite - Prévisualisation
Rectangle {
    id: previewContainer
    Layout.fillHeight: true
    Layout.fillWidth: true
    color: "#1A1A1A"
    visible: showPreview
    border.width: borderWidth
    border.color: borderColor
    radius: borderRadius
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: padding
        spacing: window.spacing
        
        // Titre de la prévisualisation
        Label {
            text: "Preview"
            font.bold: true
            font.pixelSize: labelFontSize
            font.family: orbitronFont.name
            color: primaryTextColor
            Layout.alignment: Qt.AlignHCenter
        }
        
        // Zone de prévisualisation avec ScrollView pour permettre le défilement
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // Image de prévisualisation
            Image {
                id: previewImage
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                width: parent.width
                height: parent.height
                cache: false
                asynchronous: true
                
                // Afficher un message si aucune prévisualisation n'est disponible
                Text {
                    anchors.centerIn: parent
                    text: "Click 'Refresh Preview' to generate a preview"
                    color: fieldText
                    font.family: orbitronFont.name
                    visible: previewImage.status !== Image.Ready || previewImage.source === ""
                }
                
                // Gérer les erreurs de chargement
                onStatusChanged: {
                    if (status === Image.Error) {
                        previewStatusText.text = "Error loading preview image"
                        previewStatusText.color = errorColor
                    }
                }
            }
        }
        
        // Texte de statut pour la prévisualisation
        Label {
            id: previewStatusText
            text: "No preview generated yet"
            font.family: orbitronFont.name
            color: fieldText
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }
}

// Bouton Refresh Preview
Button {
    id: refreshPreviewButton
    text: "Refresh Preview"
    font.family: orbitronFont.name
    font.pixelSize: labelFontSize
    Layout.preferredWidth: 180
    
    property bool isAnimating: false
    property bool isProcessing: false
    property string originalText: "Refresh Preview"
    property string successText: "Preview Updated!"
    property string processingText: "Processing..."
    property string buttonState: "normal" // "normal", "processing", "success", "error"
    
    // Timer pour retarder le démarrage du traitement après l'animation de clic
    Timer {
        id: previewClickDelayTimer
        interval: 150
        repeat: false
        onTriggered: {
            // Démarrer l'animation de traitement
            refreshPreviewButton.startProcessingAnimation()
            
            // Appeler la fonction de génération de prévisualisation
            generator.generatePreview(
                parseInt(fftSizeField.text),
                parseFloat(overlapField.text),
                parseFloat(minFreqField.text),
                parseFloat(maxFreqField.text),
                parseFloat(durationField.text),
                parseInt(sampleRateField.text),
                parseFloat(dynamicRangeField.text),
                parseFloat(gammaCorrectionField.text),
                ditheringToggle.checked,
                parseFloat(contrastFactorField.text),
                highBoostToggle.checked,
                parseFloat(highBoostAlphaField.text),
                pageFormatCombo.currentIndex,
                bottomMarginField.getValue(),
                spectroHeightField.getValue(),
                writingSpeedField.getValue(),
                inputFileField.text
            )
        }
    }
    
    function startSuccessAnimation() {
        isAnimating = true
        isProcessing = false
        buttonState = "success"
        previewProgressIndicator.running = false
        previewProgressIndicator.visible = false
        
        // Changer immédiatement le texte
        text = successText
        
        // Animation de succès sobre
        previewSuccessAnimation.start()
        
        // Timer pour revenir à l'état normal
        previewResetTimer.start()
    }
    
    function startProcessingAnimation() {
        isProcessing = true
        buttonState = "processing"
        text = processingText
        previewProgressIndicator.visible = true
        previewProgressIndicator.running = true
        background.opacity = 0.7 // Réduire l'opacité du fond pour mettre en évidence l'indicateur
    }
    
    function stopProcessingAnimation() {
        isProcessing = false
        previewProgressIndicator.running = false
        previewProgressIndicator.visible = false
        background.opacity = 1.0
    }
    
    function resetState() {
        buttonState = "normal"
        text = originalText
        isAnimating = false
        isProcessing = false
        scale = 1.0
        background.color = buttonBackground
        background.opacity = 1.0
    }
    
    Timer {
        id: previewResetTimer
        interval: 1500
        onTriggered: {
            // Animation de retour à l'état normal
            previewReturnToNormalAnimation.start()
        }
    }
    
    // Indicateur de progression circulaire
    BusyIndicator {
        id: previewProgressIndicator
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: width
        running: false
        visible: false
        
        // Style personnalisé pour l'indicateur
        contentItem: Item {
            implicitWidth: 64
            implicitHeight: 64
            
            Rectangle {
                id: previewItem
                anchors.centerIn: parent
                width: parent.width
                height: width
                radius: width / 2
                color: "transparent"
                border.width: width * 0.1
                border.color: primaryTextColor
                opacity: 0.0
                
                RotationAnimation {
                    target: previewItem
                    running: previewProgressIndicator.running
                    from: 0
                    to: 360
                    duration: 1500
                    loops: Animation.Infinite
                }
                
                // Animation d'apparition
                NumberAnimation {
                    target: previewItem
                    property: "opacity"
                    from: 0.0
                    to: 0.8
                    duration: 300
                    running: previewProgressIndicator.running
                }
            }
        }
    }
    
    // Animation de succès sobre
    SequentialAnimation {
        id: previewSuccessAnimation
        
        ParallelAnimation {
            // Changement de couleur vers la couleur de succès
            ColorAnimation {
                target: refreshPreviewButton.background
                property: "color"
                to: successColor
                duration: 200
            }
            
            // Légère augmentation de taille pour attirer l'attention
            NumberAnimation {
                target: refreshPreviewButton
                property: "scale"
                to: 1.05
                duration: 200
                easing.type: Easing.OutBack
            }
        }
    }
    
    // Animation de retour à l'état normal
    SequentialAnimation {
        id: previewReturnToNormalAnimation
        
        ParallelAnimation {
            // Retour à la couleur normale
            ColorAnimation {
                target: refreshPreviewButton.background
                property: "color"
                to: buttonBackground
                duration: 300
            }
            
            // Retour à la taille normale
            NumberAnimation {
                target: refreshPreviewButton
                property: "scale"
                to: 1.0
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
        
        // Réinitialisation des propriétés
        ScriptAction {
            script: {
                refreshPreviewButton.resetState();
            }
        }
    }
    
    // Animation de clic améliorée avec retour visuel immédiat
    SequentialAnimation {
        id: previewClickAnimation
        alwaysRunToEnd: true
        
        ParallelAnimation {
            // Animation de réduction d'échelle
            NumberAnimation {
                target: refreshPreviewButton
                property: "scale"
                from: 1.0
                to: 0.92
                duration: 100
                easing.type: Easing.OutQuad
            }
            
            // Animation de couleur pour un feedback visuel plus fort
            ColorAnimation {
                target: refreshPreviewButton.background
                property: "color"
                to: Qt.darker(buttonBackground, 1.3)
                duration: 100
            }
        }
        
        ParallelAnimation {
            // Retour à l'état normal ou transition vers l'état de traitement
            NumberAnimation {
                target: refreshPreviewButton
                property: "scale"
                from: 0.92
                to: 1.0
                duration: 150
                easing.type: Easing.OutBack
                easing.overshoot: 1.5
            }
        }
    }
    
    contentItem: Item {
        implicitWidth: previewButtonText.implicitWidth
        implicitHeight: previewButtonText.implicitHeight
        
        Text {
            id: previewButtonText
            anchors.centerIn: parent
            text: parent.parent.text
            font.family: orbitronFont.name
            font.pixelSize: labelFontSize
            color: parent.parent.hovered || parent.parent.isAnimating || parent.parent.isProcessing ? buttonHoverText : buttonText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            
            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }
    }
    
    background: Rectangle {
        color: parent.hovered && !parent.isProcessing ? buttonHoverBackground : buttonBackground
        radius: borderRadius
        implicitHeight: 40
        
        // Effet de lueur pour l'état de succès
        Rectangle {
            id: previewGlowEffect
            anchors.fill: parent
            anchors.margins: -4
            radius: parent.radius + 4
            color: "transparent"
            border.width: 2
            border.color: successColor
            opacity: 0
            
            // Animation de pulsation pour l'effet de lueur
            SequentialAnimation {
                running: refreshPreviewButton.buttonState === "success"
                loops: 1
                
                NumberAnimation {
                    target: previewGlowEffect
                    property: "opacity"
                    from: 0
                    to: 0.8
                    duration: 300
                    easing.type: Easing.OutCubic
                }
                
                NumberAnimation {
                    target: previewGlowEffect
                    property: "opacity"
                    from: 0.8
                    to: 0
                    duration: 800
                    easing.type: Easing.InCubic
                }
            }
        }
        
        Behavior on color {
            ColorAnimation { 
                duration: animationDuration
            }
        }
        
        Behavior on opacity {
            NumberAnimation { 
                duration: animationDuration
            }
        }
    }
    
    onClicked: {
        // Vérifier si le bouton n'est pas déjà en cours de traitement
        if (buttonState === "processing") return
        
        // Animation de clic avec retour visuel immédiat
        previewClickAnimation.start()
        
        // Vérification des champs requis
        if (inputFileField.text === "" && !useDefaultInputToggle.checked) {
            previewStatusText.text = "Please select a WAV file or use default path"
            previewStatusText.color = errorColor
            return
        }
        
        // Démarrer le timer pour retarder le démarrage du traitement
        previewClickDelayTimer.start()
    }
}
