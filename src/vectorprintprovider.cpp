#include "../include/vectorprintprovider.h"
#include <QDir>
#include <QFileInfo>
#include <QDebug>
#include <QThread>
#include <QFuture>
#include <QtConcurrent/QtConcurrent>
#include <cairo/cairo.h>
#include <cairo/cairo-pdf.h>

// Fonction C externe pour la génération vectorielle (à implémenter)
extern "C" {
    int spectral_generator_vector_pdf(const SpectrogramSettings *cfg,
                                     const char *inputFile,
                                     const char *outputFile,
                                     int dpi);
}

VectorPrintProvider::VectorPrintProvider(QObject *parent)
    : QObject(parent)
{
}

VectorPrintProvider::~VectorPrintProvider()
{
}

void VectorPrintProvider::generateVectorPDF(
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
    int dpi)
{
    // Vérifier que les fichiers existent
    if (inputFile.isEmpty()) {
        emit vectorPDFGenerated(false, "", "Le fichier d'entrée n'est pas spécifié");
        return;
    }

    if (!QFileInfo::exists(inputFile)) {
        emit vectorPDFGenerated(false, "", "Le fichier d'entrée n'existe pas");
        return;
    }

    QDir dir(outputFolder);
    if (!dir.exists()) {
        emit vectorPDFGenerated(false, "", "Le dossier de sortie n'existe pas");
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

    // Définir le chemin du fichier de sortie
    QString outputFile = QDir(outputFolder).filePath("spectrogram_vector.pdf");

    // Exécuter la génération dans un thread séparé
    QFuture<void> future = QtConcurrent::run([=]() {
        this->runVectorGeneration(settings, inputFile, outputFile, dpi);
    });
}

void VectorPrintProvider::runVectorGeneration(
    const SpectrogramSettings &settings,
    const QString &inputFile,
    const QString &outputFile,
    int dpi)
{
    // Ajouter des logs détaillés
    qDebug() << "Génération du PDF vectoriel";
    qDebug() << "Fichier d'entrée: " << inputFile;
    qDebug() << "Fichier de sortie: " << outputFile;
    qDebug() << "Résolution: " << dpi << " DPI";
    qDebug() << "Taille FFT: " << settings.fftSize;
    qDebug() << "Format de page: " << (settings.pageFormat == 0 ? "A4 portrait" : "A3 paysage");
    
    // Convertir les QString en const char* pour l'API C
    QByteArray inputFileBytes = inputFile.toLocal8Bit();
    QByteArray outputFileBytes = outputFile.toLocal8Bit();
    
    const char *inputFileCStr = inputFileBytes.constData();
    const char *outputFileCStr = outputFileBytes.constData();

    // Appeler la fonction C
    qDebug() << "Appel de spectral_generator_vector_pdf pour la génération du PDF vectoriel";
    int result = spectral_generator_vector_pdf(&settings, inputFileCStr, outputFileCStr, dpi);
    qDebug() << "spectral_generator_vector_pdf a retourné: " << result << (result == EXIT_SUCCESS ? " (SUCCÈS)" : " (ÉCHEC)");

    // Émettre le signal avec le résultat
    if (result == EXIT_SUCCESS) {
        qDebug() << "PDF vectoriel généré avec succès à: " << outputFile;
        // Vérifier que le fichier existe
        if (QFile::exists(outputFile)) {
            qDebug() << "Le fichier de sortie existe, émission du signal de succès";
            emit vectorPDFGenerated(true, outputFile);
        } else {
            qWarning() << "Le fichier de sortie n'existe pas: " << outputFile;
            emit vectorPDFGenerated(false, "", "Le fichier de sortie n'a pas été créé");
        }
    } else {
        qWarning() << "Échec de la génération du PDF vectoriel, code d'erreur: " << result;
        emit vectorPDFGenerated(false, "", "Erreur lors de la génération du PDF vectoriel (code: " + QString::number(result) + ")");
    }
}
