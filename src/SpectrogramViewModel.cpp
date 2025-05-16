/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#include "../include/SpectrogramViewModel.h"
#include <QDebug>
#include <QUuid>

SpectrogramViewModel::SpectrogramViewModel(QObject *parent)
    : QObject(parent)
    , m_parametersModel(nullptr)
    , m_generator(nullptr)
    , m_isGenerating(false)
    , m_statusMessage("")
    , m_hasPreview(false)
    , m_ownsParametersModel(false)
    , m_ownsGenerator(false)
{
    // Create default instances if not provided
    m_parametersModel = new SpectrogramParametersModel(this);
    m_ownsParametersModel = true;
    
    m_generator = new SpectrogramGenerator(this);
    m_ownsGenerator = true;
    
    // Connect signals
    connectSignals();
}

SpectrogramViewModel::~SpectrogramViewModel()
{
    // Clean up owned objects
    if (m_ownsParametersModel && m_parametersModel) {
        delete m_parametersModel;
        m_parametersModel = nullptr;
    }
    
    if (m_ownsGenerator && m_generator) {
        delete m_generator;
        m_generator = nullptr;
    }
}

void SpectrogramViewModel::initialize(SpectrogramParametersModel* paramsModel, SpectrogramGenerator* generator)
{
    // Cleanup owned objects first
    if (m_ownsParametersModel && m_parametersModel) {
        delete m_parametersModel;
    }
    
    if (m_ownsGenerator && m_generator) {
        delete m_generator;
    }
    
    // Set new objects with non-ownership
    m_parametersModel = paramsModel;
    m_generator = generator;
    m_ownsParametersModel = false;
    m_ownsGenerator = false;
    
    // Connect signals
    connectSignals();
}

double SpectrogramViewModel::audioDuration() const 
{
    if (!m_parametersModel) {
        return 0.0;
    }
    // Return the audioDuration property from the model, which is now set by onCalculatedParametersUpdated
    return m_parametersModel->audioDuration();
}

void SpectrogramViewModel::connectSignals()
{
    if (!m_generator) return;
    
    // Connect generator signals to this ViewModel
    connect(m_generator, &SpectrogramGenerator::spectrogramGenerated,
            this, &SpectrogramViewModel::onSpectrogramGenerated);
    
    connect(m_generator, &SpectrogramGenerator::previewGenerated,
            this, &SpectrogramViewModel::onPreviewGenerated);
    
    connect(m_generator, &SpectrogramGenerator::segmentPreviewGenerated,
            this, &SpectrogramViewModel::onSegmentPreviewGenerated);
    
    connect(m_generator, &SpectrogramGenerator::previewSaved,
            this, &SpectrogramViewModel::onPreviewSaved);
    
    connect(m_generator, &SpectrogramGenerator::taskProgressUpdated,
            this, &SpectrogramViewModel::onTaskProgressUpdated);
    
    // connect(m_generator, &SpectrogramGenerator::fftParametersCalculated, // Signal to be removed
    //         this, &SpectrogramViewModel::onFftParametersCalculated);
    
    // Connect the generator's calculatedParametersUpdated signal to the ViewModel's slot
    connect(m_generator, &SpectrogramGenerator::calculatedParametersUpdated,
            this, &SpectrogramViewModel::onCalculatedParametersUpdated);

    if (!m_parametersModel) return;
    
    // Connect the model's parametersChanged signal to the ViewModel's slot
    // This slot will then call the generator to update its internal state and recalculate.
    connect(m_parametersModel, &SpectrogramParametersModel::parametersChanged,
            this, &SpectrogramViewModel::onModelParametersChanged);

    // Individual signals like pageFormatChanged or writingSpeedChanged no longer need
    // to be directly connected to audioDurationChanged here, as onModelParametersChanged
    // will trigger a full recalculation via the generator, which then updates the model's audioDuration.
}

void SpectrogramViewModel::generateSpectrogram(const QString &inputFile, const QString &outputFolder)
{
    if (!m_parametersModel || !m_generator) {
        emit spectrogramGenerated(false, "", "Internal error: Models not initialized");
        return;
    }
    
    // Set status
    m_isGenerating = true;
    m_statusMessage = "Generating spectrogram...";
    emit isGeneratingChanged();
    emit statusMessageChanged();
    
    // Create SpectrogramSettingsCpp from the model
    SpectrogramSettingsCpp settings(m_parametersModel);
    
    // Get visualization type
    QString visualizationType = "Raster (PNG)"; // Default
    
    // Call the generator with the settings object
    m_generator->generateSpectrogram(settings, inputFile, outputFolder, visualizationType);
}

void SpectrogramViewModel::generatePreview(const QString &inputFile)
{
    if (!m_parametersModel || !m_generator) {
        emit previewGenerated(false, "Internal error: Models not initialized");
        return;
    }
    
    // Set status
    m_isGenerating = true;
    m_statusMessage = "Generating preview...";
    emit isGeneratingChanged();
    emit statusMessageChanged();
    
    // Create SpectrogramSettingsCpp from the model
    SpectrogramSettingsCpp settings(m_parametersModel);
    
    // Call the generator with the settings object
    m_generator->generatePreview(settings, inputFile);
}

void SpectrogramViewModel::generateSpectrogramFromSegment(
    const QByteArray &audioSegment, 
    const QString &originalFileName, 
    double startTime)
{
    if (!m_parametersModel || !m_generator) {
        emit previewGenerated(false, "Internal error: Models not initialized");
        return;
    }
    
    if (audioSegment.isEmpty()) {
        emit previewGenerated(false, "Empty audio segment");
        return;
    }
    
    // Set status
    m_isGenerating = true;
    m_statusMessage = "Generating spectrogram from segment...";
    emit isGeneratingChanged();
    emit statusMessageChanged();
    
    // Create SpectrogramSettingsCpp from the model
    SpectrogramSettingsCpp settings(m_parametersModel);

    // Calculate segment duration from size and sample rate and update settings
    // Note: The original generateSpectrogramFromSegment in generator took segmentDuration as a direct param.
    // Now that it takes SpectrogramSettingsCpp, we need to ensure the duration in settings is the segment's duration.
    // The SpectrogramSettingsCpp constructor from model will take model->duration().
    // We need to override it for this specific case.
    double segmentDuration = static_cast<double>(audioSegment.size()) / 
                           (sizeof(float) * settings.getSampleRate()); // Use sampleRate from settings
    settings.setDuration(segmentDuration); // Override duration for this segment generation
    
    // Call the generator with the settings object
    m_generator->generateSpectrogramFromSegment(settings, audioSegment, originalFileName, startTime);
}

void SpectrogramViewModel::saveCurrentPreview(const QString &outputFilePath, const QString &format)
{
    if (!m_generator) {
        emit previewSaved(false, "", format, "Generator not initialized");
        return;
    }
    
    if (!m_hasPreview) {
        emit previewSaved(false, "", format, "No preview to save");
        return;
    }
    
    m_statusMessage = "Saving preview...";
    emit statusMessageChanged();
    
    // Forward to generator
    m_generator->saveCurrentPreview(outputFilePath, format);
}

bool SpectrogramViewModel::printPreview()
{
    if (!m_generator) {
        return false;
    }
    
    if (!m_hasPreview) {
        return false;
    }
    
    m_statusMessage = "Printing preview...";
    emit statusMessageChanged();
    
    // Forward to generator
    return m_generator->printPreview();
}

QStringList SpectrogramViewModel::getAvailableVisualizationTypes() const
{
    if (!m_generator) {
        return QStringList();
    }
    
    return m_generator->getAvailableVisualizationTypes();
}

QString SpectrogramViewModel::normalizeAudioFile(const QString &inputPath, double factor)
{
    if (!m_generator) {
        return QString();
    }
    
    return m_generator->normalizeAudioFile(inputPath, factor);
}

double SpectrogramViewModel::calculateNormalizationFactor(const QString &audioPath)
{
    if (!m_generator) {
        return 1.0;
    }
    
    return m_generator->calculateNormalizationFactor(audioPath);
}

// Private slots to handle generator signals
void SpectrogramViewModel::onSpectrogramGenerated(bool success, const QString &outputPath, const QString &errorMessage)
{
    // Update status
    m_isGenerating = false;
    
    if (success) {
        m_statusMessage = "Spectrogram generated successfully: " + outputPath;
    } else {
        m_statusMessage = "Error generating spectrogram: " + errorMessage;
    }
    
    emit isGeneratingChanged();
    emit statusMessageChanged();
    
    // Forward signal to QML
    emit spectrogramGenerated(success, outputPath, errorMessage);
}

void SpectrogramViewModel::onPreviewGenerated(bool success, const QImage &previewImage, const QString &errorMessage)
{
    Q_UNUSED(previewImage);
    // Update status
    m_isGenerating = false;
    
    if (success) {
        m_statusMessage = "Preview generated successfully";
        m_hasPreview = true;
    } else {
        m_statusMessage = "Error generating preview: " + errorMessage;
    }
    
    emit isGeneratingChanged();
    emit statusMessageChanged();
    emit hasPreviewChanged();
    
    // Forward signal to QML (simplified version without image)
    emit previewGenerated(success, errorMessage);
}

void SpectrogramViewModel::onSegmentPreviewGenerated(bool success, const QImage &previewImage, const QString &errorMessage)
{
    Q_UNUSED(previewImage);
    // Update status
    m_isGenerating = false;
    
    if (success) {
        m_statusMessage = "Segment preview generated successfully";
        m_hasPreview = true;
    } else {
        m_statusMessage = "Error generating segment preview: " + errorMessage;
    }
    
    emit isGeneratingChanged();
    emit statusMessageChanged();
    emit hasPreviewChanged();
    
    // Forward signal to QML (simplified version without image)
    emit previewGenerated(success, errorMessage);
}

void SpectrogramViewModel::onPreviewSaved(bool success, const QString &outputPath, const QString &format, const QString &errorMessage)
{
    if (success) {
        m_statusMessage = "Preview saved successfully: " + outputPath;
    } else {
        m_statusMessage = "Error saving preview: " + errorMessage;
    }
    
    emit statusMessageChanged();
    
    // Forward signal to QML
    emit previewSaved(success, outputPath, format, errorMessage);
}

void SpectrogramViewModel::onTaskProgressUpdated(const QUuid &taskId, int progress, const QString &message)
{
    Q_UNUSED(taskId);
    m_statusMessage = message + " (" + QString::number(progress) + "%)";
    emit statusMessageChanged();
    
    // Forward signal to QML
    emit progressUpdated(progress, message);
}

// Removed SpectrogramViewModel::onFftParametersCalculated as the slot is removed from .h

void SpectrogramViewModel::onCalculatedParametersUpdated(double binsPerSecond, int calculatedFftSize, double effectiveOverlap, double audioDuration, bool isResolutionLimited)
{
    qDebug() << "SpectrogramViewModel::onCalculatedParametersUpdated - Received calculated parameters from Generator";
    qDebug() << "  - Bins/s:" << binsPerSecond;
    qDebug() << "  - FFT Size:" << calculatedFftSize;
    qDebug() << "  - Overlap:" << effectiveOverlap;
    qDebug() << "  - Audio Duration:" << audioDuration;
    qDebug() << "  - Resolution Limited:" << isResolutionLimited;

    if (m_parametersModel) {
        m_parametersModel->setBinsPerSecond(binsPerSecond);
        m_parametersModel->setFftSize(calculatedFftSize);
        m_parametersModel->setEffectiveOverlap(effectiveOverlap);
        m_parametersModel->setAudioDuration(audioDuration); // This will emit audioDurationChanged from the model
        m_parametersModel->setIsResolutionLimited(isResolutionLimited);
    }

    // Forward the signal to QML (if QML needs these values directly, otherwise it gets them from the model)
    // For now, we assume QML primarily reacts to model changes.
    // If direct forwarding is still needed for some QML components, this can be kept.
    // emit calculatedParametersUpdated(binsPerSecond, calculatedFftSize, effectiveOverlap, audioDuration, isResolutionLimited);
}

void SpectrogramViewModel::onModelParametersChanged()
{
    qDebug() << "SpectrogramViewModel::onModelParametersChanged - Model parameters have changed, updating generator.";
    if (!m_parametersModel || !m_generator) {
        qWarning() << "SpectrogramViewModel::onModelParametersChanged - Model or Generator not initialized!";
        return;
    }

    // Create SpectrogramSettingsCpp from the current state of m_parametersModel
    // using the new constructor.
    SpectrogramSettingsCpp settings(m_parametersModel);

    m_generator->updateInputParameters(settings);
}
