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
    , m_cacheValid(false)
    , m_cachedBps(-1.0)
    , m_cachedFftSize(-1)
    , m_cachedOverlap(-1.0)
    , m_resolutionLimited(false)
    , m_batchUpdating(false)
    , m_paramsChanged(false)
{
    // Initial calculation of derived values
    recalculateDerivedValues();
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
            invalidateCache();
            emit parametersChanged();
        }
    }
}

double SpectrogramParametersModel::calculateBpsFromSlider(double sliderValue)
{
    // Préserver la valeur du curseur
    m_resolutionSliderValue = sliderValue;
    
    // Calcul du maximum physiquement imprimable (bins/s)
    // Cette limite DOIT être respectée quelle que soit la position du curseur
    double maxBps = calculateMaxBps(m_writingSpeed);
    
    // Calcul du bins/s effectif selon la position du curseur
    // Modulation entre résolution temporelle et fréquentielle
    double bps;
    if (sliderValue <= 0.5) {
        // De 0.0 à 0.5 (Temporel): haute densité temporelle, 75%-100% du maximum
        bps = maxBps * (0.75 + 0.25 * (1.0 - sliderValue * 2.0));
    } else {
        // De 0.5 à 1.0 (Spectral): densité réduite, 20%-75% du maximum
        bps = maxBps * (0.75 - 0.55 * ((sliderValue - 0.5) * 2.0));
    }
    
    // Respecter les limites physiques
    bps = qMin(bps, maxBps);
    bps = qMax(bps, 20.0); // minimum 20 bins/s
    
    // Vérifier si on atteint la limite physique (95% ou plus du maximum)
    m_resolutionLimited = (bps >= maxBps * 0.95);
    
    // Mettre en cache et retourner
    m_cachedBps = bps;
    
    // Recalculate all derived values
    recalculateDerivedValues();
    
    return bps;
}

double SpectrogramParametersModel::calculateOverlapFromSlider(double sliderValue)
{
    // Le overlap n'est plus directement contrôlé par le curseur
    // Il devient une valeur dérivée du rapport entre FFT size et hop size
    // Cette fonction est conservée pour compatibilité avec le code existant
    
    // Les positions du curseur correspondent généralement à ces valeurs d'overlap:
    // 0.0 (Temporel): overlap faible (~0.3) car on veut des fenêtres très espacées
    // 1.0 (Spectral): overlap élevé (~0.92) car on veut des fenêtres très chevauchées
    
    // Interpolation linéaire entre les valeurs d'overlap selon le curseur
    double overlap = 0.3 + sliderValue * (0.92 - 0.3);
    
    // Déterminer le preset le plus proche pour compatibilité avec le code existant
    if (overlap < 0.4) {
        m_overlapPreset = 0; // Low
    } else if (overlap < 0.7) {
        m_overlapPreset = 1; // Medium
    } else {
        m_overlapPreset = 2; // High
    }
    
    return overlap;
}

bool SpectrogramParametersModel::isResolutionLimited()
{
    return m_resolutionLimited;
}

double SpectrogramParametersModel::calculateAudioDuration()
{
    // Calculate the audio duration based on page format and writing speed
    // Get width in cm based on page format (A4 portrait or A3 landscape)
    double pageWidthCM = (m_pageFormat == 0) ? 21.0 : 42.0; // A4 width = 21cm, A3 width = 42cm
    
    // Adjust for margins if needed (simplified)
    double effectiveWidthCM = pageWidthCM - 2.0; // 1cm margin on each side
    
    // Calculate duration based on writing speed (cm/s)
    double duration = effectiveWidthCM / m_writingSpeed;
    
    return duration;
}

double SpectrogramParametersModel::calculateMaxBps(double writingSpeed)
{
    // Calculate maximum bins per second based on physical limitations
    // 800 DPI means 800 pixels per inch, or 800 / 2.54 pixels per cm
    const double DPI = 800.0;
    const double CM_TO_INCH = 2.54;
    
    // Max bins per second = (DPI / CM_TO_INCH) * writing speed
    double maxBps = std::floor((DPI / CM_TO_INCH) * writingSpeed);
    
    return maxBps;
}

SpectrogramSettings SpectrogramParametersModel::toCStruct() const
{
    // Convert the C++ model to the C structure
    SpectrogramSettings settings;
    
    // Copy basic parameters
    settings.minFreq = m_minFreq;
    settings.maxFreq = m_maxFreq;
    settings.duration = m_duration;
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
    
    // Calculate derived parameters if needed
    if (!m_cacheValid) {
        const_cast<SpectrogramParametersModel*>(this)->recalculateDerivedValues();
    }
    
    // Copy derived parameters
    settings.binsPerSecond = m_cachedBps;
    settings.overlapPreset = m_overlapPreset;
    settings.fftSize = m_cachedFftSize; // Transmettre la taille FFT calculée
    
    return settings;
}

double SpectrogramParametersModel::binsPerSecond()
{
    if (!m_cacheValid) {
        recalculateDerivedValues();
    }
    return m_cachedBps;
}

int SpectrogramParametersModel::fftSize()
{
    if (!m_cacheValid) {
        recalculateDerivedValues();
    }
    return m_cachedFftSize;
}

double SpectrogramParametersModel::effectiveOverlap()
{
    if (!m_cacheValid) {
        recalculateDerivedValues();
    }
    return m_cachedOverlap;
}

void SpectrogramParametersModel::invalidateCache()
{
    m_cacheValid = false;
}

void SpectrogramParametersModel::recalculateDerivedValues()
{
    // Calculer toutes les valeurs dérivées en fonction des paramètres actuels
    
    // 1. Obtenir le bins/s du curseur si pas déjà calculé
    if (m_cachedBps < 0) {
        m_cachedBps = calculateBpsFromSlider(m_resolutionSliderValue);
    }
    
    // 2. Calculer le hop size en échantillons (basé sur le taux d'échantillonnage et bins/s)
    double hopSize = static_cast<double>(m_sampleRate) / m_cachedBps;
    
    // 3. Déterminer la taille FFT selon la position du curseur
    // - Position 0.0 (Temporel): FFT courte (512-1024)
    // - Position 1.0 (Spectral): FFT longue (8192-16384)
    double baseSize;
    if (m_resolutionSliderValue <= 0.5) {
        // Position 0.0-0.5: petite FFT (512 à 2048)
        baseSize = 512.0 * std::pow(4.0, m_resolutionSliderValue * 2.0);
    } else {
        // Position 0.5-1.0: grande FFT (2048 à 16384)
        baseSize = 2048.0 * std::pow(8.0, (m_resolutionSliderValue - 0.5) * 2.0);
    }
    
    // Trouver la puissance de 2 la plus proche
    int powerOf2 = 1;
    while (powerOf2 < baseSize) {
        powerOf2 *= 2;
    }
    
    // 4. Ajuster la taille FFT pour le taux d'échantillonnage
    // Pour les taux d'échantillonnage élevés (>48kHz), augmenter proportionnellement
    if (m_sampleRate > 48000) {
        double scaleFactor = std::ceil(static_cast<double>(m_sampleRate) / 48000.0);
        powerOf2 = static_cast<int>(powerOf2 * scaleFactor);
        
        // S'assurer que c'est toujours une puissance de 2
        int newPowerOf2 = 1;
        while (newPowerOf2 < powerOf2) {
            newPowerOf2 *= 2;
        }
        powerOf2 = newPowerOf2;
    }
    
    m_cachedFftSize = powerOf2;
    
    // 5. Calculer l'overlap effectif (qui dépend maintenant du hop size et de la taille FFT)
    m_cachedOverlap = 1.0 - (hopSize / static_cast<double>(m_cachedFftSize));
    
    // S'assurer que l'overlap est dans une plage raisonnable
    if (m_cachedOverlap < 0.3) m_cachedOverlap = 0.3;
    if (m_cachedOverlap > 0.95) m_cachedOverlap = 0.95;
    
    // Déterminer le preset pour compatibilité avec le code existant
    if (m_cachedOverlap < 0.4) {
        m_overlapPreset = 0; // Low
    } else if (m_cachedOverlap < 0.7) {
        m_overlapPreset = 1; // Medium
    } else {
        m_overlapPreset = 2; // High
    }
    
    // Marquer le cache comme valide
    m_cacheValid = true;
    
    // Émettre les signaux pour les valeurs dérivées
    emit binsPerSecondChanged();
    emit fftSizeChanged();
    emit effectiveOverlapChanged();
    emit overlapPresetChanged();
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
            invalidateCache();
            emit parametersChanged();
            m_paramsChanged = false;
        }
    } else {
        invalidateCache();
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
        emit enablDitheringChanged();
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
        
        // Writing speed affects derived values like bps and effective duration
        m_cachedBps = -1.0; // Force recalculation
        emitChangeSignal(true);
    }
}

void SpectrogramParametersModel::setResolutionSliderValue(double value)
{
    if (m_resolutionSliderValue != value) {
        m_resolutionSliderValue = value;
        emit resolutionSliderValueChanged();
        
        // Resolution slider affects derived values
        m_cachedBps = -1.0; // Force recalculation
        emitChangeSignal(true);
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
