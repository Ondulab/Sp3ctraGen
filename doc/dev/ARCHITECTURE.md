# Architecture du Projet SpectroGen après Refactorisation

Ce document décrit l'architecture du projet SpectroGen après la refactorisation, en mettant l'accent sur les patterns de conception utilisés, les principes de conception appliqués et les bonnes pratiques à suivre.

## 1. Vue d'ensemble de l'architecture

L'architecture du projet SpectroGen est basée sur une séparation claire entre:

1. **Interface utilisateur** (QML)
2. **Logique métier** (C++)
3. **Moteur de traitement du signal** (C)

Cette séparation permet une meilleure maintenabilité et une évolution indépendante de chaque couche.

```
┌─────────────────┐
│  Interface QML  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Logique C++    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Moteur C       │
└─────────────────┘
```

## 2. Principes de conception appliqués

### 2.1. DRY (Don't Repeat Yourself)

Le principe DRY a été appliqué pour éliminer la duplication de code et de constantes:

- Centralisation des constantes dans `SharedConstants.h`
- Extraction du code commun dans les classes de base
- Création de composants QML réutilisables

### 2.2. Séparation des préoccupations (Separation of Concerns)

Chaque composant a une responsabilité unique et bien définie:

- **Interface utilisateur**: Présentation et interaction avec l'utilisateur
- **Logique métier**: Coordination des opérations et gestion des données
- **Moteur de traitement**: Algorithmes de traitement du signal et génération de spectrogrammes

### 2.3. Principe ouvert/fermé (Open/Closed Principle)

Les composants sont conçus pour être ouverts à l'extension mais fermés à la modification:

- Utilisation de classes abstraites et d'interfaces
- Implémentation du pattern Strategy pour les différentes visualisations
- Composants QML paramétrables

## 3. Patterns de conception utilisés

### 3.1. Pattern Strategy

Le pattern Strategy est utilisé pour encapsuler différentes implémentations de génération de spectrogrammes:

```
┌───────────────────────┐
│ VisualizationStrategy │
│   (classe abstraite)  │
└───────────┬───────────┘
            │
            ├─────────────────────┐
            │                     │
┌───────────▼───────────┐ ┌───────▼───────────────┐
│RasterVisualizationStrategy│ │VectorVisualizationStrategy│
└───────────────────────┘ └─────────────────────────┘
```

Ce pattern permet d'ajouter facilement de nouveaux formats de sortie sans modifier le code existant.

### 3.2. Pattern Template Method

Le pattern Template Method est utilisé dans la classe `VisualizationStrategy` pour définir le squelette de l'algorithme de génération de spectrogrammes, tout en permettant aux sous-classes de redéfinir certaines étapes:

```cpp
// Méthode template dans la classe de base
bool VisualizationStrategy::generate(const SpectrogramSettingsCpp& settings, 
                                   const QString& inputFile,
                                   const QString& outputFile)
{
    // Étapes communes
    // ...
    
    // Exécuter la génération dans un thread séparé
    QFuture<void> future = QtConcurrent::run([=]() {
        this->runGeneration(cSettings, inputFile, outputFile);
    });
    
    return true;
}

// Méthode abstraite à implémenter par les sous-classes
virtual int callGeneratorFunction(const SpectrogramSettings& settings,
                                const char* inputFile,
                                const char* outputFile) = 0;
```

### 3.3. Pattern Singleton

Le pattern Singleton est utilisé pour les classes utilitaires qui n'ont besoin que d'une seule instance:

- `QmlConstants`: Exposé comme singleton à QML
- `PathManager`: Utilise des méthodes statiques

### 3.4. Pattern Composite

Le pattern Composite est utilisé dans l'interface utilisateur QML pour construire des interfaces complexes à partir de composants simples:

- `AnimatedButton`: Composant de bouton réutilisable
- `ValidatedTextField`: Composant de champ de texte réutilisable

## 4. Structure des fichiers

```
SpectroGen/
├── include/                  # Fichiers d'en-tête C++
│   ├── SharedConstants.h     # Constantes partagées entre C et C++
│   ├── Constants.h           # Constantes C++ (utilise SharedConstants.h)
│   ├── QmlConstants.h        # Exposition des constantes à QML
│   ├── PathManager.h         # Gestion des chemins de fichiers
│   ├── VisualizationStrategy.h # Interface de stratégie
│   ├── RasterVisualizationStrategy.h # Stratégie pour PNG
│   └── VectorVisualizationStrategy.h # Stratégie pour PDF
├── src/                      # Fichiers source C++
│   ├── spectral_common.h     # Constantes et définitions C (utilise SharedConstants.h)
│   ├── spectral_*.c          # Moteur de traitement du signal en C
│   ├── VisualizationStrategy.cpp # Implémentation de la classe de base
│   ├── RasterVisualizationStrategy.cpp # Implémentation de la stratégie PNG
│   └── VectorVisualizationStrategy.cpp # Implémentation de la stratégie PDF
├── qml/                      # Fichiers QML pour l'interface utilisateur
│   ├── components/           # Composants QML réutilisables
│   │   ├── AnimatedButton.qml # Bouton avec animations
│   │   └── ValidatedTextField.qml # Champ de texte avec validation
│   ├── main.qml              # Interface principale
│   └── minimal_main.qml      # Interface simplifiée
└── doc/                      # Documentation
    ├── README.md             # Documentation principale
    └── dev/                  # Documentation pour les développeurs
        ├── ARCHITECTURE.md   # Ce document
        └── REFACTORISATION.md # Guide de refactorisation
```

## 5. Flux de données

Le flux de données dans l'application suit le chemin suivant:

1. **Interface utilisateur (QML)**: L'utilisateur configure les paramètres et déclenche la génération
2. **Logique métier (C++)**: Les paramètres sont validés et transmis au moteur de traitement
3. **Moteur de traitement (C)**: Le spectrogramme est généré et enregistré dans un fichier
4. **Logique métier (C++)**: Le résultat est transmis à l'interface utilisateur
5. **Interface utilisateur (QML)**: Le résultat est affiché à l'utilisateur

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    QML      │     │     C++     │     │      C      │
│  Interface  │────▶│   Logique   │────▶│   Moteur    │
└─────┬───────┘     └─────┬───────┘     └─────┬───────┘
      │                   │                   │
      │                   │                   │
      │                   │                   │
┌─────▼───────┐     ┌─────▼───────┐     ┌─────▼───────┐
│    QML      │     │     C++     │     │  Fichier    │
│  Affichage  │◀────│ Traitement  │◀────│  de sortie  │
└─────────────┘     └─────────────┘     └─────────────┘
```

## 6. Communication entre les couches

### 6.1. Communication QML → C++

La communication de QML vers C++ se fait via:

- **Appels de méthodes**: QML appelle des méthodes C++ exposées
- **Propriétés liées**: QML lie des propriétés à des propriétés C++ exposées

### 6.2. Communication C++ → QML

La communication de C++ vers QML se fait via:

- **Signaux**: C++ émet des signaux que QML peut connecter à des slots
- **Propriétés notifiables**: C++ modifie des propriétés qui notifient QML des changements

### 6.3. Communication C++ → C

La communication de C++ vers C se fait via:

- **Appels de fonctions**: C++ appelle des fonctions C exportées
- **Structures de données**: C++ passe des structures de données à C

## 7. Bonnes pratiques à suivre

### 7.1. Gestion des constantes

- Toujours définir les constantes dans `SharedConstants.h`
- Utiliser les constantes via `Constants.h` en C++ et via `QmlConstants` en QML
- Ne jamais coder en dur des valeurs qui pourraient être des constantes

### 7.2. Ajout de nouvelles fonctionnalités

- Pour ajouter un nouveau format de sortie, créer une nouvelle classe dérivée de `VisualizationStrategy`
- Pour ajouter un nouveau composant d'interface, créer un nouveau composant QML dans le dossier `qml/components`
- Pour ajouter un nouveau paramètre, l'ajouter dans `SharedConstants.h` et l'exposer via `QmlConstants`

### 7.3. Tests

- Tester chaque couche indépendamment
- Utiliser des mocks pour isoler les couches lors des tests
- Tester les cas limites et les cas d'erreur

## 8. Évolution future

L'architecture refactorisée facilite les évolutions futures suivantes:

- **Nouveaux formats de sortie**: Ajout facile de nouveaux formats (SVG, TIFF, etc.)
- **Nouveaux algorithmes de traitement**: Possibilité d'ajouter de nouveaux algorithmes de traitement du signal
- **Interface utilisateur améliorée**: Possibilité d'ajouter de nouveaux composants d'interface utilisateur
- **Internationalisation**: Possibilité d'ajouter la prise en charge de plusieurs langues

## 9. Conclusion

L'architecture refactorisée du projet SpectroGen est basée sur des principes de conception solides et des patterns éprouvés. Elle offre une séparation claire des préoccupations, une réutilisation maximale du code et une extensibilité pour les évolutions futures.

En suivant les bonnes pratiques décrites dans ce document, les développeurs pourront maintenir et faire évoluer le projet de manière efficace et cohérente.