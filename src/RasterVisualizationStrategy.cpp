#include "../include/RasterVisualizationStrategy.h"
#include "../include/FileManager.h"
#include <QDebug>
#include <QFuture>
#include <QtConcurrent/QtConcurrent>

// Déclaration externe de la fonction C
extern "C" {
    int spectral_generator_impl(const SpectrogramSettings *cfg,
                               const char *inputFile,
                               const char *outputFile);
}

RasterVisualizationStrategy::RasterVisualizationStrategy(QObject *parent)
    : VisualizationStrategy(parent)
{
}

bool RasterVisualizationStrategy::generate(const SpectrogramSettingsCpp& settings, 
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

void RasterVisualizationStrategy::runGeneration(const SpectrogramSettings& settings,
                                              const QString& inputFile,
                                              const QString& outputFile)
{
    // Ajouter des logs détaillés
    qDebug() << "Génération du spectrogramme raster";
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
    
    // Appeler la fonction C
    qDebug() << "Appel de spectral_generator_impl pour la génération du spectrogramme raster";
    int result = spectral_generator_impl(&settings, inputFileCStr, outputFileCStr);
    qDebug() << "spectral_generator_impl a retourné: " << result << (result == EXIT_SUCCESS ? " (SUCCÈS)" : " (ÉCHEC)");
    
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

QString RasterVisualizationStrategy::getName() const
{
    return "Raster (PNG)";
}

QString RasterVisualizationStrategy::getDescription() const
{
    return "Génère un spectrogramme au format raster (PNG) avec une résolution de 800 DPI";
}

QStringList RasterVisualizationStrategy::getSupportedExtensions() const
{
    return QStringList() << "png";
}