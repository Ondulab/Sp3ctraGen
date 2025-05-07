#!/bin/bash

# Script pour générer une configuration LLDB qui aide à localiser les fichiers source
# Mis à jour pour la nouvelle structure de dossiers

# Aller au répertoire racine du projet
cd "$(dirname "$0")/.." || exit 1

# Vérifier si l'exécutable existe
if [ ! -f "SpectroGen.app/Contents/MacOS/SpectroGen" ]; then
    echo "Erreur: L'exécutable n'existe pas."
    echo "Veuillez d'abord compiler le projet avec scripts/build.sh"
    exit 1
fi

# Créer un fichier de configuration LLDB
cat > .lldbinit << EOF
# Configuration LLDB pour SpectroGen

# Définir l'architecture cible
settings set target.process.target-architecture arm64

# Activer les points d'arrêt en ligne
settings set target.inline-breakpoint-strategy always

# Ajouter le répertoire source actuel à la liste des chemins de recherche
settings append target.source-map /Users/zhonx/Documents/Workspaces/Workspace_Xcode/CISYNTH_App/CISYNTH_Qt ${PWD}

# Ajouter le répertoire include à la liste des chemins de recherche
settings append target.source-map /Users/zhonx/Documents/Workspaces/Workspace_Xcode/CISYNTH_App/CISYNTH_Qt/include ${PWD}/include

# Ajouter le répertoire src à la liste des chemins de recherche
settings append target.source-map /Users/zhonx/Documents/Workspaces/Workspace_Xcode/CISYNTH_App/CISYNTH_Qt/src ${PWD}/src

# Activer la journalisation des symboles pour le débogage
settings set symbols.debug-info-format dwarf

# Activer la journalisation des événements de débogage
settings set target.process.thread.step-avoid-regexp ""

# Activer tous les points d'arrêt
breakpoint enable
EOF

echo "Configuration LLDB générée dans .lldbinit"
echo "Cette configuration aidera LLDB à localiser les fichiers source pendant le débogage."
echo ""
echo "Pour utiliser cette configuration:"
echo "1. Exécutez VSCode depuis le terminal dans ce répertoire:"
echo "   open -a 'Visual Studio Code' ."
echo ""
echo "2. Ou utilisez le script de débogage amélioré:"
echo "   scripts/debug_enhanced.sh"
echo ""

# Créer un script de débogage amélioré dans le dossier scripts/
cat > scripts/debug_enhanced.sh << EOF
#!/bin/bash

# Script pour déboguer l'application SpectroGen avec LLDB et configuration améliorée
# Mis à jour pour la nouvelle structure de dossiers

# Aller au répertoire racine du projet
cd "\$(dirname "\$0")/.." || exit 1

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
EOF

# Rendre le script exécutable
chmod +x scripts/debug_enhanced.sh

echo "Script de débogage amélioré généré: scripts/debug_enhanced.sh"
