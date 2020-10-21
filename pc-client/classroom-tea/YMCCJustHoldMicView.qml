import QtQuick 2.0
import "Configuuration.js" as Cfg
/*填写试听课报告时 询问老师是否交麦提示*/
MouseArea {
    property string tips: "老师即将开始填写试听课报告，申请将麦交给您，您是否同意上麦？";
    signal ccWhetherHoldMic(var holdMic);//cc是否同意上麦 0 不同意  1 同意
    hoverEnabled: true
    onWheel: {
        return;
    }

    Rectangle{
        width: 250 * widthRate
        height: 180 * heightRate
        color: "#ffffff"
        radius: 8*heightRate
        anchors.centerIn: parent

        Column{
            width: parent.width - 40 * heightRate
            height: 40 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 30 * heightRate
            spacing: 15 * widthRate
            anchors.horizontalCenter: parent.horizontalCenter
            Text{
                text: "老师即将开始填写试听课报告，申请将麦交给您，"
                font.family: "Microsoft YaHei"
                font.pixelSize: 13 * tipDropClassroom.ratesRates
                color:"#222222"
            }

            Text{
                text: "                            您是否同意上麦？"
                width: parent.width
                font.family: "Microsoft YaHei"
                font.pixelSize: 13 * tipDropClassroom.ratesRates
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
                        text: "拒绝"
                        anchors.centerIn: parent
                        font.family: "Microsoft YaHei"
                        font.pixelSize: 18 * tipDropClassroom.ratesRates
                        color:"#96999c"
                    }
                }
                onClicked: {
                    ccWhetherHoldMic(0);
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
                        text: "同意"
                        anchors.centerIn: parent
                        font.family: "Microsoft YaHei"
                        font.pixelSize: 18 * tipDropClassroom.ratesRates
                        color: "#ffffff"
                    }
                }
                onClicked: {
                   ccWhetherHoldMic(1);
                }
            }
        }
    }
}

