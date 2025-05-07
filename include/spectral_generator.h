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
} SpectrogramSettings;

// C function we want to call from C++
int spectral_generator(const SpectrogramSettings *cfg,
                       const char *inputFile,
                       const char *outputFile);

#ifdef __cplusplus
}
#endif

#endif
