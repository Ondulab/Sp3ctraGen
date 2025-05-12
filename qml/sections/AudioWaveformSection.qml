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
    property var writingSpeed: 8.0  // Utiliser 'var' au lieu de 'double' pour une meilleure détection des changements
    property var fftSize: 8192      // Idem pour fftSize
    
    // Observer les changements de vitesse d'écriture pour mettre à jour le segment
    onWritingSpeedChanged: {
        // Ajouter un logging détaillé pour diagnostiquer le problème
        console.log("*** onWritingSpeedChanged triggered ***")
        console.log("  - writingSpeed type:", typeof writingSpeed)
        console.log("  - writingSpeed value:", writingSpeed)
        console.log("  - After parseFloat:", parseFloat(writingSpeed))
        
        // Recalculer le segment lorsque la vitesse d'écriture change
        if (waveformProvider && waveformProvider.getTotalDuration() > 0 && audioWaveform) {
            // Convertir explicitement la valeur en nombre pour éviter les problèmes avec les points décimaux
            var numericSpeed = parseFloat(writingSpeed)
            console.log("  - Calling _updateSegmentWithNumericSpeed with:", numericSpeed)
            _updateSegmentWithNumericSpeed(numericSpeed)
        }
    }
    
    // Fonction helper pour mettre à jour avec une valeur numérique
    function _updateSegmentWithNumericSpeed(speedValue) {
        console.log("Mise à jour du segment avec vitesse numérique:", speedValue)
        updateSegmentDisplay(audioWaveform.cursorPosition)
    }
    
    // Observer les changements de taille FFT pour mettre à jour le segment
    onFftSizeChanged: {
        // Recalculer le segment lorsque la taille FFT change
        if (waveformProvider && waveformProvider.getTotalDuration() > 0 && audioWaveform) {
            updateSegmentDisplay(audioWaveform.cursorPosition)
        }
    }
    
    // Signaux
    signal audioFileLoaded(bool success, real duration, int sampleRate)
    signal segmentSelected(double startPosition, double duration)
    signal requestGenerateSpectrogram()
    
    // Handler pour le chargement de fichier
    function onFileLoaded(success, durationSeconds, sampleRate) {
        console.log("AudioWaveformSection: onFileLoaded callback called with success=" + success);
        
        if (success) {
            // Vérifier que audioWaveform est correctement initialisé
            if (audioWaveform) {
                console.log("AudioWaveformSection: audioWaveform is correctly initialized");
                
                // Obtenir les données de forme d'onde pour l'affichage
                var waveformWidth = audioWaveform.width;
                audioWaveform.waveformData = waveformProvider.getWaveformData(waveformWidth);
                
                // Calculer le segment initial
                var segment = waveformProvider.calculateExtractionSegment(
                    audioWaveform.cursorPosition,
                    pageFormat,
                    writingSpeed,
                    fftSize
                );
                
                // Mettre à jour les indicateurs visuels
                audioWaveform.segmentStart = segment.startPosition / waveformProvider.getTotalDuration();
                audioWaveform.segmentDuration = segment.duration / waveformProvider.getTotalDuration();
            } else {
                console.log("AudioWaveformSection: WARNING - audioWaveform is not initialized!");
            }
            
            if (statusText) {
                statusText.showSuccess("Audio file loaded: " + durationSeconds.toFixed(2) + " seconds at " + sampleRate + " Hz");
            }
            
            // Émettre le signal avec les informations
            audioFileLoaded(success, durationSeconds, sampleRate);
        } else {
            if (statusText) {
                statusText.showError("Error loading audio file");
            }
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
            showSegment: true  // S'assurer que l'affichage du segment est activé
            
            onCursorMoved: {
                // Utiliser la fonction factoriée pour mettre à jour le segment
                if (waveformProvider && waveformProvider.getTotalDuration() > 0) {
                    updateSegmentDisplay(position)
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
                    if (typeof openInputFileDialog === "function") {
                        // Utiliser la fonction d'ouverture sécurisée définie dans main.qml
                        openInputFileDialog()
                    } else if (inputFileDialog) {
                        // Fallback au cas où openInputFileDialog n'est pas disponible
                        inputFileDialog.open()
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
            writingSpeed,
            fftSize
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
            writingSpeed,
            fftSize
        )
        
        return segment.startPosition
    }
    
    // Fonction factorisée pour mettre à jour l'affichage du segment
    function updateSegmentDisplay(position) {
        if (!waveformProvider || waveformProvider.getTotalDuration() <= 0) {
            return
        }
        
        var segment = waveformProvider.calculateExtractionSegment(
            position,
            pageFormat,
            writingSpeed,
            fftSize
        )
        // Mettre à jour les indicateurs visuels
        var relativeStart = segment.startPosition / waveformProvider.getTotalDuration()
        var relativeDuration = segment.duration / waveformProvider.getTotalDuration()
        
        console.log("Mise à jour du segment - Valeurs absolues:",
                    "startPosition =", segment.startPosition.toFixed(2),
                    "duration =", segment.duration.toFixed(2))
        console.log("Mise à jour du segment - Valeurs relatives:",
                    "segmentStart =", relativeStart.toFixed(4),
                    "segmentDuration =", relativeDuration.toFixed(4))
        
        audioWaveform.segmentStart = relativeStart
        audioWaveform.segmentDuration = relativeDuration
        
        
        // Mettre à jour le texte d'information
        var startSec = segment.startPosition.toFixed(2)
        var durationSec = segment.duration.toFixed(2)
        statusText.text = "Position: " + startSec + "s, Segment duration: " + durationSec + "s"
        
        // Émettre le signal avec les informations du segment
        segmentSelected(segment.startPosition, segment.duration)
    }
    
    // Nous n'utiliserons pas de Connections ici pour éviter les erreurs de structure QML
}
