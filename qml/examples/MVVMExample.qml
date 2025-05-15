import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.Sp3ctraGen.backend 1.0
import "../components"
import "../styles" as AppStyles

/**
 * Exemple d'utilisation du modèle MVVM
 * Ce fichier montre comment utiliser le nouveau modèle de paramètres unifié et le ViewModel
 * pour simplifier l'interface QML et améliorer la séparation des responsabilités.
 */
Rectangle {
    id: demoContainer
    width: 800
    height: 600
    color: "#222"
    
    // ViewModel et modèle de paramètres (exposés par le contexte)
    // property SpectrogramViewModel viewModel: null
    // property SpectrogramParametersModel paramsModel: null
    
    // Variables pour suivre la progression
    property real progressValue: 0
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // ===== Titre =====
        Text {
            Layout.fillWidth: true
            text: "Démonstration MVVM"
            color: "white"
            font.pixelSize: 24
            font.bold: true
        }
        
        // ===== Section Paramètres =====
        GroupBox {
            Layout.fillWidth: true
            title: "Paramètres de base"
            
            background: Rectangle {
                color: "#333"
                border.color: "#555"
                radius: 5
            }
            
            label: Label {
                text: parent.title
                color: "white"
                font.bold: true
                bottomPadding: 5
            }
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                
                // Liaison bidirectionnelle avec le modèle de paramètres
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text { 
                        text: "Fréq. Min (Hz):" 
                        color: "white" 
                        Layout.preferredWidth: 100
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: paramsModel.minFreq
                        onTextChanged: {
                            if (text !== "" && !isNaN(parseFloat(text))) {
                                paramsModel.minFreq = parseFloat(text)
                            }
                        }
                        color: "white"
                        background: Rectangle { color: "#444" }
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text { 
                        text: "Fréq. Max (Hz):" 
                        color: "white" 
                        Layout.preferredWidth: 100
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: paramsModel.maxFreq
                        onTextChanged: {
                            if (text !== "" && !isNaN(parseFloat(text))) {
                                paramsModel.maxFreq = parseFloat(text)
                            }
                        }
                        color: "white"
                        background: Rectangle { color: "#444" }
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text { 
                        text: "Vitesse (cm/s):" 
                        color: "white" 
                        Layout.preferredWidth: 100
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: paramsModel.writingSpeed
                        onTextChanged: {
                            if (text !== "" && !isNaN(parseFloat(text))) {
                                paramsModel.writingSpeed = parseFloat(text)
                            }
                        }
                        color: "white"
                        background: Rectangle { color: "#444" }
                    }
                }
                
                // Curseur de résolution avec mise à jour groupée
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text { 
                        text: "Résolution:" 
                        color: "white" 
                    }
                    
                    Slider {
                        id: resolutionSlider
                        Layout.fillWidth: true
                        from: 0.0
                        to: 1.0
                        value: paramsModel.resolutionSliderValue
                        
                        // Utilisation d'un timer pour éviter des mises à jour trop fréquentes
                        Timer {
                            id: updateTimer
                            interval: 100
                            running: false
                            repeat: false
                            onTriggered: {
                                paramsModel.resolutionSliderValue = resolutionSlider.value
                            }
                        }
                        
                        onValueChanged: {
                            updateTimer.restart()
                        }
                    }
                    
                    Row {
                        Layout.fillWidth: true
                        Text { text: "Temporel"; color: "#aaa"; font.pixelSize: 12 }
                        Item { width: parent.width - 150; height: 1 }
                        Text { text: "Spectral"; color: "#aaa"; font.pixelSize: 12 }
                    }
                }
                
                // Exemple de mise à jour groupée
                Button {
                    text: "Appliquer les changements"
                    Layout.fillWidth: true
                    
                    onClicked: {
                        // Début de la mise à jour groupée
                        paramsModel.beginUpdate();
                        
                        // Toutes ces mises à jour ne déclencheront les recalculs qu'une seule fois
                        paramsModel.minFreq = 30;
                        paramsModel.maxFreq = 18000;
                        paramsModel.writingSpeed = 3.0;
                        paramsModel.resolutionSliderValue = 0.5;
                        
                        // Fin de la mise à jour groupée
                        paramsModel.endUpdate();
                    }
                }
            }
        }
        
        // ===== Section Valeurs Calculées =====
        GroupBox {
            Layout.fillWidth: true
            title: "Valeurs calculées et mises en cache"
            
            background: Rectangle {
                color: "#333"
                border.color: "#555"
                radius: 5
            }
            
            label: Label {
                text: parent.title
                color: "white"
                font.bold: true
                bottomPadding: 5
            }
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                
                // Les valeurs calculées sont automatiquement mises à jour et mises en cache
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 5
                    
                    Text { text: "Taille FFT:"; color: "white" }
                    Text { 
                        text: paramsModel.fftSize.toString(); 
                        color: "#66ff66"
                        font.bold: true 
                    }
                    
                    Text { text: "Bins par seconde:"; color: "white" }
                    Text { 
                        text: paramsModel.binsPerSecond.toFixed(1); 
                        color: "#66ff66" 
                        font.bold: true
                    }
                    
                    Text { text: "Overlap effectif:"; color: "white" }
                    Text { 
                        text: (paramsModel.effectiveOverlap * 100).toFixed(1) + "%"; 
                        color: "#66ff66"
                        font.bold: true
                    }
                    
                    Text { text: "Limite atteinte:"; color: "white" }
                    Text { 
                        text: paramsModel.isResolutionLimited() ? "Oui" : "Non"; 
                        color: paramsModel.isResolutionLimited() ? "#ff6666" : "#66ff66"
                        font.bold: true
                    }
                }
                
                // Bouton pour forcer le recalcul
                Button {
                    text: "Forcer recalcul"
                    Layout.fillWidth: true
                    
                    onClicked: {
                        // Réinitialiser le cache en modifiant une valeur qui affecte les calculs
                        paramsModel.resolutionSliderValue = paramsModel.resolutionSliderValue + 0.01;
                        if (paramsModel.resolutionSliderValue > 1.0) {
                            paramsModel.resolutionSliderValue = 0.0;
                        }
                    }
                }
            }
        }
        
        // ===== Section Actions ViewModel =====
        GroupBox {
            Layout.fillWidth: true
            title: "Actions ViewModel"
            
            background: Rectangle {
                color: "#333"
                border.color: "#555"
                radius: 5
            }
            
            label: Label {
                text: parent.title
                color: "white"
                font.bold: true
                bottomPadding: 5
            }
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                
                // Actions principales
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Button {
                        text: "Générer Aperçu"
                        Layout.fillWidth: true
                        enabled: !viewModel.isGenerating
                        
                        onClicked: {
                            viewModel.generatePreview("sample.wav")
                        }
                    }
                    
                    Button {
                        text: "Sauvegarder Aperçu"
                        Layout.fillWidth: true
                        enabled: !viewModel.isGenerating && viewModel.hasPreview
                        
                        onClicked: {
                            viewModel.saveCurrentPreview("/tmp/preview.png", "png");
                        }
                    }
                }
                
                // État et progression
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#444"
                    radius: 3
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 2
                        
                        Text {
                            id: statusText
                            Layout.fillWidth: true
                            text: viewModel.statusMessage
                            color: viewModel.isGenerating ? "orange" : "lightgreen"
                            elide: Text.ElideRight
                            font.pixelSize: 14
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            visible: viewModel.isGenerating
                            color: "#222"
                            
                            Rectangle {
                                width: parent.width * progressValue / 100
                                height: parent.height
                                color: "orange"
                            }
                        }
                    }
                }
            }
        }
        
        Item {
            Layout.fillHeight: true
        }
    }
    
    // ===== Connexion aux signaux =====
    Component.onCompleted: {
        // Connexion au signal de progression
        viewModel.progressUpdated.connect(function(progress, message) {
            progressValue = progress;
        });
        
        // Connexion aux signaux de génération
        viewModel.previewGenerated.connect(function(success, errorMessage) {
            if (!success) {
                console.error("Erreur de génération: " + errorMessage);
            }
        });
        
        viewModel.previewSaved.connect(function(success, outputPath, format, errorMessage) {
            if (success) {
                console.log("Aperçu sauvegardé: " + outputPath);
            } else {
                console.error("Erreur de sauvegarde: " + errorMessage);
            }
        });
    }
}
