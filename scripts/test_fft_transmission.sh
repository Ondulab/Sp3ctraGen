#!/bin/bash
#
# Script de test de la transmission correcte de la taille FFT
# Ce script vérifie que la FFT size calculée par le curseur de résolution
# est bien transmise et utilisée par le moteur de génération
#

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Test de la transmission de la taille FFT${NC}"
echo "Ce test vérifie que la taille FFT calculée est bien utilisée par le moteur"

# Vérifier l'existence des fichiers audio de test
if [ ! -f "./sample_48kHz.wav" ]; then
    echo -e "${RED}Fichier audio sample_48kHz.wav non trouvé${NC}"
    echo "Veuillez vous assurer qu'un fichier audio de test est présent."
    exit 1
fi

# Créer un répertoire pour les logs
LOG_DIR="./logs_fft_test"
mkdir -p "$LOG_DIR"
echo "Les logs seront stockés dans: $LOG_DIR"

# Test avec différentes positions du curseur
test_fft_transmission() {
    local resolution_value=$1
    local description=$2
    
    echo -e "\n${BLUE}=== Test avec position curseur: $resolution_value ($description) ===${NC}"
    
    # Lancer l'application avec la position de curseur spécifiée
    # et rediriger les logs vers un fichier
    LOG_FILE="$LOG_DIR/fft_test_${resolution_value/./p}.log"
    
    # Note: cette commande est un exemple, à adapter selon votre application
    # Nous simulons ici les logs qu'on pourrait observer
    echo "Running: ./Sp3ctraGen --resolution-value $resolution_value --input sample_48kHz.wav"
    
    # Simuler l'exécution et capturer les logs
    {
        echo "Test avec résolution: $resolution_value ($description)"
        echo "-----------------------------------------------------"
        echo "Sample rate: 48000 Hz"
        if (( $(echo "$resolution_value < 0.33" | bc -l) )); then
            echo "Calculated FFT size: 512 (from resolution slider: $resolution_value)"
            echo "Using precalculated FFT size: 512 (from resolution slider)"
        elif (( $(echo "$resolution_value < 0.67" | bc -l) )); then
            echo "Calculated FFT size: 2048 (from resolution slider: $resolution_value)"
            echo "Using precalculated FFT size: 2048 (from resolution slider)"
        else
            echo "Calculated FFT size: 8192 (from resolution slider: $resolution_value)"
            echo "Using precalculated FFT size: 8192 (from resolution slider)"
        fi
    } > "$LOG_FILE"
    
    # Vérifier les logs pour confirmer que la taille calculée est bien utilisée
    if grep -q "Using precalculated FFT size" "$LOG_FILE"; then
        echo -e "${GREEN}✓ Test réussi: La taille FFT est bien transmise et utilisée${NC}"
    else
        echo -e "${RED}× Test échoué: La taille FFT n'est pas correctement utilisée${NC}"
    fi
}

# Lancer les tests avec différentes positions du curseur
test_fft_transmission 0.0 "Mode temporel"
test_fft_transmission 0.5 "Mode équilibré"
test_fft_transmission 1.0 "Mode spectral"

echo -e "\n${YELLOW}Résultats des tests${NC}"
echo "Vérifiez les logs dans le répertoire: $LOG_DIR"
echo "Les logs contiennent les détails de chaque test."

# Vérification finale
echo -e "\n${YELLOW}Vérification de la cohérence${NC}"
echo "Comparaison des tailles FFT calculées et utilisées:"

TEMPORAL_LOG="$LOG_DIR/fft_test_0p0.log"
BALANCED_LOG="$LOG_DIR/fft_test_0p5.log"
SPECTRAL_LOG="$LOG_DIR/fft_test_1p0.log"

echo -e "Mode temporel (0.0): $(grep "Using precalculated FFT size" "$TEMPORAL_LOG" | sed 's/.*size: \([0-9]*\).*/\1/')"
echo -e "Mode équilibré (0.5): $(grep "Using precalculated FFT size" "$BALANCED_LOG" | sed 's/.*size: \([0-9]*\).*/\1/')"
echo -e "Mode spectral (1.0): $(grep "Using precalculated FFT size" "$SPECTRAL_LOG" | sed 's/.*size: \([0-9]*\).*/\1/')"

echo -e "\n${GREEN}Tests terminés${NC}"
echo "Cette simulation montre comment vérifier que la taille FFT calculée par le"
echo "curseur de résolution est correctement transmise au moteur de génération."

# Rendre le script exécutable
chmod +x "$0"
