#!/bin/bash

# Script de configuration pour CISYNTH_Qt sur macOS
# Ce script installe les dépendances nécessaires et configure l'environnement

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Configuration de l'environnement pour CISYNTH_Qt ===${NC}"

# Vérifier si Homebrew est installé
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew n'est pas installé. Installation...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Échec de l'installation de Homebrew. Veuillez l'installer manuellement.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Homebrew est déjà installé.${NC}"
fi

# Mettre à jour Homebrew
echo -e "${YELLOW}Mise à jour de Homebrew...${NC}"
brew update

# Installer Qt 5
echo -e "${YELLOW}Installation de Qt 5...${NC}"
if brew list qt@5 &>/dev/null; then
    echo -e "${GREEN}Qt 5 est déjà installé.${NC}"
else
    brew install qt@5
    if [ $? -ne 0 ]; then
        echo -e "${RED}Échec de l'installation de Qt 5.${NC}"
        exit 1
    fi
fi

# Installer les bibliothèques de traitement du signal et d'image
echo -e "${YELLOW}Installation des bibliothèques FFTW, Cairo et libsndfile...${NC}"
for pkg in fftw cairo libsndfile; do
    if brew list $pkg &>/dev/null; then
        echo -e "${GREEN}$pkg est déjà installé.${NC}"
    else
        brew install $pkg
        if [ $? -ne 0 ]; then
            echo -e "${RED}Échec de l'installation de $pkg.${NC}"
            exit 1
        fi
    fi
done

# Installer bear (optionnel)
echo -e "${YELLOW}Installation de bear (pour compile_commands.json)...${NC}"
if brew list bear &>/dev/null; then
    echo -e "${GREEN}bear est déjà installé.${NC}"
else
    brew install bear
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Échec de l'installation de bear. Ce n'est pas critique.${NC}"
    fi
fi

# Vérifier les outils de ligne de commande Xcode
echo -e "${YELLOW}Vérification des outils de ligne de commande Xcode...${NC}"
if ! xcode-select -p &>/dev/null; then
    echo -e "${RED}Les outils de ligne de commande Xcode ne sont pas installés. Installation...${NC}"
    xcode-select --install
    echo -e "${YELLOW}Veuillez terminer l'installation des outils de ligne de commande Xcode puis relancer ce script.${NC}"
    exit 1
else
    echo -e "${GREEN}Les outils de ligne de commande Xcode sont installés.${NC}"
fi

# Configurer les variables d'environnement
echo -e "${YELLOW}Configuration des variables d'environnement...${NC}"

# Trouver le chemin de Qt
QT_PATH=""
POSSIBLE_PATHS=(
    "/usr/local/opt/qt@5"
    "/usr/local/opt/qt5"
    "/usr/local/opt/qt"
    "/opt/homebrew/opt/qt@5"
    "/opt/homebrew/opt/qt5"
    "/opt/homebrew/opt/qt"
)

# Chercher qmake dans les chemins possibles
QMAKE_PATH=""
for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -f "$path/bin/qmake" ]; then
        QT_PATH="$path"
        QMAKE_PATH="$path/bin/qmake"
        echo -e "${GREEN}Qt trouvé à: $QT_PATH${NC}"
        break
    fi
done

# Si qmake n'est pas trouvé dans les chemins prédéfinis, chercher dans le PATH
if [ -z "$QMAKE_PATH" ]; then
    QMAKE_PATH=$(which qmake)
    if [ -n "$QMAKE_PATH" ]; then
        QT_PATH=$(dirname $(dirname $QMAKE_PATH))
        echo -e "${GREEN}Qt trouvé à: $QT_PATH${NC}"
    else
        echo -e "${RED}qmake non trouvé. Veuillez installer Qt 5 et vous assurer que qmake est dans votre PATH.${NC}"
        echo -e "${YELLOW}Vous pouvez installer Qt 5 avec: brew install qt@5${NC}"
        echo -e "${YELLOW}Puis ajouter au PATH: echo 'export PATH=\"/usr/local/opt/qt@5/bin:\$PATH\"' >> ~/.zshrc${NC}"
        exit 1
    fi
fi

# Ajouter Qt au PATH si ce n'est pas déjà fait
if [[ ":$PATH:" != *":$QT_PATH/bin:"* ]]; then
    echo -e "${YELLOW}Ajout de Qt au PATH...${NC}"
    echo 'export PATH="'$QT_PATH'/bin:$PATH"' >> ~/.zshrc
    echo 'export PATH="'$QT_PATH'/bin:$PATH"' >> ~/.bash_profile
    echo -e "${GREEN}Qt a été ajouté au PATH. Veuillez redémarrer votre terminal ou exécuter 'source ~/.zshrc' ou 'source ~/.bash_profile'.${NC}"
else
    echo -e "${GREEN}Qt est déjà dans le PATH.${NC}"
fi

# Générer le projet
echo -e "${YELLOW}Génération du projet avec qmake: $QMAKE_PATH${NC}"
$QMAKE_PATH -spec macx-clang CONFIG+=debug CONFIG+=qml_debug

if [ $? -ne 0 ]; then
    echo -e "${RED}Échec de la génération du projet avec qmake.${NC}"
    exit 1
else
    echo -e "${GREEN}Projet généré avec succès.${NC}"
fi

echo -e "${GREEN}=== Configuration terminée ===${NC}"
echo -e "${YELLOW}Vous pouvez maintenant compiler le projet avec 'make' ou en utilisant VSCode.${NC}"
echo -e "${YELLOW}Pour ouvrir le projet dans VSCode, exécutez 'code .' dans ce répertoire.${NC}"
