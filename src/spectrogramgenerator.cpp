#include "../include/spectrogramgenerator.h"
#include "../include/previewimageprovider.h"
#include "../include/FileManager.h"
#include "../include/VisualizationFactory.h"
#include "../include/TaskManager.h"
#include "../include/Constants.h"
#include <QDir>
#include <QFileInfo>
#include <QDebug>
#include <QTemporaryFile>
#include <QImageReader>
#include <QBuffer>
#include <sndfile.h>

// Initialisation de la variable statique
PreviewImageProvider* SpectrogramGenerator::s_previewProvider = nullptr;

SpectrogramGenerator::SpectrogramGenerator(QObject *parent)
    : QObject(parent)
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
}

void SpectrogramGenerator::generateSpectrogram(
    int fftSize,
    double overlap,
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
    const QString &inputFile,
    const QString &outputFolder,
    const QString &visualizationType,
    bool enableNormalization)
{
    // Créer les paramètres
    SpectrogramSettingsCpp settings = createSettings(
        fftSize, overlap, minFreq, maxFreq, duration, sampleRate,
        dynamicRangeDB, gammaCorrection, enableDithering, contrastFactor,
        enableHighBoost, highBoostAlpha, enableHighPassFilter,
        highPassCutoffFreq, highPassFilterOrder, pageFormat,
        bottomMarginMM, spectroHeightMM, writingSpeed,
        enableNormalization
    );
    
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
    
    // Exécuter la génération
    strategy->generate(settings, inputFile, outputFile);
}

void SpectrogramGenerator::generatePreview(
    int fftSize,
    double overlap,
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
    const QString &inputFile,
    bool enableVerticalScale,
    bool enableBottomReferenceLine,
    double bottomReferenceLineOffset,
    bool enableTopReferenceLine,
    double topReferenceLineOffset,
    bool displayParameters,
    double textScaleFactor,
    double lineThicknessFactor)
{
    // Vérifier que le fichier d'entrée existe si spécifié
    if (!inputFile.isEmpty() && !QFileInfo::exists(inputFile)) {
        emit previewGenerated(false, QImage(), "Le fichier d'entrée n'existe pas");
        return;
    }
    
    // Créer la structure de paramètres en utilisant la méthode createSettings
    SpectrogramSettingsCpp settingsCpp = createSettings(
        fftSize, overlap, minFreq, maxFreq, duration, sampleRate,
        dynamicRangeDB, gammaCorrection, enableDithering, contrastFactor,
        enableHighBoost, highBoostAlpha, enableHighPassFilter,
        highPassCutoffFreq, highPassFilterOrder, pageFormat,
        bottomMarginMM, spectroHeightMM, writingSpeed,
        true, // enableNormalization
        enableVerticalScale,
        enableBottomReferenceLine,
        bottomReferenceLineOffset,
        enableTopReferenceLine,
        topReferenceLineOffset,
        displayParameters,
        textScaleFactor,
        lineThicknessFactor
    );
    
    // Convertir en structure C
    SpectrogramSettings settings = settingsCpp.toCStruct();
    
    // Exécuter la génération de prévisualisation dans un thread séparé via TaskManager
    QUuid taskId = TaskManager::getInstance()->runTask(
        [this, settings, inputFile](TaskManager::ProgressCallback progressCallback) {
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
            int result = spectral_generator_with_metadata(&settings, inputFileCStr, tempFileCStr,
                                                         audioFileName.toUtf8().constData(), 0.0, settings.duration);
            
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
    int fftSize,
    double overlap,
    double minFreq,
    double maxFreq,
    double segmentDuration,
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
    bool enableVerticalScale,
    bool enableBottomReferenceLine,
    double bottomReferenceLineOffset,
    bool enableTopReferenceLine,
    double topReferenceLineOffset,
    bool displayParameters,
    double textScaleFactor,
    double lineThicknessFactor,
    const QByteArray &audioSegment,
    const QString &originalAudioFileName,
    double startTime)
{
    // Vérifier que le segment audio n'est pas vide
    if (audioSegment.isEmpty()) {
        emit segmentPreviewGenerated(false, QImage(), "Le segment audio est vide");
        return;
    }
    
    // Log des valeurs d'entrée
    qDebug() << "DEBUG - generateSpectrogramFromSegment - Valeurs d'entrée:";
    qDebug() << "DEBUG -   minFreq = " << minFreq;
    qDebug() << "DEBUG -   maxFreq = " << maxFreq;
    qDebug() << "DEBUG -   fftSize = " << fftSize;
    qDebug() << "DEBUG -   sampleRate = " << sampleRate;
    
    // Créer la structure de paramètres en utilisant la méthode createSettings
    SpectrogramSettingsCpp settingsCpp = createSettings(
        fftSize, overlap, minFreq, maxFreq, segmentDuration, sampleRate,
        dynamicRangeDB, gammaCorrection, enableDithering, contrastFactor,
        enableHighBoost, highBoostAlpha, enableHighPassFilter,
        highPassCutoffFreq, highPassFilterOrder, pageFormat,
        bottomMarginMM, spectroHeightMM, writingSpeed,
        true, // enableNormalization
        enableVerticalScale,
        enableBottomReferenceLine,
        bottomReferenceLineOffset,
        enableTopReferenceLine,
        topReferenceLineOffset,
        displayParameters,
        textScaleFactor,
        lineThicknessFactor
    );
    
    // Log après createSettings
    qDebug() << "DEBUG - Après createSettings:";
    qDebug() << "DEBUG -   settingsCpp.m_minFreq = " << settingsCpp.getMinFreq();
    qDebug() << "DEBUG -   settingsCpp.m_maxFreq = " << settingsCpp.getMaxFreq();
    
    // Convertir en structure C
    SpectrogramSettings settings = settingsCpp.toCStruct();
    
    // Log après conversion en structure C
    qDebug() << "DEBUG - Après conversion en structure C:";
    qDebug() << "DEBUG -   settings.minFreq = " << settings.minFreq;
    qDebug() << "DEBUG -   settings.maxFreq = " << settings.maxFreq;
    
    // Exécuter la génération de prévisualisation dans un thread séparé via TaskManager
    QUuid taskId = TaskManager::getInstance()->runTask(
        [this, settings, audioSegment, originalAudioFileName, startTime](TaskManager::ProgressCallback progressCallback) {
            this->runSegmentPreviewGeneration(settings, audioSegment, originalAudioFileName, startTime);
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

void SpectrogramGenerator::saveCurrentPreview(const QString &outputFolder, const QString &format)
{
    qDebug() << "SpectrogramGenerator::saveCurrentPreview - Sauvegarde de la prévisualisation actuelle dans le dossier:" << outputFolder;
    
    // Vérifier que le fournisseur d'images est disponible
    if (!s_previewProvider) {
        qWarning() << "Fournisseur d'images non disponible!";
        emit previewSaved(false, "", format, "Fournisseur d'images non disponible");
        return;
    }
    
    // Vérifier que le dossier de sortie existe
    if (!FileManager::validateOutputDirectory(outputFolder)) {
        qWarning() << "Le dossier de sortie n'existe pas:" << outputFolder;
        emit previewSaved(false, "", format, "Le dossier de sortie n'existe pas");
        return;
    }
    
    // Définir le chemin du fichier de sortie avec l'extension appropriée
    QString outputFile = FileManager::generateOutputFilename(
        outputFolder, "spectrogram_preview", format.toLower());
    
    qDebug() << "Sauvegarde de la prévisualisation dans:" << outputFile;
    
    // Sauvegarder l'image originale à haute résolution dans le format spécifié
    bool success = s_previewProvider->saveOriginalImage(outputFile, format);
    
    if (success) {
        qDebug() << "Prévisualisation sauvegardée avec succès dans:" << outputFile << "au format:" << format;
        emit previewSaved(true, outputFile, format);
    } else {
        qWarning() << "Échec de la sauvegarde de la prévisualisation dans:" << outputFile << "au format:" << format;
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

SpectrogramSettingsCpp SpectrogramGenerator::createSettings(
    int fftSize,
    double overlap,
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
    double lineThicknessFactor)
{
    // Log des paramètres d'entrée
    qDebug() << "DEBUG - createSettings - Paramètres d'entrée:";
    qDebug() << "DEBUG -   minFreq = " << minFreq;
    qDebug() << "DEBUG -   maxFreq = " << maxFreq;
    qDebug() << "DEBUG -   fftSize = " << fftSize;
    qDebug() << "DEBUG -   overlap = " << overlap;
    
    SpectrogramSettingsCpp settings;
    
    // Vérification de la structure avant initialisation
    qDebug() << "DEBUG - Avant initFromQmlParameters:";
    qDebug() << "DEBUG -   settings.m_minFreq = " << settings.getMinFreq();
    qDebug() << "DEBUG -   settings.m_maxFreq = " << settings.getMaxFreq();
    
    settings.initFromQmlParameters(
        fftSize, overlap, minFreq, maxFreq, duration, sampleRate,
        dynamicRangeDB, gammaCorrection, enableDithering, contrastFactor,
        enableHighBoost, highBoostAlpha, enableHighPassFilter,
        highPassCutoffFreq, highPassFilterOrder, pageFormat,
        bottomMarginMM, spectroHeightMM, writingSpeed,
        enableNormalization,
        enableVerticalScale,
        enableBottomReferenceLine,
        bottomReferenceLineOffset,
        enableTopReferenceLine,
        topReferenceLineOffset,
        displayParameters
    );
    
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
    qDebug() << "  - FFT size: " << settings.fftSize;
    qDebug() << "  - Sample rate: " << settings.sampleRate;
    qDebug() << "  - Duration: " << settings.duration;
    
    // Use original audio file name if provided, otherwise use temp file name
    QString audioFileName = !originalAudioFileName.isEmpty() ? 
                            originalAudioFileName : 
                            QFileInfo(audioTempFilePath).fileName();
    
    // Call the C function to generate the spectrogram in the temporary file
    // Pass the original audio filename, start time and segment duration for parameters display
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
