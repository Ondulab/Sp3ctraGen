/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

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
#include "../include/SharedConstants.h"

/* ---------------------------------------------------------------------
   Fallback macros: if a configuration value is zero (or not valid),
   the corresponding default from the original #defines is used.
--------------------------------------------------------------------- */
#define DEFAULT_INT(cfgVal, defaultVal)    (((cfgVal) > 0) ? (cfgVal) : (defaultVal))
#define DEFAULT_DBL(cfgVal, defaultVal)    (((cfgVal) > 0.0) ? (cfgVal) : (defaultVal))
#define DEFAULT_BOOL(cfgVal, defaultVal)   (((cfgVal) == 0 || (cfgVal) == 1) ? (cfgVal) : (defaultVal))
#define DEFAULT_STR(cfgVal, defaultVal)    (((cfgVal) != NULL && (cfgVal)[0] != '\0') ? (cfgVal) : (defaultVal))

/* Page dimensions in pixels at 800 DPI */
#define A4_WIDTH               (A4_WIDTH_MM * MM_TO_PIXELS)
#define A4_HEIGHT              (A4_HEIGHT_MM * MM_TO_PIXELS)
#define A3_WIDTH               (A3_WIDTH_MM * MM_TO_PIXELS)
#define A3_HEIGHT              (A3_HEIGHT_MM * MM_TO_PIXELS)
#define TOP_MARGIN             (1600.0/(800/PRINTER_DPI))
#define DEFAULT_BOTTOM_MARGIN  (DEFAULT_BOTTOM_MARGIN_MM * MM_TO_PIXELS)
#define DEFAULT_SPECTRO_HEIGHT (DEFAULT_SPECTRO_HEIGHT_MM * MM_TO_PIXELS)

/* Image processing parameters */
#define USE_LOG_AMPLITUDE      1
#define USE_LOG_FREQUENCY      1
#define SCALE_FACTOR           1.0
#define ENABLE_BLUR            0
#define BLUR_RADIUS            5

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
