#include "../include/FileManager.h"
#include "../include/Constants.h"
#include <QFileInfo>
#include <QStandardPaths>
#include <QDateTime>
#include <QDebug>

bool FileManager::validateInputFile(const QString& path)
{
    if (path.isEmpty()) {
        qWarning() << "Input file path is empty";
        return false;
    }
    
    QFileInfo fileInfo(path);
    if (!fileInfo.exists()) {
        qWarning() << "Input file does not exist:" << path;
        return false;
    }
    
    if (!fileInfo.isReadable()) {
        qWarning() << "Input file is not readable:" << path;
        return false;
    }
    
    return true;
}

bool FileManager::validateOutputDirectory(const QString& path)
{
    if (path.isEmpty()) {
        qWarning() << "Output directory path is empty";
        return false;
    }
    
    QDir dir(path);
    if (!dir.exists()) {
        qWarning() << "Output directory does not exist:" << path;
        return false;
    }
    
    // Vérifier si le dossier est accessible en écriture
    QFileInfo dirInfo(path);
    if (!dirInfo.isWritable()) {
        qWarning() << "Output directory is not writable:" << path;
        return false;
    }
    
    return true;
}

bool FileManager::ensureDirectoryExists(const QString& path)
{
    if (path.isEmpty()) {
        qWarning() << "Directory path is empty";
        return false;
    }
    
    QDir dir(path);
    if (dir.exists()) {
        return true;
    }
    
    // Créer le dossier et tous les dossiers parents nécessaires
    if (dir.mkpath(".")) {
        qDebug() << "Created directory:" << path;
        return true;
    } else {
        qWarning() << "Failed to create directory:" << path;
        return false;
    }
}

QString FileManager::getDefaultInputPath()
{
    // Utiliser le chemin relatif depuis le répertoire de l'application
    QString defaultPath = QDir::currentPath() + "/" + Constants::DEFAULT_INPUT_FILE;
    
    // Vérifier si le fichier existe
    if (QFileInfo::exists(defaultPath)) {
        return defaultPath;
    }
    
    // Sinon, chercher dans les dossiers de musique standard
    QStringList musicPaths = QStandardPaths::standardLocations(QStandardPaths::MusicLocation);
    for (const QString& musicPath : musicPaths) {
        QString testPath = musicPath + "/" + Constants::DEFAULT_INPUT_FILE;
        if (QFileInfo::exists(testPath)) {
            return testPath;
        }
    }
    
    // Si aucun fichier n'est trouvé, retourner le chemin par défaut
    return defaultPath;
}

QString FileManager::getDefaultOutputPath()
{
    // Utiliser le répertoire de l'application comme dossier de sortie par défaut
    QString defaultPath = QDir::currentPath();
    
    // Vérifier si le dossier est accessible en écriture
    if (QFileInfo(defaultPath).isWritable()) {
        return defaultPath;
    }
    
    // Sinon, utiliser le dossier Documents ou Images
    QStringList docPaths = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation);
    if (!docPaths.isEmpty() && QFileInfo(docPaths.first()).isWritable()) {
        return docPaths.first();
    }
    
    QStringList picPaths = QStandardPaths::standardLocations(QStandardPaths::PicturesLocation);
    if (!picPaths.isEmpty() && QFileInfo(picPaths.first()).isWritable()) {
        return picPaths.first();
    }
    
    // En dernier recours, utiliser le dossier temporaire
    return QDir::tempPath();
}

QString FileManager::generateOutputFilename(const QString& outputFolder, 
                                           const QString& baseName,
                                           const QString& format)
{
    QDir dir(outputFolder);
    
    // Si le nom de base est vide, utiliser un nom par défaut avec horodatage
    QString fileName;
    if (baseName.isEmpty()) {
        QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss");
        fileName = QString("spectrogram_%1.%2").arg(timestamp).arg(format);
    } else {
        // S'assurer que l'extension est correcte
        if (baseName.endsWith("." + format, Qt::CaseInsensitive)) {
            fileName = baseName;
        } else {
            fileName = baseName + "." + format;
        }
    }
    
    return dir.filePath(fileName);
}