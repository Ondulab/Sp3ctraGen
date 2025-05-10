# Traitement du signal et génération de spectrogrammes

## Introduction

Ce document détaille les algorithmes et processus utilisés dans SpectroGen pour le traitement du signal audio et la génération de spectrogrammes haute qualité. Une attention particulière est portée aux optimisations pour l'impression et la numérisation, ainsi qu'aux paramètres qui influencent la qualité du résultat final.

## Principes fondamentaux des spectrogrammes

Un spectrogramme est une représentation visuelle du spectre de fréquences d'un signal qui varie dans le temps. Il permet de visualiser comment l'énergie du signal est distribuée à différentes fréquences au cours du temps.

La génération d'un spectrogramme implique plusieurs étapes clés:

1. **Segmentation du signal** - Division du signal audio en segments courts (fenêtres)
2. **Fenêtrage** - Application d'une fonction de fenêtrage pour réduire les effets de bord
3. **Transformation de Fourier** - Conversion de chaque segment du domaine temporel au domaine fréquentiel
4. **Calcul de magnitude** - Calcul de l'amplitude pour chaque composante fréquentielle
5. **Conversion en décibels** - Conversion des magnitudes en échelle logarithmique (dB)
6. **Mappage de couleurs** - Conversion des valeurs en dB en intensités de pixels

## Paramètres clés et valeurs par défaut

SpectroGen utilise un ensemble de paramètres soigneusement optimisés pour produire des spectrogrammes de haute qualité:

| Paramètre | Valeur Par Défaut | Unité | Description |
|-----------|------------------|-------|-------------|
| fftSize | 8192 | échantillons | Taille de la fenêtre FFT - cruciale pour la résolution fréquentielle |
| overlap | 0.85 | ratio | Chevauchement des fenêtres FFT - affecte la résolution temporelle |
| minFreq | 65.0 | Hz | Fréquence minimale affichée |
| maxFreq | 16640.0 | Hz | Fréquence maximale affichée |
| sampleRate | 192000 | Hz | Taux d'échantillonnage - toujours 192kHz indépendamment du fichier source |
| dynamicRangeDB | 60.0 | dB | Plage dynamique représentée |
| gammaCorrection | 0.8 | - | Correction gamma pour le contraste |
| enableDithering | false | booléen | Activation du dithering |
| contrastFactor | 1.9 | - | Facteur de contraste |
| enableHighBoost | true | booléen | Activation de l'amplification des hautes fréquences |
| highBoostAlpha | 0.99 | - | Paramètre alpha pour l'amplification des hautes fréquences |
| pageFormat | 0 | - | Format de page (0=A4 portrait, 1=A3 paysage) |
| bottomMarginMM | 50.0 | mm | Marge inférieure |
| spectroHeightMM | 216.7 | mm | Hauteur du spectrogramme |
| writingSpeed | 8.0 | cm/s | Vitesse d'écriture |

Ces paramètres sont centralisés dans le fichier `SharedConstants.h` et accessibles via:
- Le namespace `Constants` en C++
- Le singleton `Constants` en QML
- Les macros directes en C

## Algorithmes de traitement du signal

### 1. Chargement et prétraitement des fichiers audio

#### 1.1 Chargement du fichier audio

Le chargement du fichier audio est géré par la fonction `load_wav_file()` dans `spectral_wav_processing.c`. Cette fonction utilise la bibliothèque libsndfile pour lire les fichiers WAV.

```c
int load_wav_file(const char *filename, double **signal, int *num_samples, int *sample_rate, double duration, int normalize)
{
    SNDFILE *sf;
    SF_INFO info;
    
    // Initialiser la structure info
    memset(&info, 0, sizeof(info));
    
    // Ouvrir le fichier son pour la lecture
    sf = sf_open(filename, SFM_READ, &info);
    if (sf == NULL) {
        fprintf(stderr, "Error: Could not open file %s: %s\n", filename, sf_strerror(NULL));
        return 1;
    }
    
    // Déterminer le nombre de frames à lire
    int frames_to_read = 0;
    if (duration > 0) {
        frames_to_read = (int)(duration * info.samplerate);
        if (frames_to_read > info.frames) {
            frames_to_read = info.frames;
        }
    } else {
        frames_to_read = info.frames;
    }
    
    // Allouer de la mémoire pour le signal
    *signal = (double *)malloc(frames_to_read * sizeof(double));
    
    // Lire les données audio
    if (info.channels > 1) {
        // Mixage des canaux en mono
        // ...
    } else {
        // Fichier mono, lecture directe
        *num_samples = sf_readf_double(sf, *signal, frames_to_read);
    }
    
    // Définir le taux d'échantillonnage
    *sample_rate = info.samplerate;
    
    // Fermer le fichier
    sf_close(sf);
    
    // Normaliser l'audio si demandé
    if (normalize) {
        // Normalisation à une amplitude maximale de 1.0
        // ...
    }
    
    return 0;
}
```

**Points clés:**
- SpectroGen charge toujours l'intégralité du fichier audio, indépendamment de la durée spécifiée
- Les fichiers multi-canaux sont mixés en mono en calculant la moyenne des canaux
- Le taux d'échantillonnage original du fichier est préservé à ce stade

#### 1.2 Normalisation audio

Si la normalisation est activée, le signal est normalisé à une amplitude maximale de 1.0:

```c
if (normalize) {
    double max_abs = 0.0;
    for (int i = 0; i < *num_samples; i++) {
        if (fabs((*signal)[i]) > max_abs) {
            max_abs = fabs((*signal)[i]);
        }
    }
    if (max_abs > 0.0) {
        for (int i = 0; i < *num_samples; i++) {
            (*signal)[i] /= max_abs;
        }
    }
}
```

Cette normalisation assure une utilisation optimale de la plage dynamique disponible.

#### 1.3 Amplification des hautes fréquences

Une caractéristique importante de SpectroGen est l'amplification des hautes fréquences, implémentée par la fonction `apply_high_freq_boost_filter()`:

```c
void apply_high_freq_boost_filter(double *signal, int num_samples, double alpha)
{
    if (num_samples < 2) return;
    
    double prev_sample = signal[0];
    for (int i = 1; i < num_samples; i++) {
        double current_sample = signal[i];
        signal[i] = current_sample - alpha * prev_sample;
        prev_sample = current_sample;
    }
}
```

**Explication détaillée:**
Cette fonction implémente un filtre "pre-emphasis" qui amplifie les hautes fréquences. L'équation utilisée est:

```
y[n] = x[n] - alpha * x[n-1]
```

où:
- `y[n]` est l'échantillon de sortie
- `x[n]` est l'échantillon d'entrée actuel
- `x[n-1]` est l'échantillon d'entrée précédent
- `alpha` est le coefficient de filtre (généralement 0.99)

Ce filtre simple mais efficace améliore la visibilité des hautes fréquences qui sont souvent difficiles à discerner dans les spectrogrammes. Il s'agit essentiellement d'un filtre passe-haut du premier ordre qui atténue les basses fréquences et amplifie les hautes fréquences.

La réponse en fréquence de ce filtre est:

```
H(f) = 1 - alpha * e^(-j2πf)
```

Pour `alpha = 0.99`, le filtre amplifie les fréquences au-dessus d'environ 1 kHz, avec une amplification maximale aux fréquences les plus élevées.

### 2. Analyse FFT et traitement spectral

#### 2.1 Initialisation de la FFT

L'initialisation de la FFT est gérée par la fonction `fft_init()` dans `spectral_fft.c`:

```c
int fft_init(int fft_size, int *fft_effective_size, fftw_plan *plan, double **in, fftw_complex **out)
{
    // Déterminer la taille effective de la FFT en fonction de l'option de zero-padding
    #if USE_ZERO_PADDING
        *fft_effective_size = ZERO_PAD_SIZE;
    #else
        *fft_effective_size = fft_size;
    #endif
    
    // Calculer le nombre de bins fréquentiels
    int num_bins = (*fft_effective_size) / 2 + 1;
    
    // Allouer le buffer d'entrée
    *in = (double *)fftw_malloc(sizeof(double) * (*fft_effective_size));
    
    // Allouer le buffer de sortie
    *out = (fftw_complex *)fftw_malloc(sizeof(fftw_complex) * num_bins);
    
    // Créer le plan FFT
    *plan = fftw_plan_dft_r2c_1d(*fft_effective_size, *in, *out, FFTW_ESTIMATE);
    
    return 0;
}
```

**Points clés:**
- SpectroGen utilise la bibliothèque FFTW3 pour les calculs de FFT
- Une extension à 65535 échantillons (zero-padding) est systématiquement appliquée pour améliorer la résolution fréquentielle
- Le nombre de bins fréquentiels est `fft_effective_size / 2 + 1` en raison de la symétrie du spectre pour les signaux réels

#### 2.2 Calcul du spectrogramme

Le calcul du spectrogramme est effectué par la fonction `compute_spectrogram()` dans `spectral_fft.c`:

```c
int compute_spectrogram(double *signal, int total_samples, int sample_rate,
                       int fft_size, double overlap, 
                       double min_freq, double max_freq,
                       SpectrogramData *spectro_data)
{
    // Initialiser la FFT
    int fft_effective_size;
    fftw_plan plan;
    double *in;
    fftw_complex *out;
    
    if (fft_init(fft_size, &fft_effective_size, &plan, &in, &out) != 0) {
        return 1;
    }
    
    // Calculer le pas en fonction du chevauchement
    int step = (int)(fft_size * (1.0 - overlap));
    if (step < 1) step = 1;
    
    // Calculer le nombre de fenêtres
    int num_windows = (total_samples - fft_size) / step + 1;
    
    // Calculer le nombre de bins fréquentiels
    int num_bins = fft_effective_size / 2 + 1;
    double freq_resolution = sample_rate / (double)fft_effective_size;
    
    // Allouer de la mémoire pour les données du spectrogramme
    double *spectrogram = (double *)malloc(num_windows * num_bins * sizeof(double));
    
    // Calculer les indices de bins fréquentiels à partir de la plage de fréquences spécifiée
    int index_min = (int)ceil(min_freq / freq_resolution);
    int index_max = (int)floor(max_freq / freq_resolution);
    
    // Calculer le spectrogramme
    for (int w = 0; w < num_windows; w++) {
        int start_index = w * step;
        
        // Copier le segment du signal dans le buffer d'entrée FFT avec zero-padding si nécessaire
        for (int i = 0; i < fft_size; i++) {
            if (start_index + i < total_samples) {
                in[i] = signal[start_index + i];
            } else {
                in[i] = 0.0;
            }
        }
        
        // Zero-padding du reste du buffer si nécessaire
        for (int i = fft_size; i < fft_effective_size; i++) {
            in[i] = 0.0;
        }
        
        // Appliquer la fonction de fenêtrage
        apply_hann_window(in, fft_size);
        
        // Exécuter la FFT
        fftw_execute(plan);
        
        // Calculer la magnitude pour chaque bin fréquentiel
        for (int b = 0; b < num_bins; b++) {
            double real = out[b][0];
            double imag = out[b][1];
            double magnitude = sqrt(real * real + imag * imag);
            
            spectrogram[w * num_bins + b] = magnitude;
        }
    }
    
    // Remplir la structure de données du spectrogramme
    spectro_data->data = spectrogram;
    spectro_data->num_windows = num_windows;
    spectro_data->num_bins = num_bins;
    spectro_data->index_min = index_min;
    spectro_data->index_max = index_max;
    
    // Nettoyer les ressources FFT
    fft_cleanup(plan, in, out);
    
    return 0;
}
```

**Explication détaillée du processus:**

1. **Segmentation du signal**: Le signal audio est divisé en segments courts (fenêtres) avec un chevauchement spécifié par le paramètre `overlap`. Le pas entre les fenêtres est calculé comme `step = fft_size * (1.0 - overlap)`.

2. **Fenêtrage**: Une fenêtre de Hann est appliquée à chaque segment pour réduire les effets de bord et les fuites spectrales:

```c
void apply_hann_window(double *buffer, int size)
{
    for (int i = 0; i < size; i++) {
        // Fenêtre de Hann: 0.5 * (1 - cos(2π * n / (N - 1)))
        double window = 0.5 * (1.0 - cos(2.0 * M_PI * i / (size - 1)));
        buffer[i] *= window;
    }
}
```

La fenêtre de Hann est définie par l'équation:
```
w(n) = 0.5 * (1 - cos(2π * n / (N - 1)))
```
où N est la taille de la fenêtre.

3. **Zero-padding**: Une extension à 65535 échantillons est appliquée pour améliorer la résolution fréquentielle. Cela consiste à ajouter des zéros à la fin du segment avant d'appliquer la FFT.

4. **Transformation de Fourier**: La FFT est appliquée à chaque segment fenêtré pour obtenir sa représentation fréquentielle.

5. **Calcul de magnitude**: Pour chaque bin fréquentiel, la magnitude est calculée à partir des parties réelle et imaginaire du résultat de la FFT:
```
magnitude = sqrt(real^2 + imag^2)
```

#### 2.3 Traitement de l'image du spectrogramme

Le traitement de l'image du spectrogramme est effectué par la fonction `apply_image_processing()` dans `spectral_fft.c`:

```c
void apply_image_processing(SpectrogramData *spectro_data, 
                           double dynamic_range_db, double gamma_correction,
                           int enable_dither, double contrast_factor)
{
    // Traiter chaque pixel du spectrogramme
    for (int w = 0; w < num_windows; w++) {
        for (int b = index_min; b <= index_max; b++) {
            double magnitude = spectrogram[w * num_bins + b];
            double intensity = 0.0;
            double epsilon = 1e-10; // Éviter le log de zéro
            
            // Appliquer l'échelle logarithmique d'amplitude si activée
            if (USE_LOG_AMPLITUDE) {
                double dB = 20.0 * log10(magnitude + epsilon);
                double max_dB = 20.0 * log10(global_max + epsilon);
                double min_dB = max_dB - dynamic_range_db;
                intensity = (dB - min_dB) / (max_dB - min_dB);
                
                // Limiter à [0, 1]
                if (intensity < 0.0) intensity = 0.0;
                if (intensity > 1.0) intensity = 1.0;
            } else {
                // Normalisation linéaire
                intensity = magnitude / global_max;
            }
            
            // Appliquer la correction gamma
            if (gamma_correction != 1.0) {
                intensity = pow(intensity, 1.0 / gamma_correction);
            }
            
            // Inverser l'intensité (1.0 = blanc, 0.0 = noir)
            double inverted_intensity = 1.0 - intensity;
            
            // Quantifier à la plage 0-255
            double quantized = inverted_intensity * 255.0;
            
            // Appliquer le dithering si activé
            if (enable_dither) {
                double dither = ((double)rand() / (double)RAND_MAX) - 0.5;
                quantized += dither;
            }
            
            // Limiter après dithering
            if (quantized < 0.0) quantized = 0.0;
            if (quantized > 255.0) quantized = 255.0;
            
            // Convertir à la plage 0-1
            double final_intensity = quantized / 255.0;
            
            // Appliquer l'amélioration de contraste
            final_intensity = (final_intensity - 0.5) * contrast_factor + 0.5;
            
            // Limiter final
            if (final_intensity < 0.0) final_intensity = 0.0;
            if (final_intensity > 1.0) final_intensity = 1.0;
            
            // Stocker la valeur traitée dans le spectrogramme
            spectrogram[w * num_bins + b] = final_intensity;
        }
    }
}
```

**Explication détaillée des étapes de traitement:**

1. **Conversion en dB**: Les magnitudes sont converties en décibels pour mieux représenter la perception humaine:
```
dB = 20 * log10(magnitude)
```
Cette conversion est essentielle car l'oreille humaine perçoit les intensités sonores de manière logarithmique.

2. **Normalisation**: Les valeurs en dB sont normalisées à la plage [0, 1] en fonction de la plage dynamique spécifiée:
```
intensity = (dB - min_dB) / (max_dB - min_dB)
```
où `min_dB = max_dB - dynamic_range_db`.

3. **Correction gamma**: Une correction gamma est appliquée pour ajuster la réponse non-linéaire de la perception visuelle:
```
intensity = pow(intensity, 1.0 / gamma_correction)
```
Une valeur de gamma inférieure à 1.0 (par exemple 0.8) éclaircit l'image globale et améliore la visibilité des détails de faible intensité.

4. **Inversion**: L'intensité est inversée pour produire un fond noir avec les signaux en blanc:
```
inverted_intensity = 1.0 - intensity
```
Cette inversion est optimale pour la lecture par scanner.

5. **Dithering**: Si activé, un bruit aléatoire subtil est ajouté pour réduire les artefacts de quantification:
```
dither = ((double)rand() / (double)RAND_MAX) - 0.5
quantized += dither
```
Le dithering peut améliorer la perception visuelle des transitions subtiles d'intensité.

6. **Amélioration du contraste**: Le facteur de contraste est appliqué pour améliorer la lisibilité:
```
final_intensity = (final_intensity - 0.5) * contrast_factor + 0.5
```
Une valeur de 1.9 donne un bon équilibre entre visibilité des détails et lisibilité globale.

## Génération des images de spectrogramme

SpectroGen supporte deux formats de sortie principaux: raster (PNG) et vectoriel (PDF). Chaque format est géré par une stratégie de visualisation spécifique.

### 1. Génération d'images raster (PNG)

La génération d'images raster est implémentée dans `spectral_raster.c` et utilise la bibliothèque Cairo pour créer des images PNG à 800 DPI.

**Points clés:**
- Résolution fixée à 800 DPI pour une qualité d'impression optimale
- Dimensions physiques précises basées sur le format de page (A4 portrait ou A3 paysage)
- Mappage logarithmique des fréquences pour une représentation perceptuellement correcte

### 2. Génération d'images vectorielles (PDF)

La génération d'images vectorielles est implémentée dans `spectral_vector.c` et utilise également Cairo pour créer des fichiers PDF vectoriels.

**Avantages du format vectoriel:**
- Mise à l'échelle sans perte de qualité
- Taille de fichier potentiellement plus petite
- Meilleure qualité d'impression à différentes résolutions

## Optimisations pour l'impression et la numérisation

Pour qu'un spectrogramme soit lisible par un scanner après impression, plusieurs optimisations sont implémentées:

### 1. Contraste élevé

Le contraste élevé est obtenu grâce à plusieurs mécanismes:
- Facteur de contraste de 1.9
- Correction gamma de 0.8
- Inversion des niveaux d'intensité (fond noir, signaux en blanc)

### 2. Maintien strict de l'échelle temporelle

SpectroGen maintient strictement l'échelle temporelle spécifiée (cm/s):

```c
// Si toutes les fenêtres ne peuvent pas tenir sur la page, on limite le nombre affiché
visible_duration_sec = page_width_cm / writingSpeed;
// Calculer combien de fenêtres correspondant à la durée visible
visible_windows = (int)(num_windows * (visible_duration_sec / audio_duration));
```

Cette approche garantit que les relations temporelles dans l'audio sont correctement préservées dans le spectrogramme.

### 3. Résolution minimale garantie

Le code assure une résolution minimale de 10 fenêtres par centimètre:

```c
int min_windows_per_cm = 10; // Minimum de fenêtres par cm pour une résolution acceptable
```

Cette densité minimale garantit que les détails temporels fins sont correctement représentés.

### 4. Dimensions physiques précises

Le système utilise des constantes de conversion précises pour maintenir les dimensions physiques correctes:

```c
#define PIXELS_TO_CM           0.00317   // 1 pixel = 0.00317 cm à 800 DPI
#define MM_TO_PIXELS           31.5      // 1 mm = 31.5 pixels à 800 DPI
```

Ces constantes assurent que les dimensions du spectrogramme imprimé correspondent exactement aux spécifications.

### 5. Filtrage des hautes fréquences

L'amplification des hautes fréquences est cruciale pour la numérisation car elle améliore la détection des composantes à haute fréquence qui pourraient être atténuées par le processus d'impression et de numérisation.

## Paramètres et leur impact

### 1. Taille de la FFT (fftSize)

La taille de la FFT détermine la résolution fréquentielle du spectrogramme:
- Une taille plus grande améliore la résolution fréquentielle mais réduit la résolution temporelle
- La valeur par défaut de 8192 offre un bon compromis

**Impact sur la résolution fréquentielle:**
```
résolution_fréquentielle = taux_échantillonnage / fft_size
```

Pour un taux d'échantillonnage de 192 kHz et une taille de FFT de 8192, la résolution fréquentielle est d'environ 23.4 Hz.

### 2. Chevauchement (overlap)

Le chevauchement détermine la résolution temporelle du spectrogramme:
- Une valeur plus élevée améliore la résolution temporelle mais augmente le temps de calcul
- La valeur par défaut de 0.85 (85%) offre une excellente résolution temporelle

**Impact sur la résolution temporelle:**
```
pas_temporel = (1 - overlap) * fft_size / taux_échantillonnage
```

Pour un taux d'échantillonnage de 192 kHz, une taille de FFT de 8192 et un chevauchement de 0.85, le pas temporel est d'environ 6.4 ms.

### 3. Plage de fréquences (minFreq, maxFreq)

La plage de fréquences détermine les fréquences affichées dans le spectrogramme:
- `minFreq` (65 Hz) correspond approximativement à la note Do1 sur un piano
- `maxFreq` (16640 Hz) couvre la majeure partie du spectre audible humain

### 4. Plage dynamique (dynamicRangeDB)

La plage dynamique détermine la différence entre les niveaux les plus forts et les plus faibles affichés:
- Une valeur plus élevée montre plus de détails dans les signaux faibles
- La valeur par défaut de 60 dB correspond à un rapport de 1:1000 en amplitude

### 5. Vitesse d'écriture (writingSpeed)

La vitesse d'écriture détermine l'échelle temporelle du spectrogramme:
- Exprimée en cm/s, elle définit combien de centimètres représentent une seconde d'audio
- La valeur par défaut de 8.0 cm/s offre un bon compromis entre détail et taille du spectrogramme

**Impact sur la durée visible:**
```
durée_visible = largeur_page_cm / vitesse_écriture
```

Pour une page A4 (21 cm de large) et une vitesse d'écriture de 8 cm/s, la durée visible est d'environ 2.6 secondes.

## Conclusion

Le système de génération de spectrogrammes de SpectroGen est basé sur des algorithmes de traitement du signal sophistiqués et des optimisations spécifiques pour l'impression et la numérisation. Les paramètres par défaut ont été soigneusement choisis pour offrir un équilibre optimal entre résolution fréquentielle, résolution temporelle et qualité visuelle.

Les principales caractéristiques qui distinguent SpectroGen sont:
1. Un taux d'échantillonnage élevé (192 kHz) pour une excellente résolution fréquentielle
2. Une taille FFT adaptée (8192) pour un bon compromis entre résolution temps-fréquence
3. Un zero-padding important (65535) pour améliorer la précision de l'analyse spectrale
4. Un chevauchement important (0.85) pour une bonne résolution temporelle
5. Une amplification correcte des hautes fréquences via un filtre pre-emphasis
6. Un calcul précis des dimensions physiques basé sur la vitesse d'écriture
7. Le maintien strict de l'échelle temporelle même si cela implique la troncature de l'audio
8. Un traitement optimisé du contraste pour la numérisation

Ces caractéristiques font de SpectroGen un outil puissant pour la génération de spectrogrammes de haute qualité adaptés à l'impression et à la numérisation.