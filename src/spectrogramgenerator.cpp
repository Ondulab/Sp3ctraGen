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
            emit spectrogramGenerated(false, "", "Le fichier d'entrée n'existe pas");
            return;
        }

        QDir dir(outputFolder);
        if (!dir.exists()) {
            emit spectrogramGenerated(false, "", "Le dossier de sortie n'existe pas");
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
    // Convertir les QString en const char* pour l'API C
    QByteArray inputFileBytes = inputFile.toLocal8Bit();
    QByteArray outputFileBytes = outputFile.toLocal8Bit();
    
    const char *inputFileCStr = inputFileBytes.constData();
    const char *outputFileCStr = outputFileBytes.constData();

    // Appeler la fonction C
    int result = spectral_generator(&settings, inputFileCStr, outputFileCStr);

    // Émettre le signal avec le résultat
    if (result == EXIT_SUCCESS) {
        emit spectrogramGenerated(true, outputFile);
    } else {
        emit spectrogramGenerated(false, "", "Erreur lors de la génération du spectrogramme");
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
    int pageFormat,
    double bottomMarginMM,
    double spectroHeightMM,
    double writingSpeed,
    const QString &inputFile)
{
    // Vérifier que le fichier d'entrée existe si spécifié
    bool useDefaultPath = inputFile.isEmpty();
    
    if (!useDefaultPath && !QFileInfo::exists(inputFile)) {
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
        emit previewGenerated(false, QImage(), "Impossible de créer un fichier temporaire");
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
                qDebug() << "Mise à jour de l'image dans le fournisseur d'images";
                qDebug() << "Dimensions de l'image: " << previewImage.width() << "x" << previewImage.height();
                qDebug() << "Format de l'image: " << previewImage.format();
                s_previewProvider->updateImage(previewImage);
                
                // Vérifier l'état de l'image après la mise à jour
                s_previewProvider->debugImageState();
            } else {
                qDebug() << "Fournisseur d'images non disponible!";
            }
            
            emit previewGenerated(true, previewImage);
        } else {
            emit previewGenerated(false, QImage(), "Erreur lors du chargement de la prévisualisation");
        }
    } else {
        emit previewGenerated(false, QImage(), "Erreur lors de la génération de la prévisualisation");
    }
    
    // Supprimer le fichier temporaire
    QFile::remove(tempFilePath);
}
