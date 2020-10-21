import QtQuick 2.0
import "Configuration.js" as Cfg

MouseArea {
    id: button
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    property string imageUrl: ""
    property string pressedImage: ""
    property string hoverImg: ""
    property string text: ""
    property string hoveredClr: "transparent"
    property string normalClr: "transparent"
    property bool imgzoom: false; //图片缩小显示

    Rectangle {
        anchors.fill: parent
        color: parent.containsMouse ? hoveredClr : normalClr
        radius: 2
    }

    Image {
        id: imageArea
        anchors.fill: parent
        anchors.centerIn: parent
        source: parent.containsMouse ? (parent.pressed ? pressedImage : (hoverImg == "" ? pressedImage : hoverImg)) : (parent.pressed ? pressedImage : button.imageUrl)
        fillMode: Image.PreserveAspectFit
    }
}
