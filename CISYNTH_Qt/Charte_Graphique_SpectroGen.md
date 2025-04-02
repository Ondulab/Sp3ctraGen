# Charte Graphique CISYNTH Qt

Ce document décrit la charte graphique utilisée dans l'application CISYNTH Qt. Il détaille l'utilisation des couleurs, de la typographie et les principes de mise en forme des différents composants de l'interface utilisateur.

## Sommaire
1. Palette de couleurs
2. Typographie
3. Principes de mise en page et alignement
4. Fenêtre principale (ApplicationWindow)
5. Conteneurs et séparateurs
6. Titres et libellés (Label)
7. Champs de formulaire (TextField, CheckBox, Button)
8. Dialogues de fichiers (FileDialog)
9. Indicateurs d'état (Text)
10. Bonnes pratiques et remarques

---

## Palette de couleurs

| Couleur | Code Hex | Utilisation principale |
|---------|----------|------------------------|
| Gris foncé | #333333 | Couleur d'arrière-plan principale de la fenêtre |
| Gris clair | #cccccc | Séparateurs, bordures |
| Blanc | #ffffff | Texte principal, contenu des champs |
| Vert | #4CAF50 | Indicateurs de succès |
| Rouge | #F44336 | Indicateurs d'erreur |
| Bleu | #2196F3 | Boutons d'action, éléments interactifs |
| Gris moyen | #888888 | Texte secondaire, placeholders |

Exemple d'utilisation :
- Le fond global est en gris foncé (#333333)
- Les textes (titres, labels, etc.) sont en blanc (#ffffff)
- Les séparateurs sont en gris clair (#cccccc)
- Les messages de succès sont en vert (#4CAF50)
- Les messages d'erreur sont en rouge (#F44336)
- Les boutons principaux sont en bleu (#2196F3)

---

## Typographie

- **Police principale** : Police système par défaut de Qt
  - Pour une cohérence avec la charte web, il est recommandé d'utiliser une police personnalisée comme Orbitron
  - Implémentation via FontLoader en QML :

```qml
FontLoader {
    id: orbitronFont
    source: "qrc:/fonts/Orbitron-Regular.ttf"
}
```

- **Style général** :
  - L'ensemble de l'application utilise la police système par défaut
  - Les tailles de texte varient selon l'importance :
    - Titres : 16px (font.pixelSize: 16)
    - Labels : 12-14px
    - Champs de texte : 12-14px
  - Les titres sont en gras (font.bold: true)

---

## Principes de mise en page et alignement

- **Disposition générale** :
  - L'ApplicationWindow a une taille de base de 500x700 pixels
  - Le contenu est organisé dans un ScrollView pour permettre le défilement
  - Les éléments sont disposés verticalement dans un ColumnLayout
  - Les marges extérieures sont de 20 pixels (anchors.margins: 20)
  - L'espacement entre les éléments est de 10 pixels (spacing: 10)

- **Grilles et formulaires** :
  - Les formulaires utilisent un GridLayout à 2 colonnes
  - Espacement horizontal entre colonnes : 10 pixels (columnSpacing: 10)
  - Espacement vertical entre lignes : 8 pixels (rowSpacing: 8)
  - Les labels sont alignés à gauche, les champs à droite

- **Alignement du texte** :
  - Les titres sont alignés à gauche
  - Les messages d'état sont centrés (horizontalAlignment: Text.AlignHCenter)
  - Les boutons d'action principaux sont centrés (Layout.alignment: Qt.AlignHCenter)

---

## Fenêtre principale (ApplicationWindow)

- **Dimensions** : 500x700 pixels
- **Titre** : "CISYNTH Spectrogram Generator"
- **Couleur de fond** : Gris foncé (#333333)
- **Contenu** : ScrollView contenant un ColumnLayout

Exemple de code :
```qml
ApplicationWindow {
    id: window
    title: "CISYNTH Spectrogram Generator"
    width: 500
    height: 700
    visible: true
    color: "#333333"
    
    // Contenu
}
```

---

## Conteneurs et séparateurs

- **ScrollView** :
  - Remplit toute la fenêtre (anchors.fill: parent)
  - Permet le défilement vertical du contenu
  - Largeur de contenu égale à la largeur de la fenêtre (contentWidth: parent.width)

- **ColumnLayout** :
  - Largeur égale à la largeur du parent (width: parent.width)
  - Marges de 20 pixels (anchors.margins: 20)
  - Espacement de 10 pixels entre les éléments (spacing: 10)

- **GridLayout** :
  - 2 colonnes pour les formulaires
  - Espacement horizontal : 10 pixels (columnSpacing: 10)
  - Espacement vertical : 8 pixels (rowSpacing: 8)

- **Séparateurs** :
  - Rectangle de hauteur 1 pixel
  - Couleur gris clair (#cccccc)
  - Largeur égale à la largeur du parent (Layout.fillWidth: true)
  - Marges verticales de 10 pixels (Layout.topMargin: 10, Layout.bottomMargin: 10)

Exemple de code :
```qml
Rectangle {
    height: 1
    color: "#cccccc"
    Layout.fillWidth: true
    Layout.topMargin: 10
    Layout.bottomMargin: 10
}
```

---

## Titres et libellés (Label)

- **Titres de section** :
  - Texte en blanc (#ffffff)
  - Taille : 16 pixels (font.pixelSize: 16)
  - Style : Gras (font.bold: true)
  - Marge supérieure : 10 pixels (Layout.topMargin: 10)

Exemple de code :
```qml
Label {
    text: "Paramètres du Spectrogramme"
    font.bold: true
    font.pixelSize: 16
    color: "#ffffff"
    Layout.topMargin: 10
}
```

- **Labels de champ** :
  - Texte en blanc (#ffffff)
  - Taille : 12-14 pixels
  - Alignement : Gauche dans un GridLayout

Exemple de code :
```qml
Label { 
    text: "Taille FFT:" 
    color: "#ffffff"
}
```

---

## Champs de formulaire (TextField, CheckBox, Button)

### Style commun
- Texte en blanc (#ffffff)
- Fond semi-transparent
- Bordure fine

### TextField
- Largeur préférée : 80 pixels pour les champs numériques (Layout.preferredWidth: 80)
- Validateurs appropriés selon le type de données (IntValidator, DoubleValidator)
- Texte centré

Exemple de code :
```qml
TextField {
    id: fftSizeField
    text: "8192"
    Layout.preferredWidth: 80
    validator: IntValidator { bottom: 1 }
    color: "#ffffff"
    horizontalAlignment: Text.AlignHCenter
}
```

### CheckBox
- Case à cocher standard
- Texte en blanc (#ffffff)

Exemple de code :
```qml
CheckBox {
    id: ditheringCheckBox
    checked: false
}
```

### Button
- Texte en blanc (#ffffff)
- Fond bleu (#2196F3)
- Bordure arrondie
- Effet de survol : légère transparence

Exemple de code pour un bouton principal :
```qml
Button {
    text: "Générer le Spectrogramme"
    Layout.topMargin: 10
    Layout.alignment: Qt.AlignHCenter
    background: Rectangle {
        color: "#2196F3"
        radius: 4
    }
    contentItem: Text {
        text: parent.text
        color: "#ffffff"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
```

Exemple de code pour un bouton secondaire :
```qml
Button {
    text: "Parcourir..."
    background: Rectangle {
        color: "#555555"
        radius: 4
    }
    contentItem: Text {
        text: parent.text
        color: "#ffffff"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
```

---

## Dialogues de fichiers (FileDialog)

- **Titre** : Descriptif de l'action ("Sélectionner un fichier WAV", "Sélectionner un dossier de sortie")
- **Filtres** : Adaptés au type de fichier attendu (nameFilters: ["Fichiers audio (*.wav)"])
- **Mode** : Sélection de fichier ou de dossier selon le besoin (selectFolder: true/false)

Exemple de code :
```qml
FileDialog {
    id: inputFileDialog
    title: "Sélectionner un fichier WAV"
    nameFilters: ["Fichiers audio (*.wav)"]
    onAccepted: {
        inputFileField.text = fileUrl.toString().replace("file://", "")
    }
}
```

---

## Indicateurs d'état (Text)

- **Texte de statut** :
  - Largeur égale à la largeur du parent (Layout.fillWidth: true)
  - Marge supérieure : 10 pixels (Layout.topMargin: 10)
  - Retour à la ligne automatique (wrapMode: Text.WordWrap)
  - Alignement horizontal centré (horizontalAlignment: Text.AlignHCenter)
  - Couleur variable selon l'état :
    - Succès : Vert (#4CAF50)
    - Erreur : Rouge (#F44336)

Exemple de code :
```qml
Text {
    id: statusText
    Layout.fillWidth: true
    Layout.topMargin: 10
    wrapMode: Text.WordWrap
    horizontalAlignment: Text.AlignHCenter
    // La couleur est définie dynamiquement
}
```

---

## Bonnes pratiques et remarques

1. **Consistance** :
   - Conserver les mêmes valeurs de couleurs dans toute l'application
   - Respecter la hiérarchie visuelle : titres > labels > texte secondaire
   - Utiliser les mêmes espacements et marges dans toute l'interface

2. **Responsivité** :
   - Utiliser Layout.fillWidth: true pour que les éléments s'adaptent à la largeur de la fenêtre
   - Placer le contenu dans un ScrollView pour permettre le défilement sur les petits écrans
   - Éviter les largeurs fixes sauf pour les champs de saisie numériques

3. **Accessibilité** :
   - Assurer un contraste suffisant entre le texte et le fond
   - Utiliser des tailles de texte lisibles (minimum 12px)
   - Ajouter des tooltips aux champs pour expliquer leur fonction

4. **Cohérence avec l'identité visuelle** :
   - Pour une cohérence parfaite avec la version web, envisager d'intégrer la police Orbitron
   - Adapter la palette de couleurs pour se rapprocher de la charte web (fond sombre, texte or)

5. **Personnalisation** :
   - Pour modifier la palette de couleurs, créer des propriétés QML globales ou un fichier de thème
   - Pour changer la police, utiliser FontLoader et définir la police dans un fichier de style global

6. **Évolution** :
   - Prévoir l'internationalisation des textes
   - Concevoir l'interface pour qu'elle puisse accueillir de nouveaux paramètres
   - Documenter les composants personnalisés pour faciliter leur réutilisation

---

## Proposition d'évolution vers la charte web

Pour rapprocher l'interface Qt de la charte web, voici les modifications recommandées :

1. **Palette de couleurs** :
   - Fond principal : #222 (au lieu de #333333)
   - Texte principal : #D4AF37 (or) (au lieu de blanc)
   - Champs de formulaire : fond #333, texte #BBB
   - Boutons : fond #555, texte #000, hover fond #333, texte #FFF

2. **Typographie** :
   - Intégrer la police Orbitron via FontLoader
   - Appliquer cette police à tous les éléments textuels

3. **Conteneurs** :
   - Ajouter des bordures dorées (#D4AF37) aux sections
   - Utiliser des coins arrondis (radius: 8)

4. **Exemple de mise en œuvre** :
```qml
// Dans un fichier Theme.qml
QtObject {
    readonly property color backgroundColor: "#222"
    readonly property color primaryTextColor: "#D4AF37"
    readonly property color fieldBackground: "#333"
    readonly property color fieldText: "#BBB"
    readonly property color buttonBackground: "#555"
    readonly property color buttonText: "#000"
    readonly property color buttonHoverBackground: "#333"
    readonly property color buttonHoverText: "#FFF"
    readonly property color borderColor: "#D4AF37"
    readonly property int borderRadius: 8
}
```

Cette évolution permettrait d'harmoniser l'expérience utilisateur entre les versions web et desktop de l'application CISYNTH.
