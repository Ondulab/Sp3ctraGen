/***********************************************************************
 * spectrogram.c
 *
 * Project: Audio Synthesis and Synchronized Spectrogram Generation
 * Target: macOS (Xcode)
 * Language: C (Allman style, code and comments in English)
 *
 * This file implements a spectrogram generator that reads a WAV file,
 * computes its FFT using FFTW3 and draws a PNG image using Cairo.
 *
 * Compilation example:
 *   gcc spectrogram.c -o spectrogram -lfftw3 -lcairo -lm -lsndfile
 *
 * Author: [Your Name]
 * Date: [Date]
 ***********************************************************************/

#include <unistd.h>  // For getcwd
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include <fftw3.h>
#include <cairo/cairo.h>
#include <sndfile.h>
#include "spectral_generator.h"

/* ---------------------------------------------------------------------
   Fallback macros: if a configuration value is zero (or not valid),
   the corresponding default from the original #defines is used.
--------------------------------------------------------------------- */
#define DEFAULT_INT(cfgVal, defaultVal)    (((cfgVal) > 0) ? (cfgVal) : (defaultVal))
#define DEFAULT_DBL(cfgVal, defaultVal)    (((cfgVal) > 0.0) ? (cfgVal) : (defaultVal))
#define DEFAULT_BOOL(cfgVal, defaultVal)   (((cfgVal) == 0 || (cfgVal) == 1) ? (cfgVal) : (defaultVal))

/* -------------------------- */
/* Default parameters         */
/* (Originally defined as macros) */
#define DEFAULT_DURATION        4.0
#define DEFAULT_SAMPLE_RATE     192000
#define DEFAULT_FFT_SIZE        8192
#define DEFAULT_OVERLAP         0.85
#define DEFAULT_MIN_FREQ        65
#define DEFAULT_MAX_FREQ        16640.0
#define BASE_WIDTH              7014.0
#define BASE_HEIGHT             4962.0
#define TOP_MARGIN              600.0
#define BOTTOM_MARGIN           600.0
#define USE_LOG_AMPLITUDE       1
#define USE_LOG_FREQUENCY       1
#define DYNAMIC_RANGE_DB        60.0
#define GAMMA_CORRECTION        0.8
#define ENABLE_DITHERING        0
#define CONTRAST_FACTOR         1.9
#define SCALE_FACTOR            1.0
#define ENABLE_BLUR             0
#define BLUR_RADIUS             5
#define ENABLE_HIGH_BOOST       1
#define HIGH_BOOST_ALPHA        0.99

/* -------------------------- */
/* Other compile-time options */
/* -------------------------- */
#define USE_ZERO_PADDING          1   /* Use zero-padding solution */
#define USE_HYBRID_FFT            0   /* Use hybrid FFT for low frequencies */
#define USE_MODIFIED_LOG_MAPPING  0   /* Use modified logarithmic mapping */
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

/* ---------------------------------------------------------------------
   Function prototypes for internal routines
--------------------------------------------------------------------- */
int load_wav_file(const char *filename, double **signal, int *num_samples, int *sample_rate, double duration);
void generate_sine_wave(double *signal, int total_samples, double sample_rate, double frequency, double amplitude);
void apply_hann_window(double *buffer, int size);
void apply_separable_box_blur(cairo_surface_t *surface, int radius);
void apply_high_freq_boost_filter(double *signal, int num_samples, double alpha);

/*---------------------------------------------------------------------
 * spectral_generator()
 *
 * Generates a spectrogram PNG image.
 * Parameters are extracted from the SpectrogramSettings structure.
 * If any parameter is zero, the default value is used.
 *
 * Returns:
 *  - EXIT_SUCCESS on success, EXIT_FAILURE on error.
 *---------------------------------------------------------------------*/
int spectral_generator(const SpectrogramSettings *cfg,
                       const char *inputFile,
                       const char *outputFile)
{
    /* Copy configuration and fallback to defaults if necessary */
    SpectrogramSettings s = *cfg;
    int     fft_size        = DEFAULT_INT(s.fftSize,        DEFAULT_FFT_SIZE);
    double  overlap         = DEFAULT_DBL(s.overlap,        DEFAULT_OVERLAP);
    double  minFreq         = DEFAULT_DBL(s.minFreq,        DEFAULT_MIN_FREQ);
    double  maxFreq         = DEFAULT_DBL(s.maxFreq,        DEFAULT_MAX_FREQ);
    double  duration        = DEFAULT_DBL(s.duration,       DEFAULT_DURATION);
    int     sample_rate     = DEFAULT_INT(s.sampleRate,     DEFAULT_SAMPLE_RATE);
    double  dynamicRangeDB  = DEFAULT_DBL(s.dynamicRangeDB, DYNAMIC_RANGE_DB);
    double  gammaCorr       = DEFAULT_DBL(s.gammaCorrection, GAMMA_CORRECTION);
    int     enableDither    = DEFAULT_BOOL(s.enableDithering, ENABLE_DITHERING);
    double  contrastFactor  = DEFAULT_DBL(s.contrastFactor, CONTRAST_FACTOR);
    int     enableHighBoost = DEFAULT_BOOL(s.enableHighBoost, ENABLE_HIGH_BOOST);
    double  highBoostAlpha  = DEFAULT_DBL(s.highBoostAlpha, HIGH_BOOST_ALPHA);

    printf("Spectrogram generation parameters:\n");
    printf(" - FFT size: %d\n", fft_size);
    printf(" - Overlap: %f\n", overlap);
    printf(" - Min frequency: %f\n", minFreq);
    printf(" - Max frequency: %f\n", maxFreq);
    printf(" - Duration: %f\n", duration);
    printf(" - Sample rate: %d\n", sample_rate);
    printf(" - Dynamic range (dB): %f\n", dynamicRangeDB);
    printf(" - Gamma correction: %f\n", gammaCorr);
    printf(" - Dithering: %d\n", enableDither);
    printf(" - Contrast factor: %f\n", contrastFactor);
    printf(" - High boost: %d (alpha = %f)\n", enableHighBoost, highBoostAlpha);
    printf(" - Input file: %s\n", inputFile);
    printf(" - Output file: %s\n", outputFile);

    /* ------------------------------ */
    /* 1. Load audio signal from WAV  */
    /* ------------------------------ */
    int total_samples = 0;
    double *signal = NULL;
    if (load_wav_file(inputFile, &signal, &total_samples, &sample_rate, duration) != 0)
    {
        fprintf(stderr, "Error: Unable to load WAV file.\n");
        return EXIT_FAILURE;
    }

    /* Apply high frequency boost if enabled */
    if (enableHighBoost)
    {
        apply_high_freq_boost_filter(signal, total_samples, highBoostAlpha);
    }

    /* ------------------------------ */
    /* 2. FFT and Spectrogram Setup   */
    /* ------------------------------ */
    #if USE_ZERO_PADDING
        int fft_effective_size = ZERO_PAD_SIZE;
    #else
        int fft_effective_size = fft_size;
    #endif

    int num_bins = fft_effective_size / 2 + 1;
    double freq_resolution = sample_rate / (double)fft_effective_size;
    int step = (int)(fft_size * (1.0 - overlap));
    int num_windows = (total_samples - fft_size) / step + 1;

    double *spectrogram = (double *)malloc(num_windows * num_bins * sizeof(double));
    if (spectrogram == NULL)
    {
        fprintf(stderr, "Error: Unable to allocate memory for the spectrogram.\n");
        free(signal);
        return EXIT_FAILURE;
    }

    #if USE_ZERO_PADDING
        double *in_zp = (double *)fftw_malloc(sizeof(double) * fft_effective_size);
        fftw_complex *out_zp = (fftw_complex *)fftw_malloc(sizeof(fftw_complex) * num_bins);
        if (in_zp == NULL || out_zp == NULL)
        {
            fprintf(stderr, "Error: Unable to allocate FFTW buffers for zero-padding.\n");
            free(signal);
            free(spectrogram);
            return EXIT_FAILURE;
        }
        fftw_plan plan = fftw_plan_dft_r2c_1d(fft_effective_size, in_zp, out_zp, FFTW_ESTIMATE);
    #else
        double *in = (double *)fftw_malloc(sizeof(double) * fft_size);
        fftw_complex *out = (fftw_complex *)fftw_malloc(sizeof(fftw_complex) * num_bins);
        if (in == NULL || out == NULL)
        {
            fprintf(stderr, "Error: Unable to allocate FFTW buffers.\n");
            free(signal);
            free(spectrogram);
            return EXIT_FAILURE;
        }
        fftw_plan plan = fftw_plan_dft_r2c_1d(fft_size, in, out, FFTW_ESTIMATE);
    #endif

    #if USE_HYBRID_FFT
        int hybrid_fft_size = HYBRID_FFT_SIZE;
        int hybrid_num_bins = hybrid_fft_size / 2 + 1;
        double *hybrid_in = (double *)fftw_malloc(sizeof(double) * hybrid_fft_size);
        fftw_complex *hybrid_out = (fftw_complex *)fftw_malloc(sizeof(fftw_complex) * hybrid_num_bins);
        if (hybrid_in == NULL || hybrid_out == NULL)
        {
            fprintf(stderr, "Error: Unable to allocate hybrid FFTW buffers.\n");
            #if USE_ZERO_PADDING
                fftw_free(in_zp);
                fftw_free(out_zp);
            #else
                fftw_free(in);
                fftw_free(out);
            #endif
            free(signal);
            free(spectrogram);
            return EXIT_FAILURE;
        }
        fftw_plan hybrid_plan = fftw_plan_dft_r2c_1d(hybrid_fft_size, hybrid_in, hybrid_out, FFTW_ESTIMATE);
    #endif

    if (enableDither)
    {
        srand((unsigned int)time(NULL));
    }

    double global_max = 0.0;

    /* ------------------------------ */
    /* 3. Compute the Spectrogram     */
    /* ------------------------------ */
    for (int w = 0; w < num_windows; w++)
    {
        int start_index = w * step;

        #if USE_ZERO_PADDING
            for (int i = 0; i < fft_size; i++)
            {
                in_zp[i] = signal[start_index + i];
            }
            for (int i = fft_size; i < fft_effective_size; i++)
            {
                in_zp[i] = 0.0;
            }
            apply_hann_window(in_zp, fft_size);
        #else
            for (int i = 0; i < fft_size; i++)
            {
                in[i] = signal[start_index + i];
            }
            apply_hann_window(in, fft_size);
        #endif

        #if USE_ZERO_PADDING
            fftw_execute(plan);
        #else
            fftw_execute(plan);
        #endif

        for (int b = 0; b < num_bins; b++)
        {
            #if USE_ZERO_PADDING
                double real = out_zp[b][0];
                double imag = out_zp[b][1];
            #else
                double real = out[b][0];
                double imag = out[b][1];
            #endif
            double magnitude = sqrt(real * real + imag * imag);
            spectrogram[w * num_bins + b] = magnitude;
            if (magnitude > global_max)
            {
                global_max = magnitude;
            }
        }

        #if USE_HYBRID_FFT
            for (int i = 0; i < fft_size; i++)
            {
                hybrid_in[i] = signal[start_index + i];
            }
            for (int i = fft_size; i < hybrid_fft_size; i++)
            {
                hybrid_in[i] = 0.0;
            }
            apply_hann_window(hybrid_in, fft_size);
            fftw_execute(hybrid_plan);
            for (int b = 0; b < num_bins; b++)
            {
                double freq = b * (sample_rate / (double)fft_size);
                if (freq < HYBRID_LOW_FREQ_THRESHOLD)
                {
                    int hybrid_bin = (int)round(b * (hybrid_fft_size / (double)fft_size));
                    if (hybrid_bin >= hybrid_num_bins)
                    {
                        hybrid_bin = hybrid_num_bins - 1;
                    }
                    double real = hybrid_out[hybrid_bin][0];
                    double imag = hybrid_out[hybrid_bin][1];
                    double magnitude = sqrt(real * real + imag * imag);
                    spectrogram[w * num_bins + b] = magnitude;
                    if (magnitude > global_max)
                    {
                        global_max = magnitude;
                    }
                }
            }
        #endif
    }

    /* ------------------------------ */
    /* 4. Frequency Range Filtering   */
    /* ------------------------------ */
    int index_min = (int)ceil(DEFAULT_MIN_FREQ / freq_resolution);
    int index_max = (int)floor(DEFAULT_MAX_FREQ / freq_resolution);
    if (index_max > num_bins - 1)
    {
        index_max = num_bins - 1;
    }
    int num_freq_bins = index_max - index_min + 1;

    /* ------------------------------ */
    /* 5. Generate the PNG Spectrogram*/
    /* ------------------------------ */
    int base_width = (int)BASE_WIDTH;
    int base_height = (int)BASE_HEIGHT;
    int image_width = (int)(base_width * SCALE_FACTOR);
    int image_height = (int)(base_height * SCALE_FACTOR);

    cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, image_width, image_height);
    cairo_t *cr = cairo_create(surface);
    if (cr == NULL)
    {
        fprintf(stderr, "Error: Unable to create Cairo context.\n");
        #if USE_ZERO_PADDING
            fftw_destroy_plan(plan);
            fftw_free(in_zp);
            fftw_free(out_zp);
        #else
            fftw_destroy_plan(plan);
            fftw_free(in);
            fftw_free(out);
        #endif
        #if USE_HYBRID_FFT
            fftw_destroy_plan(hybrid_plan);
            fftw_free(hybrid_in);
            fftw_free(hybrid_out);
        #endif
        free(signal);
        free(spectrogram);
        return EXIT_FAILURE;
    }

    cairo_set_antialias(cr, CAIRO_ANTIALIAS_BEST);
    cairo_scale(cr, SCALE_FACTOR, SCALE_FACTOR);
    cairo_set_source_rgb(cr, 1.0, 1.0, 1.0);
    cairo_paint(cr);

    double effective_height = base_height - TOP_MARGIN - BOTTOM_MARGIN;

    for (int w = 0; w < num_windows; w++)
    {
        double cell_width = base_width / num_windows;
        for (int b = index_min; b <= index_max; b++)
        {
            double magnitude = spectrogram[w * num_bins + b];
            double intensity = 0.0;
            double epsilon = 1e-10;
            if (USE_LOG_AMPLITUDE)
            {
                double dB = 20.0 * log10(magnitude + epsilon);
                double max_dB = 20.0 * log10(global_max + epsilon);
                double min_dB = max_dB - DYNAMIC_RANGE_DB;
                intensity = (dB - min_dB) / (max_dB - min_dB);
                if (intensity < 0.0)
                    intensity = 0.0;
                if (intensity > 1.0)
                    intensity = 1.0;
            }
            else
            {
                intensity = magnitude / global_max;
            }

            if (gammaCorr != 1.0)
            {
                intensity = pow(intensity, 1.0 / gammaCorr);
            }

            double inverted_intensity = 1.0 - intensity;
            double quantized = inverted_intensity * 255.0;
            if (enableDither)
            {
                double dither = ((double)rand() / (double)RAND_MAX) - 0.5;
                quantized += dither;
            }
            if (quantized < 0.0)
                quantized = 0.0;
            if (quantized > 255.0)
                quantized = 255.0;
            double final_intensity = quantized / 255.0;

            #if USE_LOG_BLACK_LEVEL
                final_intensity = log(quantized + 1.0) / log(256.0);
            #endif

            final_intensity = (final_intensity - 0.5) * contrastFactor + 0.5;
            if (final_intensity < 0.0)
                final_intensity = 0.0;
            if (final_intensity > 1.0)
                final_intensity = 1.0;

            double y = 0.0;
            double cell_height = 0.0;
            if (USE_LOG_FREQUENCY)
            {
                double freq = b * freq_resolution;
                double freq_next = (b + 1) * freq_resolution;
                double log_min = log(DEFAULT_MIN_FREQ);
                double log_max = log(DEFAULT_MAX_FREQ);
                #if USE_MODIFIED_LOG_MAPPING
                    double ratio_current = (log(freq) - log_min) / (log_max - log_min);
                    double ratio_next = (log(freq_next) - log_min) / (log_max - log_min);
                    ratio_current = pow(ratio_current, LOG_MAPPING_EXPONENT);
                    ratio_next = pow(ratio_next, LOG_MAPPING_EXPONENT);
                    double y_current = (base_height - BOTTOM_MARGIN) - (ratio_current * effective_height);
                    double y_next = (base_height - BOTTOM_MARGIN) - (ratio_next * effective_height);
                #else
                    double y_current = (base_height - BOTTOM_MARGIN) - ((log(freq) - log_min) / (log_max - log_min)) * effective_height;
                    double y_next = (base_height - BOTTOM_MARGIN) - ((log(freq_next) - log_min) / (log_max - log_min)) * effective_height;
                #endif
                y = y_next;
                cell_height = fabs(y_next - y_current);
            }
            else
            {
                int local_index = b - index_min;
                cell_height = effective_height / num_freq_bins;
                y = (base_height - BOTTOM_MARGIN) - ((local_index + 1) * cell_height);
            }

            cairo_set_source_rgb(cr, final_intensity, final_intensity, final_intensity);
            double x = w * cell_width;
            cairo_rectangle(cr, x, y, cell_width, cell_height);
            cairo_fill(cr);
        }
    }

    #if ENABLE_BLUR
        apply_separable_box_blur(surface, BLUR_RADIUS);
    #endif

    /* Debug: Print the current working directory */
    {
        char cwd[1024];
        if (getcwd(cwd, sizeof(cwd)) != NULL)
        {
            printf("Current working directory: %s\n", cwd);
        }
        else
        {
            perror("getcwd error");
        }
    }

    /* Write the PNG image and check for errors */
    cairo_status_t status = cairo_surface_write_to_png(surface, outputFile);
    if (status != CAIRO_STATUS_SUCCESS)
    {
        fprintf(stderr, "Error writing PNG: %s\n", cairo_status_to_string(status));
    }
    else
    {
        printf("PNG written successfully.\n");
    }

    /* Destroy the Cairo context and surface */
    cairo_destroy(cr);
    cairo_surface_destroy(surface);

    #if USE_ZERO_PADDING
        fftw_destroy_plan(plan);
        fftw_free(in_zp);
        fftw_free(out_zp);
    #else
        fftw_destroy_plan(plan);
        fftw_free(in);
        fftw_free(out);
    #endif
    #if USE_HYBRID_FFT
        fftw_destroy_plan(hybrid_plan);
        fftw_free(hybrid_in);
        fftw_free(hybrid_out);
    #endif

    free(signal);
    free(spectrogram);

    printf("Spectrogram PNG generated successfully as \"%s\".\n", outputFile);

    return EXIT_SUCCESS;
}

/*---------------------------------------------------------------------
 * load_wav_file()
 *
 * Loads a WAV file and extracts the first 'duration' seconds of audio.
 * If the file is stereo, converts it to mono by averaging channels.
 * Normalizes the audio to a maximum absolute amplitude of 1.
 *
 * Returns:
 *  - 0 on success, -1 on failure.
 *---------------------------------------------------------------------*/
int load_wav_file(const char *filename, double **signal, int *num_samples, int *sample_rate, double duration)
{
    SF_INFO sfinfo;
    SNDFILE *infile = sf_open(filename, SFM_READ, &sfinfo);
    if (infile == NULL)
    {
        fprintf(stderr, "Error: Unable to open file %s\n", filename);
        return -1;
    }

    *sample_rate = sfinfo.samplerate;
    int total_frames = (int)(duration * (*sample_rate));
    if (total_frames > sfinfo.frames)
    {
        total_frames = sfinfo.frames;
    }

    int channels = sfinfo.channels;
    float *temp_buffer = (float *)malloc(total_frames * channels * sizeof(float));
    if (temp_buffer == NULL)
    {
        fprintf(stderr, "Error: Unable to allocate temporary buffer.\n");
        sf_close(infile);
        return -1;
    }

    int frames_read = sf_readf_float(infile, temp_buffer, total_frames);
    if (frames_read < total_frames)
    {
        total_frames = frames_read;
    }

    *signal = (double *)malloc(total_frames * sizeof(double));
    if (*signal == NULL)
    {
        fprintf(stderr, "Error: Unable to allocate signal buffer.\n");
        free(temp_buffer);
        sf_close(infile);
        return -1;
    }

    for (int i = 0; i < total_frames; i++)
    {
        if (channels == 1)
        {
            (*signal)[i] = temp_buffer[i];
        }
        else
        {
            double sum = 0.0;
            for (int c = 0; c < channels; c++)
            {
                sum += temp_buffer[i * channels + c];
            }
            (*signal)[i] = sum / channels;
        }
    }

    /* Normalize the audio to a maximum absolute amplitude of 1 */
    double max_abs = 0.0;
    for (int i = 0; i < total_frames; i++)
    {
        if (fabs((*signal)[i]) > max_abs)
        {
            max_abs = fabs((*signal)[i]);
        }
    }
    if (max_abs > 0.0)
    {
        for (int i = 0; i < total_frames; i++)
        {
            (*signal)[i] /= max_abs;
        }
    }

    free(temp_buffer);
    sf_close(infile);
    *num_samples = total_frames;
    return 0;
}

/*---------------------------------------------------------------------
 * generate_sine_wave()
 *
 * Synthesizes a sine wave and stores samples in the provided buffer.
 * (For reference; not used when loading a WAV file.)
 *---------------------------------------------------------------------*/
void generate_sine_wave(double *signal, int total_samples, double sample_rate, double frequency, double amplitude)
{
    for (int i = 0; i < total_samples; i++)
    {
        double t = (double)i / sample_rate;
        signal[i] = amplitude * sin(2.0 * M_PI * frequency * t);
    }
}

/*---------------------------------------------------------------------
 * apply_hann_window()
 *
 * Applies an in-place Hann window to the buffer of length 'size'.
 *---------------------------------------------------------------------*/
void apply_hann_window(double *buffer, int size)
{
    for (int i = 0; i < size; i++)
    {
        buffer[i] *= 0.5 * (1.0 - cos(2.0 * M_PI * i / (size - 1)));
    }
}

/*---------------------------------------------------------------------
 * apply_separable_box_blur()
 *
 * Applies a separable box blur to the Cairo surface.
 *---------------------------------------------------------------------*/
void apply_separable_box_blur(cairo_surface_t *surface, int radius)
{
    cairo_surface_flush(surface);
    int width = cairo_image_surface_get_width(surface);
    int height = cairo_image_surface_get_height(surface);
    int stride = cairo_image_surface_get_stride(surface);
    unsigned char *data = cairo_image_surface_get_data(surface);

    unsigned char *temp = (unsigned char *)malloc(height * stride);
    if (!temp)
    {
        return;
    }

    /* Horizontal pass */
    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < width; x++)
        {
            int sumA = 0, sumR = 0, sumG = 0, sumB = 0;
            int count = 0;
            for (int k = -radius; k <= radius; k++)
            {
                int nx = x + k;
                if (nx < 0 || nx >= width)
                    continue;
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
    for (int x = 0; x < width; x++)
    {
        for (int y = 0; y < height; y++)
        {
            int sumA = 0, sumR = 0, sumG = 0, sumB = 0;
            int count = 0;
            for (int k = -radius; k <= radius; k++)
            {
                int ny = y + k;
                if (ny < 0 || ny >= height)
                    continue;
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
 * apply_high_freq_boost_filter()
 *
 * Applies a pre-emphasis filter to accentuate high frequencies.
 * The filter is defined as: y[n] = x[n] - alpha * x[n-1]
 * This operation is performed in-place.
 *---------------------------------------------------------------------*/
void apply_high_freq_boost_filter(double *signal, int num_samples, double alpha)
{
    if (num_samples < 2)
        return;

    double prev_sample = signal[0];
    for (int i = 1; i < num_samples; i++)
    {
        double current_sample = signal[i];
        signal[i] = current_sample - alpha * prev_sample;
        prev_sample = current_sample;
    }
}
