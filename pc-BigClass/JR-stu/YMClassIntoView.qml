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
        opacity: 0.4
        radius: 12 * heightRate
    }

    property int max: 4;
    property int min: 0;
    property int currentValue: 0;
    property string tips: isStudentUser ?  "正在进入教室..." : "正在进入旁听...";

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
        width: 220 * widthRate
        height: 110 * heightRate
        radius: 6 * heightRate
        color: "white"
        anchors.centerIn: parent

        MouseArea{
            width: 14 * heightRate
            height: 14 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 10 * heightRate
            cursorShape: Qt.PointingHandCursor
            anchors.right: parent.right
            anchors.rightMargin: 10 * heightRate
            visible: false
            Image{
                anchors.fill: parent
                source: "qrc:/images/bar_btn_close.png"
            }
            onClicked: {
                waitClassroom.visible = false
            }
        }

        Column{
            width: parent.width
            height: parent.height * 0.9
            anchors.top: parent.top
            anchors.topMargin: 33 * heightRate
            spacing: 20 * heightRate

            Image{
                width: 48 * widthRate
                height: 48 * widthRate
                source: "qrc:/images/classlogo.png"
                anchors.horizontalCenter: parent.horizontalCenter
                smooth: true
                visible: false
            }
            Rectangle{
                id: progressbarItem
                width: parent.width * 0.9
                height: 8 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                color:"#ff5000"
                radius: 5 * heightRate
                Rectangle{
                    id: progressBarb
                    z: 2
                    width: parent.width * 0.2
                    height: parent.height * 0.95
                    radius: 5 * heightRate
                    //color: "#ff5000"
                    LinearGradient{
                        anchors.fill: parent;
                        gradient: Gradient{
                            GradientStop{
                                position: 0.0;
                                color:  "#ff5000";
                            }
                            GradientStop{
                                position: 0.5;
                                color:"#FFEA4E";
                            }
                            GradientStop{
                                position: 1.0;
                                color: "#ff5000";
                            }
                        }
                        start:Qt.point(0, 0);
                        end: Qt.point(parent.width, 0);
                    }
                }
            }

            Text{
                text: tips
                font.family: Cfg.CLASSROOM_FAMILY
                font.pixelSize: Cfg.CLASSROOM_FONTSIZE * widthRate
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    //滚动动画
    SequentialAnimation {
        id: playbanner
        running: true
        loops:  Animation.Infinite
        NumberAnimation {
            target: progressBarb;
            property: "x";
            from: 0
            to: progressbarItem.width - progressBarb.width;
            duration: 1000
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

