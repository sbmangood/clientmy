import QtQuick 2.0
import "./Configuration.js" as Cfg

Item {
    width: 28 * heightRate
    height: parent.height

    property string itemStr: "";//选项文本
    property int itemNum: 0;//选项人数
    property color colorValue: "#35D0B0";//#4D90FF

    visible: itemStr == "" ? false : true;

    Text {
        id: numText
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 18 * heightRate
        color: "#ffffff"
        text: itemNum
        anchors.bottom: recView.top
        anchors.bottomMargin: 4 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle{
        id: recView
        width: 28 * heightRate
        height: 1 * (itemNum > 140 ? 140 : itemNum )
        color: colorValue
        anchors.bottom: itemText.top
        anchors.bottomMargin: 10 * heightRate
    }

    Text {
        id: itemText
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 18 * heightRate
        color: "#ffffff"
        text: itemStr
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

}
