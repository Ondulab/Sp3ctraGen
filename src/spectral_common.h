#ifndef SPECTRAL_COMMON_H
#define SPECTRAL_COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <fftw3.h>
#include <cairo/cairo.h>
#include <sndfile.h>
#include <time.h>
#include "../include/spectral_generator.h"

/* ---------------------------------------------------------------------
   Fallback macros: if a configuration value is zero (or not valid),
   the corresponding default from the original #defines is used.
--------------------------------------------------------------------- */
#define DEFAULT_INT(cfgVal, defaultVal)    (((cfgVal) > 0) ? (cfgVal) : (defaultVal))
#define DEFAULT_DBL(cfgVal, defaultVal)    (((cfgVal) > 0.0) ? (cfgVal) : (defaultVal))
#define DEFAULT_BOOL(cfgVal, defaultVal)   (((cfgVal) == 0 || (cfgVal) == 1) ? (cfgVal) : (defaultVal))
#define DEFAULT_STR(cfgVal, defaultVal)    (((cfgVal) != NULL && (cfgVal)[0] != '\0') ? (cfgVal) : (defaultVal))
#define PIXELS_TO_CM                       0.00317   // Conversion cm en pixels à 800 DPI: 1 cm = 315 pixels, donc 1 pixel = 0.00317 cm

/* -------------------------- */
/* Default parameters         */
/* -------------------------- */
#define DEFAULT_DURATION        4.0
#define DEFAULT_SAMPLE_RATE     192000
#define DEFAULT_FFT_SIZE        8192
#define DEFAULT_OVERLAP         0.85
#define DEFAULT_MIN_FREQ        65
#define DEFAULT_MAX_FREQ        16640.0

/* Default file paths for debugging */
#define DEFAULT_INPUT_FILE      "/Users/zhonx/Documents/Workspaces/Workspace_Xcode/CISYNTH_App/sample.wav"
#define DEFAULT_OUTPUT_FOLDER   "/Users/zhonx/Downloads"
#define DEFAULT_OUTPUT_FILE     "/Users/zhonx/Downloads/spectrogram.png"
#define DEFAULT_PDF_OUTPUT      "/Users/zhonx/Downloads/spectrogram.pdf"

/* Page dimensions in pixels at 800 DPI */
#define A4_WIDTH               6613.0
#define A4_HEIGHT              9354.0
#define A3_WIDTH               13228.0
#define A3_HEIGHT              9354.0
#define TOP_MARGIN             1600.0
#define DEFAULT_BOTTOM_MARGIN  1600.0
#define DEFAULT_SPECTRO_HEIGHT 5334.0

/* Page dimensions in millimeters */
#define A4_WIDTH_MM            210.0
#define A4_HEIGHT_MM           297.0
#define A3_WIDTH_MM            420.0
#define A3_HEIGHT_MM           297.0

/* Conversion factors */
#define MM_TO_PIXELS           31.5    // Conversion mm en pixels à 800 DPI (800/25.4)
#define MM_TO_POINTS           2.83    // Conversion mm en points (72/25.4)
#define POINTS_PER_INCH        72.0    // PDF utilise 72 points par pouce

/* Image processing parameters */
#define USE_LOG_AMPLITUDE      1
#define USE_LOG_FREQUENCY      1
#define DYNAMIC_RANGE_DB       60.0
#define GAMMA_CORRECTION       0.8
#define ENABLE_DITHERING       0
#define CONTRAST_FACTOR        1.9
#define SCALE_FACTOR           1.0
#define ENABLE_BLUR            0
#define BLUR_RADIUS            5
#define ENABLE_HIGH_BOOST      1
#define HIGH_BOOST_ALPHA       0.99

/* FFT-related options */
#define USE_ZERO_PADDING         1    /* Use zero-padding solution */
#define USE_HYBRID_FFT           0    /* Use hybrid FFT for low frequencies */
#define USE_MODIFIED_LOG_MAPPING 0    /* Use modified logarithmic mapping */

#if USE_ZERO_PADDING
    #define ZERO_PAD_SIZE 65535
#endif

#if USE_HYBRID_FFT
    #define HYBRID_LOW_FREQ_THRESHOLD 500.0
    #define HYBRID_FFT_SIZE 65535
#endif

#if USE_MODIFIED_LOG_MAPPING
    #define LOG_MAPPING_EXPONENT 0.7
#endif

/* Exit status */
#ifndef EXIT_SUCCESS
    #define EXIT_SUCCESS 0
#endif

#ifndef EXIT_FAILURE
    #define EXIT_FAILURE 1
#endif

#endif /* SPECTRAL_COMMON_H */
