/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

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
    
    // Check if the directory is writable
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
    
    // Create the directory and all necessary parent directories
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
    // Use the relative path from the application directory
    QString defaultPath = QDir::currentPath() + "/" + Constants::DEFAULT_INPUT_FILE;
    
    // Check if the file exists
    if (QFileInfo::exists(defaultPath)) {
        return defaultPath;
    }
    
    // Otherwise, look in standard music folders
    QStringList musicPaths = QStandardPaths::standardLocations(QStandardPaths::MusicLocation);
    for (const QString& musicPath : musicPaths) {
        QString testPath = musicPath + "/" + Constants::DEFAULT_INPUT_FILE;
        if (QFileInfo::exists(testPath)) {
            return testPath;
        }
    }
    
    // If no file is found, return the default path
    return defaultPath;
}

QString FileManager::getDefaultOutputPath()
{
    // Use the application directory as the default output folder
    QString defaultPath = QDir::currentPath();
    
    // Check if the directory is writable
    if (QFileInfo(defaultPath).isWritable()) {
        return defaultPath;
    }
    
    // Otherwise, use the Documents or Pictures folder
    QStringList docPaths = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation);
    if (!docPaths.isEmpty() && QFileInfo(docPaths.first()).isWritable()) {
        return docPaths.first();
    }
    
    QStringList picPaths = QStandardPaths::standardLocations(QStandardPaths::PicturesLocation);
    if (!picPaths.isEmpty() && QFileInfo(picPaths.first()).isWritable()) {
        return picPaths.first();
    }
    
    // As a last resort, use the temporary folder
    return QDir::tempPath();
}

QString FileManager::generateOutputFilename(const QString& outputFolder, 
                                           const QString& baseName,
                                           const QString& format)
{
    QDir dir(outputFolder);
    
    // If the base name is empty, use a default name with timestamp
    QString fileName;
    if (baseName.isEmpty()) {
        QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss");
        fileName = QString("spectrogram_%1.%2").arg(timestamp).arg(format);
    } else {
        // Ensure the extension is correct
        if (baseName.endsWith("." + format, Qt::CaseInsensitive)) {
            fileName = baseName;
        } else {
            fileName = baseName + "." + format;
        }
    }
    
    return dir.filePath(fileName);
}