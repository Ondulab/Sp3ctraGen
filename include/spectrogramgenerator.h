/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef SPECTROGRAMGENERATOR_H
#define SPECTROGRAMGENERATOR_H

#include <QObject>
#include <QString>
#include <QUrl>
#include <QQmlEngine>
#include <QImage>
#include <QByteArray>
#include <QUuid>
#include <QStringList>
#include <QDir>
#include <QFileInfo>
#include "SpectrogramSettingsCpp.h"

// Forward declarations
class PreviewImageProvider;
class VisualizationStrategy;

/**
 * @brief Main class for spectrogram generation
 *
 * This class provides the interface between QML and the C/C++ backend.
 * It uses the new abstractions (SpectrogramSettingsCpp, VisualizationStrategy, etc.)
 * for better modularity and extensibility.
 */
class SpectrogramGenerator : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit SpectrogramGenerator(QObject *parent = nullptr);
    virtual ~SpectrogramGenerator();
    
    /**
     * @brief Sets the preview image provider
     *
     * @param provider Pointer to the image provider
     */
    static void setPreviewImageProvider(PreviewImageProvider *provider);

    /**
     * @brief Generates a spectrogram
     *
     * @param minFreq Minimum frequency (Hz)
     * @param maxFreq Maximum frequency (Hz)
     * @param duration Duration (seconds)
     * @param sampleRate Sample rate
     * @param dynamicRangeDB Dynamic range (dB)
     * @param gammaCorrection Gamma correction
     * @param enableDithering Enable dithering
     * @param contrastFactor Contrast factor
     * @param enableHighBoost Enable high frequency boost
     * @param highBoostAlpha Alpha for high frequency boost
     * @param enableHighPassFilter Enable high-pass filter
     * @param highPassCutoffFreq High-pass filter cutoff frequency
     * @param highPassFilterOrder High-pass filter order
     * @param pageFormat Page format (0=A4 portrait, 1=A3 landscape)
     * @param bottomMarginMM Bottom margin in millimeters
     * @param spectroHeightMM Spectrogram height in millimeters
     * @param writingSpeed Writing speed in cm/s
     * @param inputFile Input audio file
     * @param outputFolder Output folder
     * @param visualizationType Visualization type (default "Raster (PNG)")
     * @param enableNormalization Enable volume normalization (default true)
     * @param binsPerSecond Number of bins per second
     * @param overlapPreset Overlap preset (0=Low, 1=Medium, 2=High)
     */
    Q_INVOKABLE void generateSpectrogram(
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
        const QString &visualizationType = "Raster (PNG)",
        bool enableNormalization = true,
        double binsPerSecond = 150.0,
        int overlapPreset = 1
    );
    
    /**
     * @brief Generates a spectrogram preview
     *
     * @param minFreq Minimum frequency (Hz)
     * @param maxFreq Maximum frequency (Hz)
     * @param duration Duration (seconds)
     * @param sampleRate Sample rate
     * @param dynamicRangeDB Dynamic range (dB)
     * @param gammaCorrection Gamma correction
     * @param enableDithering Enable dithering
     * @param contrastFactor Contrast factor
     * @param enableHighBoost Enable high frequency boost
     * @param highBoostAlpha Alpha for high frequency boost
     * @param enableHighPassFilter Enable high-pass filter
     * @param highPassCutoffFreq High-pass filter cutoff frequency
     * @param highPassFilterOrder High-pass filter order
     * @param pageFormat Page format (0=A4 portrait, 1=A3 landscape)
     * @param bottomMarginMM Bottom margin in millimeters
     * @param spectroHeightMM Spectrogram height in millimeters
     * @param writingSpeed Writing speed in cm/s
     * @param inputFile Input audio file
     */
    Q_INVOKABLE void generatePreview(
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
        bool enableVerticalScale = true,
        bool enableBottomReferenceLine = false,
        double bottomReferenceLineOffset = -34.75,
        bool enableTopReferenceLine = false,
        double topReferenceLineOffset = 12.55,
        bool displayParameters = false,
        double textScaleFactor = 2.0,
        double lineThicknessFactor = 2.0,
        double binsPerSecond = 150.0,
        int overlapPreset = 1
    );
    
    /**
     * @brief Generates a spectrogram from an audio segment
     *
     * @param minFreq Minimum frequency (Hz)
     * @param maxFreq Maximum frequency (Hz)
     * @param segmentDuration Segment duration (seconds)
     * @param sampleRate Sample rate
     * @param dynamicRangeDB Dynamic range (dB)
     * @param gammaCorrection Gamma correction
     * @param enableDithering Enable dithering
     * @param contrastFactor Contrast factor
     * @param enableHighBoost Enable high frequency boost
     * @param highBoostAlpha Alpha for high frequency boost
     * @param enableHighPassFilter Enable high-pass filter
     * @param highPassCutoffFreq High-pass filter cutoff frequency
     * @param highPassFilterOrder High-pass filter order
     * @param pageFormat Page format (0=A4 portrait, 1=A3 landscape)
     * @param bottomMarginMM Bottom margin in millimeters
     * @param spectroHeightMM Spectrogram height in millimeters
     * @param writingSpeed Writing speed in cm/s
     * @param audioSegment Audio segment (QByteArray)
     */
    Q_INVOKABLE void generateSpectrogramFromSegment(
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
        const QString &originalAudioFileName = "",
        double startTime = 0.0,
        double binsPerSecond = 150.0,
        int overlapPreset = 1
    );
    
    /**
     * @brief Saves the current preview image
     *
     * @param outputFilePath Complete output file path
     * @param format Image format (png, pdf, etc.)
     */
    Q_INVOKABLE void saveCurrentPreview(const QString &outputFilePath, const QString &format = "png");
    
    /**
     * @brief Prints the current preview image
     *
     * @return true if printing succeeded, false otherwise
     */
    Q_INVOKABLE bool printPreview();
    
    /**
     * @brief Gets the list of available visualization types
     *
     * @return List of visualization types
     */
    Q_INVOKABLE QStringList getAvailableVisualizationTypes() const;
    
    /**
     * @brief Gets the list of supported file extensions
     *
     * @return List of supported extensions
     */
    Q_INVOKABLE QStringList getSupportedFileExtensions() const;
    
    /**
     * @brief Calcule les bins/s en fonction de la position du curseur de résolution
     *
     * Cette méthode implémente l'interpolation entre les trois ancres du curseur:
     * - 0.0 (Temporal): ratio = 0.26, privilégie la résolution temporelle
     * - 0.5 (Balanced): ratio = 0.16, équilibre entre résolution temporelle et fréquentielle
     * - 1.0 (Spectral): ratio = 0.085, privilégie la résolution fréquentielle
     *
     * @param sliderValue Position du curseur (0.0 à 1.0)
     * @param writingSpeed Vitesse d'écriture en cm/s
     * @return Valeur de bins/s calculée et limitée
     */
    Q_INVOKABLE double calculateBpsFromSlider(double sliderValue, double writingSpeed);
    
    /**
     * @brief Calcule l'overlap en fonction de la position du curseur de résolution
     *
     * @param sliderValue Position du curseur (0.0 à 1.0)
     * @return Valeur d'overlap calculée
     */
    Q_INVOKABLE double calculateOverlapFromSlider(double sliderValue);
    
    /**
     * @brief Checks if resolution limitation is reached
     *
     * @return true if bins/s value has been limited (min or max), false otherwise
     */
    Q_INVOKABLE bool isResolutionLimited();
    
    /**
     * @brief Calculates audio duration based on paper format and writing speed
     *
     * Formula: duration (s) = paper width (cm) / writeSpeed (cm/s)
     *
     * @return Audio duration in seconds
     */
    Q_INVOKABLE double calculateAudioDuration();
    
    /**
     * @brief Updates parameters when page format changes
     * 
     * This method serves as a wrapper for the private createSettings method
     * to update spectrogramgenerator parameters and recalculate audio duration
     * when output format changes in the UI.
     * 
     * @param pageFormat Page format (0=A4 portrait, 1=A3 landscape)
     * @param bottomMarginMM Bottom margin in millimeters
     * @param spectroHeightMM Spectrogram height in millimeters 
     * @param writingSpeed Writing speed in cm/s
     * @param minFreq Minimum frequency (Hz)
     * @param maxFreq Maximum frequency (Hz)
     * @param sampleRate Sample rate (optional, will use current value if 0)
     * @return Calculated audio duration in seconds after format change
     */
    Q_INVOKABLE double updatePageFormat(
        int pageFormat,
        double bottomMarginMM,
        double spectroHeightMM,
        double writingSpeed,
        double minFreq,
        double maxFreq,
        int sampleRate = 0
    );
    
    /**
     * @brief Calcule le plafond physique maxBps basé sur la résolution d'impression
     *
     * Formule: maxBps = ⌊(800/2.54) × writeSpeed⌋
     *
     * @param writingSpeed Vitesse d'écriture en cm/s
     * @return Nombre maximum de bins par seconde possible
     */
    Q_INVOKABLE double calculateMaxBps(double writingSpeed);
    
   /**
    * @brief Normalizes an audio file and saves the result to a temporary file
    *
    * @param inputPath Path to the original audio file
    * @param factor Normalization factor to apply (1.0 = no change)
    * @return Path to the normalized temporary file, or empty string if failed
    */
   Q_INVOKABLE QString normalizeAudioFile(const QString &inputPath, double factor);
   
   /**
    * @brief Calculates the normalization factor for an audio file
    *
    * @param audioPath Path to the audio file
    * @return Recommended normalization factor (0.95/maxAmplitude)
    */
   Q_INVOKABLE double calculateNormalizationFactor(const QString &audioPath);
   
    /**
     * @brief Cleans up temporary files created during normalization
     */
   Q_INVOKABLE void cleanup();
    
    /**
     * @brief Gets the width of the current preview image in pixels
     * @return Image width in pixels
     */
    Q_INVOKABLE int getPreviewImageWidth() const;
    
    /**
     * @brief Gets the height of the current preview image in pixels
     * @return Image height in pixels
     */
    Q_INVOKABLE int getPreviewImageHeight() const;
    
    /**
     * @brief Gets the DPI of the current preview image
     * @return Image DPI
     */
    Q_INVOKABLE double getPreviewImageDPI() const;
    
    /**
     * @brief Gets the width of the current preview image in centimeters
     * @return Image width in centimeters
     */
    Q_INVOKABLE double getPreviewImageWidthCM() const;
    
    /**
     * @brief Gets the height of the current preview image in centimeters
     * @return Image height in centimeters
     */
    Q_INVOKABLE double getPreviewImageHeightCM() const;

signals:
    /**
     * @brief Signal emitted when auto FFT parameters are calculated
     *
     * @param calculatedFftSize The calculated FFT size
     * @param effectiveOverlap The effective overlap value
     * @param binsPerSecond The bins per second value used for calculation
     */
    void fftParametersCalculated(int calculatedFftSize, double effectiveOverlap, double binsPerSecond);

    /**
     * @brief Signal emitted when a spectrogram is generated
     *
     * @param success Generation success
     * @param outputPath Output file path
     * @param errorMessage Error message in case of failure
     */
    void spectrogramGenerated(bool success, const QString &outputPath, const QString &errorMessage = "");
    
    /**
     * @brief Signal emitted when a preview is generated
     *
     * @param success Generation success
     * @param previewImage Preview image
     * @param errorMessage Error message in case of failure
     */
    void previewGenerated(bool success, const QImage &previewImage, const QString &errorMessage = "");
    
    /**
     * @brief Signal emitted when a segment preview is generated
     *
     * @param success Generation success
     * @param previewImage Preview image
     * @param errorMessage Error message in case of failure
     */
    void segmentPreviewGenerated(bool success, const QImage &previewImage, const QString &errorMessage = "");
    
    /**
     * @brief Signal emitted when a preview is saved
     *
     * @param success Save success
     * @param outputPath Output file path
     * @param format Image format
     * @param errorMessage Error message in case of failure
     */
    void previewSaved(bool success, const QString &outputPath, const QString &format, const QString &errorMessage = "");
    
    /**
     * @brief Signal emitted when task progress is updated
     *
     * @param taskId Task identifier
     * @param progress Progress (0-100)
     * @param message Progress message
     */
    void taskProgressUpdated(const QUuid &taskId, int progress, const QString &message);

private:
    /**
     * @brief Creates a SpectrogramSettingsCpp object from QML parameters
     *
     * @param minFreq Minimum frequency (Hz)
     * @param maxFreq Maximum frequency (Hz)
     * @param duration Duration (seconds)
     * @param sampleRate Sample rate
     * @param dynamicRangeDB Dynamic range (dB)
     * @param gammaCorrection Gamma correction
     * @param enableDithering Enable dithering
     * @param contrastFactor Contrast factor
     * @param enableHighBoost Enable high frequency boost
     * @param highBoostAlpha Alpha for high frequency boost
     * @param enableHighPassFilter Enable high-pass filter
     * @param highPassCutoffFreq High-pass filter cutoff frequency
     * @param highPassFilterOrder High-pass filter order
     * @param pageFormat Page format (0=A4 portrait, 1=A3 landscape)
     * @param bottomMarginMM Bottom margin in millimeters
     * @param spectroHeightMM Spectrogram height in millimeters
     * @param writingSpeed Writing speed in cm/s
     * @return Initialized SpectrogramSettingsCpp object
     * @param enableNormalization Enable volume normalization
     */
    // Propriété interne pour les paramètres
    SpectrogramSettingsCpp m_settings;
    
    /**
     * @brief Crée un objet SpectrogramSettingsCpp à partir des paramètres QML
     */
    SpectrogramSettingsCpp createSettings(
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
        bool enableVerticalScale = true,
        bool enableBottomReferenceLine = false,
        double bottomReferenceLineOffset = -34.75,
        bool enableTopReferenceLine = false,
        double topReferenceLineOffset = 12.55,
        bool displayParameters = false,
        double textScaleFactor = 2.0,
        double lineThicknessFactor = 2.0,
        double binsPerSecond = 150.0,
        int overlapPreset = 1
    );
    
    /**
     * @brief Private method to execute preview generation
     *
     * @param settings Spectrogram settings
     * @param inputFile Input audio file
     */
    void runPreviewGeneration(
        const SpectrogramSettings &settings,
        const QString &inputFile
    );
    
    /**
     * @brief Private method to generate a preview from an audio segment
     *
     * @param settings Spectrogram settings
     * @param audioSegment Audio segment
     * @param originalAudioFileName Original audio file name for display (optional)
     * @param startTime Start time in seconds for display (optional)
     */
    void runSegmentPreviewGeneration(
        const SpectrogramSettings &settings,
        const QByteArray &audioSegment,
        const QString &originalAudioFileName = "",
        double startTime = 0.0
    );
    
    // Preview image
    QImage m_previewImage;
    
    // Preview image provider (static)
    static PreviewImageProvider *s_previewProvider;
    
    // Map of running tasks
    QMap<QUuid, QString> m_runningTasks;
    
    // List of temporary files to be cleaned up
    QStringList m_tempFiles;
};

#endif // SPECTROGRAMGENERATOR_H
