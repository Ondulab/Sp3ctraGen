#ifndef MACOSBRIDGE_H
#define MACOSBRIDGE_H

#include <QObject>
#include <QString>

/**
 * Classe qui sert de pont entre QML et les fonctions natives de macOS
 */
class MacOSBridge : public QObject
{
    Q_OBJECT

public:
    explicit MacOSBridge(QObject *parent = nullptr);
    virtual ~MacOSBridge();

public slots:
    /**
     * Prépare les dialogues de fichiers natifs de macOS pour éviter les erreurs ViewBridge
     */
    void prepareFileDialogs();
    
    /**
     * Configure spécifiquement un dialogue d'ouverture de fichier avant son affichage
     */
    void prepareFileOpenDialog();
    
    /**
     * Configure spécifiquement un dialogue de sélection de dossier avant son affichage
     */
    void prepareFolderSelectDialog();
};

#endif // MACOSBRIDGE_H
