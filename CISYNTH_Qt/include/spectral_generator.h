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
    double  duration;
    int     sampleRate;
    double  dynamicRangeDB;
    double  gammaCorrection;
    int     enableDithering;
    double  contrastFactor;
    int     enableHighBoost;
    double  highBoostAlpha;
} SpectrogramSettings;

// C function we want to call from C++
int spectral_generator(const SpectrogramSettings *cfg,
                       const char *inputFile,
                       const char *outputFile);

#ifdef __cplusplus
}
#endif

#endif
