#!/bin/bash

# Script de nettoyage pour Sp3ctraGen
# Ce script supprime tous les fichiers de build générés

# Aller au répertoire racine du projet
cd "$(dirname "$0")/.." || exit 1

echo "🧹 Nettoyage complet..."

# Supprimer le répertoire de build
if [ -d "build" ]; then
    echo "  📁 Suppression du répertoire build..."
    rm -rf build
fi

# Supprimer les objets compilés avec make clean
if [ -f "Makefile" ]; then
    echo "  🔧 Exécution de make clean..."
    make clean >/dev/null 2>&1
fi

# Supprimer les fichiers Makefile et autres générés par qmake
echo "  📄 Suppression des fichiers générés par qmake..."
rm -f Makefile *.o moc_*.cpp qrc_*.cpp ui_*.h .qmake.stash

# Supprimer l'application générée
if [ -d "Sp3ctraGen.app" ]; then
    echo "  🗑️ Suppression de l'application compilée (Sp3ctraGen.app)..."
    rm -rf Sp3ctraGen.app
fi

echo "✅ Nettoyage terminé"