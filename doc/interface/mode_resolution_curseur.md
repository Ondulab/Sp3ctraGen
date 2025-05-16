# Mode de résolution par curseur

## Introduction

Le mode de résolution par curseur est une fonctionnalité avancée de Sp3ctraGen qui offre un contrôle intuitif sur le compromis entre résolution temporelle et résolution fréquentielle des spectrogrammes générés.

## Principe de fonctionnement

Contrairement à la méthode traditionnelle qui nécessite de définir directement des valeurs numériques pour les "bins par seconde" (bps) et l'overlap, le mode de résolution par curseur propose une approche simplifiée :

- Un **curseur unique** permet de choisir facilement le compromis résolution temporelle/fréquentielle
- Des **calculs automatiques** garantissent des valeurs optimales pour chaque position du curseur
- Le système assure que la résolution respecte les **contraintes physiques d'impression**

## Utilisation du curseur

Le curseur de résolution présente trois positions principales, chacune optimisée pour un type d'analyse spécifique :

![Curseur de résolution](../images/resolution_curseur.png)

### 1. Mode "Temporal" (à gauche)

- Favorise la **résolution temporelle**
- Idéal pour distinguer des événements sonores rapprochés dans le temps
- Parfait pour l'analyse de transitoires, percussions, ou changements rapides
- Offre moins de précision dans la séparation des fréquences proches

### 2. Mode "Balanced" (centre)

- Équilibre entre résolution temporelle et fréquentielle
- Recommandé pour les analyses générales
- Convient à la plupart des contenus audio standard
- Position par défaut du curseur

### 3. Mode "Spectral" (à droite)

- Privilégie la **résolution fréquentielle**
- Optimal pour distinguer des fréquences proches
- Parfait pour l'analyse d'harmoniques ou de sons stationnaires
- Offre moins de précision temporelle

## Valeurs techniques générées

Pour les utilisateurs avancés, le système affiche les valeurs techniques dérivées de la position du curseur :

### Bins par seconde (bps)

Le nombre de colonnes spectrales par seconde d'audio, qui détermine directement la résolution temporelle.

| Vitesse d'écriture | Mode Temporal | Mode Balanced | Mode Spectral |
|--------------------|---------------|--------------|---------------|
| 1 cm/s | 82 bps | 50 bps | 27 bps |
| 5 cm/s | 409 bps | 252 bps | 134 bps |
| 10 cm/s | 819 bps | 504 bps | 268 bps |

### Taille de FFT calculée

La taille de la fenêtre d'analyse FFT, toujours arrondie à la puissance de 2 supérieure. Des valeurs plus élevées offrent une meilleure résolution fréquentielle.

### Overlap effectif

Le taux de chevauchement entre les fenêtres d'analyse consécutives. Les valeurs typiques sont :
- Mode Temporal : environ 0.30 (30%)
- Mode Balanced : environ 0.75 (75%)
- Mode Spectral : environ 0.92 (92%)

## Relation avec la vitesse d'écriture

La vitesse d'écriture (en cm/s) a un impact direct sur les valeurs de bps et la durée audio représentée :

- Des vitesses d'écriture plus élevées permettent des valeurs de bps plus élevées
- La durée audio représentée est toujours calculée selon la formule :  
  durée (s) = largeur du papier (cm) / vitesse d'écriture (cm/s)

## Échelle constante et adaptation dynamique

> ✨ **Nouveau dans la version 0.12.1** : Avec l'adaptation dynamique de l'espacement entre bins, la largeur du segment audio est maintenant uniquement déterminée par la vitesse d'écriture, indépendamment de la position du curseur de résolution.

Grâce à cette amélioration :

- La modification du curseur de résolution n'affecte plus la largeur du spectrogramme 
- Seule la vitesse d'écriture influence l'échelle horizontale du spectrogramme
- La position du curseur affecte uniquement la qualité d'analyse (compromis temporel/spectral)
- La relation "durée audio = largeur papier / vitesse d'écriture" est strictement respectée

Cette amélioration permet de choisir librement la qualité d'analyse souhaitée sans compromettre l'échelle physique du rendu final.

## Limitations et avertissements

Le système maintient automatiquement les valeurs de bins par seconde dans une plage raisonnable (20-1200 bps) pour garantir des résultats de qualité. Si le curseur génère des valeurs hors de cette plage, les conditions suivantes s'appliquent :

1. **Limitation basse** (< 20 bps) : 
   - Se produit généralement à très faible vitesse d'écriture
   - Un message d'avertissement s'affiche
   - La valeur est automatiquement fixée à 20 bps

2. **Limitation haute** (> 1200 bps) :
   - Se produit à haute vitesse d'écriture, surtout en mode Temporal
   - Un message d'avertissement s'affiche
   - La valeur est automatiquement fixée à 1200 bps

![Avertissement de limitation](../images/resolution_warning.png)

## Conseils d'utilisation

### Quand utiliser chaque mode

- **Mode Temporal** : Pour l'analyse de contenus rythmiques, de consonnes dans la parole, ou d'événements très courts
- **Mode Balanced** : Pour une analyse générale de musique ou de parole
- **Mode Spectral** : Pour l'analyse de tonalités soutenues, de notes tenues, ou la séparation d'harmoniques proches

### Ajustement fin

Le curseur permet un réglage continu entre les trois modes principaux, offrant un ajustement fin selon vos besoins spécifiques.

### Optimisation pour différents types d'audio

1. **Voix parlée** :
   - Position recommandée : Entre Balanced et Temporal
   - Vitesse d'écriture : 5-8 cm/s

2. **Musique orchestrale** :
   - Position recommandée : Entre Balanced et Spectral
   - Vitesse d'écriture : 3-6 cm/s

3. **Signaux électroniques** :
   - Position recommandée : Spectral
   - Vitesse d'écriture : 2-4 cm/s

4. **Percussions/Batterie** :
   - Position recommandée : Temporal
   - Vitesse d'écriture : 8-12 cm/s

## Comparaison avec le système antérieur

Pour les utilisateurs familiers avec l'ancien système de paramétrage :

| Ancien paramètre | Nouveau système |
|------------------|-----------------|
| Bins/s (direct) | Calculé automatiquement selon la position du curseur |
| Préréglage d'overlap (Low/Medium/High) | Intégré dans le positionnement du curseur |
| FFT Size (choix manuel) | Calculée automatiquement et optimisée |

## Conclusion

Le mode de résolution par curseur simplifie considérablement l'obtention de spectrogrammes de haute qualité en remplaçant plusieurs paramètres techniques par une interface intuitive. En déplaçant simplement le curseur, vous pouvez facilement trouver le compromis optimal entre résolution temporelle et fréquentielle pour votre analyse spécifique.

Avec l'adaptation dynamique de l'espacement entre bins, vous pouvez désormais vous concentrer uniquement sur la qualité d'analyse sans vous soucier des impacts sur l'échelle physique du rendu final.

Pour les utilisateurs avancés, les valeurs techniques sous-jacentes restent visibles et explicites, offrant à la fois simplicité d'utilisation et transparence technique.
