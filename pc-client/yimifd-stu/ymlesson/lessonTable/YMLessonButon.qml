import QtQuick 2.0
import "../../Configuration.js" as Cfg

MouseArea{
    property bool selected: false;
    property string text: ""

    width: parent.width
    height: parent.height


//    Rectangle{
//        id: selecteItem
//        anchors.fill: parent
//        color: parent.pressed ? Cfg.BTN_PRESSED_CLR : "transparent"
//    }

    Text{
        text: parent.text
        anchors.centerIn: parent
    }
    Rectangle{
        width: 1
        height: parent.height
        color: "#e0e0e0"
        anchors.right: parent.right
    }
}
