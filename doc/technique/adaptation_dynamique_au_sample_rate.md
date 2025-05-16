# Adaptation dynamique au taux d'échantillonnage

Ce document explique comment le nouveau système de résolution adaptatif s'ajuste automatiquement aux différents taux d'échantillonnage pour garantir une cohérence visuelle optimale.

## Problématique

Dans les systèmes traditionnels de génération de spectrogrammes, la taille de la FFT (Fast Fourier Transform) est généralement fixée indépendamment du taux d'échantillonnage, ce qui entraîne plusieurs problèmes:

1. **Inconsistance visuelle** : Un même réglage produit des résultats visuellement différents selon le taux d'échantillonnage
2. **Complexité pour l'utilisateur** : Obligation d'ajuster manuellement les paramètres selon le fichier audio
3. **Résolution fréquentielle incohérente** : La précision fréquentielle varie selon le taux d'échantillonnage

## Solution implémentée

Le nouveau système de résolution adaptative prend en compte automatiquement le taux d'échantillonnage pour garantir une cohérence visuelle et analytique:

### 1. Adaptation proportionnelle de la taille FFT

```cpp
// Dans SpectrogramParametersModel::recalculateDerivedValues()
if (m_sampleRate > 48000) {
    // Augmenter proportionnellement pour les taux élevés
    double scaleFactor = std::ceil(static_cast<double>(m_sampleRate) / 48000.0);
    powerOf2 = static_cast<int>(powerOf2 * scaleFactor);
    
    // S'assurer que c'est toujours une puissance de 2
    int newPowerOf2 = 1;
    while (newPowerOf2 < powerOf2) {
        newPowerOf2 *= 2;
    }
    powerOf2 = newPowerOf2;
}
```

Cette approche:
1. Prend comme référence le taux d'échantillonnage de 48 kHz
2. Pour les taux supérieurs, augmente la taille FFT proportionnellement
3. Garantit que la taille FFT reste une puissance de 2 (optimale pour les algorithmes FFT)

### 2. Préservation du hop size relatif

```cpp
// Calcul du step (hop size) en échantillons
double hopSize = static_cast<double>(m_sampleRate) / m_cachedBps;
```

En déterminant le hop size directement à partir du taux d'échantillonnage et de la densité bins/s:
- La résolution temporelle reste constante (en termes de bins par seconde)
- L'espacement entre fenêtres s'adapte naturellement au taux d'échantillonnage

### 3. Ajustement de l'overlap effectif

```cpp
// Calcul de l'overlap effectif
m_cachedOverlap = 1.0 - (hopSize / static_cast<double>(m_cachedFftSize));
```

L'overlap effectif devient une conséquence des autres paramètres, assurant:
- Une transition fluide entre fenêtres d'analyse
- Une densité temporelle cohérente quelle que soit la taille FFT

## Résultats pratiques

Cette adaptation dynamique garantit que:

1. Un fichier à 48 kHz et un fichier à 96 kHz analysés avec les mêmes paramètres de résolution produiront des spectrogrammes avec:
   - Une densité temporelle identique (même nombre de bins par seconde)
   - Une résolution fréquentielle proportionnellement adaptée
   - Un compromis temporel/spectral perceptuellement équivalent

2. Les valeurs typiques attendues selon le taux d'échantillonnage:

| Sample Rate | Position Temporel (0.0) | Position Équilibrée (0.5) | Position Spectral (1.0) |
|-------------|-------------------------|---------------------------|-------------------------|
| 44.1/48 kHz | FFT: 512-1024           | FFT: ~2048                | FFT: 8192-16384         |
| 96 kHz      | FFT: 1024-2048          | FFT: ~4096                | FFT: 16384-32768        |
| 192 kHz     | FFT: 2048-4096          | FFT: ~8192                | FFT: 32768-65536        |

## Avantages pour l'utilisateur

Cette adaptation automatique offre plusieurs avantages:

1. **Transparence** : L'utilisateur n'a pas besoin de comprendre ou d'ajuster des paramètres techniques
2. **Cohérence** : Le résultat visuel est prévisible indépendamment du taux d'échantillonnage
3. **Optimisation** : La qualité d'analyse est automatiquement optimisée pour chaque fichier
4. **Simplicité** : Un seul curseur contrôle le compromis temporel/spectral, quelle que soit la source audio

L'adaptation dynamique au taux d'échantillonnage est donc un élément clé du nouveau système de résolution adaptative, permettant une expérience utilisateur simplifiée tout en garantissant des résultats optimaux dans toutes les conditions.
