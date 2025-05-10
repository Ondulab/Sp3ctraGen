/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef PATHMANAGER_H
#define PATHMANAGER_H

#include <QString>
#include <QDir>

/**
 * @brief File path management class
 *
 * This class provides methods to manage file paths
 * consistently and eliminate hardcoded paths.
 */
class PathManager
{
public:
    /**
     * @brief Gets the default input file path
     *
     * @return Default input file path
     */
    static QString getDefaultInputPath();
    
    /**
     * @brief Gets the default output folder
     *
     * @return Default output folder
     */
    static QString getDefaultOutputFolder();
    
    /**
     * @brief Gets the default output file path
     *
     * @return Default output file path
     */
    static QString getDefaultOutputPath();
    
    /**
     * @brief Gets the default PDF file path
     *
     * @return Default PDF file path
     */
    static QString getDefaultPdfPath();
    
    /**
     * @brief Resolves a relative path to an absolute path
     *
     * @param relativePath Relative path
     * @return Absolute path
     */
    static QString resolveRelativePath(const QString& relativePath);
    
    /**
     * @brief Gets the application directory
     *
     * @return Application directory
     */
    static QString getApplicationDir();
    
    /**
     * @brief Gets the resources directory
     *
     * @return Resources directory
     */
    static QString getResourcesDir();
};

#endif // PATHMANAGER_H