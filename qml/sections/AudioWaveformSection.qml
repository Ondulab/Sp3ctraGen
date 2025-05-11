import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import "../components"
import "../styles" as AppStyles

/**
 * Section de la forme d'onde audio
 * 
 * Cette section affiche la forme d'onde du fichier audio et permet
 * de sélectionner un segment pour la génération du spectrogramme.
 */
SectionContainer {
    id: audioWaveformSection
    title: "Audio Waveform"
    preferredHeight: 200
    
    // Références aux dépendances externes
    property var waveformProvider: null
    property var generator: null
    property var inputFileDialog: null
    
    // Propriétés exposées
    property alias audioWaveform: audioWaveform
    property alias cursorPosition: audioWaveform.cursorPosition
    property alias segmentStart: audioWaveform.segmentStart
    property alias segmentDuration: audioWaveform.segmentDuration
    property string audioFilePath: ""
    
    // Propriétés pour les paramètres de génération
    property int pageFormat: 0
    property double writingSpeed: 8.0
    
    // Signaux
    signal audioFileLoaded(bool success, real duration, int sampleRate)
    signal segmentSelected(double startPosition, double duration)
    signal requestGenerateSpectrogram()
    
    // Handler pour le chargement de fichier
    function onFileLoaded(success, durationSeconds, sampleRate) {
        if (success) {
            // Obtenir les données de forme d'onde pour l'affichage
            var waveformWidth = audioWaveform.width
            audioWaveform.waveformData = waveformProvider.getWaveformData(waveformWidth)
            
            // Calculer le segment initial
            var segment = waveformProvider.calculateExtractionSegment(
                audioWaveform.cursorPosition,
                pageFormat,
                writingSpeed
            )
            
            // Mettre à jour les indicateurs visuels
            audioWaveform.segmentStart = segment.startPosition / waveformProvider.getTotalDuration()
            audioWaveform.segmentDuration = segment.duration / waveformProvider.getTotalDuration()
            
            statusText.showSuccess("Audio file loaded: " + durationSeconds.toFixed(2) + " seconds at " + sampleRate + " Hz")
            
            // Émettre le signal avec les informations
            audioFileLoaded(success, durationSeconds, sampleRate)
        } else {
            statusText.showError("Error loading audio file")
        }
    }
    
    // Mise en page
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: AppStyles.Theme.spacing
        
        // Composant de visualisation de forme d'onde
        AudioWaveform {
            id: audioWaveform
            Layout.fillWidth: true
            Layout.fillHeight: true
            waveColor: AppStyles.Theme.primaryTextColor
            
            onCursorMoved: {
                // Calculer le segment à extraire
                if (waveformProvider && waveformProvider.getTotalDuration() > 0) {
                    var segment = waveformProvider.calculateExtractionSegment(
                        position,
                        pageFormat,
                        writingSpeed
                    )
                    
                    // Mettre à jour les indicateurs visuels
                    audioWaveform.segmentStart = segment.startPosition / waveformProvider.getTotalDuration()
                    audioWaveform.segmentDuration = segment.duration / waveformProvider.getTotalDuration()
                    
                    // Mettre à jour le texte d'information
                    var startSec = segment.startPosition.toFixed(2)
                    var durationSec = segment.duration.toFixed(2)
                    statusText.text = "Position: " + startSec + "s, Segment duration: " + durationSec + "s"
                    
                    // Émettre le signal avec les informations du segment
                    segmentSelected(segment.startPosition, segment.duration)
                }
            }
        }
        
        // Boutons pour la forme d'onde
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: AppStyles.Theme.spacing
            
            Button {
                id: loadAudioButton
                text: "Load Audio"
                
                onClicked: {
                    if (inputFileDialog) {
                        inputFileDialog.open()
                        
                        // Connecter temporairement au signal accepted
                        var connection = function() {
                            var filePath = inputFileDialog.fileUrl.toString().replace("file://", "")
                            audioWaveformSection.audioFilePath = filePath
                            
                            if (waveformProvider) {
                                waveformProvider.loadFile(filePath)
                            }
                            
                            inputFileDialog.accepted.disconnect(connection)
                        }
                        
                        inputFileDialog.accepted.connect(connection)
                    }
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
            
            Button {
                id: generateFromSegmentButton
                text: "Generate Spectrogram"
                
                onClicked: {
                    if (!waveformProvider || waveformProvider.getTotalDuration() <= 0) {
                        statusText.showError("No audio file loaded")
                        return
                    }
                    
                    statusText.text = "Generating segment preview..."
                    requestGenerateSpectrogram()
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
        
        // Texte de statut pour la forme d'onde
        StatusText {
            id: statusText
            text: "No audio file loaded"
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
        }
    }
    
    // Initialiser les connexions aux signaux du fournisseur de données
    Component.onCompleted: {
        if (waveformProvider) {
            waveformProvider.fileLoaded.connect(onFileLoaded)
        }
    }
    
    // Méthodes publiques
    function loadAudioFile(filePath) {
        if (waveformProvider) {
            audioFilePath = filePath
            waveformProvider.loadFile(filePath)
        }
    }
    
    function extractCurrentSegment() {
        if (!waveformProvider || waveformProvider.getTotalDuration() <= 0) {
            return null
        }
        
        // Calculer le segment à extraire
        var segment = waveformProvider.calculateExtractionSegment(
            audioWaveform.cursorPosition,
            pageFormat,
            writingSpeed
        )
        
        // Extraire le segment audio
        return waveformProvider.extractSegment(
            segment.startPosition,
            segment.duration
        )
    }
    
    function getAudioFileName() {
        if (!audioFilePath) return ""
        
        var audioFileName = audioFilePath
        return audioFileName.split('/').pop() // Extraire juste le nom du fichier
    }
    
    function getStartPosition() {
        if (!waveformProvider || waveformProvider.getTotalDuration() <= 0) {
            return 0
        }
        
        var segment = waveformProvider.calculateExtractionSegment(
            audioWaveform.cursorPosition,
            pageFormat,
            writingSpeed
        )
        
        return segment.startPosition
    }
}
