#!/bin/bash

# Script pour exécuter l'application Sp3ctraGen avec contrôle des niveaux de log
# Utilisation: ./scripts/run.sh [--debug=NIVEAU] [--help]
#   NIVEAU 0: Aucun log (par défaut)
#   NIVEAU 1: Logs de l'application uniquement
#   NIVEAU 2: Logs de l'application + quelques logs Qt
#   NIVEAU 3: Tous les logs (application + Qt complet)

# Fonction d'affichage de l'aide
show_help() {
    echo "Utilisation: ./scripts/run.sh [OPTIONS]"
    echo "Options:"
    echo "  --debug=NIVEAU    Définit le niveau de débogage (0-3)"
    echo "      0: Aucun log (par défaut)"
    echo "      1: Logs de l'application uniquement"
    echo "      2: Logs de l'application + logs Qt limités"
    echo "      3: Tous les logs (application + Qt complet)"
    echo "  --help            Affiche ce message d'aide"
    exit 0
}

# Valeur par défaut du niveau de débogage
DEBUG_LEVEL=0

# Traitement des arguments
for arg in "$@"; do
    if [[ $arg == --debug=* ]]; then
        DEBUG_LEVEL="${arg#*=}"
        # Vérifier que c'est un nombre entre 0 et 3
        if ! [[ "$DEBUG_LEVEL" =~ ^[0-3]$ ]]; then
            echo "Erreur: Le niveau de débogage doit être entre 0 et 3"
            echo "Utilisez --help pour plus d'informations"
            exit 1
        fi
    elif [[ $arg == "--help" ]]; then
        show_help
    fi
done

# Aller au répertoire racine du projet
cd "$(dirname "$0")/.." || exit 1

# Vérifier si l'exécutable existe
if [ ! -f "Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen" ]; then
    echo "Erreur: L'exécutable n'existe pas."
    echo "Veuillez d'abord compiler le projet avec scripts/build.sh"
    exit 1
fi

# Définir les variables d'environnement nécessaires
export DYLD_LIBRARY_PATH="/opt/homebrew/opt/qt@5/lib:/opt/homebrew/opt/fftw/lib:/opt/homebrew/opt/cairo/lib:/opt/homebrew/opt/libsndfile/lib"
export QT_QPA_PLATFORM="cocoa"

# Configuration des niveaux de log Qt selon le niveau de débogage choisi
case $DEBUG_LEVEL in
    0)
        # Aucun log
        export QT_LOGGING_RULES="*.debug=false;qt.*=false"
        echo "Lancement de Sp3ctraGen sans logs (niveau 0)"
        ;;
    1)
        # Logs de l'application uniquement
        export QT_LOGGING_RULES="qt.*=false;default=true"
        echo "Lancement de Sp3ctraGen avec logs application uniquement (niveau 1)"
        ;;
    2)
        # Logs de l'application + logs Qt limités
        export QT_LOGGING_RULES="qt.*.debug=false;*.debug=true"
        echo "Lancement de Sp3ctraGen avec logs application + Qt limités (niveau 2)"
        ;;
    3)
        # Tous les logs (comportement d'origine)
        export QT_LOGGING_RULES="*.debug=true;qt.*.debug=true"
        echo "Lancement de Sp3ctraGen avec tous les logs - application + Qt complet (niveau 3)"
        ;;
    *)
        # Par sécurité, valeur par défaut: aucun log
        export QT_LOGGING_RULES="*.debug=false;qt.*=false"
        echo "Lancement de Sp3ctraGen sans logs (niveau par défaut)"
        ;;
esac

echo "Appuyez sur Ctrl+C pour arrêter l'application."
echo "-----------------------------------------------------"

# Exécuter directement l'application
./Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen