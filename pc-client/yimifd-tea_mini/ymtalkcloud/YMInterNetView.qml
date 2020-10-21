import QtQuick 2.0
import "../Configuration.js" as Cfg

Rectangle{
    anchors.fill: parent
    radius: 12 * widthRate

    Image{
        id: netIco
        width: 60 * widthRate
        height: 60 * widthRate
        source: "qrc:/images/icon_nowifi.png"
        anchors.top: parent.top
        anchors.topMargin: (parent.height - (30 * heightRate) * 2 - (10 * heightRate) - height) * 0.5
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Text{
        id: netText
        height: 30 * heightRate
        text: "网络不给力,请检查你的网络设置～"
        color: "#666666"
        anchors.top: netIco.bottom
        anchors.topMargin: 10 * heightRate
        font.family: Cfg.LESSON_FONT_FAMILY
        font.pixelSize: 12 * widthRate
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Rectangle{
        width: 80 * widthRate
        height: 30 * heightRate
        border.color: "#666666"
        border.width: 1
        radius: 4
        anchors.top: netText.bottom
        anchors.topMargin: 10 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        Text{
            text: "刷新"
            color: "#666666"
            font.family: Cfg.LESSON_FONT_FAMILY
            anchors.centerIn: parent
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                queryData();
            }
        }
    }
}

