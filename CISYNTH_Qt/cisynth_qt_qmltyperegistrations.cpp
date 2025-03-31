/****************************************************************************
** Generated QML type registration code
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <QtQml/qqml.h>
#include <QtQml/qqmlmoduleregistration.h>

#include <spectrogramgenerator.h>

void qml_register_types_com_cisynth_backend()
{
    qmlRegisterTypesAndRevisions<SpectrogramGenerator>("com.cisynth.backend", 1);
    qmlRegisterModule("com.cisynth.backend", 1, 0);
}

static const QQmlModuleRegistration registration("com.cisynth.backend", 1, qml_register_types_com_cisynth_backend);
