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
    
    // Style properties
    property color primaryTextColor: "#D4AF37"
    property color fieldBackground: "#333"
    property color fieldText: "#BBB"
    property color buttonBackground: "#555"
    property color buttonText: "#000"
    property color buttonHoverBackground: "#333"
    property color buttonHoverText: "#FFF"
    property color borderColor: "#D4AF37"
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
    
    // C++ backend reference
    SpectrogramGenerator {
        id: generator
        onSpectrogramGenerated: {
            console.log("Signal spectrogramGenerated received: success=" + success + ", outputPath=" + outputPath + ", errorMessage=" + errorMessage);
            
            if (success) {
                statusText.text = "Spectrogram successfully generated: " + outputPath
                statusText.color = successColor
            } else {
                statusText.text = "Error generating spectrogram: " + errorMessage
                statusText.color = errorColor
            }
        }
        
        onPreviewGenerated: {
            console.log("Signal previewGenerated received: success=" + success + ", errorMessage=" + errorMessage);
            
            if (success) {
                // Force image reload using a timestamp
                previewImage.source = ""  // Clear previous image
                previewImage.source = "image://preview/" + Date.now()  // Use timestamp to avoid cache
                previewStatusText.text = "Preview updated"
                previewStatusText.color = successColor
            } else {
                previewStatusText.text = "Error generating preview: " + errorMessage
                previewStatusText.color = errorColor
            }
        }
    }

    // Main layout with horizontal division
    RowLayout {
        anchors.fill: parent
        anchors.margins: margin
        spacing: window.spacing
        
        // Left side - Parameters
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.5
            color: "#222"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: window.spacing
                
                Label {
                    text: "SpectroGen"
                    font.bold: true
                    font.pixelSize: titleFontSize
                    font.family: orbitronFont.name
                    color: primaryTextColor
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Refresh Preview button
                Button {
                    id: refreshPreviewButton
                    text: "Refresh Preview"
                    font.family: orbitronFont.name
                    font.pixelSize: labelFontSize
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 180
                    
                    background: Rectangle {
                        color: parent.hovered ? buttonHoverBackground : buttonBackground
                        radius: borderRadius
                        implicitHeight: 40
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: orbitronFont.name
                        font.pixelSize: labelFontSize
                        color: parent.hovered ? buttonHoverText : buttonText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        // Call the preview generation function with default values
                        generator.generatePreview(
                            8192,    // fftSize
                            0.85,    // overlap
                            65,      // minFreq
                            16640,   // maxFreq
                            4.0,     // duration
                            192000,  // sampleRate
                            60.0,    // dynamicRangeDB
                            0.8,     // gammaCorrection
                            false,   // enableDithering
                            1.9,     // contrastFactor
                            true,    // enableHighBoost
                            0.99,    // highBoostAlpha
                            false,   // enableHighPassFilter
                            100.0,   // highPassCutoffFreq
                            2,       // highPassFilterOrder
                            0,       // pageFormat
                            50.0,    // bottomMarginMM - 50mm is correct as a physical value
                            169.5,   // spectroHeightMM - adjusted to better fit the screen at 800 DPI
                            8.0,     // writingSpeed
                            "",      // inputFile (uses default path)
                            verticalScaleToggle.checked,
                            bottomLineToggle.checked,
                            parseFloat(bottomLineOffsetField.text),
                            topLineToggle.checked,
                            parseFloat(topLineOffsetField.text),
                            showParamsToggle.checked,
                            2.0,     // textScaleFactor - to increase text size
                            2.0      // lineThicknessFactor - to increase line thickness
                        )
                    }
                }
                
                // Controls for new features
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: outputOptionsLayout.implicitHeight + 2 * padding
                    color: "transparent"
                    border.width: borderWidth
                    border.color: borderColor
                    radius: borderRadius
                    Layout.topMargin: 10
                    
                    ColumnLayout {
                        id: outputOptionsLayout
                        anchors.fill: parent
                        anchors.margins: padding
                        spacing: window.spacing
                        
                        Label {
                            text: "Output Format Options"
                            font.bold: true
                            font.pixelSize: labelFontSize
                            font.family: orbitronFont.name
                            color: primaryTextColor
                        }
                        
                        // Vertical scale
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: window.spacing
                            
                            Label {
                                text: "Vertical Scale:"
                                font.family: orbitronFont.name
                                color: primaryTextColor
                                Layout.preferredWidth: 120
                            }
                            
                            Switch {
                                id: verticalScaleToggle
                                checked: true
                                
                                indicator: Rectangle {
                                    implicitWidth: 40
                                    implicitHeight: 20
                                    radius: 10
                                    color: parent.checked ? toggleActiveColor : toggleInactiveColor
                                    border.color: toggleBorderColor
                                    border.width: 1
                                    
                                    Rectangle {
                                        x: parent.parent.checked ? parent.width - width - 2 : 2
                                        y: 2
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: "white"
                                        
                                        Behavior on x {
                                            NumberAnimation { duration: 200 }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Bottom reference line
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: window.spacing
                            
                            Label {
                                text: "Bottom Line:"
                                font.family: orbitronFont.name
                                color: primaryTextColor
                                Layout.preferredWidth: 120
                            }
                            
                            Switch {
                                id: bottomLineToggle
                                checked: false
                                
                                indicator: Rectangle {
                                    implicitWidth: 40
                                    implicitHeight: 20
                                    radius: 10
                                    color: parent.checked ? toggleActiveColor : toggleInactiveColor
                                    border.color: toggleBorderColor
                                    border.width: 1
                                    
                                    Rectangle {
                                        x: parent.parent.checked ? parent.width - width - 2 : 2
                                        y: 2
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: "white"
                                        
                                        Behavior on x {
                                            NumberAnimation { duration: 200 }
                                        }
                                    }
                                }
                            }
                            
                            Label {
                                text: "Offset (mm):"
                                font.family: orbitronFont.name
                                color: primaryTextColor
                                visible: bottomLineToggle.checked
                            }
                            
                            TextField {
                                id: bottomLineOffsetField
                                text: "34.75"
                                Layout.preferredWidth: 60
                                visible: bottomLineToggle.checked
                                color: fieldText
                                font.family: orbitronFont.name
                                validator: DoubleValidator { bottom: 0; top: 100 }
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                        
                        // Top reference line
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: window.spacing
                            
                            Label {
                                text: "Top Line:"
                                font.family: orbitronFont.name
                                color: primaryTextColor
                                Layout.preferredWidth: 120
                            }
                            
                            Switch {
                                id: topLineToggle
                                checked: false
                                
                                indicator: Rectangle {
                                    implicitWidth: 40
                                    implicitHeight: 20
                                    radius: 10
                                    color: parent.checked ? toggleActiveColor : toggleInactiveColor
                                    border.color: toggleBorderColor
                                    border.width: 1
                                    
                                    Rectangle {
                                        x: parent.parent.checked ? parent.width - width - 2 : 2
                                        y: 2
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: "white"
                                        
                                        Behavior on x {
                                            NumberAnimation { duration: 200 }
                                        }
                                    }
                                }
                            }
                            
                            Label {
                                text: "Offset (mm):"
                                font.family: orbitronFont.name
                                color: primaryTextColor
                                visible: topLineToggle.checked
                            }
                            
                            TextField {
                                id: topLineOffsetField
                                text: "12.55"
                                Layout.preferredWidth: 60
                                visible: topLineToggle.checked
                                color: fieldText
                                font.family: orbitronFont.name
                                validator: DoubleValidator { bottom: 0; top: 100 }
                                background: Rectangle {
                                    color: fieldBackground
                                    radius: borderRadius / 2
                                }
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                        
                        // Parameters display
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: window.spacing
                            
                            Label {
                                text: "Show Parameters:"
                                font.family: orbitronFont.name
                                color: primaryTextColor
                                Layout.preferredWidth: 120
                            }
                            
                            Switch {
                                id: showParamsToggle
                                checked: false
                                
                                indicator: Rectangle {
                                    implicitWidth: 40
                                    implicitHeight: 20
                                    radius: 10
                                    color: parent.checked ? toggleActiveColor : toggleInactiveColor
                                    border.color: toggleBorderColor
                                    border.width: 1
                                    
                                    Rectangle {
                                        x: parent.parent.checked ? parent.width - width - 2 : 2
                                        y: 2
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: "white"
                                        
                                        Behavior on x {
                                            NumberAnimation { duration: 200 }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Save Preview button
                Button {
                    id: savePreviewButton
                    text: "Save Preview"
                    font.family: orbitronFont.name
                    font.pixelSize: labelFontSize
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 180
                    Layout.topMargin: 10
                    
                    background: Rectangle {
                        color: parent.hovered ? buttonHoverBackground : buttonBackground
                        radius: borderRadius
                        implicitHeight: 40
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: orbitronFont.name
                        font.pixelSize: labelFontSize
                        color: parent.hovered ? buttonHoverText : buttonText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        // Save the preview
                        generator.saveCurrentPreview("", "png");
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
                    Layout.preferredWidth: 250
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
        
        // Right side - Preview
        Rectangle {
            id: previewContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#1A1A1A"
            border.width: borderWidth
            border.color: borderColor
            radius: borderRadius
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: padding
                spacing: window.spacing
                
                // Preview title
                Label {
                    text: "Preview"
                    font.bold: true
                    font.pixelSize: labelFontSize
                    font.family: orbitronFont.name
                    color: primaryTextColor
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Preview area with ScrollView to allow scrolling
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    // Preview image
                    Image {
                        id: previewImage
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        width: parent.width
                        height: parent.height
                        cache: false
                        asynchronous: true
                        
                        // Display a message if no preview is available
                        Text {
                            anchors.centerIn: parent
                            text: "Click 'Refresh Preview' to generate a preview"
                            color: fieldText
                            font.family: orbitronFont.name
                            visible: previewImage.status !== Image.Ready || previewImage.source === ""
                        }
                        
                        // Handle loading errors
                        onStatusChanged: {
                            if (status === Image.Error) {
                                previewStatusText.text = "Error loading preview image"
                                previewStatusText.color = errorColor
                            }
                        }
                    }
                }
                
                // Status text for preview
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
    }
}
