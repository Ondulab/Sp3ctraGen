# Charte graphique et interface utilisateur de Sp3ctraGen

## Introduction

L'interface graphique de Sp3ctraGen a été conçue avec une attention particulière à l'ergonomie et à la cohérence visuelle. Ce document présente les éléments clés de la charte graphique et de l'organisation de l'interface utilisateur.

## Principes de conception

L'interface utilisateur de Sp3ctraGen suit plusieurs principes fondamentaux :

1. **Clarté** : Les contrôles et informations sont présentés de manière claire et organisée
2. **Cohérence** : Les éléments similaires utilisent des styles cohérents dans toute l'application
3. **Feedback** : L'utilisateur reçoit un retour visuel pour chaque action
4. **Accessibilité** : L'interface utilise des contrastes élevés et des tailles de texte lisibles
5. **Modularité** : L'interface est divisée en sections logiques et indépendantes

## Palette de couleurs

Sp3ctraGen utilise une palette de couleurs cohérente, définie dans `qml/styles/Theme.qml` :

### Couleurs principales

- **Couleur primaire** : `#0076D6` - Utilisée pour les éléments interactifs principaux et les accentuations
- **Couleur secondaire** : `#404040` - Utilisée pour les éléments d'interface secondaires
- **Couleur de fond** : `#2A2A2A` - Couleur de fond principale de l'application
- **Couleur de texte principale** : `#FFFFFF` - Texte sur fond sombre
- **Couleur de texte secondaire** : `#B0B0B0` - Texte moins important ou descriptif

### Couleurs de feedback

- **Couleur de succès** : `#00C853` - Utilisée pour les messages de succès
- **Couleur d'erreur** : `#FF5252` - Utilisée pour les messages d'erreur
- **Couleur d'avertissement** : `#FFD600` - Utilisée pour les avertissements
- **Couleur d'information** : `#2196F3` - Utilisée pour les messages informatifs

### Couleurs spécifiques

- **Couleur de segmentation** : `rgba(255, 128, 0, 0.5)` - Pour les zones sélectionnées dans la forme d'onde
- **Couleur de spectrogramme** : Dégradé noir-blanc inversé pour une meilleure lisibilité

## Typographie

L'application utilise une typographie soigneusement sélectionnée pour assurer la lisibilité :

- **Police principale** : "Roboto" - Pour la majorité des textes de l'interface
- **Police d'accent** : "Orbitron" - Pour les titres et éléments importants
- **Police monospace** : "Roboto Mono" - Pour les valeurs numériques et techniques

### Tailles de police

- **Grande** : 18px - Titres de section
- **Moyenne** : 14px - Texte standard, étiquettes
- **Petite** : 12px - Informations secondaires, descriptions

## Composants d'interface

### Sections

L'interface est organisée en sections modulaires, chacune encapsulée dans un composant `SectionContainer` :

- **En-tête de section** : Fond légèrement plus foncé avec le titre de la section
- **Corps de section** : Fond standard avec les contrôles associés
- **Espacement** : Marge uniforme entre les sections pour une séparation visuelle claire

### Contrôles interactifs

#### Boutons

Les boutons suivent un style uniforme :
- Fond de couleur primaire
- Texte blanc
- Coins légèrement arrondis
- Animation de survol pour le feedback visuel
- Transition de couleur fluide

```qml
Button {
    contentItem: Text {
        text: parent.text
        color: parent.hovered ? AppStyles.Theme.buttonHoverText : AppStyles.Theme.buttonText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    
    background: Rectangle {
        color: parent.hovered ? AppStyles.Theme.buttonHoverBackground : AppStyles.Theme.buttonBackground
        radius: AppStyles.Theme.borderRadius / 2
        
        Behavior on color {
            ColorAnimation {
                duration: AppStyles.Theme.animationDuration
            }
        }
    }
}
```

#### Champs de saisie

Les champs de saisie utilisent un composant personnalisé `ParameterField` qui offre :
- Validation intégrée des valeurs numériques
- Support des unités (Hz, dB, etc.)
- Retour visuel sur les erreurs de saisie
- Formatage automatique des valeurs

#### Curseurs

Les curseurs (Slider) sont utilisés pour les paramètres continus comme le mode de résolution :
- Poignée distinctive pour faciliter la manipulation
- Marques visuelles pour les positions importantes
- Étiquettes textuelles pour les valeurs clés
- Mise à jour dynamique des valeurs associées

#### Interrupteurs

Les interrupteurs (Toggle) utilisent un composant personnalisé `ToggleSwitch` :
- Animation fluide entre les états
- Couleurs distinctes pour les états activé/désactivé
- Feedback tactile (si disponible sur la plateforme)

## Organisation de l'interface

L'interface de Sp3ctraGen est organisée en plusieurs sections principales :

### 1. Section Fichier

Contrôles pour la sélection des fichiers d'entrée et de sortie.

### 2. Section Paramètres du spectrogramme

Contrôles pour la configuration des paramètres d'analyse spectrale.

### 3. Section Paramètres de filtrage

Options de filtrage du signal pour optimiser l'analyse.

### 4. Section Format de sortie

Configuration du format et des dimensions du spectrogramme généré.

### 5. Section Prévisualisation

Affichage de l'aperçu du spectrogramme avant la génération finale.

### 6. Section Forme d'onde audio

Visualisation du signal audio temporel avec sélection de segment.

## Messages de feedback

Le système de feedback utilise le composant `StatusText` pour fournir des informations claires à l'utilisateur :

- **Messages de succès** : Texte vert indiquant la réussite d'une opération
- **Messages d'erreur** : Texte rouge signalant un problème
- **Messages d'avertissement** : Texte jaune alertant sur une situation potentiellement problématique
- **Messages d'information** : Texte bleu fournissant des informations contextuelles

## Responsive design

L'interface s'adapte à différentes tailles d'écran :

- Les sections peuvent être redimensionnées
- Les composants utilisent des ancrages relatifs
- Les tailles de police s'ajustent selon la densité de pixels
- Les contrôles maintiennent des dimensions minimales pour rester utilisables

## Animation et transitions

Sp3ctraGen utilise des animations subtiles pour améliorer l'expérience utilisateur :

- Transitions fluides lors du changement d'état des contrôles
- Animations de chargement pour les opérations longues
- Effets de survol pour indiquer l'interactivité
- Transitions entre les différentes vues ou états

## Icônes et éléments graphiques

Les icônes utilisées dans l'application suivent un style cohérent :
- Style simple et épuré
- Contours clairs
- Taille uniforme
- Signification intuitive

## Accessibilité

L'interface est conçue pour être accessible :
- Contrastes élevés pour la lisibilité
- Support des raccourcis clavier pour les actions courantes
- Tailles de texte ajustables
- Messages d'erreur explicites

## Implémentation technique

La charte graphique est implémentée à travers plusieurs fichiers QML :
- `qml/styles/Theme.qml` : Définition des constantes de style
- `qml/styles/Fonts.qml` : Configuration des polices
- `qml/components/` : Composants réutilisables respectant la charte

## Best practices pour le développement

Lors du développement de nouvelles fonctionnalités, suivez ces bonnes pratiques :

1. Utilisez les constantes définies dans `Theme.qml` plutôt que des valeurs codées en dur
2. Créez des composants réutilisables pour les éléments récurrents
3. Maintenez la cohérence visuelle entre les sections
4. Testez l'interface à différentes résolutions
5. Assurez-vous que les fonctionnalités restent accessibles via le clavier

## Exemples visuels

![Interface principale](../images/main_interface.png)
*L'interface principale de Sp3ctraGen montrant l'organisation en sections*

![Composants d'interface](../images/ui_components.png)
*Les principaux composants d'interface suivant la charte graphique*

## Conclusion

La charte graphique de Sp3ctraGen a été conçue pour offrir une expérience utilisateur cohérente, intuitive et efficace. En suivant ces directives, l'application maintient une identité visuelle forte tout en restant fonctionnelle et accessible à tous les utilisateurs.
