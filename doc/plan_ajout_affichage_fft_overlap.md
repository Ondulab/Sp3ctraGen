# Plan d'ajout de l'affichage de la taille FFT et de l'Overlap

## Contexte
Suite à la suppression des fonctionnalités obsolètes (bins per second et overlap presets), nous avons besoin d'ajouter l'affichage des valeurs calculées de la taille FFT et de l'overlap dans l'interface utilisateur. Ces valeurs sont calculées par le backend mais ne sont pas visibles pour l'utilisateur.

## Objectifs
1. Afficher la taille FFT calculée
2. Afficher la valeur d'overlap calculée
3. Mettre ces informations dans la section des paramètres du spectrogramme, sous l'affichage des bins/s

## Modifications nécessaires

### 1. Mise à jour de SpectrogramParameters.qml

#### Ajouter de nouvelles propriétés
```qml
// Propriétés pour afficher les valeurs calculées par le backend
property int calculatedFftSize: 4096   // Valeur par défaut
property double calculatedOverlap: 0.85 // Valeur par défaut
```

#### Ajouter l'affichage des valeurs dans la grille existante
Après l'affichage de Bins/s et avant Audio Duration, ajouter :

```qml
// Taille FFT calculée
ThemedLabel {
    text: "FFT Size:"
    font.pixelSize: smallFontSize
    horizontalAlignment: Text.AlignRight
    Layout.alignment: Qt.AlignRight
    Layout.preferredWidth: parent.width / 2 - 10
}
ThemedLabel {
    id: fftSizeLabel
    text: calculatedFftSize.toString()
    font.pixelSize: smallFontSize
    Layout.alignment: Qt.AlignLeft
    Layout.preferredWidth: parent.width / 2 - 10
}

// Overlap calculé
ThemedLabel {
    text: "Overlap:"
    font.pixelSize: smallFontSize
    horizontalAlignment: Text.AlignRight
    Layout.alignment: Qt.AlignRight
    Layout.preferredWidth: parent.width / 2 - 10
}
ThemedLabel {
    id: overlapLabel
    text: calculatedOverlap.toFixed(3)
    font.pixelSize: smallFontSize
    Layout.alignment: Qt.AlignLeft
    Layout.preferredWidth: parent.width / 2 - 10
}
```

#### Mettre à jour la méthode de mise à jour des paramètres calculés
```qml
// Méthode pour mettre à jour les valeurs affichées
function updateCalculatedParameters() {
    // Mettre à jour l'affichage de la durée audio
    audioDurationLabel.text = audioDuration.toFixed(2);
    
    // Mettre à jour l'affichage des bins/s
    binsPerSecondValueLabel.text = binsPerSecondValue.toFixed(1);
    
    // Mettre à jour l'affichage de la taille FFT et de l'overlap
    fftSizeLabel.text = calculatedFftSize.toString();
    overlapLabel.text = calculatedOverlap.toFixed(3);
}
```

#### Modifier la gestion du changement de valeur du curseur
Dans le handler `onValueChanged` du resolutionSlider, ajouter :

```qml
// Calculer l'overlap directement
calculatedOverlap = generator.calculateOverlapFromSlider(value);

// Pour la FFT, nous devons utiliser le signal fftParametersCalculated
// qui est émis par le backend quand les paramètres changent
```

#### Ajouter la connexion au signal fftParametersCalculated

Ajouter une connexion au signal fftParametersCalculated dans le Component.onCompleted :

```qml
Component.onCompleted: {
    // Calculer les valeurs initiales
    if (generator) {
        binsPerSecondValue = generator.calculateBpsFromSlider(resolutionSlider.value, writingSpeedNumeric);
        audioDuration = generator.calculateAudioDuration();
        isResolutionLimited = generator.isResolutionLimited();
        
        // Connexion au signal de mise à jour des paramètres FFT
        generator.fftParametersCalculated.connect(function(fftSize, overlap, bps) {
            calculatedFftSize = fftSize;
            calculatedOverlap = overlap;
            updateCalculatedParameters();
        });
        
        updateCalculatedParameters();
    } else {
        console.warn("Generator not available during initialization");
        // Valeurs par défaut
        binsPerSecondValue = 150.0;
        audioDuration = 2.625; // 21cm / 8cm/s
        calculatedFftSize = 4096;
        calculatedOverlap = 0.85;
        isResolutionLimited = false;
    }
}
```

### 2. Vérifier les méthodes nécessaires dans le backend

S'assurer que les méthodes suivantes existent dans la classe SpectrogramGenerator :
- `calculateOverlapFromSlider(value)` : déjà présente
- `calculateFftSize(value, writingSpeed)` : à vérifier, pourrait nécessiter une implémentation

### 3. Modification dans le backend SpectrogramGenerator

Il n'est pas nécessaire d'ajouter une méthode `calculateFftSize` au SpectrogramGenerator car celui-ci émet déjà un signal `fftParametersCalculated` avec les trois valeurs importantes :

```cpp
void fftParametersCalculated(int calculatedFftSize, double effectiveOverlap, double binsPerSecond);
```

Ce signal doit être émis à chaque fois que :
1. Le curseur de résolution change
2. La vitesse d'écriture change
3. Le format de page change

Nous devons nous assurer que le signal est correctement émis dans ces cas.

## Plan de test
1. Vérifier que les valeurs affichées correspondent aux calculs attendus
2. Vérifier que les valeurs se mettent à jour correctement lorsque l'utilisateur déplace le curseur
3. Vérifier que les valeurs se mettent à jour lorsque la vitesse d'écriture change
4. Vérifier que le signal fftParametersCalculated est bien émis par le backend dans tous les cas nécessaires

## Impact sur l'utilisateur
L'utilisateur pourra voir les valeurs techniques calculées par le backend, ce qui offre une meilleure compréhension du comportement du système et facilite les diagnostics en cas de problème.