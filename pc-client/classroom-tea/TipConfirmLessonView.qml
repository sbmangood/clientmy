import QtQuick 2.0
import "./Configuuration.js" as Cfg

/*
*申请上麦页面
*/

Rectangle{
    width: 320 * heightRate
    height: 180 * heightRate
    radius: 12 * heightRate

    signal sigCancelMic();//拒绝上麦
    signal sigMicOk();//确认上麦

    Text{
        id: tipText1
        width: parent.width - 40 * heightRate
        text: "是否已经和学生沟通好，将更换老师上课？"
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 16 * heightRate
        anchors.top: parent.top
        anchors.topMargin: (parent.height - height - 40 * heightRate) * 0.5
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
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
                text: qsTr("否")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                anchors.centerIn: parent
            }

            onClicked: {
                sigCancelMic();
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
                text: qsTr("是")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                anchors.centerIn: parent
            }

            onClicked: {
                sigMicOk();
            }
        }

    }

}


