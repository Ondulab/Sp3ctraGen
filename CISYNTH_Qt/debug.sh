#!/bin/bash

# Script pour déboguer l'application SpectroGen avec LLDB

# Vérifier si l'exécutable existe
if [ ! -f "SpectroGen.app/Contents/MacOS/SpectroGen" ]; then
    echo "Erreur: L'exécutable n'existe pas."
    echo "Veuillez d'abord compiler le projet avec ./build.sh"
    exit 1
fi

# Définir les variables d'environnement nécessaires
export DYLD_LIBRARY_PATH="/opt/homebrew/opt/qt@5/lib:/opt/homebrew/opt/fftw/lib:/opt/homebrew/opt/cairo/lib:/opt/homebrew/opt/libsndfile/lib"
export QT_QPA_PLATFORM="cocoa"

# Créer un fichier temporaire avec les commandes LLDB
cat > /tmp/lldb_commands.txt << EOF
# Définir l'architecture cible
settings set target.process.target-architecture arm64

# Activer les points d'arrêt en ligne
settings set target.inline-breakpoint-strategy always

# Définir un point d'arrêt sur la fonction main
breakpoint set -n main

# Activer tous les points d'arrêt
breakpoint enable

# Lancer le programme
process launch --stop-at-entry

# Afficher les informations sur les points d'arrêt
breakpoint list

# Continuer l'exécution jusqu'au premier point d'arrêt
continue
EOF

echo "Lancement du débogueur LLDB..."
echo "Utilisez les commandes suivantes pour naviguer:"
echo "  n ou next       - Pas à pas principal (sans entrer dans les fonctions)"
echo "  s ou step       - Pas à pas détaillé (entre dans les fonctions)"
echo "  finish          - Sortir de la fonction actuelle"
echo "  c ou continue   - Continuer l'exécution jusqu'au prochain point d'arrêt"
echo "  bt              - Afficher la pile d'appels"
echo "  frame variable  - Afficher les variables locales"
echo "  q ou quit       - Quitter le débogueur"
echo ""
echo "Pour plus d'informations consultez DEBUGGING.md"
echo ""

# Lancer LLDB avec le fichier de commandes
lldb -s /tmp/lldb_commands.txt SpectroGen.app/Contents/MacOS/SpectroGen

# Nettoyer le fichier temporaire
rm /tmp/lldb_commands.txt
