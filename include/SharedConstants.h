#ifndef SHARED_CONSTANTS_H
#define SHARED_CONSTANTS_H

#ifdef __cplusplus
extern "C" {
#endif

// Paramètres audio par défaut
#define DEFAULT_FFT_SIZE        8192
#define DEFAULT_OVERLAP         0.85
#define DEFAULT_MIN_FREQ        65.0
#define DEFAULT_MAX_FREQ        16640.0
#define DEFAULT_DURATION        4.0
#define DEFAULT_SAMPLE_RATE     192000
#define DYNAMIC_RANGE_DB        60.0
#define GAMMA_CORRECTION        0.8
#define ENABLE_DITHERING        0
#define CONTRAST_FACTOR         1.9
#define ENABLE_HIGH_BOOST       1
#define HIGH_BOOST_ALPHA        0.99

// Dimensions de page en millimètres
#define A4_WIDTH_MM             210.0
#define A4_HEIGHT_MM            297.0
#define A3_WIDTH_MM             420.0
#define A3_HEIGHT_MM            297.0

// Facteurs de conversion
#define MM_TO_PIXELS            31.5    // 800 DPI / 25.4 mm/inch
#define MM_TO_POINTS            2.83    // 72 DPI / 25.4 mm/inch
#define POINTS_PER_INCH         72.0
#define PIXELS_TO_CM            0.00317 // 1 pixel = 0.00317 cm à 800 DPI

// Marges par défaut
#define DEFAULT_BOTTOM_MARGIN_MM 50.8
#define DEFAULT_SPECTRO_HEIGHT_MM 216.7

// Chemins par défaut
#define DEFAULT_INPUT_FILENAME  "sample.wav"
#define DEFAULT_OUTPUT_FOLDER   "."
#define DEFAULT_OUTPUT_FILENAME "spectrogram.png"
#define DEFAULT_PDF_FILENAME    "spectrogram.pdf"

#ifdef __cplusplus
}
#endif

#endif // SHARED_CONSTANTS_H