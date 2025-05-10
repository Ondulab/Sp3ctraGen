/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef SPECTROGRAM_CONFIG_H
#define SPECTROGRAM_CONFIG_H

#ifdef __cplusplus
extern "C" {
#endif

// Structure for spectrogram settings
typedef struct SpectrogramSettings
{
    int     fftSize;
    double  overlap;
    double  minFreq;
    double  maxFreq;
    double  duration;        // Used as a fallback if writingSpeed is 0
    int     sampleRate;
    double  dynamicRangeDB;
    double  gammaCorrection;
    int     enableDithering;
    double  contrastFactor;
    int     enableHighBoost;
    double  highBoostAlpha;
    int     pageFormat;       // 0 = A4 portrait, 1 = A3 landscape
    double  bottomMarginMM;   // bottom margin in millimeters
    double  spectroHeightMM;  // spectrogram height in millimeters
    double  writingSpeed;     // writing speed in cm/s
    int     enableHighPassFilter;  // 0 = disabled, 1 = enabled
    double  highPassCutoffFreq;    // Cutoff frequency in Hz
    int     highPassFilterOrder;   // Filter order (1-8)
    int     enableNormalization;   // 0 = disabled, 1 = enabled (preserve original amplitude)
    int     enableVerticalScale;   // 0 = disabled, 1 = enabled
    int     enableBottomReferenceLine;    // 0 = disabled, 1 = enabled
    double  bottomReferenceLineOffset;    // Offset in mm (negative = downward)
    int     enableTopReferenceLine;       // 0 = disabled, 1 = enabled
    double  topReferenceLineOffset;       // Offset in mm (positive = upward)
    int     displayParameters;            // 0 = disabled, 1 = enabled
    double  textScaleFactor;              // Scale factor for text size (default = 1.0)
    double  lineThicknessFactor;          // Scale factor for line thickness (default = 1.0)
} SpectrogramSettings;

// C function we want to call from C++
int spectral_generator(const SpectrogramSettings *cfg,
                       const char *inputFile,
                       const char *outputFile);

// C function for vector PDF generation with custom DPI
int spectral_generator_vector_pdf(const SpectrogramSettings *cfg,
                                 const char *inputFile,
                                 const char *outputFile,
                                 int dpi);

// C function with additional metadata for parameters display
int spectral_generator_with_metadata(const SpectrogramSettings *cfg,
                                   const char *inputFile,
                                   const char *outputFile,
                                   const char *audioFileName,
                                   double startTime,
                                   double segmentDuration);

#ifdef __cplusplus
}
#endif

#endif
