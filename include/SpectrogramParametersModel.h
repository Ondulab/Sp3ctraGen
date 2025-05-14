/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef SPECTROGRAMPARAMETERSMODEL_H
#define SPECTROGRAMPARAMETERSMODEL_H

#include <QObject>
#include <QQmlEngine>
#include "spectral_generator.h"

/**
 * @brief Model class for spectrogram parameters
 *
 * This class centralizes all parameters used for spectrogram generation
 * and provides a unified interface for QML and C++ backend.
 * It implements caching of derived values to avoid redundant calculations.
 */
class SpectrogramParametersModel : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    
    // Basic parameters
    Q_PROPERTY(double minFreq READ minFreq WRITE setMinFreq NOTIFY minFreqChanged)
    Q_PROPERTY(double maxFreq READ maxFreq WRITE setMaxFreq NOTIFY maxFreqChanged)
    Q_PROPERTY(double duration READ duration WRITE setDuration NOTIFY durationChanged)
    Q_PROPERTY(int sampleRate READ sampleRate WRITE setSampleRate NOTIFY sampleRateChanged)
    Q_PROPERTY(double dynamicRangeDB READ dynamicRangeDB WRITE setDynamicRangeDB NOTIFY dynamicRangeDBChanged)
    Q_PROPERTY(double gammaCorrection READ gammaCorrection WRITE setGammaCorrection NOTIFY gammaCorrectionChanged)
    Q_PROPERTY(bool enableDithering READ enableDithering WRITE setEnableDithering NOTIFY enablDitheringChanged)
    Q_PROPERTY(double contrastFactor READ contrastFactor WRITE setContrastFactor NOTIFY contrastFactorChanged)
    Q_PROPERTY(double writingSpeed READ writingSpeed WRITE setWritingSpeed NOTIFY writingSpeedChanged)
    Q_PROPERTY(double resolutionSliderValue READ resolutionSliderValue WRITE setResolutionSliderValue NOTIFY resolutionSliderValueChanged)
    
    // Filter parameters
    Q_PROPERTY(bool enableHighBoost READ enableHighBoost WRITE setEnableHighBoost NOTIFY enableHighBoostChanged)
    Q_PROPERTY(double highBoostAlpha READ highBoostAlpha WRITE setHighBoostAlpha NOTIFY highBoostAlphaChanged)
    Q_PROPERTY(bool enableHighPassFilter READ enableHighPassFilter WRITE setEnableHighPassFilter NOTIFY enableHighPassFilterChanged)
    Q_PROPERTY(double highPassCutoffFreq READ highPassCutoffFreq WRITE setHighPassCutoffFreq NOTIFY highPassCutoffFreqChanged)
    Q_PROPERTY(int highPassFilterOrder READ highPassFilterOrder WRITE setHighPassFilterOrder NOTIFY highPassFilterOrderChanged)
    Q_PROPERTY(bool enableNormalization READ enableNormalization WRITE setEnableNormalization NOTIFY enableNormalizationChanged)
    
    // Output parameters
    Q_PROPERTY(int pageFormat READ pageFormat WRITE setPageFormat NOTIFY pageFormatChanged)
    Q_PROPERTY(double bottomMarginMM READ bottomMarginMM WRITE setBottomMarginMM NOTIFY bottomMarginMMChanged)
    Q_PROPERTY(double spectroHeightMM READ spectroHeightMM WRITE setSpectroHeightMM NOTIFY spectroHeightMMChanged)
    Q_PROPERTY(bool enableVerticalScale READ enableVerticalScale WRITE setEnableVerticalScale NOTIFY enableVerticalScaleChanged)
    Q_PROPERTY(bool enableBottomReferenceLine READ enableBottomReferenceLine WRITE setEnableBottomReferenceLine NOTIFY enableBottomReferenceLineChanged)
    Q_PROPERTY(double bottomReferenceLineOffset READ bottomReferenceLineOffset WRITE setBottomReferenceLineOffset NOTIFY bottomReferenceLineOffsetChanged)
    Q_PROPERTY(bool enableTopReferenceLine READ enableTopReferenceLine WRITE setEnableTopReferenceLine NOTIFY enableTopReferenceLineChanged)
    Q_PROPERTY(double topReferenceLineOffset READ topReferenceLineOffset WRITE setTopReferenceLineOffset NOTIFY topReferenceLineOffsetChanged)
    Q_PROPERTY(bool displayParameters READ displayParameters WRITE setDisplayParameters NOTIFY displayParametersChanged)
    Q_PROPERTY(double textScaleFactor READ textScaleFactor WRITE setTextScaleFactor NOTIFY textScaleFactorChanged)
    Q_PROPERTY(double lineThicknessFactor READ lineThicknessFactor WRITE setLineThicknessFactor NOTIFY lineThicknessFactorChanged)
    
    // Derived/Calculated parameters
    Q_PROPERTY(double binsPerSecond READ binsPerSecond NOTIFY binsPerSecondChanged)
    Q_PROPERTY(int fftSize READ fftSize NOTIFY fftSizeChanged)
    Q_PROPERTY(double effectiveOverlap READ effectiveOverlap NOTIFY effectiveOverlapChanged)
    Q_PROPERTY(int overlapPreset READ overlapPreset WRITE setOverlapPreset NOTIFY overlapPresetChanged)
    
public:
    explicit SpectrogramParametersModel(QObject *parent = nullptr);
    ~SpectrogramParametersModel();
    
    // Batch update control
    Q_INVOKABLE void beginUpdate();
    Q_INVOKABLE void endUpdate();
    
    // Derived value calculations
    Q_INVOKABLE double calculateBpsFromSlider(double sliderValue);
    Q_INVOKABLE double calculateOverlapFromSlider(double sliderValue);
    Q_INVOKABLE bool isResolutionLimited();
    Q_INVOKABLE double calculateAudioDuration();
    Q_INVOKABLE double calculateMaxBps(double writingSpeed);
    
    // Conversion to C structure
    SpectrogramSettings toCStruct() const;
    
    // Getters
    double minFreq() const { return m_minFreq; }
    double maxFreq() const { return m_maxFreq; }
    double duration() const { return m_duration; }
    int sampleRate() const { return m_sampleRate; }
    double dynamicRangeDB() const { return m_dynamicRangeDB; }
    double gammaCorrection() const { return m_gammaCorrection; }
    bool enableDithering() const { return m_enableDithering; }
    double contrastFactor() const { return m_contrastFactor; }
    double writingSpeed() const { return m_writingSpeed; }
    double resolutionSliderValue() const { return m_resolutionSliderValue; }
    bool enableHighBoost() const { return m_enableHighBoost; }
    double highBoostAlpha() const { return m_highBoostAlpha; }
    bool enableHighPassFilter() const { return m_enableHighPassFilter; }
    double highPassCutoffFreq() const { return m_highPassCutoffFreq; }
    int highPassFilterOrder() const { return m_highPassFilterOrder; }
    bool enableNormalization() const { return m_enableNormalization; }
    int pageFormat() const { return m_pageFormat; }
    double bottomMarginMM() const { return m_bottomMarginMM; }
    double spectroHeightMM() const { return m_spectroHeightMM; }
    bool enableVerticalScale() const { return m_enableVerticalScale; }
    bool enableBottomReferenceLine() const { return m_enableBottomReferenceLine; }
    double bottomReferenceLineOffset() const { return m_bottomReferenceLineOffset; }
    bool enableTopReferenceLine() const { return m_enableTopReferenceLine; }
    double topReferenceLineOffset() const { return m_topReferenceLineOffset; }
    bool displayParameters() const { return m_displayParameters; }
    double textScaleFactor() const { return m_textScaleFactor; }
    double lineThicknessFactor() const { return m_lineThicknessFactor; }
    int overlapPreset() const { return m_overlapPreset; }
    
    // Derived getters (with caching)
    double binsPerSecond();
    int fftSize();
    double effectiveOverlap();
    
    // Setters
    void setMinFreq(double value);
    void setMaxFreq(double value);
    void setDuration(double value);
    void setSampleRate(int value);
    void setDynamicRangeDB(double value);
    void setGammaCorrection(double value);
    void setEnableDithering(bool value);
    void setContrastFactor(double value);
    void setWritingSpeed(double value);
    void setResolutionSliderValue(double value);
    void setEnableHighBoost(bool value);
    void setHighBoostAlpha(double value);
    void setEnableHighPassFilter(bool value);
    void setHighPassCutoffFreq(double value);
    void setHighPassFilterOrder(int value);
    void setEnableNormalization(bool value);
    void setPageFormat(int value);
    void setBottomMarginMM(double value);
    void setSpectroHeightMM(double value);
    void setEnableVerticalScale(bool value);
    void setEnableBottomReferenceLine(bool value);
    void setBottomReferenceLineOffset(double value);
    void setEnableTopReferenceLine(bool value);
    void setTopReferenceLineOffset(double value);
    void setDisplayParameters(bool value);
    void setTextScaleFactor(double value);
    void setLineThicknessFactor(double value);
    void setOverlapPreset(int value);
    
signals:
    // Property change signals
    void minFreqChanged();
    void maxFreqChanged();
    void durationChanged();
    void sampleRateChanged();
    void dynamicRangeDBChanged();
    void gammaCorrectionChanged();
    void enablDitheringChanged();
    void contrastFactorChanged();
    void writingSpeedChanged();
    void resolutionSliderValueChanged();
    void enableHighBoostChanged();
    void highBoostAlphaChanged();
    void enableHighPassFilterChanged();
    void highPassCutoffFreqChanged();
    void highPassFilterOrderChanged();
    void enableNormalizationChanged();
    void pageFormatChanged();
    void bottomMarginMMChanged();
    void spectroHeightMMChanged();
    void enableVerticalScaleChanged();
    void enableBottomReferenceLineChanged();
    void bottomReferenceLineOffsetChanged();
    void enableTopReferenceLineChanged();
    void topReferenceLineOffsetChanged();
    void displayParametersChanged();
    void textScaleFactorChanged();
    void lineThicknessFactorChanged();
    void overlapPresetChanged();
    
    // Derived value change signals
    void binsPerSecondChanged();
    void fftSizeChanged();
    void effectiveOverlapChanged();
    
    // Batch update signal
    void parametersChanged();

private:
    // Basic parameters
    double m_minFreq;
    double m_maxFreq;
    double m_duration;
    int m_sampleRate;
    double m_dynamicRangeDB;
    double m_gammaCorrection;
    bool m_enableDithering;
    double m_contrastFactor;
    double m_writingSpeed;
    double m_resolutionSliderValue;
    
    // Filter parameters
    bool m_enableHighBoost;
    double m_highBoostAlpha;
    bool m_enableHighPassFilter;
    double m_highPassCutoffFreq;
    int m_highPassFilterOrder;
    bool m_enableNormalization;
    
    // Output parameters
    int m_pageFormat;
    double m_bottomMarginMM;
    double m_spectroHeightMM;
    bool m_enableVerticalScale;
    bool m_enableBottomReferenceLine;
    double m_bottomReferenceLineOffset;
    bool m_enableTopReferenceLine;
    double m_topReferenceLineOffset;
    bool m_displayParameters;
    double m_textScaleFactor;
    double m_lineThicknessFactor;
    int m_overlapPreset;
    
    // Cache for calculated values
    bool m_cacheValid;
    double m_cachedBps;
    int m_cachedFftSize;
    double m_cachedOverlap;
    bool m_resolutionLimited;
    
    // Batch update tracking
    bool m_batchUpdating;
    bool m_paramsChanged;
    
    // Private methods
    void invalidateCache();
    void recalculateDerivedValues();
    double getOverlapValueFromPreset() const;
    void emitChangeSignal(bool batch = false);
};

#endif // SPECTROGRAMPARAMETERSMODEL_H
