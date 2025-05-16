# Correction du problème de mise à jour du format de page

## Problème identifié

Lorsque l'utilisateur changeait le format de page (de A4 à A3 ou inversement), deux problèmes se produisaient :

1. Une erreur JavaScript apparaissait dans la console : `TypeError: Property 'createSettings' of object SpectrogramGenerator_QML_xxx is not a function`
2. Bien que la durée audio soit correctement calculée côté C++ (comme le montrent les logs), elle n'était pas correctement affichée dans l'interface utilisateur

## Cause du problème

1. Le code QML tentait d'appeler directement la méthode privée `createSettings` du générateur de spectrogrammes, qui n'est pas accessible depuis QML
2. Bien que nous ayons mis en place un mécanisme de mise à jour de l'interface (`forceUpdateDisplay()`), celui-ci n'était pas suffisamment robuste pour garantir la mise à jour des valeurs d'affichage

## Solution implémentée

### 1. Correction de l'accès à la méthode privée

La solution initiale consistait à exposer une méthode publique `updatePageFormat` dans `SpectrogramGenerator` via la macro `Q_INVOKABLE`. Cette méthode sert de wrapper pour appeler la méthode privée `createSettings`.

```cpp
// Dans spectrogramgenerator.h
Q_INVOKABLE double updatePageFormat(int pageFormat, ...);

// Dans spectrogramgenerator.cpp 
double SpectrogramGenerator::updatePageFormat(int pageFormat, ...) {
    qDebug() << "SpectrogramGenerator::updatePageFormat - Mise à jour du format de page:" << pageFormat;
    
    // Création des paramètres
    SpectrogramSettings settings;
    settings.m_minFreq = minFreq;
    settings.m_maxFreq = maxFreq;
    
    // Appel à la méthode privée createSettings
    createSettings(settings, pageFormat, ...);
    
    // Calcul et retour de la durée audio
    double audioDuration = calculateAudioDuration();
    return audioDuration;
}
```

### 2. Amélioration du mécanisme de mise à jour de l'interface

L'appel à `forceUpdateDisplay()` était correct dans le code QML, mais l'implémentation de cette méthode dans `SpectrogramParameters.qml` n'était pas suffisamment robuste.

Nous avons amélioré ce mécanisme en :

1. Ajoutant un Timer QML dans `SpectrogramParameters.qml` qui force le rafraîchissement complet des valeurs affichées
2. Ajoutant des logs plus détaillés pour confirmer que les valeurs sont correctement mises à jour
3. S'assurant que la propriété `audioDuration` est explicitement mise à jour avant d'appeler `forceUpdateDisplay()`

```qml
// Dans SpectrogramParameters.qml
// Timer pour forcer le rafraîchissement de l'interface
Timer {
    id: refreshTimer
    interval: 100
    repeat: false
    onTriggered: {
        // Force un rafraîchissement complet des valeurs
        audioDurationLabel.text = "";
        audioDurationLabel.text = audioDuration.toFixed(2);
        
        binsPerSecondValueLabel.text = "";
        binsPerSecondValueLabel.text = binsPerSecondValue.toFixed(1);
        
        fftSizeLabel.text = "";
        fftSizeLabel.text = calculatedFftSize.toString();
        
        overlapLabel.text = "";
        overlapLabel.text = calculatedOverlap.toFixed(3);
    }
}

// Fonction publique pour forcer une mise à jour externe
function forceUpdateDisplay() {
    updateCalculatedParameters();
    // Déclencher le timer pour forcer un rafraîchissement complet
    refreshTimer.restart();
}
```

### 3. Amélioration de l'appel depuis main.qml

Dans le gestionnaire `onFormatChanged` du composant `OutputFormat` :

```qml
onFormatChanged: {
    // Mise à jour des dépendances lorsque le format change
    audioWaveformSection.pageFormat = pageFormat
    
    // Mettre à jour le format de page dans le générateur (crucial)
    // Utiliser la nouvelle méthode updatePageFormat au lieu de la méthode privée createSettings
    var newAudioDuration = generator.updatePageFormat(
        pageFormat, // nouveau format de page
        parseFloat(bottomMargin),
        parseFloat(spectroHeight),
        spectrogramParametersSection.writingSpeedNumeric,
        spectrogramParametersSection.minFreqNumeric,
        spectrogramParametersSection.maxFreqNumeric,
        waveformProvider ? waveformProvider.getSampleRate() : 44100
    );
    
    // Mettre à jour la durée audio dans tous les composants qui en ont besoin
    if (spectrogramParametersSection && audioWaveformSection && waveformProvider && 
        waveformProvider.getTotalDuration() > 0) {
        
        // Utiliser directement la valeur retournée par updatePageFormat
        // au lieu de la recalculer
        console.log("Format de page changé: " + pageFormat + 
                  ", nouvelle durée audio: " + newAudioDuration.toFixed(2) + "s" +
                  ", writingSpeed: " + spectrogramParametersSection.writingSpeedNumeric + " cm/s");
        
        // IMPORTANT : Forcer la mise à jour de la durée audio
        spectrogramParametersSection.audioDuration = newAudioDuration;
        
        // Déclencher le timer pour garantir la mise à jour de l'interface
        spectrogramParametersSection.forceUpdateDisplay();
        
        // Mettre à jour le segment audio dans la section de forme d'onde
        audioWaveformSection.updateSegmentDisplay(audioWaveformSection.cursorPosition);
    }
}
```

## Résultats

Les modifications apportées résolvent les deux problèmes identifiés :
1. L'erreur JavaScript a disparu car nous utilisons maintenant une méthode correctement exposée à QML
2. La durée audio est correctement calculée et affichée dans l'interface utilisateur

Les logs de l'application montrent que la durée audio est calculée correctement (5.25s pour le format A3 avec une vitesse d'écriture de 8 cm/s) et le mécanisme de mise à jour forcée garantit que cette valeur est correctement affichée dans l'interface.
