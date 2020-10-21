import QtQuick 2.0
import "./Configuuration.js" as Cfg

/*
*新老讲义消息提醒框
*/

MouseArea {
    id: versionView

    Rectangle{
        border.color: "#c0c0c0"
        border.width: 1
        radius: 12 * heightRate
        anchors.fill: parent
    }

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    signal sigOk();//同意信号

    Item{
        id: backView
        width: 240 * widthRates;
        height: 180 * heightRates;
        //radius:  6
        anchors.centerIn: parent
        //color: "#ffffff"

        MouseArea{
            width: parent.width * 0.8
            height: 30 * heightRates
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            cursorShape: Qt.PointingHandCursor


            Rectangle{
                anchors.fill: parent
                radius: 6 * heightRates
                color: "#ff5000"
                border.color: "#cccccc"
                border.width: 1
            }

            Text {
                text: qsTr("确定")
                color:  "#ffffff"
                font.pixelSize: 14 * heightRates
                font.family: Cfg.font_family
                anchors.centerIn: parent
            }

            onClicked: {
                versionView.visible = false;
            }
        }
    }

    Column{
        width: backView.width * 0.8
        height: backView.height
        anchors.top: backView.top
        anchors.topMargin: 25 * heightRates
        anchors.horizontalCenter: backView.horizontalCenter
        spacing: 5 * widthRates

        Text{
            width: parent.width
            text: "您的学生软件版本太低,无法使用最新讲义,请让学生更新至最新版本3.0或直接使用老版讲义上课!"
            wrapMode: Text.WordWrap
            font.family: Cfg.font_family
            font.pixelSize: 12 * heightRates
            horizontalAlignment: Text.AlignHCenter
        }
    }

}
