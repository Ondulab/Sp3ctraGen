# Exemple d'utilisation du modèle MVVM dans Sp3ctraGen

Ce document présente un exemple d'utilisation de la nouvelle architecture MVVM implémentée dans Sp3ctraGen, avec des extraits de code QML montrant comment utiliser le nouveau modèle de paramètres unifié et le ViewModel.

## Structure du modèle MVVM

```
┌─────────────────┐
│  Interface QML  │ (Vue)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  ViewModel C++  │ (SpectrogramViewModel)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Modèle Unifié   │ (SpectrogramParametersModel)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Backend C/C++  │ (SpectrogramGenerator, etc.)
└─────────────────┘
```

## Exemple d'utilisation en QML

### Avant : Accès direct aux paramètres et au generator

```qml
// Avant la refactorisation
Button {
    text: "Générer spectrogramme"
    onClicked: {
        generator.generateSpectrogramFromSegment(
            minFreq, maxFreq, segmentDur, sampleRate, dynamicRange,
            gammaCorrection, enableDithering, contrastFactor,
            enableHighBoost, highBoostAlpha, enableHighPassFilter,
            highPassCutoffFreq, highPassFilterOrder, pageFormat,
            bottomMarginMM, spectroHeightMM, writingSpeed,
            enableVerticalScale, enableBottomReferenceLine,
            bottomReferenceLineOffset, enableTopReferenceLine,
            topReferenceLineOffset, displayParameters,
            textScaleFactor, lineThicknessFactor,
            audioSegment, originalFileName, startPosition,
            binsPerSecond, overlapPreset
        )
    }
}
```

### Après : Utilisation du modèle MVVM

```qml
// Après la refactorisation
Button {
    text: "Générer spectrogramme"
    onClicked: {
        // Le ViewModel se charge de récupérer tous les paramètres et de gérer les appels
        viewModel.generateSpectrogramFromSegment(
            audioWaveformSection.extractCurrentSegment(),
            audioWaveformSection.getAudioFileName(),
            audioWaveformSection.getStartPosition()
        )
    }
}
```

## Liaison bidirectionnelle des paramètres avec le modèle

### Avant : Chaque champ a sa propre valeur locale

```qml
// Paramètres locaux dans chaque composant
ParameterField {
    id: minFreqField
    label: qsTr("Fréquence min (Hz)")
    value: "20"
    validator: DoubleValidator { bottom: 1.0; top: 20000.0 }
    onValueChanged: {
        // Logique de conversion et validation complexe
        var numericValue = parseFloat(value.replace(',', '.'));
        // ...
    }
}
```

### Après : Liaison directe avec le modèle centralisé

```qml
// Liaison directe avec le modèle centralisé
ParameterField {
    id: minFreqField
    label: qsTr("Fréquence min (Hz)")
    value: paramsModel.minFreq
    validator: DoubleValidator { bottom: 1.0; top: 20000.0 }
    onValueChanged: {
        paramsModel.minFreq = value
    }
}
```

## Affichage des valeurs calculées

```qml
// Affichage automatique des valeurs calculées (mises en cache)
Column {
    Text { text: "Taille FFT calculée: " + paramsModel.fftSize }
    Text { text: "Bins par seconde: " + paramsModel.binsPerSecond.toFixed(1) }
    Text { text: "Overlap effectif: " + (paramsModel.effectiveOverlap * 100).toFixed(1) + "%" }
}
```

## Mises à jour groupées

```qml
Button {
    text: "Appliquer les changements"
    onClicked: {
        // Grouper les modifications pour éviter des recalculs inutiles
        paramsModel.beginUpdate();
        
        paramsModel.minFreq = minFreqField.value;
        paramsModel.maxFreq = maxFreqField.value;
        paramsModel.writingSpeed = writingSpeedField.value;
        paramsModel.resolutionSliderValue = resolutionSlider.value;
        
        paramsModel.endUpdate();
        
        // Les signaux et recalculs sont déclenchés une seule fois ici
    }
}
```

## Status et retour d'information via ViewModel

```qml
// Affichage de l'état et des messages
StatusText {
    text: viewModel.statusMessage
    color: viewModel.isGenerating ? "orange" : "green"
}

// Désactivation des contrôles pendant la génération
Button {
    text: "Générer"
    enabled: !viewModel.isGenerating
    // ...
}

// Progression
ProgressBar {
    visible: viewModel.isGenerating
    value: progressValue // Connecté au signal viewModel.progressUpdated
}
```

## Gestion des événements

```qml
// Connexion aux signaux du ViewModel
Component.onCompleted: {
    viewModel.spectrogramGenerated.connect(function(success, outputPath, errorMessage) {
        if (success) {
            statusText.text = "Spectrogramme généré avec succès: " + outputPath;
            statusText.color = "green";
        } else {
            statusText.text = "Erreur: " + errorMessage;
            statusText.color = "red";
        }
    });
    
    viewModel.progressUpdated.connect(function(progress, message) {
        progressBar.value = progress / 100.0;
        progressText.text = message;
    });
}
```

## Avantages de l'architecture MVVM

1. **Séparation des préoccupations**: L'interface QML se concentre sur l'affichage et les interactions utilisateur, le ViewModel gère la logique d'application, et le modèle encapsule les données et les règles métier.

2. **Réduction de la duplication de code**: Les calculs dérivés sont centralisés et mis en cache.

3. **Simplification des appels**: Plus besoin de passer 20+ paramètres à chaque appel de fonction.

4. **Meilleures performances**: Mises à jour par lots, cache pour les valeurs calculées, réduction des recalculs inutiles.

5. **Meilleure maintenance**: Organisation claire du code, séparation des responsabilités, et moins de code dupliqué.

## Migration 

Pour migrer progressivement vers cette nouvelle architecture:

1. Commencer par remplacer certains appels directs au générateur par des appels au ViewModel.
2. Remplacer progressivement les liaisons de propriétés dans les composants QML pour utiliser le modèle centralisé.
3. Éliminer les calculs redondants dans les composants QML en les remplaçant par des accès aux propriétés calculées du modèle.

Vous pouvez effectuer cette migration module par module, sans avoir à réécrire toute l'application d'un coup.
