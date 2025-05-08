#include "../include/RasterVisualizationStrategy.h"
#include <QDebug>

// Déclaration externe de la fonction C
extern "C" {
    int spectral_generator_impl(const SpectrogramSettings *cfg,
                               const char *inputFile,
                               const char *outputFile);
}

RasterVisualizationStrategy::RasterVisualizationStrategy(QObject *parent)
    : VisualizationStrategy(parent)
{
}


int RasterVisualizationStrategy::callGeneratorFunction(const SpectrogramSettings& settings,
                                                     const char* inputFile,
                                                     const char* outputFile)
{
    qDebug() << "Appel de spectral_generator_impl pour la génération du spectrogramme raster";
    return spectral_generator_impl(&settings, inputFile, outputFile);
}

QString RasterVisualizationStrategy::getName() const
{
    return "Raster (PNG)";
}

QString RasterVisualizationStrategy::getDescription() const
{
    return "Génère un spectrogramme au format raster (PNG) avec une résolution de 800 DPI";
}

QStringList RasterVisualizationStrategy::getSupportedExtensions() const
{
    return QStringList() << "png";
}