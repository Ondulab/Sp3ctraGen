/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#include "../include/SpectrogramSettingsCpp.h"
#include "../include/SpectrogramParametersModel.h" // Needed for the new constructor
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
    , m_highPassCutoffFreq(100.0)  // Valeur raisonnable par défaut pour le passe-haut
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
    , m_fftSize(0) // 0 signifie calcul automatique
    , m_printerDpi(DEFAULT_PRINTER_DPI) // Valeur par défaut pour la résolution d'impression
{
}

// Constructeur à partir de SpectrogramParametersModel
SpectrogramSettingsCpp::SpectrogramSettingsCpp(const SpectrogramParametersModel* model)
{
    if (!model) {
        qWarning() << "SpectrogramSettingsCpp: SpectrogramParametersModel pointer is null, initializing with default settings.";
        // Initialize with default values (delegating to default constructor or setting them here)
        *this = SpectrogramSettingsCpp(); // Use default constructor
        return;
    }

    initFromQmlParameters(
        model->minFreq(),
        model->maxFreq(),
        model->duration(),
        model->sampleRate(),
        model->dynamicRangeDB(),
        model->gammaCorrection(),
        model->enableDithering(),
        model->contrastFactor(),
        model->enableHighBoost(),
        model->highBoostAlpha(),
        model->enableHighPassFilter(),
        model->highPassCutoffFreq(),
        model->highPassFilterOrder(),
        model->pageFormat(),
        model->bottomMarginMM(),
        model->spectroHeightMM(),
        model->writingSpeed(),
        model->enableNormalization(),
        model->enableVerticalScale(),
        model->enableBottomReferenceLine(),
        model->bottomReferenceLineOffset(),
        model->enableTopReferenceLine(),
        model->topReferenceLineOffset(),
        model->displayParameters(),
        model->textScaleFactor(),
        model->lineThicknessFactor(),
        model->binsPerSecond(),      // Use the current (possibly derived) value from model
        model->overlapPreset(),
        model->printerDpi()
    );
    // Ensure resolutionSliderValue is also set, as it's used in calculations
    setResolutionSliderValue(model->resolutionSliderValue());
    // Note: fftSize is calculated within initFromQmlParameters or later by generator logic
    // m_isResolutionLimited is also determined during calculations
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
    
    // Debug: Afficher la valeur de la fréquence de coupure
    qDebug() << "DEBUG - toCStruct - m_highPassCutoffFreq = " << m_highPassCutoffFreq;
    
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
    cSettings.fftSize = m_fftSize; // Transfert de la taille FFT calculée
    cSettings.printerDpi = m_printerDpi; // Transfert de la résolution d'impression
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
    settings.m_fftSize = cSettings.fftSize; // Récupération de la taille FFT
    settings.m_printerDpi = cSettings.printerDpi; // Récupération de la résolution d'impression
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
    int overlapPreset,
    double printerDpi)
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
    // IMPORTANT: Afficher la valeur reçue pour débogage
    qDebug() << "DEBUG - Valeur de highPassCutoffFreq reçue depuis QML: " << highPassCutoffFreq;
    m_highPassCutoffFreq = highPassCutoffFreq;
    qDebug() << "DEBUG - Après assignation, m_highPassCutoffFreq = " << m_highPassCutoffFreq;
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
    m_printerDpi = printerDpi;
    
    // Log détaillé pour le débogage du paramètre DPI
    qDebug() << "DEBUG - initFromQmlParameters - Résolution d'impression (DPI) définie à:" << m_printerDpi;
    
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
    // S'assurer que la valeur de binsPerSecond est utilisée (pas une constante)
    double actualBinsPerSecond = m_binsPerSecond;
    double hopSize = sampleRate / actualBinsPerSecond;
    
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
    // maxBps = ⌊(DPI/2.54) × writeSpeed⌋
    return floor((m_printerDpi / INCH_TO_CM) * writingSpeed);
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
 * @brief Calcule le bins/s optimal en fonction de la vitesse d'écriture et de la résolution d'impression
 *
 * Cette méthode implémente la nouvelle logique :
 * 1. Le bins/s est automatiquement adapté à la résolution d'impression (800 dpi)
 * 2. Le slider de résolution contrôle désormais uniquement l'overlap (temporel/spectral)
 * 3. La relation est garantie: durée = largeur papier (cm) / writeSpeed (cm/s)
 *
 * @param sliderValue Position du curseur (0.0 à 1.0) - Utilisé uniquement pour les logs
 * @param writingSpeed Vitesse d'écriture en cm/s
 * @return Valeur de bins/s optimale calculée
 */
double SpectrogramSettingsCpp::calculateBpsFromSlider(double sliderValue, double writingSpeed) const
{
    // Calcul du bins/s optimal basé sur la résolution d'impression
    // Formula: bins_per_second = (DPI / 2.54 cm/inch) * writeSpeed
    double optimalBps = (m_printerDpi / INCH_TO_CM) * writingSpeed;
    
    // Arrondir à l'entier inférieur pour s'assurer qu'on ne dépasse jamais la résolution physique
    optimalBps = floor(optimalBps);
    
    // Vérifier si la limitation est atteinte
    m_isResolutionLimited = (optimalBps <= MIN_BINS_PER_SECOND || optimalBps >= MAX_BINS_PER_SECOND);
    
    // Appliquer les limites (clamp)
    if (optimalBps < MIN_BINS_PER_SECOND) {
        optimalBps = MIN_BINS_PER_SECOND;
    } else if (optimalBps > MAX_BINS_PER_SECOND) {
        optimalBps = MAX_BINS_PER_SECOND;
    }
    
    qDebug() << "Resolution calculation - slider value:" << sliderValue
             << "writing speed (cm/s):" << writingSpeed
             << "optimal bins/s:" << optimalBps
             << "limited:" << m_isResolutionLimited;
    
    return optimalBps;
}

/**
 * @brief Calcule la valeur d'overlap en fonction de la position du curseur
 *
 * Cette méthode implémente une interpolation linéaire entre les trois ancres du curseur:
 * - Temporal (0): Très faible chevauchement (privilégie la résolution temporelle)
 * - Balanced (0.5): Chevauchement moyen (équilibre temps/fréquence)
 * - Spectral (1.0): Fort chevauchement (privilégie la résolution fréquentielle)
 *
 * Avec la nouvelle approche, le curseur contrôle directement et uniquement l'overlap,
 * puisque le bins/s est calculé automatiquement par rapport à la résolution physique.
 *
 * @param sliderValue Position du curseur (0.0 à 1.0)
 * @return Valeur d'overlap calculée
 */
double SpectrogramSettingsCpp::calculateOverlapFromSlider(double sliderValue) const
{
    // Définir des valeurs d'overlap plus extrêmes pour offrir une meilleure distinction
    // entre le mode temporel (0.30) et le mode spectral (0.92)
    const double TEMPORAL_OVERLAP = 0.30;  // Faible overlap = meilleure résolution temporelle
    const double BALANCED_OVERLAP = 0.75;  // Overlap moyen = compromis
    const double SPECTRAL_OVERLAP = 0.92;  // Fort overlap = meilleure résolution spectrale
    
    if (sliderValue <= 0.5) {
        // Interpolation linéaire entre Temporal (0) et Balanced (0.5)
        return TEMPORAL_OVERLAP +
               (sliderValue / 0.5) * (BALANCED_OVERLAP - TEMPORAL_OVERLAP);
    } else {
        // Interpolation linéaire entre Balanced (0.5) et Spectral (1.0)
        return BALANCED_OVERLAP +
               ((sliderValue - 0.5) / 0.5) * (SPECTRAL_OVERLAP - BALANCED_OVERLAP);
    }
}

/**
 * @brief Détermine le préréglage d'overlap à utiliser en fonction de la position du curseur
 *
 * Cette méthode permet de synchroniser la position du curseur de résolution
 * avec les préréglages d'overlap existants :
 * - Slidervalue 0.0-0.33   -> Preset Low (0)
 * - Slidervalue 0.33-0.67  -> Preset Medium (1)
 * - Slidervalue 0.67-1.0   -> Preset High (2)
 *
 * @param sliderValue Position du curseur (0.0 à 1.0)
 * @return Préréglage d'overlap correspondant (0=Low, 1=Medium, 2=High)
 */
int SpectrogramSettingsCpp::getOverlapPresetFromSlider(double sliderValue) const
{
    // Diviser la plage du curseur en trois segments égaux
    if (sliderValue < 0.33) {
        // Zone Temporal (0.0 - 0.33) -> Low overlap
        return 0;
    } else if (sliderValue < 0.67) {
        // Zone Balanced (0.33 - 0.67) -> Medium overlap
        return 1;
    } else {
        // Zone Spectral (0.67 - 1.0) -> High overlap
        return 2;
    }
}
