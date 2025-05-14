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
    
    // Propriétés pour la normalisation
    property bool isAudioNormalized: false
    property real normalizationFactor: 1.0
    property string originalAudioPath: ""
    property string normalizedAudioPath: ""
    
    // Propriétés exposées
    property alias audioWaveform: audioWaveform
    property alias cursorPosition: audioWaveform.cursorPosition
    property alias segmentStart: audioWaveform.segmentStart
    property alias segmentDuration: audioWaveform.segmentDuration
    property string audioFilePath: ""
    
    // Propriétés pour les paramètres de génération
    property int pageFormat: 0
    property var writingSpeed: 8.0     // Utiliser 'var' au lieu de 'double' pour une meilleure détection des changements
    property var binsPerSecond: 150.0  // Remplace fftSize
    property int overlapPreset: 1      // 0=Low, 1=Medium, 2=High
    
    // Propriété pour stocker le chemin d'accès complet au fichier audio
    property string audioSourceUrl: ""
    
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
    
    // Observer les changements de binsPerSecond pour mettre à jour le segment
    onBinsPerSecondChanged: {
        // Recalculer le segment lorsque bins/s change
        if (waveformProvider && waveformProvider.getTotalDuration() > 0 && audioWaveform) {
            updateSegmentDisplay(audioWaveform.cursorPosition)
        }
    }
    
    // Observer les changements de overlapPreset pour mettre à jour le segment
    onOverlapPresetChanged: {
        // Recalculer le segment lorsque le préréglage d'overlap change
        if (waveformProvider && waveformProvider.getTotalDuration() > 0 && audioWaveform) {
            updateSegmentDisplay(audioWaveform.cursorPosition)
        }
    }
    
    // Signaux
    signal audioFileLoaded(bool success, real duration, int sampleRate)
    signal segmentSelected(double startPosition, double duration)
    signal requestGenerateSpectrogram()
    signal audioPlaybackStarted()
    signal audioPlaybackStopped()
    
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
                    binsPerSecond,
                    overlapPreset
                );
                
                // Mettre à jour les indicateurs visuels
                audioWaveform.segmentStart = segment.startPosition / waveformProvider.getTotalDuration();
                audioWaveform.segmentDuration = segment.duration / waveformProvider.getTotalDuration();
                
                // Configurer la source audio pour la lecture
                audioWaveform.setAudioSource(audioSourceUrl, durationSeconds);
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
                    // Arrêter la lecture si elle est en cours lors du déplacement du curseur
                    if (audioWaveform.isPlaying) {
                        audioWaveform.stopPlayback();
                    }
                    updateSegmentDisplay(position);
                }
            }
            
            onPlaybackStarted: {
                audioPlaybackStarted();
                statusText.showSuccess("Audio playback started");
            }
            
            onPlaybackStopped: {
                audioPlaybackStopped();
                statusText.text = "Position: " + getStartPosition().toFixed(2) + "s, Segment duration: " +
                                 (segmentDuration * waveformProvider.getTotalDuration()).toFixed(2) + "s";
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
                id: normalizeAudioButton
                text: isAudioNormalized ? "Disable Normalization" : "Normalize Audio"
                
                onClicked: {
                    if (!waveformProvider || waveformProvider.getTotalDuration() <= 0) {
                        statusText.showError("No audio file loaded")
                        return
                    }
                    normalizeAudio()
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
            
            // Nouveau bouton Play/Pause
            Button {
                id: playPauseButton
                text: audioWaveform && audioWaveform.isPlaying ? "Pause" : "Play"
                enabled: true // Rendre le bouton toujours actif pour diagnostiquer
                
                // Ajouter des logs pour diagnostiquer
                Component.onCompleted: {
                    console.log("playPauseButton initialized");
                    console.log("waveformProvider:", waveformProvider ? "exists" : "null");
                    if (waveformProvider) {
                        console.log("getTotalDuration:", waveformProvider.getTotalDuration());
                    }
                }
                
                // Mise à jour de l'état du bouton
                property bool updating: false
                
                // Fonction pour mettre à jour le texte sans boucle infinie
                function updateText() {
                    if (updating) return;
                    updating = true;
                    text = audioWaveform && audioWaveform.isPlaying ? "Pause" : "Play";
                    updating = false;
                }
                
                Connections {
                    target: audioWaveform
                    function onIsPlayingChanged() {
                        playPauseButton.updateText();
                    }
                }
                
                onClicked: {
                    console.log("Play/Pause button clicked");
                    console.log("waveformProvider:", waveformProvider ? "exists" : "null");
                    if (waveformProvider) {
                        console.log("getTotalDuration:", waveformProvider.getTotalDuration());
                    }
                    console.log("audioWaveform:", audioWaveform ? "exists" : "null");
                    console.log("audioSourceUrl:", audioSourceUrl);
                    
                    // Basculer la lecture même si les conditions ne sont pas remplies
                    if (audioWaveform) {
                        console.log("Calling togglePlayback()");
                        audioWaveform.togglePlayback();
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
        console.log("loadAudioFile called with:", filePath);
        
        if (waveformProvider) {
            // Stocker le chemin du fichier original
            originalAudioPath = filePath;
            audioFilePath = filePath;
            
            // Réinitialiser l'état de normalisation
            isAudioNormalized = false;
            normalizationFactor = 1.0;
            normalizedAudioPath = "";
            
            // Convertir le chemin de fichier en URL compatible avec QtMultimedia
            // Pour macOS, nous assurons que le chemin est correctement formaté
            // S'il contient déjà file://, ne pas le rajouter
            if (filePath.startsWith("file://")) {
                audioSourceUrl = filePath;
            } else {
                audioSourceUrl = "file://" + filePath;
            }
            
            console.log("Setting audioSourceUrl to:", audioSourceUrl);
            
            // Charger le fichier dans le fournisseur de données
            waveformProvider.loadFile(filePath);
            
            // Afficher un état explicite dans le statut
            statusText.showSuccess("Audio file loaded. Click Play to listen.");
            
            // Arrêter toute lecture en cours
            if (audioWaveform && audioWaveform.isPlaying) {
                audioWaveform.stopPlayback();
            }
            
            // Forcer une mise à jour directe de l'audioWaveform
            if (audioWaveform) {
                console.log("Updating audio source directly in AudioWaveform");
                console.log("  Total duration from provider:", waveformProvider.getTotalDuration());
                audioWaveform.setAudioSource(audioSourceUrl, waveformProvider.getTotalDuration());
            }
        } else {
            console.error("waveformProvider is null in loadAudioFile");
        }
    }
    
    function extractCurrentSegment() {
        if (!waveformProvider || waveformProvider.getTotalDuration() <= 0) {
            return null;
        }
        
        // Calculer le segment à extraire
        var segment = waveformProvider.calculateExtractionSegment(
            audioWaveform.cursorPosition,
            pageFormat,
            writingSpeed,
            binsPerSecond,
            overlapPreset
        );
        
        // Extraire le segment audio
        // Puisqu'on utilise déjà le fichier audio normalisé si la normalisation est activée,
        // nous n'avons plus besoin d'appliquer la normalisation ici
        var audioData = waveformProvider.extractSegment(
            segment.startPosition,
            segment.duration
        );
        
        // Retourner les données sans traitement supplémentaire
        return audioData;
    }
    
    function getAudioFileName() {
        if (!audioFilePath) return "";
        
        var audioFileName = audioFilePath;
        return audioFileName.split('/').pop(); // Extraire juste le nom du fichier
    }
    
    function getStartPosition() {
        if (!waveformProvider || waveformProvider.getTotalDuration() <= 0) {
            return 0;
        }
        
        var segment = waveformProvider.calculateExtractionSegment(
            audioWaveform.cursorPosition,
            pageFormat,
            writingSpeed,
            binsPerSecond,
            overlapPreset
        );
        
        return segment.startPosition;
    }
    
    // Fonction factorisée pour mettre à jour l'affichage du segment
    function updateSegmentDisplay(position) {
        if (!waveformProvider || waveformProvider.getTotalDuration() <= 0) {
            return;
        }
        
        var segment = waveformProvider.calculateExtractionSegment(
            position,
            pageFormat,
            writingSpeed,
            binsPerSecond,
            overlapPreset
        );
        // Mettre à jour les indicateurs visuels
        var relativeStart = segment.startPosition / waveformProvider.getTotalDuration();
        var relativeDuration = segment.duration / waveformProvider.getTotalDuration();
        
        console.log("Mise à jour du segment - Valeurs absolues:",
                    "startPosition =", segment.startPosition.toFixed(2),
                    "duration =", segment.duration.toFixed(2));
        console.log("Mise à jour du segment - Valeurs relatives:",
                    "segmentStart =", relativeStart.toFixed(4),
                    "segmentDuration =", relativeDuration.toFixed(4));
        
        audioWaveform.segmentStart = relativeStart;
        audioWaveform.segmentDuration = relativeDuration;
        
        
        // Mettre à jour le texte d'information
        var startSec = segment.startPosition.toFixed(2);
        var durationSec = segment.duration.toFixed(2);
        statusText.text = "Position: " + startSec + "s, Segment duration: " + durationSec + "s";
        
        // Émettre le signal avec les informations du segment
        segmentSelected(segment.startPosition, segment.duration);
        
        // Si une lecture audio est en cours, l'arrêter car le segment a changé
        if (audioWaveform && audioWaveform.isPlaying) {
            audioWaveform.stopPlayback();
        }
    }
    
    // Méthode pour démarrer ou arrêter la lecture audio du segment actuel
    function toggleAudioPlayback() {
        if (audioWaveform && waveformProvider && waveformProvider.getTotalDuration() > 0) {
            audioWaveform.togglePlayback();
        }
    }
    
    // Fonction pour normaliser l'audio et mettre à jour l'affichage
    function normalizeAudio() {
        console.log("Normalizing audio...");
        
        if (!waveformProvider || waveformProvider.getTotalDuration() <= 0 || !audioWaveform) {
            console.error("Cannot normalize: provider or audioWaveform not available");
            return;
        }
        
        // Si l'audio est déjà normalisé, désactiver la normalisation et revenir au fichier original
        if (isAudioNormalized) {
            console.log("Audio already normalized - toggling normalization off");
            isAudioNormalized = false;
            normalizationFactor = 1.0;
            
            // Recharger le fichier audio original
            console.log("Reverting to original audio file:", originalAudioPath);
            waveformProvider.loadFile(originalAudioPath);
            
            // Mettre à jour l'URL source pour la lecture
            if (originalAudioPath.startsWith("file://")) {
                audioSourceUrl = originalAudioPath;
            } else {
                audioSourceUrl = "file://" + originalAudioPath;
            }
            
            // Mettre à jour la source audio pour le composant AudioWaveform
            if (audioWaveform) {
                audioWaveform.setAudioSource(audioSourceUrl, waveformProvider.getTotalDuration());
            }
            
            statusText.showSuccess("Audio normalization disabled");
            return;
        }
        
        // Si nous n'avons pas encore calculé le facteur de normalisation, le faire maintenant
        if (normalizationFactor === 1.0) {
            console.log("Calculating normalization factor for:", originalAudioPath);
            normalizationFactor = generator.calculateNormalizationFactor(originalAudioPath);
            console.log("Calculated normalization factor:", normalizationFactor);
        }
        
        // Vérifier si nous avons déjà un fichier normalisé
        if (!normalizedAudioPath || normalizedAudioPath === "") {
            console.log("Creating normalized audio file with factor:", normalizationFactor);
            normalizedAudioPath = generator.normalizeAudioFile(originalAudioPath, normalizationFactor);
            
            if (!normalizedAudioPath || normalizedAudioPath === "") {
                statusText.showError("Failed to create normalized audio file");
                return;
            }
            
            console.log("Normalized audio file created at:", normalizedAudioPath);
        }
        
        // Charger le fichier audio normalisé
        console.log("Loading normalized audio file into provider");
        waveformProvider.loadFile(normalizedAudioPath);
        
        // Mettre à jour l'URL source pour la lecture
        if (normalizedAudioPath.startsWith("file://")) {
            audioSourceUrl = normalizedAudioPath;
        } else {
            audioSourceUrl = "file://" + normalizedAudioPath;
        }
        
        // Mettre à jour la source audio pour le composant AudioWaveform
        if (audioWaveform) {
            audioWaveform.setAudioSource(audioSourceUrl, waveformProvider.getTotalDuration());
        }
        
        // Activer l'état normalisé
        isAudioNormalized = true;
        
        // Afficher un message de confirmation
        statusText.showSuccess("Audio normalized (factor: " + normalizationFactor.toFixed(2) + ")");
    }
}
