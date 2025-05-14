/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef SPECTROGRAMVIEWMODEL_H
#define SPECTROGRAMVIEWMODEL_H

#include <QObject>
#include <QQmlEngine>
#include <QByteArray>
#include <QString>
#include "SpectrogramParametersModel.h"
#include "spectrogramgenerator.h"

/**
 * @brief ViewModel class for spectrogram generation
 *
 * This class serves as an intermediate layer between QML UI and C++ backend.
 * It simplifies the interface and centralizes the business logic.
 */
class SpectrogramViewModel : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    
    // Expose the parameters model to QML
    Q_PROPERTY(SpectrogramParametersModel* parameters READ parameters CONSTANT)
    
    // Status properties
    Q_PROPERTY(bool isGenerating READ isGenerating NOTIFY isGeneratingChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(bool hasPreview READ hasPreview NOTIFY hasPreviewChanged)
    
    // Durée audio calculée à partir du format papier et de la vitesse d'écriture
    Q_PROPERTY(double audioDuration READ audioDuration NOTIFY audioDurationChanged)
    
public:
    explicit SpectrogramViewModel(QObject *parent = nullptr);
    ~SpectrogramViewModel();
    
    // Initialize with existing models
    void initialize(SpectrogramParametersModel* paramsModel, SpectrogramGenerator* generator);
    
    // Access to the parameters model
    SpectrogramParametersModel* parameters() const { return m_parametersModel; }
    
    // Status getters
    bool isGenerating() const { return m_isGenerating; }
    QString statusMessage() const { return m_statusMessage; }
    bool hasPreview() const { return m_hasPreview; }
    double audioDuration() const;
    
    // Main functions exposed to QML
    Q_INVOKABLE void generateSpectrogram(const QString &inputFile, const QString &outputFolder);
    Q_INVOKABLE void generatePreview(const QString &inputFile);
    Q_INVOKABLE void generateSpectrogramFromSegment(
        const QByteArray &audioSegment, 
        const QString &originalFileName,
        double startTime);
    
    Q_INVOKABLE void saveCurrentPreview(const QString &outputFilePath, const QString &format = "png");
    Q_INVOKABLE bool printPreview();
    
    // Utility methods
    Q_INVOKABLE QStringList getAvailableVisualizationTypes() const;
    Q_INVOKABLE QString normalizeAudioFile(const QString &inputPath, double factor);
    Q_INVOKABLE double calculateNormalizationFactor(const QString &audioPath);
    
signals:
    // Status signals
    void isGeneratingChanged();
    void statusMessageChanged();
    void hasPreviewChanged();
    void audioDurationChanged();
    
    // Result signals
    void spectrogramGenerated(bool success, const QString &outputPath, const QString &errorMessage = "");
    void previewGenerated(bool success, const QString &errorMessage = "");
    void previewSaved(bool success, const QString &outputPath, const QString &format, const QString &errorMessage = "");
    
    // Progress signals
    void progressUpdated(int progress, const QString &message);
    
private:
    // Helper methods
    void connectSignals();
    
private slots:
    // Handle signals from the generator
    void onSpectrogramGenerated(bool success, const QString &outputPath, const QString &errorMessage);
    void onPreviewGenerated(bool success, const QImage &previewImage, const QString &errorMessage);
    void onSegmentPreviewGenerated(bool success, const QImage &previewImage, const QString &errorMessage);
    void onPreviewSaved(bool success, const QString &outputPath, const QString &format, const QString &errorMessage);
    void onTaskProgressUpdated(const QUuid &taskId, int progress, const QString &message);
    void onFftParametersCalculated(int calculatedFftSize, double effectiveOverlap, double binsPerSecond);
    
private:
    // Models
    SpectrogramParametersModel* m_parametersModel;
    SpectrogramGenerator* m_generator;
    
    // Status tracking
    bool m_isGenerating;
    QString m_statusMessage;
    bool m_hasPreview;
    
    // Ownership flags
    bool m_ownsParametersModel;
    bool m_ownsGenerator;
};

#endif // SPECTROGRAMVIEWMODEL_H
