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
    const QString &visualizationType)
{
    // Créer les paramètres
    SpectrogramSettingsCpp settings = createSettings(
        fftSize, overlap, minFreq, maxFreq, duration, sampleRate,
        dynamicRangeDB, gammaCorrection, enableDithering, contrastFactor,
        enableHighBoost, highBoostAlpha, enableHighPassFilter,
        highPassCutoffFreq, highPassFilterOrder, pageFormat,
        bottomMarginMM, spectroHeightMM, writingSpeed
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
    const QString &inputFile)
{
    // Vérifier que le fichier d'entrée existe si spécifié
    if (!inputFile.isEmpty() && !QFileInfo::exists(inputFile)) {
        emit previewGenerated(false, QImage(), "Le fichier d'entrée n'existe pas");
        return;
    }
    
    // Créer la structure de paramètres
    SpectrogramSettings settings;
    settings.fftSize = fftSize;
    settings.overlap = overlap;
    settings.minFreq = minFreq;
    settings.maxFreq = maxFreq;
    settings.duration = duration;
    settings.sampleRate = sampleRate;
    settings.dynamicRangeDB = dynamicRangeDB;
    settings.gammaCorrection = gammaCorrection;
    settings.enableDithering = enableDithering ? 1 : 0;
    settings.contrastFactor = contrastFactor;
    settings.enableHighBoost = enableHighBoost ? 1 : 0;
    settings.highBoostAlpha = highBoostAlpha;
    settings.enableHighPassFilter = enableHighPassFilter ? 1 : 0;
    settings.highPassCutoffFreq = highPassCutoffFreq;
    settings.highPassFilterOrder = highPassFilterOrder;
    settings.pageFormat = pageFormat;
    settings.bottomMarginMM = bottomMarginMM;
    settings.spectroHeightMM = spectroHeightMM;
    settings.writingSpeed = writingSpeed;
    
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
            
            // Appeler la fonction C pour générer le spectrogramme dans le fichier temporaire
            int result = spectral_generator(&settings, inputFileCStr, tempFileCStr);
            
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
    const QByteArray &audioSegment)
{
    // Vérifier que le segment audio n'est pas vide
    if (audioSegment.isEmpty()) {
        emit segmentPreviewGenerated(false, QImage(), "Le segment audio est vide");
        return;
    }
    
    // Créer la structure de paramètres
    SpectrogramSettings settings;
    settings.fftSize = fftSize;
    settings.overlap = overlap;
    settings.minFreq = minFreq;
    settings.maxFreq = maxFreq;
    settings.duration = segmentDuration;
    
    // Utiliser la fréquence d'échantillonnage native du fichier audio
    // Le paramètre sampleRate est ignoré car nous utilisons toujours la fréquence native
    // qui sera détectée lors de la lecture du fichier WAV temporaire
    settings.sampleRate = sampleRate > 0 ? sampleRate : 44100; // Valeur par défaut raisonnable
    settings.dynamicRangeDB = dynamicRangeDB;
    settings.gammaCorrection = gammaCorrection;
    settings.enableDithering = enableDithering ? 1 : 0;
    settings.contrastFactor = contrastFactor;
    settings.enableHighBoost = enableHighBoost ? 1 : 0;
    settings.highBoostAlpha = highBoostAlpha;
    settings.enableHighPassFilter = enableHighPassFilter ? 1 : 0;
    settings.highPassCutoffFreq = highPassCutoffFreq;
    settings.highPassFilterOrder = highPassFilterOrder;
    settings.pageFormat = pageFormat;
    settings.bottomMarginMM = bottomMarginMM;
    settings.spectroHeightMM = spectroHeightMM;
    settings.writingSpeed = writingSpeed;
    
    // Exécuter la génération de prévisualisation dans un thread séparé via TaskManager
    QUuid taskId = TaskManager::getInstance()->runTask(
        [this, settings, audioSegment](TaskManager::ProgressCallback progressCallback) {
            this->runSegmentPreviewGeneration(settings, audioSegment);
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
    double writingSpeed)
{
    SpectrogramSettingsCpp settings;
    settings.initFromQmlParameters(
        fftSize, overlap, minFreq, maxFreq, duration, sampleRate,
        dynamicRangeDB, gammaCorrection, enableDithering, contrastFactor,
        enableHighBoost, highBoostAlpha, enableHighPassFilter,
        highPassCutoffFreq, highPassFilterOrder, pageFormat,
        bottomMarginMM, spectroHeightMM, writingSpeed
    );
    return settings;
}

void SpectrogramGenerator::runSegmentPreviewGeneration(
    const SpectrogramSettings &settings,
    const QByteArray &audioSegment)
{
    // Log debug information
    qDebug() << "Génération de la prévisualisation du segment";
    qDebug() << "Taille du segment:" << audioSegment.size() << "octets";
    qDebug() << "Taux d'échantillonnage:" << settings.sampleRate;
    qDebug() << "Durée:" << settings.duration << "secondes";
    
    // Create a temporary WAV file with proper header
    QTemporaryFile audioTempFile(QDir::tempPath() + "/spectrogen_segment_XXXXXX.wav");
    audioTempFile.setAutoRemove(false); // Don't auto-remove to allow processing
    
    if (!audioTempFile.open()) {
        emit segmentPreviewGenerated(false, QImage(), "Impossible de créer le fichier temporaire pour les données audio");
        return;
    }
    
    QString audioTempFilePath = audioTempFile.fileName();
    qDebug() << "Chemin du fichier audio temporaire:" << audioTempFilePath;
    
    // We need to create a proper WAV file with header
    // Instead of writing raw data, we'll use libsndfile to create a valid WAV file
    
    // First close our QTemporaryFile
    audioTempFile.close();
    
    // Now use libsndfile to create a proper WAV file
    SF_INFO sfInfo;
    memset(&sfInfo, 0, sizeof(sfInfo));
    
    // Utiliser la fréquence d'échantillonnage native du fichier audio
    int nativeSampleRate = settings.sampleRate;
    
    qDebug() << "Utilisation du taux d'échantillonnage pour le fichier WAV:" << nativeSampleRate;
    sfInfo.samplerate = nativeSampleRate;
    sfInfo.channels = 1; // Mono for simplicity
    sfInfo.format = SF_FORMAT_WAV | SF_FORMAT_FLOAT;
    
    SNDFILE *outfile = sf_open(audioTempFilePath.toUtf8().constData(), SFM_WRITE, &sfInfo);
    if (!outfile) {
        qWarning() << "Échec de la création du fichier WAV:" << sf_strerror(nullptr);
        QFile::remove(audioTempFilePath);
        emit segmentPreviewGenerated(false, QImage(), "Échec de la création du fichier WAV: " + QString(sf_strerror(nullptr)));
        return;
    }
    
    // The audioSegment contains raw float samples, we need to convert it back to float array
    int numSamples = audioSegment.size() / sizeof(float);
    const float *samples = reinterpret_cast<const float*>(audioSegment.constData());
    
    // Write the samples to the file
    sf_count_t written = sf_writef_float(outfile, samples, numSamples / sfInfo.channels);
    sf_close(outfile);
    
    if (written != numSamples / sfInfo.channels) {
        qWarning() << "Échec de l'écriture de tous les échantillons. Attendu:" << numSamples / sfInfo.channels << "Écrit:" << written;
        QFile::remove(audioTempFilePath);
        emit segmentPreviewGenerated(false, QImage(), "Échec de l'écriture de tous les échantillons audio");
        return;
    }
    
    // Créer un fichier temporaire pour la prévisualisation
    QTemporaryFile imageTempFile;
    imageTempFile.setAutoRemove(false);
    
    if (!imageTempFile.open()) {
        QFile::remove(audioTempFilePath);
        emit segmentPreviewGenerated(false, QImage(), "Impossible de créer le fichier temporaire pour l'image");
        return;
    }
    
    QString imageTempFilePath = imageTempFile.fileName();
    imageTempFile.close();
    
    // Convertir les QString en const char* pour l'API C
    QByteArray audioFileBytes = audioTempFilePath.toLocal8Bit();
    QByteArray imageFileBytes = imageTempFilePath.toLocal8Bit();
    
    const char *audioFileCStr = audioFileBytes.constData();
    const char *imageFileCStr = imageFileBytes.constData();
    
    // Ajouter des logs détaillés avant d'appeler la fonction C
    qDebug() << "Appel de spectral_generator avec:";
    qDebug() << "  - Fichier audio: " << audioTempFilePath;
    qDebug() << "  - Fichier image: " << imageTempFilePath;
    qDebug() << "  - Taille FFT: " << settings.fftSize;
    qDebug() << "  - Taux d'échantillonnage: " << settings.sampleRate;
    qDebug() << "  - Durée: " << settings.duration;
    
    // Appeler la fonction C pour générer le spectrogramme dans le fichier temporaire
    int result = spectral_generator(&settings, audioFileCStr, imageFileCStr);
    
    qDebug() << "spectral_generator a retourné: " << result << (result == EXIT_SUCCESS ? " (SUCCÈS)" : " (ÉCHEC)");
    
    if (result == EXIT_SUCCESS) {
        qDebug() << "Chargement de l'image générée depuis: " << imageTempFilePath;
        // Charger l'image générée
        QImageReader reader(imageTempFilePath);
        QImage previewImage = reader.read();
        
        if (!previewImage.isNull()) {
            qDebug() << "Image chargée avec succès: " << previewImage.width() << "x" << previewImage.height();
            // Stocker l'image et émettre le signal
            m_previewImage = previewImage;
            
            // Mettre à jour l'image dans le fournisseur d'images si disponible
            if (s_previewProvider) {
                qDebug() << "Mise à jour de l'image dans le fournisseur de prévisualisation";
                qDebug() << "Mise à jour de l'image dans le fournisseur d'images (segment)";
                qDebug() << "Dimensions de l'image: " << previewImage.width() << "x" << previewImage.height();
                qDebug() << "Format de l'image: " << previewImage.format();
                s_previewProvider->updateImage(previewImage);
                
                // Vérifier l'état de l'image après la mise à jour
                s_previewProvider->debugImageState();
            } else {
                qDebug() << "Fournisseur d'images non disponible!";
            }
            
            qDebug() << "Émission du signal segmentPreviewGenerated avec success=true";
            emit segmentPreviewGenerated(true, previewImage);
        } else {
            qWarning() << "Échec du chargement de l'image depuis: " << imageTempFilePath;
            emit segmentPreviewGenerated(false, QImage(), "Erreur lors du chargement de l'image de prévisualisation du segment");
        }
    } else {
        qWarning() << "spectral_generator a échoué avec le code: " << result;
        emit segmentPreviewGenerated(false, QImage(), "Erreur lors de la génération de la prévisualisation du segment (code: " + QString::number(result) + ")");
    }
    
    // Supprimer les fichiers temporaires
    QFile::remove(audioTempFilePath);
    QFile::remove(imageTempFilePath);
    
    qDebug() << "Génération de la prévisualisation du segment terminée avec le résultat:" << (result == EXIT_SUCCESS ? "SUCCÈS" : "ÉCHEC");
}
