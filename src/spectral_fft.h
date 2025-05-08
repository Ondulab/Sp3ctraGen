#ifndef SPECTRAL_FFT_H
#define SPECTRAL_FFT_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <fftw3.h>
#include <time.h>
#include "spectral_common.h"

// Structure to hold spectrogram data
typedef struct {
    double *data;           // The spectrogram matrix
    int num_windows;        // Number of time windows
    int num_bins;           // Number of frequency bins
    int index_min;          // Minimum frequency bin index for the specified range
    int index_max;          // Maximum frequency bin index for the specified range
    double global_max;      // Maximum magnitude value in the spectrogram
} SpectrogramData;

// Function prototypes
int fft_init(int fft_size, int *fft_effective_size, fftw_plan *plan, double **in, fftw_complex **out);
void fft_cleanup(fftw_plan plan, double *in, fftw_complex *out);
int compute_spectrogram(double *signal, int total_samples, int sample_rate, 
                       int fft_size, double overlap, 
                       double min_freq, double max_freq,
                       SpectrogramData *spectro_data);
void apply_image_processing(SpectrogramData *spectro_data, 
                           double dynamic_range_db, double gamma_correction,
                           int enable_dither, double contrast_factor);

#endif /* SPECTRAL_FFT_H */
