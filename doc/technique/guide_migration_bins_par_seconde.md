# Guide de migration vers le système Bins/s

## Introduction

Ce guide vous accompagne dans la transition vers le nouveau système de paramétrage basé sur les Bins par seconde (Bins/s). Cette mise à jour majeure change fondamentalement la façon dont les spectrogrammes sont configurés, en simplifiant le processus et en améliorant la cohérence des résultats.

## Qu'est-ce qui change ?

### Avant : Paramétrage manuel de la FFT size

Dans les versions précédentes, vous deviez spécifier manuellement :
- La FFT size (par ex. 8192 échantillons)
- Le taux de chevauchement (overlap, par ex. 0.85)
- La vitesse d'écriture (writing speed, par ex. 2.5 cm/s)

Ces paramètres interagissaient de façon complexe et ne permettaient pas d'estimer facilement la densité temporelle du spectrogramme.

### Maintenant : Paramétrage par Bins/s

Avec la nouvelle approche :
- Vous spécifiez le nombre de bins (colonnes) par seconde d'audio
- La FFT size est calculée automatiquement en fonction de ce paramètre
- L'overlap est fixé à 0.85 pour une qualité optimale
- La vitesse d'écriture et le format papier déterminent directement la durée audio

## Comment migrer vos projets existants

### Étape 1 : Calculer le Bins/s équivalent

Si vous utilisiez une configuration stable, vous pouvez calculer le bins/s équivalent :

```
bins_per_second = sample_rate / (fft_size * (1 - overlap))
```

Exemple :
- Sample rate = 48000 Hz
- FFT size = 8192
- Overlap = 0.85

Calcul :
```
bins_per_second = 48000 / (8192 * 0.15) ≈ 39 bins/s
```

### Étape 2 : Activer le mode automatique

Dans l'interface utilisateur :
1. Activez l'option "Calcul auto FFT Size"
2. Entrez la valeur Bins/s calculée (ou ajustez-la selon vos préférences)

### Étape 3 : Ajuster pour des résultats équivalents

Pour obtenir des résultats visuellement similaires à vos spectrogrammes précédents :

1. Générez un spectrogramme test avec le bins/s calculé
2. Comparez avec vos résultats précédents
3. Ajustez le bins/s si nécessaire :
   - Augmentez pour une résolution temporelle plus fine
   - Diminuez pour une résolution fréquentielle plus fine

## Tableau de conversion

Pour faciliter la migration, voici un tableau de correspondance approximative pour différentes configurations courantes :

| Sample Rate | FFT Size | Overlap | Bins/s équivalent | Description |
|-------------|----------|---------|-------------------|-------------|
| 48000 Hz    | 4096     | 0.85    | 78                | Standard    |
| 48000 Hz    | 8192     | 0.85    | 39                | Haute résolution |
| 48000 Hz    | 16384    | 0.85    | 20                | Ultra-haute résolution |
| 48000 Hz    | 2048     | 0.85    | 156               | Basse résolution |
| 96000 Hz    | 8192     | 0.85    | 78                | Standard haute fréquence |
| 192000 Hz   | 16384    | 0.85    | 78                | Standard très haute fréquence |

## Mode compatibilité

Si vous préférez continuer à utiliser l'ancien système de paramétrage :

1. Désactivez l'option "Calcul auto FFT Size"
2. Entrez manuellement la FFT size comme auparavant

Tous vos projets existants continueront à fonctionner exactement comme avant.

## Avantages de la migration

### Simplification du processus

- Réduction des paramètres à gérer
- Relation plus intuitive entre les paramètres et le résultat
- Meilleure prévisibilité des résultats

### Optimisation automatique

- Calcul optimal de la FFT size en fonction du sample rate
- Adaptation automatique aux différents formats de papier
- Équilibre automatique entre résolution temporelle et fréquentielle

### Standardisation des configurations

- Configurations plus facilement partageables entre projets
- Référence commune pour discuter des paramètres (ex: "j'utilise 150 bins/s")
- Reproductibilité accrue des résultats

## Exemples pratiques

### Exemple 1 : Analyse détaillée haute fréquence

Configuration recommandée :
- Bins/s : 80-100
- Format : A4 portrait
- Writing speed : 2.5 cm/s

Résultat : Spectrogramme détaillé avec bonne résolution fréquentielle pour les hautes fréquences.

### Exemple 2 : Équilibre général

Configuration recommandée :
- Bins/s : 150 (valeur par défaut)
- Format : A4 portrait
- Writing speed : 2.5 cm/s

Résultat : Bon équilibre entre résolution temporelle et fréquentielle.

### Exemple 3 : Analyse longue durée

Configuration recommandée :
- Bins/s : 200-250
- Format : A3 landscape
- Writing speed : 3.5 cm/s

Résultat : Spectrogramme couvrant une longue durée avec résolution temporelle accrue.

## Conclusion

La transition vers le système Bins/s simplifie considérablement le paramétrage des spectrogrammes tout en améliorant la cohérence et la prévisibilité des résultats. Bien que le changement demande une adaptation initiale, les avantages à long terme en valent largement la peine.

N'hésitez pas à expérimenter avec différentes valeurs de Bins/s pour trouver les configurations qui conviennent le mieux à vos besoins spécifiques d'analyse.