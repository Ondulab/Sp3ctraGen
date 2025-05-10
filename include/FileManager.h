/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QString>
#include <QDir>

/**
 * @brief Utility class for file management
 *
 * This class provides static methods to manage file operations
 * consistently throughout the application.
 */
class FileManager {
public:
    /**
     * @brief Validates an input file
     *
     * @param path Path of the file to validate
     * @return true if the file exists and is readable
     */
    static bool validateInputFile(const QString& path);
    
    /**
     * @brief Validates an output directory
     *
     * @param path Path of the directory to validate
     * @return true if the directory exists and is writable
     */
    static bool validateOutputDirectory(const QString& path);
    
    /**
     * @brief Creates a directory if it doesn't exist
     *
     * @param path Path of the directory to create
     * @return true if the directory exists or was successfully created
     */
    static bool ensureDirectoryExists(const QString& path);
    
    /**
     * @brief Gets the default input file path
     *
     * @return Default input file path
     */
    static QString getDefaultInputPath();
    
    /**
     * @brief Gets the default output directory path
     *
     * @return Default output directory path
     */
    static QString getDefaultOutputPath();
    
    /**
     * @brief Generates an output filename based on the format
     *
     * @param outputFolder Output directory
     * @param baseName Base name of the file
     * @param format File format (png, pdf, etc.)
     * @return Complete path of the output file
     */
    static QString generateOutputFilename(const QString& outputFolder, 
                                         const QString& baseName,
                                         const QString& format);
};

#endif // FILEMANAGER_H