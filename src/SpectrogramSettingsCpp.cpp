/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#include "../include/SpectrogramSettingsCpp.h"
#include "../include/Constants.h"
#include <QDebug>

SpectrogramSettingsCpp::SpectrogramSettingsCpp()
    : m_minFreq(Constants::MIN_FREQ)
    , m_maxFreq(Constants::MAX_FREQ)
    , m_duration(Constants::DURATION)
    , m_sampleRate(Constants::SAMPLE_RATE)
    , m_dynamicRangeDB(Constants::DYNAMIC_RANGE)
    , m_gammaCorrection(Constants::GAMMA)
    , m_enableDithering(Constants::DITHERING)
    , m_contrastFactor(Constants::CONTRAST)
    , m_enableHighBoost(Constants::HIGH_BOOST)
    , m_highBoostAlpha(Constants::HIGH_BOOST_ALPHA_VAL)
    , m_enableHighPassFilter(false)
    , m_highPassCutoffFreq(0.0)
    , m_highPassFilterOrder(2)
    , m_pageFormat(Constants::PAGE_FORMAT_A4_PORTRAIT)
    , m_bottomMarginMM(Constants::BOTTOM_MARGIN)
    , m_spectroHeightMM(Constants::SPECTRO_HEIGHT)
    , m_writingSpeed(0.0)
    , m_enableNormalization(true) // By default, normalization is enabled
    , m_enableVerticalScale(true) // By default, vertical scale is enabled
    , m_enableBottomReferenceLine(false)
    , m_bottomReferenceLineOffset(-34.75) // Default offset in mm
    , m_enableTopReferenceLine(false)
    , m_topReferenceLineOffset(12.55) // Default offset in mm
    , m_displayParameters(false)
    , m_textScaleFactor(2.0) // Default text scale factor
    , m_lineThicknessFactor(2.0) // Default line thickness factor
    , m_binsPerSecond(DEFAULT_BINS_PER_SECOND) // Valeur par défaut pour bins/s
    , m_overlapPreset(DEFAULT_OVERLAP_PRESET) // Préréglage d'overlap (Medium par défaut)
    , m_resolutionSliderValue(0.5) // Valeur initiale du curseur: Balanced
    , m_isResolutionLimited(false) // Pas de limitation initialement
{
}

SpectrogramSettingsCpp SpectrogramSettingsCpp::defaultSettings()
{
    return SpectrogramSettingsCpp();
}

SpectrogramSettingsCpp SpectrogramSettingsCpp::highResolutionSettings()
{
    SpectrogramSettingsCpp settings;
    settings.m_binsPerSecond = 200.0; // Plus de bins par seconde
    settings.m_overlapPreset = 2; // High overlap
    settings.m_dynamicRangeDB = 70.0;
    settings.m_gammaCorrection = 0.7;
    settings.m_contrastFactor = 2.0;
    return settings;
}

// Méthode pour obtenir la valeur d'overlap en fonction du préréglage
double SpectrogramSettingsCpp::getOverlapValueFromPreset() const
{
    switch (m_overlapPreset) {
        case 0:
            return OVERLAP_PRESET_LOW;
        case 2:
            return OVERLAP_PRESET_HIGH;
        case 1:
        default:
            return OVERLAP_PRESET_MEDIUM;
    }
}

SpectrogramSettings SpectrogramSettingsCpp::toCStruct() const
{
    SpectrogramSettings cSettings;
    cSettings.minFreq = m_minFreq;
    cSettings.maxFreq = m_maxFreq;
    cSettings.duration = m_duration;
    cSettings.sampleRate = m_sampleRate;
    cSettings.dynamicRangeDB = m_dynamicRangeDB;
    cSettings.gammaCorrection = m_gammaCorrection;
    cSettings.enableDithering = m_enableDithering ? 1 : 0;
    cSettings.contrastFactor = m_contrastFactor;
    cSettings.enableHighBoost = m_enableHighBoost ? 1 : 0;
    cSettings.highBoostAlpha = m_highBoostAlpha;
    cSettings.enableHighPassFilter = m_enableHighPassFilter ? 1 : 0;
    cSettings.highPassCutoffFreq = m_highPassCutoffFreq;
    cSettings.highPassFilterOrder = m_highPassFilterOrder;
    cSettings.pageFormat = m_pageFormat;
    cSettings.bottomMarginMM = m_bottomMarginMM;
    cSettings.spectroHeightMM = m_spectroHeightMM;
    cSettings.writingSpeed = m_writingSpeed;
    cSettings.enableNormalization = m_enableNormalization ? 1 : 0;
    cSettings.enableVerticalScale = m_enableVerticalScale ? 1 : 0;
    cSettings.enableBottomReferenceLine = m_enableBottomReferenceLine ? 1 : 0;
    cSettings.bottomReferenceLineOffset = m_bottomReferenceLineOffset;
    cSettings.enableTopReferenceLine = m_enableTopReferenceLine ? 1 : 0;
    cSettings.topReferenceLineOffset = m_topReferenceLineOffset;
    cSettings.displayParameters = m_displayParameters ? 1 : 0;
    cSettings.textScaleFactor = m_textScaleFactor;
    cSettings.lineThicknessFactor = m_lineThicknessFactor;
    // Paramètres pour le mode bins/s
    cSettings.binsPerSecond = m_binsPerSecond;
    cSettings.overlapPreset = m_overlapPreset;
    return cSettings;
}

SpectrogramSettingsCpp SpectrogramSettingsCpp::fromCStruct(const SpectrogramSettings& cSettings)
{
    SpectrogramSettingsCpp settings;
    settings.m_minFreq = cSettings.minFreq;
    settings.m_maxFreq = cSettings.maxFreq;
    settings.m_duration = cSettings.duration;
    settings.m_sampleRate = cSettings.sampleRate;
    settings.m_dynamicRangeDB = cSettings.dynamicRangeDB;
    settings.m_gammaCorrection = cSettings.gammaCorrection;
    settings.m_enableDithering = cSettings.enableDithering != 0;
    settings.m_contrastFactor = cSettings.contrastFactor;
    settings.m_enableHighBoost = cSettings.enableHighBoost != 0;
    settings.m_highBoostAlpha = cSettings.highBoostAlpha;
    settings.m_enableHighPassFilter = cSettings.enableHighPassFilter != 0;
    settings.m_highPassCutoffFreq = cSettings.highPassCutoffFreq;
    settings.m_highPassFilterOrder = cSettings.highPassFilterOrder;
    settings.m_pageFormat = cSettings.pageFormat;
    settings.m_bottomMarginMM = cSettings.bottomMarginMM;
    settings.m_spectroHeightMM = cSettings.spectroHeightMM;
    settings.m_writingSpeed = cSettings.writingSpeed;
    settings.m_enableNormalization = cSettings.enableNormalization != 0;
    settings.m_enableVerticalScale = cSettings.enableVerticalScale != 0;
    settings.m_enableBottomReferenceLine = cSettings.enableBottomReferenceLine != 0;
    settings.m_bottomReferenceLineOffset = cSettings.bottomReferenceLineOffset;
    settings.m_enableTopReferenceLine = cSettings.enableTopReferenceLine != 0;
    settings.m_topReferenceLineOffset = cSettings.topReferenceLineOffset;
    settings.m_displayParameters = cSettings.displayParameters != 0;
    settings.m_textScaleFactor = cSettings.textScaleFactor;
    settings.m_lineThicknessFactor = cSettings.lineThicknessFactor;
    // Paramètres pour le mode bins/s
    settings.m_binsPerSecond = cSettings.binsPerSecond;
    settings.m_overlapPreset = cSettings.overlapPreset;
    return settings;
}

void SpectrogramSettingsCpp::initFromQmlParameters(
    double minFreq,
    double maxFreq,
    double duration,
    int sampleRate,
    double dynamicRangeDB,
    double gammaCorrection,
    bool enableDithering,
    double contrastFactor,
    bool enableHighBoost,
    double highBoostAlpha,
    bool enableHighPassFilter,
    double highPassCutoffFreq,
    int highPassFilterOrder,
    int pageFormat,
    double bottomMarginMM,
    double spectroHeightMM,
    double writingSpeed,
    bool enableNormalization,
    bool enableVerticalScale,
    bool enableBottomReferenceLine,
    double bottomReferenceLineOffset,
    bool enableTopReferenceLine,
    double topReferenceLineOffset,
    bool displayParameters,
    double textScaleFactor,
    double lineThicknessFactor,
    double binsPerSecond,
    int overlapPreset)
{
    // Log des valeurs avant mise à jour
    qDebug() << "DEBUG - initFromQmlParameters - Avant mise à jour:";
    qDebug() << "DEBUG -   m_minFreq (actuel) = " << m_minFreq;
    qDebug() << "DEBUG -   minFreq (reçu) = " << minFreq;
    qDebug() << "DEBUG -   m_maxFreq (actuel) = " << m_maxFreq;
    qDebug() << "DEBUG -   maxFreq (reçu) = " << maxFreq;
    qDebug() << "DEBUG -   Constants::MIN_FREQ = " << Constants::MIN_FREQ;
    
    m_minFreq = minFreq;
    m_maxFreq = maxFreq;
    m_duration = duration;
    m_sampleRate = sampleRate;
    m_dynamicRangeDB = dynamicRangeDB;
    m_gammaCorrection = gammaCorrection;
    m_enableDithering = enableDithering;
    m_contrastFactor = contrastFactor;
    m_enableHighBoost = enableHighBoost;
    m_highBoostAlpha = highBoostAlpha;
    m_enableHighPassFilter = enableHighPassFilter;
    m_highPassCutoffFreq = highPassCutoffFreq;
    m_highPassFilterOrder = highPassFilterOrder;
    m_pageFormat = pageFormat;
    m_bottomMarginMM = bottomMarginMM;
    m_spectroHeightMM = spectroHeightMM;
    m_writingSpeed = writingSpeed;
    m_enableNormalization = enableNormalization;
    m_enableVerticalScale = enableVerticalScale;
    m_enableBottomReferenceLine = enableBottomReferenceLine;
    m_bottomReferenceLineOffset = bottomReferenceLineOffset;
    m_enableTopReferenceLine = enableTopReferenceLine;
    m_topReferenceLineOffset = topReferenceLineOffset;
    m_displayParameters = displayParameters;
    m_textScaleFactor = textScaleFactor;
    m_lineThicknessFactor = lineThicknessFactor;
    m_binsPerSecond = binsPerSecond;
    m_overlapPreset = overlapPreset;
    
    // Log des valeurs après mise à jour
    qDebug() << "DEBUG - initFromQmlParameters - Après mise à jour:";
    qDebug() << "DEBUG -   m_minFreq = " << m_minFreq;
    qDebug() << "DEBUG -   m_maxFreq = " << m_maxFreq;
    qDebug() << "DEBUG -   m_binsPerSecond = " << m_binsPerSecond;
    qDebug() << "DEBUG -   m_overlapPreset = " << m_overlapPreset;
    qDebug() << "DEBUG -   Overlap value = " << getOverlapValueFromPreset();
}

/**
 * @brief Calcule la taille FFT optimale en fonction du taux d'échantillonnage, du nombre de bins/s et du préréglage d'overlap
 *
 * Cette méthode implémente le calcul automatique de la FFT size basé sur:
 * 1. Le taux d'échantillonnage de l'audio
 * 2. Le nombre de bins par seconde souhaité
 * 3. Le préréglage d'overlap sélectionné (Low, Medium, High)
 *
 * La formule utilisée est:
 *   FFT size = (Sample Rate / bins/s) / (1 - overlap)
 *
 * Le résultat est arrondi à la puissance de 2 supérieure pour optimiser les calculs FFT.
 *
 * @param sampleRate Le taux d'échantillonnage du fichier audio en Hz
 * @return La taille FFT calculée et optimisée
 */
int SpectrogramSettingsCpp::calculateFftSize(int sampleRate) const
{
    // Obtenir la valeur d'overlap correspondant au préréglage
    double overlapValue = getOverlapValueFromPreset();
    
    // Calculer le diviseur
    const double diviseur = 1.0 - overlapValue;
    
    // Calcul du hop size (pas entre fenêtres FFT) en échantillons
    double hopSize = sampleRate / m_binsPerSecond;
    
    // Calcul de la FFT size initiale
    int fftSize = static_cast<int>(hopSize / diviseur);
    
    // Arrondir à la puissance de 2 supérieure
    int powerOf2 = 1;
    while (powerOf2 < fftSize) {
        powerOf2 *= 2;
    }
    
    qDebug() << "Calculated FFT size:" << powerOf2
             << "from sample rate:" << sampleRate
             << "bins/s:" << m_binsPerSecond
             << "overlap preset:" << m_overlapPreset
             << "overlap value:" << overlapValue
             << "hop size:" << hopSize;
    
    return powerOf2;
}

/**
 * @brief Calcule le plafond physique maxBps en fonction de la vitesse d'écriture
 *
 * Cette méthode calcule le nombre maximum de bins par seconde qui peuvent être imprimés
 * en fonction de la vitesse d'écriture et de la résolution d'impression.
 *
 * Formule: maxBps = ⌊(800/2.54) × writeSpeed⌋
 *
 * @param writingSpeed Vitesse d'écriture en cm/s
 * @return Nombre maximum de bins par seconde possible
 */
double SpectrogramSettingsCpp::calculateMaxBps(double writingSpeed) const
{
    // maxBps = ⌊(800/2.54) × writeSpeed⌋
    return floor((PRINTER_DPI / INCH_TO_CM) * writingSpeed);
}

/**
 * @brief Obtient la largeur du papier en cm en fonction du format sélectionné
 *
 * @return Largeur du papier en cm
 */
double SpectrogramSettingsCpp::getPaperWidthCm() const
{
    if (m_pageFormat == Constants::PAGE_FORMAT_A4_PORTRAIT) {
        return A4_PORTRAIT_WIDTH_CM;
    } else {
        return A3_LANDSCAPE_WIDTH_CM;
    }
}

/**
 * @brief Calcule la durée audio représentée en fonction du format papier et de la vitesse d'écriture
 *
 * Formule: durée (s) = largeur papier (cm) / writeSpeed (cm/s)
 *
 * @return Durée audio en secondes
 */
double SpectrogramSettingsCpp::calculateAudioDuration() const
{
    // durée (s) = largeur papier (cm) / writeSpeed (cm/s)
    return getPaperWidthCm() / m_writingSpeed;
}

/**
 * @brief Calcule le bins/s en fonction de la position du curseur et de la vitesse d'écriture
 *
 * Cette méthode implémente une interpolation linéaire entre les trois ancres du curseur:
 * - Temporal (0): Privilégie la résolution temporelle
 * - Balanced (0.5): Équilibre entre résolution temporelle et fréquentielle
 * - Spectral (1.0): Privilégie la résolution fréquentielle
 *
 * La valeur de bps est limitée entre MIN_BINS_PER_SECOND et MAX_BINS_PER_SECOND
 * et ne peut pas dépasser le plafond physique maxBps.
 *
 * @param sliderValue Position du curseur (0.0 à 1.0)
 * @param writingSpeed Vitesse d'écriture en cm/s
 * @return Valeur de bps calculée
 */
double SpectrogramSettingsCpp::calculateBpsFromSlider(double sliderValue, double writingSpeed) const
{
    double maxBps = calculateMaxBps(writingSpeed);
    double ratio;
    
    if (sliderValue <= 0.5) {
        // Interpolation linéaire entre Temporal (0) et Balanced (0.5)
        ratio = RESOLUTION_TEMPORAL_RATIO +
                (sliderValue / 0.5) * (RESOLUTION_BALANCED_RATIO - RESOLUTION_TEMPORAL_RATIO);
    } else {
        // Interpolation linéaire entre Balanced (0.5) et Spectral (1.0)
        ratio = RESOLUTION_BALANCED_RATIO +
                ((sliderValue - 0.5) / 0.5) * (RESOLUTION_SPECTRAL_RATIO - RESOLUTION_BALANCED_RATIO);
    }
    
    // Calculer le bps initial
    double bps = ratio * maxBps;
    
    // Vérifier si la limitation est atteinte
    m_isResolutionLimited = (bps <= MIN_BINS_PER_SECOND || bps >= MAX_BINS_PER_SECOND);
    
    // Appliquer les limites (clamp)
    if (bps < MIN_BINS_PER_SECOND) {
        bps = MIN_BINS_PER_SECOND;
    } else if (bps > MAX_BINS_PER_SECOND) {
        bps = MAX_BINS_PER_SECOND;
    }
    
    qDebug() << "Resolution slider value:" << sliderValue
             << "maxBps:" << maxBps
             << "ratio:" << ratio
             << "calculated bps:" << bps
             << "limited:" << m_isResolutionLimited;
    
    return bps;
}

/**
 * @brief Calcule la valeur d'overlap en fonction de la position du curseur
 *
 * Cette méthode implémente une interpolation linéaire entre les trois ancres du curseur:
 * - Temporal (0): Faible chevauchement
 * - Balanced (0.5): Chevauchement moyen
 * - Spectral (1.0): Fort chevauchement
 *
 * @param sliderValue Position du curseur (0.0 à 1.0)
 * @return Valeur d'overlap calculée
 */
double SpectrogramSettingsCpp::calculateOverlapFromSlider(double sliderValue) const
{
    if (sliderValue <= 0.5) {
        // Interpolation linéaire entre Temporal (0) et Balanced (0.5)
        return RESOLUTION_TEMPORAL_OVERLAP +
               (sliderValue / 0.5) * (RESOLUTION_BALANCED_OVERLAP - RESOLUTION_TEMPORAL_OVERLAP);
    } else {
        // Interpolation linéaire entre Balanced (0.5) et Spectral (1.0)
        return RESOLUTION_BALANCED_OVERLAP +
               ((sliderValue - 0.5) / 0.5) * (RESOLUTION_SPECTRAL_OVERLAP - RESOLUTION_BALANCED_OVERLAP);
    }
}