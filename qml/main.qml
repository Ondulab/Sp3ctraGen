import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import com.spectrogen.backend 1.0
import "components"
import "sections"
import "styles" as AppStyles

/**
 * Fenêtre principale de l'application SpectroGen
 * Version modulaire avec architecture à composants
 */
ApplicationWindow {
    id: window
    title: "SpectroGen"
    width: 900
    height: 700
    visible: true
    color: "#222"
    
    // Propriétés responsives
    property bool isNarrow: width < AppStyles.Theme.narrowWidthThreshold
    property bool isSmall: width < AppStyles.Theme.smallWidthThreshold
    property bool showPreview: width >= AppStyles.Theme.previewWidthThreshold
    
    // Adapter l'affichage en fonction de la taille de la fenêtre
    onWidthChanged: {
        isNarrow = width < AppStyles.Theme.narrowWidthThreshold
        isSmall = width < AppStyles.Theme.smallWidthThreshold
        showPreview = width >= AppStyles.Theme.previewWidthThreshold
    }
    
    // Dimensions minimales
    minimumWidth: 800
    minimumHeight: 600
    
    // ===== Backend objects =====
    
    // Générateur de spectrogrammes
    SpectrogramGenerator {
        id: generator
        
        // Compteur pour forcer le rechargement de l'image
        property int previewCounter: 0
        
        onSpectrogramGenerated: {
            console.log("Signal spectrogramGenerated received: success=" + success + ", outputPath=" + outputPath + ", errorMessage=" + errorMessage);
            
            if (success) {
                previewSection.statusText.text = "Spectrogram successfully generated: " + outputPath;
                previewSection.statusText.color = AppStyles.Theme.successColor;
            } else {
                previewSection.statusText.text = "Error generating spectrogram: " + errorMessage;
                previewSection.statusText.color = AppStyles.Theme.errorColor;
            }
        }
        
        onPreviewGenerated: {
            console.log("Signal previewGenerated received: success=" + success + ", errorMessage=" + errorMessage);
            
            if (success) {
                // Incrémenter le compteur pour forcer un nouveau chargement
                previewCounter++;
                
                // Forcer le rechargement de l'image
                previewSection.previewImageLoader.active = false;
                
                // Utiliser un timer pour laisser le temps au loader de se désactiver
                previewResetTimer.start();
                
                previewSection.statusText.text = "Preview updated";
                previewSection.statusText.color = AppStyles.Theme.successColor;
            } else {
                previewSection.statusText.text = "Error generating preview: " + errorMessage;
                previewSection.statusText.color = AppStyles.Theme.errorColor;
            }
        }
        
        onSegmentPreviewGenerated: {
            console.log("Signal segmentPreviewGenerated received: success=" + success + ", errorMessage=" + errorMessage);
            
            if (success) {
                // Incrémenter le compteur pour forcer un nouveau chargement
                previewCounter++;
                
                // Forcer le rechargement de l'image
                previewSection.previewImageLoader.active = false;
                
                // Utiliser un timer pour laisser le temps au loader de se désactiver
                previewResetTimer.start();
                
                previewSection.statusText.text = "Segment preview updated";
                previewSection.statusText.color = AppStyles.Theme.successColor;
                audioWaveformSection.statusText.text = "Segment preview generated successfully";
                audioWaveformSection.statusText.color = AppStyles.Theme.successColor;
            } else {
                previewSection.statusText.text = "Error generating segment preview: " + errorMessage;
                previewSection.statusText.color = AppStyles.Theme.errorColor;
                audioWaveformSection.statusText.text = "Error generating segment preview: " + errorMessage;
                audioWaveformSection.statusText.color = AppStyles.Theme.errorColor;
            }
        }
        
        onPreviewSaved: {
            console.log("Signal previewSaved received: success=" + success + ", outputPath=" + outputPath + ", format=" + format + ", errorMessage=" + errorMessage);
            
            // Réinitialiser le bouton de sauvegarde
            previewSection.savePreviewButton.isProcessing = false;
            previewSection.savePreviewButton.text = "Save Preview";
            
            if (success) {
                previewSection.statusText.text = "Preview saved successfully as " + format.toUpperCase() + ": " + outputPath;
                previewSection.statusText.color = AppStyles.Theme.successColor;
            } else {
                previewSection.statusText.text = "Error saving preview in " + format.toUpperCase() + " format: " + errorMessage;
                previewSection.statusText.color = AppStyles.Theme.errorColor;
            }
        }
    }
    
    // Fournisseur de données de forme d'onde
    WaveformProvider {
        id: waveformProvider
        
        onFileLoaded: {
            console.log("Audio file loaded: success=" + success + ", duration=" + durationSeconds + "s, sampleRate=" + sampleRate);
            
            if (success) {
                // Get waveform data for display
                var waveformWidth = audioWaveformSection.audioWaveform.width;
                audioWaveformSection.audioWaveform.waveformData = waveformProvider.getWaveformData(waveformWidth);
                
                // Calculate initial segment
                var segment = waveformProvider.calculateExtractionSegment(
                    audioWaveformSection.audioWaveform.cursorPosition,
                    outputFormatSection.pageFormat,
                    spectrogramParametersSection.writingSpeed
                );
                
                // Update visual indicators
                audioWaveformSection.audioWaveform.segmentStart = segment.startPosition / waveformProvider.getTotalDuration();
                audioWaveformSection.audioWaveform.segmentDuration = segment.duration / waveformProvider.getTotalDuration();
                
                audioWaveformSection.statusText.text = "Audio file loaded: " + durationSeconds.toFixed(2) + " seconds at " + sampleRate + " Hz";
                audioWaveformSection.statusText.color = AppStyles.Theme.successColor;
            } else {
                audioWaveformSection.statusText.text = "Error loading audio file";
                audioWaveformSection.statusText.color = AppStyles.Theme.errorColor;
            }
        }
    }
    
    // Timer pour réactiver le loader après un court délai
    Timer {
        id: previewResetTimer
        interval: 50
        onTriggered: {
            previewSection.previewImageLoader.active = true;  // Réactiver le loader pour recréer l'image
        }
    }
    
    // ===== Dialogues =====
    FileDialog {
        id: inputFileDialog
        title: "Select WAV File"
        nameFilters: ["Audio files (*.wav)"]
        onAccepted: {
            var filePath = fileUrl.toString().replace("file://", "")
            console.log("Input file selected: " + filePath)
            audioWaveformSection.loadAudioFile(filePath)
        }
    }
    
    FileDialog {
        id: outputFolderDialog
        title: "Select Output Folder"
        selectFolder: true
        onAccepted: {
            var folderPath = fileUrl.toString().replace("file://", "")
            console.log("Output folder selected: " + folderPath)
            fileSettingsSection.setOutputFolder(folderPath)
        }
    }
    
    // ===== Layout principal =====
    RowLayout {
        anchors.fill: parent
        anchors.margins: AppStyles.Theme.margin
        spacing: AppStyles.Theme.spacing
        
        // ----- Partie gauche - Paramètres -----
        ScrollView {
            id: parametersScrollView
            Layout.fillHeight: true
            Layout.preferredWidth: showPreview ? parent.width * 0.5 : parent.width
            Layout.minimumWidth: 350
            contentWidth: parametersColumn.width
            
            ColumnLayout {
                id: parametersColumn
                width: parametersScrollView.width - 20  // Marge pour la scrollbar
                spacing: AppStyles.Theme.spacing
                
                // Espace en haut pour l'équilibre visuel
                Item {
                    Layout.preferredHeight: AppStyles.Theme.margin / 2
                }
                
                // Section 1: Paramètres du spectrogramme
                SpectrogramParameters {
                    id: spectrogramParametersSection
                    Layout.fillWidth: true
                    isSmall: window.isSmall
                    
                    onParametersChanged: {
                        // Mise à jour en temps réel de la prévisualisation si nécessaire
                        // Ou simplement stockage des valeurs pour la génération
                    }
                }
                
                // Séparateur
                Rectangle {
                    height: 1
                    color: AppStyles.Theme.separatorColor
                    Layout.fillWidth: true
                    Layout.topMargin: AppStyles.Theme.spacing
                    Layout.bottomMargin: AppStyles.Theme.spacing
                }
                
                // Section 2: Format de sortie
                OutputFormat {
                    id: outputFormatSection
                    Layout.fillWidth: true
                    isSmall: window.isSmall
                    
                    onFormatChanged: {
                        // Mise à jour des dépendances lorsque le format change
                        audioWaveformSection.pageFormat = pageFormat
                    }
                }
                
                // Séparateur
                Rectangle {
                    height: 1
                    color: AppStyles.Theme.separatorColor
                    Layout.fillWidth: true
                    Layout.topMargin: AppStyles.Theme.spacing
                    Layout.bottomMargin: AppStyles.Theme.spacing
                }
                
                // Section 3: Paramètres de fichiers
                FileSettings {
                    id: fileSettingsSection
                    Layout.fillWidth: true
                    outputFolderDialog: outputFolderDialog
                    
                    onRequestSelectOutputFolder: {
                        outputFolderDialog.open()
                    }
                }
                
                // Séparateur
                Rectangle {
                    height: 1
                    color: AppStyles.Theme.separatorColor
                    Layout.fillWidth: true
                    Layout.topMargin: AppStyles.Theme.spacing
                    Layout.bottomMargin: AppStyles.Theme.spacing
                }
                
                // Section 4: Forme d'onde audio
                AudioWaveformSection {
                    id: audioWaveformSection
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    
                    // Liaison des dépendances
                    waveformProvider: waveformProvider
                    generator: generator
                    inputFileDialog: inputFileDialog
                    
                    // Liaison bidirectionnelle des paramètres
                    pageFormat: outputFormatSection.pageFormat
                    writingSpeed: spectrogramParametersSection.writingSpeed
                    
                    onRequestGenerateSpectrogram: {
                        generateSpectrogramFromSegment()
                    }
                }
            }
        }
        
        // ----- Partie droite - Prévisualisation -----
        PreviewSection {
            id: previewSection
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: showPreview
            generator: generator
            
            onSaveRequested: function(format) {
                generator.saveCurrentPreview(fileSettingsSection.outputFolder, format)
            }
            
            onPrintRequested: {
                generator.printPreview()
            }
        }
    }
    
    // ===== Fonctions de coordination =====
    
    // Fonction pour générer le spectrogramme à partir du segment audio sélectionné
    function generateSpectrogramFromSegment() {
        if (!waveformProvider || waveformProvider.getTotalDuration() <= 0) {
            console.log("No audio file loaded")
            return
        }
        
        // Extraire le segment audio
        var audioSegment = audioWaveformSection.extractCurrentSegment()
        if (!audioSegment) {
            console.log("Failed to extract audio segment")
            return
        }
        
        // Obtenir le nom du fichier audio d'origine
        var originalFileName = audioWaveformSection.getAudioFileName()
        
        // Obtenir la position de départ
        var startPosition = audioWaveformSection.getStartPosition()
        
        // Générer le spectrogramme
        generator.generateSpectrogramFromSegment(
            parseInt(spectrogramParametersSection.fftSize),
            parseFloat(spectrogramParametersSection.overlap),
            parseFloat(spectrogramParametersSection.minFreq),
            parseFloat(spectrogramParametersSection.maxFreq),
            parseFloat(audioWaveformSection.segmentDuration * waveformProvider.getTotalDuration()),
            parseInt(waveformProvider.getSampleRate()),
            parseFloat(spectrogramParametersSection.dynamicRange),
            parseFloat(spectrogramParametersSection.gammaCorrection),
            spectrogramParametersSection.ditheringEnabled,
            parseFloat(spectrogramParametersSection.contrastFactor),
            spectrogramParametersSection.highBoostEnabled,
            parseFloat(spectrogramParametersSection.highBoostAlpha),
            spectrogramParametersSection.highPassEnabled,
            parseFloat(spectrogramParametersSection.highPassCutoff),
            parseInt(spectrogramParametersSection.highPassOrder) + 1, // +1 car highPassOrder est un index, pas la valeur
            outputFormatSection.pageFormat,
            parseFloat(outputFormatSection.bottomMargin),
            parseFloat(outputFormatSection.spectroHeight),
            parseFloat(spectrogramParametersSection.writingSpeed),
            outputFormatSection.verticalScaleEnabled,
            outputFormatSection.bottomReferenceLineEnabled,
            outputFormatSection.bottomReferenceLineEnabled ? parseFloat(outputFormatSection.bottomReferenceLineOffset) : 34.75,
            outputFormatSection.topReferenceLineEnabled,
            outputFormatSection.topReferenceLineEnabled ? parseFloat(outputFormatSection.topReferenceLineOffset) : 12.55,
            outputFormatSection.displayParametersEnabled,
            2.0, // textScaleFactor
            2.0, // lineThicknessFactor
            audioSegment,
            originalFileName,
            startPosition
        )
    }
}
