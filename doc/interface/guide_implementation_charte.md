# Guide d'implémentation de la Charte Graphique CISYNTH Qt

Ce document explique comment implémenter la charte graphique CISYNTH dans votre application Qt.

## Fichiers inclus

1. `Charte_Graphique_SpectroGen.md` - Documentation complète de la charte graphique
2. `qml/Theme.qml` - Singleton QML contenant toutes les propriétés de style
3. `qml/qmldir` - Fichier d'enregistrement du module UI et du singleton Theme
4. `qml/ExempleTheme.qml` - Exemple d'application utilisant le thème
5. `fonts/Orbitron-Regular.ttf` - Police Orbitron (Regular)

## Comment utiliser le thème

### 1. Importer le module UI dans votre fichier QML

```qml
import com.spectrogen.ui 1.0
```

### 2. Utiliser les propriétés du thème

```qml
Rectangle {
    color: Theme.backgroundColor
    border.color: Theme.borderColor
    border.width: Theme.borderWidth
    radius: Theme.borderRadius
}

Text {
    color: Theme.primaryTextColor
    font.family: Theme.fontFamily
    font.pixelSize: Theme.textFontSize
}

Button {
    contentItem: Text {
        text: parent.text
        color: parent.hovered ? Theme.buttonHoverText : Theme.buttonText
        font.family: Theme.fontFamily
        horizontalAlignment: Text.AlignHCenter
    }
    
    background: Rectangle {
        color: parent.hovered ? Theme.buttonHoverBackground : Theme.buttonBackground
        radius: Theme.borderRadius / 2
    }
}
```

### 3. Charger la police Orbitron

Assurez-vous d'inclure la police Orbitron dans votre application :

```qml
FontLoader {
    id: orbitronFont
    source: "qrc:/fonts/Orbitron-Regular.ttf"
}
```

## Exemple complet

Consultez le fichier `qml/ExempleTheme.qml` pour un exemple complet d'utilisation du thème.

## Personnalisation

Pour modifier les couleurs, les dimensions ou d'autres propriétés du thème, éditez simplement le fichier `qml/Theme.qml`.

## Intégration avec l'application existante

Pour intégrer cette charte graphique dans l'application CISYNTH Qt existante :

1. Assurez-vous que les fichiers `Theme.qml`, `qmldir` et la police Orbitron sont inclus dans les ressources QML
2. Importez le module UI dans `main.qml`
3. Remplacez progressivement les styles hardcodés par des références au thème
4. Pour les composants complexes, créez des composants QML personnalisés qui utilisent le thème

## Exemple de migration

### Avant :

```qml
Label {
    text: "Paramètres du Spectrogramme"
    font.bold: true
    font.pixelSize: 16
    Layout.topMargin: 10
}
```

### Après :

```qml
Label {
    text: "Paramètres du Spectrogramme"
    font.bold: true
    font.pixelSize: Theme.titleFontSize
    font.family: Theme.fontFamily
    color: Theme.primaryTextColor
    Layout.topMargin: Theme.spacing
}
```

## Remarques importantes

1. La police Orbitron est essentielle pour respecter l'identité visuelle de CISYNTH
2. Les couleurs or/noir sont caractéristiques de la marque et doivent être conservées
3. Tous les composants doivent utiliser les propriétés du thème pour assurer la cohérence
4. Pour les futures mises à jour, modifiez uniquement le fichier Theme.qml
