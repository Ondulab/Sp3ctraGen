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
    
    // Utiliser la méthode du modèle de paramètres pour calculer la durée audio
    // à partir du format papier et de la vitesse d'écriture
    return m_parametersModel->calculateAudioDuration();
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
    
    connect(m_generator, &SpectrogramGenerator::fftParametersCalculated,
            this, &SpectrogramViewModel::onFftParametersCalculated);
    
    if (!m_parametersModel) return;
    
    // Connecter les signaux du modèle de paramètres qui affectent la durée audio
    connect(m_parametersModel, &SpectrogramParametersModel::pageFormatChanged,
            this, &SpectrogramViewModel::audioDurationChanged);
    
    connect(m_parametersModel, &SpectrogramParametersModel::writingSpeedChanged,
            this, &SpectrogramViewModel::audioDurationChanged);
    
    // Connexion générale pour tout changement de paramètres
    connect(m_parametersModel, &SpectrogramParametersModel::parametersChanged,
            this, &SpectrogramViewModel::audioDurationChanged);
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
    
    // Convert model's parameters to C++ values (used by generator internally)
    m_parametersModel->toCStruct();
    
    // Get visualization type
    QString visualizationType = "Raster (PNG)"; // Default
    
    // Call the generator with consolidated parameters
    m_generator->generateSpectrogram(
        m_parametersModel->minFreq(),
        m_parametersModel->maxFreq(),
        m_parametersModel->duration(),
        m_parametersModel->sampleRate(),
        m_parametersModel->dynamicRangeDB(),
        m_parametersModel->gammaCorrection(),
        m_parametersModel->enableDithering(),
        m_parametersModel->contrastFactor(),
        m_parametersModel->enableHighBoost(),
        m_parametersModel->highBoostAlpha(),
        m_parametersModel->enableHighPassFilter(),
        m_parametersModel->highPassCutoffFreq(),
        m_parametersModel->highPassFilterOrder(),
        m_parametersModel->pageFormat(),
        m_parametersModel->bottomMarginMM(),
        m_parametersModel->spectroHeightMM(),
        m_parametersModel->writingSpeed(),
        inputFile,
        outputFolder,
        visualizationType,
        m_parametersModel->enableNormalization(),
        m_parametersModel->binsPerSecond(),
        m_parametersModel->overlapPreset()
    );
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
    
    // Call the generator with consolidated parameters
    m_generator->generatePreview(
        m_parametersModel->minFreq(),
        m_parametersModel->maxFreq(),
        m_parametersModel->duration(),
        m_parametersModel->sampleRate(),
        m_parametersModel->dynamicRangeDB(),
        m_parametersModel->gammaCorrection(),
        m_parametersModel->enableDithering(),
        m_parametersModel->contrastFactor(),
        m_parametersModel->enableHighBoost(),
        m_parametersModel->highBoostAlpha(),
        m_parametersModel->enableHighPassFilter(),
        m_parametersModel->highPassCutoffFreq(),
        m_parametersModel->highPassFilterOrder(),
        m_parametersModel->pageFormat(),
        m_parametersModel->bottomMarginMM(),
        m_parametersModel->spectroHeightMM(),
        m_parametersModel->writingSpeed(),
        inputFile,
        m_parametersModel->enableVerticalScale(),
        m_parametersModel->enableBottomReferenceLine(),
        m_parametersModel->bottomReferenceLineOffset(),
        m_parametersModel->enableTopReferenceLine(),
        m_parametersModel->topReferenceLineOffset(),
        m_parametersModel->displayParameters(),
        m_parametersModel->textScaleFactor(),
        m_parametersModel->lineThicknessFactor(),
        m_parametersModel->binsPerSecond(),
        m_parametersModel->overlapPreset()
    );
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
    
    // Calculate segment duration from size and sample rate
    double segmentDuration = audioSegment.size() / 
                           (sizeof(float) * m_parametersModel->sampleRate());
    
    // Call the generator with consolidated parameters
    m_generator->generateSpectrogramFromSegment(
        m_parametersModel->minFreq(),
        m_parametersModel->maxFreq(),
        segmentDuration,
        m_parametersModel->sampleRate(),
        m_parametersModel->dynamicRangeDB(),
        m_parametersModel->gammaCorrection(),
        m_parametersModel->enableDithering(),
        m_parametersModel->contrastFactor(),
        m_parametersModel->enableHighBoost(),
        m_parametersModel->highBoostAlpha(),
        m_parametersModel->enableHighPassFilter(),
        m_parametersModel->highPassCutoffFreq(),
        m_parametersModel->highPassFilterOrder(),
        m_parametersModel->pageFormat(),
        m_parametersModel->bottomMarginMM(),
        m_parametersModel->spectroHeightMM(),
        m_parametersModel->writingSpeed(),
        m_parametersModel->enableVerticalScale(),
        m_parametersModel->enableBottomReferenceLine(),
        m_parametersModel->bottomReferenceLineOffset(),
        m_parametersModel->enableTopReferenceLine(),
        m_parametersModel->topReferenceLineOffset(),
        m_parametersModel->displayParameters(),
        m_parametersModel->textScaleFactor(),
        m_parametersModel->lineThicknessFactor(),
        audioSegment,
        originalFileName,
        startTime,
        m_parametersModel->binsPerSecond(),
        m_parametersModel->overlapPreset()
    );
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

void SpectrogramViewModel::onFftParametersCalculated(int calculatedFftSize, double effectiveOverlap, double binsPerSecond)
{
    // No action needed, parameters model is updated directly
    // Could add special logic here if needed
    qDebug() << "FFT parameters calculated: size=" << calculatedFftSize 
             << ", overlap=" << effectiveOverlap 
             << ", bps=" << binsPerSecond;
}
