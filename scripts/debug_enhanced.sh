#!/bin/bash

# Script pour déboguer l'application SpectroGen avec LLDB et configuration améliorée
# Mis à jour pour la nouvelle structure de dossiers

# Aller au répertoire racine du projet
cd "$(dirname "$0")/.." || exit 1

# Vérifier si l'exécutable existe
if [ ! -f "SpectroGen.app/Contents/MacOS/SpectroGen" ]; then
    echo "Erreur: L'exécutable n'existe pas."
    echo "Veuillez d'abord compiler le projet avec scripts/build.sh"
    exit 1
fi

# Définir les variables d'environnement nécessaires
export DYLD_LIBRARY_PATH="/opt/homebrew/opt/qt@5/lib:/opt/homebrew/opt/fftw/lib:/opt/homebrew/opt/cairo/lib:/opt/homebrew/opt/libsndfile/lib"
export QT_QPA_PLATFORM="cocoa"

# Créer un fichier temporaire avec les commandes LLDB
cat > /tmp/lldb_commands.txt << EOC
# Charger la configuration LLDB
command source .lldbinit

# Définir un point d'arrêt sur la fonction main
breakpoint set -n main

# Lancer le programme
process launch --stop-at-entry

# Afficher les informations sur les points d'arrêt
breakpoint list

# Afficher les informations sur les fichiers source
target modules dump symfile

# Continuer l'exécution jusqu'au premier point d'arrêt
continue
EOC

echo "Lancement du débogueur LLDB avec configuration améliorée..."
echo "Utilisez les commandes suivantes pour naviguer:"
echo "  n ou next       - Pas à pas principal (sans entrer dans les fonctions)"
echo "  s ou step       - Pas à pas détaillé (entre dans les fonctions)"
echo "  finish          - Sortir de la fonction actuelle"
echo "  c ou continue   - Continuer l'exécution jusqu'au prochain point d'arrêt"
echo "  bt              - Afficher la pile d'appels"
echo "  frame variable  - Afficher les variables locales"
echo "  q ou quit       - Quitter le débogueur"
echo ""
echo "Pour plus d'informations, consultez doc/dev/DEBUGGING.md"
echo ""

# Lancer LLDB avec le fichier de commandes
lldb -s /tmp/lldb_commands.txt SpectroGen.app/Contents/MacOS/SpectroGen

# Nettoyer le fichier temporaire
rm /tmp/lldb_commands.txt
