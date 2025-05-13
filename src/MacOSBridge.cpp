#include "../include/MacOSBridge.h"
#include <QDebug>
#include <QStandardPaths>

#ifdef Q_OS_MAC
// Déclarations de fonctions natives macOS
extern "C" void fixFileDialogIssues();
extern "C" void configureFileOpenPanel();
extern "C" void configureFolderSelectPanel();
extern "C" void configureSavePanel();
extern "C" void configureSavePanelWithName(const char* fileName);
#endif

MacOSBridge::MacOSBridge(QObject *parent) : QObject(parent)
{
    qDebug() << "MacOSBridge initialized";
}

MacOSBridge::~MacOSBridge()
{
}

void MacOSBridge::prepareFileDialogs()
{
#ifdef Q_OS_MAC
    fixFileDialogIssues();
#else
    qDebug() << "prepareFileDialogs: Not on macOS, no action needed";
#endif
}

void MacOSBridge::prepareFileOpenDialog()
{
#ifdef Q_OS_MAC
    configureFileOpenPanel();
#else
    qDebug() << "prepareFileOpenDialog: Not on macOS, no action needed";
#endif
}

void MacOSBridge::prepareFolderSelectDialog()
{
#ifdef Q_OS_MAC
    configureFolderSelectPanel();
#else
    qDebug() << "prepareFolderSelectDialog: Not on macOS, no action needed";
#endif
}

void MacOSBridge::prepareSaveDialog()
{
#ifdef Q_OS_MAC
    configureSavePanel();
#else
    qDebug() << "prepareSaveDialog: Not on macOS, no action needed";
#endif
}

void MacOSBridge::prepareSaveDialogWithName(const QString &fileName)
{
#ifdef Q_OS_MAC
    // Convertir QString en const char* pour l'interface C
    QByteArray fileNameUtf8 = fileName.toUtf8();
    configureSavePanelWithName(fileNameUtf8.constData());
#else
    qDebug() << "prepareSaveDialogWithName: Not on macOS, no action needed";
#endif
}

QString MacOSBridge::getDownloadsPath()
{
#ifdef Q_OS_MAC
    QString downloadsPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    qDebug() << "Downloads path: " << downloadsPath;
    return downloadsPath;
#else
    // Fallback sur le répertoire standard des téléchargements pour les autres plateformes
    return QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
#endif
}
