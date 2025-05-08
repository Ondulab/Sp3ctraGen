#ifndef VECTORPRINTPROVIDER_H
#define VECTORPRINTPROVIDER_H

#include <QObject>
#include <QString>
#include <QUrl>
#include <QQmlEngine>
#include "spectral_generator.h"

/**
 * @brief The VectorPrintProvider class
 * 
 * Cette classe fournit des fonctionnalités d'impression vectorielle 1:1
 * en utilisant Cairo directement pour le rendu sans dépendre du système
 * d'impression de Qt. Elle permet d'exporter des spectrogrammes en PDF
 * vectoriel à haute résolution (800 DPI) avec des dimensions physiques précises.
 */
class VectorPrintProvider : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    /**
     * @brief Formats de page supportés
     */
    enum PageFormat {
        A4Portrait = 0,
        A3Landscape = 1
    };
    Q_ENUM(PageFormat)

    explicit VectorPrintProvider(QObject *parent = nullptr);
    virtual ~VectorPrintProvider();

    /**
     * @brief Génère un PDF vectoriel du spectrogramme
     * 
     * @param fftSize Taille de la FFT
     * @param overlap Chevauchement des fenêtres
     * @param minFreq Fréquence minimale (Hz)
     * @param maxFreq Fréquence maximale (Hz)
     * @param duration Durée (secondes)
     * @param sampleRate Taux d'échantillonnage
     * @param dynamicRangeDB Plage dynamique (dB)
     * @param gammaCorrection Correction gamma
     * @param enableDithering Activer le dithering
     * @param contrastFactor Facteur de contraste
     * @param enableHighBoost Activer l'amplification des hautes fréquences
     * @param highBoostAlpha Alpha pour l'amplification des hautes fréquences
     * @param enableHighPassFilter Activer le filtre passe-haut
     * @param highPassCutoffFreq Fréquence de coupure du filtre passe-haut
     * @param highPassFilterOrder Ordre du filtre passe-haut
     * @param pageFormat Format de page (0=A4 portrait, 1=A3 paysage)
     * @param bottomMarginMM Marge inférieure en millimètres
     * @param spectroHeightMM Hauteur du spectrogramme en millimètres
     * @param writingSpeed Vitesse d'écriture en cm/s
     * @param inputFile Fichier audio d'entrée
     * @param outputFolder Dossier de sortie
     * @param dpi Résolution en DPI (par défaut 800)
     */
    Q_INVOKABLE void generateVectorPDF(
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
        int dpi = 800
    );

signals:
    /**
     * @brief Signal émis lorsque le PDF vectoriel est généré
     * 
     * @param success Succès de la génération
     * @param outputPath Chemin du fichier de sortie
     * @param errorMessage Message d'erreur en cas d'échec
     */
    void vectorPDFGenerated(bool success, const QString &outputPath, const QString &errorMessage = "");

private:
    /**
     * @brief Exécute la génération du PDF vectoriel dans un thread séparé
     * 
     * @param settings Paramètres du spectrogramme
     * @param inputFile Fichier audio d'entrée
     * @param outputFile Fichier PDF de sortie
     * @param dpi Résolution en DPI
     */
    void runVectorGeneration(
        const SpectrogramSettings &settings,
        const QString &inputFile,
        const QString &outputFile,
        int dpi
    );
};

#endif // VECTORPRINTPROVIDER_H
