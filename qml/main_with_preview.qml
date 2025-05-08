import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import com.spectrogen.backend 1.0

ApplicationWindow {
    id: window
    title: "SpectroGen"
    width: 900
    height: 700
    visible: true
    color: "#222"
    
    // Orbitron Font
    FontLoader {
        id: orbitronFont
        source: "qrc:/fonts/Orbitron-Regular.ttf"
    }
    
    // Responsive properties
    property bool isNarrow: width < 600
    property bool isSmall: width < 400
    property bool showPreview: width >= 800
    
    // Style properties
    property color primaryTextColor: "#D4AF37"
    property color fieldBackground: "#333"
    property color fieldText: "#BBB"
    property color buttonBackground: "#555"
    property color buttonText: "#000"
    property color buttonHoverBackground: "#333"
    property color buttonHoverText: "#FFF"
    property color borderColor: "#D4AF37"
    property color toggleBorderColor: "#555"
    property color toggleActiveColor: "#D4AF37"
    property color toggleInactiveColor: "#555"
    property color separatorColor: "#444"
    property color successColor: "#4CAF50"
    property color errorColor: "#F44336"
    property int spacing: 10
    property int margin: 20
    property int padding: 10
    property int borderRadius: 8
    property int borderWidth: 1
    property int titleFontSize: 20
    property int labelFontSize: 16
    property int textFontSize: 14
    property int animationDuration: 200
    
    // Adapt layout based on window size
    onWidthChanged: {
        isNarrow = width < 600
        isSmall = width < 400
        showPreview = width >= 800
    }
    
    // Allow window resizing
    minimumWidth: 800
    minimumHeight: 600

    // C++ backend reference
    SpectrogramGenerator {
        id: generator
        onSpectrogramGenerated: {
            console.log("Signal spectrogramGenerated received: success=" + success + ", outputPath=" + outputPath + ", errorMessage=" + errorMessage);
            
            // Arrêter l'animation de traitement
            generateButton.stopProcessingAnimation()
            
            if (success) {
                statusText.text = "Spectrogram successfully generated: " + outputPath
                statusText.color = successColor
                generateButton.startSuccessAnimation()
            } else {
                statusText.text = "Error generating spectrogram: " + errorMessage
                statusText.color = errorColor
            }
        }
    }
}
        }
        
        onPreviewGenerated: {
            console.log("Signal previewGenerated received: success=" + success + ", errorMessage=" + errorMessage);
            
            // Arrêter l'animation de traitement
            refreshPreviewButton.stopProcessingAnimation()
            
            if (success) {
                // Forcer le rechargement de l'image en utilisant un timestamp
                previewImage.source = ""  // Effacer l'image précédente
                previewImage.source = "image://preview/" + Date.now()  // Utiliser un timestamp pour éviter le cache
                previewStatusText.text = "Preview updated"
                previewStatusText.color = successColor
                refreshPreviewButton.startSuccessAnimation()
            } else {
                previewStatusText.text = "Error generating preview: " + errorMessage
                previewStatusText.color = errorColor
            }
        }
    }

    // File selection dialog
    FileDialog {
        id: inputFileDialog
        title: "Select WAV File"
        nameFilters: ["Audio files (*.wav)"]
        onAccepted: {
            inputFileField.text = fileUrl.toString().replace("file://", "")
            console.log("Input file selected: " + inputFileField.text);
            useDefaultInputToggle.checked = false;  // Désactiver l'option de chemin par défaut si un fichier est sélectionné
        }
    }

    // Folder selection dialog
    FileDialog {
        id: outputFolderDialog
        title: "Select Output Folder"
        selectFolder: true
        onAccepted: {
            outputFolderField.text = fileUrl.toString().replace("file://", "")
            console.log("Output folder selected: " + outputFolderField.text);
            useDefaultOutputToggle.checked = false;  // Désactiver l'option de chemin par défaut si un dossier est sélectionné
        }
    }

    // Layout principal avec division horizontale
    RowLayout {
        anchors.fill: parent
        anchors.margins: margin
        spacing: window.spacing
        
        // Partie gauche - Paramètres
        ScrollView {
            id: parametersScrollView
            Layout.fillHeight: true
            Layout.preferredWidth: showPreview ? parent.width * 0.5 : parent.width
            Layout.minimumWidth: 350
            contentWidth: parametersColumn.width
            
            ColumnLayout {
                id: parametersColumn
                width: parametersScrollView.width - 20  // Marge pour la scrollbar
                spacing: window.spacing

                // Main title
                Label {
                    text: "SpectroGen"
                    font.bold: true
                    font.pixelSize: titleFontSize
                    font.family: orbitronFont.name
                    color: primaryTextColor
                    Layout.topMargin: margin
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Buttons row
                RowLayout {
                    Layout.topMargin: window.spacing
                    Layout.alignment: Qt.AlignHCenter
                    spacing: window.spacing
                    
                    // Refresh Preview button
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
                                    false, // enableHighPassFilter (désactivé par défaut)
                                    100.0, // highPassCutoffFreq (valeur par défaut)
                                    2,     // highPassFilterOrder (valeur par défaut)
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
                    
                    // Generate button
                    Button {
                        id: generateButton
                        text: "Generate Spectrogram"
                        font.family: orbitronFont.name
                        font.pixelSize: labelFontSize
                        Layout.preferredWidth: 180
                        
                        property bool isAnimating: false
                        property bool isProcessing: false
                        property string originalText: "Generate Spectrogram"
                        property string successText: "Generated!"
                        property string processingText: "Processing..."
                        property string buttonState: "normal" // "normal", "processing", "success", "error"
                        
                        // Timer pour retarder le démarrage du traitement après l'animation de clic
                        Timer {
                            id: clickDelayTimer
                            interval: 150
                            repeat: false
                            onTriggered: {
                                // Démarrer l'animation de traitement
                                generateButton.startProcessingAnimation()
                                
                                // Appeler la fonction de génération
                                generator.generateSpectrogram(
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
                                    false, // enableHighPassFilter (désactivé par défaut)
                                    100.0, // highPassCutoffFreq (valeur par défaut)
                                    2,     // highPassFilterOrder (valeur par défaut)
                                    pageFormatCombo.currentIndex,
                                    bottomMarginField.getValue(),
                                    spectroHeightField.getValue(),
                                    writingSpeedField.getValue(),
                                    inputFileField.text,
                                    outputFolderField.text
                                )
                            }
                        }
                        
                        function startSuccessAnimation() {
                            isAnimating = true
                            isProcessing = false
                            buttonState = "success"
                            progressIndicator.running = false
                            progressIndicator.visible = false
                            
                            // Changer immédiatement le texte
                            text = successText
                            
                            // Animation de succès sobre
                            successAnimation.start()
                            
                            // Timer pour revenir à l'état normal
                            resetTimer.start()
                        }
                        
                        function startProcessingAnimation() {
                            isProcessing = true
                            buttonState = "processing"
                            text = processingText
                            progressIndicator.visible = true
                            progressIndicator.running = true
                            background.opacity = 0.7 // Réduire l'opacité du fond pour mettre en évidence l'indicateur
                        }
                        
                        function stopProcessingAnimation() {
                            isProcessing = false
                            progressIndicator.running = false
                            progressIndicator.visible = false
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
                            id: resetTimer
                            interval: 1500
                            onTriggered: {
                                // Animation de retour à l'état normal
                                returnToNormalAnimation.start()
                            }
                        }
                        
                        // Indicateur de progression circulaire
                        BusyIndicator {
                            id: progressIndicator
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
                                    id: item
                                    anchors.centerIn: parent
                                    width: parent.width
                                    height: width
                                    radius: width / 2
                                    color: "transparent"
                                    border.width: width * 0.1
                                    border.color: primaryTextColor
                                    opacity: 0.0
                                    
                                    RotationAnimation {
                                        target: item
                                        running: progressIndicator.running
                                        from: 0
                                        to: 360
                                        duration: 1500
                                        loops: Animation.Infinite
                                    }
                                    
                                    // Animation d'apparition
                                    NumberAnimation {
                                        target: item
                                        property: "opacity"
                                        from: 0.0
                                        to: 0.8
                                        duration: 300
                                        running: progressIndicator.running
                                    }
                                }
                            }
                        }
                        
                        // Animation de succès sobre
                        SequentialAnimation {
                            id: successAnimation
                            
                            ParallelAnimation {
                                // Changement de couleur vers la couleur de succès
                                ColorAnimation {
                                    target: generateButton.background
                                    property: "color"
                                    to: successColor
                                    duration: 200
                                }
                                
                                // Légère augmentation de taille pour attirer l'attention
                                NumberAnimation {
                                    target: generateButton
                                    property: "scale"
                                    to: 1.05
                                    duration: 200
                                    easing.type: Easing.OutBack
                                }
                            }
                        }
                        
                        // Animation de retour à l'état normal
                        SequentialAnimation {
                            id: returnToNormalAnimation
                            
                            ParallelAnimation {
                                // Retour à la couleur normale
                                ColorAnimation {
                                    target: generateButton.background
                                    property: "color"
                                    to: buttonBackground
                                    duration: 300
                                }
                                
                                // Retour à la taille normale
                                NumberAnimation {
                                    target: generateButton
                                    property: "scale"
                                    to: 1.0
                                    duration: 300
                                    easing.type: Easing.InOutQuad
                                }
                            }
                            
                            // Réinitialisation des propriétés
                            ScriptAction {
                                script: {
                                    generateButton.resetState();
                                }
                            }
                        }
                        
                        // Animation de clic améliorée avec retour visuel immédiat
                        SequentialAnimation {
                            id: clickAnimation
                            alwaysRunToEnd: true
                            
                            ParallelAnimation {
                                // Animation de réduction d'échelle
                                NumberAnimation {
                                    target: generateButton
                                    property: "scale"
                                    from: 1.0
                                    to: 0.92
                                    duration: 100
                                    easing.type: Easing.OutQuad
                                }
                                
                                // Animation de couleur pour un feedback visuel plus fort
                                ColorAnimation {
                                    target: generateButton.background
                                    property: "color"
                                    to: Qt.darker(buttonBackground, 1.3)
                                    duration: 100
                                }
                            }
                            
                            ParallelAnimation {
                                // Retour à l'état normal ou transition vers l'état de traitement
                                NumberAnimation {
                                    target: generateButton
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
                            implicitWidth: buttonText.implicitWidth
                            implicitHeight: buttonText.implicitHeight
                            
                            Text {
                                id: buttonText
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
                                id: glowEffect
                                anchors.fill: parent
                                anchors.margins: -4
                                radius: parent.radius + 4
                                color: "transparent"
                                border.width: 2
                                border.color: successColor
                                opacity: 0
                                
                                // Animation de pulsation pour l'effet de lueur
                                SequentialAnimation {
                                    running: generateButton.buttonState === "success"
                                    loops: 1
                                    
                                    NumberAnimation {
                                        target: glowEffect
                                        property: "opacity"
                                        from: 0
                                        to: 0.8
                                        duration: 300
                                        easing.type: Easing.OutCubic
                                    }
                                    
                                    NumberAnimation {
                                        target: glowEffect
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
                            clickAnimation.start()
                            
                            // Vérification des champs requis
                            if (inputFileField.text === "" && !useDefaultInputToggle.checked) {
                                statusText.text = "Please select a WAV file or use default path"
                                statusText.color = errorColor
                                return
                            }
                            
                            if (outputFolderField.text === "" && !useDefaultOutputToggle.checked) {
                                statusText.text = "Please select an output folder or use default path"
                                statusText.color = errorColor
                                return
                            }
                            
                            // Démarrer le timer pour retarder le démarrage du traitement
                            clickDelayTimer.start()
                        }
                    }
                }

                // Status text
                Label {
                    id: statusText
                    text: "Ready"
                    font.family: orbitronFont.name
                    color: fieldText
                    Layout.topMargin: window.spacing
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: window.isSmall ? parent.width * 0.9 : 250
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
                
                // Parameters container with border
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parametersLayout.implicitHeight + 2 * padding
                    color: "transparent"
                    border.width: borderWidth
                    border.color: borderColor
                    radius: borderRadius
                    
                    ColumnLayout {
                        id: parametersLayout
                        anchors.fill: parent
                        anchors.margins: padding
                        spacing: window.spacing
                        
                        Label {
                            text: "Spectrogram Parameters"
                            font.bold: true
                            font.pixelSize: labelFontSize
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }

                        // Spectrogram parameters
                        GridLayout {
                            columns: window.isSmall ? 1 : 2
                            Layout.fillWidth: true
                            columnSpacing: window.spacing
                            rowSpacing: window.spacing / 2

                            Label { 
                                text: "FFT Size:" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: fftSizeField
                                text: "8192"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: IntValidator { bottom: 1 }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            // Autres paramètres du spectrogramme
                            // ...
                            
                            // Champ de durée caché (conservé pour rétrocompatibilité)
                            Item {
                                id: durationField
                                visible: false
                                property string text: "4.0"
                            }
                            
                            // Champs pour les paramètres de format de sortie
                            Item {
                                id: pageFormatCombo
                                visible: false
                                property int currentIndex: 0
                            }
                            
                            Item {
                                id: bottomMarginField
                                visible: false
                                property string text: "50.0"
                                
                                function getValue() {
                                    return parseFloat(text);
                                }
                            }
                            
                            Item {
                                id: spectroHeightField
                                visible: false
                                property string text: "216.7"
                                
                                function getValue() {
                                    return parseFloat(text);
                                }
                            }
                            
                            Item {
                                id: writingSpeedField
                                visible: false
                                property string text: "8.0"
                                
                                function getValue() {
                                    return parseFloat(text);
                                }
                            }
                            
                            // Autres champs simplifiés
                            Item {
                                id: overlapField
                                visible: false
                                property string text: "0.85"
                            }
                            
                            Item {
                                id: minFreqField
                                visible: false
                                property string text: "65"
                            }
                            
                            Item {
                                id: maxFreqField
                                visible: false
                                property string text: "16640"
                            }
                            
                            Item {
                                id: sampleRateField
                                visible: false
                                property string text: "192000"
                            }
                            
                            Item {
                                id: dynamicRangeField
                                visible: false
                                property string text: "60.0"
                            }
                            
                            Item {
                                id: gammaCorrectionField
                                visible: false
                                property string text: "0.8"
                            }
                            
                            Item {
                                id: ditheringToggle
                                visible: false
                                property bool checked: false
                            }
                            
                            Item {
                                id: contrastFactorField
                                visible: false
                                property string text: "1.9"
                            }
                            
                            Item {
                                id: highBoostToggle
                                visible: false
                                property bool checked: true
                            }
                            
                            Item {
                                id: highBoostAlphaField
                                visible: false
                                property string text: "0.99"
                            }
                            
                            Item {
                                id: inputFileField
                                visible: false
                                property string text: ""
                            }
                            
                            Item {
                                id: useDefaultInputToggle
                                visible: false
                                property bool checked: true
                            }
                            
                            Item {
                                id: outputFolderField
                                visible: false
                                property string text: ""
                            }
                            
                            Item {
                                id: useDefaultOutputToggle
                                visible: false
                                property bool checked: true
                            }
                        }
                    }
                }
            }
        }
        
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
