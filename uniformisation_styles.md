# Plan d'uniformisation des styles de composants

Ce document détaille les modifications à apporter pour uniformiser les styles des composants dans les fichiers SpectrogramParameters.qml et OutputFormat.qml.

## Problème identifié

Actuellement, les deux fichiers utilisent des dimensions hardcodées pour les composants ToggleSwitch et FilterComboBox :

```qml
Layout.preferredWidth: 80
Layout.preferredHeight: 30
```

## Solution proposée

### 1. Modification du fichier Theme.qml

Ajouter une constante `controlWidth` pour compléter la propriété `controlHeight` déjà existante :

```qml
// Ajouter cette ligne à Theme.qml
readonly property int controlWidth: 80  // À placer après controlHeight (ligne 58)
```

### 2. Modification des composants

#### ToggleSwitch.qml

Modifier les propriétés par défaut pour utiliser le thème central :

```qml
// Avant (lignes 16-17)
property int preferredWidth: 80
property int preferredHeight: 30

// Après
property int preferredWidth: AppStyles.Theme.controlWidth
property int preferredHeight: AppStyles.Theme.controlHeight
```

#### FilterComboBox.qml

Ajuster la largeur implicite pour correspondre à celle utilisée dans les sections :

```qml
// Avant (ligne 30)
implicitWidth: 120

// Après
implicitWidth: AppStyles.Theme.controlWidth
```

### 3. Mise à jour des sections

#### SpectrogramParameters.qml

Remplacer toutes les occurrences de :

```qml
// Avant (lignes 144-145, 156-157, 181-182, 207-208, 237)
Layout.preferredWidth: 80
Layout.preferredHeight: 30

// Après
Layout.preferredWidth: AppStyles.Theme.controlWidth
Layout.preferredHeight: AppStyles.Theme.controlHeight
```

#### OutputFormat.qml

Remplacer toutes les occurrences de :

```qml
// Avant (lignes 49, 85-86, 97-98, 124-125, 150-151)
Layout.preferredWidth: 80
Layout.preferredHeight: 30

// Après
Layout.preferredWidth: AppStyles.Theme.controlWidth
Layout.preferredHeight: AppStyles.Theme.controlHeight
```

## Implémentation détaillée

### 1. Theme.qml (modification exacte)

```qml
// Ajouter après la ligne 58 où se trouve controlHeight
readonly property int controlHeight: 30
readonly property int controlWidth: 80    // Nouvelle ligne à ajouter
```

### 2. ToggleSwitch.qml (modification exacte)

```qml
// Modifier les lignes 16-17
property bool enabled: true
property int preferredWidth: AppStyles.Theme.controlWidth
property int preferredHeight: AppStyles.Theme.controlHeight
```

### 3. FilterComboBox.qml (modification exacte)

```qml
// Modifier la ligne 30
background: Rectangle {
    implicitWidth: AppStyles.Theme.controlWidth
    implicitHeight: AppStyles.Theme.fieldHeight
```

### 4. SpectrogramParameters.qml (modifications exactes)

Remplacer :
- Lignes 144-145 (normalizationToggle)
- Lignes 156-157 (ditheringToggle)
- Lignes 181-182 (highBoostToggle)
- Lignes 207-208 (highPassToggle)
- Ligne 237 (highPassOrderCombo)

Pour chaque ToggleSwitch :
```qml
Layout.preferredWidth: AppStyles.Theme.controlWidth
Layout.preferredHeight: AppStyles.Theme.controlHeight
```

Pour FilterComboBox :
```qml
Layout.preferredWidth: AppStyles.Theme.controlWidth
```

### 5. OutputFormat.qml (modifications exactes)

Remplacer :
- Ligne 49 (pageFormatCombo)
- Lignes 85-86 (verticalScaleToggle)
- Lignes 97-98 (bottomReferenceLineToggle)
- Lignes 124-125 (topReferenceLineToggle)
- Lignes 150-151 (displayParametersToggle)

Pour le ComboBox :
```qml
Layout.preferredWidth: AppStyles.Theme.controlWidth
```

Pour chaque ToggleSwitch :
```qml
Layout.preferredWidth: AppStyles.Theme.controlWidth
Layout.preferredHeight: AppStyles.Theme.controlHeight
```

## Avantages de cette approche

1. **Centralisation** : Toutes les dimensions sont définies au même endroit
2. **Cohérence** : Garantit que les composants ont la même taille dans toute l'application
3. **Maintenabilité** : Facilite les changements futurs (il suffit de modifier Theme.qml)
4. **Lisibilité** : Le code exprime clairement l'intention (utiliser une taille standard)

## Diagramme de l'architecture

```
Theme.qml
  │
  ├─> ToggleSwitch.qml ───┐
  │                       ├─> SpectrogramParameters.qml
  └─> FilterComboBox.qml ─┘
                          │
                          └─> OutputFormat.qml