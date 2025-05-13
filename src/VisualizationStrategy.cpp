/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#include "../include/VisualizationStrategy.h"
#include "../include/FileManager.h"
#include <QDebug>
#include <QFuture>
#include <QtConcurrent/QtConcurrent>

VisualizationStrategy::VisualizationStrategy(QObject *parent)
    : QObject(parent)
{
}

bool VisualizationStrategy::generate(const SpectrogramSettingsCpp& settings, 
                                   const QString& inputFile,
                                   const QString& outputFile)
{
    // Validate input and output files
    if (!FileManager::validateInputFile(inputFile)) {
        emit generationCompleted(false, "", "Input file does not exist or is not readable");
        return false;
    }
    
    // Check that the output directory exists
    QString outputDir = QFileInfo(outputFile).path();
    if (!FileManager::ensureDirectoryExists(outputDir)) {
        emit generationCompleted(false, "", "Unable to create output directory");
        return false;
    }
    
    // Convert parameters to C structure
    SpectrogramSettings cSettings = settings.toCStruct();
    
    // Execute generation in a separate thread
    QFuture<void> future = QtConcurrent::run([=]() {
        this->runGeneration(cSettings, inputFile, outputFile);
    });
    
    return true;
}

void VisualizationStrategy::runGeneration(const SpectrogramSettings& settings,
                                        const QString& inputFile,
                                        const QString& outputFile)
{
    // Add detailed logs
    qDebug() << "Generating spectrogram with strategy: " << getName();
    qDebug() << "Input file: " << inputFile;
    qDebug() << "Output file: " << outputFile;
    qDebug() << "Bins per second: " << settings.binsPerSecond;
    qDebug() << "Overlap preset: " << (settings.overlapPreset == 0 ? "Low" :
                                     settings.overlapPreset == 2 ? "High" : "Medium");
    
    emit progressUpdated(10, "Preparing generation...");
    
    // Convert QString to const char* for C API
    QByteArray inputFileBytes = inputFile.toLocal8Bit();
    QByteArray outputFileBytes = outputFile.toLocal8Bit();
    
    const char *inputFileCStr = inputFileBytes.constData();
    const char *outputFileCStr = outputFileBytes.constData();
    
    emit progressUpdated(20, "Generating spectrogram...");
    
    // Call the strategy-specific C function
    int result = callGeneratorFunction(settings, inputFileCStr, outputFileCStr);
    
    emit progressUpdated(90, "Finalizing...");
    
    // Emit signal with the result
    if (result == EXIT_SUCCESS) {
        qDebug() << "Spectrogram successfully generated at: " << outputFile;
        // Check that the file exists
        if (QFile::exists(outputFile)) {
            qDebug() << "Output file exists, emitting success signal";
            emit progressUpdated(100, "Generation completed successfully");
            emit generationCompleted(true, outputFile);
        } else {
            qWarning() << "Output file does not exist: " << outputFile;
            emit generationCompleted(false, "", "Output file was not created");
        }
    } else {
        qWarning() << "Failed to generate spectrogram, error code: " << result;
        emit generationCompleted(false, "", "Error generating spectrogram (code: " + QString::number(result) + ")");
    }
}