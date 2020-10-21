import QtQuick 2.0
import "Configuration.js" as Cfg

MouseArea {
    id: button
    width: parent.width
    height: parent.height
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    anchors.verticalCenter: parent.verticalCenter

    property string imageUrl: ""
    property string pressedImage: ""
    property string hoverImg: ""

    Image {
        id: imageArea
        anchors.fill: parent
        anchors.centerIn: parent
        source: parent.containsMouse ? (parent.pressed ? pressedImage : (hoverImg == "" ? pressedImage : hoverImg)) : (parent.pressed ? pressedImage : button.imageUrl)
        fillMode: Image.PreserveAspectFit
    }
}
