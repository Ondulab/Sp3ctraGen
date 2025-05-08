#include "../include/spectrogramgenerator.h"
#include "../include/previewimageprovider.h"
#include <QDir>
#include <QFileInfo>
#include <QDebug>
#include <QThread>
#include <QFuture>
#include <QtConcurrent/QtConcurrent>
#include <QTemporaryFile>
#include <QImageReader>
#include <QBuffer>
#include <sndfile.h>

// Initialisation de la variable statique
PreviewImageProvider* SpectrogramGenerator::s_previewProvider = nullptr;

SpectrogramGenerator::SpectrogramGenerator(QObject *parent)
    : QObject(parent)
{
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
    const QString &outputFolder)
{
    // Si les chemins sont vides, les valeurs par défaut seront utilisées automatiquement
    // dans le module spectral_generator.c
    bool useDefaultPaths = inputFile.isEmpty() || outputFolder.isEmpty();
    
    // Vérifier que les fichiers existent si nous n'utilisons pas les chemins par défaut
    if (!useDefaultPaths) {
        if (!QFileInfo::exists(inputFile)) {
            emit spectrogramGenerated(false, "", "Input file does not exist");
            return;
        }

        QDir dir(outputFolder);
        if (!dir.exists()) {
            emit spectrogramGenerated(false, "", "Output folder does not exist");
            return;
        }
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

    // Définir le chemin du fichier de sortie
    QString outputFile;
    if (useDefaultPaths) {
        // Si nous utilisons les chemins par défaut, laissons le module C gérer cela
        outputFile = "";
    } else {
        outputFile = QDir(outputFolder).filePath("spectrogram.png");
    }

    // Exécuter la génération dans un thread séparé
    QFuture<void> future = QtConcurrent::run([=]() {
        this->runGeneration(settings, inputFile, outputFile);
    });
}

void SpectrogramGenerator::runGeneration(
    const SpectrogramSettings &settings,
    const QString &inputFile,
    const QString &outputFile)
{
    // Ajouter des logs détaillés
    qDebug() << "Running spectrogram generation";
    qDebug() << "Input file: " << inputFile;
    qDebug() << "Output file: " << outputFile;
    qDebug() << "FFT size: " << settings.fftSize;
    qDebug() << "Sample rate: " << settings.sampleRate;
    qDebug() << "Duration: " << settings.duration;
    qDebug() << "Writing speed: " << settings.writingSpeed;
    
    // Convertir les QString en const char* pour l'API C
    QByteArray inputFileBytes = inputFile.toLocal8Bit();
    QByteArray outputFileBytes = outputFile.toLocal8Bit();
    
    const char *inputFileCStr = inputFileBytes.constData();
    const char *outputFileCStr = outputFileBytes.constData();

    // Appeler la fonction C
    qDebug() << "Calling spectral_generator for full spectrogram generation";
    int result = spectral_generator(&settings, inputFileCStr, outputFileCStr);
    qDebug() << "spectral_generator returned: " << result << (result == EXIT_SUCCESS ? " (SUCCESS)" : " (FAILURE)");

    // Émettre le signal avec le résultat
    if (result == EXIT_SUCCESS) {
        qDebug() << "Spectrogram generated successfully at: " << outputFile;
        // Vérifier que le fichier existe
        if (QFile::exists(outputFile)) {
            qDebug() << "Output file exists, emitting success signal";
            emit spectrogramGenerated(true, outputFile);
        } else {
            qWarning() << "Output file does not exist: " << outputFile;
            emit spectrogramGenerated(false, "", "Output file was not created");
        }
    } else {
        qWarning() << "Failed to generate spectrogram, error code: " << result;
        emit spectrogramGenerated(false, "", "Error generating spectrogram (code: " + QString::number(result) + ")");
    }
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
    bool useDefaultPath = inputFile.isEmpty();
    
    if (!useDefaultPath && !QFileInfo::exists(inputFile)) {
        emit previewGenerated(false, QImage(), "Input file does not exist");
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

    // Exécuter la génération de prévisualisation dans un thread séparé
    QFuture<void> future = QtConcurrent::run([=]() {
        this->runPreviewGeneration(settings, inputFile);
    });
}

void SpectrogramGenerator::runPreviewGeneration(
    const SpectrogramSettings &settings,
    const QString &inputFile)
{
    // Créer un fichier temporaire pour la prévisualisation
    QTemporaryFile tempFile;
    tempFile.setAutoRemove(false); // Ne pas supprimer automatiquement pour pouvoir le charger
    
    if (!tempFile.open()) {
        emit previewGenerated(false, QImage(), "Unable to create temporary file");
        return;
    }
    
    QString tempFilePath = tempFile.fileName();
    tempFile.close();
    
    // Convertir les QString en const char* pour l'API C
    QByteArray inputFileBytes = inputFile.toLocal8Bit();
    QByteArray tempFileBytes = tempFilePath.toLocal8Bit();
    
    const char *inputFileCStr = inputFileBytes.constData();
    const char *tempFileCStr = tempFileBytes.constData();

    // Appeler la fonction C pour générer le spectrogramme dans le fichier temporaire
    int result = spectral_generator(&settings, inputFileCStr, tempFileCStr);

    if (result == EXIT_SUCCESS) {
        // Charger l'image générée
        QImageReader reader(tempFilePath);
        QImage previewImage = reader.read();
        
        if (!previewImage.isNull()) {
            // Stocker l'image et émettre le signal
            m_previewImage = previewImage;
            
            // Mettre à jour l'image dans le fournisseur d'images si disponible
            if (s_previewProvider) {
                qDebug() << "Updating image in image provider";
                qDebug() << "Image dimensions: " << previewImage.width() << "x" << previewImage.height();
                qDebug() << "Image format: " << previewImage.format();
                s_previewProvider->updateImage(previewImage);
                
                // Vérifier l'état de l'image après la mise à jour
                s_previewProvider->debugImageState();
            } else {
                qDebug() << "Image provider not available!";
            }
            
            emit previewGenerated(true, previewImage);
        } else {
            emit previewGenerated(false, QImage(), "Error loading preview image");
        }
    } else {
        emit previewGenerated(false, QImage(), "Error generating preview");
    }
    
    // Supprimer le fichier temporaire
    QFile::remove(tempFilePath);
}

void SpectrogramGenerator::saveCurrentPreview(const QString &outputFolder, const QString &format)
{
    qDebug() << "SpectrogramGenerator::saveCurrentPreview - Saving current preview to folder:" << outputFolder;
    
    // Vérifier que le fournisseur d'images est disponible
    if (!s_previewProvider) {
        qWarning() << "Image provider not available!";
        emit previewSaved(false, "", "Image provider not available");
        return;
    }
    
    // Vérifier que le dossier de sortie existe
    QDir dir(outputFolder);
    if (!outputFolder.isEmpty() && !dir.exists()) {
        qWarning() << "Output folder does not exist:" << outputFolder;
        emit previewSaved(false, "", "Output folder does not exist");
        return;
    }
    
    // Définir le chemin du fichier de sortie avec l'extension appropriée
    QString outputFile;
    QString fileName = "spectrogram_preview." + format.toLower();
    
    if (outputFolder.isEmpty()) {
        // Si le dossier de sortie est vide, utiliser le dossier courant
        outputFile = QDir::currentPath() + "/" + fileName;
    } else {
        outputFile = QDir(outputFolder).filePath(fileName);
    }
    
    qDebug() << "Saving preview to:" << outputFile;
    
    // Sauvegarder l'image originale à haute résolution dans le format spécifié
    bool success = s_previewProvider->saveOriginalImage(outputFile, format);
    
    if (success) {
        qDebug() << "Preview saved successfully to:" << outputFile << "in format:" << format;
        emit previewSaved(true, outputFile, format);
    } else {
        qWarning() << "Failed to save preview to:" << outputFile << "in format:" << format;
        emit previewSaved(false, "", format, "Failed to save preview image");
    }
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
        emit segmentPreviewGenerated(false, QImage(), "Audio segment is empty");
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
    settings.sampleRate = 0; // 0 signifie "utiliser la fréquence native du fichier"
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

    // Exécuter la génération de prévisualisation dans un thread séparé
    QFuture<void> future = QtConcurrent::run([=]() {
        this->runSegmentPreviewGeneration(settings, audioSegment);
    });
}

void SpectrogramGenerator::runSegmentPreviewGeneration(
    const SpectrogramSettings &settings,
    const QByteArray &audioSegment)
{
    // Log debug information
    qDebug() << "Running segment preview generation";
    qDebug() << "Segment size:" << audioSegment.size() << "bytes";
    qDebug() << "Sample rate:" << settings.sampleRate;
    qDebug() << "Duration:" << settings.duration << "seconds";
    
    // Create a temporary WAV file with proper header
    QTemporaryFile audioTempFile(QDir::tempPath() + "/spectrogen_segment_XXXXXX.wav");
    audioTempFile.setAutoRemove(false); // Don't auto-remove to allow processing
    
    if (!audioTempFile.open()) {
        emit segmentPreviewGenerated(false, QImage(), "Failed to create temporary file for audio data");
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
    
    // Utiliser la fréquence d'échantillonnage native du fichier audio
    // Si settings.sampleRate est 0, utiliser une valeur par défaut raisonnable
    int nativeSampleRate;
    
    if (settings.sampleRate > 0) {
        nativeSampleRate = settings.sampleRate;
    } else {
        // Utiliser la fréquence d'échantillonnage du segment audio
        // Comme nous n'avons pas accès direct à cette information, nous utilisons une valeur par défaut
        nativeSampleRate = 44100; // Valeur par défaut raisonnable
    }
    
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
    
    // Créer un fichier temporaire pour la prévisualisation
    QTemporaryFile imageTempFile;
    imageTempFile.setAutoRemove(false);
    
    if (!imageTempFile.open()) {
        QFile::remove(audioTempFilePath);
        emit segmentPreviewGenerated(false, QImage(), "Unable to create temporary file for image");
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
    qDebug() << "Calling spectral_generator with:";
    qDebug() << "  - Audio file: " << audioTempFilePath;
    qDebug() << "  - Image file: " << imageTempFilePath;
    qDebug() << "  - FFT size: " << settings.fftSize;
    qDebug() << "  - Sample rate: " << settings.sampleRate;
    qDebug() << "  - Duration: " << settings.duration;
    
    // Appeler la fonction C pour générer le spectrogramme dans le fichier temporaire
    int result = spectral_generator(&settings, audioFileCStr, imageFileCStr);
    
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
