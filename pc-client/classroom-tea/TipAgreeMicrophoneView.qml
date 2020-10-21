import QtQuick 2.0
import "./Configuuration.js" as Cfg

/*
*继续旁听或者确认上麦页面
*/

Rectangle{
    width: 320 * heightRate
    height: 180 * heightRate
    radius: 12 * heightRate

    signal sigMicrophoneCancenl();//取消上麦
    signal sigMicrophoneOk();//确认上麦

    Text{
        id: tipText1
        text: "上课中的老师同意后才能上麦"
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 16 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 20 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        text: "成功上麦后将由您给学生上课"
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 16 * heightRate
        anchors.top: tipText1.bottom
        anchors.topMargin: 5 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Row{
        width: 260 * heightRate
        height: 40 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20 * heightRate
        spacing: 20 * heightRate

        //继续旁听
        MouseArea{
            width: 120 * heightRate
            height: 40 * heightRate
            cursorShape: Qt.PointingHandCursor

            Rectangle{
                anchors.fill: parent
                color: "#e0e0e0"
                radius: 6 * heightRate
            }

            Text {
                color: "white"
                text: qsTr("继续旁听")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                anchors.centerIn: parent
            }

            onClicked: {
                sigMicrophoneCancenl();
            }
        }

        //确认上麦
        MouseArea{
            width: 120 * heightRate
            height: 40 * heightRate
            cursorShape: Qt.PointingHandCursor

            Rectangle{
                anchors.fill: parent
                color: "#ff5000"
                radius: 6 * heightRate
            }

            Text {
                color: "white"
                text: qsTr("确认上麦")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                anchors.centerIn: parent
            }

            onClicked: {
                sigMicrophoneOk();
            }
        }

    }

}


