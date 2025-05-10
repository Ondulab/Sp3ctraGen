/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef VISUALIZATIONSTRATEGY_H
#define VISUALIZATIONSTRATEGY_H

#include <QString>
#include <QObject>
#include "SpectrogramSettingsCpp.h"

/**
 * @brief Strategy interface for different visualization types
 *
 * This class defines the common interface for all visualization strategies.
 * It uses the Strategy pattern to allow easy addition of new visualization types.
 * It also implements the Template Method pattern to factor common code.
 */
class VisualizationStrategy : public QObject
{
    Q_OBJECT
    
public:
    explicit VisualizationStrategy(QObject *parent = nullptr);
    virtual ~VisualizationStrategy() = default;
    
    /**
     * @brief Generates a visualization (Template Method)
     *
     * This method implements the skeleton of the generation algorithm
     * and delegates specific steps to subclasses.
     *
     * @param settings Spectrogram settings
     * @param inputFile Input audio file
     * @param outputFile Output file
     * @return true if generation started successfully
     */
    bool generate(const SpectrogramSettingsCpp& settings,
                 const QString& inputFile,
                 const QString& outputFile);
                         
    /**
     * @brief Gets the strategy name
     *
     * @return Strategy name
     */
    virtual QString getName() const = 0;
    
    /**
     * @brief Gets the strategy description
     *
     * @return Strategy description
     */
    virtual QString getDescription() const = 0;
    
    /**
     * @brief Gets the supported file extensions
     *
     * @return List of supported extensions (without the dot)
     */
    virtual QStringList getSupportedExtensions() const = 0;
    
protected:
    /**
     * @brief Abstract method for specific generation implementation
     *
     * This method must be implemented by subclasses to provide
     * the specific implementation of generation.
     *
     * @param settings Spectrogram settings
     * @param inputFile Input audio file
     * @param outputFile Output file
     * @return Return code (EXIT_SUCCESS or EXIT_FAILURE)
     */
    virtual int callGeneratorFunction(const SpectrogramSettings& settings,
                                     const char* inputFile,
                                     const char* outputFile) = 0;
    
    /**
     * @brief Executes generation in a separate thread
     *
     * @param settings Spectrogram settings
     * @param inputFile Input audio file
     * @param outputFile Output file
     */
    void runGeneration(const SpectrogramSettings& settings,
                      const QString& inputFile,
                      const QString& outputFile);
    
signals:
    /**
     * @brief Signal emitted during generation to indicate progress
     *
     * @param progress Progress (0-100)
     * @param message Progress message
     */
    void progressUpdated(int progress, const QString& message);
    
    /**
     * @brief Signal emitted when generation is complete
     *
     * @param success Generation success
     * @param outputPath Output file path
     * @param errorMessage Error message in case of failure
     */
    void generationCompleted(bool success, const QString& outputPath, const QString& errorMessage = "");
};

#endif // VISUALIZATIONSTRATEGY_H