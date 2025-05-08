#ifndef RASTERVISUALIZATIONSTRATEGY_H
#define RASTERVISUALIZATIONSTRATEGY_H

#include "VisualizationStrategy.h"

/**
 * @brief Stratégie de visualisation pour les spectrogrammes raster (PNG)
 *
 * Cette classe implémente la génération de spectrogrammes au format raster (PNG)
 * en utilisant la fonction spectral_generator_impl.
 */
class RasterVisualizationStrategy : public VisualizationStrategy
{
    Q_OBJECT
    
public:
    explicit RasterVisualizationStrategy(QObject *parent = nullptr);
    virtual ~RasterVisualizationStrategy() = default;
    
    /**
     * @brief Obtient le nom de la stratégie
     *
     * @return Nom de la stratégie
     */
    QString getName() const override;
    
    /**
     * @brief Obtient la description de la stratégie
     *
     * @return Description de la stratégie
     */
    QString getDescription() const override;
    
    /**
     * @brief Obtient les extensions de fichier supportées
     *
     * @return Liste des extensions supportées (sans le point)
     */
    QStringList getSupportedExtensions() const override;
    
protected:
    /**
     * @brief Implémentation spécifique de la génération pour le format raster
     *
     * @param settings Paramètres du spectrogramme
     * @param inputFile Fichier audio d'entrée
     * @param outputFile Fichier de sortie
     * @return Code de retour (EXIT_SUCCESS ou EXIT_FAILURE)
     */
    int callGeneratorFunction(const SpectrogramSettings& settings,
                             const char* inputFile,
                             const char* outputFile) override;
};

#endif // RASTERVISUALIZATIONSTRATEGY_H