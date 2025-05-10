/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef VECTORVISUALIZATIONSTRATEGY_H
#define VECTORVISUALIZATIONSTRATEGY_H

#include "VisualizationStrategy.h"

/**
 * @brief Visualization strategy for vector spectrograms (PDF)
 *
 * This class implements the generation of spectrograms in vector format (PDF)
 * using the spectral_generator_vector_pdf_impl function.
 */
class VectorVisualizationStrategy : public VisualizationStrategy
{
    Q_OBJECT
    
public:
    explicit VectorVisualizationStrategy(QObject *parent = nullptr);
    virtual ~VectorVisualizationStrategy() = default;
    
    /**
     * @brief Gets the strategy name
     *
     * @return Strategy name
     */
    QString getName() const override;
    
    /**
     * @brief Gets the strategy description
     *
     * @return Strategy description
     */
    QString getDescription() const override;
    
    /**
     * @brief Gets the supported file extensions
     *
     * @return List of supported extensions (without the dot)
     */
    QStringList getSupportedExtensions() const override;
    
    /**
     * @brief Sets the DPI resolution for PDF generation
     *
     * @param dpi Resolution in DPI
     */
    void setDpi(int dpi);
    
    /**
     * @brief Gets the current DPI resolution
     *
     * @return Resolution in DPI
     */
    int getDpi() const;
    
protected:
    /**
     * @brief Specific implementation of generation for vector format
     *
     * @param settings Spectrogram settings
     * @param inputFile Input audio file
     * @param outputFile Output file
     * @return Return code (EXIT_SUCCESS or EXIT_FAILURE)
     */
    int callGeneratorFunction(const SpectrogramSettings& settings,
                             const char* inputFile,
                             const char* outputFile) override;
                      
    int m_dpi; // Resolution in DPI for PDF generation
};

#endif // VECTORVISUALIZATIONSTRATEGY_H