#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "../include/spectrogramgenerator.h"
#include "../include/previewimageprovider.h"
#include "../include/waveformprovider.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    // Enregistrer nos types C++ pour QML
    qmlRegisterType<SpectrogramGenerator>("com.spectrogen.backend", 1, 0, "SpectrogramGenerator");
    qmlRegisterType<WaveformProvider>("com.spectrogen.backend", 1, 0, "WaveformProvider");

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
    
    engine.load(url);

    return app.exec();
}
