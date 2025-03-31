#ifndef SPECTROGRAMGENERATOR_H
#define SPECTROGRAMGENERATOR_H

#include <QObject>
#include <QString>
#include <QUrl>
#include <QQmlEngine>
#include "spectral_generator.h"

class SpectrogramGenerator : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit SpectrogramGenerator(QObject *parent = nullptr);
    virtual ~SpectrogramGenerator();

    Q_INVOKABLE void generateSpectrogram(
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
        const QString &outputFolder
    );

signals:
    void spectrogramGenerated(bool success, const QString &outputPath, const QString &errorMessage = "");

private:
    // Méthode privée pour exécuter la génération dans un thread séparé
    void runGeneration(
        const SpectrogramSettings &settings,
        const QString &inputFile,
        const QString &outputFile
    );
};

#endif // SPECTROGRAMGENERATOR_H
