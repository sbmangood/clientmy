import QtQuick 2.0
import "Configuration.js" as Cfg

/******退出提醒页面********/

MouseArea {
    id: exitTipsItem
    anchors.fill: parent
    hoverEnabled: true
    onWheel: {
        return
    }
    property string tips: "";
    property bool appExit: false;

    signal cancelConfirm();
    signal confirmed();
    signal confirmExit();

    Rectangle{
        color: "black"
        opacity: 0.4
        radius:  12 * widthRate
        anchors.fill: parent
    }

    Rectangle{
        width: 240 * widthRate
        height: 180 * heightRate
        color: "#ffffff"
        radius: 8 * heightRate
        anchors.centerIn: parent

        Item{
            width: parent.width
            height: 40 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 20 * widthRate
            Text{
                text: tips
                anchors.centerIn: parent
                font.family: Cfg.EXIT_FAMILY
                font.pixelSize: (Cfg.EXIT_FONTSIZE  - 2) * widthRate
                color: Cfg.EXIT_FONT_COLOR
            }
        }

        MouseArea{
            width: 120 * widthRate
            height: 40 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 15 * heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin:  15 * heightRate
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                id: cancelItem
                width: 92 * widthRate
                height: 40 * heightRate
                border.color: "#96999c"
                border.width: 1
                anchors.centerIn: parent
                radius: 4 * heightRate
                Text{
                    text: "取消"
                    anchors.centerIn: parent
                    font.family: Cfg.EXIT_FAMILY
                    font.pixelSize: (Cfg.EXIT_FONTSIZE) * heightRate
                    color:"#3c3c3c"
                }
            }
            onClicked: {
                cancelConfirm();
            }
        }

        MouseArea{
            width: 120 * widthRate
            height: 40 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 15 *heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin:  15 * heightRate
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                id: confirmItem
                width: 92 * widthRate
                height: 40 * heightRate
                color: "#ff5000"
                anchors.centerIn: parent
                radius: 4 * heightRate
                Text{
                    text: "确定"
                    anchors.centerIn: parent
                    font.family: Cfg.EXIT_FAMILY
                    font.pixelSize: (Cfg.EXIT_FONTSIZE) * heightRate
                    color: "#ffffff"
                }
            }
            onClicked: {
                if(appExit){
                    confirmExit();
                }else{
                    confirmed();
                }
            }
        }

    }
    //动画过渡
    NumberAnimation {
        id: animateOpacity
        target: exitTipsItem
        duration: 500
        properties: "opacity"
        from: 0.0
        to: 1.0
        onStopped: {
        }
    }
    function startFadeOut()
    {
        animateOpacity.stop();
        animateOpacity.start();
    }
}

