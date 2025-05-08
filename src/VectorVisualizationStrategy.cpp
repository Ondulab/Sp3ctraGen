#include "../include/VectorVisualizationStrategy.h"
#include <QDebug>

// Déclaration externe de la fonction C
extern "C" {
    int spectral_generator_vector_pdf_impl(const SpectrogramSettings *cfg,
                                          const char *inputFile,
                                          const char *outputFile,
                                          int dpi);
}

VectorVisualizationStrategy::VectorVisualizationStrategy(QObject *parent)
    : VisualizationStrategy(parent)
    , m_dpi(800) // Résolution par défaut
{
}

QString VectorVisualizationStrategy::getName() const
{
    return "Vectoriel (PDF)";
}

QString VectorVisualizationStrategy::getDescription() const
{
    return QString("Génère un spectrogramme au format vectoriel (PDF) avec une résolution de %1 DPI").arg(m_dpi);
}

QStringList VectorVisualizationStrategy::getSupportedExtensions() const
{
    return QStringList() << "pdf";
}

void VectorVisualizationStrategy::setDpi(int dpi)
{
    if (dpi > 0) {
        m_dpi = dpi;
    }
}

int VectorVisualizationStrategy::getDpi() const
{
    return m_dpi;
}

int VectorVisualizationStrategy::callGeneratorFunction(const SpectrogramSettings& settings,
                                                     const char* inputFile,
                                                     const char* outputFile)
{
    qDebug() << "Appel de spectral_generator_vector_pdf_impl pour la génération du PDF vectoriel";
    qDebug() << "Résolution: " << m_dpi << " DPI";
    return spectral_generator_vector_pdf_impl(&settings, inputFile, outputFile, m_dpi);
}
