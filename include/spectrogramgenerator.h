#ifndef SPECTROGRAMGENERATOR_H
#define SPECTROGRAMGENERATOR_H

#include <QObject>
#include <QString>
#include <QUrl>
#include <QQmlEngine>
#include <QImage>
#include <QByteArray>
#include <QUuid>
#include "SpectrogramSettingsCpp.h"

// Déclarations anticipées
class PreviewImageProvider;
class VisualizationStrategy;

/**
 * @brief Classe principale pour la génération de spectrogrammes
 * 
 * Cette classe fournit l'interface entre QML et le backend C/C++.
 * Elle utilise les nouvelles abstractions (SpectrogramSettingsCpp, VisualizationStrategy, etc.)
 * pour une meilleure modularité et extensibilité.
 */
class SpectrogramGenerator : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit SpectrogramGenerator(QObject *parent = nullptr);
    virtual ~SpectrogramGenerator();
    
    /**
     * @brief Définit le fournisseur d'images de prévisualisation
     * 
     * @param provider Pointeur vers le fournisseur d'images
     */
    static void setPreviewImageProvider(PreviewImageProvider *provider);

    /**
     * @brief Génère un spectrogramme
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
     * @param visualizationType Type de visualisation (par défaut "Raster (PNG)")
     */
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
        bool enableHighPassFilter,
        double highPassCutoffFreq,
        int highPassFilterOrder,
        int pageFormat,
        double bottomMarginMM,
        double spectroHeightMM,
        double writingSpeed,
        const QString &inputFile,
        const QString &outputFolder,
        const QString &visualizationType = "Raster (PNG)"
    );
    
    /**
     * @brief Génère une prévisualisation du spectrogramme
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
     */
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
        bool enableHighPassFilter,
        double highPassCutoffFreq,
        int highPassFilterOrder,
        int pageFormat,
        double bottomMarginMM,
        double spectroHeightMM,
        double writingSpeed,
        const QString &inputFile
    );
    
    /**
     * @brief Génère un spectrogramme à partir d'un segment audio
     * 
     * @param fftSize Taille de la FFT
     * @param overlap Chevauchement des fenêtres
     * @param minFreq Fréquence minimale (Hz)
     * @param maxFreq Fréquence maximale (Hz)
     * @param segmentDuration Durée du segment (secondes)
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
     * @param audioSegment Segment audio (QByteArray)
     */
    Q_INVOKABLE void generateSpectrogramFromSegment(
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
        const QByteArray &audioSegment
    );
    
    /**
     * @brief Sauvegarde l'image de prévisualisation actuelle
     * 
     * @param outputFolder Dossier de sortie
     * @param format Format de l'image (png, pdf, etc.)
     */
    Q_INVOKABLE void saveCurrentPreview(const QString &outputFolder, const QString &format = "png");
    
    /**
     * @brief Obtient la liste des types de visualisation disponibles
     * 
     * @return Liste des types de visualisation
     */
    Q_INVOKABLE QStringList getAvailableVisualizationTypes() const;
    
    /**
     * @brief Obtient la liste des extensions de fichier supportées
     * 
     * @return Liste des extensions supportées
     */
    Q_INVOKABLE QStringList getSupportedFileExtensions() const;

signals:
    /**
     * @brief Signal émis lorsqu'un spectrogramme est généré
     * 
     * @param success Succès de la génération
     * @param outputPath Chemin du fichier de sortie
     * @param errorMessage Message d'erreur en cas d'échec
     */
    void spectrogramGenerated(bool success, const QString &outputPath, const QString &errorMessage = "");
    
    /**
     * @brief Signal émis lorsqu'une prévisualisation est générée
     * 
     * @param success Succès de la génération
     * @param previewImage Image de prévisualisation
     * @param errorMessage Message d'erreur en cas d'échec
     */
    void previewGenerated(bool success, const QImage &previewImage, const QString &errorMessage = "");
    
    /**
     * @brief Signal émis lorsqu'une prévisualisation de segment est générée
     * 
     * @param success Succès de la génération
     * @param previewImage Image de prévisualisation
     * @param errorMessage Message d'erreur en cas d'échec
     */
    void segmentPreviewGenerated(bool success, const QImage &previewImage, const QString &errorMessage = "");
    
    /**
     * @brief Signal émis lorsqu'une prévisualisation est sauvegardée
     * 
     * @param success Succès de la sauvegarde
     * @param outputPath Chemin du fichier de sortie
     * @param format Format de l'image
     * @param errorMessage Message d'erreur en cas d'échec
     */
    void previewSaved(bool success, const QString &outputPath, const QString &format, const QString &errorMessage = "");
    
    /**
     * @brief Signal émis lorsque la progression d'une tâche est mise à jour
     * 
     * @param taskId Identifiant de la tâche
     * @param progress Progression (0-100)
     * @param message Message de progression
     */
    void taskProgressUpdated(const QUuid &taskId, int progress, const QString &message);

private:
    /**
     * @brief Crée un objet SpectrogramSettingsCpp à partir des paramètres QML
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
     * @return Objet SpectrogramSettingsCpp initialisé
     */
    SpectrogramSettingsCpp createSettings(
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
        double writingSpeed
    );
    
    /**
     * @brief Méthode privée pour exécuter la génération de prévisualisation
     * 
     * @param settings Paramètres du spectrogramme
     * @param inputFile Fichier audio d'entrée
     */
    void runPreviewGeneration(
        const SpectrogramSettings &settings,
        const QString &inputFile
    );
    
    /**
     * @brief Méthode privée pour générer une prévisualisation à partir d'un segment audio
     * 
     * @param settings Paramètres du spectrogramme
     * @param audioSegment Segment audio
     */
    void runSegmentPreviewGeneration(
        const SpectrogramSettings &settings,
        const QByteArray &audioSegment
    );
    
    // Image de prévisualisation
    QImage m_previewImage;
    
    // Fournisseur d'images de prévisualisation (statique)
    static PreviewImageProvider *s_previewProvider;
    
    // Map des tâches en cours
    QMap<QUuid, QString> m_runningTasks;
};

#endif // SPECTROGRAMGENERATOR_H
