/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#include "../include/PathManager.h"
#include <QCoreApplication>
#include <QStandardPaths>
#include "../include/Constants.h"

QString PathManager::getDefaultInputPath()
{
    return resolveRelativePath(Constants::DEFAULT_INPUT_FILE);
}

QString PathManager::getDefaultOutputFolder()
{
    return resolveRelativePath(Constants::DEFAULT_OUTPUT_FOLDER_PATH);
}

QString PathManager::getDefaultOutputPath()
{
    return resolveRelativePath(Constants::DEFAULT_OUTPUT_FILE);
}

QString PathManager::getDefaultPdfPath()
{
    return resolveRelativePath(Constants::DEFAULT_PDF_OUTPUT);
}

QString PathManager::resolveRelativePath(const QString& relativePath)
{
    if (QDir::isAbsolutePath(relativePath)) {
        return relativePath;
    }
    
    if (relativePath.startsWith("./") || relativePath.startsWith("../")) {
        return QDir::cleanPath(QDir::currentPath() + QDir::separator() + relativePath);
    }
    
    return QDir::cleanPath(getApplicationDir() + QDir::separator() + relativePath);
}

QString PathManager::getApplicationDir()
{
    return QCoreApplication::applicationDirPath();
}

QString PathManager::getResourcesDir()
{
    return QDir::cleanPath(getApplicationDir() + QDir::separator() + "resources");
}