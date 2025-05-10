# Guide de style de développement

## Introduction

Ce document formalise les règles et conventions techniques applicables à l'ensemble des projets de l'équipe. L'objectif est de réduire la dette technique, fluidifier les relectures de code, et garantir la maintenabilité à long terme.

## 1. Conventions de codage

### 1.1. Indentation et formatage

#### Règles générales

- **Indentation**: 4 espaces (pas de tabulations)
- **Longueur de ligne**: Maximum 100 caractères
- **Encodage**: UTF-8
- **Fins de ligne**: LF (Unix)

#### C++

- **Accolades**: Nouvelle ligne pour les accolades ouvrantes
  ```cpp
  void maFonction()
  {
      // Code
  }
  ```
- **Espacement**: Un espace après les mots-clés, avant et après les opérateurs
  ```cpp
  if (condition) {
      a = b + c;
  }
  ```
- **Parenthèses**: Pas d'espace après une parenthèse ouvrante ou avant une parenthèse fermante
  ```cpp
  fonction(argument1, argument2);
  ```

#### C

- **Accolades**: Même ligne pour les accolades ouvrantes
  ```c
  void ma_fonction() {
      // Code
  }
  ```
- **Espacement**: Même règles qu'en C++
- **Parenthèses**: Même règles qu'en C++

#### QML

- **Accolades**: Même ligne pour les accolades ouvrantes
  ```qml
  Rectangle {
      width: 100
      height: 100
  }
  ```
- **Espacement**: Un espace après les deux-points dans les déclarations de propriétés
  ```qml
  property int valeur: 42
  ```

### 1.2. Nommage

#### C++

- **Classes et structures**: PascalCase
  ```cpp
  class SpectrogramGenerator { ... }
  struct AudioData { ... }
  ```
- **Méthodes et fonctions**: camelCase
  ```cpp
  void generateSpectrogram() { ... }
  ```
- **Variables**: camelCase
  ```cpp
  int frameCount = 0;
  ```
- **Variables membres**: Préfixe `m_` suivi de camelCase
  ```cpp
  class MaClasse {
  private:
      int m_valeur;
  };
  ```
- **Variables statiques**: Préfixe `s_` suivi de camelCase
  ```cpp
  static int s_instanceCount = 0;
  ```
- **Constantes**: SNAKE_CASE_MAJUSCULE
  ```cpp
  const int MAX_BUFFER_SIZE = 1024;
  ```
- **Énumérations**: PascalCase pour le type, PascalCase pour les valeurs
  ```cpp
  enum class ColorFormat {
      RGB,
      RGBA,
      HSV
  };
  ```
- **Fichiers**: Même nom que la classe principale qu'ils contiennent
  ```
  SpectrogramGenerator.h
  SpectrogramGenerator.cpp
  ```

#### C

- **Fonctions**: snake_case
  ```c
  void apply_hann_window(double *buffer, int size) { ... }
  ```
- **Variables**: snake_case
  ```c
  int sample_rate = 44100;
  ```
- **Constantes et macros**: SNAKE_CASE_MAJUSCULE
  ```c
  #define MAX_FFT_SIZE 8192
  ```
- **Structures**: PascalCase
  ```c
  typedef struct {
      double *data;
      int num_samples;
  } AudioBuffer;
  ```
- **Fichiers**: snake_case
  ```
  spectral_fft.h
  spectral_fft.c
  ```

#### QML

- **Composants**: PascalCase
  ```
  AnimatedButton.qml
  ValidatedTextField.qml
  ```
- **IDs**: camelCase
  ```qml
  Rectangle {
      id: mainContainer
  }
  ```
- **Propriétés**: camelCase
  ```qml
  property bool isAnimating: false
  ```
- **Fonctions**: camelCase
  ```qml
  function startAnimation() { ... }
  ```
- **Signaux**: camelCase
  ```qml
  signal processingStarted()
  ```

### 1.3. Commentaires et documentation

#### C++

- **Documentation de classe**: Style Doxygen avec `/**` et `*/`
  ```cpp
  /**
   * @brief Classe pour générer des spectrogrammes
   * 
   * Cette classe fournit des méthodes pour générer des spectrogrammes
   * à partir de fichiers audio.
   */
  class SpectrogramGenerator { ... }
  ```
- **Documentation de méthode**: Style Doxygen
  ```cpp
  /**
   * @brief Génère un spectrogramme
   * 
   * @param settings Paramètres du spectrogramme
   * @param inputFile Fichier audio d'entrée
   * @param outputFile Fichier de sortie
   * @return true si la génération a réussi
   */
  bool generateSpectrogram(const SpectrogramSettings& settings,
                          const QString& inputFile,
                          const QString& outputFile);
  ```
- **Commentaires en ligne**: Utiliser `//` avec un espace après
  ```cpp
  int count = 0; // Initialisation du compteur
  ```
- **Commentaires de section**: Utiliser `//` avec des tirets pour créer une séparation visuelle
  ```cpp
  // ----- Gestion des ressources -----
  ```

#### C

- **Documentation de fonction**: Style bloc avec des sections
  ```c
  /*---------------------------------------------------------------------
   * apply_hann_window()
   *
   * Applies a Hann window to the input buffer.
   *
   * Parameters:
   *  - buffer: Input buffer
   *  - size: Size of the buffer
   *---------------------------------------------------------------------*/
  ```
- **Commentaires en ligne**: Utiliser `//` ou `/* */` avec un espace après
  ```c
  int count = 0; /* Initialisation du compteur */
  ```

#### QML

- **Documentation de composant**: Style JavaDoc
  ```qml
  /**
   * Bouton animé avec états (normal, processing, success)
   * 
   * Ce composant fournit un bouton avec des animations et des états
   * pour indiquer visuellement le statut d'une opération.
   */
  Button {
      // ...
  }
  ```
- **Commentaires en ligne**: Utiliser `//` avec un espace après
  ```qml
  property bool isAnimating: false // Indique si une animation est en cours
  ```

## 2. Structure de projet

### 2.1. Organisation des répertoires

```
ProjectName/
├── src/                      # Fichiers source C/C++
├── include/                  # Fichiers d'en-tête C/C++
├── qml/                      # Fichiers QML pour l'interface utilisateur
│   ├── components/           # Composants QML réutilisables
│   └── qml.qrc               # Fichier de ressources QML
├── scripts/                  # Scripts utilitaires
├── build/                    # Fichiers générés lors de la compilation
│   ├── obj/                  # Fichiers objets (.o)
│   ├── moc/                  # Fichiers générés par le Meta-Object Compiler
│   ├── rcc/                  # Fichiers de ressources compilés
│   └── ui/                   # Fichiers générés par l'UI compiler
├── doc/                      # Documentation
├── assets/                   # Ressources non-code
├── config/                   # Fichiers de configuration
├── fonts/                    # Polices utilisées par l'application
└── ProjectName.pro           # Fichier de projet Qt
```

### 2.2. Organisation du code

#### Séparation des préoccupations

Le code doit être organisé selon une architecture en trois couches:

1. **Interface utilisateur (QML)**
   - Présentation et interaction avec l'utilisateur
   - Composants réutilisables
   - Styles et thèmes

2. **Logique métier (C++)**
   - Coordination des opérations
   - Gestion des données
   - Communication entre l'interface et le moteur

3. **Moteur de traitement (C)**
   - Algorithmes de traitement du signal
   - Opérations intensives en calcul
   - Génération des images

#### Principes d'organisation

- **Principe de responsabilité unique**: Chaque classe ou module ne doit avoir qu'une seule raison de changer
- **Principe ouvert/fermé**: Les entités doivent être ouvertes à l'extension mais fermées à la modification
- **Principe de substitution de Liskov**: Les objets d'une classe dérivée doivent pouvoir être substitués aux objets de la classe de base
- **Principe de ségrégation des interfaces**: Plusieurs interfaces spécifiques valent mieux qu'une interface générale
- **Principe d'inversion des dépendances**: Dépendre des abstractions, pas des implémentations

### 2.3. Gestion des dépendances

- **Dépendances externes**: Spécifiées dans le fichier de projet (.pro)
- **Chemins d'inclusion**: Utiliser des chemins relatifs à partir de la racine du projet
- **Ordre des inclusions**:
  1. En-tête correspondant au fichier source
  2. En-têtes du projet
  3. En-têtes des bibliothèques tierces
  4. En-têtes standard

Exemple:
```cpp
#include "MaClasse.h" // En-tête correspondant
#include "AutreClasse.h" // En-tête du projet
#include <QObject> // En-tête Qt
#include <vector> // En-tête standard
```

## 3. Conventions Git

### 3.1. Format des messages de commit

Utiliser le format [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Types de commit:
- `feat`: Nouvelle fonctionnalité
- `fix`: Correction de bug
- `docs`: Modification de la documentation
- `style`: Changements qui n'affectent pas le sens du code (espaces, formatage, etc.)
- `refactor`: Modification du code qui ne corrige pas un bug et n'ajoute pas de fonctionnalité
- `perf`: Amélioration des performances
- `test`: Ajout ou correction de tests
- `build`: Modifications du système de build ou des dépendances
- `ci`: Modifications des fichiers de configuration CI
- `chore`: Autres changements qui ne modifient pas les fichiers src ou test

Exemples:
```
feat(ui): ajouter un bouton de prévisualisation

fix(audio): corriger le chargement des fichiers WAV stéréo

docs: mettre à jour la documentation d'installation
```

### 3.2. Gestion des branches

- **main**: Branche principale, toujours stable
- **develop**: Branche de développement, intégration continue
- **feature/xxx**: Branches de fonctionnalités
- **fix/xxx**: Branches de correction de bugs
- **release/x.y.z**: Branches de préparation de release

Workflow:
1. Créer une branche à partir de `develop` pour chaque fonctionnalité ou correction
2. Développer et tester la fonctionnalité
3. Créer une pull request vers `develop`
4. Après revue et validation, merger dans `develop`
5. Périodiquement, merger `develop` dans `main` via une branche `release/x.y.z`

### 3.3. Pull Requests et revues de code

- **Titre**: Utiliser le même format que pour les messages de commit
- **Description**: Expliquer le contexte, les changements et les tests effectués
- **Taille**: Limiter à 500 lignes de code modifiées maximum
- **Revue**: Au moins un approbateur requis avant de merger
- **Tests**: Tous les tests doivent passer avant de merger
- **Conflits**: Doivent être résolus par l'auteur de la PR

## 4. Documentation

### 4.1. Documentation du code

#### C++

Utiliser Doxygen pour documenter:
- Toutes les classes
- Toutes les méthodes publiques et protégées
- Les membres publics
- Les énumérations et leurs valeurs

Format:
```cpp
/**
 * @brief Description courte
 *
 * Description détaillée sur
 * plusieurs lignes si nécessaire.
 *
 * @param param1 Description du paramètre 1
 * @param param2 Description du paramètre 2
 * @return Description de la valeur de retour
 * @throws Description des exceptions potentielles
 * @see Références à d'autres classes ou méthodes
 */
```

#### C

Utiliser un format de commentaire bloc pour documenter:
- Toutes les fonctions
- Toutes les structures
- Toutes les macros importantes

Format:
```c
/*---------------------------------------------------------------------
 * nom_de_fonction()
 *
 * Description détaillée de la fonction.
 *
 * Parameters:
 *  - param1: Description du paramètre 1
 *  - param2: Description du paramètre 2
 *
 * Returns:
 *  - Description de la valeur de retour
 *---------------------------------------------------------------------*/
```

#### QML

Utiliser le format JavaDoc pour documenter:
- Tous les composants
- Toutes les propriétés publiques
- Tous les signaux
- Toutes les fonctions publiques

Format:
```qml
/**
 * Description du composant
 *
 * Détails supplémentaires si nécessaire.
 */
```

### 4.2. Documentation du projet

La documentation du projet doit être organisée comme suit:

```
doc/
├── index.md                  # Point d'entrée de la documentation
├── vue_ensemble.md           # Vue d'ensemble du projet
├── architecture/             # Documentation sur l'architecture
│   └── patterns_conception.md # Patterns de conception utilisés
├── technique/                # Documentation technique
│   ├── traitement_signal.md  # Traitement du signal
│   └── flux_donnees.md       # Flux de données
├── interface/                # Documentation sur l'interface
│   └── interface_utilisateur.md # Interface utilisateur
└── developpement/            # Documentation pour les développeurs
    ├── guide_developpement.md # Guide de développement
    └── guide_style_developpement.md # Ce document
```

### 4.3. Politique de mise à jour

- La documentation doit être mise à jour en même temps que le code
- Toute modification significative du code doit être accompagnée d'une mise à jour de la documentation
- Les pull requests doivent inclure les mises à jour de documentation nécessaires
- La documentation doit être revue lors des revues de code

## 5. Bonnes pratiques

### 5.1. Gestion des erreurs

- **C++**: Utiliser les exceptions pour les erreurs exceptionnelles, les codes de retour pour les erreurs attendues
- **C**: Utiliser les codes de retour et les messages d'erreur
- **QML**: Utiliser les signaux pour communiquer les erreurs

### 5.2. Tests

- **Tests unitaires**: Pour les composants individuels
- **Tests d'intégration**: Pour les interactions entre composants
- **Tests fonctionnels**: Pour les fonctionnalités complètes
- **Couverture de code**: Viser au moins 80% de couverture

### 5.3. Performance

- **Profilage**: Utiliser des outils comme Qt Creator Profiler ou Instruments (macOS)
- **Optimisation**: Optimiser uniquement après avoir identifié les goulots d'étranglement
- **Multithreading**: Utiliser `TaskManager` pour les opérations longues

### 5.4. Sécurité

- **Validation des entrées**: Toujours valider les entrées utilisateur
- **Gestion de la mémoire**: Utiliser des pointeurs intelligents en C++
- **Libération des ressources**: Toujours libérer les ressources allouées en C

## 6. Outils recommandés

- **IDE**: Qt Creator ou Visual Studio Code
- **Formatage**: clang-format avec un fichier de configuration partagé
- **Analyse statique**: clang-tidy, cppcheck
- **Documentation**: Doxygen
- **Gestion de version**: Git avec GitLab ou GitHub
- **Intégration continue**: GitLab CI ou GitHub Actions

## Conclusion

Ce guide de style de développement est un document vivant qui évoluera avec les besoins et les pratiques de l'équipe. Il est important de le suivre pour maintenir une base de code cohérente et maintenable, mais il est également important de le faire évoluer lorsque de meilleures pratiques sont identifiées.

En cas de doute sur une convention ou une pratique, référez-vous à ce document ou discutez-en avec l'équipe pour clarifier et potentiellement améliorer ce guide.