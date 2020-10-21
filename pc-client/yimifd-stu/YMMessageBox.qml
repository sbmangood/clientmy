import QtQuick 2.0
import "Configuration.js" as Cfg

//请求erp接口失败的时候, 使用这个窗口, 来提示错误消息
MouseArea {
    property string tips: "";
    signal confirmed();

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
            width: parent.width
            height: 40*heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24 * heightRate

            MouseArea{
                width: parent.width
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                //anchors.centerIn: parent

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
                    console.log("--------------------1212----------------")
                    confirmed();
                }
            }
        }
    }
}

