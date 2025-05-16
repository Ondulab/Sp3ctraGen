# Guide de démarrage rapide de Sp3ctraGen

Ce guide vous aidera à prendre en main rapidement l'application Sp3ctraGen et à générer votre premier spectrogramme de qualité.

## Premier lancement

Après avoir [installé Sp3ctraGen](installation.md), lancez l'application depuis le dossier Applications ou via Launchpad. L'interface principale se compose de plusieurs sections :

![Interface principale](../images/interface_principale.png)

1. **Section Fichier** : Sélection des fichiers d'entrée/sortie
2. **Paramètres du spectrogramme** : Configuration des paramètres d'analyse
3. **Paramètres de filtrage** : Options de filtrage du signal
4. **Format de sortie** : Choix du format et des dimensions
5. **Prévisualisation** : Aperçu du spectrogramme
6. **Forme d'onde audio** : Visualisation du signal temporel

## Générer votre premier spectrogramme

### Étape 1 : Sélectionner un fichier audio

1. Dans la section "Fichier", cliquez sur le bouton "Ouvrir" à côté du champ "Fichier d'entrée"
2. Naviguez et sélectionnez un fichier audio au format WAV
3. Le fichier sélectionné apparaîtra dans le champ "Fichier d'entrée"
4. La forme d'onde audio s'affichera automatiquement en bas de l'interface

### Étape 2 : Définir le fichier de sortie

1. Cliquez sur le bouton "Parcourir" à côté du champ "Fichier de sortie"
2. Choisissez l'emplacement où vous souhaitez enregistrer le spectrogramme
3. Entrez un nom de fichier (sans extension)
4. L'extension sera automatiquement ajoutée en fonction du format sélectionné dans la section "Format de sortie"

### Étape 3 : Configurer les paramètres de base

Pour un premier essai, les paramètres par défaut sont généralement appropriés :

- **Bins par seconde** : 150 (valeur par défaut équilibrée)
- **Plage de fréquences** : 65 Hz à 16640 Hz (couvre l'essentiel du spectre audible)
- **Plage dynamique** : 60 dB (valeur standard)

Ces paramètres offrent un bon équilibre entre résolution temporelle et fréquentielle.

### Étape 4 : Choisir le format de sortie

1. Dans la section "Format de sortie", sélectionnez :
   - Format PNG (raster) pour une utilisation numérique
   - Format PDF (vectoriel) pour l'impression
   
2. Sélectionnez le format de page :
   - A4 portrait (par défaut)
   - A3 paysage (pour des fichiers audio plus longs)

3. La vitesse d'écriture par défaut (8.0 cm/s) convient pour la plupart des analyses générales

### Étape 5 : Générer le spectrogramme

1. Cliquez sur le bouton "Générer" en bas de l'interface
2. Une barre de progression s'affichera pendant le traitement
3. Une fois terminé, un message de confirmation apparaîtra
4. Le spectrogramme généré sera enregistré à l'emplacement spécifié

## Comprendre la prévisualisation

La prévisualisation vous permet d'avoir un aperçu du spectrogramme avant la génération finale :

1. Après avoir chargé un fichier audio, la prévisualisation s'affiche automatiquement
2. Modifiez les paramètres pour voir leur effet en temps réel
3. L'image prévisualisée est de résolution inférieure à la sortie finale
4. Utilisez cette prévisualisation pour affiner vos paramètres avant la génération finale

## Ajuster les paramètres pour des besoins spécifiques

### Pour l'analyse vocale

1. Réglez la plage de fréquences sur 80-8000 Hz
2. Utilisez un bins/s de 150-200
3. Activez l'amplification des hautes fréquences

### Pour l'analyse musicale

1. Étendez la plage de fréquences à 20-20000 Hz
2. Utilisez un bins/s de 100-150
3. Ajustez la correction gamma à 0.7-0.8

### Pour les fichiers très longs

1. Sélectionnez le format A3 paysage
2. Augmentez la vitesse d'écriture à 12-15 cm/s pour afficher une durée plus longue
3. Utilisez un bins/s plus élevé (200-250) pour maintenir une résolution temporelle suffisante

## Utilisation de la forme d'onde audio

La visualisation de la forme d'onde vous aide à naviguer dans le fichier audio :

1. La forme d'onde complète du fichier est affichée
2. Les zones plus claires correspondent à des volumes plus élevés
3. Vous pouvez zoomer en utilisant la molette de la souris tout en survolant la forme d'onde
4. Utilisez cette visualisation pour identifier les sections d'intérêt de votre fichier audio

## Optimisation des résultats d'impression

Pour obtenir des spectrogrammes optimisés pour l'impression :

1. Sélectionnez le format PDF vectoriel
2. Utilisez une résolution de 800 DPI (définie automatiquement)
3. Augmentez légèrement le contraste (environ 2.0) pour une meilleure lisibilité à l'impression
4. Ajustez les marges selon vos besoins d'impression ou de reliure

## Conseils et astuces

### Améliorer la qualité de l'analyse

- Commencez toujours avec les paramètres par défaut, puis ajustez progressivement
- Utilisez des valeurs de bins/s plus faibles pour une meilleure résolution fréquentielle
- Utilisez des valeurs de bins/s plus élevées pour une meilleure résolution temporelle
- Activez l'amplification des hautes fréquences pour faire ressortir les détails subtils

### Gain de temps

- Utilisez la prévisualisation pour tester rapidement différents paramètres
- Enregistrez vos configurations préférées pour différents types d'analyses
- Pour des tests rapides, commencez avec un format PNG avant de générer le PDF final

### Résolution des problèmes

- Si le spectrogramme semble trop sombre, augmentez la plage dynamique ou réduisez le contraste
- Si certaines fréquences sont difficiles à distinguer, ajustez les paramètres de filtrage
- Si l'application semble lente avec de grands fichiers, essayez de limiter la plage de fréquences

## Étapes suivantes

Maintenant que vous savez comment générer un spectrogramme de base, vous pouvez :

1. Explorer les [fonctionnalités avancées](fonctionnalites.md) de l'application
2. Apprendre à utiliser le [mode résolution curseur](fonctionnalites.md#utilisation-du-mode-résolution-curseur) pour des analyses plus précises
3. Expérimenter avec les [paramètres de filtrage](fonctionnalites.md#paramètres-de-filtrage) pour optimiser vos analyses

Pour une description complète de toutes les fonctionnalités disponibles, consultez la [documentation des fonctionnalités](fonctionnalites.md).
