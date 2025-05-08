#ifndef VISUALIZATIONFACTORY_H
#define VISUALIZATIONFACTORY_H

#include <QObject>
#include <QMap>
#include <QString>
#include "VisualizationStrategy.h"

/**
 * @brief Fabrique pour les stratégies de visualisation
 * 
 * Cette classe implémente le pattern Factory pour créer et gérer
 * les différentes stratégies de visualisation disponibles.
 */
class VisualizationFactory : public QObject
{
    Q_OBJECT
    
public:
    /**
     * @brief Obtient l'instance unique de la fabrique (Singleton)
     * 
     * @return Instance de la fabrique
     */
    static VisualizationFactory* getInstance();
    
    /**
     * @brief Obtient une stratégie de visualisation par son nom
     * 
     * @param name Nom de la stratégie
     * @return Pointeur vers la stratégie ou nullptr si non trouvée
     */
    VisualizationStrategy* getStrategy(const QString& name);
    
    /**
     * @brief Obtient une stratégie de visualisation par extension de fichier
     * 
     * @param extension Extension de fichier (sans le point)
     * @return Pointeur vers la stratégie ou nullptr si non trouvée
     */
    VisualizationStrategy* getStrategyForExtension(const QString& extension);
    
    /**
     * @brief Obtient la liste des noms de stratégies disponibles
     * 
     * @return Liste des noms de stratégies
     */
    QStringList getAvailableStrategyNames() const;
    
    /**
     * @brief Obtient la liste des extensions de fichier supportées
     * 
     * @return Liste des extensions supportées (sans le point)
     */
    QStringList getSupportedExtensions() const;
    
private:
    /**
     * @brief Constructeur privé (Singleton)
     * 
     * @param parent Objet parent
     */
    explicit VisualizationFactory(QObject *parent = nullptr);
    
    /**
     * @brief Destructeur
     */
    ~VisualizationFactory();
    
    /**
     * @brief Initialise les stratégies disponibles
     */
    void initializeStrategies();
    
    static VisualizationFactory* s_instance; // Instance unique (Singleton)
    QMap<QString, VisualizationStrategy*> m_strategies; // Stratégies par nom
};

#endif // VISUALIZATIONFACTORY_H