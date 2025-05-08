#ifndef CONSTANTS_H
#define CONSTANTS_H

#include <QString>

/**
 * @brief Espace de noms pour les constantes centralisées
 * 
 * Cet espace de noms contient toutes les constantes utilisées dans l'application,
 * centralisées en un seul endroit pour faciliter la maintenance.
 */
namespace Constants {
    // Paramètres audio par défaut
    constexpr int DEFAULT_FFT_SIZE = 8192;
    constexpr double DEFAULT_OVERLAP = 0.85;
    constexpr double DEFAULT_MIN_FREQ = 65.0;
    constexpr double DEFAULT_MAX_FREQ = 16640.0;
    constexpr double DEFAULT_DURATION = 4.0;
    constexpr int DEFAULT_SAMPLE_RATE = 192000;
    constexpr double DYNAMIC_RANGE_DB = 60.0;
    constexpr double GAMMA_CORRECTION = 0.8;
    constexpr bool ENABLE_DITHERING = false;
    constexpr double CONTRAST_FACTOR = 1.9;
    constexpr bool ENABLE_HIGH_BOOST = true;
    constexpr double HIGH_BOOST_ALPHA = 0.99;
    
    // Formats de page
    constexpr int PAGE_FORMAT_A4_PORTRAIT = 0;
    constexpr int PAGE_FORMAT_A3_LANDSCAPE = 1;
    
    // Dimensions de page en millimètres
    constexpr double A4_WIDTH_MM = 210.0;
    constexpr double A4_HEIGHT_MM = 297.0;
    constexpr double A3_WIDTH_MM = 420.0;
    constexpr double A3_HEIGHT_MM = 297.0;
    
    // Facteurs de conversion
    constexpr double MM_TO_PIXELS = 31.5;    // 800 DPI / 25.4 mm/inch
    constexpr double MM_TO_POINTS = 2.83;    // 72 DPI / 25.4 mm/inch
    constexpr double POINTS_PER_INCH = 72.0;
    
    // Marges par défaut
    constexpr double DEFAULT_BOTTOM_MARGIN_MM = 50.8;  // ~2 inches
    constexpr double DEFAULT_SPECTRO_HEIGHT_MM = 169.3; // ~6.7 inches
    
    // Couleurs de l'interface utilisateur
    const QString PRIMARY_COLOR = "#D4AF37";  // Or
    const QString BACKGROUND_COLOR = "#222222";
    const QString FIELD_BACKGROUND_COLOR = "#333333";
    const QString FIELD_TEXT_COLOR = "#BBBBBB";
    const QString BUTTON_BACKGROUND_COLOR = "#555555";
    const QString BUTTON_TEXT_COLOR = "#000000";
    const QString BUTTON_HOVER_BACKGROUND_COLOR = "#333333";
    const QString BUTTON_HOVER_TEXT_COLOR = "#FFFFFF";
    const QString BORDER_COLOR = "#D4AF37";
    const QString TOGGLE_BORDER_COLOR = "#555555";
    const QString TOGGLE_ACTIVE_COLOR = "#D4AF37";
    const QString TOGGLE_INACTIVE_COLOR = "#555555";
    const QString SEPARATOR_COLOR = "#444444";
    const QString SUCCESS_COLOR = "#4CAF50";
    const QString ERROR_COLOR = "#F44336";
    
    // Chemins par défaut (à remplacer par des chemins relatifs ou configurables)
    const QString DEFAULT_INPUT_FILE = "sample.wav";
    const QString DEFAULT_OUTPUT_FOLDER = ".";
    const QString DEFAULT_OUTPUT_FILE = "spectrogram.png";
    const QString DEFAULT_PDF_OUTPUT = "spectrogram.pdf";
}

#endif // CONSTANTS_H