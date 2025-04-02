import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import com.spectrogen.backend 1.0

ApplicationWindow {
    id: window
    title: "SpectroGen"
    width: 500
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
    }
    
    // Allow window resizing
    minimumWidth: 350
    minimumHeight: 500

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

    // File selection dialog
    FileDialog {
        id: inputFileDialog
        title: "Select WAV File"
        nameFilters: ["Audio files (*.wav)"]
        onAccepted: {
            inputFileField.text = fileUrl.toString().replace("file://", "")
            console.log("Input file selected: " + inputFileField.text);
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
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        
        ColumnLayout {
            width: parent.width
            anchors.margins: margin
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

                        Label { 
                            text: "Overlap (0..1):" 
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        TextField {
                            id: overlapField
                            text: "0.85"
                            Layout.preferredWidth: window.isSmall ? 120 : 80
                            Layout.fillWidth: window.isSmall
                            validator: DoubleValidator { bottom: 0.0; top: 1.0 }
                            color: fieldText
                            font.family: orbitronFont.name
                            background: Rectangle {
                                color: fieldBackground
                                radius: borderRadius / 2
                            }
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Label { 
                            text: "Min Frequency (Hz):" 
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        TextField {
                            id: minFreqField
                            text: "65"
                            Layout.preferredWidth: window.isSmall ? 120 : 80
                            Layout.fillWidth: window.isSmall
                            validator: DoubleValidator { bottom: 0.0 }
                            color: fieldText
                            font.family: orbitronFont.name
                            background: Rectangle {
                                color: fieldBackground
                                radius: borderRadius / 2
                            }
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Label { 
                            text: "Max Frequency (Hz):" 
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        TextField {
                            id: maxFreqField
                            text: "16640"
                            Layout.preferredWidth: window.isSmall ? 120 : 80
                            Layout.fillWidth: window.isSmall
                            validator: DoubleValidator { bottom: 0.0 }
                            color: fieldText
                            font.family: orbitronFont.name
                            background: Rectangle {
                                color: fieldBackground
                                radius: borderRadius / 2
                            }
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Label { 
                            text: "Duration (s):" 
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        TextField {
                            id: durationField
                            text: "4.0"
                            Layout.preferredWidth: window.isSmall ? 120 : 80
                            Layout.fillWidth: window.isSmall
                            validator: DoubleValidator { bottom: 0.0 }
                            color: fieldText
                            font.family: orbitronFont.name
                            background: Rectangle {
                                color: fieldBackground
                                radius: borderRadius / 2
                            }
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Label { 
                            text: "Sample Rate:" 
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        TextField {
                            id: sampleRateField
                            text: "192000"
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

                        Label { 
                            text: "Dynamic Range (dB):" 
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        TextField {
                            id: dynamicRangeField
                            text: "60.0"
                            Layout.preferredWidth: window.isSmall ? 120 : 80
                            Layout.fillWidth: window.isSmall
                            validator: DoubleValidator { bottom: 0.0 }
                            color: fieldText
                            font.family: orbitronFont.name
                            background: Rectangle {
                                color: fieldBackground
                                radius: borderRadius / 2
                            }
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Label { 
                            text: "Gamma Correction:" 
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        TextField {
                            id: gammaCorrectionField
                            text: "0.8"
                            Layout.preferredWidth: window.isSmall ? 120 : 80
                            Layout.fillWidth: window.isSmall
                            validator: DoubleValidator { bottom: 0.0 }
                            color: fieldText
                            font.family: orbitronFont.name
                            background: Rectangle {
                                color: fieldBackground
                                radius: borderRadius / 2
                            }
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Label { 
                            text: "Enable Dithering:" 
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        Item {
                            id: ditheringToggle
                            Layout.preferredWidth: window.isSmall ? 120 : 80
                            Layout.preferredHeight: 30
                            Layout.fillWidth: window.isSmall
                            
                            property bool checked: false
                            
                            Rectangle {
                                id: ditheringBackground
                                anchors.fill: parent
                                radius: height / 2
                                color: "transparent"
                                border.width: 1
                                border.color: toggleBorderColor
                                
                                Rectangle {
                                    id: ditheringIndicator
                                    width: parent.width / 2
                                    height: parent.height - 4
                                    radius: height / 2
                                    x: ditheringToggle.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    color: ditheringToggle.checked ? toggleActiveColor : toggleInactiveColor
                                    
                                    Behavior on x {
                                        NumberAnimation { 
                                            duration: animationDuration
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                    
                                    Behavior on color {
                                        ColorAnimation { 
                                            duration: animationDuration
                                        }
                                    }
                                }
                                
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    ditheringToggle.checked = !ditheringToggle.checked
                                }
                            }
                        }

                        Label { 
                            text: "Contrast Factor:" 
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        TextField {
                            id: contrastFactorField
                            text: "1.9"
                            Layout.preferredWidth: window.isSmall ? 120 : 80
                            Layout.fillWidth: window.isSmall
                            validator: DoubleValidator { bottom: 0.0 }
                            color: fieldText
                            font.family: orbitronFont.name
                            background: Rectangle {
                                color: fieldBackground
                                radius: borderRadius / 2
                            }
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Label { 
                            text: "High Boost Filter:" 
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        Item {
                            id: highBoostToggle
                            Layout.preferredWidth: window.isSmall ? 120 : 80
                            Layout.preferredHeight: 30
                            Layout.fillWidth: window.isSmall
                            
                            property bool checked: true
                            
                            Rectangle {
                                id: highBoostBackground
                                anchors.fill: parent
                                radius: height / 2
                                color: "transparent"
                                border.width: 1
                                border.color: toggleBorderColor
                                
                                Rectangle {
                                    id: highBoostIndicator
                                    width: parent.width / 2
                                    height: parent.height - 4
                                    radius: height / 2
                                    x: highBoostToggle.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    color: highBoostToggle.checked ? toggleActiveColor : toggleInactiveColor
                                    
                                    Behavior on x {
                                        NumberAnimation { 
                                            duration: animationDuration
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                    
                                    Behavior on color {
                                        ColorAnimation { 
                                            duration: animationDuration
                                        }
                                    }
                                }
                                
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    highBoostToggle.checked = !highBoostToggle.checked
                                }
                            }
                        }

                        Label { 
                            text: "High Boost Alpha:" 
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        TextField {
                            id: highBoostAlphaField
                            text: "0.99"
                            Layout.preferredWidth: window.isSmall ? 120 : 80
                            Layout.fillWidth: window.isSmall
                            validator: DoubleValidator { bottom: 0.0; top: 1.0 }
                            color: fieldText
                            font.family: orbitronFont.name
                            background: Rectangle {
                                color: fieldBackground
                                radius: borderRadius / 2
                            }
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            // Separator
            Rectangle {
                height: 1
                color: separatorColor
                Layout.fillWidth: true
                Layout.topMargin: window.spacing
                Layout.bottomMargin: window.spacing
            }

            // File selection container with border
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: filesLayout.implicitHeight + 2 * padding
                color: "transparent"
                border.width: borderWidth
                border.color: borderColor
                radius: borderRadius
                
                ColumnLayout {
                    id: filesLayout
                    anchors.fill: parent
                    anchors.margins: padding
                    spacing: window.spacing
                    
                    Label { 
                        text: "File Selection" 
                        font.bold: true
                        font.pixelSize: labelFontSize
                        font.family: orbitronFont.name
                        color: primaryTextColor
                    }
                    
                    Label { 
                        text: "Input File:" 
                        font.family: orbitronFont.name
                        color: primaryTextColor
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: window.spacing / 2
                        
                        TextField {
                            id: inputFileField
                            Layout.fillWidth: true
                            placeholderText: "Choose a WAV file..."
                            readOnly: true
                            color: fieldText
                            font.family: orbitronFont.name
                            background: Rectangle {
                                color: fieldBackground
                                radius: borderRadius / 2
                            }
                        }
                        
                        Button {
                            text: "Browse..."
                            font.family: orbitronFont.name
                            onClicked: inputFileDialog.open()
                            
                            contentItem: Text {
                                text: parent.text
                                font.family: orbitronFont.name
                                color: parent.hovered ? buttonHoverText : buttonText
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                color: parent.hovered ? buttonHoverBackground : buttonBackground
                                radius: borderRadius / 2
                                
                                Behavior on color {
                                    ColorAnimation { 
                                        duration: animationDuration
                                    }
                                }
                            }
                        }
                    }
                    
                    Label { 
                        text: "Output Folder:" 
                        font.family: orbitronFont.name
                        color: primaryTextColor
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: window.spacing / 2
                        
                        TextField {
                            id: outputFolderField
                            Layout.fillWidth: true
                            placeholderText: "Choose a folder..."
                            readOnly: true
                            color: fieldText
                            font.family: orbitronFont.name
                            background: Rectangle {
                                color: fieldBackground
                                radius: borderRadius / 2
                            }
                        }
                        
                        Button {
                            text: "Browse..."
                            font.family: orbitronFont.name
                            onClicked: outputFolderDialog.open()
                            
                            contentItem: Text {
                                text: parent.text
                                font.family: orbitronFont.name
                                color: parent.hovered ? buttonHoverText : buttonText
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                color: parent.hovered ? buttonHoverBackground : buttonBackground
                                radius: borderRadius / 2
                                
                                Behavior on color {
                                    ColorAnimation { 
                                        duration: animationDuration
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Generate button
            Button {
                id: generateButton
                text: "Generate Spectrogram"
                font.family: orbitronFont.name
                font.pixelSize: labelFontSize
                Layout.topMargin: window.spacing
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: window.isSmall ? parent.width * 0.9 : 250
                
                property bool isAnimating: false
                property bool isProcessing: false
                property string originalText: "Generate Spectrogram"
                property string successText: "Success!"
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

                        console.log("Generating spectrogram with parameters:");
                        console.log(" - FFT Size: " + fftSizeField.text);
                        console.log(" - Overlap: " + overlapField.text);
                        console.log(" - Min Frequency: " + minFreqField.text);
                        console.log(" - Max Frequency: " + maxFreqField.text);
                        console.log(" - Duration: " + durationField.text);
                        console.log(" - Sample Rate: " + sampleRateField.text);
                        console.log(" - Dynamic Range: " + dynamicRangeField.text);
                        console.log(" - Gamma Correction: " + gammaCorrectionField.text);
                        console.log(" - Dithering: " + ditheringToggle.checked);
                        console.log(" - Contrast Factor: " + contrastFactorField.text);
                        console.log(" - High Boost: " + highBoostToggle.checked);
                        console.log(" - High Boost Alpha: " + highBoostAlphaField.text);
                        console.log(" - Input File: " + inputFileField.text);
                        console.log(" - Output Folder: " + outputFolderField.text);

                        // Appeler la fonction de génération du spectrogramme
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
                            inputFileField.text,
                            outputFolderField.text
                        )
                    }
                }
                
                function startSuccessAnimation() {
                    console.log("Starting success animation");
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
                    console.log("Starting processing animation");
                    isProcessing = true
                    buttonState = "processing"
                    text = processingText
                    progressIndicator.visible = true
                    progressIndicator.running = true
                    background.opacity = 0.7 // Réduire l'opacité du fond pour mettre en évidence l'indicateur
                }
                
                function stopProcessingAnimation() {
                    console.log("Stopping processing animation");
                    isProcessing = false
                    progressIndicator.running = false
                    progressIndicator.visible = false
                    background.opacity = 1.0
                    
                    // Ne pas réinitialiser le texte ou l'état ici, car cela sera fait par startSuccessAnimation
                    // ou par resetState en cas d'erreur
                }
                
                function resetState() {
                    console.log("Resetting button state");
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
                                id: fadeInAnimation
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
                            id: glowAnimation
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
                    if (inputFileField.text === "") {
                        statusText.text = "Please select an input WAV file"
                        statusText.color = errorColor
                        return
                    }
                    
                    if (outputFolderField.text === "") {
                        statusText.text = "Please select an output folder"
                        statusText.color = errorColor
                        return
                    }
                    
                    // Démarrer le timer pour retarder le démarrage du traitement
                    clickDelayTimer.start()
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
        }
    }
}
