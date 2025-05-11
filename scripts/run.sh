#!/bin/bash

# Script pour exécuter l'application Sp3ctraGen
# Mis à jour pour la nouvelle structure de dossiers

# Aller au répertoire racine du projet
cd "$(dirname "$0")/.." || exit 1

# Vérifier si l'exécutable existe
if [ ! -f "Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen" ]; then
    echo "Erreur: L'exécutable n'existe pas."
    echo "Veuillez d'abord compiler le projet avec scripts/build.sh"
    exit 1
fi

# Exécuter l'application
echo "Lancement de Sp3ctraGen..."
open Sp3ctraGen.app
