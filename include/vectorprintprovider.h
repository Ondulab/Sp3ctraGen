/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef VECTORPRINTPROVIDER_H
#define VECTORPRINTPROVIDER_H

#include <QObject>
#include <QString>
#include <QUrl>
#include <QQmlEngine>
#include "spectral_generator.h"
#include "SharedConstants.h"

/**
 * @brief The VectorPrintProvider class
 *
 * This class provides 1:1 vector printing capabilities
 * using Cairo directly for rendering without depending on the Qt
 * printing system. It allows exporting spectrograms as vector PDF
 * at high resolution (800 DPI) with precise physical dimensions.
 */
class VectorPrintProvider : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    /**
     * @brief Supported page formats
     */
    enum PageFormat {
        A4Portrait = 0,
        A3Landscape = 1
    };
    Q_ENUM(PageFormat)

    explicit VectorPrintProvider(QObject *parent = nullptr);
    virtual ~VectorPrintProvider();

    /**
     * @brief Generates a vector PDF of the spectrogram
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
     * @param binsPerSecond Number of bins per second
     * @param overlapPreset Overlap preset (0=Low, 1=Medium, 2=High)
     * @param inputFile Input audio file
     * @param outputFolder Output folder
     * @param dpi Resolution in DPI (default 800)
     */
    Q_INVOKABLE void generateVectorPDF(
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
        double binsPerSecond,
        int overlapPreset,
        const QString &inputFile,
        const QString &outputFolder,
        int dpi = PRINTER_DPI
    );

signals:
    /**
     * @brief Signal emitted when the vector PDF is generated
     *
     * @param success Generation success
     * @param outputPath Output file path
     * @param errorMessage Error message in case of failure
     */
    void vectorPDFGenerated(bool success, const QString &outputPath, const QString &errorMessage = "");

private:
    /**
     * @brief Executes vector PDF generation in a separate thread
     *
     * @param settings Spectrogram settings
     * @param inputFile Input audio file
     * @param outputFile Output PDF file
     * @param dpi Resolution in DPI
     */
    void runVectorGeneration(
        const SpectrogramSettings &settings,
        const QString &inputFile,
        const QString &outputFile,
        int dpi
    );
};

#endif // VECTORPRINTPROVIDER_H
