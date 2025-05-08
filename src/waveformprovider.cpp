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
    // Initialiser la structure SF_INFO
    memset(&m_fileInfo, 0, sizeof(SF_INFO));
}

WaveformProvider::~WaveformProvider()
{
    closeFile();
}

bool WaveformProvider::loadFile(const QString &filePath)
{
    // Fermer le fichier précédent s'il est ouvert
    closeFile();
    
    m_filePath = filePath;
    
    // Vérifier si le fichier existe
    QFile file(filePath);
    if (!file.exists()) {
        qWarning() << "File does not exist:" << filePath;
        emit fileLoaded(false, 0, 0);
        return false;
    }
    
    // Ouvrir le fichier audio avec libsndfile
    m_file = sf_open(filePath.toUtf8().constData(), SFM_READ, &m_fileInfo);
    if (!m_file) {
        qWarning() << "Failed to open audio file:" << filePath << "Error:" << sf_strerror(nullptr);
        emit fileLoaded(false, 0, 0);
        return false;
    }
    
    // Analyser le fichier audio
    analyzeAudio();
    
    // Calculer la durée en secondes
    double durationSeconds = static_cast<double>(m_fileInfo.frames) / m_fileInfo.samplerate;
    
    m_fileLoaded = true;
    emit fileLoaded(true, durationSeconds, m_fileInfo.samplerate);
    
    return true;
}

void WaveformProvider::analyzeAudio()
{
    // Allouer de la mémoire pour les données audio
    m_audioData.resize(m_fileInfo.frames * m_fileInfo.channels);
    
    // Lire toutes les données audio
    sf_count_t readCount = sf_readf_float(m_file, m_audioData.data(), m_fileInfo.frames);
    
    if (readCount != m_fileInfo.frames) {
        qWarning() << "Failed to read all audio frames. Expected:" << m_fileInfo.frames << "Read:" << readCount;
    }
    
    // Revenir au début du fichier pour les futures lectures
    sf_seek(m_file, 0, SEEK_SET);
}

QVariantList WaveformProvider::getWaveformData(int width)
{
    QVariantList result;
    
    if (!m_fileLoaded || m_audioData.empty()) {
        qWarning() << "No audio data loaded";
        return result;
    }
    
    // Rééchantillonner les données pour l'affichage
    resampleForDisplay(width, result);
    
    return result;
}

void WaveformProvider::resampleForDisplay(int targetWidth, QVariantList &result)
{
    // Nombre d'échantillons par pixel
    int samplesPerPixel = std::max(1, static_cast<int>(m_fileInfo.frames / targetWidth));
    
    // Nombre de canaux
    int channels = m_fileInfo.channels;
    
    // Pour chaque pixel de la largeur cible
    for (int i = 0; i < targetWidth; ++i) {
        // Calculer l'indice de début pour ce pixel
        int startIdx = i * samplesPerPixel * channels;
        
        // S'assurer que nous ne dépassons pas les limites
        if (startIdx >= m_audioData.size()) {
            break;
        }
        
        // Calculer les valeurs min et max pour ce segment
        float minValue = 0.0f;
        float maxValue = 0.0f;
        float rmsValue = 0.0f;
        int count = 0;
        
        // Parcourir tous les échantillons pour ce pixel
        for (int j = 0; j < samplesPerPixel && (startIdx + j * channels) < m_audioData.size(); ++j) {
            // Moyenne des canaux pour chaque échantillon
            float sampleValue = 0.0f;
            for (int ch = 0; ch < channels; ++ch) {
                int idx = startIdx + j * channels + ch;
                if (idx < m_audioData.size()) {
                    sampleValue += m_audioData[idx];
                }
            }
            sampleValue /= channels;
            
            // Mettre à jour min/max
            minValue = std::min(minValue, sampleValue);
            maxValue = std::max(maxValue, sampleValue);
            
            // Calculer RMS
            rmsValue += sampleValue * sampleValue;
            count++;
        }
        
        // Finaliser RMS
        if (count > 0) {
            rmsValue = std::sqrt(rmsValue / count);
        }
        
        // Ajouter les valeurs à la liste de résultats
        QVariantMap point;
        point["min"] = minValue;
        point["max"] = maxValue;
        point["rms"] = rmsValue;
        result.append(point);
    }
}

QVariantMap WaveformProvider::calculateExtractionSegment(double cursorPosition, int pageFormat, double writingSpeed)
{
    if (!m_fileLoaded) {
        qWarning() << "No audio file loaded";
        return QVariantMap();
    }
    
    // Largeur du papier en millimètres
    double paperWidthMM = (pageFormat == 0) ? 210.0 : 420.0; // A4 vs A3
    
    // Conversion de la vitesse d'écriture de cm/s à mm/s
    double speedMMS = writingSpeed * 10.0;
    
    // Calcul de la durée du segment en secondes
    double segmentDuration = paperWidthMM / speedMMS;
    
    // Position de début en secondes (basée sur la position relative du curseur)
    double totalDuration = static_cast<double>(m_fileInfo.frames) / m_fileInfo.samplerate;
    double startPosition = cursorPosition * totalDuration;
    
    // S'assurer que le segment ne dépasse pas la fin du fichier
    if (startPosition + segmentDuration > totalDuration) {
        startPosition = totalDuration - segmentDuration;
        if (startPosition < 0) {
            startPosition = 0;
            segmentDuration = totalDuration;
        }
    }
    
    // Calculer les indices d'échantillons
    qint64 startSample = static_cast<qint64>(startPosition * m_fileInfo.samplerate);
    qint64 sampleCount = static_cast<qint64>(segmentDuration * m_fileInfo.samplerate);
    
    // Créer et retourner la carte de résultats
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
    
    // Calculer les indices d'échantillons
    sf_count_t startSample = static_cast<sf_count_t>(startPosition * m_fileInfo.samplerate);
    sf_count_t sampleCount = static_cast<sf_count_t>(duration * m_fileInfo.samplerate);
    
    // S'assurer que nous ne dépassons pas les limites
    if (startSample >= m_fileInfo.frames) {
        qWarning() << "Start position beyond end of file";
        return QByteArray();
    }
    
    if (startSample + sampleCount > m_fileInfo.frames) {
        sampleCount = m_fileInfo.frames - startSample;
    }
    
    // Positionner le curseur de fichier
    sf_seek(m_file, startSample, SEEK_SET);
    
    // Allouer un buffer pour les données audio
    std::vector<float> buffer(sampleCount * m_fileInfo.channels);
    
    // Lire les données
    sf_count_t readCount = sf_readf_float(m_file, buffer.data(), sampleCount);
    
    if (readCount != sampleCount) {
        qWarning() << "Failed to read all requested samples. Expected:" << sampleCount << "Read:" << readCount;
    }
    
    // Convertir en QByteArray
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
