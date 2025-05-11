// components/ThemedLabel.qml
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles" as AppStyles

Label {
    id: themedLabel

    font.family: AppStyles.Fonts.orbitron
    font.pixelSize: AppStyles.Theme.fontSizeSmall
    color: AppStyles.Theme.primaryTextColor
    Layout.preferredWidth: AppStyles.Theme.labelWidth
    Layout.alignment: Qt.AlignVCenter
}
