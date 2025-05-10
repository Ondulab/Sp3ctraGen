/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#include "../include/SpectrogramSettingsCpp.h"
#include "../include/Constants.h"

SpectrogramSettingsCpp::SpectrogramSettingsCpp()
    : m_fftSize(Constants::FFT_SIZE)
    , m_overlap(Constants::OVERLAP)
    , m_minFreq(Constants::MIN_FREQ)
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
{
}

SpectrogramSettingsCpp SpectrogramSettingsCpp::defaultSettings()
{
    return SpectrogramSettingsCpp();
}

SpectrogramSettingsCpp SpectrogramSettingsCpp::highResolutionSettings()
{
    SpectrogramSettingsCpp settings;
    settings.m_fftSize = 16384;
    settings.m_overlap = 0.9;
    settings.m_dynamicRangeDB = 70.0;
    settings.m_gammaCorrection = 0.7;
    settings.m_contrastFactor = 2.0;
    return settings;
}

SpectrogramSettings SpectrogramSettingsCpp::toCStruct() const
{
    SpectrogramSettings cSettings;
    cSettings.fftSize = m_fftSize;
    cSettings.overlap = m_overlap;
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
    return cSettings;
}

SpectrogramSettingsCpp SpectrogramSettingsCpp::fromCStruct(const SpectrogramSettings& cSettings)
{
    SpectrogramSettingsCpp settings;
    settings.m_fftSize = cSettings.fftSize;
    settings.m_overlap = cSettings.overlap;
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
    return settings;
}

void SpectrogramSettingsCpp::initFromQmlParameters(
    int fftSize,
    double overlap,
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
    double lineThicknessFactor)
{
    m_fftSize = fftSize;
    m_overlap = overlap;
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
}