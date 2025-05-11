import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: waveformView
    
    // Propriétés exposées
    property var waveformData: []
    property double cursorPosition: 0
    property double segmentStart: 0
    property double segmentDuration: 0
    property color waveColor: "#D4AF37"
    property color cursorColor: "#FFFFFF"
    property color segmentColor: "#80D4AF37"
    property color backgroundColor: "#1A1A1A"
    property bool showSegment: true
    property bool interactive: true
    
    // Signaux
    signal cursorMoved(double position)
    
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
            
            // Dessiner le remplissage
            ctx.beginPath();
            ctx.moveTo(0, centerY);
            
            for (var i = 0; i < waveformData.length; i++) {
                var x = (i / waveformData.length) * width;
                var point = waveformData[i];
                var maxY = centerY - (point.max * maxAmplitude);
                var minY = centerY - (point.min * maxAmplitude);
                
                if (i === 0) {
                    ctx.lineTo(x, maxY);
                } else {
                    ctx.lineTo(x, maxY);
                }
            }
            
            for (var j = waveformData.length - 1; j >= 0; j--) {
                var x2 = (j / waveformData.length) * width;
                var point2 = waveformData[j];
                var minY2 = centerY - (point2.min * maxAmplitude);
                
                ctx.lineTo(x2, minY2);
            }
            
            ctx.lineTo(0, centerY);
            ctx.closePath();
            ctx.fill();
            
            // Dessiner les contours
            ctx.beginPath();
            for (var k = 0; k < waveformData.length; k++) {
                var x3 = (k / waveformData.length) * width;
                var point3 = waveformData[k];
                var maxY3 = centerY - (point3.max * maxAmplitude);
                
                if (k === 0) {
                    ctx.moveTo(x3, maxY3);
                } else {
                    ctx.lineTo(x3, maxY3);
                }
            }
            ctx.stroke();
            
            ctx.beginPath();
            for (var l = 0; l < waveformData.length; l++) {
                var x4 = (l / waveformData.length) * width;
                var point4 = waveformData[l];
                var minY4 = centerY - (point4.min * maxAmplitude);
                
                if (l === 0) {
                    ctx.moveTo(x4, minY4);
                } else {
                    ctx.lineTo(x4, minY4);
                }
            }
            ctx.stroke();
            
            // Dessiner la ligne RMS
            ctx.beginPath();
            ctx.strokeStyle = Qt.rgba(waveColor.r, waveColor.g, waveColor.b, 0.7);
            for (var m = 0; m < waveformData.length; m++) {
                var x5 = (m / waveformData.length) * width;
                var point5 = waveformData[m];
                var rmsY = centerY - (point5.rms * maxAmplitude);
                
                if (m === 0) {
                    ctx.moveTo(x5, rmsY);
                } else {
                    ctx.lineTo(x5, rmsY);
                }
            }
            ctx.stroke();
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
        z: -1
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
    
    // Afficher un message si aucune donnée n'est disponible
    Text {
        anchors.centerIn: parent
        text: "No audio data loaded"
        color: "#AAAAAA"
        font.pixelSize: 14
        visible: waveformData.length === 0
    }
}
