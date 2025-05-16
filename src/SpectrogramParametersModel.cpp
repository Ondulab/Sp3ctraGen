/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#include "../include/SpectrogramParametersModel.h"
#include "../include/SharedConstants.h"
#include <QtMath>
#include <QDebug>

SpectrogramParametersModel::SpectrogramParametersModel(QObject *parent)
    : QObject(parent)
    // Initialize with default values
    , m_minFreq(20.0)
    , m_maxFreq(20000.0)
    , m_duration(120.0)
    , m_sampleRate(44100)
    , m_dynamicRangeDB(70.0)
    , m_gammaCorrection(1.0)
    , m_enableDithering(true)
    , m_contrastFactor(1.0)
    , m_writingSpeed(2.5)
    , m_resolutionSliderValue(0.5) // Balanced resolution
    , m_enableHighBoost(false)
    , m_highBoostAlpha(0.75)
    , m_enableHighPassFilter(false)
    , m_highPassCutoffFreq(20.0)
    , m_highPassFilterOrder(2)
    , m_enableNormalization(true)
    , m_pageFormat(0) // A4 portrait
    , m_bottomMarginMM(10.0)
    , m_spectroHeightMM(180.0)
    , m_enableVerticalScale(true)
    , m_enableBottomReferenceLine(false)
    , m_bottomReferenceLineOffset(-34.75)
    , m_enableTopReferenceLine(false)
    , m_topReferenceLineOffset(12.55)
    , m_displayParameters(false)
    , m_textScaleFactor(2.0)
    , m_lineThicknessFactor(2.0)
    , m_overlapPreset(1) // Medium
    , m_printerDpi(400.0) // Valeur par défaut pour la résolution d'impression
    , m_binsPerSecond(150.0) // Default value
    , m_fftSize(2048) // Default value
    , m_effectiveOverlap(0.5) // Default value
    , m_audioDuration(0.0) // Default value, will be calculated by generator
    , m_isResolutionLimited(false) // Default value
    , m_batchUpdating(false)
    , m_paramsChanged(false)
{
    // No initial calculation of derived values needed here anymore
}

SpectrogramParametersModel::~SpectrogramParametersModel()
{
    // No special cleanup needed
}

void SpectrogramParametersModel::beginUpdate()
{
    m_batchUpdating = true;
}

void SpectrogramParametersModel::endUpdate()
{
    if (m_batchUpdating) {
        m_batchUpdating = false;
        
        if (m_paramsChanged) {
            m_paramsChanged = false;
            // invalidateCache(); // Cache removed
            emit parametersChanged();
        }
    }
}

SpectrogramSettings SpectrogramParametersModel::toCStruct() const
{
    // Convert the C++ model to the C structure
    SpectrogramSettings settings;
    
    // Copy basic parameters
    settings.minFreq = m_minFreq;
    settings.maxFreq = m_maxFreq;
    settings.duration = m_duration; // This duration is the input from user, not the calculated one for page
    settings.sampleRate = m_sampleRate;
    settings.dynamicRangeDB = m_dynamicRangeDB;
    settings.gammaCorrection = m_gammaCorrection;
    settings.enableDithering = m_enableDithering ? 1 : 0;
    settings.contrastFactor = m_contrastFactor;
    settings.enableHighBoost = m_enableHighBoost ? 1 : 0;
    settings.highBoostAlpha = m_highBoostAlpha;
    settings.pageFormat = m_pageFormat;
    settings.bottomMarginMM = m_bottomMarginMM;
    settings.spectroHeightMM = m_spectroHeightMM;
    settings.writingSpeed = m_writingSpeed;
    settings.enableHighPassFilter = m_enableHighPassFilter ? 1 : 0;
    settings.highPassCutoffFreq = m_highPassCutoffFreq;
    settings.highPassFilterOrder = m_highPassFilterOrder;
    settings.enableNormalization = m_enableNormalization ? 1 : 0;
    settings.enableVerticalScale = m_enableVerticalScale ? 1 : 0;
    settings.enableBottomReferenceLine = m_enableBottomReferenceLine ? 1 : 0;
    settings.bottomReferenceLineOffset = m_bottomReferenceLineOffset;
    settings.enableTopReferenceLine = m_enableTopReferenceLine ? 1 : 0;
    settings.topReferenceLineOffset = m_topReferenceLineOffset;
    settings.displayParameters = m_displayParameters ? 1 : 0;
    settings.textScaleFactor = m_textScaleFactor;
    settings.lineThicknessFactor = m_lineThicknessFactor;
    
    // Copy derived parameters from member variables
    settings.binsPerSecond = m_binsPerSecond;
    settings.overlapPreset = m_overlapPreset; // overlapPreset is still an input
    settings.fftSize = m_fftSize;
    settings.printerDpi = m_printerDpi;
    // Note: effectiveOverlap is not directly in SpectrogramSettings struct,
    // it's derived from fftSize and hopSize (which is sampleRate/binsPerSecond)
    // The generator will use fftSize and binsPerSecond to determine the actual overlap.
    // The audioDuration for the actual spectrogram output based on page size is calculated by the generator.
    
    return settings;
}

double SpectrogramParametersModel::getOverlapValueFromPreset() const
{
    // Map preset (0, 1, 2) to updated overlap values (0.3, 0.6, 0.85)
    // These values are within the requested range of 0.3 to 0.92
    const double OVERLAP_LOW = 0.3;
    const double OVERLAP_MEDIUM = 0.6;
    const double OVERLAP_HIGH = 0.85;
    
    switch (m_overlapPreset) {
        case 0: return OVERLAP_LOW;
        case 1: return OVERLAP_MEDIUM;
        case 2: return OVERLAP_HIGH;
        default: return OVERLAP_MEDIUM;
    }
}

void SpectrogramParametersModel::emitChangeSignal(bool batch)
{
    if (batch) {
        m_paramsChanged = true;
        if (!m_batchUpdating) {
            // invalidateCache(); // Cache removed
            emit parametersChanged();
            m_paramsChanged = false;
        }
    } else {
        // invalidateCache(); // Cache removed
        // If not batching, and a single param changes, we might still want to emit parametersChanged
        // Or rely on individual signals. For now, keep as is, assuming individual signals are sufficient
        // or batching is used for multiple changes.
    }
}

// Setter implementations
void SpectrogramParametersModel::setMinFreq(double value)
{
    if (m_minFreq != value) {
        m_minFreq = value;
        emit minFreqChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setMaxFreq(double value)
{
    if (m_maxFreq != value) {
        m_maxFreq = value;
        emit maxFreqChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setDuration(double value)
{
    if (m_duration != value) {
        m_duration = value;
        emit durationChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setSampleRate(int value)
{
    if (m_sampleRate != value) {
        m_sampleRate = value;
        emit sampleRateChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setDynamicRangeDB(double value)
{
    if (m_dynamicRangeDB != value) {
        m_dynamicRangeDB = value;
        emit dynamicRangeDBChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setGammaCorrection(double value)
{
    if (m_gammaCorrection != value) {
        m_gammaCorrection = value;
        emit gammaCorrectionChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setEnableDithering(bool value)
{
    if (m_enableDithering != value) {
        m_enableDithering = value;
        emit enableDitheringChanged(); 
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setContrastFactor(double value)
{
    if (m_contrastFactor != value) {
        m_contrastFactor = value;
        emit contrastFactorChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setWritingSpeed(double value)
{
    if (m_writingSpeed != value) {
        m_writingSpeed = value;
        emit writingSpeedChanged();
        emitChangeSignal(true); // Writing speed is an input parameter, derived values will be updated by generator
    }
}

void SpectrogramParametersModel::setResolutionSliderValue(double value)
{
    if (m_resolutionSliderValue != value) {
        m_resolutionSliderValue = value;
        emit resolutionSliderValueChanged();
        emitChangeSignal(true); // Slider value is an input parameter
    }
}

void SpectrogramParametersModel::setEnableHighBoost(bool value)
{
    if (m_enableHighBoost != value) {
        m_enableHighBoost = value;
        emit enableHighBoostChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setHighBoostAlpha(double value)
{
    if (m_highBoostAlpha != value) {
        m_highBoostAlpha = value;
        emit highBoostAlphaChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setEnableHighPassFilter(bool value)
{
    if (m_enableHighPassFilter != value) {
        m_enableHighPassFilter = value;
        emit enableHighPassFilterChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setHighPassCutoffFreq(double value)
{
    if (m_highPassCutoffFreq != value) {
        m_highPassCutoffFreq = value;
        emit highPassCutoffFreqChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setHighPassFilterOrder(int value)
{
    if (m_highPassFilterOrder != value) {
        m_highPassFilterOrder = value;
        emit highPassFilterOrderChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setEnableNormalization(bool value)
{
    if (m_enableNormalization != value) {
        m_enableNormalization = value;
        emit enableNormalizationChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setPageFormat(int value)
{
    if (m_pageFormat != value) {
        m_pageFormat = value;
        emit pageFormatChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setBottomMarginMM(double value)
{
    if (m_bottomMarginMM != value) {
        m_bottomMarginMM = value;
        emit bottomMarginMMChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setSpectroHeightMM(double value)
{
    if (m_spectroHeightMM != value) {
        m_spectroHeightMM = value;
        emit spectroHeightMMChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setEnableVerticalScale(bool value)
{
    if (m_enableVerticalScale != value) {
        m_enableVerticalScale = value;
        emit enableVerticalScaleChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setEnableBottomReferenceLine(bool value)
{
    if (m_enableBottomReferenceLine != value) {
        m_enableBottomReferenceLine = value;
        emit enableBottomReferenceLineChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setBottomReferenceLineOffset(double value)
{
    if (m_bottomReferenceLineOffset != value) {
        m_bottomReferenceLineOffset = value;
        emit bottomReferenceLineOffsetChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setEnableTopReferenceLine(bool value)
{
    if (m_enableTopReferenceLine != value) {
        m_enableTopReferenceLine = value;
        emit enableTopReferenceLineChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setTopReferenceLineOffset(double value)
{
    if (m_topReferenceLineOffset != value) {
        m_topReferenceLineOffset = value;
        emit topReferenceLineOffsetChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setDisplayParameters(bool value)
{
    if (m_displayParameters != value) {
        m_displayParameters = value;
        emit displayParametersChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setTextScaleFactor(double value)
{
    if (m_textScaleFactor != value) {
        m_textScaleFactor = value;
        emit textScaleFactorChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setLineThicknessFactor(double value)
{
    if (m_lineThicknessFactor != value) {
        m_lineThicknessFactor = value;
        emit lineThicknessFactorChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setOverlapPreset(int value)
{
    if (m_overlapPreset != value && value >= 0 && value <= 2) {
        m_overlapPreset = value;
        emit overlapPresetChanged();
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setPrinterDpi(double value)
{
    if (m_printerDpi != value && value >= 72.0 && value <= 1200.0) {
        m_printerDpi = value;
        emit printerDpiChanged();
        emitChangeSignal(true); // Printer DPI is an input parameter
    }
}

// Setters for derived properties
void SpectrogramParametersModel::setBinsPerSecond(double value)
{
    if (m_binsPerSecond != value) {
        m_binsPerSecond = value;
        emit binsPerSecondChanged();
        // No emitChangeSignal(true) here as this is a derived value set externally
    }
}

void SpectrogramParametersModel::setFftSize(int value)
{
    if (m_fftSize != value) {
        m_fftSize = value;
        emit fftSizeChanged();
    }
}

void SpectrogramParametersModel::setEffectiveOverlap(double value)
{
    if (m_effectiveOverlap != value) {
        m_effectiveOverlap = value;
        emit effectiveOverlapChanged();
    }
}

void SpectrogramParametersModel::setAudioDuration(double value)
{
    if (m_audioDuration != value) {
        m_audioDuration = value;
        emit audioDurationChanged();
    }
}

void SpectrogramParametersModel::setIsResolutionLimited(bool value)
{
    if (m_isResolutionLimited != value) {
        m_isResolutionLimited = value;
        emit isResolutionLimitedChanged();
    }
}
