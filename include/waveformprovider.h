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
    
    // Charge un fichier WAV et extrait les données
    Q_INVOKABLE bool loadFile(const QString &filePath);
    
    // Retourne les données pour l'affichage de la forme d'onde
    Q_INVOKABLE QVariantList getWaveformData(int width);
    
    // Calcule le segment à extraire en fonction des paramètres
    Q_INVOKABLE QVariantMap calculateExtractionSegment(
        double cursorPosition,
        int pageFormat,
        double writingSpeed
    );
    
    // Extrait le segment audio pour la génération
    Q_INVOKABLE QByteArray extractSegment(
        double startPosition, 
        double duration
    );
    
    // Retourne la durée totale du fichier audio en secondes
    Q_INVOKABLE double getTotalDuration() const;
    
    // Retourne le taux d'échantillonnage du fichier audio
    Q_INVOKABLE int getSampleRate() const;

signals:
    void fileLoaded(bool success, double durationSeconds, int sampleRate);

private:
    // Données du fichier audio
    SF_INFO m_fileInfo;
    SNDFILE* m_file;
    std::vector<float> m_audioData;
    QString m_filePath;
    bool m_fileLoaded;
    
    // Méthodes privées d'analyse
    void analyzeAudio();
    void resampleForDisplay(int targetWidth, QVariantList &result);
    void closeFile();
};

#endif // WAVEFORMPROVIDER_H
