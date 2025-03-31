import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import com.cisynth.backend 1.0

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
        }
    }

    // Folder selection dialog
    FileDialog {
        id: outputFolderDialog
        title: "Select Output Folder"
        selectFolder: true
        onAccepted: {
            outputFolderField.text = fileUrl.toString().replace("file://", "")
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
                property string originalText: "Generate Spectrogram"
                property string successText: "Success!"
                
                function startSuccessAnimation() {
                    isAnimating = true
                    blinkAnimation.start()
                    textChangeTimer.start()
                    resetTimer.start()
                }
                
                Timer {
                    id: textChangeTimer
                    interval: 200
                    onTriggered: {
                        generateButton.text = generateButton.successText
                    }
                }
                
                Timer {
                    id: resetTimer
                    interval: 2000
                    onTriggered: {
                        blinkAnimation.stop()
                        generateButton.text = generateButton.originalText
                        generateButton.isAnimating = false
                        generateButton.background.color = buttonBackground
                    }
                }
                
                SequentialAnimation {
                    id: blinkAnimation
                    loops: 4
                    
                    PropertyAnimation {
                        target: generateButton.background
                        property: "color"
                        to: successColor
                        duration: 250
                    }
                    
                    PropertyAnimation {
                        target: generateButton.background
                        property: "color"
                        to: buttonBackground
                        duration: 250
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    font.family: orbitronFont.name
                    font.pixelSize: labelFontSize
                    color: parent.hovered || parent.isAnimating ? buttonHoverText : buttonText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                background: Rectangle {
                    color: parent.hovered ? buttonHoverBackground : buttonBackground
                    radius: borderRadius
                    implicitHeight: 40
                    
                    Behavior on color {
                        ColorAnimation { 
                            duration: animationDuration
                        }
                    }
                }
                
                onClicked: {
                    // Check if required fields are filled
                    if (inputFileField.text === "" || outputFolderField.text === "") {
                        statusText.text = "Please select an input file and output folder"
                        statusText.color = errorColor
                        return
                    }

                    // Call the spectrogram generation function
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

            // Status text
            Text {
                id: statusText
                Layout.fillWidth: true
                Layout.topMargin: window.spacing
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                font.family: orbitronFont.name
                // Color is set dynamically
            }
        }
    }
}
