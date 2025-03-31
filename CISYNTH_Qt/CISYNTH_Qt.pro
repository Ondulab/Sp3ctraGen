QT += quick

CONFIG += c++17
CONFIG += qmltypes
CONFIG += sdk_no_version_check

QML_IMPORT_NAME = com.cisynth.backend
QML_IMPORT_MAJOR_VERSION = 1

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    src/main.cpp \
    src/spectrogramgenerator.cpp \
    src/spectral_generator.c

HEADERS += \
    include/spectrogramgenerator.h \
    include/spectral_generator.h

# Include path for header files
INCLUDEPATH += $$PWD/include

RESOURCES += qml/qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# FFTW3 library
unix:!macx {
    LIBS += -lfftw3 -lcairo -lsndfile
}
macx {
    LIBS += -L/opt/homebrew/lib -lfftw3 -lcairo -lsndfile
    INCLUDEPATH += /opt/homebrew/include
}
win32 {
    # Windows-specific library paths would go here
}
