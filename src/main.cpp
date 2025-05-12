#include <QtWidgets/QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QGuiApplication>
#include "../include/spectrogramgenerator.h"
#include "../include/previewimageprovider.h"
#include "../include/waveformprovider.h"
#include "../include/VisualizationFactory.h"
#include "../include/TaskManager.h"
#include "../include/Constants.h"
#include "../include/QmlConstants.h"
#include "../include/PathManager.h"
#include "../include/MacOSBridge.h"
#include <QDebug>

// Déclaration de la fonction d'initialisation macOS
#ifdef Q_OS_MAC
extern "C" void initMacOSSpecific();
extern "C" void fixFileDialogIssues();
extern "C" void configureFileOpenPanel();
extern "C" void configureFolderSelectPanel();
#endif

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QApplication app(argc, argv);
    
#ifdef Q_OS_MAC
    // Initialiser la prise en charge spécifique de macOS
    initMacOSSpecific();
    // Résoudre les problèmes de dialogue de fichiers macOS
    fixFileDialogIssues();
#endif
    
    // Initialiser les singletons
    VisualizationFactory::getInstance();
    TaskManager::getInstance();
    
    qDebug() << "Initialisation de l'application Sp3ctraGen";
    qDebug() << "Types de visualisation disponibles:" << VisualizationFactory::getInstance()->getAvailableStrategyNames();
    qDebug() << "Extensions supportées:" << VisualizationFactory::getInstance()->getSupportedExtensions();

    // Enregistrer nos types C++ pour QML
    qmlRegisterType<SpectrogramGenerator>("com.Sp3ctraGen.backend", 1, 0, "SpectrogramGenerator");
    qmlRegisterType<WaveformProvider>("com.Sp3ctraGen.backend", 1, 0, "WaveformProvider");
    qmlRegisterType<MacOSBridge>("com.Sp3ctraGen.backend", 1, 0, "MacOSBridge");
    
    // Enregistrer la classe QmlConstants comme singleton
    qmlRegisterSingletonType<QmlConstants>("com.Sp3ctraGen.constants", 1, 0, "Constants",
        [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
            Q_UNUSED(engine)
            Q_UNUSED(scriptEngine)
            return new QmlConstants();
        });

    QQmlApplicationEngine engine;
    
    // Créer et enregistrer le fournisseur d'images de prévisualisation
    PreviewImageProvider *previewProvider = new PreviewImageProvider();
    engine.addImageProvider("preview", previewProvider);
    
    // Rendre le fournisseur d'images accessible à la classe SpectrogramGenerator
    SpectrogramGenerator::setPreviewImageProvider(previewProvider);
    
    // Définir le chemin d'accès aux fichiers QML
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    
    // Connecter le signal aboutToQuit pour nettoyer les ressources
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    // Nettoyer les ressources lors de la fermeture de l'application
    QObject::connect(&app, &QGuiApplication::aboutToQuit, []() {
        qDebug() << "Nettoyage des ressources...";
        
        // Annuler toutes les tâches en cours
        TaskManager::getInstance()->cancelAllTasks();
        
        qDebug() << "Nettoyage terminé";
    });
    
    engine.load(url);

    return app.exec();
}
