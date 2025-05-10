/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef SPECTRAL_WAV_PROCESSING_H
#define SPECTRAL_WAV_PROCESSING_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sndfile.h>
#include <cairo/cairo.h>
#include "spectral_common.h"

// Function prototypes
int load_wav_file(const char *filename, double **signal, int *num_samples, int *sample_rate, double duration, int normalize);
void generate_sine_wave(double *signal, int total_samples, double sample_rate, double frequency, double amplitude);
void apply_hann_window(double *buffer, int size);
void apply_high_freq_boost_filter(double *signal, int num_samples, double alpha);
void design_highpass_filter(double cutoff_freq, int order, double sample_rate, double *a, double *b);
void apply_highpass_filter(double *signal, int num_samples, double *a, double *b, int filter_order);
void apply_separable_box_blur(cairo_surface_t *surface, int radius);

#endif /* SPECTRAL_WAV_PROCESSING_H */
