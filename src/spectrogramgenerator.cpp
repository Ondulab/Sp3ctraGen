#include "../include/spectrogramgenerator.h"
#include "../include/previewimageprovider.h"
#include "../include/FileManager.h"
#include "../include/VisualizationFactory.h"
#include "../include/TaskManager.h"
#include "../include/Constants.h"
#include "../src/spectral_wav_processing.h"
#include <QDir>
#include <QFileInfo>
#include <QDebug>
#include <QTemporaryFile>
#include <QImageReader>
#include <QBuffer>
#include <QDateTime>
#include <sndfile.h>

// Initialisation de la variable statique
PreviewImageProvider* SpectrogramGenerator::s_previewProvider = nullptr;

SpectrogramGenerator::SpectrogramGenerator(QObject *parent)
    : QObject(parent)
    , m_settings()
{
    // Connecter les signaux du TaskManager pour relayer les mises à jour de progression
    connect(TaskManager::getInstance(), &TaskManager::taskProgressUpdated,
            this, &SpectrogramGenerator::taskProgressUpdated);
}

void SpectrogramGenerator::setPreviewImageProvider(PreviewImageProvider *provider)
{
    s_previewProvider = provider;
}

SpectrogramGenerator::~SpectrogramGenerator()
{
    // Nettoyer les fichiers temporaires lors de la destruction
    cleanup();
}

void SpectrogramGenerator::generateSpectrogram(
    const SpectrogramSettingsCpp& settings,
    const QString &inputFile,
    const QString &outputFolder,
    const QString &visualizationType)
{
    // The settings object is now passed directly.
    // The createSettings method is primarily for internal use or when converting from individual QML params.
    // For direct calls like this, we assume 'settings' is already correctly populated.
    // We might still want to update m_settings if this generator instance is long-lived and m_settings is used elsewhere.
    // For now, let's assume the passed 'settings' is what we should use for this specific generation.
    // The settings object is now passed directly.
    // The VisualizationStrategy::generate method expects SpectrogramSettingsCpp.

    // Valider le fichier d'entrée
    if (!FileManager::validateInputFile(inputFile)) {
        emit spectrogramGenerated(false, "", "Le fichier d'entrée n'existe pas ou n'est pas lisible");
        return;
    }
    
    // Valider le dossier de sortie
    if (!FileManager::validateOutputDirectory(outputFolder)) {
        emit spectrogramGenerated(false, "", "Le dossier de sortie n'existe pas ou n'est pas accessible en écriture");
        return;
    }
    
    // Obtenir la stratégie de visualisation
    VisualizationStrategy* strategy = VisualizationFactory::getInstance()->getStrategy(visualizationType);
    if (!strategy) {
        // Essayer d'obtenir la stratégie par défaut (Raster)
        strategy = VisualizationFactory::getInstance()->getStrategy("Raster (PNG)");
        if (!strategy) {
            emit spectrogramGenerated(false, "", "Aucune stratégie de visualisation disponible");
            return;
        }
    }
    
    // Déterminer l'extension de fichier
    QString extension = strategy->getSupportedExtensions().first();
    
    // Générer le nom du fichier de sortie
    QString outputFile = FileManager::generateOutputFilename(
        outputFolder, "spectrogram", extension);
    
    // Connecter les signaux de la stratégie
    connect(strategy, &VisualizationStrategy::generationCompleted,
            this, &SpectrogramGenerator::spectrogramGenerated, Qt::UniqueConnection);
    
    // Exécuter la génération - En supposant que strategy->generate attend SpectrogramSettingsCpp&
    // Si ce n'est pas le cas, il faudra ajuster la signature de VisualizationStrategy::generate
    // ou convertir 'settings' en structure C ici si la stratégie l'attend.
    // Pour l'instant, on suppose que l'erreur indique que la stratégie attend SpectrogramSettingsCpp.
    strategy->generate(settings, inputFile, outputFile);
}

void SpectrogramGenerator::generatePreview(
    const SpectrogramSettingsCpp& settings,
    const QString &inputFile)
{
    // Vérifier que le fichier d'entrée existe si spécifié
    if (!inputFile.isEmpty() && !QFileInfo::exists(inputFile)) {
        emit previewGenerated(false, QImage(), "Le fichier d'entrée n'existe pas");
        return;
    }
    
    // The settings object is now passed directly.
    SpectrogramSettings cStructSettings = settings.toCStruct();
    
    // Exécuter la génération de prévisualisation dans un thread séparé via TaskManager
    QUuid taskId = TaskManager::getInstance()->runTask(
        [this, cStructSettings, inputFile](TaskManager::ProgressCallback progressCallback) { // Use cStructSettings
            // Créer un fichier temporaire pour la prévisualisation
            QTemporaryFile tempFile;
            tempFile.setAutoRemove(false); // Ne pas supprimer automatiquement pour pouvoir le charger
            
            progressCallback(10, "Création du fichier temporaire...");
            
            if (!tempFile.open()) {
                emit previewGenerated(false, QImage(), "Impossible de créer le fichier temporaire");
                return;
            }
            
            QString tempFilePath = tempFile.fileName();
            tempFile.close();
            
            progressCallback(20, "Génération du spectrogramme...");
            
            // Convertir les QString en const char* pour l'API C
            QByteArray inputFileBytes = inputFile.toLocal8Bit();
            QByteArray tempFileBytes = tempFilePath.toLocal8Bit();
            
            const char *inputFileCStr = inputFileBytes.constData();
            const char *tempFileCStr = tempFileBytes.constData();
            
            // Extract filename from path for parameters display
            QString audioFileName = inputFile.isEmpty() ? "Default" : QFileInfo(inputFile).fileName();
            
            // Call the C function to generate the spectrogram in the temporary file
            // Pass the audio filename, start time (0.0 for preview) and duration for parameters display
            int result = spectral_generator_with_metadata(&cStructSettings, inputFileCStr, tempFileCStr, // Use cStructSettings
                                                         audioFileName.toUtf8().constData(), 0.0, cStructSettings.duration); // Use cStructSettings
            
            progressCallback(80, "Traitement de l'image...");
            
            if (result == EXIT_SUCCESS) {
                // Charger l'image générée
                QImageReader reader(tempFilePath);
                QImage previewImage = reader.read();
                
                if (!previewImage.isNull()) {
                    // Stocker l'image et émettre le signal
                    m_previewImage = previewImage;
                    
                    // Mettre à jour l'image dans le fournisseur d'images si disponible
                    if (s_previewProvider) {
                        qDebug() << "Mise à jour de l'image dans le fournisseur d'images";
                        qDebug() << "Dimensions de l'image: " << previewImage.width() << "x" << previewImage.height();
                        qDebug() << "Format de l'image: " << previewImage.format();
                        s_previewProvider->updateImage(previewImage);
                        
                        // Vérifier l'état de l'image après la mise à jour
                        s_previewProvider->debugImageState();
                    } else {
                        qDebug() << "Fournisseur d'images non disponible!";
                    }
                    
                    progressCallback(100, "Prévisualisation générée avec succès");
                    emit previewGenerated(true, previewImage);
                } else {
                    emit previewGenerated(false, QImage(), "Erreur lors du chargement de l'image de prévisualisation");
                }
            } else {
                emit previewGenerated(false, QImage(), "Erreur lors de la génération de la prévisualisation");
            }
            
            // Supprimer le fichier temporaire
            QFile::remove(tempFilePath);
        },
        [this](bool success, const QString& message) {
            // Cette fonction est appelée lorsque la tâche est terminée
            if (!success) {
                emit previewGenerated(false, QImage(), message);
            }
        }
    );
    
    // Stocker l'ID de la tâche
    m_runningTasks[taskId] = "preview";
}

void SpectrogramGenerator::generateSpectrogramFromSegment(
    const SpectrogramSettingsCpp& settings,
    const QByteArray &audioSegment,
    const QString &originalAudioFileName,
    double startTime)
{
    // Vérifier que le segment audio n'est pas vide
    if (audioSegment.isEmpty()) {
        emit segmentPreviewGenerated(false, QImage(), "Le segment audio est vide");
        return;
    }
    
    // The settings object is now passed directly.
    // Log des valeurs d'entrée
    qDebug() << "DEBUG - generateSpectrogramFromSegment - Valeurs d'entrée (from settings object):";
    qDebug() << "DEBUG -   minFreq = " << settings.getMinFreq();
    qDebug() << "DEBUG -   maxFreq = " << settings.getMaxFreq();
    qDebug() << "DEBUG -   sampleRate = " << settings.getSampleRate();
    
    SpectrogramSettings cStructSettings = settings.toCStruct();
    
    // Log après conversion en structure C
    qDebug() << "DEBUG - Après conversion en structure C:";
    qDebug() << "DEBUG -   cStructSettings.minFreq = " << cStructSettings.minFreq;
    qDebug() << "DEBUG -   cStructSettings.maxFreq = " << cStructSettings.maxFreq;
    
    // Exécuter la génération de prévisualisation dans un thread séparé via TaskManager
    QUuid taskId = TaskManager::getInstance()->runTask(
        [this, cStructSettings, audioSegment, originalAudioFileName, startTime](TaskManager::ProgressCallback progressCallback) { // Use cStructSettings
            // Indiquer le début du traitement
            progressCallback(10, "Préparation du segment audio...");
            
            this->runSegmentPreviewGeneration(cStructSettings, audioSegment, originalAudioFileName, startTime); // Use cStructSettings
            
            // Indiquer la fin du traitement
            progressCallback(100, "Traitement du segment terminé");
        },
        [this](bool success, const QString& message) {
            // Cette fonction est appelée lorsque la tâche est terminée
            if (!success) {
                emit segmentPreviewGenerated(false, QImage(), message);
            }
        }
    );
    
    // Stocker l'ID de la tâche
    m_runningTasks[taskId] = "segment";
}

void SpectrogramGenerator::saveCurrentPreview(const QString &outputFilePath, const QString &format)
{
    qDebug() << "SpectrogramGenerator::saveCurrentPreview - Sauvegarde de la prévisualisation dans:" << outputFilePath;
    
    // Vérifier que le fournisseur d'images est disponible
    if (!s_previewProvider) {
        qWarning() << "Fournisseur d'images non disponible!";
        emit previewSaved(false, "", format, "Fournisseur d'images non disponible");
        return;
    }
    
    // Extraction du dossier du chemin complet
    QFileInfo fileInfo(outputFilePath);
    QString outputFolder = fileInfo.absolutePath();
    
    // Vérifier que le dossier de sortie existe
    if (!FileManager::validateOutputDirectory(outputFolder)) {
        qWarning() << "Le dossier de sortie n'existe pas:" << outputFolder;
        emit previewSaved(false, "", format, "Le dossier de sortie n'existe pas");
        return;
    }
    
    qDebug() << "Sauvegarde de la prévisualisation dans:" << outputFilePath;
    
    // Sauvegarder l'image originale à haute résolution dans le format spécifié
    bool success = s_previewProvider->saveOriginalImage(outputFilePath, format);
    
    if (success) {
        qDebug() << "Prévisualisation sauvegardée avec succès dans:" << outputFilePath << "au format:" << format;
        emit previewSaved(true, outputFilePath, format);
    } else {
        qWarning() << "Échec de la sauvegarde de la prévisualisation dans:" << outputFilePath << "au format:" << format;
        emit previewSaved(false, "", format, "Échec de la sauvegarde de l'image de prévisualisation");
    }
}

QStringList SpectrogramGenerator::getAvailableVisualizationTypes() const
{
    return VisualizationFactory::getInstance()->getAvailableStrategyNames();
}

QStringList SpectrogramGenerator::getSupportedFileExtensions() const
{
    return VisualizationFactory::getInstance()->getSupportedExtensions();
}

// Removed Q_INVOKABLE calculateBpsFromSlider
// Removed Q_INVOKABLE calculateOverlapFromSlider
// Removed Q_INVOKABLE isResolutionLimited
// Removed Q_INVOKABLE calculateAudioDuration
// Removed Q_INVOKABLE calculateMaxBps

void SpectrogramGenerator::updateInputParameters(const SpectrogramSettingsCpp& newSettings)
{
    qDebug() << "SpectrogramGenerator::updateInputParameters - Received new settings.";

    bool criticalChanged = false;
    if (m_settings.getResolutionSliderValue() != newSettings.getResolutionSliderValue()) criticalChanged = true;
    if (m_settings.getWritingSpeed() != newSettings.getWritingSpeed()) criticalChanged = true;
    if (m_settings.getSampleRate() != newSettings.getSampleRate()) criticalChanged = true;
    if (m_settings.getPageFormat() != newSettings.getPageFormat()) criticalChanged = true;
    if (m_settings.getPrinterDpi() != newSettings.getPrinterDpi()) criticalChanged = true;
    if (m_settings.getOverlapPreset() != newSettings.getOverlapPreset()) criticalChanged = true;
    // Add other parameters here if they become critical for performCalculationsAndNotify

    m_settings = newSettings; // Update the internal settings object

    if (criticalChanged) {
        qDebug() << "SpectrogramGenerator::updateInputParameters - Critical parameter changed, performing calculations.";
        performCalculationsAndNotify(); // Recalculate derived values and notify
    } else {
        qDebug() << "SpectrogramGenerator::updateInputParameters - No critical parameters changed, skipping full recalculation.";
        // Potentially, we could emit calculatedParametersUpdated with the current m_calculated... values
        // if QML needs to be re-notified even if values haven't changed, but this is usually not necessary.
        // Or, if some non-critical parameters affect a subset of derived values not handled by performCalculationsAndNotify,
        // that logic would go here. For now, assume non-critical changes don't require new derived values.
    }
}

double SpectrogramGenerator::updatePageFormat(
    int pageFormat,
    double bottomMarginMM,
    double spectroHeightMM,
    double writingSpeed,
    double minFreq,
    double maxFreq,
    int sampleRate,
    double printerDpi)
{
    qDebug() << "SpectrogramGenerator::updatePageFormat - Mise à jour du format de page:" << pageFormat;
    qDebug() << "SpectrogramGenerator::updatePageFormat - DPI reçu de l'interface:" << printerDpi;

    // Update relevant settings
    m_settings.setPageFormat(pageFormat);
    m_settings.setBottomMarginMM(bottomMarginMM);
    m_settings.setSpectroHeightMM(spectroHeightMM);
    m_settings.setWritingSpeed(writingSpeed);
    m_settings.setMinFreq(minFreq);
    m_settings.setMaxFreq(maxFreq);
    m_settings.setPrinterDpi(printerDpi);

    // If sample rate is provided, update it
    if (sampleRate > 0) {
        m_settings.setSampleRate(sampleRate);
    }

    // Perform calculations and notify QML
    performCalculationsAndNotify();

    // This method no longer needs to return audio duration,
    // as it's now part of the calculatedParametersUpdated signal.
    // Returning 0.0 as a placeholder, QML should use the signal.
    return 0.0;
}

void SpectrogramGenerator::performCalculationsAndNotify()
{
    qDebug() << "SpectrogramGenerator::performCalculationsAndNotify - Performing calculations";

    // Use the current settings to perform calculations
    double sliderValue = m_settings.getResolutionSliderValue();
    double writingSpeed = m_settings.getWritingSpeed();
    int sampleRate = m_settings.getSampleRate();
    // int pageFormat = m_settings.getPageFormat(); // Unused directly here, m_settings methods use it
    // double printerDpi = m_settings.getPrinterDpi(); // Unused directly here
    // double minFreq = m_settings.getMinFreq(); // Unused directly here
    // double maxFreq = m_settings.getMaxFreq(); // Unused directly here

    // 1. Calculate Bins/s
    // The calculateBpsFromSlider method within m_settings will use the writingSpeed from m_settings.
    // It also needs the sliderValue.
    m_calculatedBinsPerSecond = m_settings.calculateBpsFromSlider(sliderValue, writingSpeed);
    m_settings.setBinsPerSecond(m_calculatedBinsPerSecond); // Update settings with calculated Bps

    // 2. Calculate Overlap Preset and Effective Overlap
    // The getOverlapPresetFromSlider method within m_settings will use the sliderValue from m_settings.
    int overlapPreset = m_settings.getOverlapPresetFromSlider(sliderValue);
    m_settings.setOverlapPreset(overlapPreset); // Update settings with calculated preset

    // Calculate FFT Size based on the calculated Bins/s and Sample Rate
    // The calculateFftSize method within m_settings will use the sampleRate from m_settings.
    m_calculatedFftSize = m_settings.calculateFftSize(sampleRate);
    m_settings.setFftSize(m_calculatedFftSize); // Update settings with calculated FFT Size

    double hopSize = static_cast<double>(sampleRate) / m_calculatedBinsPerSecond;
    m_calculatedOverlap = 1.0 - (hopSize / m_calculatedFftSize);

    // 3. Calculate Audio Duration
    m_calculatedAudioDuration = m_settings.calculateAudioDuration();

    // 4. Check Resolution Limitation
    m_isResolutionLimited = m_settings.isResolutionLimited();

    qDebug() << "Calculations complete:";
    qDebug() << "  - Bins/s:" << m_calculatedBinsPerSecond;
    qDebug() << "  - FFT Size:" << m_calculatedFftSize;
    qDebug() << "  - Overlap:" << m_calculatedOverlap;
    qDebug() << "  - Audio Duration:" << m_calculatedAudioDuration;
    qDebug() << "  - Resolution Limited:" << m_isResolutionLimited;

    // Emit the signal with all calculated parameters
    emit calculatedParametersUpdated(
        m_calculatedBinsPerSecond,
        m_calculatedFftSize,
        m_calculatedOverlap,
        m_calculatedAudioDuration,
        m_isResolutionLimited
    );

    // The existing fftParametersCalculated signal is still emitted by createSettings,
    // which is called during generate* methods. We keep it for now.
    // emit fftParametersCalculated(m_calculatedFftSize, m_calculatedOverlap, m_calculatedBinsPerSecond);
}

SpectrogramSettingsCpp SpectrogramGenerator::createSettings(
    double minFreq,
    double maxFreq,
    double duration,
    int sampleRate,
    double dynamicRangeDB,
    double gammaCorrection,
    bool enableDithering,
    double contrastFactor,
    bool enableHighBoost,
    double highBoostAlpha,
    bool enableHighPassFilter,
    double highPassCutoffFreq,
    int highPassFilterOrder,
    int pageFormat,
    double bottomMarginMM,
    double spectroHeightMM,
    double writingSpeed,
    bool enableNormalization,
    bool enableVerticalScale,
    bool enableBottomReferenceLine,
    double bottomReferenceLineOffset,
    bool enableTopReferenceLine,
    double topReferenceLineOffset,
    bool displayParameters,
    double textScaleFactor,
    double lineThicknessFactor,
    double binsPerSecond,
    int overlapPreset,
    double printerDpi)
{
    // Log des paramètres d'entrée
    qDebug() << "DEBUG - createSettings - Paramètres d'entrée:";
    qDebug() << "DEBUG -   minFreq = " << minFreq;
    qDebug() << "DEBUG -   maxFreq = " << maxFreq;
    qDebug() << "DEBUG -   binsPerSecond = " << binsPerSecond;
    qDebug() << "DEBUG -   printerDpi (entrée) = " << printerDpi;
    qDebug() << "DEBUG -   m_settings.getPrinterDpi() = " << m_settings.getPrinterDpi();
    
    SpectrogramSettingsCpp settings;
    
    // Vérification de la structure avant initialisation
    qDebug() << "DEBUG - Avant initFromQmlParameters:";
    qDebug() << "DEBUG -   settings.m_minFreq = " << settings.getMinFreq();
    qDebug() << "DEBUG -   settings.m_maxFreq = " << settings.getMaxFreq();
    qDebug() << "DEBUG -   pageFormat = " << pageFormat;
    qDebug() << "DEBUG -   writingSpeed = " << writingSpeed;
    
    // Initialiser les paramètres depuis QML (IMPORTANT: avant l'affectation à m_settings)
    settings.initFromQmlParameters(
        minFreq,
        maxFreq,
        duration,
        sampleRate,
        dynamicRangeDB,
        gammaCorrection,
        enableDithering,
        contrastFactor,
        enableHighBoost,
        highBoostAlpha,
        enableHighPassFilter,
        highPassCutoffFreq,
        highPassFilterOrder,
        pageFormat,
        bottomMarginMM,
        spectroHeightMM,
        writingSpeed,
        enableNormalization,
        enableVerticalScale,
        enableBottomReferenceLine,
        bottomReferenceLineOffset,
        enableTopReferenceLine,
        topReferenceLineOffset,
        displayParameters,
        textScaleFactor,
        lineThicknessFactor,
        binsPerSecond,
        overlapPreset,
        printerDpi
    );
    
    // La taille FFT peut être fournie directement par le modèle de résolution adaptative
    int calculatedFftSize;
    if (settings.getFftSize() > 0) {
        // Utiliser la taille FFT précalculée si disponible
        calculatedFftSize = settings.getFftSize();
        qDebug() << " - Using provided FFT size:" << calculatedFftSize << "from resolution model";
    } else {
        // Sinon calculer la taille FFT à partir des paramètres courants
        calculatedFftSize = settings.calculateFftSize(sampleRate);
        qDebug() << " - Calculated FFT size:" << calculatedFftSize << "(from bins/s=" << binsPerSecond << ")";
    }
    
    // Calculer l'overlap effectif
    double hopSize = static_cast<double>(sampleRate) / binsPerSecond;
    double overlapValue = settings.getOverlapValueFromPreset();
    double effectiveOverlap = 1.0 - (hopSize / calculatedFftSize);
    qDebug() << " - Overlap preset: " << overlapPreset << " (value: " << overlapValue << ")";
    qDebug() << " - Resulting effective overlap:" << effectiveOverlap;
    
    // Stocker la valeur calculée pour qu'elle soit transmise au moteur de génération
    settings.setFftSize(calculatedFftSize);
    
    // IMPORTANT: Stocker les paramètres mis à jour dans l'instance m_settings pour pouvoir y accéder plus tard
    m_settings = settings;
    
    // Émettre le signal avec les paramètres calculés
    // emit fftParametersCalculated(calculatedFftSize, effectiveOverlap, binsPerSecond); // Signal to be removed
    
    // Vérification de la structure après initialisation
    qDebug() << "DEBUG - Après initFromQmlParameters:";
    qDebug() << "DEBUG -   settings.m_minFreq = " << settings.getMinFreq();
    qDebug() << "DEBUG -   settings.m_maxFreq = " << settings.getMaxFreq();
    
    return settings;
}

void SpectrogramGenerator::runSegmentPreviewGeneration(
    const SpectrogramSettings &settings,
    const QByteArray &audioSegment,
    const QString &originalAudioFileName,
    double startTime)
{
    // Log debug information
    qDebug() << "Generating segment preview";
    qDebug() << "Segment size:" << audioSegment.size() << "bytes";
    qDebug() << "Sample rate:" << settings.sampleRate;
    qDebug() << "Duration:" << settings.duration << "seconds";
    
    // Create a temporary WAV file with proper header
    QTemporaryFile audioTempFile(QDir::tempPath() + "/Sp3ctraGen_segment_XXXXXX.wav");
    audioTempFile.setAutoRemove(false); // Don't auto-remove to allow processing
    
    if (!audioTempFile.open()) {
        emit segmentPreviewGenerated(false, QImage(), "Impossible de créer le fichier temporaire pour les données audio");
        return;
    }
    
    QString audioTempFilePath = audioTempFile.fileName();
    qDebug() << "Temporary audio file path:" << audioTempFilePath;
    
    // We need to create a proper WAV file with header
    // Instead of writing raw data, we'll use libsndfile to create a valid WAV file
    
    // First close our QTemporaryFile
    audioTempFile.close();
    
    // Now use libsndfile to create a proper WAV file
    SF_INFO sfInfo;
    memset(&sfInfo, 0, sizeof(sfInfo));
    
    // Use the native sample rate of the audio file
    int nativeSampleRate = settings.sampleRate;
    
    qDebug() << "Using sample rate for WAV file:" << nativeSampleRate;
    sfInfo.samplerate = nativeSampleRate;
    sfInfo.channels = 1; // Mono for simplicity
    sfInfo.format = SF_FORMAT_WAV | SF_FORMAT_FLOAT;
    
    SNDFILE *outfile = sf_open(audioTempFilePath.toUtf8().constData(), SFM_WRITE, &sfInfo);
    if (!outfile) {
        qWarning() << "Failed to create WAV file:" << sf_strerror(nullptr);
        QFile::remove(audioTempFilePath);
        emit segmentPreviewGenerated(false, QImage(), "Failed to create WAV file: " + QString(sf_strerror(nullptr)));
        return;
    }
    
    // The audioSegment contains raw float samples, we need to convert it back to float array
    int numSamples = audioSegment.size() / sizeof(float);
    const float *samples = reinterpret_cast<const float*>(audioSegment.constData());
    
    // Write the samples to the file
    sf_count_t written = sf_writef_float(outfile, samples, numSamples / sfInfo.channels);
    sf_close(outfile);
    
    if (written != numSamples / sfInfo.channels) {
        qWarning() << "Failed to write all samples. Expected:" << numSamples / sfInfo.channels << "Written:" << written;
        QFile::remove(audioTempFilePath);
        emit segmentPreviewGenerated(false, QImage(), "Failed to write all audio samples");
        return;
    }
    
    // Create a temporary file for the preview image
    QTemporaryFile imageTempFile;
    imageTempFile.setAutoRemove(false);
    
    if (!imageTempFile.open()) {
        QFile::remove(audioTempFilePath);
        emit segmentPreviewGenerated(false, QImage(), "Unable to create temporary file for the image");
        return;
    }
    
    QString imageTempFilePath = imageTempFile.fileName();
    imageTempFile.close();
    
    // Convert QString to const char* for the C API
    QByteArray audioFileBytes = audioTempFilePath.toLocal8Bit();
    QByteArray imageFileBytes = imageTempFilePath.toLocal8Bit();
    
    const char *audioFileCStr = audioFileBytes.constData();
    const char *imageFileCStr = imageFileBytes.constData();
    
    // Add detailed logs before calling the C function
    qDebug() << "Calling spectral_generator with:";
    qDebug() << "  - Audio file: " << audioTempFilePath;
    qDebug() << "  - Image file: " << imageTempFilePath;
    qDebug() << "  - Sample rate: " << settings.sampleRate;
    qDebug() << "  - Duration: " << settings.duration;
    qDebug() << "  - Bins/s: " << settings.binsPerSecond;
    
    // Use original audio file name if provided, otherwise use temp file name
    QString audioFileName = !originalAudioFileName.isEmpty() ? 
                            originalAudioFileName : 
                            QFileInfo(audioTempFilePath).fileName();
    
    // Call the C function to generate the spectrogram in the temporary file
    // Pass the original audio filename, start time and segment duration for parameters display
    qDebug() << "Using DPI value: " << settings.printerDpi << " (from user interface)";
    int result = spectral_generator_with_metadata(&settings, audioFileCStr, imageFileCStr,
                                                 audioFileName.toUtf8().constData(), startTime, settings.duration);
    
    qDebug() << "spectral_generator returned: " << result << (result == EXIT_SUCCESS ? " (SUCCESS)" : " (FAILURE)");
    
    if (result == EXIT_SUCCESS) {
        qDebug() << "Loading generated image from: " << imageTempFilePath;
        // Charger l'image générée
        QImageReader reader(imageTempFilePath);
        QImage previewImage = reader.read();
        
        if (!previewImage.isNull()) {
            qDebug() << "Image loaded successfully: " << previewImage.width() << "x" << previewImage.height();
            // Stocker l'image et émettre le signal
            m_previewImage = previewImage;
            
            // Mettre à jour l'image dans le fournisseur d'images si disponible
            if (s_previewProvider) {
                qDebug() << "Updating image in preview provider";
                qDebug() << "Updating image in image provider (segment)";
                qDebug() << "Image dimensions: " << previewImage.width() << "x" << previewImage.height();
                qDebug() << "Image format: " << previewImage.format();
                s_previewProvider->updateImage(previewImage);
                
                // Vérifier l'état de l'image après la mise à jour
                s_previewProvider->debugImageState();
            } else {
                qDebug() << "Image provider not available!";
            }
            
            qDebug() << "Emitting segmentPreviewGenerated signal with success=true";
            emit segmentPreviewGenerated(true, previewImage);
        } else {
            qWarning() << "Failed to load image from: " << imageTempFilePath;
            emit segmentPreviewGenerated(false, QImage(), "Error loading segment preview image");
        }
    } else {
        qWarning() << "spectral_generator failed with code: " << result;
        emit segmentPreviewGenerated(false, QImage(), "Error generating segment preview (code: " + QString::number(result) + ")");
    }
    
    // Supprimer les fichiers temporaires
    QFile::remove(audioTempFilePath);
    QFile::remove(imageTempFilePath);
    
    qDebug() << "Segment preview generation completed with result:" << (result == EXIT_SUCCESS ? "SUCCESS" : "FAILURE");
}

bool SpectrogramGenerator::printPreview()
{
    qDebug() << "SpectrogramGenerator::printPreview - Impression de la prévisualisation actuelle";
    
    // Vérifier que le fournisseur d'images est disponible
    if (!s_previewProvider) {
        qWarning() << "Fournisseur d'images non disponible!";
        return false;
    }
    
    // Appeler la méthode d'impression du fournisseur d'images
    return s_previewProvider->printImage();
}

QString SpectrogramGenerator::normalizeAudioFile(const QString &inputPath, double factor)
{
    qDebug() << "SpectrogramGenerator::normalizeAudioFile - Normalizing audio file:" << inputPath << "with factor:" << factor;
    
    // Vérifier que le fichier d'entrée existe
    if (!QFileInfo::exists(inputPath)) {
        qWarning() << "Le fichier d'entrée n'existe pas:" << inputPath;
        return QString();
    }
    
    // Créer un nom de fichier temporaire unique dans le dossier temporaire du système
    QDir tempDir(QDir::tempPath());
    QFileInfo fileInfo(inputPath);
    QString baseName = fileInfo.baseName();
    QString extension = fileInfo.suffix();
    
    QString outputFileName = baseName + "_normalized_" +
                            QString::number(QDateTime::currentMSecsSinceEpoch()) + "." + extension;
    QString outputPath = tempDir.filePath(outputFileName);
    
    qDebug() << "Fichier temporaire normalisé:" << outputPath;
    
    // Appeler la fonction C pour normaliser le fichier audio
    int result = normalize_wav_file(
        inputPath.toUtf8().constData(),
        outputPath.toUtf8().constData(),
        factor
    );
    
    if (result != 0) {
        qWarning() << "Échec de la normalisation du fichier audio (code:" << result << ")";
        return QString();
    }
    
    // Enregistrer le fichier temporaire pour le nettoyage ultérieur
    m_tempFiles.append(outputPath);
    
    return outputPath;
}

double SpectrogramGenerator::calculateNormalizationFactor(const QString &audioPath)
{
    qDebug() << "SpectrogramGenerator::calculateNormalizationFactor - Analyzing audio file:" << audioPath;
    
    // Vérifier que le fichier d'entrée existe
    if (!QFileInfo::exists(audioPath)) {
        qWarning() << "Le fichier d'entrée n'existe pas:" << audioPath;
        return 1.0; // Valeur par défaut (pas de changement)
    }
    
    // Ouvrir le fichier audio avec libsndfile
    SF_INFO info;
    memset(&info, 0, sizeof(info));
    
    SNDFILE *sf = sf_open(audioPath.toUtf8().constData(), SFM_READ, &info);
    if (!sf) {
        qWarning() << "Impossible d'ouvrir le fichier audio:" << sf_strerror(NULL);
        return 1.0;
    }
    
    // Lire les échantillons et trouver la valeur maximale d'amplitude
    double max_amplitude = 0.0;
    const int BUFFER_SIZE = 4096;
    double buffer[BUFFER_SIZE];
    
    sf_count_t read_count;
    while ((read_count = sf_read_double(sf, buffer, BUFFER_SIZE)) > 0) {
        for (sf_count_t i = 0; i < read_count; i++) {
            double abs_value = fabs(buffer[i]);
            if (abs_value > max_amplitude) {
                max_amplitude = abs_value;
            }
        }
    }
    
    sf_close(sf);
    
    // Calculer le facteur de normalisation
    // Limiter le facteur à une valeur raisonnable pour éviter une amplification excessive
    // des fichiers avec de très faibles amplitudes
    double factor = 1.0;
    if (max_amplitude > 0.001) {
        factor = 0.95 / max_amplitude; // 95% du maximum pour éviter l'écrêtage
    } else {
        factor = 10.0; // Limite pour les fichiers avec amplitude très faible
    }
    
    qDebug() << "Amplitude maximale:" << max_amplitude << "- Facteur de normalisation calculé:" << factor;
    
    return factor;
}

void SpectrogramGenerator::cleanup()
{
    qDebug() << "SpectrogramGenerator::cleanup - Nettoyage de" << m_tempFiles.size() << "fichiers temporaires";
    
    // Supprimer tous les fichiers temporaires
    for (const QString &filePath : m_tempFiles) {
        QFile file(filePath);
        if (file.exists()) {
            qDebug() << "Suppression du fichier temporaire:" << filePath;
            if (!file.remove()) {
                qWarning() << "Impossible de supprimer le fichier temporaire:" << filePath
                          << "- Erreur:" << file.errorString();
            }
        }
    }
    
    // Vider la liste
    m_tempFiles.clear();
}

int SpectrogramGenerator::getPreviewImageWidth() const
{
    if (!s_previewProvider) {
        qWarning() << "Fournisseur d'images non disponible!";
        return 0;
    }
    return s_previewProvider->getImageWidth();
}

int SpectrogramGenerator::getPreviewImageHeight() const
{
    if (!s_previewProvider) {
        qWarning() << "Fournisseur d'images non disponible!";
        return 0;
    }
    return s_previewProvider->getImageHeight();
}

double SpectrogramGenerator::getPreviewImageDPI() const
{
    if (!s_previewProvider) {
        qWarning() << "Fournisseur d'images non disponible!";
        return m_settings.getPrinterDpi(); // Utiliser la valeur des paramètres
    }
    return s_previewProvider->getImageDPI();
}

double SpectrogramGenerator::getPreviewImageWidthCM() const
{
    if (!s_previewProvider) {
        qWarning() << "Fournisseur d'images non disponible!";
        return 0.0;
    }
    return s_previewProvider->getImageWidthCM();
}

double SpectrogramGenerator::getPreviewImageHeightCM() const
{
    if (!s_previewProvider) {
        qWarning() << "Fournisseur d'images non disponible!";
        return 0.0;
    }
    return s_previewProvider->getImageHeightCM();
}

#include "moc_spectrogramgenerator.cpp"
