import QtQuick 2.0
import "./Configuuration.js" as Cfg

/*
*开始练习、停止练习弹窗
*/

Rectangle {
    id: tipExercise
    color: Qt.rgba(0.5,0.5,0.5,0.6)
    property bool isStart: false;

    signal sigStartExercise();//开始练习信号

    Rectangle{
        width: 240 * widthRate
        height: 240 * heightRate
        anchors.centerIn: parent
        radius: 12 * heightRate
        color: "#ffffff"
        border.width: 1
        border.color: "#eeeeee"

        Text{
            width: parent.width
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            text: "已发给学生开始练题"
            horizontalAlignment: Text.AlignHCenter
            anchors.top: parent.top
            anchors.topMargin: 20 * heightRate
        }

        Column{
            width: parent.width - 40
            height: 100 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 60 * heightRate
            spacing: 5  * heightRate
            anchors.horizontalCenter: parent.horizontalCenter

            Text{
                id: tipsText
                width: parent.width
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                text: qsTr("1、每次可练习一题");
            }
            Text{
                width: parent.width
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                text: "2、学生做完提交后，就可以批改并讲解题目了"
            }
            Text{
                width: parent.width
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                text: "3、您可以随时强制停止练习"
            }
        }

        MouseArea{
            id: cancelButton
            width: 80 * widthRate
            height: 40 * heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            cursorShape: Qt.PointingHandCursor

            Rectangle{
                anchors.fill: parent
                color: "#ff5000"
                radius: 6 * heightRate
            }

            Text {
                text: qsTr("知道了")
                color: "#ffffff"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                anchors.centerIn: parent
            }
            onClicked: {
               sigStartExercise();
            }
        }

    }
}
