#!/bin/bash

# Script d'empaquetage complet pour Sp3ctraGen
# Ce script :
# 1. Nettoie le projet (optionnel avec --no-clean)
# 2. Compile l'application
# 3. Déploie les bibliothèques Qt et dépendances (optionnel avec --no-deploy)
# 4. Crée un DMG pour la distribution (optionnel avec --no-dmg)

# Aller au répertoire racine du projet
cd "$(dirname "$0")/.." || exit 1

echo "🚀 Démarrage du processus d'empaquetage de Sp3ctraGen..."

# Configuration des options
DO_CLEAN=true
DO_DEPLOY=true
DO_DMG=true
BUILD_ARGS=""

# Traitement des arguments
for arg in "$@"
do
    case $arg in
        --no-clean)
            DO_CLEAN=false
            echo "ℹ️ Option: Pas de nettoyage"
            ;;
        --no-deploy)
            DO_DEPLOY=false
            BUILD_ARGS="$BUILD_ARGS --no-deploy"
            echo "ℹ️ Option: Pas de déploiement Qt"
            ;;
        --no-dmg)
            DO_DMG=false
            echo "ℹ️ Option: Pas de création de DMG"
            ;;
        --help)
            echo "Usage: ./scripts/package.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-clean   Ne pas nettoyer avant la compilation"
            echo "  --no-deploy  Ne pas déployer les bibliothèques Qt"
            echo "  --no-dmg     Ne pas créer de DMG pour la distribution"
            echo "  --help       Affiche cette aide"
            exit 0
            ;;
    esac
done

# Étape 1 : Nettoyage (si activé)
if [ "$DO_CLEAN" = true ]; then
    echo "🧹 Nettoyage du projet..."
    ./scripts/clean.sh
    
    # Vérifier si le nettoyage a réussi
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors du nettoyage. Abandon du processus d'empaquetage."
        exit 1
    fi
else
    echo "🧹 Nettoyage ignoré (--no-clean)"
fi

# Étape 2 : Compilation
echo "🔨 Compilation de l'application..."
./scripts/build.sh $BUILD_ARGS

# Vérifier si la compilation a réussi
if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la compilation. Abandon du processus d'empaquetage."
    exit 1
fi

# Étape 3 : Déploiement des bibliothèques Qt et dépendances (si activé)
if [ "$DO_DEPLOY" = true ]; then
    echo "📚 Déploiement des dépendances Qt..."
    
    # Détection de qmake pour trouver macdeployqt
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
    echo "ℹ️ Déploiement des bibliothèques en cours (cette opération peut prendre plusieurs minutes)..."
    echo "ℹ️ Le processus peut sembler bloqué lors de la copie des bibliothèques système, c'est normal."
    
    # Déploiement des bibliothèques avec moins de verbosité
    "$MACDEPLOYQT_PATH" Sp3ctraGen.app -qmldir=./qml -verbose=1
    
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
else
    echo "📚 Déploiement Qt ignoré (--no-deploy)"
fi

# Étape 4 : Création du DMG (si activé)
if [ "$DO_DMG" = true ]; then
    echo "📦 Création du DMG pour distribution..."
    ./scripts/create_dmg.sh
    
    # Vérifier si la création du DMG a réussi
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors de la création du DMG. Abandon du processus d'empaquetage."
        exit 1
    fi
    
    echo ""
    echo "✅ Processus d'empaquetage terminé avec succès !"
    echo "📦 Vous pouvez maintenant distribuer le fichier dist/Sp3ctraGen.dmg"
else
    echo "📦 Création du DMG ignorée (--no-dmg)"
    echo ""
    echo "✅ Processus d'empaquetage terminé avec succès !"
fi

echo ""
echo "💡 Options disponibles:"
echo "   ./scripts/package.sh --no-clean   # Ne pas nettoyer avant compilation"
echo "   ./scripts/package.sh --no-deploy  # Ne pas déployer les bibliothèques Qt"
echo "   ./scripts/package.sh --no-dmg     # Ne pas créer de DMG"
echo "   ./scripts/package.sh --help       # Affiche l'aide complète"
echo ""
if [ "$DO_DMG" = true ]; then
    echo "📝 Instructions pour les utilisateurs :"
    echo "   1. Monter le DMG"
    echo "   2. Glisser Sp3ctraGen.app dans le dossier Applications"
    echo "   3. Exécuter le script 'install_helper.command' pour désactiver la quarantaine"
    echo ""
fi