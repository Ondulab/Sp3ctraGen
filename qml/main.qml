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
        
        // Compteur pour forcer le rechargement de l'image
        property int previewCounter: 0
        
        onPreviewGenerated: {
            console.log("Signal previewGenerated received: success=" + success + ", errorMessage=" + errorMessage);
            
            // Arrêter l'animation de traitement
            refreshPreviewButton.stopProcessingAnimation()
            
            if (success) {
                // Incrémenter le compteur pour forcer un nouveau chargement
                previewCounter++;
                
                // Forcer le rechargement de l'image avec un identifiant unique
                previewImageLoader.active = false;  // Désactiver le loader pour détruire l'image
                
                // Utiliser un timer pour laisser le temps au loader de se désactiver
                previewResetTimer.start();
                
                previewStatusText.text = "Preview updated"
                previewStatusText.color = successColor
                refreshPreviewButton.startSuccessAnimation()
            } else {
                previewStatusText.text = "Error generating preview: " + errorMessage
                previewStatusText.color = errorColor
            }
        }
    }
    
    // Timer pour réactiver le loader après un court délai
    Timer {
        id: previewResetTimer
        interval: 50
        onTriggered: {
            previewImageLoader.active = true;  // Réactiver le loader pour recréer l'image
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
                                text: "Vitesse d'écriture (cm/s):" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: writingSpeedField
                                text: "8.0"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { 
                                    bottom: 0.1
                                    decimals: 2
                                    notation: DoubleValidator.StandardNotation
                                    locale: "fr_FR" // Utilisation du locale français pour accepter la virgule
                                }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                                
                                // Fonction pour remplacer les virgules par des points lors de la conversion en nombre
                                function getValue() {
                                    return parseFloat(text.replace(',', '.'));
                                }
                            }
                            
                            // Champ de durée caché (conservé pour rétrocompatibilité)
                            Item {
                                id: durationField
                                visible: false
                                property string text: "4.0"
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
                
                // Format de sortie container with border
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: outputFormatLayout.implicitHeight + 2 * padding
                    color: "transparent"
                    border.width: borderWidth
                    border.color: borderColor
                    radius: borderRadius
                    
                    ColumnLayout {
                        id: outputFormatLayout
                        anchors.fill: parent
                        anchors.margins: padding
                        spacing: window.spacing
                        
                        Label {
                            text: "Format de Sortie"
                            font.bold: true
                            font.pixelSize: labelFontSize
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        
                        GridLayout {
                            columns: window.isSmall ? 1 : 2
                            Layout.fillWidth: true
                            columnSpacing: window.spacing
                            rowSpacing: window.spacing / 2
                            
                            Label { 
                                text: "Format de page:" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            ComboBox {
                                id: pageFormatCombo
                                model: ["A4 Portrait", "A3 Paysage"]
                                Layout.preferredWidth: window.isSmall ? 120 : 120
                                Layout.fillWidth: window.isSmall
                                
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                
                                contentItem: Text {
                                    text: pageFormatCombo.displayText
                                    font.family: orbitronFont.name
                                    color: fieldText
                                    horizontalAlignment: Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    leftPadding: 5
                                }
                                
                                popup: Popup {
                                    y: pageFormatCombo.height
                                    width: pageFormatCombo.width
                                    implicitHeight: contentItem.implicitHeight
                                    padding: 1
                                    
                                    contentItem: ListView {
                                        clip: true
                                        implicitHeight: contentHeight
                                        model: pageFormatCombo.popup.visible ? pageFormatCombo.delegateModel : null
                                        
                                        ScrollBar.vertical: ScrollBar {
                                            active: pageFormatCombo.popup.visible
                                        }
                                    }
                                    
                                    background: Rectangle {
                                        color: fieldBackground
                                        border.color: borderColor
                                        radius: borderRadius / 2
                                    }
                                }
                            }
                            
                            Label { 
                                text: "Marge inférieure (mm):" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: bottomMarginField
                                text: "50,0"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { 
                                    bottom: 0.0 
                                    decimals: 2
                                    notation: DoubleValidator.StandardNotation
                                    locale: "fr_FR" // Utilisation du locale français pour accepter la virgule
                                }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                                
                                // Fonction pour remplacer les virgules par des points lors de la conversion en nombre
                                function getValue() {
                                    return parseFloat(text.replace(',', '.'));
                                }
                            }
                            
                            Label { 
                                text: "Hauteur spectrogramme (mm):" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            TextField {
                                id: spectroHeightField
                                text: "216,7"
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.fillWidth: window.isSmall
                                validator: DoubleValidator { 
                                    bottom: 0.0 
                                    decimals: 2
                                    notation: DoubleValidator.StandardNotation
                                    locale: "fr_FR" // Utilisation du locale français pour accepter la virgule
                                }
                                color: fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                                
                                // Fonction pour remplacer les virgules par des points lors de la conversion en nombre
                                function getValue() {
                                    return parseFloat(text.replace(',', '.'));
                                }
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
                        
                        GridLayout {
                            columns: 2
                            Layout.fillWidth: true
                            
                            Label { 
                                text: "Input File:" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            
                            Item {
                                id: useDefaultInputToggle
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.preferredHeight: 30
                                
                                property bool checked: false
                                
                                Rectangle {
                                    anchors.fill: parent
                                    radius: height / 2
                                    color: "transparent"
                                    border.width: 1
                                    border.color: toggleBorderColor
                                    
                                    Rectangle {
                                        width: parent.width / 2
                                        height: parent.height - 4
                                        radius: height / 2
                                        x: useDefaultInputToggle.checked ? parent.width - width - 2 : 2
                                        y: 2
                                        color: useDefaultInputToggle.checked ? toggleActiveColor : toggleInactiveColor
                                        
                                        Behavior on x {
                                            NumberAnimation { 
                                                duration: animationDuration
                                                easing.type: Easing.InOutQuad
                                            }
                                        }
                                    }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: useDefaultInputToggle.checked ? "Défaut" : "Perso"
                                        color: fieldText
                                        font.family: orbitronFont.name
                                        font.pixelSize: 10
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        useDefaultInputToggle.checked = !useDefaultInputToggle.checked
                                        if (useDefaultInputToggle.checked) {
                                            inputFileField.text = ""
                                        }
                                    }
                                }
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: window.spacing / 2
                            
                            TextField {
                                id: inputFileField
                                Layout.fillWidth: true
                                placeholderText: useDefaultInputToggle.checked ? "Using default path" : "Choose a WAV file..."
                                readOnly: true
                                color: useDefaultInputToggle.checked ? Qt.darker(fieldText, 1.3) : fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: useDefaultInputToggle.checked ? Qt.darker(fieldBackground, 1.2) : fieldBackground
                                    radius: borderRadius / 2
                                }
                                enabled: !useDefaultInputToggle.checked
                            }
                            
                            Button {
                                text: "Browse..."
                                font.family: orbitronFont.name
                                onClicked: inputFileDialog.open()
                                enabled: !useDefaultInputToggle.checked
                                opacity: useDefaultInputToggle.checked ? 0.5 : 1.0
                                
                                contentItem: Text {
                                    text: parent.text
                                    font.family: orbitronFont.name
                                    color: parent.hovered ? window.buttonHoverText : window.buttonText
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
                        
                        GridLayout {
                            columns: 2
                            Layout.fillWidth: true
                            
                            Label { 
                                text: "Output Folder:" 
                                font.family: orbitronFont.name
                                color: primaryTextColor
                            }
                            
                            Item {
                                id: useDefaultOutputToggle
                                Layout.preferredWidth: window.isSmall ? 120 : 80
                                Layout.preferredHeight: 30
                                
                                property bool checked: false
                                
                                Rectangle {
                                    anchors.fill: parent
                                    radius: height / 2
                                    color: "transparent"
                                    border.width: 1
                                    border.color: toggleBorderColor
                                    
                                    Rectangle {
                                        width: parent.width / 2
                                        height: parent.height - 4
                                        radius: height / 2
                                        x: useDefaultOutputToggle.checked ? parent.width - width - 2 : 2
                                        y: 2
                                        color: useDefaultOutputToggle.checked ? toggleActiveColor : toggleInactiveColor
                                        
                                        Behavior on x {
                                            NumberAnimation { 
                                                duration: animationDuration
                                                easing.type: Easing.InOutQuad
                                            }
                                        }
                                    }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: useDefaultOutputToggle.checked ? "Défaut" : "Perso"
                                        color: fieldText
                                        font.family: orbitronFont.name
                                        font.pixelSize: 10
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        useDefaultOutputToggle.checked = !useDefaultOutputToggle.checked
                                        if (useDefaultOutputToggle.checked) {
                                            outputFolderField.text = ""
                                        }
                                    }
                                }
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: window.spacing / 2
                            
                            TextField {
                                id: outputFolderField
                                Layout.fillWidth: true
                                placeholderText: useDefaultOutputToggle.checked ? "Using default path" : "Choose a folder..."
                                readOnly: true
                                color: useDefaultOutputToggle.checked ? Qt.darker(fieldText, 1.3) : fieldText
                                font.family: orbitronFont.name
                                background: Rectangle {
                                    color: useDefaultOutputToggle.checked ? Qt.darker(fieldBackground, 1.2) : fieldBackground
                                    radius: borderRadius / 2
                                }
                                enabled: !useDefaultOutputToggle.checked
                            }
                            
                            Button {
                                text: "Browse..."
                                font.family: orbitronFont.name
                                onClicked: outputFolderDialog.open()
                                enabled: !useDefaultOutputToggle.checked
                                opacity: useDefaultOutputToggle.checked ? 0.5 : 1.0
                                
                                contentItem: Text {
                                    text: parent.text
                                    font.family: orbitronFont.name
                                    color: parent.hovered ? window.buttonHoverText : window.buttonText
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
                
                // Separator
                Rectangle {
                    height: 1
                    color: separatorColor
                    Layout.fillWidth: true
                    Layout.topMargin: window.spacing
                    Layout.bottomMargin: window.spacing
                }
                
                // Buttons container
                RowLayout {
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
                            id: previewButtonResetTimer
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
                                color: parent.parent.hovered || parent.parent.isAnimating || parent.parent.isProcessing ? window.buttonHoverText : window.buttonText
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
                                color: parent.parent.hovered || parent.parent.isAnimating || parent.parent.isProcessing ? window.buttonHoverText : window.buttonText
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
                                    source: "image://preview/" + (generator.previewCounter === 0 ? "init" : generator.previewCounter)
                                    
                                    // Gérer les erreurs de chargement
                                    Component.onCompleted: {
                                        console.log("Image component completed");
                                        console.log("Initial source: " + source);
                                    }
                                    
                                    onSourceChanged: {
                                        console.log("Image source changed: " + source);
                                        console.log("Image width: " + width + ", height: " + height);
                                        console.log("Parent width: " + parent.width + ", height: " + parent.height);
                                    }
                                    
                                    onStatusChanged: {
                                        console.log("Image status changed: " + status);
                                        if (status === Image.Ready) {
                                            console.log("Image loaded successfully: " + source);
                                            console.log("Image size: " + sourceSize.width + "x" + sourceSize.height);
                                            console.log("Image width: " + width + ", height: " + height);
                                            console.log("Image visible: " + visible);
                                            console.log("Image opacity: " + opacity);
                                        } else if (status === Image.Loading) {
                                            console.log("Image loading: " + source);
                                        } else if (status === Image.Error) {
                                            console.log("Error loading image: " + source);
                                            previewStatusText.text = "Error loading preview image"
                                            previewStatusText.color = errorColor
                                        }
                                    }
                                    
                                    onPaintedWidthChanged: {
                                        console.log("Image painted width changed: " + paintedWidth);
                                    }
                                    
                                    onPaintedHeightChanged: {
                                        console.log("Image painted height changed: " + paintedHeight);
                                    }
                                }
                            }
                        }
                        
                        // Afficher un message si aucune prévisualisation n'est disponible
                        Text {
                            anchors.centerIn: parent
                            text: "Click 'Refresh Preview' to generate a preview"
                            color: fieldText
                            font.family: orbitronFont.name
                            visible: !previewImageLoader.active || generator.previewCounter === 0
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
                
                // Espace pour les contrôles supplémentaires de prévisualisation si nécessaire
            }
        }
    }
}
