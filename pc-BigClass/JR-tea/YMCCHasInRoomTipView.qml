import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuration.js" as Cfg

/*
* 旁听账号进入教室提醒窗
*/

Item{
    id: ccHasInRoomView
    anchors.fill: parent

    Rectangle{
        color: "black"
        opacity: 0.4
        radius:  12 * widthRate
        anchors.fill: parent
    }

    Rectangle{
        z: 2
        width: 250 * widthRate
        height: 220 * heightRate
        color: "#ffffff"
        radius: 8*heightRate
        anchors.centerIn: parent

        Column{
            width: parent.width
            height: 80 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 50 * heightRate

            Text{
                width: parent.width
                text: "CC/协助CC/CR 其中一人已在教室，无法进入"
                horizontalAlignment: Text.AlignHCenter
                font.family: Cfg.EXIT_FAMILY
                font.pixelSize: 18 * heightRate
                color:"#222222"
            }
        }

        MouseArea{
            width: parent.width * 0.8
            height: 40 * heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 38 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                id: confirmItem
                width:parent.width
                height: 43*heightRate
                color: "#ff5000"

                anchors.centerIn: parent
                radius:4*heightRate
                Text{
                    text: "确定"
                    anchors.centerIn: parent
                    font.family: Cfg.EXIT_FAMILY
                    font.pixelSize: Cfg.EXIT_BUTTON_FONTSIZE * heightRate
                    color: "#ffffff"
                }
            }
            onClicked: {
                ccHasInRoomView.visible = false;
            }
        }

    }


}

