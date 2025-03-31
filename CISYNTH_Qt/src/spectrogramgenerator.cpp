#include "../include/spectrogramgenerator.h"
#include <QDir>
#include <QFileInfo>
#include <QDebug>
#include <QThread>
#include <QFuture>
#include <QtConcurrent/QtConcurrent>

SpectrogramGenerator::SpectrogramGenerator(QObject *parent)
    : QObject(parent)
{
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
    const QString &inputFile,
    const QString &outputFolder)
{
    // Vérifier que les fichiers existent
    if (!QFileInfo::exists(inputFile)) {
        emit spectrogramGenerated(false, "", "Le fichier d'entrée n'existe pas");
        return;
    }

    QDir dir(outputFolder);
    if (!dir.exists()) {
        emit spectrogramGenerated(false, "", "Le dossier de sortie n'existe pas");
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

    // Définir le chemin du fichier de sortie
    QString outputFile = QDir(outputFolder).filePath("spectrogram.png");

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
