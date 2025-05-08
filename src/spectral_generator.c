#include "spectral_common.h"
#include "spectral_wav_processing.h"
#include "spectral_fft.h"

// Déclarations externes des fonctions implémentées dans les autres modules
extern int spectral_generator_impl(const SpectrogramSettings *cfg, 
                                  const char *inputFile, 
                                  const char *outputFile);

extern int spectral_generator_vector_pdf_impl(const SpectrogramSettings *cfg, 
                                             const char *inputFile, 
                                             const char *outputFile, 
                                             int dpi);

/*---------------------------------------------------------------------
 * spectral_generator()
 *
 * Wrapper pour la fonction d'implémentation dans spectral_raster.c
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
    // Redirecteur vers l'implémentation dans spectral_raster.c
    return spectral_generator_impl(cfg, inputFile, outputFile);
}

/*---------------------------------------------------------------------
 * spectral_generator_vector_pdf()
 *
 * Wrapper pour la fonction d'implémentation dans spectral_vector.c
 *
 * Generates a vector PDF spectrogram with precise physical dimensions.
 * Uses Cairo PDF surface for high-quality vector output.
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
int spectral_generator_vector_pdf(const SpectrogramSettings *cfg,
                                  const char *inputFile,
                                  const char *outputFile,
                                  int dpi)
{
    // Redirecteur vers l'implémentation dans spectral_vector.c
    return spectral_generator_vector_pdf_impl(cfg, inputFile, outputFile, dpi);
}
