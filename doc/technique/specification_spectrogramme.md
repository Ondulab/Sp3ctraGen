# Spécification du Générateur de Spectrogramme pour la Version QT

## 1. Introduction

À partir de l'analyse approfondie du code existant, ce document détaille le fonctionnement exact du générateur de spectrogramme de la version QT de SpectroGen, en mettant l'accent sur les paramètres par défaut, les processus de traitement du signal et les optimisations pour l'impression et la lecture par scanner.

## 2. Architecture du Système de Génération de Spectrogramme

L'architecture du système comprend plusieurs composants organisés en trois couches distinctes:

### 2.1. Vue d'ensemble des couches

1. **Interface utilisateur** (QML)
   - Interface principale (`main.qml`, `minimal_main.qml`)
   - Composants réutilisables (`AnimatedButton.qml`, `ValidatedTextField.qml`)
   - Constantes exposées via `QmlConstants`

2. **Logique métier** (C++)
   - `SpectrogramGenerator` (classe C++ intermédiaire)
   - Stratégies de visualisation (`VisualizationStrategy`, `RasterVisualizationStrategy`, `VectorVisualizationStrategy`)
   - Gestionnaires (`FileManager`, `PathManager`, `TaskManager`)

3. **Moteur de traitement** (C)
   - `spectral_generator.c` (moteur principal)
   - `spectral_fft.c` (traitement FFT)
   - `spectral_raster.c` et `spectral_vector.c` (génération d'images)
   - Bibliothèques: FFTW3 (FFT), libsndfile (lecture audio), Cairo (rendu graphique)

### 2.2. Patterns de conception utilisés

- **Pattern Strategy**: Utilisé pour encapsuler différentes implémentations de génération de spectrogrammes (raster, vectoriel)
- **Pattern Template Method**: Utilisé dans la classe `VisualizationStrategy` pour définir le squelette de l'algorithme de génération
- **Pattern Singleton**: Utilisé pour les classes utilitaires comme `QmlConstants` et `PathManager`

L'interaction entre ces composants permet une séparation claire entre l'interface utilisateur, la logique de traitement intermédiaire et le moteur de traitement du signal, facilitant la maintenance et l'extension du système.

## 3. Paramètres par Défaut et Valeurs Clés

D'après l'analyse du code, les valeurs par défaut optimales dans la version QT sont:

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

Ces constantes sont maintenant centralisées dans le fichier `SharedConstants.h` et accessibles via:
- Le namespace `Constants` en C++
- Le singleton `Constants` en QML
- Les macros directes en C

## 4. Processus de Génération du Spectrogramme

### 4.1 Préparation des Données Audio

1. **Échantillonnage Constant**: Toutes les données audio sont traitées à 192kHz, quelle que soit la fréquence d'échantillonnage originale. Cette valeur élevée permet une meilleure résolution fréquentielle.

2. **Chargement Complet du Fichier**: Le code charge toujours l'intégralité du fichier audio, indépendamment de la durée spécifiée:
   ```c
   // Modification importante: Charger tout le fichier indépendamment de la durée passée
   // int total_frames = (int)(duration * (*sample_rate));
   int total_frames = sfinfo.frames; // Toujours charger l'intégralité du fichier
   ```
   Cette approche garantit que toutes les données audio sont disponibles pour le traitement, même si une partie seulement sera visible dans le spectrogramme final.

3. **Amplification des Hautes Fréquences**: Un filtre passe-haut est appliqué lorsque `enableHighBoost=true`, implémenté comme:
   ```c
   void apply_high_freq_boost_filter(double *signal, int num_samples, double alpha) {
       if (num_samples < 2) return;
       double prev_sample = signal[0];
       for (int i = 1; i < num_samples; i++) {
           double current_sample = signal[i];
           signal[i] = current_sample - alpha * prev_sample;
           prev_sample = current_sample;
       }
   }
   ```
   Ce filtre simple mais efficace (techniquement un filtre "pre-emphasis") améliore la visibilité des hautes fréquences qui sont souvent difficiles à discerner, en utilisant la formule `y[n] = x[n] - alpha * x[n-1]` où `alpha` est généralement fixé à 0.99.

4. **Normalisation Audio**: Le signal est normalisé à une amplitude maximale de 1.0 pour assurer une utilisation optimale de la plage dynamique:
   ```c
   double max_abs = 0.0;
   for (int i = 0; i < total_frames; i++) {
       if (fabs((*signal)[i]) > max_abs) {
           max_abs = fabs((*signal)[i]);
       }
   }
   if (max_abs > 0.0) {
       for (int i = 0; i < total_frames; i++) {
           (*signal)[i] /= max_abs;
       }
   }
   ```

### 4.2 Analyse FFT et Traitement Spectral

1. **Fenêtrage**: Une fenêtre de Hann est appliquée aux segments de données pour réduire les fuites spectrales:
   ```c
   void apply_hann_window(double *buffer, int size) {
       for (int i = 0; i < size; i++) {
           buffer[i] *= 0.5 * (1.0 - cos(2.0 * M_PI * i / (size - 1)));
       }
   }
   ```
   Ce fenêtrage est crucial pour éviter les artefacts dans l'analyse spectrale.

2. **Zero-Padding**: Une extension à 65535 échantillons est systématiquement appliquée pour améliorer la résolution fréquentielle:
   ```c
   #define USE_ZERO_PADDING 1
   #define ZERO_PAD_SIZE 65535
   ```
   Cette technique multiplie significativement la résolution de la FFT, ce qui est particulièrement important pour l'analyse des basses fréquences.

3. **FFT**: Transformée de Fourier rapide avec la bibliothèque FFTW3:
   ```c
   fftw_plan plan = fftw_plan_dft_r2c_1d(fft_effective_size, in_zp, out_zp, FFTW_ESTIMATE);
   ```
   L'utilisation de FFTW3 assure des performances optimales pour ce calcul intensif.

4. **Calcul de Magnitude**: La magnitude est calculée pour chaque bin fréquentiel:
   ```c
   double real = out_zp[b][0];
   double imag = out_zp[b][1];
   double magnitude = sqrt(real * real + imag * imag);
   ```
   Cette magnitude représente l'amplitude du signal à chaque fréquence.

5. **Conversion en dB**: Les magnitudes sont converties en décibels pour mieux représenter la perception humaine:
   ```c
   double dB = 20.0 * log10(magnitude + epsilon);
   double max_dB = 20.0 * log10(global_max + epsilon);
   double min_dB = max_dB - DYNAMIC_RANGE_DB;
   intensity = (dB - min_dB) / (max_dB - min_dB);
   ```
   L'échelle logarithmique correspond mieux à la perception humaine des intensités sonores.

6. **Calcul du Pas et Nombre de Fenêtres**: Un aspect important récemment amélioré est le calcul du pas entre les fenêtres FFT en fonction de la vitesse d'écriture:
   ```c
   // Calculer le pas (step) basé sur le chevauchement demandé
   step = (int)(fft_size * (1.0 - overlap));
   if (step < 1) step = 1;
   
   // Calculer le nombre de fenêtres
   num_windows = (total_samples - fft_size) / step + 1;
   ```
   Le code comporte également une logique pour assurer une résolution suffisante (minimum de fenêtres par centimètre):
   ```c
   int min_windows_per_cm = 10; // Minimum de fenêtres par cm pour une résolution acceptable
   int min_windows = (int)(spectrogram_width_cm * min_windows_per_cm);
   
   if (num_windows < min_windows) {
       // Recalculer le pas pour avoir au moins min_windows fenêtres
       step = (total_samples - fft_size) / min_windows;
       if (step < 1) step = 1;
       
       // Recalculer le nombre de fenêtres avec le nouveau pas
       num_windows = (total_samples - fft_size) / step + 1;
       
       // Calculer le nouveau chevauchement correspondant
       double new_overlap = 1.0 - (step / (double)fft_size);
   }
   ```

### 4.3 Traitement du Contraste et Colorisation

1. **Correction Gamma**: Appliquée avec la formule:
   ```c
   intensity = pow(intensity, 1.0 / gammaCorr);
   ```
   Cette correction permet d'ajuster la réponse non-linéaire de la perception visuelle.

2. **Amélioration du Contraste**: Le facteur de contraste est appliqué:
   ```c
   final_intensity = (final_intensity - 0.5) * contrastFactor + 0.5;
   ```
   La valeur par défaut de 1.9 donne un bon équilibre entre visibilité des détails et lisibilité globale.

3. **Inversion**: L'inversion des niveaux est effectuée pour un spectrogramme optimal pour scanner:
   ```c
   double inverted_intensity = 1.0 - intensity;
   ```
   Cette inversion produit un fond noir avec les signaux en blanc, ce qui est idéal pour la lecture par scanner.

4. **Dithering**: Si activé, un bruit aléatoire subtil est ajouté pour réduire les artefacts de quantification:
   ```c
   if (enableDither) {
       double dither = ((double)rand() / (double)RAND_MAX) - 0.5;
       quantized += dither;
   }
   ```
   Le dithering peut améliorer la perception visuelle des transitions subtiles d'intensité.

### 4.4 Gestion de la Durée et des Dimensions Physiques

Une des améliorations majeures est le calcul dynamique de la durée audio affichée en fonction de la vitesse d'écriture:

1. **Calcul de la Durée Basé sur la Vitesse d'Écriture**:
   ```c
   if (writingSpeed > 0.0) {
       // Sélection du format de page pour calculer la largeur
       double pageWidth = (s.pageFormat == 1) ? A3_WIDTH : A4_WIDTH;
       
       // Convertir la largeur de pixels à cm
       double pageWidthCM = pageWidth * PIXELS_TO_CM;
       
       // Calculer la durée: durée (s) = largeur (cm) / vitesse (cm/s)
       duration = pageWidthCM / writingSpeed;
   }
   ```
   Cette approche garantit que l'échelle temporelle (cm/s) est maintenue exactement comme spécifié.

2. **Troncature Stricte**: Une fonctionnalité importante est la troncature stricte du spectrogramme à la largeur de la page, sans modification de l'échelle:
   ```c
   if (spectrogram_width_pixels > page_width) {
       // Si ça dépasse, on tronque strictement ce qui dépasse de la page
       double visible_duration = page_width_cm / writingSpeed;
       
       // On limite la taille à la largeur de la page mais on maintient strictement l'échelle cm/s
       printf(" - Only first %.2f seconds will be shown (of total %.2f seconds)\n", 
              visible_duration, audio_duration);
   }
   ```
   Cette décision de conception assure que l'échelle spatiale du spectrogramme reste exactement celle spécifiée, même si cela signifie qu'une partie de l'audio n'est pas représentée visuellement.

3. **Calcul Précis des Dimensions en Pixels et Centimètres**:
   ```c
   // A4 portrait: 210mm x 297mm → 2480 x 3508 pixels à 300 DPI
   // A3 paysage: 420mm x 297mm → 4961 x 3508 pixels à 300 DPI
   #define A4_WIDTH               2480.0
   #define A4_HEIGHT              3508.0
   #define A3_WIDTH               4961.0
   #define A3_HEIGHT              3508.0
   #define MM_TO_PIXELS           11.81   // Conversion mm en pixels à 300 DPI (300/25.4)
   ```
   Les constantes de conversion assurent une correspondance précise entre les dimensions physiques et numériques.

### 4.5 Rendu de l'Image

1. **Mappage Logarithmique des Fréquences**: Le code implémente une échelle logarithmique pour la représentation des fréquences:
   ```c
   if (USE_LOG_FREQUENCY) {
       double freq = b * freq_resolution;
       double freq_next = (b + 1) * freq_resolution;
       double log_min = log(DEFAULT_MIN_FREQ);
       double log_max = log(DEFAULT_MAX_FREQ);
       double y_current = (base_height - bottom_margin) - ((log(freq) - log_min) / (log_max - log_min)) * effective_height;
       double y_next = (base_height - bottom_margin) - ((log(freq_next) - log_min) / (log_max - log_min)) * effective_height;
   }
   ```
   Cette représentation logarithmique des fréquences est essentielle pour une représentation perceptuellement correcte.

2. **Résolution**: La résolution est fixée à 800 DPI, une valeur qui offre un bon compromis entre qualité d'image et taille de fichier:
   ```c
   // Définitions de formats de page (en pixels à 800 DPI)
   #define A4_WIDTH               6615.0  // 210mm à 800 DPI
   ```
   Cette résolution est suffisante pour l'impression de haute qualité et la numérisation.

3. **Gestion des Marges et Hauteur du Spectrogramme**: Le code permet de spécifier précisément les marges et la hauteur du spectrogramme en millimètres:
   ```c
   double bottom_margin = DEFAULT_DBL(s.bottomMarginMM * MM_TO_PIXELS, DEFAULT_BOTTOM_MARGIN);
   double spectro_height = DEFAULT_DBL(s.spectroHeightMM * MM_TO_PIXELS, DEFAULT_SPECTRO_HEIGHT);
   ```
   Les valeurs par défaut de 50mm pour la marge inférieure et 216.7mm pour la hauteur du spectrogramme sont optimisées pour le rendu sur une page A4.

## 5. Optimisations pour l'Impression et la Numérisation

Pour qu'un spectrogramme soit lisible par un scanner après impression, les caractéristiques essentielles implémentées sont:

1. **Contraste Élevé**: L'implémentation réalise un contraste élevé grâce à plusieurs mécanismes:
   - Facteur de contraste de 1.9
   - Correction gamma de 0.8
   - Inversion des niveaux d'intensité

2. **Maintien Strict de l'Échelle Temporelle**: Le code maintient strictement l'échelle temporelle spécifiée (cm/s):
   ```c
   // Si toutes les fenêtres ne peuvent pas tenir sur la page, on limite le nombre affiché
   visible_duration_sec = page_width_cm / writingSpeed;
   // Calculer combien de fenêtres correspondant à la durée visible
   visible_windows = (int)(num_windows * (visible_duration_sec / audio_duration));
   ```
   Cette approche garantit que les relations temporelles dans l'audio sont correctement préservées dans le spectrogramme.

3. **Résolution Minimale Garantie**: Le code assure une résolution minimale de 10 fenêtres par centimètre:
   ```c
   int min_windows_per_cm = 10; // Minimum de fenêtres par cm pour une résolution acceptable
   ```
   Cette densité minimale garantit que les détails temporels fins sont correctement représentés.

4. **Dimensions Physiques Précises**: Le système utilise des constantes de conversion précises pour maintenir les dimensions physiques correctes:
   ```c
   #define PIXELS_TO_CM           0.00317   // 1 pixel = 0.00317 cm à 800 DPI
   #define MM_TO_PIXELS           31.5      // 1 mm = 31.5 pixels à 800 DPI
   ```
   Ces constantes assurent que les dimensions du spectrogramme imprimé correspondent exactement aux spécifications.

5. **Filtrage des Hautes Fréquences**: L'amplification des hautes fréquences est cruciale pour la numérisation car elle améliore la détection des composantes à haute fréquence qui pourraient être atténuées par le processus d'impression et de numérisation.

## 6. Stratégies de Visualisation

Le système utilise le pattern Strategy pour encapsuler différentes implémentations de génération de spectrogrammes:

1. **Stratégie Raster (PNG)**:
   - Utilise Cairo pour générer des images PNG à 800 DPI
   - Optimisée pour l'impression et la numérisation
   - Supporte les formats A4 portrait et A3 paysage

2. **Stratégie Vectorielle (PDF)**:
   - Génère des fichiers PDF vectoriels
   - Permet une mise à l'échelle sans perte de qualité
   - Supporte différentes résolutions (DPI)

Ces stratégies partagent une interface commune définie dans la classe abstraite `VisualizationStrategy`, ce qui permet d'ajouter facilement de nouveaux formats de sortie sans modifier le code existant.

## 7. Contraintes Importantes pour la Version JUCE

Pour assurer une compatibilité parfaite avec la version QT, la version JUCE doit:

1. **Respecter les paramètres par défaut**: Utiliser strictement les mêmes valeurs par défaut pour tous les paramètres tels que définis dans la section 3.

2. **Maintenir le taux d'échantillonnage élevé**: Toujours traiter à 192kHz, indépendamment du fichier source.

3. **Implémenter le zero-padding**: Utiliser la même taille de 65535 échantillons pour le zero-padding.

4. **Gestion correcte de la vitesse d'écriture**: Implémenter le même modèle de calcul de la durée visible en fonction de la vitesse d'écriture:
   ```
   durée (s) = largeur_page (cm) / vitesse_écriture (cm/s)
   ```

5. **Troncature stricte**: Maintenir l'approche de troncature stricte lorsque le contenu audio dépasse la largeur de la page, sans modification de l'échelle.

6. **Calcul identique des dimensions physiques**: Respecter les mêmes calculs de dimensions basés sur la vitesse d'écriture et les formats de page.

7. **Gestion identique des marges et hauteurs**: Implémenter le même traitement des paramètres de marge inférieure et hauteur du spectrogramme exprimés en millimètres.

8. **Chargement complet du fichier audio**: Charger toujours l'intégralité du fichier audio indépendamment de la durée qui sera effectivement visible.

## 8. Conclusion

La génération d'un spectrogramme optimal pour l'impression et la lecture par scanner repose sur plusieurs éléments clés implémentés dans le code existant:

1. Un taux d'échantillonnage élevé (192kHz) pour une excellente résolution fréquentielle
2. Une taille FFT adaptée (8192) pour un bon compromis entre résolution temps-fréquence
3. Un zero-padding important (65535) pour améliorer la précision de l'analyse spectrale
4. Un chevauchement important (0.85) pour une bonne résolution temporelle
5. Une amplification correcte des hautes fréquences via un filtre pre-emphasis
6. Un calcul précis des dimensions physiques basé sur la vitesse d'écriture
7. Le maintien strict de l'échelle temporelle même si cela implique la troncature de l'audio
8. Un traitement optimisé du contraste pour la numérisation

Ces paramètres et méthodes de traitement constituent la base pour obtenir un spectrogramme de qualité compatible avec les besoins d'impression et de numérisation. La version JUCE devra respecter scrupuleusement ces spécifications pour garantir la compatibilité avec la version QT existante.

## 9. Améliorations Apportées par la Refactorisation

La refactorisation du projet a apporté plusieurs améliorations significatives:

1. **Centralisation des constantes**: Toutes les constantes sont maintenant définies dans un seul endroit (`SharedConstants.h`), éliminant la duplication et les incohérences potentielles.

2. **Architecture modulaire**: L'utilisation du pattern Strategy permet d'ajouter facilement de nouveaux formats de sortie sans modifier le code existant.

3. **Composants réutilisables**: Les composants QML réutilisables (`AnimatedButton`, `ValidatedTextField`) améliorent la cohérence de l'interface utilisateur et réduisent la duplication de code.

4. **Gestion améliorée des chemins**: La classe `PathManager` élimine les chemins codés en dur et fournit une gestion cohérente des chemins de fichiers.

5. **Documentation améliorée**: La documentation a été mise à jour pour refléter l'architecture actuelle et fournir des guides pour les développeurs.

Ces améliorations rendent le code plus robuste, plus maintenable et plus facile à étendre avec de nouvelles fonctionnalités à l'avenir.