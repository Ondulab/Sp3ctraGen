#ifndef PATHMANAGER_H
#define PATHMANAGER_H

#include <QString>
#include <QDir>

/**
 * @brief Classe de gestion des chemins de fichiers
 * 
 * Cette classe fournit des méthodes pour gérer les chemins de fichiers
 * de manière cohérente et éliminer les chemins codés en dur.
 */
class PathManager
{
public:
    /**
     * @brief Obtient le chemin par défaut du fichier d'entrée
     * 
     * @return Chemin par défaut du fichier d'entrée
     */
    static QString getDefaultInputPath();
    
    /**
     * @brief Obtient le dossier de sortie par défaut
     * 
     * @return Dossier de sortie par défaut
     */
    static QString getDefaultOutputFolder();
    
    /**
     * @brief Obtient le chemin par défaut du fichier de sortie
     * 
     * @return Chemin par défaut du fichier de sortie
     */
    static QString getDefaultOutputPath();
    
    /**
     * @brief Obtient le chemin par défaut du fichier PDF
     * 
     * @return Chemin par défaut du fichier PDF
     */
    static QString getDefaultPdfPath();
    
    /**
     * @brief Résout un chemin relatif en chemin absolu
     * 
     * @param relativePath Chemin relatif
     * @return Chemin absolu
     */
    static QString resolveRelativePath(const QString& relativePath);
    
    /**
     * @brief Obtient le répertoire de l'application
     * 
     * @return Répertoire de l'application
     */
    static QString getApplicationDir();
    
    /**
     * @brief Obtient le répertoire des ressources
     * 
     * @return Répertoire des ressources
     */
    static QString getResourcesDir();
};

#endif // PATHMANAGER_H