/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef CONSTANTS_H
#define CONSTANTS_H

#include <QString>
#include "SharedConstants.h"

/**
 * @brief Namespace for centralized constants
 *
 * This namespace contains all constants used in the application,
 * centralized in one place to facilitate maintenance.
 */
namespace Constants {
    // Default audio parameters
    constexpr int FFT_SIZE = DEFAULT_FFT_SIZE;
    constexpr double OVERLAP = DEFAULT_OVERLAP;
    constexpr double MIN_FREQ = DEFAULT_MIN_FREQ;
    constexpr double MAX_FREQ = DEFAULT_MAX_FREQ;
    constexpr double DURATION = DEFAULT_DURATION;
    constexpr int SAMPLE_RATE = DEFAULT_SAMPLE_RATE;
    constexpr double DYNAMIC_RANGE = DYNAMIC_RANGE_DB;
    constexpr double GAMMA = GAMMA_CORRECTION;
    constexpr bool DITHERING = (ENABLE_DITHERING != 0);
    constexpr double CONTRAST = CONTRAST_FACTOR;
    constexpr bool HIGH_BOOST = (ENABLE_HIGH_BOOST != 0);
    constexpr double HIGH_BOOST_ALPHA_VAL = HIGH_BOOST_ALPHA;
    
    // Page formats
    constexpr int PAGE_FORMAT_A4_PORTRAIT = 0;
    constexpr int PAGE_FORMAT_A3_LANDSCAPE = 1;
    
    // Page dimensions in millimeters
    constexpr double A4_WIDTH = A4_WIDTH_MM;
    constexpr double A4_HEIGHT = A4_HEIGHT_MM;
    constexpr double A3_WIDTH = A3_WIDTH_MM;
    constexpr double A3_HEIGHT = A3_HEIGHT_MM;
    
    // Conversion factors
    constexpr double MM_TO_PX = MM_TO_PIXELS;
    constexpr double MM_TO_PT = MM_TO_POINTS;
    constexpr double POINTS_PER_IN = POINTS_PER_INCH;
    constexpr double PX_TO_CM = PIXELS_TO_CM;
    
    // Default margins
    constexpr double BOTTOM_MARGIN = DEFAULT_BOTTOM_MARGIN_MM;
    constexpr double SPECTRO_HEIGHT = DEFAULT_SPECTRO_HEIGHT_MM;
    
    // User interface colors
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
    
    // Default paths (to be replaced by relative or configurable paths)
    const QString DEFAULT_INPUT_FILE = DEFAULT_INPUT_FILENAME;
    const QString DEFAULT_OUTPUT_FOLDER_PATH = DEFAULT_OUTPUT_FOLDER;
    const QString DEFAULT_OUTPUT_FILE = DEFAULT_OUTPUT_FILENAME;
    const QString DEFAULT_PDF_OUTPUT = DEFAULT_PDF_FILENAME;
}

#endif // CONSTANTS_H