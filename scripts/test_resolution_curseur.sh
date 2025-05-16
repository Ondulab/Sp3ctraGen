#!/bin/bash
#
# Script de test de la nouvelle implémentation du curseur de résolution
# Ce script génère plusieurs spectrogrammes avec différents réglages du curseur
# pour vérifier le bon fonctionnement de l'implémentation.

# Vérification de la présence du binaire
if [ ! -f "./Sp3ctraGen" ]; then
    echo "Erreur: Binaire Sp3ctraGen non trouvé. Veuillez d'abord compiler l'application."
    exit 1
fi

# Vérification de la présence des fichiers de test
if [ ! -f "./sample_48kHz.wav" ] || [ ! -f "./sample_96kHz.wav" ]; then
    echo "Erreur: Fichiers audio de test non trouvés."
    echo "Veuillez vous assurer que sample_48kHz.wav et sample_96kHz.wav sont présents."
    exit 1
fi

# Création du répertoire de sortie
TEST_DIR="./test_resolution_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEST_DIR"
echo "Résultats des tests sauvegardés dans: $TEST_DIR"

# Paramètres communs pour tous les tests
MIN_FREQ=20
MAX_FREQ=20000
WRITING_SPEED=2.5

# Fonction pour générer un spectrogramme avec un réglage spécifique du curseur
generate_spectrogram() {
    local input_file=$1
    local resolution_value=$2
    local output_suffix=$3
    local sample_rate=$(soxi -r "$input_file" 2>/dev/null || echo "Unknown")
    
    # Nom du fichier de sortie basé sur les paramètres
    local output_file="${TEST_DIR}/spectrogram_${output_suffix}_res${resolution_value/./}_${sample_rate}Hz.pdf"
    
    echo "Génération: $output_file (Résolution: $resolution_value, Fichier: $(basename "$input_file"))"
    
    # Commande CLI pour générer le spectrogramme
    # Note: Ceci est une simulation, il faudrait implémenter une CLI appropriée
    # pour Sp3ctraGen qui accepte ces paramètres
    
    # Placeholder pour la commande CLI réelle
    echo ./Sp3ctraGen \
        --input "$input_file" \
        --output "$output_file" \
        --min-freq $MIN_FREQ \
        --max-freq $MAX_FREQ \
        --writing-speed $WRITING_SPEED \
        --resolution-value $resolution_value
        
    # Décommenter cette ligne quand la CLI sera prête
    # ./Sp3ctraGen \
    #    --input "$input_file" \
    #    --output "$output_file" \
    #    --min-freq $MIN_FREQ \
    #    --max-freq $MAX_FREQ \
    #    --writing-speed $WRITING_SPEED \
    #    --resolution-value $resolution_value
}

# Tests avec différentes valeurs du curseur de résolution
# pour chaque fichier de test

echo "=== Démarrage des tests avec le fichier 48kHz ==="
# Valeur 0.0 (Temporel)
generate_spectrogram "./sample_48kHz.wav" 0.0 "temporal_48k"
# Valeur 0.5 (Équilibré)
generate_spectrogram "./sample_48kHz.wav" 0.5 "balanced_48k"
# Valeur 1.0 (Spectral)
generate_spectrogram "./sample_48kHz.wav" 1.0 "spectral_48k"

echo -e "\n=== Démarrage des tests avec le fichier 96kHz ==="
# Valeur 0.0 (Temporel)
generate_spectrogram "./sample_96kHz.wav" 0.0 "temporal_96k"
# Valeur 0.5 (Équilibré)
generate_spectrogram "./sample_96kHz.wav" 0.5 "balanced_96k"
# Valeur 1.0 (Spectral)
generate_spectrogram "./sample_96kHz.wav" 1.0 "spectral_96k"

# Créer un fichier de rapport
REPORT_FILE="${TEST_DIR}/test_report.txt"
{
    echo "=== Rapport de test du curseur de résolution ==="
    echo "Date: $(date)"
    echo "Vitesse d'écriture: $WRITING_SPEED cm/s"
    echo -e "\nParamètres techniques calculés (à remplir manuellement après analyse):"
    echo -e "\n| Fichier     | Résolution | FFT Size | Bins/s | Overlap | Aspect visuel |"
    echo   "| ----------- | ---------- | -------- | ------ | ------- | ------------- |"
    echo   "| 48kHz       | 0.0        |          |        |         |               |"
    echo   "| 48kHz       | 0.5        |          |        |         |               |"
    echo   "| 48kHz       | 1.0        |          |        |         |               |"
    echo   "| 96kHz       | 0.0        |          |        |         |               |"
    echo   "| 96kHz       | 0.5        |          |        |         |               |"
    echo   "| 96kHz       | 1.0        |          |        |         |               |"
    echo -e "\nObservations et conclusions:\n"
    echo "1. "
    echo "2. "
    echo "3. "
} > "$REPORT_FILE"

echo -e "\nTests terminés. Un rapport a été créé dans $REPORT_FILE"
echo "Veuillez remplir manuellement les valeurs techniques observées et vos conclusions."
echo "Pour visualiser les spectrogrammes, ouvrez les fichiers PDF générés dans $TEST_DIR"

# Rendre le script exécutable
chmod +x "$0"
