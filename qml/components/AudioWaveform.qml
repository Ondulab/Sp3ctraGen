import QtQuick 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.15
import "../styles" as AppStyles

Rectangle {
    id: waveformView
    
    // Propriétés exposées
    property var waveformData: []
    property double cursorPosition: 0
    property double segmentStart: 0
    property double segmentDuration: 0
    property color waveColor: AppStyles.Theme.primaryTextColor
    property color cursorColor: "#FFFFFF"
    property color segmentColor: "#B04285F4"  // Bleu semi-transparent (augmentation de l'opacité)
    property color segmentBorderColor: "#FF4285F4"  // Bleu opaque pour la bordure
    property color backgroundColor: "#1A1A1A"
    property bool showSegment: true
    property bool interactive: true
    property string audioSource: ""
    property real totalDuration: 0
    property bool isPlaying: false
    
    // Signaux
    signal cursorMoved(double position)
    signal playbackStarted()
    signal playbackStopped()
    
    // Propriétés internes
    color: backgroundColor
    
    // Canvas pour dessiner la forme d'onde
    Canvas {
        id: waveformCanvas
        anchors.fill: parent
        
        // Méthode de dessin de la forme d'onde
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            
            if (waveformData.length === 0) {
                return;
            }
            
            // Calculer le centre vertical
            var centerY = height / 2;
            var maxAmplitude = height / 2 * 0.9; // 90% de la moitié de la hauteur
            
            // Dessiner la forme d'onde
            ctx.lineWidth = 1;
            ctx.strokeStyle = waveColor;
            ctx.fillStyle = Qt.rgba(waveColor.r, waveColor.g, waveColor.b, 0.2);
            
            // Vérifier le format des données (objet ou valeur simple)
            var isObjectData = typeof waveformData[0] === 'object';
            
            // Dessiner le remplissage
            ctx.beginPath();
            ctx.moveTo(0, centerY);
            
            for (var i = 0; i < waveformData.length; i++) {
                var x = (i / waveformData.length) * width;
                var y;
                
                if (isObjectData) {
                    // Format avec objets {min, max, rms}
                    y = centerY - (waveformData[i].max * maxAmplitude);
                } else {
                    // Format avec valeurs simples (comme dans simple_ui.qml)
                    y = centerY - (waveformData[i] * maxAmplitude);
                }
                
                if (i === 0) {
                    ctx.lineTo(x, y);
                } else {
                    ctx.lineTo(x, y);
                }
            }
            
            if (isObjectData) {
                // Compléter le chemin pour les données d'objet
                for (var j = waveformData.length - 1; j >= 0; j--) {
                    var x2 = (j / waveformData.length) * width;
                    var y2 = centerY - (waveformData[j].min * maxAmplitude);
                    ctx.lineTo(x2, y2);
                }
            } else {
                // Compléter le chemin pour les données simples
                for (var j2 = waveformData.length - 1; j2 >= 0; j2--) {
                    var x2b = (j2 / waveformData.length) * width;
                    var y2b = centerY + (waveformData[j2] * maxAmplitude);
                    ctx.lineTo(x2b, y2b);
                }
            }
            
            ctx.lineTo(0, centerY);
            ctx.closePath();
            ctx.fill();
            
            // Pour les données d'objet, dessiner les contours et RMS
            if (isObjectData) {
                // Dessiner les contours supérieurs
                ctx.beginPath();
                for (var k = 0; k < waveformData.length; k++) {
                    var x3 = (k / waveformData.length) * width;
                    var y3 = centerY - (waveformData[k].max * maxAmplitude);
                    
                    if (k === 0) {
                        ctx.moveTo(x3, y3);
                    } else {
                        ctx.lineTo(x3, y3);
                    }
                }
                ctx.stroke();
                
                // Dessiner les contours inférieurs
                ctx.beginPath();
                for (var l = 0; l < waveformData.length; l++) {
                    var x4 = (l / waveformData.length) * width;
                    var y4 = centerY - (waveformData[l].min * maxAmplitude);
                    
                    if (l === 0) {
                        ctx.moveTo(x4, y4);
                    } else {
                        ctx.lineTo(x4, y4);
                    }
                }
                ctx.stroke();
                
                // Dessiner la ligne RMS
                ctx.beginPath();
                ctx.strokeStyle = Qt.rgba(waveColor.r, waveColor.g, waveColor.b, 0.7);
                for (var m = 0; m < waveformData.length; m++) {
                    var x5 = (m / waveformData.length) * width;
                    var y5 = centerY - (waveformData[m].rms * maxAmplitude);
                    
                    if (m === 0) {
                        ctx.moveTo(x5, y5);
                    } else {
                        ctx.lineTo(x5, y5);
                    }
                }
                ctx.stroke();
            } else {
                // Pour les données simples, dessiner juste le contour
                ctx.beginPath();
                for (var n = 0; n < waveformData.length; n++) {
                    var x6 = (n / waveformData.length) * width;
                    var y6 = centerY - (waveformData[n] * maxAmplitude);
                    
                    if (n === 0) {
                        ctx.moveTo(x6, y6);
                    } else {
                        ctx.lineTo(x6, y6);
                    }
                }
                ctx.stroke();
            }
        }
    }
    
    // Zone du segment à extraire
    Rectangle {
        id: segmentIndicator
        x: segmentStart * parent.width
        width: segmentDuration * parent.width
        height: parent.height
        color: segmentColor
        visible: showSegment
        z: 5  // Valeur positive mais inférieure au curseur (z: 10)
        
        // Ajouter une bordure pour mieux délimiter la zone
        border.width: 1
        border.color: segmentBorderColor
    }
    
    // Curseur mobile
    Rectangle {
        id: cursor
        width: 2
        height: parent.height
        x: cursorPosition * parent.width - width / 2
        color: cursorColor
        z: 10
        
        // Poignée du curseur pour faciliter la manipulation
        Rectangle {
            id: cursorHandle
            width: 14
            height: 14
            radius: 7
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 5
            color: cursorColor
            
            // Effet de brillance
            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: 5
                color: Qt.lighter(cursorColor, 1.5)
            }
        }
    }
    
    // Zone de détection des interactions souris/tactile
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: interactive
        
        onClicked: {
            if (!interactive) return;
            
            var newPos = Math.max(0, Math.min(1, mouseX / width));
            cursorPosition = newPos;
            cursorMoved(cursorPosition);
        }
        
        onPositionChanged: {
            if (!interactive || !pressed) return;
            
            var newPos = Math.max(0, Math.min(1, mouseX / width));
            cursorPosition = newPos;
            cursorMoved(cursorPosition);
        }
    }
    
    // Mettre à jour le canvas lorsque les données changent
    onWaveformDataChanged: {
        waveformCanvas.requestPaint();
    }
    
    // Fonction pour forcer explicitement le redessinage du canvas
    function forceRedraw() {
        console.log("AudioWaveform: forceRedraw called");
        
        // Peut-être que les données n'ont pas été détectées comme changées
        // si c'est juste leurs propriétés internes qui ont été modifiées
        waveformCanvas.requestPaint();
        
        // Astuce pour forcer le QML à recalculer le layout
        var oldHeight = height;
        height = oldHeight + 0.1;
        height = oldHeight;
    }
    
    // Afficher un message si aucune donnée n'est disponible
    Text {
        anchors.centerIn: parent
        text: "No audio data loaded"
        color: "#AAAAAA"
        font.pixelSize: 14
        visible: waveformData.length === 0
    }
    
    // Composant Audio pour la lecture
    Audio {
        id: audioPlayer
        source: audioSource
        
        onPositionChanged: {
            // Si nous atteignons la fin du segment, arrêter la lecture
            if (position >= duration) {
                stop();
            }
        }
        
        onPlaybackStateChanged: {
            if (playbackState === Audio.PlayingState) {
                isPlaying = true;
                playbackStarted();
            } else {
                isPlaying = false;
                playbackStopped();
            }
        }
    }
    
    // Fonction pour basculer entre lecture et pause
    function togglePlayback() {
        console.log("togglePlayback() called");
        console.log("  audioSource:", audioSource);
        console.log("  totalDuration:", totalDuration);
        console.log("  segmentStart:", segmentStart);
        console.log("  segmentDuration:", segmentDuration);
        
        // Ne pas vérifier l'audioSource pour l'instant, pour diagnostiquer
        // Note: en production, il faudrait rétablir cette vérification
        /*
        if (!audioSource || audioSource === "") {
            console.log("No audio source set");
            return;
        }
        */
        
        if (isPlaying) {
            console.log("Stopping playback");
            audioPlayer.pause();
            isPlaying = false;
        } else {
            console.log("Starting playback");
            // Définir la position de départ au début du segment
            var startTime = segmentStart * totalDuration * 1000; // en millisecondes
            var segmentEndTime = (segmentStart + segmentDuration) * totalDuration * 1000;
            
            console.log("  startTime:", startTime);
            console.log("  segmentEndTime:", segmentEndTime);
            
            // Tenter de lire même si les conditions ne sont pas idéales
            try {
                audioPlayer.seek(startTime);
                audioPlayer.play();
                isPlaying = true;
                console.log("  Play command sent");
            } catch (e) {
                console.error("Error playing audio:", e);
            }
        }
    }
    
    // Méthode pour arrêter explicitement la lecture
    function stopPlayback() {
        if (isPlaying) {
            audioPlayer.stop();
            isPlaying = false;
        }
    }
    
    // Méthode pour définir la source audio et la durée totale
    function setAudioSource(source, duration) {
        audioSource = source;
        totalDuration = duration;
    }
}
