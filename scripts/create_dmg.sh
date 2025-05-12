#!/bin/bash

# Script de création de DMG pour Sp3ctraGen
# Ce script crée un DMG contenant :
# - L'application Sp3ctraGen.app
# - Un lien vers /Applications
# - Un script d'aide pour désactiver la quarantaine

# Aller au répertoire racine du projet
cd "$(dirname "$0")/.." || exit 1

# Configuration
APP_NAME="Sp3ctraGen"
DMG_NAME="${APP_NAME}.dmg"
TMP_DMG="tmp_${DMG_NAME}"
VOLUME_NAME="${APP_NAME} Installer"
DMG_DIR="dist"

# Vérifier si l'application existe
if [ ! -d "${APP_NAME}.app" ]; then
    echo "❌ Erreur: ${APP_NAME}.app n'existe pas."
    echo "   Veuillez d'abord compiler l'application avec ./scripts/build.sh"
    exit 1
fi

# Créer le répertoire dist s'il n'existe pas
mkdir -p "${DMG_DIR}"

# Créer un répertoire temporaire pour les fichiers de support
TMP_DIR="${DMG_DIR}/tmp_support_files"
mkdir -p "${TMP_DIR}"

# Supprimer uniquement le DMG temporaire s'il existe
# et le DMG du même nom s'il existe déjà
rm -f "${DMG_DIR}/${TMP_DMG}"
# Ne pas supprimer le DMG existant s'il a été créé pour une sauvegarde
# rm -f "${DMG_DIR}/${DMG_NAME}"

# Créer un script d'aide pour désactiver la quarantaine
cat > "${TMP_DIR}/install_helper.command" << 'EOF'
#!/bin/bash

# Helper script pour Sp3ctraGen
# Ce script désactive la quarantaine pour l'application

# Obtenir le chemin du script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Vérifier si Sp3ctraGen est déjà dans /Applications
if [ -d "/Applications/Sp3ctraGen.app" ]; then
    echo "✅ Désactivation de la quarantaine..."
    sudo xattr -d com.apple.quarantine /Applications/Sp3ctraGen.app
    echo "✅ Sp3ctraGen est prêt à être utilisé !"
    echo "   Vous pouvez maintenant lancer l'application depuis le dossier Applications."
else
    echo "❌ Sp3ctraGen.app n'est pas installé dans le dossier Applications."
    echo "   Veuillez d'abord faire glisser l'application dans le dossier Applications."
fi

echo ""
echo "Appuyez sur une touche pour fermer cette fenêtre..."
read -n 1 -s
EOF

# Rendre le script exécutable
chmod +x "${TMP_DIR}/install_helper.command"

# Créer un fichier README
cat > "${TMP_DIR}/LISEZMOI.txt" << 'EOF'
Installation de Sp3ctraGen
==========================

1. Faites glisser Sp3ctraGen.app dans le dossier Applications
2. Double-cliquez sur "install_helper.command" pour désactiver la sécurité
3. Entrez votre mot de passe lorsqu'il est demandé
4. L'application est prête à être utilisée !

En cas de problème, ouvrez Terminal et exécutez :
sudo xattr -d com.apple.quarantine /Applications/Sp3ctraGen.app

Information technique : macOS ajoute un attribut de "quarantaine" aux applications 
téléchargées depuis Internet, ce qui bloque leur exécution si elles ne sont pas signées. 
Le script supprime simplement cet attribut.
EOF

echo "📦 Création d'un DMG temporaire..."
hdiutil create -size 150m -fs HFS+ -volname "${VOLUME_NAME}" "${DMG_DIR}/${TMP_DMG}"

echo "📁 Montage du DMG..."
hdiutil attach "${DMG_DIR}/${TMP_DMG}"

echo "📋 Copie des fichiers..."
cp -R "${APP_NAME}.app" "/Volumes/${VOLUME_NAME}/"
cp "${TMP_DIR}/install_helper.command" "/Volumes/${VOLUME_NAME}/"
cp "${TMP_DIR}/LISEZMOI.txt" "/Volumes/${VOLUME_NAME}/"

echo "🔗 Création du lien vers Applications..."
ln -s /Applications "/Volumes/${VOLUME_NAME}/Applications"

# Définir le fond et la disposition des icônes (optionnel - fonctionnalité avancée)
# Cette partie nécessite AppleScript ou des outils supplémentaires

echo "💿 Démontage du DMG..."
hdiutil detach "/Volumes/${VOLUME_NAME}"

echo "🔄 Conversion en DMG final..."
hdiutil convert "${DMG_DIR}/${TMP_DMG}" -format UDZO -o "${DMG_DIR}/${DMG_NAME}"

echo "🧹 Nettoyage..."
rm "${DMG_DIR}/${TMP_DMG}"
rm -rf "${TMP_DIR}"

echo "✅ DMG créé avec succès : ${DMG_DIR}/${DMG_NAME}"
echo "   Il contient :"
echo "   - Sp3ctraGen.app"
echo "   - Un lien vers /Applications"
echo "   - Un script d'aide pour désactiver la quarantaine"
echo "   - Un fichier LISEZMOI.txt avec les instructions"