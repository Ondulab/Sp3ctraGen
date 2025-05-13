# Explication mathématique du paramètre Bins/s

## Fondements mathématiques

Le nouveau paramètre "Bins par seconde" (Bins/s) représente un changement fondamental dans l'approche du paramétrage des spectrogrammes. Ce document détaille les aspects mathématiques de cette implémentation.

## Relations mathématiques fondamentales

Dans tout spectrogramme, les relations suivantes existent :

### 1. Définitions de base

- **Sample Rate (SR)** : Nombre d'échantillons par seconde (Hz)
- **FFT Size (N)** : Nombre d'échantillons dans une fenêtre FFT
- **Overlap (O)** : Facteur de chevauchement entre fenêtres consécutives (0.0 - 1.0)
- **Hop Size (H)** : Nombre d'échantillons entre le début de deux fenêtres consécutives
- **Bins/s (B)** : Nombre de colonnes spectrales par seconde d'audio

### 2. Relations entre ces paramètres

La relation fondamentale entre le hop size et l'overlap est :
```
H = N * (1 - O)
```

Le nombre de bins par seconde est directement lié au hop size :
```
B = SR / H
```

En combinant ces deux équations, nous obtenons :
```
B = SR / (N * (1 - O))
```

### 3. Isolation de la FFT Size

En isolant N dans l'équation précédente :
```
N = SR / (B * (1 - O))
```

Avec un overlap fixe de 0.85, cette formule devient :
```
N = SR / (B * 0.15)
```

## Application pratique

### Exemple 1 : Sample Rate 48 kHz, Bins/s = 150

```
N = 48000 / (150 * 0.15) = 2133.33
```

Arrondi à la puissance de 2 supérieure : **N = 4096**

### Exemple 2 : Sample Rate 96 kHz, Bins/s = 150

```
N = 96000 / (150 * 0.15) = 4266.67
```

Arrondi à la puissance de 2 supérieure : **N = 8192**

### Exemple 3 : Sample Rate 192 kHz, Bins/s = 150

```
N = 192000 / (150 * 0.15) = 8533.33
```

Arrondi à la puissance de 2 supérieure : **N = 16384**

## Impact sur les résolutions temporelle et fréquentielle

### Résolution temporelle

La résolution temporelle est directement liée au hop size :
```
Δt = H / SR = 1 / B (secondes)
```

Donc pour Bins/s = 150 :
```
Δt = 1/150 = 0.0067 secondes = 6.7 ms
```

### Résolution fréquentielle

La résolution fréquentielle est inversement proportionnelle à la FFT size :
```
Δf = SR / N (Hz)
```

Par exemple, pour SR = 48000 Hz et N = 4096 :
```
Δf = 48000 / 4096 = 11.72 Hz
```

## Relations avec la vitesse d'écriture et le format papier

Avec le système Bins/s, les paramètres physiques déterminent directement la durée audio représentée :

```
Durée audio (s) = Largeur papier (cm) / Vitesse d'écriture (cm/s)
```

Pour un format A4 (21 cm de large) avec une vitesse de 2.5 cm/s :
```
Durée = 21 / 2.5 = 8.4 secondes
```

Le nombre total de bins dans ce spectrogramme sera :
```
Nombre de bins = Durée * Bins/s = 8.4 * 150 = 1260 bins
```

Avec une résolution d'impression de 800 DPI (31.5 pixels/mm), cela donne :
```
Espacement entre bins = (210 mm * 31.5 pixels/mm) / 1260 bins = 5.25 pixels/bin
```

## Nomogramme : Relations entre les paramètres

Pour visualiser les relations entre les différents paramètres, voici un tableau récapitulatif pour un sample rate de 48 kHz et un overlap de 0.85 :

| Bins/s | FFT Size | Hop Size | Résolution temporelle | Résolution fréquentielle |
|--------|----------|----------|----------------------|--------------------------|
| 50     | 8192     | 960      | 20.0 ms              | 5.86 Hz                  |
| 100    | 4096     | 480      | 10.0 ms              | 11.72 Hz                 |
| 150    | 4096     | 320      | 6.7 ms               | 11.72 Hz                 |
| 200    | 2048     | 240      | 5.0 ms               | 23.44 Hz                 |
| 250    | 2048     | 192      | 4.0 ms               | 23.44 Hz                 |
| 300    | 1024     | 160      | 3.3 ms               | 46.88 Hz                 |

## Exemples de configurations recommandées

### Configuration haute précision fréquentielle

- Sample rate : 192 kHz
- Bins/s : 100
- FFT Size résultante : 32768
- Résolution fréquentielle : 5.86 Hz
- Particulièrement adapté pour l'analyse détaillée de hautes fréquences

### Configuration équilibrée standard

- Sample rate : 48 kHz
- Bins/s : 150
- FFT Size résultante : 4096
- Résolution fréquentielle : 11.72 Hz
- Bon équilibre entre résolution temporelle et fréquentielle

### Configuration haute précision temporelle

- Sample rate : 48 kHz
- Bins/s : 300
- FFT Size résultante : 1024
- Résolution fréquentielle : 46.88 Hz
- Idéal pour l'analyse précise de transitoires et d'attaques

## Conclusion

Le paramètre Bins/s offre une approche plus intuitive et directe du paramétrage des spectrogrammes, en établissant une relation claire entre les paramètres physiques (format papier, vitesse d'écriture) et les paramètres de traitement du signal (FFT size, overlap).

Cette approche simplifie considérablement la configuration tout en maintenant un contrôle précis sur les résolutions temporelle et fréquentielle, permettant aux utilisateurs de se concentrer sur les aspects analytiques plutôt que sur les détails techniques de l'implémentation.