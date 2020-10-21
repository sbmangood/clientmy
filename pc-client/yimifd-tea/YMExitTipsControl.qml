import QtQuick 2.0
import "Configuration.js" as Cfg

MouseArea {
    property string tips: "";
    property bool exitSystem: false;

    signal cancelConfirm();
    signal confirmed();
    signal appExited();

    hoverEnabled: true
    onWheel: {
        return;
    }

    Rectangle{
        color: "black"
        opacity: 0.4
        anchors.fill: parent
    }

    Rectangle{
        width: 250 * widthRate
        height: 180 * heightRate
        color: "#ffffff"
        radius: 8*heightRate
        anchors.centerIn: parent

        Item{
            width: parent.width
            height: 40 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 30 * heightRate
            Text{
                text: tips
                anchors.centerIn: parent
                font.family: Cfg.EXIT_FAMILY
                font.pixelSize: Cfg.EXIT_FONTSIZE * heightRate
                color:"#222222"
            }
        }

        Row{
            width: parent.width*0.9
            height: 40*heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 12*widthRate
            MouseArea{
                width: parent.width * 0.5
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                Rectangle{
                    id: cancelItem
                    width: 92*widthRate
                    height: 43*heightRate
                    border.color: "#96999c"
                    border.width: 1
                    anchors.centerIn: parent
                    radius:4*heightRate
                    Text{
                        text: "取消"
                        anchors.centerIn: parent
                        font.family: Cfg.EXIT_FAMILY
                        font.pixelSize: Cfg.EXIT_BUTTON_FONTSIZE * heightRate
                        color:"#96999c"
                    }
                }
                onClicked: {
                    cancelConfirm();
                }
            }

            MouseArea{
                width: parent.width * 0.5
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                Rectangle{
                    id: confirmItem
                    width: 92*widthRate
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
                    if(exitSystem){
                        appExited();
                    }else{
                        confirmed();
                    }
                }
            }
        }
    }
}

