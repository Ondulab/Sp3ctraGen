# Adaptation dynamique de l'espacement entre bins

## Contexte

Dans les versions précédentes de Sp3ctraGen, le paramètre "bins par seconde" (bps) affectait directement la largeur du segment audio affiché. En effet, plus le nombre de bins par seconde était élevé (mode Temporal), plus le spectrogramme était large pour une même durée audio. Inversement, un nombre de bins par seconde plus faible (mode Spectral) réduisait la largeur du spectrogramme.

Cette relation entre la résolution et la largeur était problématique, car l'utilisateur devait faire un compromis entre la qualité d'analyse souhaitée et l'échelle du spectrogramme.

## Objectif

L'objectif de cette modification est de découpler complètement la résolution de la largeur du segment audio. 

**Principe fondamental :** 
- Seule la vitesse d'écriture (WS) devrait influencer la largeur physique du segment audio
- Le paramètre de résolution (bins/s) devrait uniquement affecter la qualité d'analyse, pas les dimensions

## Implémentation

La solution implémentée est une adaptation dynamique de l'espacement entre les bins en fonction de la résolution choisie.

### Formule clé

L'espacement entre bins est maintenant calculé comme suit :

```
seconds_per_window = 1.0 / binsPerSecond
cm_per_window = seconds_per_window * writingSpeed
pixels_per_window = cm_per_window / PIXELS_TO_CM  // Pour rendu PNG
// ou
points_per_window = cm_per_window * (POINTS_PER_INCH / 2.54)  // Pour rendu PDF
```

### Modifications techniques

1. **Rendu PNG (spectral_raster.c)**:
   - L'espacement entre bins est adapté dynamiquement pour que la largeur totale soit déterminée uniquement par la vitesse d'écriture
   - Chaque bin représente maintenant une durée fixe (1/bps secondes), mais sa largeur en pixels varie en fonction de la résolution

2. **Rendu PDF (spectral_vector.c)**:
   - Application du même principe avec adaptation aux unités PDF (points)
   - L'échelle cm/s est respectée dans le document final

3. **Traitement du signal**:
   - Le calcul de la FFT et l'analyse spectrale restent inchangés
   - La résolution temporelle et fréquentielle dépendent toujours du paramètre bins/s

## Avantages

1. **Cohérence de l'échelle** : La relation "durée audio = largeur papier / vitesse d'écriture" est désormais strictement respectée, quelle que soit la résolution choisie

2. **Facilité d'utilisation** : L'utilisateur peut ajuster la résolution selon ses besoins d'analyse sans affecter la mise en page

3. **Qualité d'impression** : Le spectrogramme conserve une largeur physique constante, garantissant une impression de qualité optimale

## Impact sur l'interface utilisateur

Cette modification est entièrement transparente pour l'utilisateur. L'interface reste inchangée, mais le comportement est maintenant plus intuitif :

- Le curseur de résolution modifie uniquement la qualité d'analyse (résolution temporelle vs. fréquentielle)
- La vitesse d'écriture est le seul paramètre qui détermine l'échelle horizontale du spectrogramme

## Note technique

Dans l'implémentation, nous avons choisi d'adapter l'espacement entre bins plutôt que de modifier la structure des données du spectrogramme. Cette approche a l'avantage de nécessiter des changements minimaux dans le code existant, tout en obtenant le comportement souhaité.

```c
// Ancien code
double window_width = spectro_width / (double)visible_windows;

// Nouveau code
double seconds_per_window = 1.0 / binsPerSecond;
double cm_per_window = seconds_per_window * writingSpeed;
double pixels_per_window = cm_per_window / PIXELS_TO_CM;
double window_width = pixels_per_window;
```

## Conclusion

Cette adaptation dynamique de l'espacement entre bins permet une séparation claire entre la qualité d'analyse (bins/s) et l'échelle physique du spectrogramme (vitesse d'écriture), offrant ainsi une expérience utilisateur plus cohérente et intuitive.
