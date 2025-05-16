#!/bin/bash
#
# Script de compilation de Sp3ctraGen avec les modifications du curseur de résolution
# 
# Ce script nettoie le projet, recompile, et exécute un test simple pour 
# vérifier le bon fonctionnement de l'implémentation du curseur de résolution

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Répertoire du projet
PROJECT_DIR="$(pwd)"
BUILD_DIR="${PROJECT_DIR}/build"

echo -e "${YELLOW}=== Compilation de Sp3ctraGen avec les modifications du curseur de résolution ===${NC}"
echo "Répertoire du projet: ${PROJECT_DIR}"

# 1. Nettoyage du projet
echo -e "\n${YELLOW}1. Nettoyage du projet${NC}"
if [ -f "./scripts/clean.sh" ]; then
    echo "Exécution du script de nettoyage..."
    ./scripts/clean.sh
    echo -e "${GREEN}Nettoyage terminé.${NC}"
else
    echo -e "${RED}Le script de nettoyage n'a pas été trouvé.${NC}"
    echo "Tentative de nettoyage manuel..."
    rm -rf "${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"
    echo -e "${GREEN}Nettoyage manuel terminé.${NC}"
fi

# 2. Compilation du projet
echo -e "\n${YELLOW}2. Compilation du projet${NC}"
if [ -f "./scripts/build.sh" ]; then
    echo "Exécution du script de compilation..."
    ./scripts/build.sh
    BUILD_RESULT=$?
    
    if [ $BUILD_RESULT -eq 0 ]; then
        echo -e "${GREEN}Compilation réussie.${NC}"
    else
        echo -e "${RED}Échec de la compilation. Code d'erreur: $BUILD_RESULT${NC}"
        exit 1
    fi
else
    echo -e "${RED}Le script de compilation n'a pas été trouvé.${NC}"
    echo "Tentative de compilation manuelle..."
    
    if [ -f "Sp3ctraGen.pro" ]; then
        qmake Sp3ctraGen.pro
        make -j4
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Compilation manuelle réussie.${NC}"
        else
            echo -e "${RED}Échec de la compilation manuelle.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Le fichier projet n'a pas été trouvé.${NC}"
        exit 1
    fi
fi

# 3. Vérification de l'exécutable
echo -e "\n${YELLOW}3. Vérification de l'exécutable${NC}"
if [ -f "./Sp3ctraGen" ] || [ -f "./build/Sp3ctraGen" ]; then
    echo -e "${GREEN}L'exécutable Sp3ctraGen a été créé avec succès.${NC}"
    
    # Trouver le chemin de l'exécutable
    if [ -f "./Sp3ctraGen" ]; then
        EXECUTABLE="./Sp3ctraGen"
    else
        EXECUTABLE="./build/Sp3ctraGen"
    fi
    
    echo "Exécutable trouvé: $EXECUTABLE"
else
    echo -e "${RED}L'exécutable Sp3ctraGen n'a pas été trouvé.${NC}"
    echo "Vérifiez les logs de compilation pour plus de détails."
    exit 1
fi

# 4. Suggestion pour les tests
echo -e "\n${YELLOW}4. Prochaines étapes${NC}"
echo -e "La compilation est terminée. Pour tester les modifications du curseur de résolution,"
echo -e "vous pouvez utiliser le script de test dédié:"
echo -e "${GREEN}./scripts/test_resolution_curseur.sh${NC}"
echo -e "ou lancer l'application directement:"
echo -e "${GREEN}$EXECUTABLE${NC}"
echo -e "\nPour comparer les résultats avec les précédentes versions, vous pouvez"
echo -e "consulter la documentation de référence dans les fichiers:"
echo -e "- doc/technique/implementation_mode_resolution_curseur.md"
echo -e "- doc/technique/adaptation_dynamique_au_sample_rate.md"
echo -e "- doc/guide_utilisateur/utilisation_curseur_resolution.md"

# Rendre le script exécutable
chmod +x "$0"

echo -e "\n${GREEN}Script terminé.${NC}"
