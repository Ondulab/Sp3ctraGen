#include "../include/VectorVisualizationStrategy.h"
#include "../include/FileManager.h"
#include <QDebug>
#include <QFuture>
#include <QtConcurrent/QtConcurrent>

// Déclaration externe de la fonction C
extern "C" {
    int spectral_generator_vector_pdf_impl(const SpectrogramSettings *cfg,
                                          const char *inputFile,
                                          const char *outputFile,
                                          int dpi);
}

VectorVisualizationStrategy::VectorVisualizationStrategy(QObject *parent)
    : VisualizationStrategy(parent)
    , m_dpi(800) // Résolution par défaut
{
}

bool VectorVisualizationStrategy::generate(const SpectrogramSettingsCpp& settings, 
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

void VectorVisualizationStrategy::runGeneration(const SpectrogramSettings& settings,
                                              const QString& inputFile,
                                              const QString& outputFile)
{
    // Ajouter des logs détaillés
    qDebug() << "Génération du spectrogramme vectoriel (PDF)";
    qDebug() << "Fichier d'entrée: " << inputFile;
    qDebug() << "Fichier de sortie: " << outputFile;
    qDebug() << "Résolution: " << m_dpi << " DPI";
    qDebug() << "Taille FFT: " << settings.fftSize;
    
    emit progressUpdated(10, "Préparation de la génération...");
    
    // Convertir les QString en const char* pour l'API C
    QByteArray inputFileBytes = inputFile.toLocal8Bit();
    QByteArray outputFileBytes = outputFile.toLocal8Bit();
    
    const char *inputFileCStr = inputFileBytes.constData();
    const char *outputFileCStr = outputFileBytes.constData();
    
    emit progressUpdated(20, "Génération du spectrogramme vectoriel...");
    
    // Appeler la fonction C
    qDebug() << "Appel de spectral_generator_vector_pdf_impl pour la génération du PDF vectoriel";
    int result = spectral_generator_vector_pdf_impl(&settings, inputFileCStr, outputFileCStr, m_dpi);
    qDebug() << "spectral_generator_vector_pdf_impl a retourné: " << result << (result == EXIT_SUCCESS ? " (SUCCÈS)" : " (ÉCHEC)");
    
    emit progressUpdated(90, "Finalisation...");
    
    // Émettre le signal avec le résultat
    if (result == EXIT_SUCCESS) {
        qDebug() << "PDF vectoriel généré avec succès à: " << outputFile;
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
        qWarning() << "Échec de la génération du PDF vectoriel, code d'erreur: " << result;
        emit generationCompleted(false, "", "Erreur lors de la génération du PDF vectoriel (code: " + QString::number(result) + ")");
    }
}

QString VectorVisualizationStrategy::getName() const
{
    return "Vectoriel (PDF)";
}

QString VectorVisualizationStrategy::getDescription() const
{
    return QString("Génère un spectrogramme au format vectoriel (PDF) avec une résolution de %1 DPI").arg(m_dpi);
}

QStringList VectorVisualizationStrategy::getSupportedExtensions() const
{
    return QStringList() << "pdf";
}

void VectorVisualizationStrategy::setDpi(int dpi)
{
    if (dpi > 0) {
        m_dpi = dpi;
    }
}

int VectorVisualizationStrategy::getDpi() const
{
    return m_dpi;
}