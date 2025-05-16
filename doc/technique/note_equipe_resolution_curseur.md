# Note à l'équipe : Implémentation du curseur de résolution adaptative

## Résumé des changements

Nous avons implémenté un nouveau système de génération adaptative dans Sp3ctraGen qui utilise un curseur unique pour contrôler le compromis entre résolution temporelle et fréquentielle. Cette implémentation simplifie l'interface utilisateur tout en offrant des résultats plus cohérents et adaptés aux contraintes physiques d'impression.

## Impact sur le code existant

Les modifications apportées préservent une rétrocompatibilité avec le code existant tout en introduisant un nouveau mécanisme de calcul des paramètres :

1. La structure de données existante `SpectrogramSettings` est maintenue
2. Les presets d'overlap sont conservés, bien que leur utilisation soit désormais dérivée du curseur
3. Les calculs internes ont été refaits pour s'adapter automatiquement au taux d'échantillonnage

## Fichiers modifiés

- `src/SpectrogramParametersModel.cpp` : Nouvelle logique de calcul des paramètres
- `src/spectral_fft.c` : Adaptation de la génération FFT
- `include/SharedConstants.h` : Nouvelles constantes pour le système adaptatif
- `qml/sections/SpectrogramParameters.qml` : Interface utilisateur améliorée

## Documentation ajoutée

Pour comprendre l'implémentation en détail, plusieurs documents techniques ont été créés :

1. `doc/technique/implementation_mode_resolution_curseur.md`
2. `doc/technique/adaptation_dynamique_au_sample_rate.md`
3. `doc/guide_utilisateur/utilisation_curseur_resolution.md`
4. `doc/technique/resume_implementation_resolution_adaptative.md`

## Comportement attendu

- La position **gauche** du curseur (0.0) privilégie les détails temporels
- La position **centrale** du curseur (0.5) offre un compromis équilibré
- La position **droite** du curseur (1.0) privilégie les détails fréquentiels

## Tests et validation

Pour tester les changements :

1. Utilisez le script `scripts/compile_resolution_update.sh` pour compiler
2. Exécutez `scripts/test_resolution_curseur.sh` pour générer des spectrogrammes de test
3. Vérifiez que les résultats correspondent au comportement attendu décrit dans la documentation

## Points importants à noter

1. **Préservation de la vitesse d'écriture** : La WS reste une contrainte stricte et les paramètres s'adaptent en fonction
2. **Adaptation au taux d'échantillonnage** : Les paramètres s'ajustent automatiquement selon le taux d'échantillonnage du fichier
3. **Calcul inversé de l'overlap** : L'overlap est maintenant calculé dynamiquement à partir de la taille FFT et du hopSize, plutôt que fixé par des presets

## Prochaines étapes

- Optimisation des valeurs de référence pour différents types d'audio
- Évaluation des performances avec différents taux d'échantillonnage
- Ajout éventuel de presets pour des cas d'usage spécifiques (parole, musique, etc.)

Merci de vérifier ces modifications et de nous faire part de vos retours.
