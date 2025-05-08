#ifndef VECTORVISUALIZATIONSTRATEGY_H
#define VECTORVISUALIZATIONSTRATEGY_H

#include "VisualizationStrategy.h"

/**
 * @brief Stratégie de visualisation pour les spectrogrammes vectoriels (PDF)
 *
 * Cette classe implémente la génération de spectrogrammes au format vectoriel (PDF)
 * en utilisant la fonction spectral_generator_vector_pdf_impl.
 */
class VectorVisualizationStrategy : public VisualizationStrategy
{
    Q_OBJECT
    
public:
    explicit VectorVisualizationStrategy(QObject *parent = nullptr);
    virtual ~VectorVisualizationStrategy() = default;
    
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
    
    /**
     * @brief Définit la résolution DPI pour la génération PDF
     *
     * @param dpi Résolution en DPI
     */
    void setDpi(int dpi);
    
    /**
     * @brief Obtient la résolution DPI actuelle
     *
     * @return Résolution en DPI
     */
    int getDpi() const;
    
protected:
    /**
     * @brief Implémentation spécifique de la génération pour le format vectoriel
     *
     * @param settings Paramètres du spectrogramme
     * @param inputFile Fichier audio d'entrée
     * @param outputFile Fichier de sortie
     * @return Code de retour (EXIT_SUCCESS ou EXIT_FAILURE)
     */
    int callGeneratorFunction(const SpectrogramSettings& settings,
                             const char* inputFile,
                             const char* outputFile) override;
                      
    int m_dpi; // Résolution en DPI pour la génération PDF
};

#endif // VECTORVISUALIZATIONSTRATEGY_H