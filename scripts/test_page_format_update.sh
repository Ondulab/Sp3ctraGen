#!/bin/bash

# Script de test pour vérifier la fonctionnalité updatePageFormat

# Définir le chemin vers l'exécutable
APP_PATH="Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen"

# Vérifier que l'application est compilée
if [ ! -f "$APP_PATH" ]; then
    echo "❌ L'application n'est pas compilée. Veuillez exécuter ./scripts/build.sh d'abord."
    exit 1
fi

echo "🔍 Test de la correction de mise à jour du format de page..."
echo "📋 Test du script : scripts/test_page_format_update.sh"
echo "🕒 Date d'exécution : $(date)"
echo "-------------------------------------------"

# Tester le changement de format de page
echo "✅ Lancement de l'application avec la correction..."
echo "Veuillez vérifier dans l'application que :"
echo "1. Le passage du format A4 à A3 (et vice versa) dans la section 'Output Format' fonctionne correctement"
echo "2. La durée audio est mise à jour automatiquement"
echo "3. Aucune erreur 'TypeError: Property 'createSettings' is not a function' n'apparaît dans les logs"
echo ""
echo "💡 Si tout fonctionne correctement, la correction a réussi !"

# Lancer l'application avec les logs actifs
"$APP_PATH" 2>&1 | tee test_page_format_update.log

echo ""
echo "📄 Les logs ont été enregistrés dans test_page_format_update.log"
echo "-------------------------------------------"
