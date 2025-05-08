#include "../include/VisualizationStrategy.h"
#include "../include/FileManager.h"
#include <QDebug>
#include <QFuture>
#include <QtConcurrent/QtConcurrent>

VisualizationStrategy::VisualizationStrategy(QObject *parent)
    : QObject(parent)
{
}

bool VisualizationStrategy::generate(const SpectrogramSettingsCpp& settings, 
                                   const QString& inputFile,
                                   const QString& outputFile)
{
    // Valider les fichiers d'entrée et de sortie
    if (!FileManager::validateInputFile(inputFile)) {
        emit generationCompleted(false, "", "Le fichier d'entrée n'existe pas ou n'est pas lisible");
        return false;
    }
    
    // Vérifier que le dossier de sortie existe
    QString outputDir = QFileInfo(outputFile).path();
    if (!FileManager::ensureDirectoryExists(outputDir)) {
        emit generationCompleted(false, "", "Impossible de créer le dossier de sortie");
        return false;
    }
    
    // Convertir les paramètres en structure C
    SpectrogramSettings cSettings = settings.toCStruct();
    
    // Exécuter la génération dans un thread séparé
    QFuture<void> future = QtConcurrent::run([=]() {
        this->runGeneration(cSettings, inputFile, outputFile);
    });
    
    return true;
}

void VisualizationStrategy::runGeneration(const SpectrogramSettings& settings,
                                        const QString& inputFile,
                                        const QString& outputFile)
{
    // Ajouter des logs détaillés
    qDebug() << "Génération du spectrogramme avec la stratégie: " << getName();
    qDebug() << "Fichier d'entrée: " << inputFile;
    qDebug() << "Fichier de sortie: " << outputFile;
    qDebug() << "Taille FFT: " << settings.fftSize;
    
    emit progressUpdated(10, "Préparation de la génération...");
    
    // Convertir les QString en const char* pour l'API C
    QByteArray inputFileBytes = inputFile.toLocal8Bit();
    QByteArray outputFileBytes = outputFile.toLocal8Bit();
    
    const char *inputFileCStr = inputFileBytes.constData();
    const char *outputFileCStr = outputFileBytes.constData();
    
    emit progressUpdated(20, "Génération du spectrogramme...");
    
    // Appeler la fonction C spécifique à la stratégie
    int result = callGeneratorFunction(settings, inputFileCStr, outputFileCStr);
    
    emit progressUpdated(90, "Finalisation...");
    
    // Émettre le signal avec le résultat
    if (result == EXIT_SUCCESS) {
        qDebug() << "Spectrogramme généré avec succès à: " << outputFile;
        // Vérifier que le fichier existe
        if (QFile::exists(outputFile)) {
            qDebug() << "Le fichier de sortie existe, émission du signal de succès";
            emit progressUpdated(100, "Génération terminée avec succès");
            emit generationCompleted(true, outputFile);
        } else {
            qWarning() << "Le fichier de sortie n'existe pas: " << outputFile;
            emit generationCompleted(false, "", "Le fichier de sortie n'a pas été créé");
        }
    } else {
        qWarning() << "Échec de la génération du spectrogramme, code d'erreur: " << result;
        emit generationCompleted(false, "", "Erreur lors de la génération du spectrogramme (code: " + QString::number(result) + ")");
    }
}