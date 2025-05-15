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
#define DEFAULT_RESOLUTION_VALUE 0.5    // Position du curseur par défaut (0.0-1.0)

// Limites pour les bins par seconde
#define MIN_BINS_PER_SECOND     10.0    // Minimum absolu pour la densité temporelle 
#define MAX_BINS_PER_SECOND     1200  // Maximum absolu pour la densité temporelle

// Constantes pour la résolution d'impression
#define PRINTER_DPI             400.0
#define INCH_TO_CM              2.54

// Paramètres du système de résolution adaptative
// ---------------------------------------------

// Taux d'échantillonnage de référence pour l'adaptation
#define REFERENCE_SAMPLE_RATE    48000

// Tailles FFT de référence pour chaque position du curseur (à 48kHz)
#define RESOLUTION_TEMPORAL_FFT_SIZE  512     // Position 0.0 (temporel)
#define RESOLUTION_BALANCED_FFT_SIZE  2048    // Position 0.5 (équilibré)
#define RESOLUTION_SPECTRAL_FFT_SIZE  8192    // Position 1.0 (spectral)

// Facteurs de densité temporelle pour chaque position du curseur
// (en pourcentage du maximum physique possible)
#define RESOLUTION_TEMPORAL_DENSITY_FACTOR  1.0     // 100% du max
#define RESOLUTION_BALANCED_DENSITY_FACTOR  0.5     // 50% du max
#define RESOLUTION_SPECTRAL_DENSITY_FACTOR  0.2     // 20% du max

// Valeurs d'overlap typiques (pour information, calculées dynamiquement)
#define RESOLUTION_TEMPORAL_OVERLAP  0.30    // Faible overlap en mode temporel
#define RESOLUTION_BALANCED_OVERLAP  0.75    // Overlap moyen en mode équilibré
#define RESOLUTION_SPECTRAL_OVERLAP  0.92    // Overlap élevé en mode spectral

// Presets d'overlap pour rétrocompatibilité
// (utilisation progressivement remplacée par l'overlap calculé dynamiquement)
#define OVERLAP_PRESET_LOW      0.30
#define OVERLAP_PRESET_MEDIUM   0.75
#define OVERLAP_PRESET_HIGH     0.92
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
#define MM_TO_PIXELS           (PRINTER_DPI/25.4)
#define MM_TO_POINTS            2.83    // 72 DPI / 25.4 mm/inch
#define POINTS_PER_INCH         72.0
#define PIXELS_TO_CM            (2.54/PRINTER_DPI)

// Marges par défaut
#define DEFAULT_BOTTOM_MARGIN_MM 50.8
#define DEFAULT_SPECTRO_HEIGHT_MM 216.7

// Chemins par défaut
#define DEFAULT_INPUT_FILENAME  "./sample.wav"
#define DEFAULT_OUTPUT_FOLDER   "."
#define DEFAULT_OUTPUT_FILENAME "spectrogram.png"
#define DEFAULT_PDF_FILENAME    "spectrogram.pdf"

#ifdef __cplusplus
}
#endif

#endif // SHARED_CONSTANTS_H
