/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef VISUALIZATIONFACTORY_H
#define VISUALIZATIONFACTORY_H

#include <QObject>
#include <QMap>
#include <QString>
#include "VisualizationStrategy.h"

/**
 * @brief Factory for visualization strategies
 *
 * This class implements the Factory pattern to create and manage
 * the different available visualization strategies.
 */
class VisualizationFactory : public QObject
{
    Q_OBJECT
    
public:
    /**
     * @brief Gets the unique instance of the factory (Singleton)
     *
     * @return Factory instance
     */
    static VisualizationFactory* getInstance();
    
    /**
     * @brief Gets a visualization strategy by its name
     *
     * @param name Strategy name
     * @return Pointer to the strategy or nullptr if not found
     */
    VisualizationStrategy* getStrategy(const QString& name);
    
    /**
     * @brief Gets a visualization strategy by file extension
     *
     * @param extension File extension (without the dot)
     * @return Pointer to the strategy or nullptr if not found
     */
    VisualizationStrategy* getStrategyForExtension(const QString& extension);
    
    /**
     * @brief Gets the list of available strategy names
     *
     * @return List of strategy names
     */
    QStringList getAvailableStrategyNames() const;
    
    /**
     * @brief Gets the list of supported file extensions
     *
     * @return List of supported extensions (without the dot)
     */
    QStringList getSupportedExtensions() const;
    
private:
    /**
     * @brief Private constructor (Singleton)
     *
     * @param parent Parent object
     */
    explicit VisualizationFactory(QObject *parent = nullptr);
    
    /**
     * @brief Destructor
     */
    ~VisualizationFactory();
    
    /**
     * @brief Initializes available strategies
     */
    void initializeStrategies();
    
    static VisualizationFactory* s_instance; // Unique instance (Singleton)
    QMap<QString, VisualizationStrategy*> m_strategies; // Strategies by name
};

#endif // VISUALIZATIONFACTORY_H