/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef WAVEFORMPROVIDER_H
#define WAVEFORMPROVIDER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QByteArray>
#include <QQmlEngine>
#include <vector>
#include <sndfile.h>

class WaveformProvider : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit WaveformProvider(QObject *parent = nullptr);
    virtual ~WaveformProvider();
    
    // Loads a WAV file and extracts data
    Q_INVOKABLE bool loadFile(const QString &filePath);
    
    // Returns data for waveform display
    Q_INVOKABLE QVariantList getWaveformData(int width);
    
    // Calculates the segment to extract based on parameters
    Q_INVOKABLE QVariantMap calculateExtractionSegment(
        double cursorPosition,
        int pageFormat,
        double writingSpeed,
        double binsPerSecond = 150.0,
        int overlapPreset = 1  // 0=Low, 1=Medium, 2=High
    );
    
    // Extracts the audio segment for generation
    Q_INVOKABLE QByteArray extractSegment(
        double startPosition, 
        double duration
    );
    
    // Returns the total duration of the audio file in seconds
    Q_INVOKABLE double getTotalDuration() const;
    
    // Returns the sample rate of the audio file
    Q_INVOKABLE int getSampleRate() const;
    
    // Returns the current audio file path
    Q_INVOKABLE QString getFilePath() const;

signals:
    void fileLoaded(bool success, double durationSeconds, int sampleRate);

private:
    // Audio file data
    SF_INFO m_fileInfo;
    SNDFILE* m_file;
    std::vector<float> m_audioData;
    QString m_filePath;
    bool m_fileLoaded;
    
    // Private analysis methods
    void analyzeAudio();
    void resampleForDisplay(int targetWidth, QVariantList &result);
    void closeFile();
};

#endif // WAVEFORMPROVIDER_H
