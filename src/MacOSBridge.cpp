#include "../include/MacOSBridge.h"
#include <QDebug>

#ifdef Q_OS_MAC
// Déclarations de fonctions natives macOS
extern "C" void fixFileDialogIssues();
extern "C" void configureFileOpenPanel();
extern "C" void configureFolderSelectPanel();
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
