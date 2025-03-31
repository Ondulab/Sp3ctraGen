#!/bin/bash

# Script pour compiler le projet SpectroGen

# Trouver qmake
QMAKE_PATH=""

if which qmake >/dev/null 2>&1; then
    QMAKE_PATH=$(which qmake)
elif [ -f /usr/local/opt/qt@5/bin/qmake ]; then
    QMAKE_PATH="/usr/local/opt/qt@5/bin/qmake"
elif [ -f /usr/local/opt/qt5/bin/qmake ]; then
    QMAKE_PATH="/usr/local/opt/qt5/bin/qmake"
elif [ -f /opt/homebrew/opt/qt@5/bin/qmake ]; then
    QMAKE_PATH="/opt/homebrew/opt/qt@5/bin/qmake"
elif [ -f /opt/homebrew/opt/qt5/bin/qmake ]; then
    QMAKE_PATH="/opt/homebrew/opt/qt5/bin/qmake"
else
    echo "Erreur: qmake non trouvé"
    exit 1
fi

echo "Utilisation de qmake: $QMAKE_PATH"

# Exécuter qmake
$QMAKE_PATH -spec macx-clang CONFIG+=debug CONFIG+=qml_debug

# Vérifier si qmake a réussi
if [ $? -ne 0 ]; then
    echo "Erreur lors de l'exécution de qmake"
    exit 1
fi

# Compiler avec make
make

# Vérifier si make a réussi
if [ $? -ne 0 ]; then
    echo "Erreur lors de la compilation"
    exit 1
fi

echo "Compilation réussie!"
echo "L'exécutable se trouve dans: SpectroGen.app/Contents/MacOS/SpectroGen"
