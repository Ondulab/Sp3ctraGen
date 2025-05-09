#include "spectral_common.h"
#include "spectral_wav_processing.h"
#include "spectral_fft.h"

/*---------------------------------------------------------------------
 * draw_vertical_scale()
 *
 * Draws a vertical scale with frequency labels on the left side of the spectrogram.
 * Uses logarithmic scale with one graduation per octave.
 *
 * Parameters:
 *  - cr: Cairo context
 *  - spectro_left: Left position of the spectrogram
 *  - spectro_top: Top position of the spectrogram
 *  - spectro_height: Height of the spectrogram in pixels
 *  - minFreq: Minimum frequency in Hz
 *  - maxFreq: Maximum frequency in Hz
 *  - octaves: Number of octaves between minFreq and maxFreq
 *---------------------------------------------------------------------*/
void draw_vertical_scale(cairo_t *cr, double spectro_left, double spectro_top,
                          double spectro_height, double minFreq, double maxFreq, double octaves,
                          double textScaleFactor, double lineThicknessFactor) {
    // Draw the main vertical line
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_set_line_width(cr, lineThicknessFactor);
    cairo_move_to(cr, spectro_left, spectro_top);
    cairo_line_to(cr, spectro_left, spectro_top + spectro_height);
    cairo_stroke(cr);
    
    // Calculate octaves for graduations
    double start_octave = ceil(log2(minFreq));
    double end_octave = floor(log2(maxFreq));
    
    // Draw graduations and labels for each octave
    cairo_set_font_size(cr, 32.0 * textScaleFactor); // Size adapted for 800 DPI, adjusted by scale factor
    
    for (double octave = start_octave; octave <= end_octave; octave++) {
        double freq = pow(2.0, octave);
        double log_ratio = log2(freq / minFreq) / octaves;
        double y = spectro_top + (1.0 - log_ratio) * spectro_height;
        
        // Draw the graduation mark
        cairo_move_to(cr, spectro_left - 5 * lineThicknessFactor, y);
        cairo_line_to(cr, spectro_left, y);
        cairo_stroke(cr);
        
        // Display the frequency label
        char label[32];
        if (freq >= 1000) {
            snprintf(label, sizeof(label), "%.1f kHz", freq / 1000.0);
        } else {
            snprintf(label, sizeof(label), "%.0f Hz", freq);
        }
        
        cairo_move_to(cr, spectro_left - 50, y + 4);
        cairo_show_text(cr, label);
    }
}

/*---------------------------------------------------------------------
 * draw_reference_lines()
 *
 * Draws horizontal reference lines above and/or below the spectrogram.
 *
 * Parameters:
 *  - cr: Cairo context
 *  - spectro_left: Left position of the spectrogram
 *  - spectro_width: Width of the spectrogram in pixels
 *  - spectro_bottom: Bottom position of the spectrogram
 *  - spectro_top: Top position of the spectrogram
 *  - enableBottom: Whether to draw the bottom reference line
 *  - bottomOffset: Offset of the bottom reference line in mm (negative = downward)
 *  - enableTop: Whether to draw the top reference line
 *  - topOffset: Offset of the top reference line in mm (positive = upward)
 *---------------------------------------------------------------------*/
void draw_reference_lines(cairo_t *cr, double spectro_left, double spectro_width,
                          double spectro_bottom, double spectro_top,
                          int enableBottom, double bottomOffset,
                          int enableTop, double topOffset,
                          double lineThicknessFactor) {
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_set_line_width(cr, lineThicknessFactor);
    
    // Bottom reference line
    if (enableBottom) {
        // Use positive offset value but apply it downward from the bottom
        double y = spectro_bottom + bottomOffset * MM_TO_PIXELS;
        cairo_move_to(cr, spectro_left, y);
        cairo_line_to(cr, spectro_left + spectro_width, y);
        cairo_stroke(cr);
    }
    
    // Top reference line
    if (enableTop) {
        double y = spectro_top - topOffset * MM_TO_PIXELS;
        cairo_move_to(cr, spectro_left, y);
        cairo_line_to(cr, spectro_left + spectro_width, y);
        cairo_stroke(cr);
    }
}

/*---------------------------------------------------------------------
 * draw_parameters_text()
 *
 * Displays the spectrogram parameters at the bottom of the page.
 *
 * Parameters:
 *  - cr: Cairo context
 *  - page_width: Width of the page in pixels
 *  - page_height: Height of the page in pixels
 *  - s: Spectrogram settings
 *---------------------------------------------------------------------*/
/*---------------------------------------------------------------------
 * draw_parameters_text()
 *
 * Displays the spectrogram parameters at the bottom of the page.
 *
 * Parameters:
 *  - cr: Cairo context
 *  - page_width: Width of the page in pixels
 *  - page_height: Height of the page in pixels
 *  - s: Spectrogram settings
 *  - audioFile: Path to audio file
 *  - startTime: Start time in seconds
 *  - segmentDuration: Duration of the segment in seconds
 *---------------------------------------------------------------------*/
void draw_parameters_text(cairo_t *cr, double page_width, double page_height,
                          const SpectrogramSettings *s, const char *audioFile, 
                          double startTime, double segmentDuration)
{
    // Extract filename from path (if provided)
    const char *filename = audioFile;
    if (filename && *filename) {
        // Find last slash or backslash
        const char *lastSlash = strrchr(filename, '/');
        const char *lastBackslash = strrchr(filename, '\\');
        
        // Use the last directory separator found
        if (lastSlash && (!lastBackslash || lastSlash > lastBackslash)) {
            filename = lastSlash + 1;
        } else if (lastBackslash) {
            filename = lastBackslash + 1;
        }
    } else {
        filename = "Unknown";
    }
    
    // Set font size scaled
    double fontSize = 48.0 * s->textScaleFactor;
    cairo_font_extents_t font_extents;
    cairo_font_extents(cr, &font_extents);
    double line_height = font_extents.height * 1.5; // Add 50% extra spacing between lines
    
    // Text origin and margin
    double margin = 50.0;
    double text_x = margin;
    double text_y = page_height - (line_height * 2.5);  // Space for 2 lines + padding
    
    // Prepare the text for the two lines
    char line1[1024];
    char line2[1024];
    
    // Line 1: file info, start time, duration, FFT and overlap
    snprintf(line1, sizeof(line1), "File: %s, Start: %.2fs, Duration: %.2fs, FFT: %d, Overlap: %.2f", 
             filename, startTime, segmentDuration, s->fftSize, s->overlap);
    
    // Line 2: frequency, sample rate, high-pass filter, dynamic range, gamma, contrast, high boost and writing speed
    snprintf(line2, sizeof(line2), "Freq: %.0f-%.0f Hz, SR: %d Hz, HPF: %s (%.0f Hz, %d), DR: %.1f dB, Gamma: %.1f, Contrast: %.1f, HB: %s (%.2f), WS: %.1f cm/s",
             s->minFreq, s->maxFreq, s->sampleRate, 
             s->enableHighPassFilter ? "On" : "Off", s->highPassCutoffFreq, s->highPassFilterOrder,
             s->dynamicRangeDB, s->gammaCorrection, s->contrastFactor,
             s->enableHighBoost ? "On" : "Off", s->highBoostAlpha, s->writingSpeed);
    
    // Calculate text dimensions for background
    cairo_text_extents_t extents1, extents2;
    cairo_set_font_size(cr, fontSize);
    cairo_text_extents(cr, line1, &extents1);
    cairo_text_extents(cr, line2, &extents2);
    
    // Calculate background dimensions
    double max_width = fmax(extents1.width, extents2.width);
    double bg_width = max_width + margin * 2;
    double bg_height = line_height * 2 + margin;
    double bg_x = margin;  // Aligned to left margin
    double bg_y = text_y - line_height - margin/2;
    
    // Draw background with slight transparency
    cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 0.85);  // White with 85% opacity
    cairo_rectangle(cr, bg_x, bg_y, bg_width, bg_height);
    cairo_fill(cr);
    
    // Set text position for left-aligned text
    text_x = bg_x + margin;
    text_y = bg_y + line_height;
    
    // Draw the two lines of text
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);  // Black text
    
    // First line
    cairo_move_to(cr, text_x, text_y);
    cairo_show_text(cr, line1);
    
    // Second line
    text_y += line_height;
    cairo_move_to(cr, text_x, text_y);
    cairo_show_text(cr, line2);
}

/*---------------------------------------------------------------------
 * spectral_generator_impl()
 *
 * Generates a spectrogram PNG image.
 * Uses exact parameters specified by the user without automatic adjustments.
 * Optimized for 800 DPI output with correct logarithmic frequency scaling.
 *
 * Returns:
 *  - EXIT_SUCCESS on success, EXIT_FAILURE on error.
 *---------------------------------------------------------------------*/
int spectral_generator_impl(const SpectrogramSettings *cfg,
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
    const char* inputFilePath = DEFAULT_STR(inputFile, DEFAULT_INPUT_FILENAME);
    const char* outputFilePath = DEFAULT_STR(outputFile, DEFAULT_OUTPUT_FILENAME);

    // Si une vitesse d'écriture est spécifiée, calculer la durée en fonction de la vitesse
    // Mais on ne modifie pas la durée si l'utilisateur a explicitement fourni une valeur
    double original_duration = duration;
    
    if (writingSpeed > 0.0 && s.duration <= 0.0) {
        // Sélection du format de page pour calculer la largeur
        double pageWidth = (s.pageFormat == 1) ? A3_WIDTH : A4_WIDTH;
        
        // Convertir la largeur de pixels à cm - en utilisant la valeur exacte
        double pageWidthCM = pageWidth / (800.0 / 2.54); // 800 pixels par pouce, 2.54 cm par pouce
        
        // Calculer la durée: durée (s) = largeur (cm) / vitesse (cm/s)
        duration = pageWidthCM / writingSpeed;
        
        // Mettre à jour la durée dans la structure s
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
    printf(" - Log frequency scale: %s\n", USE_LOG_FREQUENCY ? "enabled" : "disabled");

    /* ------------------------------ */
    /* 1. Load audio signal from WAV  */
    /* ------------------------------ */
    int total_samples = 0;
    double *signal = NULL;
    
    // Récupérer le paramètre de normalisation
    int enableNormalization = DEFAULT_BOOL(s.enableNormalization, 1);
    
    printf(" - Loading WAV file with duration: %.2f seconds\n", s.duration);
    printf(" - Normalization: %s\n", enableNormalization ? "enabled" : "disabled");
    
    if (load_wav_file(inputFilePath, &signal, &total_samples, &sample_rate, s.duration, enableNormalization) != 0) {
        fprintf(stderr, "Error: Unable to load WAV file.\n");
        return EXIT_FAILURE;
    }

    /* Apply high-pass filter if enabled */
    int enableHighPass = DEFAULT_BOOL(s.enableHighPassFilter, 0);
    double highPassCutoff = DEFAULT_DBL(s.highPassCutoffFreq, 0.0);
    int highPassOrder = DEFAULT_INT(s.highPassFilterOrder, 2);
    
    if (enableHighPass && highPassCutoff > 0.0) {
        printf(" - High-pass filter: enabled (cutoff = %.2f Hz, order = %d)\n", 
               highPassCutoff, highPassOrder);
        
        // Limit order to valid range (1-12)
        if (highPassOrder < 1) highPassOrder = 1;
        if (highPassOrder > 12) highPassOrder = 12;
        
        // Allocate coefficient arrays
        double a[13] = {0}; // Max order 12 + 1
        double b[13] = {0};
        
        // Design the filter
        design_highpass_filter(highPassCutoff, highPassOrder, sample_rate, a, b);
        
        // Apply the filter
        apply_highpass_filter(signal, total_samples, a, b, highPassOrder);
    } else {
        printf(" - High-pass filter: disabled\n");
    }
    
    /* Apply high frequency boost if enabled */
    if (enableHighBoost) {
        apply_high_freq_boost_filter(signal, total_samples, highBoostAlpha);
    }

    /* ------------------------------ */
    /* 2. Compute the Spectrogram     */
    /* ------------------------------ */
    // Create spectrogram data structure
    SpectrogramData spectro_data = {0};
    
    // Compute spectrogram - use exact overlap specified by user
    if (compute_spectrogram(signal, total_samples, sample_rate, fft_size, overlap, 
                         minFreq, maxFreq, &spectro_data) != 0) {
        fprintf(stderr, "Error: Failed to compute spectrogram.\n");
        free(signal);
        return EXIT_FAILURE;
    }
    
    // Free the signal as we've extracted the spectrogram data
    free(signal);
    signal = NULL;
    
    // Apply image processing
    apply_image_processing(&spectro_data, dynamicRangeDB, gammaCorr, enableDither, contrastFactor);
    
    /* ------------------------------ */
    /* 3. Generate the PNG Spectrogram*/
    /* ------------------------------ */
    // Determine page dimensions based on format for 800 DPI
    double page_width, page_height;
    if (s.pageFormat == 1) { // A3 landscape
        page_width = A3_WIDTH;
        page_height = A3_HEIGHT;
        printf(" - Page format: A3 landscape (%.2f x %.2f mm)\n", A3_WIDTH_MM, A3_HEIGHT_MM);
    } else { // A4 portrait (default)
        page_width = A4_WIDTH;
        page_height = A4_HEIGHT;
        printf(" - Page format: A4 portrait (%.2f x %.2f mm)\n", A4_WIDTH_MM, A4_HEIGHT_MM);
    }
    
    // Réduit la taille de la marge pour le texte (étiquettes de fréquence)
    double label_margin = 150.0; // Espace pour les étiquettes
    double bottom_margin_px = DEFAULT_DBL(s.bottomMarginMM * MM_TO_PIXELS, DEFAULT_BOTTOM_MARGIN);
    double spectro_height_px = DEFAULT_DBL(s.spectroHeightMM * MM_TO_PIXELS, DEFAULT_SPECTRO_HEIGHT);
    
    printf(" - Label margin: %.2f pixels at 800 DPI\n", label_margin);
    printf(" - Bottom margin: %.2f mm (%.2f pixels at 800 DPI)\n", s.bottomMarginMM, bottom_margin_px);
    printf(" - Spectrogram height: %.2f mm (%.2f pixels at 800 DPI)\n", s.spectroHeightMM, spectro_height_px);
    
    // Create surface and context for 800 DPI
    int image_width = (int)(page_width);
    int image_height = (int)(page_height);
    
    printf(" - Creating canvas: %d x %d pixels at 800 DPI\n", image_width, image_height);
    
    cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, image_width, image_height);
    cairo_t *cr = cairo_create(surface);
    if (cr == NULL) {
        fprintf(stderr, "Error: Unable to create Cairo context.\n");
        free(spectro_data.data);
        return EXIT_FAILURE;
    }
    
    // Fill background with white
    cairo_set_source_rgb(cr, 1.0, 1.0, 1.0);
    cairo_paint(cr);
    
    // Calculate spectrogram layout - optimisé pour utiliser toute la largeur
    // Spectrogramme commence après la marge pour les étiquettes et s'étend jusqu'au bord droit
    double spectro_left = label_margin;
    double spectro_width = page_width - label_margin;
    
    // Position verticale: depuis le bas de la page (bottom_margin)
    double spectro_bottom = page_height - bottom_margin_px;
    double spectro_top = spectro_bottom - spectro_height_px;
    
    printf(" - Spectrogram position: left=%.1f, top=%.1f, width=%.1f, height=%.1f\n",
           spectro_left, spectro_top, spectro_width, spectro_height_px);
    
    // Paramètres pour l'échelle logarithmique (si activée)
    double octaves = 0.0;
    if (USE_LOG_FREQUENCY) {
        octaves = log2(maxFreq / minFreq);
        printf(" - Octaves: %.2f (from %.1f Hz to %.1f Hz)\n", octaves, minFreq, maxFreq);
    }
    
    // Get spectrogram dimensions
    int num_windows = spectro_data.num_windows;
    int num_bins = spectro_data.num_bins;
    int index_min = spectro_data.index_min;
    int index_max = spectro_data.index_max;
    double *spectrogram = spectro_data.data;
    double freq_range = maxFreq - minFreq;
    
    // Calculate frequency resolution in the FFT
    int fft_effective_size = (USE_ZERO_PADDING) ? ZERO_PAD_SIZE : fft_size;
    double freq_resolution = sample_rate / (double)fft_effective_size;
    
    printf(" - Frequency resolution: %.2f Hz per bin\n", freq_resolution);
    printf(" - Frequency bins range: %d to %d\n", index_min, index_max);
    
    // Calculate visible windows based on writing speed and desired pixel scale
    int visible_windows = num_windows;
    
    // Si une vitesse d'écriture est spécifiée, calculer correctement le nombre de fenêtres visibles
    if (writingSpeed > 0.0) {
        // Calculer d'abord la durée réelle du signal audio
        double real_audio_duration = (double)total_samples / (double)sample_rate;
        
        // Calculer la durée des données FFT traitées
        double fft_duration;
        if (original_duration > 0.0) {
            // Si l'utilisateur a spécifié une durée, utiliser cette valeur
            fft_duration = original_duration;
        } else {
            // Sinon utiliser la durée du signal
            fft_duration = real_audio_duration;
        }
        
        // Convertir la page en cm
        double page_width_cm = page_width / (800.0 / 2.54); // 800 pixels par pouce, 2.54 cm par pouce
        double spectro_width_cm = spectro_width / (800.0 / 2.54);
        
        // Calculer la largeur du spectrogramme en cm pour la durée spécifiée
        double required_width_cm = fft_duration * writingSpeed;
        
        printf(" - Real audio duration: %.2f seconds\n", real_audio_duration);
        printf(" - Processed FFT duration: %.2f seconds\n", fft_duration);
        printf(" - Required width: %.2f cm (available: %.2f cm)\n", 
               required_width_cm, spectro_width_cm);
        
        // Si le spectrogramme est plus large que la page, ajuster le nombre de fenêtres
        if (required_width_cm > spectro_width_cm) {
            // Calculer le ratio d'échelle
            double scale_ratio = spectro_width_cm / required_width_cm;
            visible_windows = (int)(num_windows * scale_ratio);
            
            // S'assurer qu'on a au moins une fenêtre
            if (visible_windows < 1) visible_windows = 1;
            
            double visible_duration = (double)visible_windows * fft_duration / (double)num_windows;
            
            printf(" - Spectrogram exceeds available width, scaling down\n");
            printf(" - Showing %.2f seconds out of %.2f (%.1f%%)\n",
                  visible_duration, fft_duration, 
                  visible_duration * 100.0 / fft_duration);
        } else {
            // Si le spectrogramme est plus petit, il faut l'élargir pour maintenir l'échelle
            double pixel_cm_ratio = writingSpeed * fft_duration / spectro_width;
            printf(" - Spectrogram smaller than available width, maintaining scale\n");
            printf(" - Using %.2f%% of available width\n", 
                   pixel_cm_ratio * 100.0);
            
            // Dans ce cas, visible_windows reste égal à num_windows
        }
    }
    
    // Calculate pixel dimensions - directement en 800 DPI
    double window_width = spectro_width / (double)visible_windows;
    printf(" - Window width: %.3f pixels at 800 DPI\n", window_width);
    
    // Pré-calcul des fréquences réelles pour chaque bin FFT
    double *bin_frequencies = (double *)malloc(num_bins * sizeof(double));
    if (bin_frequencies == NULL) {
        fprintf(stderr, "Error: Unable to allocate memory for frequency bins.\n");
        cairo_destroy(cr);
        cairo_surface_destroy(surface);
        free(spectro_data.data);
        return EXIT_FAILURE;
    }
    
    // Calculer les fréquences exactes correspondant à chaque bin
    for (int b = 0; b < num_bins; b++) {
        bin_frequencies[b] = b * freq_resolution;
    }
    
    // Dessiner le spectrogramme
    for (int w = 0; w < visible_windows; w++) {
        double x = spectro_left + w * window_width;
        
        for (int b = index_min; b <= index_max; b++) {
            // Obtenir la fréquence réelle de ce bin
            double bin_freq = bin_frequencies[b];
            
            // Obtenir l'intensité depuis les données traitées
            double intensity = spectrogram[w * num_bins + b];
            
            // Calculer la position Y selon l'échelle (logarithmique ou linéaire)
            double y_pos;
            
            if (USE_LOG_FREQUENCY) {
                // Échelle logarithmique: espacer les octaves uniformément
                double log_ratio = log2(bin_freq / minFreq) / octaves;
                // Contraindre le ratio entre 0 et 1
                if (log_ratio < 0.0) log_ratio = 0.0;
                if (log_ratio > 1.0) log_ratio = 1.0;
                
                y_pos = spectro_bottom - (log_ratio * spectro_height_px);
            } else {
                // Échelle linéaire: répartition uniforme
                double lin_ratio = (bin_freq - minFreq) / freq_range;
                // Contraindre le ratio entre 0 et 1
                if (lin_ratio < 0.0) lin_ratio = 0.0;
                if (lin_ratio > 1.0) lin_ratio = 1.0;
                
                y_pos = spectro_bottom - (lin_ratio * spectro_height_px);
            }
            
            // Calculer la hauteur réelle du pixel (distance à la position Y suivante)
            double next_bin_freq = (b < num_bins - 1) ? bin_frequencies[b + 1] : bin_freq + freq_resolution;
            double next_y_pos;
            
            if (USE_LOG_FREQUENCY) {
                double next_log_ratio = log2(next_bin_freq / minFreq) / octaves;
                if (next_log_ratio < 0.0) next_log_ratio = 0.0;
                if (next_log_ratio > 1.0) next_log_ratio = 1.0;
                next_y_pos = spectro_bottom - (next_log_ratio * spectro_height_px);
            } else {
                double next_lin_ratio = (next_bin_freq - minFreq) / freq_range;
                if (next_lin_ratio < 0.0) next_lin_ratio = 0.0;
                if (next_lin_ratio > 1.0) next_lin_ratio = 1.0;
                next_y_pos = spectro_bottom - (next_lin_ratio * spectro_height_px);
            }
            
            double pixel_height = fabs(y_pos - next_y_pos);
            if (pixel_height < 1.0) pixel_height = 1.0; // Hauteur minimale
            
            // Définir la couleur en niveaux de gris
            cairo_set_source_rgb(cr, intensity, intensity, intensity);
            
            // Dessiner le rectangle
            cairo_rectangle(cr, x, next_y_pos, window_width, pixel_height);
            cairo_fill(cr);
        }
    }
    
    // Draw vertical scale if enabled
    if (s.enableVerticalScale) {
        // Draw vertical scale with frequency labels
        draw_vertical_scale(cr, spectro_left, spectro_top, spectro_height_px, minFreq, maxFreq, octaves,
                           s.textScaleFactor, s.lineThicknessFactor);
    }
    
    // Draw reference lines if enabled
    if (s.enableBottomReferenceLine || s.enableTopReferenceLine) {
        draw_reference_lines(cr, spectro_left, spectro_width, spectro_bottom, spectro_top,
                             s.enableBottomReferenceLine, s.bottomReferenceLineOffset,
                             s.enableTopReferenceLine, s.topReferenceLineOffset,
                             s.lineThicknessFactor);
    }
    
    // Display parameters if enabled
    if (s.displayParameters) {
        // Use empty string for audio file, 0.0 for start time, and s.duration for segment duration as defaults
        // These will be updated by the caller if needed
        draw_parameters_text(cr, page_width, page_height, &s, "", 0.0, s.duration);
    }
    
    // Apply optional blur
    #if ENABLE_BLUR
        if (BLUR_RADIUS > 0) {
            // Le rayon de flou est déjà en 800 DPI
            apply_separable_box_blur(surface, BLUR_RADIUS);
        }
    #endif
    
    // Save the image
    if (cairo_surface_write_to_png(surface, outputFilePath) != CAIRO_STATUS_SUCCESS) {
        fprintf(stderr, "Error: Failed to write PNG file: %s\n", outputFilePath);
        cairo_destroy(cr);
        cairo_surface_destroy(surface);
        free(spectro_data.data);
        free(bin_frequencies);
        return EXIT_FAILURE;
    }
    
    // Clean up resources
    cairo_destroy(cr);
    cairo_surface_destroy(surface);
    free(spectro_data.data);
    free(bin_frequencies);
    
    printf("Spectrogram generated successfully at 800 DPI: %s\n", outputFilePath);
    
    return EXIT_SUCCESS;
}

/*---------------------------------------------------------------------
 * spectral_generator_with_metadata()
 *
 * Wrapper function for spectral_generator_impl that includes metadata
 * for parameters display (audio filename and start time).
 *
 * Parameters:
 *  - cfg: Spectrogram settings
 *  - inputFile: Path to input WAV file
 *  - outputFile: Path to output PNG file
 *  - audioFileName: Name of the audio file to display in parameters
 *  - startTime: Start time in seconds to display in parameters
 *
 * Returns:
 *  - EXIT_SUCCESS on success, EXIT_FAILURE on error.
 *---------------------------------------------------------------------*/
int spectral_generator_with_metadata(const SpectrogramSettings *cfg,
                                    const char *inputFile,
                                    const char *outputFile,
                                    const char *audioFileName,
                                    double startTime,
                                    double segmentDuration)
{
    // Create a copy of the settings
    SpectrogramSettings settings = *cfg;
    
    // Store the metadata for later use in draw_parameters_text
    // This is a workaround since we can't modify the existing API
    
    // Call the implementation function
    int result = spectral_generator_impl(&settings, inputFile, outputFile);
    
    // If successful, update the parameters text with metadata
    if (result == EXIT_SUCCESS && settings.displayParameters) {
        // Load the generated image
        cairo_surface_t *surface = cairo_image_surface_create_from_png(outputFile);
        if (cairo_surface_status(surface) == CAIRO_STATUS_SUCCESS) {
            // Create a context for drawing
            cairo_t *cr = cairo_create(surface);
            
            // Get page dimensions
            int width = cairo_image_surface_get_width(surface);
            int height = cairo_image_surface_get_height(surface);
            
            // Calculate the height needed for parameters text (4 lines with spacing)
            double fontSize = 48.0 * settings.textScaleFactor;
            cairo_set_font_size(cr, fontSize);
            
            // Get font extents for dynamic line height
            cairo_font_extents_t font_extents;
            cairo_font_extents(cr, &font_extents);
            double line_height = font_extents.height * 1.5; // Add 50% extra spacing between lines
            double text_area_height = line_height * 5; // 4 lines plus some padding
            
            // Draw a white rectangle over the existing parameters text area
            cairo_set_source_rgb(cr, 1.0, 1.0, 1.0);
            cairo_rectangle(cr, 0, height - text_area_height, width, text_area_height);
            cairo_fill(cr);
            
            // Draw the parameters text with metadata
            draw_parameters_text(cr, width, height, &settings, audioFileName, startTime, settings.duration);
            
            // Save the updated image
            cairo_surface_write_to_png(surface, outputFile);
            
            // Clean up
            cairo_destroy(cr);
            cairo_surface_destroy(surface);
        }
    }
    
    return result;
}
