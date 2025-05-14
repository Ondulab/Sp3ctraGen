#ifndef SHARED_CONSTANTS_H
#define SHARED_CONSTANTS_H

#ifdef __cplusplus
extern "C" {
#endif

// Paramètres audio par défaut
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
#define DEFAULT_BINS_PER_SECOND 150.0

// Limites pour les bins par seconde
#define MIN_BINS_PER_SECOND     20.0
#define MAX_BINS_PER_SECOND     1200.0

// Constantes pour la résolution d'impression
#define PRINTER_DPI             800.0
#define INCH_TO_CM              2.54

// Constantes pour les ancres du curseur "Resolution"
#define RESOLUTION_TEMPORAL_RATIO    0.26
#define RESOLUTION_BALANCED_RATIO    0.16
#define RESOLUTION_SPECTRAL_RATIO    0.085

#define RESOLUTION_TEMPORAL_OVERLAP  0.30
#define RESOLUTION_BALANCED_OVERLAP  0.75
#define RESOLUTION_SPECTRAL_OVERLAP  0.92

// Niveaux d'overlap pour le mode bins/s
#define OVERLAP_PRESET_LOW      0.75
#define OVERLAP_PRESET_MEDIUM   0.85
#define OVERLAP_PRESET_HIGH     0.95
#define DEFAULT_OVERLAP_PRESET  1     // Medium (0=Low, 1=Medium, 2=High)

// Dimensions de page en millimètres
#define A4_WIDTH_MM             210.0
#define A4_HEIGHT_MM            297.0
#define A3_WIDTH_MM             420.0
#define A3_HEIGHT_MM            297.0

// Dimensions de page en centimètres pour les calculs de durée
#define A4_PORTRAIT_WIDTH_CM    21.0
#define A3_LANDSCAPE_WIDTH_CM   42.0

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