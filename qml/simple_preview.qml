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
                // Forcer le rechargement de l'image en utilisant un timestamp
                previewImage.source = ""  // Effacer l'image précédente
                previewImage.source = "image://preview/" + Date.now()  // Utiliser un timestamp pour éviter le cache
                previewStatusText.text = "Preview updated"
                previewStatusText.color = successColor
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
        
        // Partie gauche - Paramètres
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
                
                // Bouton Refresh Preview
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
                        // Appeler la fonction de génération de prévisualisation avec des valeurs par défaut
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
                            0,       // pageFormat
                            50.0,    // bottomMarginMM - 50mm est correct en tant que valeur physique
                            169.5,   // spectroHeightMM - ajusté pour mieux s'adapter à l'écran avec 800 DPI
                            8.0,     // writingSpeed
                            ""       // inputFile (utilise le chemin par défaut)
                        )
                    }
                }
                
                // Bouton Save Preview
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
                        // Sauvegarder la prévisualisation
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
        
        // Partie droite - Prévisualisation
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
