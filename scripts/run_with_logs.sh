#!/bin/bash

# Script pour exécuter l'application Sp3ctraGen avec filtrage des logs
# Seules les traces de l'application seront affichées (sans les logs internes de Qt)

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

# Configuration des niveaux de log Qt
# Désactiver les logs internes de Qt, mais conserver les logs de l'application
export QT_LOGGING_RULES="qt.*=false;default=true"

echo "Lancement de Sp3ctraGen avec filtrage des logs..."
echo "Seuls les logs de l'application seront affichés"
echo "Appuyez sur Ctrl+C pour arrêter l'application."
echo "-----------------------------------------------------"

# Exécuter directement l'application
./Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen