import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import "Configuration.js" as Cfg

MouseArea {
    id: waitClassroom
    hoverEnabled: true
    onWheel: {
        return
    }

    onClicked:
    {
        return
    }
    property double widthRates: 180 * widthRate * 0.2

    Rectangle{
        anchors.fill: parent
        color: "black"
        opacity: 0.8
        radius: 12 * heightRate
    }

    property int max: 4;
    property int min: 0;
    property int currentValue: 0;
    property string tips: isStudentUser ?  "进入教室中..." : "正在进入旁听...";

    onVisibleChanged: {
        if(visible){
            playbanner.start();
            enterRoomTimer.stop();
            enterRoomTimer.start();
        }else {
            playbanner.stop();
        }
    }

    Rectangle{
        width: 380 * heightRate
        height: 236 * heightRate
        radius: 6 * heightRate
        color: "white"
        anchors.centerIn: parent

        MouseArea{
            width: 36 * heightRate
            height: 36 * heightRate
            anchors.top: parent.top
//            anchors.topMargin: 10 * heightRate
            cursorShape: Qt.PointingHandCursor
            anchors.right: parent.right
//            anchors.rightMargin: 10 * heightRate
//            visible: false
            Image{
                anchors.fill: parent
                source: "qrc:/images/btn_pop_close_normal.png"
            }
            onClicked: {
                waitClassroom.visible = false
            }
        }

        Column{
            width: parent.width
            height: parent.height * 0.9
            anchors.top: parent.top
            anchors.topMargin: 35 * heightRate
            spacing: 25 * heightRate

            Image{
                width: 92 * heightRate
                height: 92 * heightRate
                source: "qrc:/images/classlogo.png"
                anchors.horizontalCenter: parent.horizontalCenter
                smooth: true
            }
            Rectangle{
                id: progressbarItem
                width: 290 * heightRate
                height: 4 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                color:"#E9E9E9"
                radius: 4 * heightRate
                Rectangle{
                    id: progressBarb
                    z: 2
                    width: parent.width * 0.5
                    height: parent.height
                    radius: 4 * heightRate
                    color: "#ff5000"
                }
            }

            Text{
                text: tips
                color: "#666666"
                font.family: Cfg.CLASSROOM_FAMILY
                font.pixelSize: 20 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 15000;
        running: false;
        repeat: false
        onTriggered:
        {
            waitClassroom.visible = false;
        }
    }
    Timer {
        id: enterRoomTimer
        interval: 20000;
        running: false;
        repeat: false
        onTriggered:
        {
            if(waitClassroom.visible)
            {
                waitClassroom.visible = false;
            }
        }
    }

    function hideAfterSeconds()
    {
        hideTimer.stop();
        hideTimer.start();
    }
}

