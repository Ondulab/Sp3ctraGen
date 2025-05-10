/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#include "spectral_wav_processing.h"

/*---------------------------------------------------------------------
 * load_wav_file()
 *
 * Loads audio from a WAV file for the exact specified duration.
 * If a non-zero duration is specified, only that amount is loaded.
 * If normalize is set to 1, the audio will be normalized to a maximum amplitude of 1.0.
 *
 * Returns:
 *  - 0 on success, non-zero on error.
 *---------------------------------------------------------------------*/
int load_wav_file(const char *filename, double **signal, int *num_samples, int *sample_rate, double duration, int normalize)
{
    SNDFILE *sf;
    SF_INFO info;
    
    // Initialize info structure
    memset(&info, 0, sizeof(info));
    
    // Open sound file for reading
    sf = sf_open(filename, SFM_READ, &info);
    if (sf == NULL) {
        fprintf(stderr, "Error: Could not open file %s: %s\n", filename, sf_strerror(NULL));
        return 1;
    }
    
    printf("File Info:\n");
    printf(" - Sample rate: %d Hz\n", info.samplerate);
    printf(" - Channels: %d\n", info.channels);
    printf(" - Format: %d\n", info.format);
    printf(" - Total frames: %lld\n", (long long)info.frames);
    printf(" - Duration: %.2f seconds\n", (double)info.frames / info.samplerate);
    
    // Determine frames to read based on requested duration
    int frames_to_read = 0;
    if (duration > 0) {
        frames_to_read = (int)(duration * info.samplerate);
        if (frames_to_read > info.frames) {
            frames_to_read = info.frames;
            printf(" - Requested duration exceeds file duration, reading entire file.\n");
        } else {
            printf(" - Loading %.2f seconds from WAV file.\n", duration);
        }
    } else {
        frames_to_read = info.frames;
        printf(" - No duration specified, reading entire file.\n");
    }
    
    // Allocate memory for the signal
    *signal = (double *)malloc(frames_to_read * sizeof(double));
    if (*signal == NULL) {
        sf_close(sf);
        fprintf(stderr, "Error: Memory allocation failed for audio signal.\n");
        return 2;
    }
    
    // If the file has multiple channels, we'll need a buffer for reading
    double *buffer = NULL;
    if (info.channels > 1) {
        buffer = (double *)malloc(frames_to_read * info.channels * sizeof(double));
        if (buffer == NULL) {
            free(*signal);
            sf_close(sf);
            fprintf(stderr, "Error: Memory allocation failed for channel buffer.\n");
            return 3;
        }
        
        // Read frames into buffer
        sf_count_t frames_read = sf_readf_double(sf, buffer, frames_to_read);
        
        // Mix down to mono by averaging channels
        printf(" - Mixing down %d channels to mono\n", info.channels);
        for (int i = 0; i < frames_read; i++) {
            double sum = 0;
            for (int j = 0; j < info.channels; j++) {
                sum += buffer[i * info.channels + j];
            }
            (*signal)[i] = sum / info.channels;
        }
        
        free(buffer);
        *num_samples = frames_read;
    } else {
        // Mono file, read directly
        *num_samples = sf_readf_double(sf, *signal, frames_to_read);
    }
    
    // Set the sample rate
    *sample_rate = info.samplerate;
    
    // Close the file
    sf_close(sf);
    
    // Normalize the audio if requested
    if (normalize) {
        printf(" - Normalizing audio to maximum amplitude of 1.0\n");
        double max_abs = 0.0;
        for (int i = 0; i < *num_samples; i++) {
            if (fabs((*signal)[i]) > max_abs) {
                max_abs = fabs((*signal)[i]);
            }
        }
        if (max_abs > 0.0) {
            printf(" - Maximum amplitude before normalization: %.6f\n", max_abs);
            for (int i = 0; i < *num_samples; i++) {
                (*signal)[i] /= max_abs;
            }
        }
    } else {
        printf(" - Skipping normalization (preserving original amplitude)\n");
        
        // Optionally, we could print the maximum amplitude for information
        double max_abs = 0.0;
        for (int i = 0; i < *num_samples; i++) {
            if (fabs((*signal)[i]) > max_abs) {
                max_abs = fabs((*signal)[i]);
            }
        }
        printf(" - Maximum amplitude: %.6f\n", max_abs);
    }
    
    printf(" - Loaded %d samples at %d Hz (%.2f seconds)\n", 
           *num_samples, *sample_rate, (double)*num_samples / *sample_rate);
    
    return 0;
}

/*---------------------------------------------------------------------
 * generate_sine_wave()
 *
 * Generates a sine wave signal with specified parameters.
 *---------------------------------------------------------------------*/
void generate_sine_wave(double *signal, int total_samples, double sample_rate, double frequency, double amplitude)
{
    double phase_increment = 2.0 * M_PI * frequency / sample_rate;
    double phase = 0.0;
    
    for (int i = 0; i < total_samples; i++) {
        signal[i] = amplitude * sin(phase);
        phase += phase_increment;
        
        // Keep phase in a reasonable range to avoid floating point precision issues
        if (phase > 2.0 * M_PI) {
            phase -= 2.0 * M_PI;
        }
    }
}

/*---------------------------------------------------------------------
 * apply_hann_window()
 *
 * Applies a Hann window to the input buffer.
 *---------------------------------------------------------------------*/
void apply_hann_window(double *buffer, int size)
{
    for (int i = 0; i < size; i++) {
        // Hann window: 0.5 * (1 - cos(2π * n / (N - 1)))
        double window = 0.5 * (1.0 - cos(2.0 * M_PI * i / (size - 1)));
        buffer[i] *= window;
    }
}

/*---------------------------------------------------------------------
 * apply_high_freq_boost_filter()
 *
 * Applies a simple high-frequency boost filter to the signal.
 * The filter is a first-order high-shelf filter with parameter alpha.
 *---------------------------------------------------------------------*/
void apply_high_freq_boost_filter(double *signal, int num_samples, double alpha)
{
    printf(" - Applying high frequency boost (alpha = %.2f)\n", alpha);
    
    if (num_samples < 2) return;
    
    double prev_sample = signal[0];
    for (int i = 1; i < num_samples; i++) {
        double current_sample = signal[i];
        signal[i] = current_sample - alpha * prev_sample;
        prev_sample = current_sample;
    }
}

/*---------------------------------------------------------------------
 * design_highpass_filter()
 *
 * Designs a digital high-pass filter with specified parameters.
 * Implements a simple Butterworth high-pass filter.
 *---------------------------------------------------------------------*/
void design_highpass_filter(double cutoff_freq, int order, double sample_rate, double *a, double *b)
{
    // Normalized cutoff frequency (0 to 1, where 1 is Nyquist)
    double w0 = 2.0 * cutoff_freq / sample_rate;
    
    // Limit w0 to avoid instabilities
    if (w0 < 0.001) w0 = 0.001;
    if (w0 > 0.999) w0 = 0.999;
    
    // Simple first-order high-pass filter design
    // This is a simplified version - a real implementation would use more complex filter design
    
    double alpha = cos(M_PI * w0) / (1.0 + sin(M_PI * w0));
    
    // Initialize filter coefficients
    a[0] = 1.0;
    a[1] = -alpha;
    b[0] = (1.0 + alpha) / 2.0;
    b[1] = -(1.0 + alpha) / 2.0;
    
    printf(" - Designed high-pass filter: cutoff = %.2f Hz, order = %d\n", cutoff_freq, order);
}

/*---------------------------------------------------------------------
 * apply_highpass_filter()
 *
 * Applies the designed high-pass filter to the signal.
 *---------------------------------------------------------------------*/
void apply_highpass_filter(double *signal, int num_samples, double *a, double *b, int filter_order)
{
    // For simplicity, implement a basic direct form I difference equation
    // This is a simplified version - a real implementation would handle all filter orders
    
    double *filtered = (double *)malloc(num_samples * sizeof(double));
    if (filtered == NULL) {
        fprintf(stderr, "Error: Memory allocation failed for filtered signal.\n");
        return;
    }
    
    // Initialize filter state
    double x_prev = 0.0;
    double y_prev = 0.0;
    
    // Apply filter
    for (int i = 0; i < num_samples; i++) {
        double x = signal[i];
        double y = (b[0] * x + b[1] * x_prev - a[1] * y_prev) / a[0];
        
        filtered[i] = y;
        
        // Update state
        x_prev = x;
        y_prev = y;
    }
    
    // Copy filtered signal back to original
    memcpy(signal, filtered, num_samples * sizeof(double));
    
    free(filtered);
    
    printf(" - Applied high-pass filter to signal\n");
}

/*---------------------------------------------------------------------
 * apply_separable_box_blur()
 *
 * Applies a separable box blur to the image.
 *---------------------------------------------------------------------*/
void apply_separable_box_blur(cairo_surface_t *surface, int radius)
{
    if (radius <= 0) return;
    
    cairo_surface_flush(surface);
    int width = cairo_image_surface_get_width(surface);
    int height = cairo_image_surface_get_height(surface);
    int stride = cairo_image_surface_get_stride(surface);
    unsigned char *data = cairo_image_surface_get_data(surface);
    
    unsigned char *temp = (unsigned char *)malloc(height * stride);
    if (temp == NULL) {
        fprintf(stderr, "Error: Memory allocation failed for blur buffer.\n");
        return;
    }
    
    /* Horizontal pass */
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int sumA = 0, sumR = 0, sumG = 0, sumB = 0;
            int count = 0;
            for (int k = -radius; k <= radius; k++) {
                int nx = x + k;
                if (nx < 0 || nx >= width) continue;
                unsigned char *p = data + y * stride + nx * 4;
                sumB += p[0];
                sumG += p[1];
                sumR += p[2];
                sumA += p[3];
                count++;
            }
            unsigned char *pt = temp + y * stride + x * 4;
            pt[0] = (unsigned char)(sumB / count);
            pt[1] = (unsigned char)(sumG / count);
            pt[2] = (unsigned char)(sumR / count);
            pt[3] = (unsigned char)(sumA / count);
        }
    }
    
    /* Vertical pass */
    for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
            int sumA = 0, sumR = 0, sumG = 0, sumB = 0;
            int count = 0;
            for (int k = -radius; k <= radius; k++) {
                int ny = y + k;
                if (ny < 0 || ny >= height) continue;
                unsigned char *pt = temp + ny * stride + x * 4;
                sumB += pt[0];
                sumG += pt[1];
                sumR += pt[2];
                sumA += pt[3];
                count++;
            }
            unsigned char *pd = data + y * stride + x * 4;
            pd[0] = (unsigned char)(sumB / count);
            pd[1] = (unsigned char)(sumG / count);
            pd[2] = (unsigned char)(sumR / count);
            pd[3] = (unsigned char)(sumA / count);
        }
    }
    
    free(temp);
    cairo_surface_mark_dirty(surface);
}
