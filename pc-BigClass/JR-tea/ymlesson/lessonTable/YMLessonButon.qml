import QtQuick 2.0
import "../../Configuration.js" as Cfg

MouseArea{
    property bool selected: false;
    property string text: ""
    property bool workTimeVisible: true;

    width: parent.width
    height: parent.height
    Rectangle{
        id: selecteItem
        anchors.fill: parent
        color: parent.pressed ? "#f3f3f3" : "transparent"
    }

    Text{
        text: parent.text
        anchors.centerIn: parent
        font.family: Cfg.LESSON_FONT_FAMILY
        font.pixelSize: Cfg.LESSON_2FONTSIZE * heightRate
    }

    Rectangle{
        width: 1
        height: parent.height
        color: "#e0e0e0"
        anchors.right: parent.right
    }
    //工作时间和非工作时间标示
    Item {
        anchors.fill: parent
        visible: workTimeVisible
        anchors.bottom: parent.bottom
        Image {
            width: 12 * heightRate
            height: 12 * heightRate
            anchors.right: parent.right
            anchors.top: parent.top
            visible: parent.visible
            source: "qrc:/images/th_icon_rest@2x.png"
        }
    }
}
