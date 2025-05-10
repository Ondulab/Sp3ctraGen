/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef RASTERVISUALIZATIONSTRATEGY_H
#define RASTERVISUALIZATIONSTRATEGY_H

#include "VisualizationStrategy.h"

/**
 * @brief Visualization strategy for raster spectrograms (PNG)
 *
 * This class implements the generation of spectrograms in raster format (PNG)
 * using the spectral_generator_impl function.
 */
class RasterVisualizationStrategy : public VisualizationStrategy
{
    Q_OBJECT
    
public:
    explicit RasterVisualizationStrategy(QObject *parent = nullptr);
    virtual ~RasterVisualizationStrategy() = default;
    
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
    
protected:
    /**
     * @brief Specific implementation of generation for raster format
     *
     * @param settings Spectrogram settings
     * @param inputFile Input audio file
     * @param outputFile Output file
     * @return Return code (EXIT_SUCCESS or EXIT_FAILURE)
     */
    int callGeneratorFunction(const SpectrogramSettings& settings,
                             const char* inputFile,
                             const char* outputFile) override;
};

#endif // RASTERVISUALIZATIONSTRATEGY_H