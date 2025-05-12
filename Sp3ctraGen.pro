###############################################################################
# Sp3ctraGen - Application de génération de spectrogrammes basée sur Qt Quick
###############################################################################

# Configuration Qt
QT += quick printsupport

# Configuration du projet
CONFIG += c++17
CONFIG += qmltypes
CONFIG += sdk_no_version_check

# Nom et cible du projet
TARGET = Sp3ctraGen
QML_IMPORT_NAME = com.cisynth.backend
QML_IMPORT_MAJOR_VERSION = 1

# Icône de l'application pour macOS
ICON = Sp3ctraGen.icns

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
    src/vectorprintprovider.cpp \
    src/SpectrogramSettingsCpp.cpp \
    src/FileManager.cpp \
    src/RasterVisualizationStrategy.cpp \
    src/VectorVisualizationStrategy.cpp \
    src/VisualizationFactory.cpp \
    src/TaskManager.cpp \
    src/VisualizationStrategy.cpp \
    src/QmlConstants.cpp \
    src/PathManager.cpp \
    src/MacOSBridge.cpp

# Fichiers d'en-tête
HEADERS += \
    include/spectrogramgenerator.h \
    include/spectral_generator.h \
    src/spectral_common.h \
    src/spectral_wav_processing.h \
    src/spectral_fft.h \
    include/previewimageprovider.h \
    include/waveformprovider.h \
    include/vectorprintprovider.h \
    include/SpectrogramSettingsCpp.h \
    include/Constants.h \
    include/SharedConstants.h \
    include/FileManager.h \
    include/VisualizationStrategy.h \
    include/RasterVisualizationStrategy.h \
    include/VectorVisualizationStrategy.h \
    include/VisualizationFactory.h \
    include/TaskManager.h \
    include/QmlConstants.h \
    include/PathManager.h \
    include/MacOSBridge.h

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
    
    # Objectif-C++ pour la prise en charge spécifique à macOS
    OBJECTIVE_SOURCES += src/macos_utils.mm
    LIBS += -framework Cocoa
}
win32 {
    # Configuration Windows
    # Windows-specific library paths would go here
}
