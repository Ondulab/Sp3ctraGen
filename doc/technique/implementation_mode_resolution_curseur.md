# Implémentation du mode de résolution avec curseur unique

Ce document détaille l'implémentation technique du nouveau mode de résolution adaptatif dans Sp3ctraGen, qui permet à l'utilisateur de contrôler le compromis entre résolution temporelle et résolution fréquentielle à l'aide d'un curseur unique.

## Principes fondamentaux

Le nouveau système repose sur les principes suivants :

1. **Curseur de résolution unique** : Remplace les paramètres techniques directs (FFT size, overlap) par un concept perceptuel "Temporel vs Spectral"
2. **Préservation stricte de la vitesse d'écriture** : La vitesse d'écriture (WS en cm/s) reste une contrainte physique non négociable
3. **Adaptation automatique au sample rate** : Les paramètres sont ajustés dynamiquement en fonction du taux d'échantillonnage
4. **Plafonnement par la résolution d'impression** : Respect de la limite maximale d'impression (800 DPI)

## Paramètres clés et leurs relations

### 1. Vitesse d'écriture (WS)

- Détermine la relation temporelle physique entre signal audio et papier (cm/s)
- Définit la limite maximale théorique de résolution horizontale (`maxBps`)
- Formule : `maxBps = ⌊(DPI / 2.54) × WS⌋` (où DPI = 800)

### 2. Position du curseur de résolution (0.0 à 1.0)

- Position 0.0 = "Temporel" : Fenêtres FFT courtes, haute densité temporelle
- Position 1.0 = "Spectral" : Fenêtres FFT longues, haute précision fréquentielle
- Utilisé pour calculer :
  - La densité de bins/seconde (pourcentage du maximum physique)
  - La taille de la FFT (fenêtre d'analyse)

### 3. Bins par seconde (bins/s)

- Représente la densité temporelle du spectrogramme
- Détermine le "hop size" (espacement entre fenêtres) : `hopSize = sampleRate / binsPerSecond`
- Calculé dynamiquement à partir du curseur et limité par `maxBps`

### 4. Taille FFT

- Détermine la résolution fréquentielle
- Position 0.0 (Temporel) : FFT courte (512-1024 points)
- Position 0.5 (Équilibré) : FFT moyenne (~2048 points)
- Position 1.0 (Spectral) : FFT longue (8192-16384 points)
- Ajustée automatiquement pour les sample rates élevés (>48kHz)

### 5. Overlap effectif

- Calculé comme conséquence de la taille FFT et du hop size
- Formule : `overlap = 1.0 - (hopSize / fftSize)`

## Mise en œuvre technique

### Dans SpectrogramParametersModel.cpp

```cpp
// 1. Calcul des bins/s d'après position du curseur
double calculateBpsFromSlider(double sliderValue) {
    // ...
    // Calcul du maximum physiquement imprimable
    double maxBps = calculateMaxBps(m_writingSpeed);
    
    if (sliderValue <= 0.5) {
        // De 0.0 à 0.5 (Temporel): haute densité temporelle
        bps = maxBps * (0.75 + 0.25 * (1.0 - sliderValue * 2.0));
    } else {
        // De 0.5 à 1.0 (Spectral): densité réduite
        bps = maxBps * (0.75 - 0.55 * ((sliderValue - 0.5) * 2.0));
    }
    // ...
}

// 2. Calcul de la taille FFT et de l'overlap effectif
void recalculateDerivedValues() {
    // ...
    // Calculer le hop size en échantillons
    double hopSize = static_cast<double>(m_sampleRate) / m_cachedBps;
    
    // Déterminer la taille FFT selon la position du curseur
    if (m_resolutionSliderValue <= 0.5) {
        // Position 0.0-0.5: petite FFT (512 à 2048)
        baseSize = 512.0 * std::pow(4.0, m_resolutionSliderValue * 2.0);
    } else {
        // Position 0.5-1.0: grande FFT (2048 à 16384)
        baseSize = 2048.0 * std::pow(8.0, (m_resolutionSliderValue - 0.5) * 2.0);
    }
    
    // Ajuster pour le taux d'échantillonnage
    if (m_sampleRate > 48000) {
        // Augmenter proportionnellement pour les taux élevés
        double scaleFactor = std::ceil(static_cast<double>(m_sampleRate) / 48000.0);
        // ...
    }
    
    // Calculer l'overlap effectif
    m_cachedOverlap = 1.0 - (hopSize / static_cast<double>(m_cachedFftSize));
    // ...
}
```

### Dans spectral_fft.c

Le code FFT a été modifié pour prendre en compte les nouveaux paramètres, avec une approche où step size (hop size) est directement dérivé du binsPerSecond sans utiliser de presets d'overlap fixes:

```c
// Calculer le step size basé sur bins_per_second
int step = (int)(sample_rate / bins_per_second);
// ...

// L'overlap effectif est maintenant une conséquence de la taille FFT et du step
double effective_overlap = 1.0 - ((double)step / fft_size);
```

## Interface utilisateur (QML)

L'interface a été améliorée pour communiquer clairement le compromis conceptuel:

- Labels "Temporel" et "Spectral" aux extrémités du curseur
- Description des caractéristiques de chaque mode
- Affichage des valeurs dérivées: bins/s, FFT size, overlap effectif

## Avantages du nouveau système

1. **Simplicité d'utilisation** : L'utilisateur contrôle un concept perceptuel, pas des paramètres techniques
2. **Cohérence des résultats** : Les spectrogrammes ont des caractéristiques prévisibles indépendamment du taux d'échantillonnage
3. **Optimisation pour l'impression** : Les résultats respectent les contraintes physiques d'impression
4. **Flexibilité** : Compromis résolution temporelle/fréquentielle ajustable selon l'application

## Valeurs attendues

| Position curseur | FFT size typique | bins/s typique | Caractéristiques visuelles |
|------------------|------------------|----------------|----------------------------|
| 0.0 (Temporel)   | 512 - 1024       | 75-100% du max | Transitoires nets, réactif |
| 0.5 (Équilibré)  | ~2048            | ~50% du max    | Bon compromis général      |
| 1.0 (Spectral)   | 8192 - 16384     | 20-40% du max  | Détail harmonique, stable  |

Cette implémentation garantit que l'utilisateur reste concentré sur l'effet recherché plutôt que sur des paramètres techniques, tout en respectant les contraintes physiques du support d'impression.
