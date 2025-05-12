# Message de commit proposé

```
feat(ui): improve QML interface components and parameter handling

- Add better access to component parameters through aliases
- Enhance parameter fields with direct numeric value access
- Improve high-pass filter controls with proper toggle behavior
- Update spectrogram generation function with more precise parameter handling
- Standardize decimal point handling in numeric inputs
- Improve preview section with better event handling
```

## Résumé des modifications

### main.qml
- Amélioration de l'accès aux valeurs numériques des composants ParameterField
- Utilisation de la propriété `numericValue` pour éviter les conversions manuelles
- Optimisation des gestionnaires d'événements pour le traitement du spectrogramme
- Amélioration de la coordination entre les différentes sections de l'interface

### SpectrogramParameters.qml
- Ajout d'alias pour exposer directement les composants
- Meilleure organisation des propriétés pour faciliter la liaison bidirectionnelle
- Amélioration des contrôles pour le filtre passe-haut avec comportement de bascule approprié
- Optimisation de la structure du GridLayout pour une meilleure présentation des contrôles

### ParameterField.qml
- Ajout d'une propriété `numericValue` qui expose directement la valeur numérique
- Standardisation sur les points décimaux pour améliorer la compatibilité
- Amélioration de la validation et mise à jour des valeurs
- Ajout de méthodes publiques pour une meilleure interaction avec les valeurs

### PreviewSection.qml
- Amélioration de la gestion des événements avec des fonctions dédiées
- Ajout d'alias pour faciliter l'accès aux composants internes
- Optimisation du système de prévisualisation avec un compteur pour forcer le rechargement
- Meilleure gestion des états et des messages pour l'utilisateur

Ces modifications améliorent l'expérience utilisateur et rendent le code plus maintenable en standardisant l'accès aux paramètres à travers l'application.