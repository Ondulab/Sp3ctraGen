# Guide d'utilisation du curseur de résolution

Ce guide explique comment utiliser efficacement le curseur de résolution dans Sp3ctraGen pour obtenir des spectrogrammes optimisés selon vos besoins d'analyse.

## Le curseur Temporel/Spectral

Le curseur de résolution est conçu pour vous permettre de contrôler intuitivement le compromis entre:
- **Résolution temporelle** : Précision dans le temps, détection des transitoires
- **Résolution fréquentielle** : Précision en fréquence, définition des harmoniques

## Choisir la bonne position

Le réglage optimal dépend du type de matériel audio et de ce que vous souhaitez observer:

### Position "Temporel" (gauche)

![Position Temporel](../images/resolution_temporel.png)

- **Caractéristiques** : Très réactif dans le temps, fenêtres FFT courtes, densité temporelle élevée
- **Idéal pour** :
  - Percussions, transitoires rapides
  - Détection précise des attaques
  - Analyse des clics, bruits impulsionnels
  - Son percussif avec beaucoup de détails temporels
- **Valeurs techniques typiques** :
  - FFT size: 512-1024 points
  - Bins/s: 1500-2400
  - Espacement temporel serré entre les fenêtres

### Position "Équilibrée" (centre)

![Position Équilibrée](../images/resolution_equilibree.png)

- **Caractéristiques** : Bon compromis entre précision temporelle et fréquentielle
- **Idéal pour** :
  - La plupart des signaux mixtes (voix, instruments)
  - Musique comportant à la fois des éléments rythmiques et harmoniques
  - Applications générales où ni le temporel ni le fréquentiel ne prédomine
- **Valeurs techniques typiques** :
  - FFT size: ~2048 points
  - Bins/s: ~1000
  - Résolution fréquentielle et temporelle équilibrées

### Position "Spectral" (droite)

![Position Spectral](../images/resolution_spectral.png)

- **Caractéristiques** : Haute précision fréquentielle, analyses stables sur de plus longues durées
- **Idéal pour** :
  - Sons tenus, notes soutenues
  - Analyse fine des harmoniques
  - Structures tonales complexes
  - Détection des composantes fréquentielles rapprochées
- **Valeurs techniques typiques** :
  - FFT size: 8192-16384 points
  - Bins/s: 200-400
  - Résolution fréquentielle très fine

## Conseils pratiques

1. **Commencez au centre** : La position équilibrée est un bon point de départ pour la plupart des signaux
2. **Adaptez selon le contenu** :
   - Déplacez vers la gauche pour des signaux percussifs ou avec beaucoup de transitoires
   - Déplacez vers la droite pour des sons tenus ou des analyses harmoniques fines
3. **Observez les valeurs techniques** : En bas du curseur, vous pouvez voir les valeurs calculées (FFT Size, Overlap, Bins/s) qui vous aident à comprendre l'effet de vos ajustements

## Interaction avec la vitesse d'écriture

La vitesse d'écriture (Writing Speed) détermine une limite physique de résolution. Si le message "Limité par la résolution horizontale d'impression" apparaît:

- Réduisez la vitesse d'écriture pour obtenir une meilleure résolution temporelle
- Ou acceptez la limitation si la vitesse d'écriture est une contrainte fixe de votre projet

## Adaptation automatique au taux d'échantillonnage

Un avantage majeur de ce nouveau système est son adaptation automatique au taux d'échantillonnage:

- Vous n'avez pas besoin d'ajuster le curseur différemment pour des fichiers 44.1kHz, 96kHz ou 192kHz
- Le système adapte automatiquement les paramètres pour maintenir un résultat perceptuellement cohérent
- La position du curseur conserve la même signification quelle que soit la source audio

Ce curseur de résolution unique simplifie grandement l'utilisation de Sp3ctraGen tout en offrant un contrôle précis sur la qualité du spectrogramme généré.
