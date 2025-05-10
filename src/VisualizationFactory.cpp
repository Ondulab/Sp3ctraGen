/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#include "../include/VisualizationFactory.h"
#include "../include/RasterVisualizationStrategy.h"
#include "../include/VectorVisualizationStrategy.h"
#include <QDebug>

// Initialization of the static instance
VisualizationFactory* VisualizationFactory::s_instance = nullptr;

VisualizationFactory* VisualizationFactory::getInstance()
{
    if (!s_instance) {
        s_instance = new VisualizationFactory();
    }
    return s_instance;
}

VisualizationFactory::VisualizationFactory(QObject *parent)
    : QObject(parent)
{
    initializeStrategies();
}

VisualizationFactory::~VisualizationFactory()
{
    // Clean up strategies
    qDeleteAll(m_strategies);
    m_strategies.clear();
}

void VisualizationFactory::initializeStrategies()
{
    // Create and register available strategies
    RasterVisualizationStrategy* rasterStrategy = new RasterVisualizationStrategy(this);
    VectorVisualizationStrategy* vectorStrategy = new VectorVisualizationStrategy(this);
    
    // Register strategies by name
    m_strategies[rasterStrategy->getName()] = rasterStrategy;
    m_strategies[vectorStrategy->getName()] = vectorStrategy;
    
    qDebug() << "Visualization strategies initialized:" << m_strategies.keys();
}

VisualizationStrategy* VisualizationFactory::getStrategy(const QString& name)
{
    if (m_strategies.contains(name)) {
        return m_strategies[name];
    }
    
    qWarning() << "Visualization strategy not found:" << name;
    return nullptr;
}

VisualizationStrategy* VisualizationFactory::getStrategyForExtension(const QString& extension)
{
    QString lowerExt = extension.toLower();
    
    // Go through all strategies to find one that supports this extension
    for (auto it = m_strategies.begin(); it != m_strategies.end(); ++it) {
        VisualizationStrategy* strategy = it.value();
        if (strategy->getSupportedExtensions().contains(lowerExt)) {
            return strategy;
        }
    }
    
    qWarning() << "No strategy found for extension:" << extension;
    return nullptr;
}

QStringList VisualizationFactory::getAvailableStrategyNames() const
{
    return m_strategies.keys();
}

QStringList VisualizationFactory::getSupportedExtensions() const
{
    QStringList extensions;
    
    // Collect all extensions supported by all strategies
    for (auto it = m_strategies.begin(); it != m_strategies.end(); ++it) {
        VisualizationStrategy* strategy = it.value();
        extensions.append(strategy->getSupportedExtensions());
    }
    
    // Remove duplicates
    extensions.removeDuplicates();
    
    return extensions;
}