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
     * @param fftSize FFT size
     * @param overlap Window overlap
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
        const QString &visualizationType = "Raster (PNG)",
        bool enableNormalization = true
    );
    
    /**
     * @brief Generates a spectrogram preview
     *
     * @param fftSize FFT size
     * @param overlap Window overlap
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
        bool enableVerticalScale = true,
        bool enableBottomReferenceLine = false,
        double bottomReferenceLineOffset = -34.75,
        bool enableTopReferenceLine = false,
        double topReferenceLineOffset = 12.55,
        bool displayParameters = false,
        double textScaleFactor = 2.0,
        double lineThicknessFactor = 2.0
    );
    
    /**
     * @brief Generates a spectrogram from an audio segment
     *
     * @param fftSize FFT size
     * @param overlap Window overlap
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
        double startTime = 0.0
    );
    
    /**
     * @brief Saves the current preview image
     *
     * @param outputFolder Output folder
     * @param format Image format (png, pdf, etc.)
     */
    Q_INVOKABLE void saveCurrentPreview(const QString &outputFolder, const QString &format = "png");
    
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

signals:
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
     * @param fftSize FFT size
     * @param overlap Window overlap
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
        double writingSpeed,
        bool enableNormalization,
        bool enableVerticalScale = true,
        bool enableBottomReferenceLine = false,
        double bottomReferenceLineOffset = -34.75,
        bool enableTopReferenceLine = false,
        double topReferenceLineOffset = 12.55,
        bool displayParameters = false,
        double textScaleFactor = 2.0,
        double lineThicknessFactor = 2.0
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
};

#endif // SPECTROGRAMGENERATOR_H
