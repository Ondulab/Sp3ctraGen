import QtQuick 2.15
import QtQuick.Controls 2.15
import com.spectrogen.constants 1.0

/**
 * Bouton animé avec états (normal, processing, success)
 * 
 * Ce composant fournit un bouton avec des animations et des états
 * pour indiquer visuellement le statut d'une opération.
 */
Button {
    id: animatedButton
    
    property bool isAnimating: false
    property bool isProcessing: false
    property string originalText: text
    property string successText: "Success!"
    property string processingText: "Processing..."
    property string buttonState: "normal" // "normal", "processing", "success", "error"
    
    font.family: orbitronFont.name
    font.pixelSize: Constants.labelFontSize
    
    // Signal émis lorsque le traitement doit commencer
    signal processingStarted()
    
    // Timer pour retarder le démarrage du traitement après l'animation de clic
    Timer {
        id: clickDelayTimer
        interval: 150
        repeat: false
        onTriggered: {
            // Démarrer l'animation de traitement
            animatedButton.startProcessingAnimation()
            
            // Émettre le signal pour indiquer que le traitement doit commencer
            animatedButton.processingStarted()
        }
    }
    
    // Timer pour revenir à l'état normal
    Timer {
        id: resetTimer
        interval: 1500
        onTriggered: {
            // Animation de retour à l'état normal
            returnToNormalAnimation.start()
        }
    }
    
    // Indicateur de progression circulaire
    BusyIndicator {
        id: progressIndicator
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: width
        running: false
        visible: false
        
        // Style personnalisé pour l'indicateur
        contentItem: Item {
            implicitWidth: 64
            implicitHeight: 64
            
            Rectangle {
                id: indicatorItem
                anchors.centerIn: parent
                width: parent.width
                height: width
                radius: width / 2
                color: "transparent"
                border.width: width * 0.1
                border.color: Constants.primaryTextColor
                opacity: 0.0
                
                RotationAnimation {
                    target: indicatorItem
                    running: progressIndicator.running
                    from: 0
                    to: 360
                    duration: 1500
                    loops: Animation.Infinite
                }
                
                // Animation d'apparition
                NumberAnimation {
                    target: indicatorItem
                    property: "opacity"
                    from: 0.0
                    to: 0.8
                    duration: 300
                    running: progressIndicator.running
                }
            }
        }
    }
    
    // Animation de succès sobre
    SequentialAnimation {
        id: successAnimation
        
        ParallelAnimation {
            // Changement de couleur vers la couleur de succès
            ColorAnimation {
                target: animatedButton.background
                property: "color"
                to: Constants.successColor
                duration: 200
            }
            
            // Légère augmentation de taille pour attirer l'attention
            NumberAnimation {
                target: animatedButton
                property: "scale"
                to: 1.05
                duration: 200
                easing.type: Easing.OutBack
            }
        }
    }
    
    // Animation de retour à l'état normal
    SequentialAnimation {
        id: returnToNormalAnimation
        
        ParallelAnimation {
            // Retour à la couleur normale
            ColorAnimation {
                target: animatedButton.background
                property: "color"
                to: Constants.buttonBackground
                duration: 300
            }
            
            // Retour à la taille normale
            NumberAnimation {
                target: animatedButton
                property: "scale"
                to: 1.0
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
        
        // Réinitialisation des propriétés
        ScriptAction {
            script: {
                animatedButton.resetState();
            }
        }
    }
    
    // Animation de clic améliorée avec retour visuel immédiat
    SequentialAnimation {
        id: clickAnimation
        alwaysRunToEnd: true
        
        ParallelAnimation {
            // Animation de réduction d'échelle
            NumberAnimation {
                target: animatedButton
                property: "scale"
                from: 1.0
                to: 0.92
                duration: 100
                easing.type: Easing.OutQuad
            }
            
            // Animation de couleur pour un feedback visuel plus fort
            ColorAnimation {
                target: animatedButton.background
                property: "color"
                to: Qt.darker(Constants.buttonBackground, 1.3)
                duration: 100
            }
        }
        
        ParallelAnimation {
            // Retour à l'état normal ou transition vers l'état de traitement
            NumberAnimation {
                target: animatedButton
                property: "scale"
                from: 0.92
                to: 1.0
                duration: 150
                easing.type: Easing.OutBack
                easing.overshoot: 1.5
            }
        }
    }
    
    // Fonctions pour gérer les états du bouton
    function startSuccessAnimation() {
        isAnimating = true
        isProcessing = false
        buttonState = "success"
        progressIndicator.running = false
        progressIndicator.visible = false
        
        // Changer immédiatement le texte
        text = successText
        
        // Animation de succès sobre
        successAnimation.start()
        
        // Timer pour revenir à l'état normal
        resetTimer.start()
    }
    
    function startProcessingAnimation() {
        isProcessing = true
        buttonState = "processing"
        text = processingText
        progressIndicator.visible = true
        progressIndicator.running = true
        background.opacity = 0.7 // Réduire l'opacité du fond pour mettre en évidence l'indicateur
    }
    
    function stopProcessingAnimation() {
        isProcessing = false
        progressIndicator.running = false
        progressIndicator.visible = false
        background.opacity = 1.0
    }
    
    function resetState() {
        buttonState = "normal"
        text = originalText
        isAnimating = false
        isProcessing = false
        scale = 1.0
        background.color = Constants.buttonBackground
        background.opacity = 1.0
    }
    
    // Gestion du clic
    onClicked: {
        // Vérifier si le bouton n'est pas déjà en cours de traitement
        if (buttonState === "processing") return
        
        // Animation de clic avec retour visuel immédiat
        clickAnimation.start()
        
        // Démarrer le timer pour retarder le démarrage du traitement
        clickDelayTimer.start()
    }
    
    // Style du bouton
    background: Rectangle {
        color: parent.hovered && !parent.isProcessing ? Constants.buttonHoverBackground : Constants.buttonBackground
        radius: Constants.borderRadius
        implicitHeight: 40
        
        // Effet de lueur pour l'état de succès
        Rectangle {
            id: glowEffect
            anchors.fill: parent
            anchors.margins: -4
            radius: parent.radius + 4
            color: "transparent"
            border.width: 2
            border.color: Constants.successColor
            opacity: 0
            
            // Animation de pulsation pour l'effet de lueur
            SequentialAnimation {
                running: animatedButton.buttonState === "success"
                loops: 1
                
                NumberAnimation {
                    target: glowEffect
                    property: "opacity"
                    from: 0
                    to: 0.8
                    duration: 300
                    easing.type: Easing.OutCubic
                }
                
                NumberAnimation {
                    target: glowEffect
                    property: "opacity"
                    from: 0.8
                    to: 0
                    duration: 800
                    easing.type: Easing.InCubic
                }
            }
        }
        
        Behavior on color {
            ColorAnimation { 
                duration: Constants.animationDuration
            }
        }
        
        Behavior on opacity {
            NumberAnimation { 
                duration: Constants.animationDuration
            }
        }
    }
    
    contentItem: Item {
        implicitWidth: buttonText.implicitWidth
        implicitHeight: buttonText.implicitHeight
        
        Text {
            id: buttonText
            anchors.centerIn: parent
            text: parent.parent.text
            font.family: orbitronFont.name
            font.pixelSize: Constants.labelFontSize
            color: parent.parent.hovered || parent.parent.isAnimating || parent.parent.isProcessing ? Constants.buttonHoverText : Constants.buttonText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            
            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }
    }
}