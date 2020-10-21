import QtQuick 2.0
import "./Configuuration.js" as Cfg

/*
*停止练习弹窗
*/

Rectangle {
    id: tipStopExercise
    color: Qt.rgba(0.5,0.5,0.5,0.6)

    signal sigStopExercise(var status);//停止练习信号

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
            text: "学生还未完成,确认需要停止练习吗?"
            horizontalAlignment: Text.AlignHCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.5 - 20
        }

        Row{
            width: parent.width * 0.8
            height: 20 * heightRates
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter

            spacing: 10 * heightRates

            MouseArea{
                width: parent.width  * 0.5
                height:  40 * heightRates
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRates
                    color: "#ffffff"
                    border.color: "#cccccc"
                    border.width: 1
                }

                Text {
                    text: qsTr("取消")
                    color:  "#cccccc"
                    font.pixelSize: 14 * heightRates
                    font.family: Cfg.font_family
                    anchors.centerIn: parent
                }
                onClicked: {
//                    console.log("=====types::types===== heightRates",  heightRates, widthRate, tipStopExercise.height, tipStopExercise.width)
                    sigStopExercise(false);
                    tipStopExercise.visible = false;
                }
            }

            MouseArea{
                width: parent.width  * 0.5
                height:  40 * heightRates
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRates
                    color: "#ff5000"
                    border.color: "#cccccc"
                    border.width: 1
                }

                Text {
                    text: qsTr("确认")
                    color:  "#ffffff"
                    font.pixelSize: 14 * heightRates
                    font.family: Cfg.font_family
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigStopExercise(true);
                    tipStopExercise.visible = false;
                }
            }
        }

    }
}

