pragma Singleton
import QtQuick 2.15

/**
 * Singleton pour les polices de caractères
 * 
 * Ce singleton expose les polices utilisées dans l'application
 * pour assurer une cohérence typographique.
 */
QtObject {
    // Définition de la police Orbitron
    readonly property FontLoader orbitronFont: FontLoader {
        source: "../styles/fonts/Orbitron-Regular.ttf"
    }
    
    // Propriété pour accéder facilement au nom de la police
    readonly property string orbitron: "Orbitron"
}
