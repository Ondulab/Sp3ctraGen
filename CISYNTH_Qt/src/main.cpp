#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "../include/spectrogramgenerator.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    // Enregistrer notre type C++ pour QML
    qmlRegisterType<SpectrogramGenerator>("com.spectrogen.backend", 1, 0, "SpectrogramGenerator");

    QQmlApplicationEngine engine;
    
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
