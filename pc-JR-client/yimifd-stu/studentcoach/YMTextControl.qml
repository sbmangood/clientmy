import QtQuick 2.0
import "../Configuration.js"as Cfg

Item {
    property string text1: "";
    property string text2: "";

    width: parent.width
    height: parent.height

    Text{
        id: txText1
        text: text1
        height: parent.height
        color: "#999999"
        font.bold: Cfg.LESSON_ALL_FONTBOLD
        font.family: Cfg.LESSON_ALL_FAMILY
        font.pixelSize: 18 * heightRate
        verticalAlignment: Text.AlignVCenter
    }
    Text{
        id: txText2
        text: text2
        height: parent.height
        color: "#666666"
        anchors.left: txText1.right
        font.bold: Cfg.LESSON_ALL_FONTBOLD
        font.family: Cfg.LESSON_ALL_FAMILY
        font.pixelSize: 18 * heightRate
        verticalAlignment: Text.AlignVCenter
    }
}
