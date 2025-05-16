# Fonctionnalités de Sp3ctraGen

Ce document présente les principales fonctionnalités de Sp3ctraGen et explique comment les utiliser efficacement.

## Vue d'ensemble

Sp3ctraGen est une application professionnelle de génération de spectrogrammes haute qualité. Elle permet de transformer des fichiers audio en représentations visuelles détaillées du contenu fréquentiel, optimisées pour l'impression et la numérisation.

## Fonctionnalités principales

### 1. Génération de spectrogrammes haute qualité

Sp3ctraGen produit des spectrogrammes avec une résolution fréquentielle et temporelle optimale, permettant une analyse précise des fichiers audio.

**Caractéristiques clés :**
- Résolution à 800 DPI pour une impression de qualité
- Échelle logarithmique pour les fréquences
- Traitement FFT optimisé
- Normalisation du signal

### 2. Formats de sortie multiples

L'application prend en charge plusieurs formats de sortie pour répondre à différents besoins :

- **PNG** (raster) :
  - Idéal pour l'utilisation numérique et le partage
  - Compatible avec tous les logiciels d'édition d'image
  - Optimisé pour l'écran et l'impression

- **PDF** (vectoriel) :
  - Mise à l'échelle sans perte de qualité
  - Idéal pour les publications scientifiques
  - Support du texte et des métadonnées

### 3. Paramètres avancés du spectrogramme

Sp3ctraGen offre un contrôle précis sur les paramètres de génération :

#### Paramètres principaux

- **Bins par seconde (Bins/s)** : Contrôle la résolution temporelle du spectrogramme.
  - Valeur recommandée : 150 bins/s
  - Valeurs plus élevées : Meilleure résolution temporelle
  - Valeurs plus basses : Meilleure résolution fréquentielle

- **Plage de fréquences** :
  - Fréquence minimale (par défaut : 65 Hz)
  - Fréquence maximale (par défaut : 16640 Hz)
  - Ajustez ces valeurs selon le contenu à analyser (voix, musique, etc.)

- **Plage dynamique (dB)** : Détermine la gamme d'intensités sonores représentées.
  - Valeur par défaut : 60 dB
  - Valeurs plus élevées : Affiche plus de détails dans les signaux faibles
  - Valeurs plus basses : Accentue les différences entre signaux forts et faibles

#### Paramètres de rendu

- **Facteur de contraste** : Ajuste le contraste visuel du spectrogramme.
  - Valeur par défaut : 1.9
  - Augmentez pour accentuer les différences d'intensité

- **Correction gamma** : Ajuste la courbe de réponse du spectrogramme.
  - Valeur par défaut : 0.8
  - Diminuez pour éclaircir les zones de faible intensité

- **Amplification des hautes fréquences** : Améliore la visibilité des composantes haute fréquence.
  - Activée par défaut
  - Particulièrement utile pour la détection de signaux discrets à haute fréquence

### 4. Prévisualisation en temps réel

La fonction de prévisualisation permet de visualiser les modifications de paramètres avant la génération finale :

- Prévisualisation rapide sans générer le fichier complet
- Mise à jour interactive lors de l'ajustement des paramètres
- Zoom et navigation dans la prévisualisation

### 5. Visualisation de la forme d'onde audio

La section de forme d'onde audio offre :

- Affichage visuel du signal temporel
- Sélection de sections spécifiques pour l'analyse
- Normalisation automatique pour une meilleure visualisation
- Zoom sur les passages d'intérêt

### 6. Paramètres de filtrage

Les options de filtrage permettent d'optimiser l'analyse pour différents types de signaux :

- **Filtre passe-haut** : Élimine les fréquences basses indésirables
  - Ajustez la fréquence de coupure selon le contenu
  
- **Filtre passe-bas** : Limite les fréquences hautes
  - Utile pour se concentrer sur les composantes fondamentales

- **Égalisation personnalisée** : Permet d'ajuster la courbe de réponse fréquentielle
  - Amplifiez ou atténuez des bandes de fréquences spécifiques

### 7. Optimisation pour l'impression

Sp3ctraGen est spécialement conçu pour produire des spectrogrammes optimisés pour l'impression :

- Support des formats standard (A4 portrait, A3 paysage)
- Réglage précis des marges et dimensions
- Contrôle de la vitesse d'écriture (cm/s) pour ajuster la durée d'audio représentée
- Génération à 800 DPI pour une qualité d'impression professionnelle

### 8. Mode résolution curseur

Le mode résolution curseur permet un contrôle encore plus précis sur la visualisation :

- Ajustement dynamique de la résolution en fonction de la position du curseur
- Adaptation automatique des paramètres FFT pour optimiser la visualisation
- Idéal pour l'analyse détaillée de sections spécifiques

## Utilisation des fonctionnalités principales

### Génération d'un spectrogramme basique

1. Dans la section "Fichier", cliquez sur "Ouvrir" pour sélectionner un fichier audio WAV
2. Choisissez un dossier et un nom de fichier de sortie
3. Sélectionnez le format de sortie souhaité (PNG ou PDF)
4. Cliquez sur "Générer" pour créer le spectrogramme avec les paramètres par défaut

### Personnalisation avancée

Pour une analyse plus précise :

1. Ajustez les paramètres "Bins par seconde" selon vos besoins d'analyse :
   - 80-100 bins/s : Analyse détaillée haute fréquence
   - 150 bins/s : Équilibre général (valeur par défaut)
   - 200-250 bins/s : Analyse longue durée

2. Modifiez la plage de fréquences pour cibler votre analyse :
   - Pour la voix humaine : 80-8000 Hz
   - Pour la musique complète : 20-20000 Hz
   - Pour les instruments graves : 20-2000 Hz

3. Ajustez la plage dynamique :
   - 40-50 dB : Accentue les signaux principaux
   - 60-70 dB : Révèle plus de détails dans les signaux faibles

4. Optimisez les paramètres de rendu pour votre cas d'utilisation :
   - Augmentez le contraste pour les impressions
   - Utilisez l'amplification des hautes fréquences pour détecter les signaux discrets

### Optimisation pour l'impression

Pour obtenir des spectrogrammes parfaitement adaptés à l'impression :

1. Sélectionnez le format de page approprié (A4 portrait ou A3 paysage)
2. Ajustez la vitesse d'écriture (cm/s) pour contrôler la durée d'audio représentée :
   - Vitesses plus lentes (2-5 cm/s) : Représentation plus détaillée, durée plus courte
   - Vitesses plus rapides (8-15 cm/s) : Représentation moins détaillée, durée plus longue

3. Définissez la marge inférieure et la hauteur du spectrogramme selon vos besoins
4. Pour l'impression, choisissez le format PDF pour une qualité optimale

### Utilisation du mode résolution curseur

Pour une analyse encore plus précise :

1. Activez le mode résolution curseur dans les paramètres avancés
2. Déplacez le curseur sur la prévisualisation pour ajuster automatiquement la résolution
3. Les zones où le curseur est positionné bénéficieront d'une résolution accrue
4. Désactivez cette fonction pour revenir à un rendu uniforme

### Utilisation de la prévisualisation

Pour tester rapidement différents paramètres :

1. Après avoir chargé un fichier audio, la prévisualisation s'affiche automatiquement
2. Modifiez les paramètres pour voir leur effet en temps réel
3. Utilisez les contrôles de zoom pour examiner les détails
4. Une fois satisfait du résultat, générez le spectrogramme final

## Cas d'utilisation spécifiques

### Analyse vocale

Configuration optimale pour l'analyse vocale :
- Fréquence minimale : 80 Hz
- Fréquence maximale : 8000 Hz
- Plage dynamique : 50 dB
- Bins par seconde : 150-200
- Amplification des hautes fréquences : Activée

### Analyse musicale

Configuration optimale pour l'analyse musicale complète :
- Fréquence minimale : 20 Hz
- Fréquence maximale : 20000 Hz
- Plage dynamique : 60-70 dB
- Bins par seconde : 100-150
- Correction gamma : 0.7-0.8 pour mieux visualiser les harmoniques

### Documents scientifiques

Configuration optimale pour les publications scientifiques :
- Format de sortie : PDF vectoriel
- Résolution : 800 DPI
- Format : A4 portrait (ou selon les exigences de la publication)
- Contraste : 2.0 pour une meilleure lisibilité à l'impression
- Amplification des hautes fréquences : Selon le sujet d'étude

## Conclusion

Les fonctionnalités de Sp3ctraGen offrent un contrôle précis sur la génération de spectrogrammes, permettant d'obtenir des résultats optimaux pour différents cas d'utilisation. L'application combine des algorithmes de traitement du signal avancés avec une interface utilisateur intuitive, rendant l'analyse spectrale accessible aussi bien aux professionnels qu'aux utilisateurs moins expérimentés.

Pour des informations plus détaillées sur l'utilisation de l'interface, veuillez consulter le [Guide de démarrage rapide](prise_en_main.md).

Pour des explications techniques approfondies sur les algorithmes et méthodes utilisés, référez-vous à la [documentation technique](../technique/specification_spectrogramme.md).
