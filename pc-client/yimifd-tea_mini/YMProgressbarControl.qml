import QtQuick 2.0
import QtQuick.Controls 1.4
import "Configuration.js" as Cfg

MouseArea {
    id: pbarView
    z: 66667
    anchors.fill: parent
    hoverEnabled: true
    onWheel: {
        return
    }

    Rectangle{
        anchors.fill: parent
        color: "black"
        opacity: 0.4
        radius:  12 * widthRate
    }

    property int min: 0;
    property int max: 100;
    property int currentValue: 0;

    Rectangle{
        width: 200 * widthRate
        height: 200 * heightRate
        radius: 6
        color: "white"
        anchors.centerIn: parent

        MouseArea{
            width: 10 * widthRate
            height: 10 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10

            Image{
                anchors.fill: parent
                source: "qrc:/images/bar_btn_close.png"
            }
            onClicked: {
                pbarView.visible = false;
            }
        }

        Image{
            id: logoImg
            width: 40 * widthRate
            height: 40 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 20 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/images/sdcr_dialog_videodownload.png"
        }

        ProgressBar{
            id: progressbar
            minimumValue: min
            maximumValue: max
            height: 15 * heightRate
            value: currentValue
            width: parent.width  * 0.78
            anchors.top: logoImg.bottom
            anchors.topMargin: 20 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label{
            id: lbValue
            text: {
                if(currentValue == max){
                   return 100 + "%";
                }
                Math.floor(currentValue / max * 100) + "%"
            }
            height: 15
            font.family: Cfg.RECORD_FAMILY
            font.pixelSize: Cfg.RECORD_FONTSIEZ * heightRate
            anchors.left: progressbar.right
            anchors.leftMargin: 2 * heightRate
            anchors.top: logoImg.bottom
            anchors.topMargin: 20 * heightRate
        }

        Text{
            text: "录播视频下载中..."
            font.family: Cfg.RECORD_FAMILY
            font.pixelSize: Cfg.RECORD_FONTSIEZ * widthRate
            anchors.top: progressbar.bottom
            anchors.topMargin: 30 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}

