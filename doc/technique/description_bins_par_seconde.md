# Implémentation du paramètre Bins par seconde (Bins/s)

## Introduction

Cette documentation détaille l'implémentation du nouveau paramètre "Bins par seconde" (Bins/s) pour optimiser le paramétrage des spectrogrammes dans Sp3ctraGen. Cette modification fondamentale change la façon dont la FFT size est déterminée, permettant de lier directement la résolution temporelle à la taille du papier et à la vitesse d'écriture.

## Concept et motivation

### Problématique initiale

Dans la version précédente, le paramétrage du spectrogramme reposait sur trois valeurs indépendantes :
- FFT Size : taille de la fenêtre FFT en échantillons
- Overlap : taux de chevauchement entre deux fenêtres consécutives (0.0 - 1.0)
- Writing Speed : vitesse d'écriture en cm/s

Cette approche présentait plusieurs inconvénients :
- Corrélation complexe entre les paramètres et le résultat visuel
- Difficulté à estimer la densité temporelle du spectrogramme
- Absence de relation directe entre le format papier et la durée audio représentée

### Nouvelle approche avec Bins/s

Le paramètre "Bins par seconde" (Bins/s) correspond au nombre de colonnes de pixels par seconde d'audio. Il permet :
- Un contrôle direct sur la résolution temporelle du spectrogramme
- Une relation claire entre format papier et durée audio
- La détermination automatique de la FFT size optimale

## Implémentation technique

### Modifications des structures

Les structures de données ont été étendues avec deux nouveaux champs :
- `binsPerSecond` : nombre de bins par seconde (valeur par défaut : 150.0)
- `useAutoFftSize` : flag pour activer le calcul automatique de la FFT size (valeur par défaut : true)

### Formules mathématiques

Le calcul de la FFT size optimale repose sur les formules suivantes :

1. **Calcul du pas entre fenêtres (hop size)**
   ```
   hop_size = sample_rate / bins_per_second
   ```

2. **Calcul de la FFT size**
   ```
   fft_size = hop_size / (1 - overlap)
   ```
   Avec un overlap fixe de 0.85, la formule devient :
   ```
   fft_size = hop_size / 0.15
   ```

3. **Arrondi à la puissance de 2 supérieure**
   ```
   fft_size_power2 = next_power_of_2(fft_size)
   ```

### Exemple concret

Pour un fichier audio avec sample_rate = 48000 Hz et un paramètre bins/s = 150 :

1. Calcul du hop size : 
   ```
   hop_size = 48000 / 150 = 320 échantillons
   ```

2. Calcul de la FFT size :
   ```
   fft_size = 320 / 0.15 = 2133.33 échantillons
   ```

3. Arrondi à la puissance de 2 :
   ```
   fft_size_power2 = 4096 échantillons
   ```

### Impact sur la résolution fréquentielle

La résolution fréquentielle est inversement proportionnelle à la FFT size :
```
resolution_freq = sample_rate / fft_size
```

Avec la nouvelle approche, cette résolution est automatiquement optimisée en fonction du bins/s.

## Stratégie de migration pour les utilisateurs existants

### Compatibilité ascendante

L'implémentation maintient une compatibilité ascendante complète :
- Le paramètre `useAutoFftSize` est désactivable, permettant de revenir au comportement précédent
- Les anciens projets utilisant des FFT sizes fixes continuent à fonctionner

### Guide de migration

Pour les utilisateurs existants, voici comment adapter vos projets :

1. **Estimation du bins/s équivalent** :
   Si vous utilisiez précédemment une configuration avec :
   - FFT size = 8192
   - Overlap = 0.85
   - Sample rate = 48000 Hz

   Le bins/s équivalent serait :
   ```
   bins_per_second = sample_rate / (fft_size * (1 - overlap))
   bins_per_second = 48000 / (8192 * 0.15) ≈ 39 bins/s
   ```

2. **Ajustement du bins/s** :
   - Pour une résolution temporelle plus fine : augmentez le bins/s
   - Pour une résolution fréquentielle plus fine : diminuez le bins/s

### Valeurs recommandées

Recommandations pour différents types d'analyses :
- Analyse détaillée haute fréquence : 80-100 bins/s
- Équilibre général : 150 bins/s (valeur par défaut)
- Analyse longue durée : 200-250 bins/s

## Avantages de la nouvelle approche

### Simplification des paramètres

- Réduction du nombre de paramètres indépendants
- Création d'une relation directe entre vitesse d'écriture, format papier et durée audio
- Approche plus intuitive pour les nouveaux utilisateurs

### Optimisation automatique

- Calcul optimal de la FFT size en fonction du sample rate
- Équilibre automatique entre résolution temporelle et fréquentielle
- Adaptation automatique aux différents formats de papier

### Précision et reproductibilité

- Résultats plus prévisibles et reproductibles
- Meilleure correspondance entre paramètres visuels et résultat
- Standardisation des configurations pour différents projets

## Limites et considérations

- Le paramètre bins/s a un impact moins direct sur la résolution fréquentielle que la FFT size
- L'overlap est fixé à 0.85 pour garantir une qualité visuelle optimale
- Les valeurs extrêmes de bins/s peuvent générer des FFT sizes très grandes ou très petites

## Conclusion

L'implémentation du paramètre bins/s représente une évolution majeure dans l'approche de génération des spectrogrammes. Elle simplifie considérablement le processus de paramétrage tout en améliorant la prévisibilité et la qualité des résultats.

Cette approche orientée résultat permet aux utilisateurs de se concentrer sur les aspects visuels et analytiques du spectrogramme plutôt que sur les détails techniques de l'algorithme de traitement du signal.