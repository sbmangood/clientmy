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
        color: "#666666"
        font.family: Cfg.LESSON_LIST_FAMILY
        font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
        verticalAlignment: Text.AlignVCenter
    }
    Text{
        id: txText2
        text: text2
        height: parent.height
        color: "#333333"
        anchors.left: txText1.right
        font.family: Cfg.LESSON_LIST_FAMILY
        font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
        verticalAlignment: Text.AlignVCenter
    }
}
