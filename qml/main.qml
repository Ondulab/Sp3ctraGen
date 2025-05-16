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

        // Connect the new signal for updated calculated parameters
        onCalculatedParametersUpdated: {
            console.log("Main.qml: Signal calculatedParametersUpdated received:",
                        "binsPerSecond=", binsPerSecond,
                        "calculatedFftSize=", calculatedFftSize,
                        "effectiveOverlap=", effectiveOverlap,
                        "audioDuration=", audioDuration,
                        "isResolutionLimited=", isResolutionLimited);

            // Update the SpectrogramParameters section with the new values
            if (spectrogramParametersSection && typeof spectrogramParametersSection.updateAllCalculatedParameters === "function") {
                try {
                    console.log("Main.qml: Mise à jour des paramètres dans spectrogramParametersSection");
                    spectrogramParametersSection.updateAllCalculatedParameters(
                        binsPerSecond,
                        calculatedFftSize,
                        effectiveOverlap,
                        audioDuration,
                        isResolutionLimited
                    );
                    console.log("Main.qml: Successfully updated all calculated parameters in UI");
                } catch (e) {
                    console.error("Main.qml: Error updating all calculated parameters:", e);
                    console.error("Main.qml: spectrogramParametersSection state:", spectrogramParametersSection ? "exists" : "null");
                }
            } else {
                console.warn("Main.qml: spectrogramParametersSection is not available or updateAllCalculatedParameters is not a function");
                console.warn("Main.qml: spectrogramParametersSection exists:", spectrogramParametersSection ? "yes" : "no");
                if (spectrogramParametersSection) {
                    console.warn("Main.qml: updateAllCalculatedParameters exists:", typeof spectrogramParametersSection.updateAllCalculatedParameters === "function" ? "yes" : "no");
                }
            }

            // Update audio waveform section with new audio duration
            if (audioWaveformSection) {
                 console.log("Main.qml: Mise à jour de audioDuration dans audioWaveformSection");
                 audioWaveformSection.audioDuration = audioDuration;
                 // Also update segment display if needed, based on cursor position
                 audioWaveformSection.updateSegmentDisplay(audioWaveformSection.cursorPosition);
            } else {
                 console.warn("Main.qml: audioWaveformSection is not available");
            }

            // Update preview section resolution text
            if (previewSection && previewSection.visible) {
                 console.log("Main.qml: Mise à jour du texte de résolution dans previewSection");
                 previewSection.updateResolutionText();
            } else {
                 console.warn("Main.qml: previewSection is not available or not visible");
            }
        }

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
                if (audioWaveformSection && audioWaveformSection.statusText) {
                    audioWaveformSection.statusText.text = "Preview generated successfully";
                    audioWaveformSection.statusText.color = AppStyles.Theme.successColor;
                }

                // Le reste de la gestion est délégué à PreviewSection

                // Mettre à jour le texte de résolution après un court délai pour s'assurer que l'image est chargée
                if (previewSection) {
                    Qt.callLater(function() {
                        previewSection.updateResolutionText();
                    });
                }
            } else {
                if (audioWaveformSection && audioWaveformSection.statusText) {
                    audioWaveformSection.statusText.text = "Error generating preview: " + errorMessage;
                    audioWaveformSection.statusText.color = AppStyles.Theme.errorColor;
                }
            }
        }

        onSegmentPreviewGenerated: {
            console.log("Signal segmentPreviewGenerated received: success=" + success + ", errorMessage=" + errorMessage);

            if (success) {
                // Mise à jour uniquement de l'interface audio
                if (audioWaveformSection && audioWaveformSection.statusText) {
                    audioWaveformSection.statusText.text = "Segment preview generated successfully";
                    audioWaveformSection.statusText.color = AppStyles.Theme.successColor;
                }

                // Le reste de la gestion est délégué à PreviewSection

                // Mettre à jour le texte de résolution après un court délai pour s'assurer que l'image est chargée
                if (previewSection) {
                    Qt.callLater(function() {
                        previewSection.updateResolutionText();
                    });
                }
            } else {
                if (audioWaveformSection && audioWaveformSection.statusText) {
                    audioWaveformSection.statusText.text = "Error generating segment preview: " + errorMessage;
                    audioWaveformSection.statusText.color = AppStyles.Theme.errorColor;
                }
            }
        }

        onPreviewSaved: {
            console.log("Signal previewSaved received: success=" + success + ", outputPath=" + outputPath + ", format=" + format + ", errorMessage=" + (errorMessage || ""));

            // Réinitialiser le bouton de sauvegarde en s'assurant que le composant existe
            // Il est important de vérifier que l'objet et sa propriété existent avant de les modifier
            try {
                if (previewSection && previewSection.savePreviewButton) {
                    previewSection.savePreviewButton.isProcessing = false;
                    previewSection.savePreviewButton.text = "Save Preview";
                }
            } catch (e) {
                console.error("Error resetting save button state:", e);
            }

            if (success) {
                if (previewSection && previewSection.statusText) {
                    previewSection.statusText.text = "Preview saved successfully as " + format.toUpperCase() + ": " + outputPath;
                    previewSection.statusText.color = AppStyles.Theme.successColor;
                }
            } else {
                if (previewSection && previewSection.statusText) {
                    previewSection.statusText.text = "Error saving preview in " + format.toUpperCase() + " format: " + (errorMessage || "");
                    previewSection.statusText.color = AppStyles.Theme.errorColor;
                }
            }

            // Force une mise à jour de l'interface pour s'assurer que le bouton est réactivé
            if (previewSection) {
                previewSection.forceActiveFocus();
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

    // Le dialogue de sélection de dossier de sortie a été retiré.
    // Il est remplacé par le dialogue de sauvegarde qui s'ouvre directement
    // lorsque l'utilisateur clique sur "Save Preview"

    // Dialogue de sauvegarde pour les prévisualisations
    FileDialog {
        id: savePreviewDialog
        title: "Enregistrer la prévisualisation"
        selectExisting: false

        // Ces propriétés seront définies dynamiquement lors de l'ouverture du dialogue
        property string selectedFormat: "png"
        property string initialFileName: "spectrogram.png"

        // Fonction pour mettre à jour les filtres selon le format
        function updateFilters(format) {
            selectedFormat = format.toLowerCase()
            if (selectedFormat === "png") {
                nameFilters = ["Images PNG (*.png)"]
                defaultSuffix = "png"
            } else if (selectedFormat === "pdf") {
                nameFilters = ["Documents PDF (*.pdf)"]
                defaultSuffix = "pdf"
            } else if (selectedFormat === "jpeg") {
                nameFilters = ["Images JPEG (*.jpg *.jpeg)"]
                defaultSuffix = "jpg"
            }
        }

        // Fonction pour générer un nom de fichier basé sur les paramètres audio
        function generateFileName() {
            var audioFileName = audioWaveformSection.getAudioFileName()
            if (!audioFileName) {
                audioFileName = "spectrogram"
            } else {
                // Supprimer l'extension du fichier audio
                var lastDotIndex = audioFileName.lastIndexOf('.')
                if (lastDotIndex > 0) {
                    audioFileName = audioFileName.substring(0, lastDotIndex)
                }
            }

            // Récupérer le timecode et la durée du segment
            var startPosition = audioWaveformSection.getStartPosition()
            var segmentDuration = audioWaveformSection.segmentDuration * waveformProvider.getTotalDuration()

            // Formater les nombres pour le nom de fichier
            var startTimeFormatted = startPosition.toFixed(1).replace('.', 'm')
            var durationFormatted = segmentDuration.toFixed(1).replace('.', 'm')

            // Construire le nom de fichier
            return audioFileName + "_t" + startTimeFormatted + "s_d" + durationFormatted + "s." + selectedFormat
        }

        onAccepted: {
            var filePath = fileUrl.toString().replace("file://", "")
            console.log("Save location selected: " + filePath)
            generator.saveCurrentPreview(filePath, selectedFormat)
        }
    }

    // Fonction d'ouverture sécurisée pour le dialogue de sauvegarde
    function safeOpenSavePreviewDialog(format) {
        // Réinitialiser l'état du bouton pour permettre de multiples sauvegardes
        if (previewSection && previewSection.savePreviewButton) {
            previewSection.savePreviewButton.isProcessing = false
            previewSection.savePreviewButton.text = "Save Preview"
        }

        // Mettre à jour les filtres selon le format
        savePreviewDialog.updateFilters(format)

        // Générer le nom de fichier initial basé sur les données audio
        var suggestedName = savePreviewDialog.generateFileName()

        // Définir le dossier par défaut (Downloads)
        savePreviewDialog.folder = "file://" + macOSBridge.getDownloadsPath()

        // Afficher le nom suggéré dans le titre pour guider l'utilisateur
        savePreviewDialog.title = "Enregistrer sous: " + suggestedName

        console.log("Dialogue de sauvegarde avec nom prérempli: " + suggestedName)

        // Configuration du dialogue natif macOS avec le nom préconfiguré
        macOSBridge.prepareSaveDialogWithName(suggestedName)

        // Ouvrir le dialogue
        savePreviewDialog.open()
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
            Layout.preferredWidth: showPreview ? 350 : parent.width
            Layout.maximumWidth: showPreview ? 350 : parent.width
            contentWidth: parametersColumn.width

            ColumnLayout {
                id: parametersColumn
                width: parametersScrollView.width - 20  // Marge pour la scrollbar
                spacing: AppStyles.Theme.spacing

                // L'espace en haut a été supprimé pour aligner les bords supérieurs

                // Section 1: Paramètres du spectrogramme
                SpectrogramParameters {
                    id: spectrogramParametersSection
                    Layout.fillWidth: true
                    isSmall: window.isSmall
                    generator: generator // Passer l'objet generator au composant

                    onParametersChanged: {
                        // Mise à jour en temps réel de la prévisualisation si nécessaire
                        // Ou simplement stockage des valeurs pour la génération
                    }

                    onFormatChanged: {
                        // Ce signal est émis lorsque le format de page ou le DPI change
                        console.log("Format de page changé:", spectrogramParametersSection.pageFormat);
                        
                        if (generator && generator.parameters) {
                            // Utiliser le modèle de paramètres directement
                            generator.parameters.beginUpdate();
                            generator.parameters.pageFormat = spectrogramParametersSection.pageFormat;
                            generator.parameters.printerDpi = spectrogramParametersSection.printerDpiNumeric;
                            generator.parameters.endUpdate();
                            
                            // Note: Les valeurs calculées (audioDuration, etc.) seront mises à jour
                            // par le signal calculatedParametersUpdated
                        } else {
                            console.error("Generator ou parameters non disponible");
                        }
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

                // Section 2: Paramètres de traitement du signal
                FilterParameters {
                    id: filterParametersSection
                    Layout.fillWidth: true
                    isSmall: window.isSmall
                    generator: generator // Passer l'objet generator au composant

                    onParametersChanged: {
                        // Mise à jour lorsque les paramètres de filtrage changent
                        // Mettre à jour la prévisualisation si nécessaire
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

                // Section 3: Options de mise en page d'impression
                PrintLayoutOptions {
                    id: printLayoutOptions
                    Layout.fillWidth: true
                    isSmall: window.isSmall

                    onLayoutChanged: {
                        // Mise à jour simple des paramètres visuels qui n'affectent pas les calculs
                        // Les mises à jour importantes sont maintenant gérées par SpectrogramParameters
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

                // La section AudioWaveformSection a été déplacée vers la partie droite
            }
        }

        // ----- Partie droite - Audio + Prévisualisation -----
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: showPreview
            spacing: AppStyles.Theme.spacing
            Layout.topMargin: 0

            // Section Audio (25% de la hauteur)
            AudioWaveformSection {
                id: audioWaveformSection
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.20

                // Liaison des dépendances
                waveformProvider: waveformProvider
                generator: generator

                // Modification pour utiliser notre fonction d'ouverture sécurisée
                property var inputFileDialog: null

                // Remplacer la référence au dialogue par notre fonction personnalisée
                function openInputFileDialog() {
                    safeOpenInputFileDialog()
                }

                // Liaison bidirectionnelle des paramètres - maintenant depuis SpectrogramParameters
                pageFormat: spectrogramParametersSection.pageFormat
                // Utiliser la valeur numérique au lieu de la chaîne de caractères
                writingSpeed: spectrogramParametersSection.writingSpeedNumeric
                // Valeur du curseur de résolution
                resolutionValue: spectrogramParametersSection.resolutionSliderValue

                onRequestGenerateSpectrogram: {
                    generateSpectrogramFromSegment()
                }
            }

            // Section Prévisualisation (75% de la hauteur restante)
            PreviewSection {
                id: previewSection
                Layout.fillHeight: true
                Layout.fillWidth: true
                generator: generator

                onSaveRequested: function(format) {
                    safeOpenSavePreviewDialog(format)
                }

                onPrintRequested: {
                    generator.printPreview()
                }
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
        var minFreq = spectrogramParametersSection.minFreqField.numericValue;
        var maxFreq = spectrogramParametersSection.maxFreqField.numericValue;
        var segmentDur = audioWaveformSection.segmentDuration * waveformProvider.getTotalDuration();
        var sampleRate = waveformProvider.getSampleRate();
        var dynamicRange = filterParametersSection.dynamicRangeNumeric;
        var gammaCorrection = filterParametersSection.gammaCorrectionNumeric;
        var contrastFactor = parseFloat(filterParametersSection.contrastFactor);
        var highBoostAlpha = filterParametersSection.highBoostAlpha;
        // Utiliser directement la valeur numérique depuis le composant
        var highPassCutoff = filterParametersSection.highPassCutoffNumeric;
        console.log("[qml] DEBUG - High-pass filter cutoff (string): '" + filterParametersSection.highPassCutoff + "'");
        console.log("[qml] DEBUG - High-pass filter cutoff (numericValue): " + highPassCutoff);
        var highPassOrder = filterParametersSection.highPassOrder + 1; // +1 car highPassOrder est un index, pas la valeur

        // Log des valeurs brutes extraites des composants QML
        console.log("[qml] DEBUG - Valeurs brutes extraites de l'interface:");
        console.log("[qml] DEBUG -   minFreq brut (getDisplayValue): '" + spectrogramParametersSection.minFreqField.getDisplayValue() + "'");
        console.log("[qml] DEBUG -   minFreq brut (value property): '" + spectrogramParametersSection.minFreq + "'");
        console.log("[qml] DEBUG -   minFreq après conversion: " + minFreq);
        console.log("[qml] DEBUG -   maxFreq brut (getDisplayValue): '" + spectrogramParametersSection.maxFreqField.getDisplayValue() + "'");
        console.log("[qml] DEBUG -   maxFreq après conversion: " + maxFreq);
        console.log("[qml] DEBUG -   resolution value: '" + spectrogramParametersSection.resolutionSliderValue + "'");

        // Log détaillé de tous les paramètres essentiels pour le débogage
        console.log("[qml] DEBUG PARAMETERS - FINAL VALUES:");
        console.log("[qml] - resolution slider = " + spectrogramParametersSection.resolutionSliderValue);
        console.log("[qml] - minFreq = " + minFreq + ", maxFreq = " + maxFreq);
        console.log("[qml] - sampleRate = " + sampleRate + ", segmentDuration = " + segmentDur);
        console.log("[qml] - binsPerSecond = " + spectrogramParametersSection.binsPerSecondValue);
        console.log("[qml] - overlapPreset = " + Math.round(spectrogramParametersSection.resolutionSliderValue * 2));
        console.log("[qml] - highPassEnabled = " + filterParametersSection.highPassEnabled);
        console.log("[qml] - highPassCutoff = " + highPassCutoff);
        console.log("[qml] - highPassOrder = " + highPassOrder);

        // Mettre à jour les paramètres directement
        if (generator && generator.parameters) {
            generator.parameters.beginUpdate();
            // Paramètres de base
            generator.parameters.minFreq = minFreq;
            generator.parameters.maxFreq = maxFreq;
            generator.parameters.duration = segmentDur;
            generator.parameters.sampleRate = sampleRate;
            generator.parameters.dynamicRangeDB = dynamicRange;
            generator.parameters.gammaCorrection = gammaCorrection;
            generator.parameters.enableDithering = filterParametersSection.ditheringEnabled;
            generator.parameters.contrastFactor = contrastFactor;
            
            // Paramètres de filtre
            generator.parameters.enableHighBoost = filterParametersSection.highBoostEnabled;
            generator.parameters.highBoostAlpha = highBoostAlpha;
            generator.parameters.enableHighPassFilter = filterParametersSection.highPassEnabled;
            generator.parameters.highPassCutoffFreq = filterParametersSection.highPassCutoffNumeric;
            generator.parameters.highPassFilterOrder = highPassOrder;
            generator.parameters.enableNormalization = true;
            
            // Paramètres de format de sortie
            generator.parameters.pageFormat = spectrogramParametersSection.pageFormat;
            generator.parameters.bottomMarginMM = parseFloat(printLayoutOptions.bottomMargin);
            generator.parameters.spectroHeightMM = parseFloat(printLayoutOptions.spectroHeight);
            generator.parameters.enableVerticalScale = printLayoutOptions.verticalScaleEnabled;
            generator.parameters.enableBottomReferenceLine = printLayoutOptions.bottomReferenceLineEnabled;
            generator.parameters.bottomReferenceLineOffset = printLayoutOptions.bottomReferenceLineEnabled ? 
                parseFloat(printLayoutOptions.bottomReferenceLineOffset) : -34.75;
            generator.parameters.enableTopReferenceLine = printLayoutOptions.topReferenceLineEnabled;
            generator.parameters.topReferenceLineOffset = printLayoutOptions.topReferenceLineEnabled ? 
                parseFloat(printLayoutOptions.topReferenceLineOffset) : 12.55;
            generator.parameters.displayParameters = printLayoutOptions.displayParametersEnabled;
            generator.parameters.textScaleFactor = 2.0;
            generator.parameters.lineThicknessFactor = 2.0;
            
            // Paramètres du moteur de génération
            generator.parameters.writingSpeed = spectrogramParametersSection.writingSpeedNumeric;
            generator.parameters.binsPerSecond = spectrogramParametersSection.binsPerSecondValue;
            generator.parameters.overlapPreset = Math.round(spectrogramParametersSection.resolutionSliderValue * 2);
            generator.parameters.printerDpi = spectrogramParametersSection.printerDpiNumeric;
            generator.parameters.resolutionSliderValue = spectrogramParametersSection.resolutionSliderValue;
            
            generator.parameters.endUpdate();
            
            // Appeler generateSpectrogramFromSegment avec les paramètres mis à jour
            generator.generateSpectrogramFromSegment(
                generator.parameters,
                audioSegment,
                originalFileName,
                startPosition
            );
        } else {
            console.error("generator ou generator.parameters n'est pas disponible");
        }

        // Log pour débogage DPI
        console.log("DPI transmis au generateur depuis main.qml: " + spectrogramParametersSection.printerDpiNumeric);
    }
}
