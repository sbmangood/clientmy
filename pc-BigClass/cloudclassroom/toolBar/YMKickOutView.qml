import QtQuick 2.0
import "./Configuration.js" as Cfg

Item {
    width: parent.width
    height: parent.height    

    Rectangle{
        anchors.fill: parent
        color: "#000000"
        opacity: 0.4
    }

    MouseArea{
        anchors.fill: parent
        onClicked: {}
    }

    signal sigKickOut();

    Item{
        width: 432 * heightRate
        height: 309 * heightRate
        anchors.centerIn: parent
        z: 1

        Image{
            anchors.fill: parent
            source: "qrc:/lessonMgrImage/bg_pop_leave.png"
        }

        MouseArea{
            width: 150 * heightRate
            height: 44 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24 * heightRate
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/lessonMgrImage/button_pop_leave_focused.png" : "qrc:/lessonMgrImage/button_pop_leave_normal.png"
            }

            onClicked: {
                sigKickOut();
            }
        }
    }

}
