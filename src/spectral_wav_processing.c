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
 * Implements a simple high-pass filter based on standard difference equation.
 *---------------------------------------------------------------------*/
void design_highpass_filter(double cutoff_freq, int order, double sample_rate, double *a, double *b)
{
    // Validation et logs détaillés pour le débogage
    printf("=== FILTRE PASSE-HAUT DEBUG ===\n");
    printf("design_highpass_filter - cutoff_freq reçue: %.2f Hz\n", cutoff_freq);
    printf("design_highpass_filter - order reçu: %d\n", order);
    printf("design_highpass_filter - sample_rate reçu: %.2f Hz\n", sample_rate);
    
    if (cutoff_freq <= 0.0) {
        printf("Warning: Invalid cutoff frequency (%.2f Hz), using default of 100 Hz\n", cutoff_freq);
        cutoff_freq = 100.0;
    }
    
    if (order < 1 || order > 8) {
        printf("Warning: Invalid filter order (%d), using order = 2\n", order);
        order = 2;
    }
    
    // Utiliser une implémentation très simple mais robuste
    // Ceci est un filtre à réponse impulsionnelle infinie (IIR) du premier ordre
    
    // Calculer le coefficient alpha (facteur de lissage) à partir de la fréquence de coupure
    // alpha est proche de 1.0 pour des fréquences de coupure basses
    double rc = 1.0 / (2.0 * M_PI * cutoff_freq);
    double dt = 1.0 / sample_rate;
    double alpha = rc / (rc + dt);
    
    // Limiter alpha pour éviter l'instabilité
    if (alpha < 0.1) alpha = 0.1;
    if (alpha > 0.95) alpha = 0.95;
    
    // Filtre passe-haut de premier ordre très simple: y[n] = alpha * (y[n-1] + x[n] - x[n-1])
    a[0] = 1.0;
    a[1] = -alpha;
    b[0] = alpha;
    b[1] = -alpha;
    a[2] = 0.0;  // Non utilisé pour un filtre du premier ordre
    b[2] = 0.0;  // Non utilisé pour un filtre du premier ordre
    
    printf(" - Designed simple high-pass filter: cutoff = %.2f Hz, alpha = %.4f\n",
           cutoff_freq, alpha);
    printf(" - Filter coefficients: a=[%.4f, %.4f], b=[%.4f, %.4f]\n",
           a[0], a[1], b[0], b[1]);
}

/*---------------------------------------------------------------------
 * apply_highpass_filter()
 *
 * Applies a simple high-pass filter to the signal.
 * Implements the formula: y[n] = alpha * (y[n-1] + x[n] - x[n-1])
 * where alpha is a coefficient related to the cutoff frequency.
 *---------------------------------------------------------------------*/
void apply_highpass_filter(double *signal, int num_samples, double *a, double *b, int filter_order)
{
    // Validate order
    if (filter_order < 1 || filter_order > 8) {
        fprintf(stderr, "Warning: Invalid filter order (%d), using order = 2\n", filter_order);
        filter_order = 2;
    }
    
    // Extraire le coefficient alpha du filtre
    double alpha = b[0];  // b[0] contient alpha selon notre design du filtre
    
    printf(" - Applying simplified high-pass filter (alpha = %.4f)\n", alpha);
    
    // Mesurer l'amplitude maximale du signal avant filtrage
    double max_amplitude = 0.0;
    for (int i = 0; i < num_samples; i++) {
        double abs_val = fabs(signal[i]);
        if (abs_val > max_amplitude) {
            max_amplitude = abs_val;
        }
    }
    printf(" - Original signal max amplitude: %.6f\n", max_amplitude);
    
    // Créer une copie de travail du signal
    double *filtered = (double *)malloc(num_samples * sizeof(double));
    if (filtered == NULL) {
        fprintf(stderr, "Error: Memory allocation failed for filtered signal.\n");
        return;
    }
    
    // Copier le signal original
    memcpy(filtered, signal, num_samples * sizeof(double));
    
    // Nombre de passes pour simuler un ordre plus élevé
    int passes = filter_order;
    printf(" - Applying filter with %d passes for order %d\n", passes, filter_order);
    
    // Appliquer le filtre plusieurs fois pour simuler un ordre plus élevé
    for (int pass = 0; pass < passes; pass++) {
        double prev_x = filtered[0];  // Premier échantillon
        double prev_y = 0.0;          // Sortie précédente (initialisée à 0)
        
        // Premier échantillon (cas spécial)
        double y = alpha * filtered[0];
        filtered[0] = y;
        prev_y = y;
        
        // Appliquer le filtre: y[n] = alpha * (y[n-1] + x[n] - x[n-1])
        for (int i = 1; i < num_samples; i++) {
            double x = filtered[i];
            y = alpha * (prev_y + x - prev_x);
            
            // Mettre à jour les états
            prev_x = x;
            prev_y = y;
            
            // Éviter les instabilités numériques
            if (isnan(y) || isinf(y)) {
                y = 0.0;
            } else if (y > 10.0) {
                y = 10.0;
            } else if (y < -10.0) {
                y = -10.0;
            }
            
            filtered[i] = y;
        }
        
        printf(" - Pass %d completed\n", pass + 1);
    }
    
    // Vérifier l'amplitude après filtrage
    double max_filtered = 0.0;
    for (int i = 0; i < num_samples; i++) {
        double abs_val = fabs(filtered[i]);
        if (abs_val > max_filtered) {
            max_filtered = abs_val;
        }
    }
    printf(" - Filtered signal max amplitude: %.6f\n", max_filtered);
    
    // Normaliser le signal si nécessaire
    if (max_filtered > 0.0 &&
        (max_filtered < 0.01 * max_amplitude || max_filtered > 2.0 * max_amplitude)) {
        double normalize_factor = max_amplitude / max_filtered;
        printf(" - Normalizing output (factor = %.4f)\n", normalize_factor);
        
        for (int i = 0; i < num_samples; i++) {
            filtered[i] *= normalize_factor;
        }
    }
    
    // Copier le résultat filtré dans le signal original
    memcpy(signal, filtered, num_samples * sizeof(double));
    
    // Libérer la mémoire
    free(filtered);
    
    printf(" - Successfully applied high-pass filter to signal\n");
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

/*---------------------------------------------------------------------
 * normalize_wav_file()
 *
 * Normalizes an audio file by applying a multiplication factor and
 * saves the result to a new file.
 *
 * Parameters:
 *  - input_path: Path to the input WAV file
 *  - output_path: Path where the normalized WAV file will be saved
 *  - factor: The normalization factor to apply to each sample
 *
 * Returns:
 *  - 0 on success, non-zero on error.
 *---------------------------------------------------------------------*/
int normalize_wav_file(const char *input_path, const char *output_path, double factor)
{
    double *signal = NULL;
    int num_samples = 0;
    int sample_rate = 0;
    
    // Load the input file without normalizing it (normalize=0)
    if (load_wav_file(input_path, &signal, &num_samples, &sample_rate, 0, 0) != 0) {
        fprintf(stderr, "Error: Failed to load input audio file for normalization\n");
        return 1;
    }
    
    printf("Normalizing audio file with factor: %.6f\n", factor);
    
    // Apply the normalization factor
    for (int i = 0; i < num_samples; i++) {
        signal[i] *= factor;
    }
    
    // Save the normalized signal to a new WAV file
    SF_INFO info;
    SNDFILE *sf;
    
    // Configure output format
    memset(&info, 0, sizeof(info));
    info.samplerate = sample_rate;
    info.channels = 1;  // Always mono
    info.format = SF_FORMAT_WAV | SF_FORMAT_PCM_16;  // 16-bit PCM WAV
    
    // Open output file
    sf = sf_open(output_path, SFM_WRITE, &info);
    if (sf == NULL) {
        fprintf(stderr, "Error: Could not open output file %s: %s\n",
                output_path, sf_strerror(NULL));
        free(signal);
        return 2;
    }
    
    // Write normalized data
    sf_count_t frames_written = sf_write_double(sf, signal, num_samples);
    if (frames_written != num_samples) {
        fprintf(stderr, "Error: Could only write %lld of %d frames\n",
                (long long)frames_written, num_samples);
        sf_close(sf);
        free(signal);
        return 3;
    }
    
    // Cleanup
    sf_close(sf);
    free(signal);
    
    printf("Successfully created normalized audio file: %s\n", output_path);
    return 0;
}
