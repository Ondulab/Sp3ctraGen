# Adaptation dynamique des bins/s et optimisation de la résolution

## Problématique initiale

Le système actuel de génération de spectrogramme présentait plusieurs problèmes :

1. La relation entre la résolution du spectrogramme et la résolution d'impression n'était pas optimale
2. Le contrôle de la résolution temporelle vs. spectrale n'était pas intuitif pour l'utilisateur
3. La durée du spectrogramme n'était pas strictement liée à la relation `largeur papier / vitesse d'écriture`
4. Des calculs inutiles pouvaient être effectués en dépassant la résolution physique du support

## Solution implémentée

### Nouveau calcul automatique des bins/s

La nouvelle implémentation garantit que les bins/s sont automatiquement calculés de manière optimale en fonction de la résolution d'impression et de la vitesse d'écriture, selon la formule :

```
bins_per_second = (800 dpi / 2.54 cm/inch) * writeSpeed
```

Cette formule traduit directement la résolution physique du support (800 dpi) en résolution temporelle, garantissant qu'on ne calcule pas plus de bins que ce qui peut être physiquement imprimé.

### Utilisation intuitive du curseur Resolution

Le curseur Resolution contrôle désormais uniquement le compromis entre résolution temporelle et spectrale via l'overlap :

- **Position Temporal (0.0)** : Faible overlap (0.30) -> Meilleure résolution temporelle
- **Position Balanced (0.5)** : Overlap moyen (0.75) -> Compromis temps/fréquence
- **Position Spectral (1.0)** : Fort overlap (0.92) -> Meilleure résolution fréquentielle

### Synchronisation automatique du préréglage d'overlap

Le préréglage d'overlap est maintenant automatiquement déterminé en fonction de la position du curseur :
- 0.0-0.33 → Preset Low (overlap = 0.30)
- 0.33-0.67 → Preset Medium (overlap = 0.75)
- 0.67-1.0 → Preset High (overlap = 0.92)

### Garantie de la relation durée/vitesse

Cette nouvelle conception garantit strictement que :
```
durée = largeur papier (cm) / writeSpeed (cm/s)
```

Ce qui permet à l'utilisateur de comprendre et prédire exactement la longueur du spectrogramme généré.

## Flux de calcul

1. L'utilisateur définit une vitesse d'écriture en cm/s
2. Le système calcule automatiquement le bins/s optimal en fonction de la résolution d'impression
3. L'utilisateur définit la préférence temporelle/spectrale avec le curseur Resolution 
4. Le système applique l'overlap correspondant au choix de l'utilisateur
5. La FFT size est calculée en fonction de tous ces paramètres pour obtenir le résultat souhaité

## Avantages de la nouvelle approche

1. **Optimisation des ressources** : Les calculs sont limités à la résolution physique réelle
2. **Contrôle intuitif** : L'utilisateur peut facilement choisir entre résolution temporelle et spectrale
3. **Prédictibilité** : La durée du spectrogramme dépend uniquement de la vitesse d'écriture et du format papier
4. **Uniformisation** : Les valeurs d'overlap sont cohérentes dans tout le code

## Implémentation technique

Les modifications ont été effectuées dans les fichiers suivants :
- `SpectrogramSettingsCpp.cpp` : Nouveaux calculs pour bins/s et overlap
- `SpectrogramGenerator.cpp` : Synchronisation du curseur avec le préréglage d'overlap
- `SharedConstants.h` : Harmonisation des valeurs d'overlap

### Valeurs critiques

Valeurs d'overlap pour les différentes positions du curseur :
- Temporal (0.0) : 0.30
- Balanced (0.5) : 0.75
- Spectral (1.0) : 0.92

Ces valeurs offrent un bon compromis entre résolution temporelle (faible overlap) et résolution spectrale (fort overlap).

## Notes d'utilisation

1. L'utilisateur définit d'abord sa vitesse d'écriture en fonction de ses besoins de durée
2. Il choisit ensuite sa préférence temporelle/spectrale avec le curseur Resolution
3. Le système s'occupe automatiquement d'optimiser tous les autres paramètres

Ce nouveau système simplifie considérablement l'utilisation tout en garantissant une utilisation optimale des ressources.
