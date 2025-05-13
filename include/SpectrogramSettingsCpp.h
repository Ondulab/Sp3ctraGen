/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef SPECTROGRAMSETTINGSCPP_H
#define SPECTROGRAMSETTINGSCPP_H

#include <QString>
#include "spectral_generator.h"
#include "SharedConstants.h"

/**
 * @brief Unified C++ class for spectrogram settings
 *
 * This class encapsulates all parameters needed to generate a spectrogram
 * and provides methods to convert between this class and the C structure.
 */
class SpectrogramSettingsCpp {
public:
    // Constructeur par défaut
    SpectrogramSettingsCpp();
    
    // Factory methods for common presets
    static SpectrogramSettingsCpp defaultSettings();
    static SpectrogramSettingsCpp highResolutionSettings();
    
    // Conversion methods
    SpectrogramSettings toCStruct() const;
    static SpectrogramSettingsCpp fromCStruct(const SpectrogramSettings& cSettings);
    
    // Getters and setters
    int getOverlapPreset() const { return m_overlapPreset; }
    void setOverlapPreset(int value) { m_overlapPreset = value; }
    
    // Méthode pour obtenir la valeur d'overlap en fonction du préréglage
    double getOverlapValueFromPreset() const;
    
    double getMinFreq() const { return m_minFreq; }
    void setMinFreq(double value) { m_minFreq = value; }
    
    double getMaxFreq() const { return m_maxFreq; }
    void setMaxFreq(double value) { m_maxFreq = value; }
    
    double getDuration() const { return m_duration; }
    void setDuration(double value) { m_duration = value; }
    
    int getSampleRate() const { return m_sampleRate; }
    void setSampleRate(int value) { m_sampleRate = value; }
    
    double getDynamicRangeDB() const { return m_dynamicRangeDB; }
    void setDynamicRangeDB(double value) { m_dynamicRangeDB = value; }
    
    double getGammaCorrection() const { return m_gammaCorrection; }
    void setGammaCorrection(double value) { m_gammaCorrection = value; }
    
    bool getEnableDithering() const { return m_enableDithering; }
    void setEnableDithering(bool value) { m_enableDithering = value; }
    
    double getContrastFactor() const { return m_contrastFactor; }
    void setContrastFactor(double value) { m_contrastFactor = value; }
    
    bool getEnableHighBoost() const { return m_enableHighBoost; }
    void setEnableHighBoost(bool value) { m_enableHighBoost = value; }
    
    double getHighBoostAlpha() const { return m_highBoostAlpha; }
    void setHighBoostAlpha(double value) { m_highBoostAlpha = value; }
    
    bool getEnableHighPassFilter() const { return m_enableHighPassFilter; }
    void setEnableHighPassFilter(bool value) { m_enableHighPassFilter = value; }
    
    double getHighPassCutoffFreq() const { return m_highPassCutoffFreq; }
    void setHighPassCutoffFreq(double value) { m_highPassCutoffFreq = value; }
    
    int getHighPassFilterOrder() const { return m_highPassFilterOrder; }
    void setHighPassFilterOrder(int value) { m_highPassFilterOrder = value; }
    
    int getPageFormat() const { return m_pageFormat; }
    void setPageFormat(int value) { m_pageFormat = value; }
    
    double getBottomMarginMM() const { return m_bottomMarginMM; }
    void setBottomMarginMM(double value) { m_bottomMarginMM = value; }
    
    double getSpectroHeightMM() const { return m_spectroHeightMM; }
    void setSpectroHeightMM(double value) { m_spectroHeightMM = value; }
    
    double getWritingSpeed() const { return m_writingSpeed; }
    void setWritingSpeed(double value) { m_writingSpeed = value; }
    
    bool getEnableNormalization() const { return m_enableNormalization; }
    void setEnableNormalization(bool value) { m_enableNormalization = value; }
    
    // Output Format options
    bool getEnableVerticalScale() const { return m_enableVerticalScale; }
    void setEnableVerticalScale(bool value) { m_enableVerticalScale = value; }
    
    bool getEnableBottomReferenceLine() const { return m_enableBottomReferenceLine; }
    void setEnableBottomReferenceLine(bool value) { m_enableBottomReferenceLine = value; }
    
    double getBottomReferenceLineOffset() const { return m_bottomReferenceLineOffset; }
    void setBottomReferenceLineOffset(double value) { m_bottomReferenceLineOffset = value; }
    
    bool getEnableTopReferenceLine() const { return m_enableTopReferenceLine; }
    void setEnableTopReferenceLine(bool value) { m_enableTopReferenceLine = value; }
    
    double getTopReferenceLineOffset() const { return m_topReferenceLineOffset; }
    void setTopReferenceLineOffset(double value) { m_topReferenceLineOffset = value; }
    
    bool getDisplayParameters() const { return m_displayParameters; }
    void setDisplayParameters(bool value) { m_displayParameters = value; }
    
    double getTextScaleFactor() const { return m_textScaleFactor; }
    void setTextScaleFactor(double value) { m_textScaleFactor = value; }
    
    double getLineThicknessFactor() const { return m_lineThicknessFactor; }
    void setLineThicknessFactor(double value) { m_lineThicknessFactor = value; }
    
    // Méthodes pour bins/s
    double getBinsPerSecond() const { return m_binsPerSecond; }
    void setBinsPerSecond(double value) { m_binsPerSecond = value; }
    
    // Méthode pour calculer la FFT size en fonction du bins/s et du préréglage d'overlap
    int calculateFftSize(int sampleRate) const;
    
    // Method to initialize from QML parameters
    void initFromQmlParameters(
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
        bool enableNormalization = true,
        bool enableVerticalScale = true,
        bool enableBottomReferenceLine = false,
        double bottomReferenceLineOffset = -34.75,
        bool enableTopReferenceLine = false,
        double topReferenceLineOffset = 12.55,
        bool displayParameters = false,
        double textScaleFactor = 2.0,
        double lineThicknessFactor = 2.0,
        double binsPerSecond = DEFAULT_BINS_PER_SECOND,
        int overlapPreset = DEFAULT_OVERLAP_PRESET
    );
    
private:
    double m_minFreq;
    double m_maxFreq;
    double m_duration;
    int m_sampleRate;
    double m_dynamicRangeDB;
    double m_gammaCorrection;
    bool m_enableDithering;
    double m_contrastFactor;
    bool m_enableHighBoost;
    double m_highBoostAlpha;
    bool m_enableHighPassFilter;
    double m_highPassCutoffFreq;
    int m_highPassFilterOrder;
    int m_pageFormat;
    double m_bottomMarginMM;
    double m_spectroHeightMM;
    double m_writingSpeed;
    bool m_enableNormalization;
    bool m_enableVerticalScale;
    bool m_enableBottomReferenceLine;
    double m_bottomReferenceLineOffset;
    bool m_enableTopReferenceLine;
    double m_topReferenceLineOffset;
    bool m_displayParameters;
    double m_textScaleFactor;
    double m_lineThicknessFactor;
    double m_binsPerSecond;          // Bins par seconde
    int m_overlapPreset;             // Préréglage d'overlap (0=Low, 1=Medium, 2=High)
};

#endif // SPECTROGRAMSETTINGSCPP_H