/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#include "spectral_fft.h"
#include "spectral_wav_processing.h"

/*---------------------------------------------------------------------
 * fft_init()
 *
 * Initializes FFT resources and allocates memory.
 *
 * Returns:
 *  - 0 on success, non-zero on error.
 *---------------------------------------------------------------------*/
int fft_init(int fft_size, int *fft_effective_size, fftw_plan *plan, double **in, fftw_complex **out)
{
    // Determine effective FFT size based on zero padding option
    #if USE_ZERO_PADDING
        *fft_effective_size = ZERO_PAD_SIZE;
    #else
        *fft_effective_size = fft_size;
    #endif
    
    // Calculate number of frequency bins
    int num_bins = (*fft_effective_size) / 2 + 1;
    
    // Allocate input buffer
    *in = (double *)fftw_malloc(sizeof(double) * (*fft_effective_size));
    if (*in == NULL) {
        fprintf(stderr, "Error: Unable to allocate FFT input buffer.\n");
        return 1;
    }
    
    // Allocate output buffer
    *out = (fftw_complex *)fftw_malloc(sizeof(fftw_complex) * num_bins);
    if (*out == NULL) {
        fprintf(stderr, "Error: Unable to allocate FFT output buffer.\n");
        fftw_free(*in);
        *in = NULL;
        return 2;
    }
    
    // Create FFT plan
    *plan = fftw_plan_dft_r2c_1d(*fft_effective_size, *in, *out, FFTW_ESTIMATE);
    if (*plan == NULL) {
        fprintf(stderr, "Error: Unable to create FFT plan.\n");
        fftw_free(*in);
        fftw_free(*out);
        *in = NULL;
        *out = NULL;
        return 3;
    }
    
    printf(" - Initialized FFT with size %d (effective size %d, %d frequency bins)\n", 
           fft_size, *fft_effective_size, num_bins);
           
    return 0;
}

/*---------------------------------------------------------------------
 * fft_cleanup()
 *
 * Frees FFT resources.
 *---------------------------------------------------------------------*/
void fft_cleanup(fftw_plan plan, double *in, fftw_complex *out)
{
    if (plan) fftw_destroy_plan(plan);
    if (in) fftw_free(in);
    if (out) fftw_free(out);
}

/*---------------------------------------------------------------------
 * compute_spectrogram()
 *
 * Computes the spectrogram matrix from an audio signal.
 * Uses the exact overlap value provided by the user without adjustment.
 *
 * Returns:
 *  - 0 on success, non-zero on error.
 *---------------------------------------------------------------------*/
int compute_spectrogram(double *signal, int total_samples, int sample_rate,
                         int fft_size, int overlap_preset, double bins_per_second,
                         double min_freq, double max_freq,
                         SpectrogramData *spectro_data)
{
    // Initialize FFT
    int fft_effective_size;
    fftw_plan plan;
    double *in;
    fftw_complex *out;
    
    if (fft_init(fft_size, &fft_effective_size, &plan, &in, &out) != 0) {
        return 1;
    }
    
    // Calculer la valeur d'overlap basée sur le préréglage
    double overlap_value;
    switch(overlap_preset) {
        case 0: // Low
            overlap_value = OVERLAP_PRESET_LOW;
            printf(" - Using low overlap preset: %.4f\n", overlap_value);
            break;
        case 2: // High
            overlap_value = OVERLAP_PRESET_HIGH;
            printf(" - Using high overlap preset: %.4f\n", overlap_value);
            break;
        default: // Medium (default)
            overlap_value = OVERLAP_PRESET_MEDIUM;
            printf(" - Using medium overlap preset: %.4f\n", overlap_value);
            break;
    }
    
    // Calculate step size based on bins per second
    int step = (int)(sample_rate / bins_per_second);
    printf(" - Using bins/s: %.2f (hop size: %d samples)\n",
           bins_per_second, step);
    
    // Calculer l'overlap effectif pour information
    double effective_overlap = 1.0 - ((double)step / fft_size);
    printf(" - Resulting effective overlap: %.4f\n", effective_overlap);
    
    if (step < 1) step = 1;
    
    // Calculate number of windows
    int num_windows = (total_samples - fft_size) / step + 1;
    if (num_windows <= 0) {
        fprintf(stderr, "Error: Signal too short for FFT size.\n");
        fft_cleanup(plan, in, out);
        return 2;
    }
    
    // Calculate number of frequency bins
    int num_bins = fft_effective_size / 2 + 1;
    double freq_resolution = sample_rate / (double)fft_effective_size;
    
    // Allocate memory for spectrogram data
    double *spectrogram = (double *)malloc(num_windows * num_bins * sizeof(double));
    if (spectrogram == NULL) {
        fprintf(stderr, "Error: Unable to allocate memory for spectrogram.\n");
        fft_cleanup(plan, in, out);
        return 3;
    }
    
    // Reset global max
    double global_max = 0.0;
    
    // Calculate frequency bin indices from user-specified frequency range
    int index_min = (int)ceil(min_freq / freq_resolution);
    int index_max = (int)floor(max_freq / freq_resolution);
    
    // Validate bin indices
    if (index_min < 0) index_min = 0;
    if (index_max > num_bins - 1) index_max = num_bins - 1;
    if (index_min >= index_max) {
        fprintf(stderr, "Warning: Min frequency index (%d) >= max frequency index (%d). Adjusting.\n", 
               index_min, index_max);
        index_min = 0;
        index_max = num_bins - 1;
    }
    
    printf(" - Computing spectrogram: %d windows, %d frequency bins\n", num_windows, num_bins);
    printf(" - Using overlap preset %d (value: %.4f, step size: %d samples)\n",
           overlap_preset, overlap_value, step);
    printf(" - Frequency range: %.2f Hz to %.2f Hz (bins %d to %d)\n",
           min_freq, max_freq, index_min, index_max);
    
    // Compute spectrogram
    for (int w = 0; w < num_windows; w++) {
        int start_index = w * step;
        
        // Copy signal chunk to FFT input buffer with zero padding if needed
        for (int i = 0; i < fft_size; i++) {
            if (start_index + i < total_samples) {
                in[i] = signal[start_index + i];
            } else {
                in[i] = 0.0;
            }
        }
        
        // Zero-pad the rest of the buffer if needed
        for (int i = fft_size; i < fft_effective_size; i++) {
            in[i] = 0.0;
        }
        
        // Apply window function
        apply_hann_window(in, fft_size);
        
        // Execute FFT
        fftw_execute(plan);
        
        // Calculate magnitude for each frequency bin
        for (int b = 0; b < num_bins; b++) {
            double real = out[b][0];
            double imag = out[b][1];
            double magnitude = sqrt(real * real + imag * imag);
            
            spectrogram[w * num_bins + b] = magnitude;
            
            // Update global maximum
            if (magnitude > global_max) {
                global_max = magnitude;
            }
        }
    }
    
    // Populate spectrogram data structure
    spectro_data->data = spectrogram;
    spectro_data->num_windows = num_windows;
    spectro_data->num_bins = num_bins;
    spectro_data->index_min = index_min;
    spectro_data->index_max = index_max;
    spectro_data->global_max = global_max;
    
    // Clean up FFT resources
    fft_cleanup(plan, in, out);
    
    return 0;
}

/*---------------------------------------------------------------------
 * apply_image_processing()
 *
 * Applies various image processing techniques to the spectrogram data.
 * Follows the same sequence of operations as the original code for
 * intensity computation and mapping.
 *---------------------------------------------------------------------*/
void apply_image_processing(SpectrogramData *spectro_data, 
                           double dynamic_range_db, double gamma_correction,
                           int enable_dither, double contrast_factor)
{
    int num_windows = spectro_data->num_windows;
    int num_bins = spectro_data->num_bins;
    int index_min = spectro_data->index_min;
    int index_max = spectro_data->index_max;
    double global_max = spectro_data->global_max;
    double *spectrogram = spectro_data->data;
    
    // Validate parameters
    if (dynamic_range_db <= 0.0) dynamic_range_db = DYNAMIC_RANGE_DB;
    if (gamma_correction <= 0.0) gamma_correction = GAMMA_CORRECTION;
    if (contrast_factor <= 0.0) contrast_factor = CONTRAST_FACTOR;
    
    printf(" - Applying image processing:\n");
    printf("   - Dynamic range: %.2f dB\n", dynamic_range_db);
    printf("   - Gamma correction: %.2f\n", gamma_correction);
    printf("   - Contrast factor: %.2f\n", contrast_factor);
    printf("   - Dithering: %s\n", enable_dither ? "enabled" : "disabled");
    
    // Initialize seed for dithering if enabled
    if (enable_dither) {
        srand((unsigned int)time(NULL));
    }
    
    // Process each pixel in the spectrogram following original algorithm
    for (int w = 0; w < num_windows; w++) {
        for (int b = index_min; b <= index_max; b++) {
            double magnitude = spectrogram[w * num_bins + b];
            double intensity = 0.0;
            double epsilon = 1e-10; // Prevent log of zero
            
            // Apply log amplitude scaling if enabled
            if (USE_LOG_AMPLITUDE) {
                double dB = 20.0 * log10(magnitude + epsilon);
                double max_dB = 20.0 * log10(global_max + epsilon);
                double min_dB = max_dB - dynamic_range_db;
                intensity = (dB - min_dB) / (max_dB - min_dB);
                
                // Clamp to [0, 1]
                if (intensity < 0.0) intensity = 0.0;
                if (intensity > 1.0) intensity = 1.0;
            } else {
                // Linear normalization
                intensity = magnitude / global_max;
            }
            
            // Apply gamma correction
            if (gamma_correction != 1.0) {
                intensity = pow(intensity, 1.0 / gamma_correction);
            }
            
            // Invert intensity (1.0 = white, 0.0 = black)
            double inverted_intensity = 1.0 - intensity;
            
            // Quantize to 0-255 range
            double quantized = inverted_intensity * 255.0;
            
            // Apply dithering if enabled
            if (enable_dither) {
                double dither = ((double)rand() / (double)RAND_MAX) - 0.5;
                quantized += dither;
            }
            
            // Clamp after dithering
            if (quantized < 0.0) quantized = 0.0;
            if (quantized > 255.0) quantized = 255.0;
            
            // Convert back to 0-1 range
            double final_intensity = quantized / 255.0;
            
            // Apply contrast enhancement
            final_intensity = (final_intensity - 0.5) * contrast_factor + 0.5;
            
            // Final clamp
            if (final_intensity < 0.0) final_intensity = 0.0;
            if (final_intensity > 1.0) final_intensity = 1.0;
            
            // Store processed value in the spectrogram
            spectrogram[w * num_bins + b] = final_intensity;
        }
    }
}
