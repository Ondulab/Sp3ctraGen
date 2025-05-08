#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QString>
#include <QDir>

/**
 * @brief Classe utilitaire pour la gestion des fichiers
 * 
 * Cette classe fournit des méthodes statiques pour gérer les opérations de fichiers
 * de manière cohérente dans toute l'application.
 */
class FileManager {
public:
    /**
     * @brief Valide un fichier d'entrée
     * 
     * @param path Chemin du fichier à valider
     * @return true si le fichier existe et est lisible
     */
    static bool validateInputFile(const QString& path);
    
    /**
     * @brief Valide un dossier de sortie
     * 
     * @param path Chemin du dossier à valider
     * @return true si le dossier existe et est accessible en écriture
     */
    static bool validateOutputDirectory(const QString& path);
    
    /**
     * @brief Crée un dossier s'il n'existe pas
     * 
     * @param path Chemin du dossier à créer
     * @return true si le dossier existe ou a été créé avec succès
     */
    static bool ensureDirectoryExists(const QString& path);
    
    /**
     * @brief Obtient le chemin du fichier d'entrée par défaut
     * 
     * @return Chemin du fichier d'entrée par défaut
     */
    static QString getDefaultInputPath();
    
    /**
     * @brief Obtient le chemin du dossier de sortie par défaut
     * 
     * @return Chemin du dossier de sortie par défaut
     */
    static QString getDefaultOutputPath();
    
    /**
     * @brief Génère un nom de fichier de sortie basé sur le format
     * 
     * @param outputFolder Dossier de sortie
     * @param baseName Nom de base du fichier
     * @param format Format du fichier (png, pdf, etc.)
     * @return Chemin complet du fichier de sortie
     */
    static QString generateOutputFilename(const QString& outputFolder, 
                                         const QString& baseName,
                                         const QString& format);
};

#endif // FILEMANAGER_H