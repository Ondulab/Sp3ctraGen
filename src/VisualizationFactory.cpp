#include "../include/VisualizationFactory.h"
#include "../include/RasterVisualizationStrategy.h"
#include "../include/VectorVisualizationStrategy.h"
#include <QDebug>

// Initialisation de l'instance statique
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
    // Nettoyer les stratégies
    qDeleteAll(m_strategies);
    m_strategies.clear();
}

void VisualizationFactory::initializeStrategies()
{
    // Créer et enregistrer les stratégies disponibles
    RasterVisualizationStrategy* rasterStrategy = new RasterVisualizationStrategy(this);
    VectorVisualizationStrategy* vectorStrategy = new VectorVisualizationStrategy(this);
    
    // Enregistrer les stratégies par nom
    m_strategies[rasterStrategy->getName()] = rasterStrategy;
    m_strategies[vectorStrategy->getName()] = vectorStrategy;
    
    qDebug() << "Stratégies de visualisation initialisées:" << m_strategies.keys();
}

VisualizationStrategy* VisualizationFactory::getStrategy(const QString& name)
{
    if (m_strategies.contains(name)) {
        return m_strategies[name];
    }
    
    qWarning() << "Stratégie de visualisation non trouvée:" << name;
    return nullptr;
}

VisualizationStrategy* VisualizationFactory::getStrategyForExtension(const QString& extension)
{
    QString lowerExt = extension.toLower();
    
    // Parcourir toutes les stratégies pour trouver celle qui supporte cette extension
    for (auto it = m_strategies.begin(); it != m_strategies.end(); ++it) {
        VisualizationStrategy* strategy = it.value();
        if (strategy->getSupportedExtensions().contains(lowerExt)) {
            return strategy;
        }
    }
    
    qWarning() << "Aucune stratégie trouvée pour l'extension:" << extension;
    return nullptr;
}

QStringList VisualizationFactory::getAvailableStrategyNames() const
{
    return m_strategies.keys();
}

QStringList VisualizationFactory::getSupportedExtensions() const
{
    QStringList extensions;
    
    // Collecter toutes les extensions supportées par toutes les stratégies
    for (auto it = m_strategies.begin(); it != m_strategies.end(); ++it) {
        VisualizationStrategy* strategy = it.value();
        extensions.append(strategy->getSupportedExtensions());
    }
    
    // Éliminer les doublons
    extensions.removeDuplicates();
    
    return extensions;
}