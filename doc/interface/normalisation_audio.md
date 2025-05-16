# Fonctionnalité de normalisation audio

## Introduction

La normalisation audio est une fonctionnalité intégrée à Sp3ctraGen qui permet d'optimiser l'affichage et la visualisation de la forme d'onde audio. Cette documentation explique son fonctionnement et son utilisation.

## Principe de fonctionnement

Lorsqu'un fichier audio est chargé dans l'application, son amplitude peut varier considérablement selon l'enregistrement. Certains fichiers peuvent présenter des niveaux très bas, rendant la visualisation de la forme d'onde difficile, tandis que d'autres peuvent avoir des niveaux proches de la saturation.

La normalisation ajuste automatiquement l'amplitude du signal afin que :
- La visualisation de la forme d'onde utilise l'espace vertical disponible de manière optimale
- Les sections de faible amplitude deviennent plus visibles
- L'aspect visuel global de la forme d'onde soit amélioré

## Fonctionnement technique

La normalisation dans Sp3ctraGen fonctionne en plusieurs étapes :

1. Analyse des données de la forme d'onde pour trouver les valeurs minimales et maximales
2. Calcul du facteur de normalisation (1.0 / valeur maximale absolue)
3. Application de ce facteur à toutes les valeurs de la forme d'onde
4. Mise à jour de l'affichage avec les données normalisées

Il est important de noter que **cette normalisation n'affecte que la visualisation** et non les données audio réelles utilisées pour générer le spectrogramme. Ainsi, la qualité et les caractéristiques du spectrogramme généré restent fidèles au signal original.

## Utilisation

### Emplacement du bouton

Le bouton "Normalize Audio" est situé dans la section de visualisation de la forme d'onde, à côté du bouton "Load Audio".

![Bouton de normalisation audio](../images/normalize_audio_button.png)

### Quand utiliser la normalisation

La normalisation est particulièrement utile dans les cas suivants :

1. **Fichiers audio de faible niveau** : Lorsque l'amplitude du signal est faible, rendant la forme d'onde à peine visible
2. **Analyse de sections spécifiques** : Pour mieux visualiser des sections particulières du signal qui pourraient être masquées à cause d'autres sections à forte amplitude
3. **Comparaison visuelle** : Pour comparer plus facilement différentes parties d'un enregistrement en égalisant leurs niveaux apparents

### Effets sur l'interface

Après avoir cliqué sur le bouton "Normalize Audio" :

1. La forme d'onde est immédiatement redimensionnée pour occuper l'espace vertical disponible
2. Un message de confirmation apparaît, indiquant le facteur de normalisation appliqué
3. Si le signal est déjà normalisé (ou proche de l'être), un message vous en informe

## Exemples visuels

### Avant normalisation
![Forme d'onde avant normalisation](../images/waveform_before_normalization.png)

### Après normalisation
![Forme d'onde après normalisation](../images/waveform_after_normalization.png)

## Points importants à retenir

1. **Normalisation visuelle uniquement** : Cette fonction n'affecte que la visualisation, pas les données audio utilisées pour le traitement du spectrogramme
2. **Réversibilité** : Recharger le fichier audio réinitialise la visualisation à son état d'origine
3. **Facteur de normalisation** : Le message affiché après la normalisation indique l'amplification appliquée (par exemple, "Audio normalized (factor: 2.45)")
4. **Pas d'effet sur le spectrogramme** : Les spectrogrammes générés conservent la dynamique originale du signal

## Relation avec les autres paramètres

Contrairement aux versions précédentes de l'application, la normalisation est maintenant une fonctionnalité de visualisation uniquement, distincte du processus de génération du spectrogramme.

La normalisation utilisée lors de la génération du spectrogramme est toujours active par défaut et appliquée automatiquement au signal avant l'analyse spectrale. Cette normalisation interne garantit une utilisation optimale de la plage dynamique dans le spectrogramme final.

## Cas d'utilisation avancés

### Identification de sections de faible niveau

La normalisation peut révéler des détails dans des sections de faible amplitude qui seraient autrement difficiles à repérer. Cette fonctionnalité est particulièrement utile pour :

- Détecter des sons ambiants ou de fond dans des enregistrements
- Identifier des artefacts subtils ou du bruit
- Analyser la structure fine de sections spécifiques d'un enregistrement

### Comparaison avant/après

Vous pouvez facilement alterner entre l'affichage normalisé et non normalisé en :
1. Cliquant sur le bouton "Normalize Audio" pour activer la normalisation
2. Rechargeant le fichier audio pour revenir à l'état non normalisé
3. Répétant selon vos besoins d'analyse

## Conclusion

La fonctionnalité de normalisation audio offre un moyen simple et efficace d'améliorer la visualisation de la forme d'onde, facilitant ainsi l'analyse préliminaire du signal avant la génération du spectrogramme. Son intégration intuitive dans l'interface utilisateur la rend accessible et pratique à utiliser, tout en préservant l'intégrité des données pour le traitement spectral.
