#ifndef VISUALIZATIONSTRATEGY_H
#define VISUALIZATIONSTRATEGY_H

#include <QString>
#include <QObject>
#include "SpectrogramSettingsCpp.h"

/**
 * @brief Interface de stratégie pour les différents types de visualisation
 * 
 * Cette classe définit l'interface commune pour toutes les stratégies de visualisation.
 * Elle utilise le pattern Strategy pour permettre l'ajout facile de nouveaux types de visualisation.
 */
class VisualizationStrategy : public QObject
{
    Q_OBJECT
    
public:
    explicit VisualizationStrategy(QObject *parent = nullptr) : QObject(parent) {}
    virtual ~VisualizationStrategy() = default;
    
    /**
     * @brief Génère une visualisation
     * 
     * @param settings Paramètres du spectrogramme
     * @param inputFile Fichier audio d'entrée
     * @param outputFile Fichier de sortie
     * @return true si la génération a réussi
     */
    virtual bool generate(const SpectrogramSettingsCpp& settings, 
                         const QString& inputFile,
                         const QString& outputFile) = 0;
                         
    /**
     * @brief Obtient le nom de la stratégie
     * 
     * @return Nom de la stratégie
     */
    virtual QString getName() const = 0;
    
    /**
     * @brief Obtient la description de la stratégie
     * 
     * @return Description de la stratégie
     */
    virtual QString getDescription() const = 0;
    
    /**
     * @brief Obtient les extensions de fichier supportées
     * 
     * @return Liste des extensions supportées (sans le point)
     */
    virtual QStringList getSupportedExtensions() const = 0;
    
signals:
    /**
     * @brief Signal émis pendant la génération pour indiquer la progression
     * 
     * @param progress Progression (0-100)
     * @param message Message de progression
     */
    void progressUpdated(int progress, const QString& message);
    
    /**
     * @brief Signal émis lorsque la génération est terminée
     * 
     * @param success Succès de la génération
     * @param outputPath Chemin du fichier de sortie
     * @param errorMessage Message d'erreur en cas d'échec
     */
    void generationCompleted(bool success, const QString& outputPath, const QString& errorMessage = "");
};

#endif // VISUALIZATIONSTRATEGY_H