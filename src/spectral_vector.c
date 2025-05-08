#include "spectral_common.h"
#include "spectral_wav_processing.h"
#include "spectral_fft.h"
#include <cairo/cairo-pdf.h>  // Ajout de l'en-tête spécifique pour les fonctions PDF

/*---------------------------------------------------------------------
 * spectral_generator_vector_pdf_impl()
 *
 * Generates a vector PDF spectrogram with precise physical dimensions.
 * Uses Cairo PDF surface for high-quality vector output.
 * Uses exact parameters specified by the user without automatic adjustments.
 * 
 * Parameters:
 *  - cfg: Spectrogram settings structure
 *  - inputFile: Path to input WAV file
 *  - outputFile: Path to output PDF file
 *  - dpi: Requested DPI for the vector output (e.g. 800)
 *
 * Returns:
 *  - EXIT_SUCCESS on success, EXIT_FAILURE on error.
 *---------------------------------------------------------------------*/
int spectral_generator_vector_pdf_impl(const SpectrogramSettings *cfg,
                                      const char *inputFile,
                                      const char *outputFile,
                                      int dpi)
{
    /* Copy configuration and fallback to defaults if necessary */
    SpectrogramSettings s = *cfg;
    int     fft_size      = DEFAULT_INT(s.fftSize,        DEFAULT_FFT_SIZE);
    double  overlap       = DEFAULT_DBL(s.overlap,        DEFAULT_OVERLAP);
    double  minFreq       = DEFAULT_DBL(s.minFreq,        DEFAULT_MIN_FREQ);
    double  maxFreq       = DEFAULT_DBL(s.maxFreq,        DEFAULT_MAX_FREQ);
    double  writingSpeed  = DEFAULT_DBL(s.writingSpeed,   0.0);
    double  duration      = DEFAULT_DBL(s.duration,       DEFAULT_DURATION);
    int     sample_rate   = DEFAULT_INT(s.sampleRate,     DEFAULT_SAMPLE_RATE);
    double  dynamicRangeDB = DEFAULT_DBL(s.dynamicRangeDB, DYNAMIC_RANGE_DB);
    double  gammaCorr     = DEFAULT_DBL(s.gammaCorrection, GAMMA_CORRECTION);
    int     enableDither  = DEFAULT_BOOL(s.enableDithering, ENABLE_DITHERING);
    double  contrastFactor = DEFAULT_DBL(s.contrastFactor, CONTRAST_FACTOR);
    
    /* Use default paths if input/output files are not specified */
    const char* inputFilePath = DEFAULT_STR(inputFile, DEFAULT_INPUT_FILE);
    const char* outputFilePath = DEFAULT_STR(outputFile, DEFAULT_PDF_OUTPUT);
    
    /* Validate DPI */
    if (dpi <= 0) {
        dpi = 300; // Fallback to standard 300 DPI
    }
    
    printf("Vector PDF generation parameters:\n");
    printf(" - Resolution: %d DPI\n", dpi);
    printf(" - FFT size: %d\n", fft_size);
    printf(" - Overlap: %f\n", overlap);
    printf(" - Min frequency: %f\n", minFreq);
    printf(" - Max frequency: %f\n", maxFreq);
    printf(" - Writing speed: %f cm/s\n", writingSpeed);
    printf(" - Input file: %s\n", inputFilePath);
    printf(" - Output file: %s\n", outputFilePath);
    
    /* ------------------------------ */
    /* 1. Calculate physical dimensions */
    /* ------------------------------ */
    // Sélection du format de page en millimètres selon le paramètre
    double page_width_mm, page_height_mm;
    if (s.pageFormat == 1) { // A3 paysage
        page_width_mm = A3_WIDTH_MM;
        page_height_mm = A3_HEIGHT_MM;
        printf(" - Page format: A3 landscape (%.1f x %.1f mm)\n", page_width_mm, page_height_mm);
    } else { // A4 portrait (par défaut)
        page_width_mm = A4_WIDTH_MM;
        page_height_mm = A4_HEIGHT_MM;
        printf(" - Page format: A4 portrait (%.1f x %.1f mm)\n", page_width_mm, page_height_mm);
    }
    
    // Conversion en points (unité PDF)
    double page_width_pt = page_width_mm * MM_TO_POINTS;
    double page_height_pt = page_height_mm * MM_TO_POINTS;
    printf(" - Page dimensions: %.2f x %.2f points\n", page_width_pt, page_height_pt);
    
    /* ------------------------------ */
    /* 2. Load audio signal from WAV  */
    /* ------------------------------ */
    int total_samples = 0;
    double *signal = NULL;
    
    // Si une vitesse d'écriture est spécifiée, calculer la durée
    if (writingSpeed > 0.0) {
        // Calculer la durée: durée (s) = largeur (cm) / vitesse (cm/s)
        double page_width_cm = page_width_mm / 10.0; // mm to cm
        duration = page_width_cm / writingSpeed;
        
        // Mettre à jour la durée dans la structure s
        s.duration = duration;
        
        printf(" - Calculated duration based on writing speed: %.2f seconds\n", duration);
    }
    
    printf(" - Loading WAV file with duration: %.2f seconds\n", s.duration);
    if (load_wav_file(inputFilePath, &signal, &total_samples, &sample_rate, s.duration) != 0) {
        fprintf(stderr, "Error: Unable to load WAV file.\n");
        return EXIT_FAILURE;
    }
    
    // Apply audio processing if enabled (high-pass filter, etc.)
    int enableHighPass = DEFAULT_BOOL(s.enableHighPassFilter, 0);
    double highPassCutoff = DEFAULT_DBL(s.highPassCutoffFreq, 0.0);
    int highPassOrder = DEFAULT_INT(s.highPassFilterOrder, 2);
    int enableHighBoost = DEFAULT_BOOL(s.enableHighBoost, ENABLE_HIGH_BOOST);
    double highBoostAlpha = DEFAULT_DBL(s.highBoostAlpha, HIGH_BOOST_ALPHA);
    
    if (enableHighPass && highPassCutoff > 0.0) {
        printf(" - High-pass filter: enabled (cutoff = %.2f Hz, order = %d)\n", 
               highPassCutoff, highPassOrder);
        
        double a[13] = {0};
        double b[13] = {0};
        design_highpass_filter(highPassCutoff, highPassOrder, sample_rate, a, b);
        apply_highpass_filter(signal, total_samples, a, b, highPassOrder);
    }
    
    if (enableHighBoost) {
        apply_high_freq_boost_filter(signal, total_samples, highBoostAlpha);
    }
    
    /* ------------------------------ */
    /* 3. Compute spectrogram data    */
    /* ------------------------------ */
    SpectrogramData spectro_data = {0};
    
    if (compute_spectrogram(signal, total_samples, sample_rate, fft_size, overlap,
                           minFreq, maxFreq, &spectro_data) != 0) {
        fprintf(stderr, "Error: Failed to compute spectrogram.\n");
        free(signal);
        return EXIT_FAILURE;
    }
    
    // We no longer need the audio signal
    free(signal);
    signal = NULL;
    
    // Apply image processing
    apply_image_processing(&spectro_data, dynamicRangeDB, gammaCorr, enableDither, contrastFactor);
    
    /* ------------------------------ */
    /* 4. Create PDF surface          */
    /* ------------------------------ */
    // Définir la surface PDF en utilisant les dimensions physiques
    cairo_surface_t *surface = cairo_pdf_surface_create(outputFilePath, page_width_pt, page_height_pt);
    if (cairo_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
        fprintf(stderr, "Error: Unable to create PDF surface.\n");
        free(spectro_data.data);
        return EXIT_FAILURE;
    }
    
    // Calculer le facteur d'échelle pour la résolution demandée
    double scale_factor = dpi / POINTS_PER_INCH; // PDF utilise 72 points par pouce
    (void)scale_factor; // Pour éviter le warning de variable non utilisée
    
    // Créer le contexte Cairo
    cairo_t *cr = cairo_create(surface);
    if (cr == NULL) {
        fprintf(stderr, "Error: Unable to create Cairo context.\n");
        cairo_surface_destroy(surface);
        free(spectro_data.data);
        return EXIT_FAILURE;
    }
    
    // Appliquer la résolution au document PDF
    cairo_pdf_surface_set_size(surface, page_width_pt, page_height_pt);
    
    // Fond blanc
    cairo_set_source_rgb(cr, 1.0, 1.0, 1.0);
    cairo_paint(cr);
    
    /* ------------------------------ */
    /* 5. Définir les marges          */
    /* ------------------------------ */
    // Marges en millimètres, converties en points
    double margin_mm = 20.0; // 20mm de marge
    double margin_pt = margin_mm * MM_TO_POINTS;
    
    // Zone utile du spectrogramme
    double spectro_width_pt = page_width_pt - (2 * margin_pt);
    double spectro_height_pt;
    
    // Calculer la hauteur du spectrogramme en fonction des réglages utilisateur
    if (s.spectroHeightMM > 0) {
        spectro_height_pt = s.spectroHeightMM * MM_TO_POINTS;
    } else {
        // Par défaut: hauteur adaptée pour conserver les proportions selon l'échelle fréquentielle
        double freq_range_ratio = (maxFreq - minFreq) / (sample_rate / 2.0);
        spectro_height_pt = spectro_width_pt * freq_range_ratio * 0.75; // Facteur 0.75 pour éviter un spectro trop haut
        
        // Limiter la hauteur maximale
        double max_height_pt = page_height_pt - (2 * margin_pt);
        if (spectro_height_pt > max_height_pt) {
            spectro_height_pt = max_height_pt;
        }
    }
    
    // Position du spectrogramme
    double spectro_x = margin_pt;
    double spectro_y = (page_height_pt - spectro_height_pt) / 2; // Centré verticalement
    
    /* ------------------------------ */
    /* 6. Dessiner le cadre et les axes */
    /* ------------------------------ */
    // Style des traits pour les vecteurs
    cairo_set_line_width(cr, 0.5);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    
    // Cadre du spectrogramme
    cairo_rectangle(cr, spectro_x, spectro_y, spectro_width_pt, spectro_height_pt);
    cairo_stroke(cr);
    
    // Extraire les données du spectrogramme
    int num_windows = spectro_data.num_windows;
    int num_bins = spectro_data.num_bins;
    int index_min = spectro_data.index_min;
    int index_max = spectro_data.index_max;
    double *spectrogram = spectro_data.data;
    double freq_range = maxFreq - minFreq;
    
    // Grille fréquentielle (tous les 1kHz ou octaves selon l'échelle)
    cairo_set_line_width(cr, 0.2);
    cairo_set_source_rgba(cr, 0.5, 0.5, 0.5, 0.5);
    
    // Dessiner des lignes horizontales pour les fréquences (toutes les octaves)
    cairo_select_font_face(cr, "Arial", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, 8);
    
    if (USE_LOG_FREQUENCY) {
        // Échelle logarithmique par octaves
        double octave_min = log2(minFreq);
        double octave_max = log2(maxFreq);
        
        for (double octave = ceil(octave_min); octave <= floor(octave_max); octave += 1.0) {
            double freq = pow(2.0, octave);
            double y_pos = spectro_y + spectro_height_pt * (1.0 - (log2(freq) - octave_min) / (octave_max - octave_min));
            
            // Ligne horizontale
            cairo_move_to(cr, spectro_x, y_pos);
            cairo_line_to(cr, spectro_x + spectro_width_pt, y_pos);
            cairo_stroke(cr);
            
            // Libellé de fréquence
            char label[32];
            if (freq >= 1000) {
                snprintf(label, sizeof(label), "%.1f kHz", freq / 1000.0);
            } else {
                snprintf(label, sizeof(label), "%.0f Hz", freq);
            }
            
            cairo_move_to(cr, spectro_x - 30, y_pos + 3);
            cairo_show_text(cr, label);
        }
    } else {
        // Échelle linéaire par paliers de 1 kHz
        int step = 1000; // 1 kHz par ligne
        if (freq_range > 10000) step = 2000; // Adapter pour les grandes plages
        
        for (int freq = ((int)minFreq / step) * step; freq <= maxFreq; freq += step) {
            if (freq < minFreq) continue;
            
            double y_pos = spectro_y + spectro_height_pt * (1.0 - (freq - minFreq) / freq_range);
            
            // Ligne horizontale
            cairo_move_to(cr, spectro_x, y_pos);
            cairo_line_to(cr, spectro_x + spectro_width_pt, y_pos);
            cairo_stroke(cr);
            
            // Libellé de fréquence
            char label[32];
            if (freq >= 1000) {
                snprintf(label, sizeof(label), "%d kHz", freq / 1000);
            } else {
                snprintf(label, sizeof(label), "%d Hz", freq);
            }
            
            cairo_move_to(cr, spectro_x - 30, y_pos + 3);
            cairo_show_text(cr, label);
        }
    }
    
    /* ------------------------------ */
    /* 7. Dessiner le spectrogramme   */
    /* ------------------------------ */
    // Calculate visible windows based on physical dimensions and writing speed
    int visible_windows = num_windows;
    double audio_duration = (double)spectro_data.num_windows / ((double)sample_rate / (fft_size * (1.0 - overlap)));
    
    if (writingSpeed > 0.0) {
        double page_width_cm = page_width_mm / 10.0;
        double spectrogram_width_cm = audio_duration * writingSpeed;
        
        if (spectrogram_width_cm > page_width_cm) {
            // Truncate to what fits on the page, but keep the scale exact
            double visible_duration = page_width_cm / writingSpeed;
            visible_windows = (int)(num_windows * (visible_duration / audio_duration));
            
            printf(" - Spectrogram exceeds page width, truncating to %d windows\n", visible_windows);
            printf(" - Shows first %.2f seconds (%.2f%% of total %.2f seconds)\n",
                  visible_duration, (visible_duration * 100.0 / audio_duration), audio_duration);
        }
    }
    
    // Calculer la taille d'un pixel du spectrogramme
    double window_width = spectro_width_pt / visible_windows;
    double bin_height = spectro_height_pt / (index_max - index_min + 1);
    
    // Dessiner chaque "pixel" du spectrogramme avec des rectangles vectoriels
    for (int w = 0; w < visible_windows; w++) {
        // Position X du "pixel"
        double x = spectro_x + w * window_width;
        
        for (int b = index_min; b <= index_max; b++) {
            // Intensité du "pixel" (0-1)
            double intensity = spectrogram[w * num_bins + b];
            
            // Calculer la position Y (inversée pour mettre les basses fréquences en bas)
            double y = spectro_y + spectro_height_pt - (b - index_min + 1) * bin_height;
            
            // Définir la couleur en niveaux de gris
            cairo_set_source_rgb(cr, intensity, intensity, intensity);
            
            // Dessiner le rectangle
            cairo_rectangle(cr, x, y, window_width, bin_height);
            cairo_fill(cr);
        }
    }
    
    /* ------------------------------ */
    /* 8. Ajouter les méta-informations */
    /* ------------------------------ */
    // Titre du document
    cairo_select_font_face(cr, "Arial", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
    cairo_set_font_size(cr, 14);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    
    char title[256];
    snprintf(title, sizeof(title), "Spectrogram: %s", inputFilePath);
    
    cairo_text_extents_t extents;
    cairo_text_extents(cr, title, &extents);
    cairo_move_to(cr, (page_width_pt - extents.width) / 2, margin_pt / 2);
    cairo_show_text(cr, title);
    
    // Informations sur les paramètres
    cairo_select_font_face(cr, "Arial", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, 8);
    
    char info[256];
    snprintf(info, sizeof(info), 
             "FFT: %d, Overlap: %.1f%%, Freq: %.0f-%.0f Hz, Resolution: %d DPI",
             fft_size, overlap * 100, minFreq, maxFreq, dpi);
    
    cairo_text_extents(cr, info, &extents);
    cairo_move_to(cr, (page_width_pt - extents.width) / 2, page_height_pt - margin_pt / 2);
    cairo_show_text(cr, info);
    
    /* ------------------------------ */
    /* 9. Finaliser et sauvegarder    */
    /* ------------------------------ */
    // Afficher la page et nettoyer
    cairo_show_page(cr);
    cairo_destroy(cr);
    cairo_surface_destroy(surface);
    
    // Libérer la mémoire
    free(spectro_data.data);
    
    printf("Vector PDF spectrogram generated successfully at %d DPI: %s\n", dpi, outputFilePath);
    
    return EXIT_SUCCESS;
}
