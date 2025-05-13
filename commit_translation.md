# Translation of French Commit Message

The commit 73105c1 ("# Améliorations visuelles et fonctionnelles pour Sp3ctraGen") has been identified as having a French message, which violates the project's commit message guidelines.

## Original message (French)

```
# Améliorations visuelles et fonctionnelles pour Sp3ctraGen

## Fonctionnalités ajoutées

1. **Mise à jour dynamique de "Segment duration" lors du changement de WS (Window Size)**
   - Le calcul de la durée du segment intègre maintenant la taille de fenêtre FFT
   - La durée du segment est automatiquement recalculée quand la valeur WS change
   - Ajout d'une liaison entre les paramètres FFT et l'affichage de la forme d'onde

2. **Visualisation améliorée de la zone audio utilisée pour le spectrogramme**
   - Ajout d'une surbrillance bleue dans la forme d'onde pour visualiser la zone utilisée
   - L'indicateur de segment possède maintenant des bordures pour une meilleure distinction
   - L'opacité et la superposition (z-index) ont été ajustées pour une meilleure visibilité
```

## Correct message (English, Conventional Commits)

```
feat(ui): improve audio visualization and dynamic segment duration updates

- Add dynamic updating of segment duration when changing FFT window size
- Enhance audio waveform visualization with blue highlighting for the processed segment
- Implement bidirectional binding between FFT size parameters and audio section
- Add segment borders and improve visibility with adjusted opacity and z-index
- Update calculation formulas to incorporate FFT size with proper scaling
```

This document serves as a reference for the proper commit message format that should have been used, without modifying the Git history.