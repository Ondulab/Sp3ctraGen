#ifndef SPECTROGRAMGENERATOR_H
#define SPECTROGRAMGENERATOR_H

#include <QObject>
#include <QString>
#include <QUrl>
#include <QQmlEngine>
#include <QImage>
#include "spectral_generator.h"

// Déclaration anticipée
class PreviewImageProvider;

class SpectrogramGenerator : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit SpectrogramGenerator(QObject *parent = nullptr);
    virtual ~SpectrogramGenerator();
    
    // Méthode statique pour définir le fournisseur d'images de prévisualisation
    static void setPreviewImageProvider(PreviewImageProvider *provider);

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
        int pageFormat,
        double bottomMarginMM,
        double spectroHeightMM,
        double writingSpeed,
        const QString &inputFile,
        const QString &outputFolder
    );
    
    Q_INVOKABLE void generatePreview(
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
        const QString &inputFile
    );

signals:
    void spectrogramGenerated(bool success, const QString &outputPath, const QString &errorMessage = "");
    void previewGenerated(bool success, const QImage &previewImage, const QString &errorMessage = "");

private:
    // Méthode privée pour exécuter la génération dans un thread séparé
    void runGeneration(
        const SpectrogramSettings &settings,
        const QString &inputFile,
        const QString &outputFile
    );
    
    // Méthode privée pour générer une prévisualisation
    void runPreviewGeneration(
        const SpectrogramSettings &settings,
        const QString &inputFile
    );
    
    // Image de prévisualisation
    QImage m_previewImage;
    
    // Fournisseur d'images de prévisualisation (statique)
    static PreviewImageProvider *s_previewProvider;
};

#endif // SPECTROGRAMGENERATOR_H
