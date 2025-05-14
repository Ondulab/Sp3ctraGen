/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#include "waveformprovider.h"
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <cmath>
#include <algorithm>

WaveformProvider::WaveformProvider(QObject *parent)
    : QObject(parent)
    , m_file(nullptr)
    , m_fileLoaded(false)
{
    // Initialize the SF_INFO structure
    memset(&m_fileInfo, 0, sizeof(SF_INFO));
}

WaveformProvider::~WaveformProvider()
{
    closeFile();
}

bool WaveformProvider::loadFile(const QString &filePath)
{
    // Close the previous file if it's open
    closeFile();
    
    m_filePath = filePath;
    
    // Check if the file exists
    QFile file(filePath);
    if (!file.exists()) {
        qWarning() << "File does not exist:" << filePath;
        emit fileLoaded(false, 0, 0);
        return false;
    }
    
    // Open the audio file with libsndfile
    m_file = sf_open(filePath.toUtf8().constData(), SFM_READ, &m_fileInfo);
    if (!m_file) {
        qWarning() << "Failed to open audio file:" << filePath << "Error:" << sf_strerror(nullptr);
        emit fileLoaded(false, 0, 0);
        return false;
    }
    
    // Analyze the audio file
    analyzeAudio();
    
    // Calculate the duration in seconds
    double durationSeconds = static_cast<double>(m_fileInfo.frames) / m_fileInfo.samplerate;
    
    m_fileLoaded = true;
    emit fileLoaded(true, durationSeconds, m_fileInfo.samplerate);
    
    return true;
}

void WaveformProvider::analyzeAudio()
{
    // Allocate memory for audio data
    m_audioData.resize(m_fileInfo.frames * m_fileInfo.channels);
    
    // Read all audio data
    sf_count_t readCount = sf_readf_float(m_file, m_audioData.data(), m_fileInfo.frames);
    
    if (readCount != m_fileInfo.frames) {
        qWarning() << "Failed to read all audio frames. Expected:" << m_fileInfo.frames << "Read:" << readCount;
    }
    
    // Return to the beginning of the file for future reads
    sf_seek(m_file, 0, SEEK_SET);
}

QVariantList WaveformProvider::getWaveformData(int width)
{
    QVariantList result;
    
    if (!m_fileLoaded || m_audioData.empty()) {
        qWarning() << "No audio data loaded";
        return result;
    }
    
    // Resample data for display
    resampleForDisplay(width, result);
    
    return result;
}

void WaveformProvider::resampleForDisplay(int targetWidth, QVariantList &result)
{
    // Number of samples per pixel
    int samplesPerPixel = std::max(1, static_cast<int>(m_fileInfo.frames / targetWidth));
    
    // Number of channels
    int channels = m_fileInfo.channels;
    
    // For each pixel of the target width
    for (int i = 0; i < targetWidth; ++i) {
        // Calculate the start index for this pixel
        int startIdx = i * samplesPerPixel * channels;
        
        // Make sure we don't exceed the limits
        if (startIdx >= static_cast<int>(m_audioData.size())) {
            break;
        }
        
        // Calculate min and max values for this segment
        float minValue = 0.0f;
        float maxValue = 0.0f;
        float rmsValue = 0.0f;
        int count = 0;
        
        // Go through all samples for this pixel
        for (int j = 0; j < samplesPerPixel && (startIdx + j * channels) < static_cast<int>(m_audioData.size()); ++j) {
            // Average of channels for each sample
            float sampleValue = 0.0f;
            for (int ch = 0; ch < channels; ++ch) {
                int idx = startIdx + j * channels + ch;
                if (idx < static_cast<int>(m_audioData.size())) {
                    sampleValue += m_audioData[idx];
                }
            }
            sampleValue /= channels;
            
            // Update min/max
            minValue = std::min(minValue, sampleValue);
            maxValue = std::max(maxValue, sampleValue);
            
            // Calculate RMS
            rmsValue += sampleValue * sampleValue;
            count++;
        }
        
        // Finalize RMS
        if (count > 0) {
            rmsValue = std::sqrt(rmsValue / count);
        }
        
        // Add values to the result list
        QVariantMap point;
        point["min"] = minValue;
        point["max"] = maxValue;
        point["rms"] = rmsValue;
        result.append(point);
    }
}

QVariantMap WaveformProvider::calculateExtractionSegment(double cursorPosition, int pageFormat, double writingSpeed, double resolutionValue)
{
    if (!m_fileLoaded) {
        qWarning() << "No audio file loaded";
        return QVariantMap();
    }
    
    // Paper width in millimeters
    double paperWidthMM = (pageFormat == 0) ? 210.0 : 420.0; // A4 vs A3
    
    // Convert writing speed from cm/s to mm/s
    double speedMMS = writingSpeed * 10.0;
    
    // Calculate segment duration based solely on paper format and writing speed
    // This ensures a consistent time window regardless of resolution settings
    double segmentDuration = paperWidthMM / speedMMS;
    
    // Start position in seconds (based on relative cursor position)
    double totalDuration = static_cast<double>(m_fileInfo.frames) / m_fileInfo.samplerate;
    double startPosition = cursorPosition * totalDuration;
    
    // Make sure the segment doesn't go beyond the end of the file
    if (startPosition + segmentDuration > totalDuration) {
        startPosition = totalDuration - segmentDuration;
        if (startPosition < 0) {
            startPosition = 0;
            segmentDuration = totalDuration;
        }
    }
    
    // Calculate sample indices
    qint64 startSample = static_cast<qint64>(startPosition * m_fileInfo.samplerate);
    qint64 sampleCount = static_cast<qint64>(segmentDuration * m_fileInfo.samplerate);
    
    // Create and return the result map
    QVariantMap result;
    result["startPosition"] = startPosition;
    result["duration"] = segmentDuration;
    result["startSample"] = startSample;
    result["sampleCount"] = sampleCount;
    
    return result;
}

QByteArray WaveformProvider::extractSegment(double startPosition, double duration)
{
    if (!m_fileLoaded || !m_file) {
        qWarning() << "No audio file loaded";
        return QByteArray();
    }
    
    // Calculate sample indices
    sf_count_t startSample = static_cast<sf_count_t>(startPosition * m_fileInfo.samplerate);
    sf_count_t sampleCount = static_cast<sf_count_t>(duration * m_fileInfo.samplerate);
    
    // Make sure we don't exceed the limits
    if (startSample >= m_fileInfo.frames) {
        qWarning() << "Start position beyond end of file";
        return QByteArray();
    }
    
    if (startSample + sampleCount > m_fileInfo.frames) {
        sampleCount = m_fileInfo.frames - startSample;
    }
    
    // Position the file cursor
    sf_seek(m_file, startSample, SEEK_SET);
    
    // Allocate a buffer for audio data
    std::vector<float> buffer(sampleCount * m_fileInfo.channels);
    
    // Read the data
    sf_count_t readCount = sf_readf_float(m_file, buffer.data(), sampleCount);
    
    if (readCount != sampleCount) {
        qWarning() << "Failed to read all requested samples. Expected:" << sampleCount << "Read:" << readCount;
    }
    
    // Convert to QByteArray
    QByteArray result;
    result.resize(buffer.size() * sizeof(float));
    memcpy(result.data(), buffer.data(), buffer.size() * sizeof(float));
    
    return result;
}

double WaveformProvider::getTotalDuration() const
{
    if (!m_fileLoaded) {
        return 0.0;
    }
    
    return static_cast<double>(m_fileInfo.frames) / m_fileInfo.samplerate;
}

int WaveformProvider::getSampleRate() const
{
    if (!m_fileLoaded) {
        return 0;
    }
    
    return m_fileInfo.samplerate;
}

QString WaveformProvider::getFilePath() const
{
    return m_filePath;
}

void WaveformProvider::closeFile()
{
    if (m_file) {
        sf_close(m_file);
        m_file = nullptr;
    }
    
    m_audioData.clear();
    m_fileLoaded = false;
    memset(&m_fileInfo, 0, sizeof(SF_INFO));
}
