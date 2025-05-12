import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import com.Sp3ctraGen.backend 1.0
import "components"
import "sections"
import "styles" as AppStyles
import "styles" as Fonts

/**
 * Fenêtre principale de l'application Sp3ctraGen
 * Version modulaire avec architecture à composants
 */
ApplicationWindow {
    id: window
    title: "Sp3ctraGen"
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
    
    // Utilitaires spécifiques à macOS
    MacOSBridge {
        id: macOSBridge
    }
    
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
                // Mise à jour de l'interface audio
                audioWaveformSection.statusText.text = "Preview generated successfully";
                audioWaveformSection.statusText.color = AppStyles.Theme.successColor;
                
                // Le reste de la gestion est délégué à PreviewSection
            } else {
                audioWaveformSection.statusText.text = "Error generating preview: " + errorMessage;
                audioWaveformSection.statusText.color = AppStyles.Theme.errorColor;
            }
        }
        
        onSegmentPreviewGenerated: {
            console.log("Signal segmentPreviewGenerated received: success=" + success + ", errorMessage=" + errorMessage);
            
            if (success) {
                // Mise à jour uniquement de l'interface audio
                audioWaveformSection.statusText.text = "Segment preview generated successfully";
                audioWaveformSection.statusText.color = AppStyles.Theme.successColor;
                
                // Le reste de la gestion est délégué à PreviewSection
            } else {
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
        // Le gestionnaire onFileLoaded a été supprimé pour éviter la duplication
        // avec le gestionnaire déjà présent dans AudioWaveformSection.qml
    }
    
    // Nota: Le timer pour réactiver le loader a été déplacé dans PreviewSection
    
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
    
    // Fonction d'ouverture sécurisée pour le dialogue d'entrée audio
    function safeOpenInputFileDialog() {
        // Préparer le dialogue natif macOS
        macOSBridge.prepareFileOpenDialog()
        // Ouvrir le dialogue
        inputFileDialog.open()
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
    
    // Fonction d'ouverture sécurisée pour le dialogue de dossier de sortie
    function safeOpenOutputFolderDialog() {
        // Préparer le dialogue natif macOS
        macOSBridge.prepareFolderSelectDialog()
        // Ouvrir le dialogue
        outputFolderDialog.open()
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
                    
                    // Modification pour utiliser notre fonction d'ouverture sécurisée
                    property var outputFolderDialog: null
                    
                    onRequestSelectOutputFolder: {
                        safeOpenOutputFolderDialog()
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
                    
                    // Modification pour utiliser notre fonction d'ouverture sécurisée
                    property var inputFileDialog: null
                    
                    // Remplacer la référence au dialogue par notre fonction personnalisée
                    function openInputFileDialog() {
                        safeOpenInputFileDialog()
                    }
                    
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
        // Récupération directe des valeurs numériques des composants ParameterField
        // Utilisation de la propriété numericValue pour éviter les conversions manuelles
        var fftSize = spectrogramParametersSection.fftSizeField.numericValue;
        var overlap = spectrogramParametersSection.overlapField.numericValue;
        var minFreq = spectrogramParametersSection.minFreqField.numericValue;
        var maxFreq = spectrogramParametersSection.maxFreqField.numericValue;
        var segmentDur = audioWaveformSection.segmentDuration * waveformProvider.getTotalDuration();
        var sampleRate = waveformProvider.getSampleRate();
        var dynamicRange = spectrogramParametersSection.dynamicRangeField.numericValue;
        var gammaCorrection = spectrogramParametersSection.gammaCorrectionField.numericValue;
        var contrastFactor = parseFloat(spectrogramParametersSection.contrastFactor);
        var highBoostAlpha = spectrogramParametersSection.highBoostAlphaField.numericValue;
        var highPassCutoff = spectrogramParametersSection.highPassCutoffField.numericValue;
        var highPassOrder = spectrogramParametersSection.highPassOrder + 1; // +1 car highPassOrder est un index, pas la valeur
        
        // Log des valeurs brutes extraites des composants QML
        console.log("[qml] DEBUG - Valeurs brutes extraites de l'interface:");
        console.log("[qml] DEBUG -   minFreq brut (getDisplayValue): '" + spectrogramParametersSection.minFreqField.getDisplayValue() + "'");
        console.log("[qml] DEBUG -   minFreq brut (value property): '" + spectrogramParametersSection.minFreq + "'");
        console.log("[qml] DEBUG -   minFreq après conversion: " + minFreq);
        console.log("[qml] DEBUG -   maxFreq brut (getDisplayValue): '" + spectrogramParametersSection.maxFreqField.getDisplayValue() + "'");
        console.log("[qml] DEBUG -   maxFreq après conversion: " + maxFreq);
        
        console.log("[qml] Paramètres spectrogram: FFT=" + fftSize + ", overlap=" + overlap +
                    ", minFreq=" + minFreq + ", maxFreq=" + maxFreq +
                    ", dynamicRange=" + dynamicRange + ", gamma=" + gammaCorrection);
                    
        generator.generateSpectrogramFromSegment(
            fftSize,
            overlap,
            minFreq,
            maxFreq,
            segmentDur,
            sampleRate,
            dynamicRange,
            gammaCorrection,
            spectrogramParametersSection.ditheringEnabled,
            contrastFactor,
            spectrogramParametersSection.highBoostEnabled,
            highBoostAlpha,
            spectrogramParametersSection.highPassEnabled,
            highPassCutoff,
            highPassOrder,
            outputFormatSection.pageFormat,
            parseFloat(outputFormatSection.bottomMargin),
            parseFloat(outputFormatSection.spectroHeight),
            spectrogramParametersSection.writingSpeedField.numericValue,
            outputFormatSection.verticalScaleEnabled,
            outputFormatSection.bottomReferenceLineEnabled,
            outputFormatSection.bottomReferenceLineEnabled ?
                parseFloat(outputFormatSection.bottomReferenceLineOffset) : 34.75,
            outputFormatSection.topReferenceLineEnabled,
            outputFormatSection.topReferenceLineEnabled ?
                parseFloat(outputFormatSection.topReferenceLineOffset) : 12.55,
            outputFormatSection.displayParametersEnabled,
            2.0, // textScaleFactor
            2.0, // lineThicknessFactor
            audioSegment,
            originalFileName,
            startPosition
        )
    }
}
