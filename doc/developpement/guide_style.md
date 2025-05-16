# Guide de style et standards de développement

Ce document définit les standards de développement et le style de code à respecter pour contribuer au projet Sp3ctraGen.

## Principes généraux

Le code de Sp3ctraGen suit plusieurs principes clés :

1. **Clarté** : Le code doit être facilement compréhensible et bien documenté
2. **Cohérence** : Les conventions doivent être appliquées uniformément
3. **Performance** : Le code doit être optimisé pour les opérations critiques
4. **Maintenabilité** : La conception doit faciliter les évolutions futures
5. **Séparation des préoccupations** : Respecter l'architecture en trois couches

## Conventions linguistiques

### Langue du code source

Tout le code source (noms de variables, fonctions, commentaires, etc.) doit être **exclusivement en anglais**. Cette règle s'applique à :

- Noms de variables, fonctions, classes, méthodes
- Commentaires et documentation dans le code
- Messages de log et messages d'erreur
- Chaînes de caractères destinées aux développeurs

### Langue de la documentation

La documentation destinée aux utilisateurs et aux développeurs est rédigée en **français**, dans un style clair et professionnel.

### Messages de commit

Les messages de commit doivent :
- Être rédigés **exclusivement en anglais**
- Suivre la convention [Conventional Commits](https://www.conventionalcommits.org/)
- Être concis mais descriptifs

Exemples :
```
feat: add support for cursor resolution mode
fix: resolve audio file loading issue with 96kHz files
refactor: simplify FFT calculation code
docs: update bins per second documentation
```

## Standards de code par langage

### C

#### Style de nommage

- **Fonctions** : snake_case (ex: `calculate_fft_size`)
- **Variables** : snake_case (ex: `sample_rate`, `fft_size`)
- **Constantes** : UPPER_SNAKE_CASE (ex: `MAX_FFT_SIZE`)
- **Types personnalisés** : PascalCase (ex: `SpectrogramSettings`)

#### Organisation du code

- Une fonction ne doit pas dépasser 50 lignes (sauf exception justifiée)
- Chaque fonction doit avoir un objectif unique et clairement défini
- Les fonctions apparentées doivent être regroupées
- Les déclarations de variables doivent être placées au début des blocs

#### Commentaires

- Chaque fichier doit commencer par un en-tête décrivant son contenu
- Chaque fonction doit être précédée d'un commentaire décrivant :
  - Son objectif
  - Ses paramètres
  - Sa valeur de retour
  - Ses effets de bord éventuels

Exemple :
```c
/**
 * Calculates the optimal FFT size based on the requested bins per second.
 *
 * @param sample_rate The audio sample rate in Hz
 * @param bins_per_second The desired bins per second
 * @param overlap The window overlap factor (0.0-1.0)
 * @return The optimal FFT size (always a power of 2)
 */
int calculate_optimal_fft_size(int sample_rate, double bins_per_second, double overlap) {
    // Implementation
}
```

### C++

#### Style de nommage

- **Classes** : PascalCase (ex: `SpectrogramGenerator`)
- **Méthodes** : camelCase (ex: `generateSpectrogram`)
- **Variables membres** : m_camelCase (ex: `m_settings`, `m_inputFile`)
- **Variables locales** : camelCase (ex: `inputFile`, `outputFormat`)
- **Constantes** : UPPER_SNAKE_CASE (ex: `MAX_THREADS`)

#### Organisation des classes

- Les déclarations doivent suivre l'ordre : public, protected, private
- Les méthodes associées doivent être regroupées
- Préférer les méthodes courtes et ciblées
- Utiliser les commentaires `// MARK: - Section name` pour organiser de grandes classes

#### Commentaires et documentation

- Chaque classe doit avoir un commentaire d'en-tête décrivant son rôle
- Les méthodes publiques doivent être documentées avec leurs paramètres et valeurs de retour
- Utiliser les tags Qt pour la documentation compatible avec QDoc

Exemple :
```cpp
/**
 * @class SpectrogramGenerator
 * @brief Main class for generating spectrograms from audio files.
 *
 * This class coordinates the generation process and handles the interaction
 * between the QML interface and the C processing engine.
 */
class SpectrogramGenerator : public QObject {
    Q_OBJECT
    // ...
};
```

### QML

#### Style de nommage

- **Composants** : PascalCase (ex: `ParameterField`)
- **Propriétés** : camelCase (ex: `minValue`, `isEnabled`)
- **Fonctions** : camelCase (ex: `calculateValue`)
- **IDs** : camelCase (ex: `spectrogramPreview`)

#### Organisation du code

- Les propriétés doivent être déclarées au début du composant
- Les signaux doivent suivre les propriétés
- Les fonctions doivent être placées après les gestionnaires de signaux
- Utiliser des composants réutilisables pour le code partagé

#### Structure des fichiers QML

- Chaque composant réutilisable doit être dans son propre fichier
- Les composants spécifiques à une section doivent être regroupés dans un sous-dossier
- Les styles doivent être définis dans un module séparé

#### Commentaires

- Utiliser `//` pour les commentaires simples
- Utiliser `/* */` pour les blocs de commentaires
- Documenter clairement l'objectif des composants complexes et leurs paramètres

## Structure des fichiers et organisation

### Structure des répertoires

- `src/` : Code source C++
- `include/` : Fichiers d'en-tête C++
- `qml/` : Fichiers QML pour l'interface
  - `components/` : Composants réutilisables
  - `sections/` : Sections principales de l'interface
  - `styles/` : Définitions de styles
- `scripts/` : Scripts utilitaires
- `doc/` : Documentation

### Conventions de nommage des fichiers

- Fichiers C : snake_case (ex: `spectral_fft.c`)
- Fichiers C++ : PascalCase (ex: `SpectrogramGenerator.cpp`)
- Fichiers d'en-tête C++ : PascalCase (ex: `VisualizationStrategy.h`)
- Fichiers QML : PascalCase (ex: `ParameterField.qml`)

## Bonnes pratiques

### Gestion de la mémoire

- Éviter les fuites de mémoire en libérant toutes les ressources allouées
- Utiliser des smart pointers en C++ quand c'est possible
- Dans le code C, respecter le pattern d'allocation/libération cohérent

### Gestion des erreurs

- Vérifier systématiquement les valeurs de retour des fonctions
- Utiliser des codes d'erreur explicites pour les fonctions C
- Utiliser des exceptions uniquement pour les conditions exceptionnelles en C++
- Fournir des messages d'erreur clairs et utiles

### Multithreading

- Identifer clairement le code thread-safe
- Protéger les données partagées avec des mutex
- Éviter les deadlocks en maintenant un ordre cohérent d'acquisition des verrous
- Utiliser les primitives Qt (QMutex, QThread) plutôt que les primitives natives

### Tests

- Écrire des tests unitaires pour les fonctions critiques
- S'assurer que les tests couvrent les cas limites et les conditions d'erreur
- Les tests doivent être indépendants et pouvoir s'exécuter dans n'importe quel ordre

## Processus de développement

### Workflow Git

1. Créer une branche pour chaque fonctionnalité ou correction
2. Faire des commits atomiques et bien documentés
3. Tester avant de soumettre une pull request
4. Faire réviser le code par au moins un autre développeur

### Structure d'une Pull Request

Une bonne pull request doit inclure :

1. Une description claire de la modification
2. La raison de la modification
3. Les tests effectués
4. Les captures d'écran/démonstrations si pertinent
5. Les références aux issues concernées

### Revue de code

Lors des revues de code, vérifier :

1. La conformité aux standards de code
2. La clarté et la lisibilité
3. La performance et l'optimisation
4. La maintenabilité et l'extensibilité
5. La présence de tests appropriés

## Utilisation des bibliothèques externes

### Bibliothèques approuvées

Les bibliothèques suivantes sont approuvées pour utilisation dans le projet :

- **Qt** : Pour l'interface utilisateur et les fonctionnalités cross-platform
- **FFTW** : Pour les calculs de transformée de Fourier
- **Cairo** : Pour le rendu graphique
- **libsndfile** : Pour le traitement des fichiers audio

### Ajout de nouvelles dépendances

Avant d'ajouter une nouvelle dépendance :

1. Discuter avec l'équipe de la nécessité de cette dépendance
2. Évaluer son impact sur la portabilité et la maintenance
3. Vérifier la licence et la compatibilité avec le projet
4. S'assurer qu'elle est activement maintenue

## Conventions de documentation

### Documentation du code

- Utiliser Doxygen/QDoc pour la documentation du code C++
- Documenter tous les aspects non évidents du code
- Inclure des exemples pour les fonctions complexes

### Documentation utilisateur

- Maintenir la documentation utilisateur à jour avec les nouvelles fonctionnalités
- Utiliser un langage clair et accessible
- Inclure des captures d'écran et des exemples concrets

## Conclusion

Ce guide vise à assurer la cohérence et la qualité du code de Sp3ctraGen. En suivant ces standards, nous créons une base de code plus facile à comprendre, à maintenir et à faire évoluer.

Les exceptions à ces règles doivent être rares et clairement justifiées dans le code ou les commentaires.
