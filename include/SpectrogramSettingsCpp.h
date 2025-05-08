#ifndef SPECTROGRAMSETTINGSCPP_H
#define SPECTROGRAMSETTINGSCPP_H

#include <QString>
#include "spectral_generator.h"

/**
 * @brief Classe C++ unifiée pour les paramètres de spectrogramme
 * 
 * Cette classe encapsule tous les paramètres nécessaires pour générer un spectrogramme
 * et fournit des méthodes pour convertir entre cette classe et la structure C.
 */
class SpectrogramSettingsCpp {
public:
    // Constructeur par défaut
    SpectrogramSettingsCpp();
    
    // Factory methods pour les préréglages communs
    static SpectrogramSettingsCpp defaultSettings();
    static SpectrogramSettingsCpp highResolutionSettings();
    
    // Méthodes de conversion
    SpectrogramSettings toCStruct() const;
    static SpectrogramSettingsCpp fromCStruct(const SpectrogramSettings& cSettings);
    
    // Getters et setters
    int getFftSize() const { return m_fftSize; }
    void setFftSize(int value) { m_fftSize = value; }
    
    double getOverlap() const { return m_overlap; }
    void setOverlap(double value) { m_overlap = value; }
    
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
    
    // Méthode pour initialiser à partir des paramètres QML
    void initFromQmlParameters(
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
        double writingSpeed
    );
    
private:
    int m_fftSize;
    double m_overlap;
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
};

#endif // SPECTROGRAMSETTINGSCPP_H