import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import com.cisynth.backend 1.0

ApplicationWindow {
    id: window
    title: "CISYNTH Spectrogram Generator"
    width: 500
    height: 700
    visible: true

    // Référence au backend C++
    SpectrogramGenerator {
        id: generator
        onSpectrogramGenerated: {
            if (success) {
                statusText.text = "Spectrogramme généré avec succès: " + outputPath
                statusText.color = "green"
            } else {
                statusText.text = "Erreur lors de la génération du spectrogramme: " + errorMessage
                statusText.color = "red"
            }
        }
    }

    // Dialogue de sélection de fichier
    FileDialog {
        id: inputFileDialog
        title: "Sélectionner un fichier WAV"
        nameFilters: ["Fichiers audio (*.wav)"]
        onAccepted: {
            inputFileField.text = fileUrl.toString().replace("file://", "")
        }
    }

    // Dialogue de sélection de dossier
    FileDialog {
        id: outputFolderDialog
        title: "Sélectionner un dossier de sortie"
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
            anchors.margins: 20
            spacing: 10

            Label {
                text: "Paramètres du Spectrogramme"
                font.bold: true
                font.pixelSize: 16
                Layout.topMargin: 10
            }

            // Paramètres du spectrogramme
            GridLayout {
                columns: 2
                Layout.fillWidth: true
                columnSpacing: 10
                rowSpacing: 8

                Label { text: "Taille FFT:" }
                TextField {
                    id: fftSizeField
                    text: "8192"
                    Layout.preferredWidth: 80
                    validator: IntValidator { bottom: 1 }
                }

                Label { text: "Chevauchement (0..1):" }
                TextField {
                    id: overlapField
                    text: "0.85"
                    Layout.preferredWidth: 80
                    validator: DoubleValidator { bottom: 0.0; top: 1.0 }
                }

                Label { text: "Fréquence Min (Hz):" }
                TextField {
                    id: minFreqField
                    text: "65"
                    Layout.preferredWidth: 80
                    validator: DoubleValidator { bottom: 0.0 }
                }

                Label { text: "Fréquence Max (Hz):" }
                TextField {
                    id: maxFreqField
                    text: "16640"
                    Layout.preferredWidth: 80
                    validator: DoubleValidator { bottom: 0.0 }
                }

                Label { text: "Durée (s):" }
                TextField {
                    id: durationField
                    text: "4.0"
                    Layout.preferredWidth: 80
                    validator: DoubleValidator { bottom: 0.0 }
                }

                Label { text: "Taux d'échantillonnage:" }
                TextField {
                    id: sampleRateField
                    text: "192000"
                    Layout.preferredWidth: 80
                    validator: IntValidator { bottom: 1 }
                }

                Label { text: "Plage dynamique (dB):" }
                TextField {
                    id: dynamicRangeField
                    text: "60.0"
                    Layout.preferredWidth: 80
                    validator: DoubleValidator { bottom: 0.0 }
                }

                Label { text: "Correction gamma:" }
                TextField {
                    id: gammaCorrectionField
                    text: "0.8"
                    Layout.preferredWidth: 80
                    validator: DoubleValidator { bottom: 0.0 }
                }

                Label { text: "Activer Dithering:" }
                CheckBox {
                    id: ditheringCheckBox
                    checked: false
                }

                Label { text: "Facteur de contraste:" }
                TextField {
                    id: contrastFactorField
                    text: "1.9"
                    Layout.preferredWidth: 80
                    validator: DoubleValidator { bottom: 0.0 }
                }

                Label { text: "Filtre High Boost:" }
                CheckBox {
                    id: highBoostCheckBox
                    checked: true
                }

                Label { text: "Alpha High Boost:" }
                TextField {
                    id: highBoostAlphaField
                    text: "0.99"
                    Layout.preferredWidth: 80
                    validator: DoubleValidator { bottom: 0.0; top: 1.0 }
                }
            }

            Rectangle {
                height: 1
                color: "#cccccc"
                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.bottomMargin: 10
            }

            // Sélection de fichiers
            Label { text: "Fichier d'entrée:" }
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputFileField
                    Layout.fillWidth: true
                    placeholderText: "Choisir un fichier WAV..."
                    readOnly: true
                }
                Button {
                    text: "Parcourir..."
                    onClicked: inputFileDialog.open()
                }
            }

            Label { text: "Dossier de sortie:" }
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: outputFolderField
                    Layout.fillWidth: true
                    placeholderText: "Choisir un dossier..."
                    readOnly: true
                }
                Button {
                    text: "Parcourir..."
                    onClicked: outputFolderDialog.open()
                }
            }

            Button {
                text: "Générer le Spectrogramme"
                Layout.topMargin: 10
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    // Vérifier que les champs obligatoires sont remplis
                    if (inputFileField.text === "" || outputFolderField.text === "") {
                        statusText.text = "Veuillez sélectionner un fichier d'entrée et un dossier de sortie"
                        statusText.color = "red"
                        return
                    }

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
                        ditheringCheckBox.checked,
                        parseFloat(contrastFactorField.text),
                        highBoostCheckBox.checked,
                        parseFloat(highBoostAlphaField.text),
                        inputFileField.text,
                        outputFolderField.text
                    )
                }
            }

            // Texte de statut
            Text {
                id: statusText
                Layout.fillWidth: true
                Layout.topMargin: 10
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
