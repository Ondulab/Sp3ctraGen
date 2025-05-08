import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import com.spectrogen.backend 1.0
import com.spectrogen.constants 1.0
import "./components"

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
    property color primaryTextColor: Constants.primaryTextColor
    property color fieldBackground: Constants.fieldBackground
    property color fieldText: Constants.fieldText
    property color buttonBackground: Constants.buttonBackground
    property color buttonText: Constants.buttonText
    property color buttonHoverBackground: Constants.buttonHoverBackground
    property color buttonHoverText: Constants.buttonHoverText
    property color borderColor: Constants.borderColor
    property color toggleBorderColor: Constants.toggleBorderColor
    property color toggleActiveColor: Constants.toggleActiveColor
    property color toggleInactiveColor: Constants.toggleInactiveColor
    property color separatorColor: Constants.separatorColor
    property color successColor: Constants.successColor
    property color errorColor: Constants.errorColor
    property int spacing: Constants.spacing
    property int margin: Constants.margin
    property int padding: Constants.padding
    property int borderRadius: Constants.borderRadius
    property int borderWidth: Constants.borderWidth
    property int titleFontSize: Constants.titleFontSize
    property int labelFontSize: Constants.labelFontSize
    property int textFontSize: Constants.textFontSize
    property int animationDuration: Constants.animationDuration
    
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

    // Layout principal avec division horizontale
    RowLayout {
        anchors.fill: parent
        anchors.margins: margin
        spacing: window.spacing
        
        // Partie gauche - Paramètres (simplifiée)
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
                
                // Champs cachés pour les paramètres
                // Champs cachés pour les paramètres
                ValidatedTextField {
                    id: fftSizeField
                    visible: false
                    defaultValue: Constants.defaultFftSize.toString()
                    isNumeric: true
                    allowDecimals: false
                }
                
                ValidatedTextField {
                    id: overlapField
                    visible: false
                    defaultValue: Constants.defaultOverlap.toString()
                    isNumeric: true
                    allowDecimals: true
                    minValue: 0.0
                    maxValue: 0.99
                }
                
                ValidatedTextField {
                    id: minFreqField
                    visible: false
                    defaultValue: Constants.defaultMinFreq.toString()
                    isNumeric: true
                    allowDecimals: true
                    minValue: 20.0
                }
                
                ValidatedTextField {
                    id: maxFreqField
                    visible: false
                    defaultValue: Constants.defaultMaxFreq.toString()
                    isNumeric: true
                    allowDecimals: true
                    minValue: 100.0
                }
                
                ValidatedTextField {
                    id: durationField
                    visible: false
                    defaultValue: Constants.defaultDuration.toString()
                    isNumeric: true
                    allowDecimals: true
                    minValue: 0.1
                }
                
                ValidatedTextField {
                    id: sampleRateField
                    visible: false
                    defaultValue: Constants.defaultSampleRate.toString()
                    isNumeric: true
                    allowDecimals: false
                    minValue: 8000
                }
                
                ValidatedTextField {
                    id: dynamicRangeField
                    visible: false
                    defaultValue: Constants.defaultDynamicRange.toString()
                    isNumeric: true
                    allowDecimals: true
                    minValue: 20.0
                    maxValue: 120.0
                }
                
                ValidatedTextField {
                    id: gammaCorrectionField
                    visible: false
                    defaultValue: Constants.defaultGammaCorrection.toString()
                    isNumeric: true
                    allowDecimals: true
                    minValue: 0.1
                    maxValue: 2.0
                }
                
                Item {
                    id: ditheringToggle
                    visible: false
                    property bool checked: Constants.defaultEnableDithering
                }
                
                ValidatedTextField {
                    id: contrastFactorField
                    visible: false
                    defaultValue: Constants.defaultContrastFactor.toString()
                    isNumeric: true
                    allowDecimals: true
                    minValue: 0.1
                    maxValue: 5.0
                }
                
                Item {
                    id: highBoostToggle
                    visible: false
                    property bool checked: Constants.defaultEnableHighBoost
                }
                
                ValidatedTextField {
                    id: highBoostAlphaField
                    visible: false
                    defaultValue: Constants.defaultHighBoostAlpha.toString()
                    isNumeric: true
                    allowDecimals: true
                    minValue: 0.0
                    maxValue: 1.0
                }
                
                Item {
                    id: pageFormatCombo
                    visible: false
                    property int currentIndex: 0
                }
                
                ValidatedTextField {
                    id: bottomMarginField
                    visible: false
                    defaultValue: "50.0"
                    isNumeric: true
                    allowDecimals: true
                    minValue: 0.0
                }
                
                ValidatedTextField {
                    id: spectroHeightField
                    visible: false
                    defaultValue: "216.7"
                    isNumeric: true
                    allowDecimals: true
                    minValue: 50.0
                }
                
                ValidatedTextField {
                    id: writingSpeedField
                    visible: false
                    defaultValue: "8.0"
                    isNumeric: true
                    allowDecimals: true
                    minValue: 0.1
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
                
                // Boutons
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: window.spacing
                    
                    // Bouton Refresh Preview
                    AnimatedButton {
                        id: refreshPreviewButton
                        text: "Refresh Preview"
                        successText: "Preview Updated!"
                        processingText: "Processing..."
                        Layout.preferredWidth: 180
                        
                        // Connecter le signal processingStarted à la fonction de génération
                        onProcessingStarted: {
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
                    
                    // Generate button (simplifié)
                    AnimatedButton {
                        id: generateButton
                        text: "Generate Spectrogram"
                        successText: "Spectrogram Generated!"
                        processingText: "Generating..."
                        Layout.preferredWidth: 180
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
    }
}
