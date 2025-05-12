#!/bin/bash

# Script de build pour Sp3ctraGen
# - Multithread (12 jobs)
# - Clean optionnel avec --clean

# Aller au répertoire racine du projet
cd "$(dirname "$0")/.." || exit 1

# Détection de qmake
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

# Nettoyage optionnel
if [ "$1" == "--clean" ]; then
    echo "Nettoyage complet..."
    rm -rf build
    make clean >/dev/null 2>&1
fi

# Génération Makefile
$QMAKE_PATH -spec macx-clang CONFIG+=debug CONFIG+=qml_debug

if [ $? -ne 0 ]; then
    echo "Erreur lors de l'exécution de qmake"
    exit 1
fi

# Compilation multithread
echo "Compilation avec 12 threads..."
make -j12

if [ $? -ne 0 ]; then
    echo "Erreur lors de la compilation"
    exit 1
fi

echo "✅ Compilation réussie"
echo "📦 Exécutable : Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen"

# Déploiement des bibliothèques Qt requises dans le bundle
echo "📚 Déploiement des dépendances Qt..."
MACDEPLOYQT_PATH="$(dirname "$QMAKE_PATH")/macdeployqt"

if [ ! -f "$MACDEPLOYQT_PATH" ]; then
    echo "⚠️ macdeployqt non trouvé à $MACDEPLOYQT_PATH, tentative de recherche alternative..."
    if which macdeployqt >/dev/null 2>&1; then
        MACDEPLOYQT_PATH=$(which macdeployqt)
    else
        echo "❌ Erreur: macdeployqt non trouvé. Les bibliothèques Qt ne seront pas intégrées à l'application."
        exit 1
    fi
fi

echo "Utilisation de macdeployqt: $MACDEPLOYQT_PATH"
"$MACDEPLOYQT_PATH" Sp3ctraGen.app -qmldir=./qml -verbose=2

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors du déploiement des bibliothèques Qt"
    exit 1
fi

echo "✅ Déploiement des dépendances Qt réussi"

# Re-signature de l'application après déploiement
echo "🔒 Re-signature de l'application..."
codesign --force --deep --sign - Sp3ctraGen.app

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la re-signature de l'application"
    exit 1
fi

echo "✅ Re-signature réussie"
