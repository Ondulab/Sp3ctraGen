/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef QMLCONSTANTS_H
#define QMLCONSTANTS_H

#include <QObject>
#include <QColor>
#include "Constants.h"

/**
 * @brief Class to expose constants to QML
 *
 * This class exposes C++ constants to QML via properties.
 * It is registered as a QML singleton to be accessible
 * from any QML file.
 */
class QmlConstants : public QObject
{
    Q_OBJECT
    
    // Audio parameters
    Q_PROPERTY(int defaultFftSize READ defaultFftSize CONSTANT)
    Q_PROPERTY(double defaultOverlap READ defaultOverlap CONSTANT)
    Q_PROPERTY(double defaultMinFreq READ defaultMinFreq CONSTANT)
    Q_PROPERTY(double defaultMaxFreq READ defaultMaxFreq CONSTANT)
    Q_PROPERTY(double defaultDuration READ defaultDuration CONSTANT)
    Q_PROPERTY(int defaultSampleRate READ defaultSampleRate CONSTANT)
    Q_PROPERTY(double defaultDynamicRange READ defaultDynamicRange CONSTANT)
    Q_PROPERTY(double defaultGammaCorrection READ defaultGammaCorrection CONSTANT)
    Q_PROPERTY(bool defaultEnableDithering READ defaultEnableDithering CONSTANT)
    Q_PROPERTY(double defaultContrastFactor READ defaultContrastFactor CONSTANT)
    Q_PROPERTY(bool defaultEnableHighBoost READ defaultEnableHighBoost CONSTANT)
    Q_PROPERTY(double defaultHighBoostAlpha READ defaultHighBoostAlpha CONSTANT)
    
    // Colors
    Q_PROPERTY(QColor primaryTextColor READ primaryTextColor CONSTANT)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor CONSTANT)
    Q_PROPERTY(QColor fieldBackground READ fieldBackground CONSTANT)
    Q_PROPERTY(QColor fieldText READ fieldText CONSTANT)
    Q_PROPERTY(QColor buttonBackground READ buttonBackground CONSTANT)
    Q_PROPERTY(QColor buttonText READ buttonText CONSTANT)
    Q_PROPERTY(QColor buttonHoverBackground READ buttonHoverBackground CONSTANT)
    Q_PROPERTY(QColor buttonHoverText READ buttonHoverText CONSTANT)
    Q_PROPERTY(QColor borderColor READ borderColor CONSTANT)
    Q_PROPERTY(QColor toggleBorderColor READ toggleBorderColor CONSTANT)
    Q_PROPERTY(QColor toggleActiveColor READ toggleActiveColor CONSTANT)
    Q_PROPERTY(QColor toggleInactiveColor READ toggleInactiveColor CONSTANT)
    Q_PROPERTY(QColor separatorColor READ separatorColor CONSTANT)
    Q_PROPERTY(QColor successColor READ successColor CONSTANT)
    Q_PROPERTY(QColor errorColor READ errorColor CONSTANT)
    
    // Dimensions
    Q_PROPERTY(int spacing READ spacing CONSTANT)
    Q_PROPERTY(int margin READ margin CONSTANT)
    Q_PROPERTY(int padding READ padding CONSTANT)
    Q_PROPERTY(int borderRadius READ borderRadius CONSTANT)
    Q_PROPERTY(int borderWidth READ borderWidth CONSTANT)
    Q_PROPERTY(int titleFontSize READ titleFontSize CONSTANT)
    Q_PROPERTY(int labelFontSize READ labelFontSize CONSTANT)
    Q_PROPERTY(int textFontSize READ textFontSize CONSTANT)
    Q_PROPERTY(int animationDuration READ animationDuration CONSTANT)
    
public:
    explicit QmlConstants(QObject *parent = nullptr);
    
    // Getters for audio parameters
    int defaultFftSize() const { return Constants::FFT_SIZE; }
    double defaultOverlap() const { return Constants::OVERLAP; }
    double defaultMinFreq() const { return Constants::MIN_FREQ; }
    double defaultMaxFreq() const { return Constants::MAX_FREQ; }
    double defaultDuration() const { return Constants::DURATION; }
    int defaultSampleRate() const { return Constants::SAMPLE_RATE; }
    double defaultDynamicRange() const { return Constants::DYNAMIC_RANGE; }
    double defaultGammaCorrection() const { return Constants::GAMMA; }
    bool defaultEnableDithering() const { return Constants::DITHERING; }
    double defaultContrastFactor() const { return Constants::CONTRAST; }
    bool defaultEnableHighBoost() const { return Constants::HIGH_BOOST; }
    double defaultHighBoostAlpha() const { return Constants::HIGH_BOOST_ALPHA_VAL; }
    
    // Getters for colors
    QColor primaryTextColor() const { return QColor(Constants::PRIMARY_COLOR); }
    QColor backgroundColor() const { return QColor(Constants::BACKGROUND_COLOR); }
    QColor fieldBackground() const { return QColor(Constants::FIELD_BACKGROUND_COLOR); }
    QColor fieldText() const { return QColor(Constants::FIELD_TEXT_COLOR); }
    QColor buttonBackground() const { return QColor(Constants::BUTTON_BACKGROUND_COLOR); }
    QColor buttonText() const { return QColor(Constants::BUTTON_TEXT_COLOR); }
    QColor buttonHoverBackground() const { return QColor(Constants::BUTTON_HOVER_BACKGROUND_COLOR); }
    QColor buttonHoverText() const { return QColor(Constants::BUTTON_HOVER_TEXT_COLOR); }
    QColor borderColor() const { return QColor(Constants::BORDER_COLOR); }
    QColor toggleBorderColor() const { return QColor(Constants::TOGGLE_BORDER_COLOR); }
    QColor toggleActiveColor() const { return QColor(Constants::TOGGLE_ACTIVE_COLOR); }
    QColor toggleInactiveColor() const { return QColor(Constants::TOGGLE_INACTIVE_COLOR); }
    QColor separatorColor() const { return QColor(Constants::SEPARATOR_COLOR); }
    QColor successColor() const { return QColor(Constants::SUCCESS_COLOR); }
    QColor errorColor() const { return QColor(Constants::ERROR_COLOR); }
    
    // Getters for dimensions
    int spacing() const { return 10; }
    int margin() const { return 20; }
    int padding() const { return 10; }
    int borderRadius() const { return 8; }
    int borderWidth() const { return 1; }
    int titleFontSize() const { return 20; }
    int labelFontSize() const { return 16; }
    int textFontSize() const { return 14; }
    int animationDuration() const { return 200; }
};

#endif // QMLCONSTANTS_H