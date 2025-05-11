# Spécification des Fonctionnalités d'Output Format pour Sp3ctraGen

## 1. Introduction

Ce document détaille les spécifications techniques pour l'implémentation de nouvelles fonctionnalités dans la section Output Format de Sp3ctraGen. Ces fonctionnalités visent à améliorer la lisibilité et l'utilité des spectrogrammes générés, en particulier pour les applications d'analyse et de numérisation.

## 2. Fonctionnalités à Implémenter

### 2.1. Échelle Verticale Graduée

#### 2.1.1. Description Fonctionnelle

Une échelle verticale graduée sera ajoutée sur le côté gauche du spectrogramme, permettant une lecture précise des fréquences représentées. Cette échelle remplacera le système d'étiquetage actuel.

#### 2.1.2. Spécifications Techniques

- **Activation** : Un bouton toggle permettra d'activer ou désactiver l'affichage de l'échelle verticale.
- **Positionnement** : L'échelle sera alignée avec le bord gauche du spectrogramme et couvrira toute sa hauteur.
- **Graduations** : 
  - Échelle logarithmique avec une graduation par octave
  - Chaque graduation sera accompagnée d'une étiquette indiquant la fréquence correspondante
  - Les fréquences minimale et maximale seront toujours affichées
- **Style Visuel** :
  - Ligne verticale continue de 1 pixel d'épaisseur
  - Graduations horizontales de 5 pixels de longueur
  - Typographie identique à celle de l'interface utilisateur
  - Couleur noire (#000000) pour assurer une bonne visibilité à l'impression

#### 2.1.3. Modifications Requises

1. **Structure de données** :
   ```c
   // Dans spectral_generator.h
   typedef struct SpectrogramSettings
   {
       // Champs existants...
       int enableVerticalScale;  // 0 = désactivé, 1 = activé
   } SpectrogramSettings;
   ```

2. **Classe C++** :
   ```cpp
   // Dans SpectrogramSettingsCpp.h
   class SpectrogramSettingsCpp {
   public:
       // Méthodes existantes...
       bool getEnableVerticalScale() const { return m_enableVerticalScale; }
       void setEnableVerticalScale(bool value) { m_enableVerticalScale = value; }
   
   private:
       // Champs existants...
       bool m_enableVerticalScale;
   };
   ```

3. **Rendu** :
   - Modifier les fonctions de rendu dans `spectral_raster.c` et `spectral_vector.c` pour implémenter le dessin de l'échelle verticale
   - Supprimer le code existant de dessin des étiquettes de fréquence

### 2.2. Lignes Horizontales de Repère

#### 2.2.1. Description Fonctionnelle

Deux lignes horizontales configurables seront ajoutées pour servir de repères visuels autour du spectrogramme. Ces lignes pourront être activées indépendamment et leur position sera ajustable via un décalage vertical.

#### 2.2.2. Spécifications Techniques

- **Activation** : Deux boutons toggle permettront d'activer ou désactiver chaque ligne indépendamment.
- **Positionnement** :
  - Ligne du bas : Positionnée avec un décalage négatif par rapport au bas du spectrogramme (par défaut : 34,75 mm)
  - Ligne du haut : Positionnée avec un décalage positif par rapport au haut du spectrogramme (par défaut : 12,55 mm)
- **Configuration** : Champs numériques permettant de spécifier le décalage en millimètres pour chaque ligne
- **Style Visuel** :
  - Lignes horizontales continues de 1 pixel d'épaisseur
  - Couleur noire (#000000)
  - Les lignes traverseront toute la largeur de la page

#### 2.2.3. Modifications Requises

1. **Structure de données** :
   ```c
   // Dans spectral_generator.h
   typedef struct SpectrogramSettings
   {
       // Champs existants...
       int enableBottomReferenceLine;    // 0 = désactivé, 1 = activé
       double bottomReferenceLineOffset; // Décalage en mm (négatif = vers le bas)
       int enableTopReferenceLine;       // 0 = désactivé, 1 = activé
       double topReferenceLineOffset;    // Décalage en mm (positif = vers le haut)
   } SpectrogramSettings;
   ```

2. **Classe C++** :
   ```cpp
   // Dans SpectrogramSettingsCpp.h
   class SpectrogramSettingsCpp {
   public:
       // Méthodes existantes...
       bool getEnableBottomReferenceLine() const { return m_enableBottomReferenceLine; }
       void setEnableBottomReferenceLine(bool value) { m_enableBottomReferenceLine = value; }
       
       double getBottomReferenceLineOffset() const { return m_bottomReferenceLineOffset; }
       void setBottomReferenceLineOffset(double value) { m_bottomReferenceLineOffset = value; }
       
       bool getEnableTopReferenceLine() const { return m_enableTopReferenceLine; }
       void setEnableTopReferenceLine(bool value) { m_enableTopReferenceLine = value; }
       
       double getTopReferenceLineOffset() const { return m_topReferenceLineOffset; }
       void setTopReferenceLineOffset(double value) { m_topReferenceLineOffset = value; }
   
   private:
       // Champs existants...
       bool m_enableBottomReferenceLine;
       double m_bottomReferenceLineOffset;
       bool m_enableTopReferenceLine;
       double m_topReferenceLineOffset;
   };
   ```

3. **Rendu** :
   - Ajouter des fonctions dans `spectral_raster.c` et `spectral_vector.c` pour dessiner les lignes horizontales en fonction des paramètres configurés

### 2.3. Affichage des Paramètres du Spectrogramme

#### 2.3.1. Description Fonctionnelle

Une option permettra d'afficher l'ensemble des paramètres utilisés pour générer le spectrogramme. Ces informations seront affichées en bas de page sous forme de texte aligné sur une seule ligne.

#### 2.3.2. Spécifications Techniques

- **Activation** : Un bouton toggle permettra d'activer ou désactiver l'affichage des paramètres.
- **Contenu** : Tous les paramètres du spectrogramme seront affichés, incluant :
  - Taille FFT
  - Chevauchement (overlap)
  - Fréquences minimale et maximale
  - Taux d'échantillonnage
  - Plage dynamique
  - Correction gamma
  - Facteur de contraste
  - Amplification des hautes fréquences
  - Vitesse d'écriture
  - Format de page
- **Positionnement** : Le texte sera affiché en bas de page, centré horizontalement
- **Style Visuel** :
  - Typographie identique à celle de l'interface utilisateur
  - Taille de police réduite (environ 8-10 points) pour permettre l'affichage de tous les paramètres
  - Couleur noire (#000000)
  - Séparation des paramètres par des virgules ou des points-virgules

#### 2.3.3. Modifications Requises

1. **Structure de données** :
   ```c
   // Dans spectral_generator.h
   typedef struct SpectrogramSettings
   {
       // Champs existants...
       int displayParameters;  // 0 = désactivé, 1 = activé
   } SpectrogramSettings;
   ```

2. **Classe C++** :
   ```cpp
   // Dans SpectrogramSettingsCpp.h
   class SpectrogramSettingsCpp {
   public:
       // Méthodes existantes...
       bool getDisplayParameters() const { return m_displayParameters; }
       void setDisplayParameters(bool value) { m_displayParameters = value; }
   
   private:
       // Champs existants...
       bool m_displayParameters;
   };
   ```

3. **Rendu** :
   - Ajouter des fonctions dans `spectral_raster.c` et `spectral_vector.c` pour formater et afficher les paramètres
   - Implémenter une fonction utilitaire pour convertir les paramètres en chaîne de caractères formatée

## 3. Interface Utilisateur

### 3.1. Section Output Format

Une nouvelle section "Output Format" sera ajoutée à l'interface utilisateur, regroupant les contrôles pour les fonctionnalités décrites ci-dessus.

#### 3.1.1. Composants de l'Interface

1. **Échelle Verticale** :
   - Toggle "Show Vertical Scale" (libellé : "Échelle verticale graduée")

2. **Lignes de Repère** :
   - Toggle "Bottom Reference Line" (libellé : "Ligne de repère inférieure")
   - Champ numérique "Bottom Offset (mm)" (valeur par défaut : -34,75)
   - Toggle "Top Reference Line" (libellé : "Ligne de repère supérieure")
   - Champ numérique "Top Offset (mm)" (valeur par défaut : +12,55)

3. **Affichage des Paramètres** :
   - Toggle "Display Parameters" (libellé : "Afficher les paramètres")

#### 3.1.2. Intégration dans l'Interface Existante

La section "Output Format" sera positionnée après les sections existantes dans l'interface utilisateur, avec un style visuel cohérent avec le reste de l'application.

## 4. Implémentation

### 4.1. Modifications des Fichiers

1. **Structures de données** :
   - `include/spectral_generator.h`
   - `include/SpectrogramSettingsCpp.h`
   - `src/SpectrogramSettingsCpp.cpp`

2. **Interface utilisateur** :
   - `qml/main.qml` ou `qml/main_with_preview.qml`
   - Création potentielle d'un nouveau composant QML pour la section Output Format

3. **Rendu** :
   - `src/spectral_raster.c`
   - `src/spectral_vector.c`

### 4.2. Algorithmes Clés

#### 4.2.1. Dessin de l'Échelle Verticale

```c
void draw_vertical_scale(cairo_t *cr, double spectro_left, double spectro_top, 
                         double spectro_height, double minFreq, double maxFreq) {
    // Dessiner la ligne verticale principale
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_set_line_width(cr, 1.0);
    cairo_move_to(cr, spectro_left, spectro_top);
    cairo_line_to(cr, spectro_left, spectro_top + spectro_height);
    cairo_stroke(cr);
    
    // Calculer les octaves pour les graduations
    double start_octave = ceil(log2(minFreq));
    double end_octave = floor(log2(maxFreq));
    
    // Dessiner les graduations et étiquettes pour chaque octave
    for (double octave = start_octave; octave <= end_octave; octave++) {
        double freq = pow(2.0, octave);
        double log_ratio = log2(freq / minFreq) / log2(maxFreq / minFreq);
        double y = spectro_top + (1.0 - log_ratio) * spectro_height;
        
        // Dessiner la graduation
        cairo_move_to(cr, spectro_left - 5, y);
        cairo_line_to(cr, spectro_left, y);
        cairo_stroke(cr);
        
        // Afficher l'étiquette de fréquence
        char label[32];
        if (freq >= 1000) {
            snprintf(label, sizeof(label), "%.1f kHz", freq / 1000.0);
        } else {
            snprintf(label, sizeof(label), "%.0f Hz", freq);
        }
        
        cairo_move_to(cr, spectro_left - 50, y + 4);
        cairo_show_text(cr, label);
    }
}
```

#### 4.2.2. Dessin des Lignes de Repère

```c
void draw_reference_lines(cairo_t *cr, double spectro_left, double spectro_width,
                         double spectro_bottom, double spectro_top,
                         int enableBottom, double bottomOffset,
                         int enableTop, double topOffset) {
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_set_line_width(cr, 1.0);
    
    // Ligne de repère inférieure
    if (enableBottom) {
        double y = spectro_bottom + bottomOffset * MM_TO_PIXELS;
        cairo_move_to(cr, spectro_left, y);
        cairo_line_to(cr, spectro_left + spectro_width, y);
        cairo_stroke(cr);
    }
    
    // Ligne de repère supérieure
    if (enableTop) {
        double y = spectro_top - topOffset * MM_TO_PIXELS;
        cairo_move_to(cr, spectro_left, y);
        cairo_line_to(cr, spectro_left + spectro_width, y);
        cairo_stroke(cr);
    }
}
```

#### 4.2.3. Affichage des Paramètres

```c
void draw_parameters_text(cairo_t *cr, double page_width, double page_height,
                         const SpectrogramSettings *s) {
    if (!s->displayParameters) return;
    
    // Formater la chaîne de paramètres
    char params[1024];
    snprintf(params, sizeof(params),
             "FFT: %d, Overlap: %.2f, Freq: %.0f-%.0f Hz, SR: %d Hz, DR: %.1f dB, "
             "Gamma: %.1f, Contrast: %.1f, HB: %s (%.2f), WS: %.1f cm/s",
             s->fftSize, s->overlap, s->minFreq, s->maxFreq, s->sampleRate,
             s->dynamicRangeDB, s->gammaCorrection, s->contrastFactor,
             s->enableHighBoost ? "On" : "Off", s->highBoostAlpha, s->writingSpeed);
    
    // Positionner et dessiner le texte
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_set_font_size(cr, 10.0);
    
    cairo_text_extents_t extents;
    cairo_text_extents(cr, params, &extents);
    
    double text_x = (page_width - extents.width) / 2;
    double text_y = page_height - 20.0;
    
    cairo_move_to(cr, text_x, text_y);
    cairo_show_text(cr, params);
}
```

## 5. Considérations d'Implémentation

### 5.1. Performance

L'ajout de ces fonctionnalités n'aura pas d'impact significatif sur les performances, car elles concernent uniquement le rendu final et non le traitement du signal.

### 5.2. Compatibilité

Les modifications doivent être implémentées de manière cohérente dans les deux stratégies de visualisation (raster et vectorielle) pour assurer une expérience utilisateur uniforme.

### 5.3. Extensibilité

L'architecture proposée permet d'ajouter facilement d'autres options de formatage à l'avenir, en suivant le même modèle d'extension des structures de données et des fonctions de rendu.

## 6. Conclusion

Ces nouvelles fonctionnalités amélioreront significativement l'utilité et la lisibilité des spectrogrammes générés par Sp3ctraGen, en particulier pour les applications d'analyse et de numérisation. L'implémentation proposée s'intègre harmonieusement dans l'architecture existante et maintient la cohérence visuelle de l'application.