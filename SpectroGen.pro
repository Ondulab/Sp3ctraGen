###############################################################################
# SpectroGen - Application de génération de spectrogrammes basée sur Qt Quick
###############################################################################

# Configuration Qt
QT += quick printsupport

# Configuration du projet
CONFIG += c++17
CONFIG += qmltypes
CONFIG += sdk_no_version_check

# Nom et cible du projet
TARGET = SpectroGen
QML_IMPORT_NAME = com.cisynth.backend
QML_IMPORT_MAJOR_VERSION = 1

# Icône de l'application pour macOS
ICON = SpectroGen.icns

# Répertoires pour les fichiers générés
OBJECTS_DIR = build/obj
MOC_DIR = build/moc
RCC_DIR = build/rcc
UI_DIR = build/ui

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Fichiers source
SOURCES += \
    src/main.cpp \
    src/spectrogramgenerator.cpp \
    src/spectral_generator.c \
    src/spectral_wav_processing.c \
    src/spectral_fft.c \
    src/spectral_raster.c \
    src/spectral_vector.c \
    src/previewimageprovider.cpp \
    src/waveformprovider.cpp \
    src/vectorprintprovider.cpp

# Fichiers d'en-tête
HEADERS += \
    include/spectrogramgenerator.h \
    include/spectral_generator.h \
    src/spectral_common.h \
    src/spectral_wav_processing.h \
    src/spectral_fft.h \
    include/previewimageprovider.h \
    include/waveformprovider.h \
    include/vectorprintprovider.h

# Chemins d'inclusion
INCLUDEPATH += $$PWD/include

# Ressources
RESOURCES += qml/qml.qrc

# Chemins d'importation QML
QML_IMPORT_PATH =
QML_DESIGNER_IMPORT_PATH =

# Règles de déploiement
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# Configuration des bibliothèques externes
unix:!macx {
    # Configuration Linux
    LIBS += -lfftw3 -lcairo -lsndfile
}
macx {
    # Configuration macOS
    LIBS += -L/opt/homebrew/lib -lfftw3 -lcairo -lsndfile
    INCLUDEPATH += /opt/homebrew/include
}
win32 {
    # Configuration Windows
    # Windows-specific library paths would go here
}
