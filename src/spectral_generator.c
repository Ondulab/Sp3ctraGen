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
#include "../include/spectral_generator.h"

/* ---------------------------------------------------------------------
   Fallback macros: if a configuration value is zero (or not valid),
   the corresponding default from the original #defines is used.
--------------------------------------------------------------------- */
#define DEFAULT_INT(cfgVal, defaultVal)    (((cfgVal) > 0) ? (cfgVal) : (defaultVal))
#define DEFAULT_DBL(cfgVal, defaultVal)    (((cfgVal) > 0.0) ? (cfgVal) : (defaultVal))
#define DEFAULT_BOOL(cfgVal, defaultVal)   (((cfgVal) == 0 || (cfgVal) == 1) ? (cfgVal) : (defaultVal))
#define DEFAULT_STR(cfgVal, defaultVal)    (((cfgVal) != NULL && (cfgVal)[0] != '\0') ? (cfgVal) : (defaultVal))
#define PIXELS_TO_CM                       0.00847   // Conversion cm en pixels à 300 DPI: 1 cm = 118.11 pixels, donc 1 pixel = 0.00847 cm
                                                     // Remarque: Cette constante est utilisée comme diviseur lors de la conversion cm -> pixels

/* -------------------------- */
/* Default parameters         */
/* (Originally defined as macros) */
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
// Définitions de formats de page (en pixels à 300 DPI)
// A4 portrait: 210mm x 297mm → 2480 x 3508 pixels à 300 DPI
// A3 paysage: 420mm x 297mm → 4961 x 3508 pixels à 300 DPI
#define A4_WIDTH               2480.0
#define A4_HEIGHT              3508.0
#define A3_WIDTH               4961.0
#define A3_HEIGHT              3508.0
#define TOP_MARGIN              600.0
#define DEFAULT_BOTTOM_MARGIN   600.0
#define DEFAULT_SPECTRO_HEIGHT  2000.0 
#define MM_TO_PIXELS            11.81   // Conversion mm en pixels à 300 DPI (300/25.4)
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
 * If inputFile or outputFile is NULL or empty, default paths are used.
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
    double  writingSpeed    = DEFAULT_DBL(s.writingSpeed,   0.0);
    double  duration        = DEFAULT_DBL(s.duration,       DEFAULT_DURATION);
    int     sample_rate     = DEFAULT_INT(s.sampleRate,     DEFAULT_SAMPLE_RATE);
    double  dynamicRangeDB  = DEFAULT_DBL(s.dynamicRangeDB, DYNAMIC_RANGE_DB);
    double  gammaCorr       = DEFAULT_DBL(s.gammaCorrection, GAMMA_CORRECTION);
    int     enableDither    = DEFAULT_BOOL(s.enableDithering, ENABLE_DITHERING);
    double  contrastFactor  = DEFAULT_DBL(s.contrastFactor, CONTRAST_FACTOR);
    int     enableHighBoost = DEFAULT_BOOL(s.enableHighBoost, ENABLE_HIGH_BOOST);
    double  highBoostAlpha  = DEFAULT_DBL(s.highBoostAlpha, HIGH_BOOST_ALPHA);
    
    /* Use default paths if input/output files are not specified */
    const char* inputFilePath = DEFAULT_STR(inputFile, DEFAULT_INPUT_FILE);
    const char* outputFilePath = DEFAULT_STR(outputFile, DEFAULT_OUTPUT_FILE);

    // Si une vitesse d'écriture est spécifiée, calculer la durée en fonction de la vitesse
    if (writingSpeed > 0.0) {
        // Sélection du format de page pour calculer la largeur
        double pageWidth = (s.pageFormat == 1) ? A3_WIDTH : A4_WIDTH;
        
        // Convertir la largeur de pixels à cm
        double pageWidthCM = pageWidth * PIXELS_TO_CM;
        
        // Calculer la durée: durée (s) = largeur (cm) / vitesse (cm/s)
        duration = pageWidthCM / writingSpeed;
        
        // Mettre à jour la durée dans la structure s (important pour que le changement soit pris en compte partout)
        s.duration = duration;
        
        printf("Writing speed: %.2f cm/s, page width: %.2f cm\n", writingSpeed, pageWidthCM);
        printf("Calculated duration based on writing speed: %.2f seconds\n", duration);
    }

    printf("Spectrogram generation parameters:\n");
    printf(" - FFT size: %d\n", fft_size);
    printf(" - Overlap: %f\n", overlap);
    printf(" - Min frequency: %f\n", minFreq);
    printf(" - Max frequency: %f\n", maxFreq);
    printf(" - Writing speed: %f cm/s\n", writingSpeed);
    printf(" - Duration: %f\n", duration);
    printf(" - Sample rate: %d\n", sample_rate);
    printf(" - Dynamic range (dB): %f\n", dynamicRangeDB);
    printf(" - Gamma correction: %f\n", gammaCorr);
    printf(" - Dithering: %d\n", enableDither);
    printf(" - Contrast factor: %f\n", contrastFactor);
    printf(" - High boost: %d (alpha = %f)\n", enableHighBoost, highBoostAlpha);
    printf(" - Input file: %s\n", inputFilePath);
    printf(" - Output file: %s\n", outputFilePath);

    /* ------------------------------ */
    /* 1. Load audio signal from WAV  */
    /* ------------------------------ */
    int total_samples = 0;
    double *signal = NULL;
    printf(" - Loading WAV file with duration: %.2f seconds (based on writing speed)\n", s.duration);
    if (load_wav_file(inputFilePath, &signal, &total_samples, &sample_rate, s.duration) != 0)
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
    
    // Calcul du nombre de fenêtres et de leur espacement
    int step;
    int num_windows;
    
    // Durée réelle audio en secondes
    double audio_duration = total_samples / (double)sample_rate;
    printf(" - Audio duration: %.2f seconds\n", audio_duration);
    
    if (writingSpeed > 0.0) {
        // Calculer la largeur physique théorique du spectrogramme
        double spectrogram_width_cm = audio_duration * writingSpeed;
        double spectrogram_width_pixels = spectrogram_width_cm / PIXELS_TO_CM;
        
        // Vérifier si ça dépasse la largeur de la page
        double page_width = (s.pageFormat == 1) ? A3_WIDTH : A4_WIDTH;
        double page_width_cm = page_width * PIXELS_TO_CM;
        
        if (spectrogram_width_pixels > page_width) {
            // Si ça dépasse, on tronque strictement ce qui dépasse de la page
            printf(" - Spectrogram width exceeds page width, will be truncated\n");
            
            // Calculer la durée visible (qui tiendra sur la page) en respectant la vitesse
            double visible_duration = page_width_cm / writingSpeed;
            
            // On limite la taille à la largeur de la page mais on maintient strictement l'échelle cm/s
            printf(" - Only first %.2f seconds will be shown (of total %.2f seconds)\n", 
                   visible_duration, audio_duration);
            printf(" - Truncating at %.2f cm (%.2f pixels), keeping the exact %.2f cm/s scale\n",
                   page_width_cm, page_width, writingSpeed);
                   
            // On n'adapte PAS le contenu pour tout afficher (c'est ce que l'utilisateur ne veut pas)
            // On se contente de limiter la largeur d'affichage
            spectrogram_width_pixels = page_width;
            spectrogram_width_cm = page_width_cm;
        }
        
        // IMPORTANT: Utiliser le chevauchement spécifié par l'utilisateur (overlap) plutôt que de le recalculer
        // Calculer le pas (step) basé sur le chevauchement demandé
        step = (int)(fft_size * (1.0 - overlap));
        if (step < 1) step = 1;
        
        // Calculer le nombre de fenêtres en fonction du pas et des échantillons disponibles
        num_windows = (total_samples - fft_size) / step + 1;
        
        // Si nécessaire, ajuster pour avoir une résolution minimale
        int min_windows_per_cm = 10; // Minimum de fenêtres par cm pour une résolution acceptable
        int min_windows = (int)(spectrogram_width_cm * min_windows_per_cm);
        
        if (num_windows < min_windows) {
            // Recalculer le pas pour avoir au moins min_windows fenêtres
            step = (total_samples - fft_size) / min_windows;
            if (step < 1) step = 1;
            
            // Recalculer le nombre de fenêtres avec le nouveau pas
            num_windows = (total_samples - fft_size) / step + 1;
            
            // Calculer le nouveau chevauchement correspondant
            double new_overlap = 1.0 - (step / (double)fft_size);
            printf(" - Adjusted overlap to %.2f for better resolution\n", new_overlap);
            overlap = new_overlap;
        }
        
        printf("Distribution horizontale basée sur la vitesse d'écriture:\n");
        printf(" - Vitesse: %.2f cm/s\n", writingSpeed);
        printf(" - Largeur du spectrogramme: %.2f cm (%.2f pixels)\n", 
               spectrogram_width_cm, spectrogram_width_pixels);
        printf(" - Nombre de fenêtres calculé: %d\n", num_windows);
        printf(" - Pas entre fenêtres: %d échantillons\n", step);
        printf(" - Fenêtres par cm: %.2f\n", num_windows / spectrogram_width_cm);
    } else {
        // Méthode originale si aucune vitesse d'écriture n'est spécifiée
        step = (int)(fft_size * (1.0 - overlap));
        num_windows = (total_samples - fft_size) / step + 1;
        printf("Distribution horizontale standard (pas de vitesse d'écriture spécifiée)\n");
        printf(" - Pas entre fenêtres: %d échantillons\n", step);
        printf(" - Nombre de fenêtres: %d\n", num_windows);
    }

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
    // Sélection du format de page en fonction du paramètre
    double page_width, page_height;
    if (s.pageFormat == 1) { // A3 paysage
        page_width = A3_WIDTH;
        page_height = A3_HEIGHT;
        printf(" - Page format: A3 landscape\n");
    } else { // A4 portrait (par défaut)
        page_width = A4_WIDTH;
        page_height = A4_HEIGHT;
        printf(" - Page format: A4 portrait\n");
    }
    
    // Calcul de la largeur du spectrogramme basé sur la durée audio et la vitesse d'écriture
    double spectrogram_width_cm;
    double spectrogram_width_pixels;
    double page_width_cm = page_width * PIXELS_TO_CM;
    
    if (writingSpeed > 0.0) {
        // Calculer la largeur théorique du spectrogramme en fonction de la durée audio et de la vitesse
        double audio_duration_seconds = total_samples / (double)sample_rate;
        spectrogram_width_cm = audio_duration_seconds * writingSpeed;
        spectrogram_width_pixels = spectrogram_width_cm / PIXELS_TO_CM;
        
        printf(" - Audio duration: %.2f seconds\n", audio_duration_seconds);
        printf(" - Writing speed: %.2f cm/s\n", writingSpeed);
        printf(" - Calculated spectrogram width: %.2f cm (%.2f pixels)\n", 
               spectrogram_width_cm, spectrogram_width_pixels);
        
        // Si la largeur calculée dépasse celle de la page, on tronque strictement
        if (spectrogram_width_pixels > page_width) {
            double visible_duration = page_width_cm / writingSpeed;
            double visible_width_cm = page_width_cm;
            double visible_ratio = visible_duration / audio_duration_seconds;
            
            printf(" - Spectrogram width exceeds page width (%.2f cm needed for %.2f seconds at %.2f cm/s)\n", 
                   spectrogram_width_cm, audio_duration_seconds, writingSpeed);
            printf(" - Only showing the first %.2f seconds (%.2f%% of audio) while strictly maintaining %.2f cm/s scale\n", 
                   visible_duration, visible_ratio * 100.0, writingSpeed);
            
            // On limite la largeur d'affichage SANS ADAPTER le contenu pour que tout rentre
            // Cela signifie qu'une partie de l'audio sera tronquée, mais l'échelle sera exacte
            spectrogram_width_pixels = page_width;
            spectrogram_width_cm = page_width_cm;
        }
    } else {
        // Comportement par défaut si aucune vitesse d'écriture n'est spécifiée
        spectrogram_width_pixels = page_width;
        spectrogram_width_cm = page_width_cm;
    }
    
    // La largeur réelle du spectrogramme à utiliser
    double base_width = spectrogram_width_pixels;
    double base_height = page_height;
    
    int image_width = (int)(page_width * SCALE_FACTOR);
    int image_height = (int)(page_height * SCALE_FACTOR);

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

    // Utilisez les marges personnalisées ou les valeurs par défaut
    double bottom_margin = DEFAULT_DBL(s.bottomMarginMM * MM_TO_PIXELS, DEFAULT_BOTTOM_MARGIN);
    double spectro_height = DEFAULT_DBL(s.spectroHeightMM * MM_TO_PIXELS, DEFAULT_SPECTRO_HEIGHT);
    printf(" - Bottom margin: %.2f mm (%.2f pixels)\n", s.bottomMarginMM, bottom_margin);
    printf(" - Spectrogram height: %.2f mm (%.2f pixels)\n", s.spectroHeightMM, spectro_height);
    
    double effective_height = spectro_height;

    // Calculer combien de fenêtres peuvent réellement tenir sur la page
    int visible_windows = num_windows;
    double visible_duration_sec = audio_duration;
    
    if (writingSpeed > 0.0 && spectrogram_width_pixels > page_width) {
        // Si toutes les fenêtres ne peuvent pas tenir sur la page, on limite le nombre affiché
        visible_duration_sec = page_width_cm / writingSpeed;
        // Calculer combien de fenêtres correspondant à la durée visible
        visible_windows = (int)(num_windows * (visible_duration_sec / audio_duration));
        printf(" - Limiting display to %d windows (%.2f%% of total %d windows)\n", 
               visible_windows, (visible_windows * 100.0 / num_windows), num_windows);
    }
    
    // Dessiner seulement les fenêtres qui tiennent sur la page
    for (int w = 0; w < visible_windows; w++)
    {
        // Adapter la largeur de cellule pour qu'elle corresponde strictement à l'échelle cm/s
        double cell_width = base_width / visible_windows;
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
                    double y_current = (base_height - bottom_margin) - (ratio_current * effective_height);
                    double y_next = (base_height - bottom_margin) - (ratio_next * effective_height);
                #else
                    double y_current = (base_height - bottom_margin) - ((log(freq) - log_min) / (log_max - log_min)) * effective_height;
                    double y_next = (base_height - bottom_margin) - ((log(freq_next) - log_min) / (log_max - log_min)) * effective_height;
                #endif
                y = y_next;
                cell_height = fabs(y_next - y_current);
            }
            else
            {
                int local_index = b - index_min;
                cell_height = effective_height / num_freq_bins;
                y = (base_height - bottom_margin) - ((local_index + 1) * cell_height);
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
    cairo_status_t status = cairo_surface_write_to_png(surface, outputFilePath);
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

    printf("Spectrogram PNG generated successfully as \"%s\".\n", outputFilePath);

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
    
    // Logs de diagnostic
    double file_duration_seconds = (double)sfinfo.frames / sfinfo.samplerate;
    printf("DIAGNOSTIC - Fichier audio:\n");
    printf(" - Durée totale du fichier: %.3f secondes (%d échantillons à %d Hz)\n", 
           file_duration_seconds, (int)sfinfo.frames, sfinfo.samplerate);
    printf(" - Durée demandée pour chargement: %.3f secondes\n", duration);
    
    // *** MODIFICATION IMPORTANTE: Charger tout le fichier indépendamment de la durée passée ***
    // int total_frames = (int)(duration * (*sample_rate));
    int total_frames = sfinfo.frames; // Toujours charger l'intégralité du fichier
    
    printf(" - Échantillons effectivement chargés: %d (%.3f secondes)\n", 
           total_frames, (double)total_frames / sfinfo.samplerate);

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
