#!/bin/bash

# Script de build léger pour Sp3ctraGen
# - Compilation multithread (12 jobs)
# - Nettoyage du projet (optionnel avec --clean)
# - Déploiement minimal des bibliothèques Qt (optionnel avec --no-deploy)

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
    echo "❌ Erreur: qmake non trouvé"
    exit 1
fi

echo "🔍 Utilisation de qmake: $QMAKE_PATH"

# Configuration et traitement des arguments
DEPLOY_QT=true
DO_CLEAN=false

# Traitement des arguments
for arg in "$@"
do
    case $arg in
        --clean)
            DO_CLEAN=true
            echo "ℹ️ Le projet sera nettoyé avant la compilation"
            ;;
        --no-deploy)
            DEPLOY_QT=false
            echo "ℹ️ Déploiement Qt désactivé"
            ;;
        --help)
            echo "Usage: ./scripts/build.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --clean      Nettoie le projet avant compilation"
            echo "  --no-deploy  Désactive le déploiement Qt (build rapide)"
            echo "  --help       Affiche cette aide"
            exit 0
            ;;
    esac
done

# Nettoyage du projet si demandé
if [ "$DO_CLEAN" = true ]; then
    echo "🧹 Nettoyage du projet avant compilation..."
    ./scripts/clean.sh
    
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors du nettoyage"
        exit 1
    fi
fi

# Génération Makefile
echo "🔧 Génération du Makefile..."
$QMAKE_PATH -spec macx-clang CONFIG+=debug CONFIG+=qml_debug

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de l'exécution de qmake"
    exit 1
fi

# Compilation multithread
echo "🚀 Compilation avec 12 threads..."
make -j12

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la compilation"
    exit 1
fi

echo "✅ Compilation réussie"

# Déploiement des bibliothèques Qt (si l'option est activée)
if [ "$DEPLOY_QT" = true ]; then
    echo "📚 Déploiement minimal des bibliothèques Qt..."
    MACDEPLOYQT_PATH="$(dirname "$QMAKE_PATH")/macdeployqt"

    if [ ! -f "$MACDEPLOYQT_PATH" ]; then
        if which macdeployqt >/dev/null 2>&1; then
            MACDEPLOYQT_PATH=$(which macdeployqt)
        else
            echo "⚠️ macdeployqt non trouvé, l'application pourrait ne pas fonctionner correctement"
            exit 1
        fi
    fi

    # Déploiement minimal des bibliothèques Qt
    "$MACDEPLOYQT_PATH" Sp3ctraGen.app -qmldir=./qml -verbose=0

    if [ $? -ne 0 ]; then
        echo "⚠️ Avertissement: problème lors du déploiement des bibliothèques Qt"
        echo "   L'application pourrait ne pas fonctionner correctement"
    else
        echo "✅ Déploiement minimal des bibliothèques Qt terminé"
    fi
    
    # Re-signature de l'application après déploiement complet
    echo "🔒 Re-signature de l'application après déploiement..."
    codesign --force --deep --sign - Sp3ctraGen.app
    
    if [ $? -ne 0 ]; then
        echo "⚠️ Avertissement: problème lors de la re-signature de l'application"
        echo "   L'application pourrait ne pas fonctionner correctement"
    else
        echo "✅ Re-signature réussie"
    fi
else
    echo "ℹ️ Déploiement Qt ignoré (--no-deploy activé)"
    
    # Signature de l'application simple lorsque le déploiement est ignoré
    echo "🔒 Signature de l'application..."
    codesign --force --sign - Sp3ctraGen.app
    
    if [ $? -ne 0 ]; then
        echo "⚠️ Avertissement: problème lors de la signature de l'application"
        echo "   L'application pourrait ne pas fonctionner correctement"
    else
        echo "✅ Signature réussie"
    fi
fi

echo "📦 Exécutable : Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen"
echo ""
echo "💡 Options disponibles:"
echo "   ./scripts/build.sh --clean      # Nettoie avant compilation"
echo "   ./scripts/build.sh --no-deploy  # Build rapide sans déploiement Qt"
echo "   ./scripts/build.sh --help       # Affiche l'aide complète"
echo ""
echo "ℹ️ Pour un déploiement complet avec création de DMG, utilisez:"
echo "   ./scripts/package.sh"
