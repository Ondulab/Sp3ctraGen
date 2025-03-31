#!/bin/bash

# Script pour exécuter l'application SpectroGen

# Vérifier si l'exécutable existe
if [ ! -f "SpectroGen.app/Contents/MacOS/SpectroGen" ]; then
    echo "Erreur: L'exécutable n'existe pas."
    echo "Veuillez d'abord compiler le projet avec ./build.sh"
    exit 1
fi

# Exécuter l'application
echo "Lancement de SpectroGen..."
open SpectroGen.app
