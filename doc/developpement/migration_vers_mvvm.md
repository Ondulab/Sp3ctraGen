# Guide de migration vers l'architecture MVVM

Ce document présente un plan détaillé pour migrer progressivement l'application Sp3ctraGen vers la nouvelle architecture MVVM (Model-View-ViewModel).

## Objectifs de la migration

1. **Éliminer les redondances de calcul** entre front-end et back-end
2. **Centraliser les paramètres** dans un modèle unifié
3. **Simplifier l'interface QML** en réduisant le nombre de paramètres passés
4. **Améliorer les performances** en utilisant des mécanismes de cache
5. **Faciliter la maintenance** en séparant clairement les responsabilités

## Architecture actuelle vs. nouvelle architecture

### Architecture actuelle
```
┌─────────────────┐
│  Interface QML  │ ◄────► Paramètres individuels
└────────┬────────┘        (20+ propriétés)
         │
         ▼
┌─────────────────┐
│  Logique C++    │ ◄────► Duplication des calculs
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Moteur C       │
└─────────────────┘
```

### Nouvelle architecture MVVM
```
┌─────────────────┐
│  Interface QML  │ ◄────► Vue simplifiée
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  ViewModel C++  │ ◄────► Logique de présentation
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Modèle unifié  │ ◄────► Calculs centralisés et cache
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Backend C/C++  │
└─────────────────┘
```

## Étapes de migration

### Phase 1: Installation de l'infrastructure (Réalisée)

1. ✅ Création de la classe `SpectrogramParametersModel`
2. ✅ Création de la classe `SpectrogramViewModel`
3. ✅ Intégration dans le fichier projet
4. ✅ Initialisation dans main.cpp
5. ✅ Documentation et exemples d'utilisation

### Phase 2: Migration des composants QML individuels

1. **Préparation**:
   - Identifier les propriétés et calculs redondants dans chaque composant
   - Créer un plan de migration spécifique pour chaque section

2. **Section SpectrogramParameters**:
   - Remplacer les propriétés locales par des références au modèle:
   ```qml
   // Avant
   property double minFreq: 20.0
   
   // Après
   // La propriété est directement liée au modèle centralisé
   property double minFreq: paramsModel.minFreq
   onMinFreqChanged: paramsModel.minFreq = minFreq
   ```

3. **Section FilterParameters**:
   - Migrer les propriétés de filtrage vers le modèle centralisé
   - Remplacer les calculs locaux par des accès aux propriétés du modèle

4. **Section OutputFormat**:
   - Lier les propriétés de format au modèle centralisé

5. **Section AudioWaveformSection**:
   - Simplifier l'interaction en utilisant le ViewModel pour les opérations sur les segments

### Phase 3: Simplification des méthodes principales

1. **Simplifier generateSpectrogramFromSegment**:
   ```qml
   // Avant
   function generateSpectrogramFromSegment() {
       // 30+ lignes de préparation des paramètres
       generator.generateSpectrogramFromSegment(
           // 20+ paramètres individuels
       )
   }
   
   // Après
   function generateSpectrogramFromSegment() {
       viewModel.generateSpectrogramFromSegment(
           audioWaveformSection.extractCurrentSegment(),
           audioWaveformSection.getAudioFileName(),
           audioWaveformSection.getStartPosition()
       )
   }
   ```

2. **Simplifier l'initialisation et communication entre composants**:
   - Utiliser le modèle centralisé pour partager l'état entre composants
   - Réduire le nombre de propriétés explicitement passées

### Phase 4: Optimisations avancées

1. **Implémentation des mises à jour par lots**:
   ```qml
   // Regrouper plusieurs modifications pour éviter des recalculs multiples
   function applyChanges() {
       paramsModel.beginUpdate();
       
       paramsModel.minFreq = minFreqField.value;
       paramsModel.maxFreq = maxFreqField.value;
       paramsModel.writingSpeed = writingSpeedField.value;
       
       paramsModel.endUpdate();
   }
   ```

2. **Utilisation des valeurs calculées en cache**:
   ```qml
   Text {
       text: "Taille FFT: " + paramsModel.fftSize + ", Overlap: " + 
             (paramsModel.effectiveOverlap * 100).toFixed(1) + "%"
   }
   ```

## Avantages pour les développeurs

1. **Code QML plus propre et concis**:
   - Moins de propriétés à définir et à passer entre composants
   - Logique de présentation déplacée vers le ViewModel

2. **Maintenance simplifiée**:
   - Localisation facile des calculs et de la logique
   - Séparation claire des responsabilités

3. **Meilleures performances**:
   - Calculs effectués une seule fois, résultats mis en cache
   - Réduction du nombre de mises à jour d'interface

4. **Meilleures pratiques de développement**:
   - Respect du principe DRY (Don't Repeat Yourself)
   - Meilleure testabilité du code

## Recommandations techniques

1. **Création de nouveaux composants**:
   - Utiliser directement la nouvelle architecture pour tout nouveau composant
   - Voir l'exemple dans `qml/examples/MVVMExample.qml`

2. **Migration des composants existants**:
   - Procéder un composant à la fois
   - Commencer par les composants les plus simples
   - Tester chaque modification avant de passer à la suivante

3. **Tests**:
   - Vérifier que les valeurs affichées sont identiques avant/après migration
   - Tester les performances pour s'assurer que les calculs ne sont effectués qu'une fois

## Exemple concret d'utilisation

Consultez `qml/examples/MVVMExample.qml` pour un exemple complet montrant comment utiliser le modèle MVVM avec l'interface QML.

La documentation détaillée sur l'API et les concepts est disponible dans `doc/developpement/exemple_utilisation_mvvm.md`.

## Prochaines étapes

1. Établir un calendrier de migration progressive
2. Commencer par migrer SpectrogramParameters et FilterParameters
3. Adapter les méthodes principales pour utiliser le ViewModel
4. Mesurer les gains de performance et la réduction de code

Cette migration peut être effectuée en parallèle avec le développement de nouvelles fonctionnalités, en s'assurant que tout nouveau code utilise directement la nouvelle architecture.
