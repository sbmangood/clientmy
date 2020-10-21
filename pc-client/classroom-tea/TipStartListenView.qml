import QtQuick 2.0
import "./Configuuration.js" as Cfg

/*
*老师退出是否立即开始上课
*/

Rectangle{
    width: 320 * heightRate
    height: 180 * heightRate
    radius: 12 * heightRate

    signal sigCloseClassroom();//退出教室
    signal sigStartLesson();//立即开始上课
    signal sigTeacherRejoinRoom();//老师返回教室

    Text{
        id: tipText1
        text: "老师已退出，学生停留在教室"
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 16 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 30 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        text: "是否立即开始与学生沟通?"
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

        //退出教室
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
                text: qsTr("不了,退出教室")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                anchors.centerIn: parent
            }

            onClicked: {
                sigCloseClassroom();
            }
        }

        //立即开始
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
                color: "#ffffff"
                text: qsTr("立即开始")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                anchors.centerIn: parent
            }

            onClicked: {

                //判断主麦者是否在线 在线就不在上麦
                if(curriculumData.justUserIsOnline(curriculumData.getCurrentOrderId()))
                {
                    sigTeacherRejoinRoom();
                    return;
                }

                currentIsAttend = false;
                sigStartLesson();
            }
        }
    }
}


