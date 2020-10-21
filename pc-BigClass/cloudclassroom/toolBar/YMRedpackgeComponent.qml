import QtQuick 2.0
import "./Configuration.js" as Cfg

Item {
    width: 172 * heightRate
    height: 172 * heightRate

    property string number: "-1";

    //展示抢到红包结果值
    Image{
        id: redPackgeImg
        anchors.fill: parent
        source: "qrc:/redPackge/hbk.png"

        Text {
            font.pixelSize: 18 * heightRate
            font.family: Cfg.DEFAULT_FONT
            font.bold: true
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40 * heightRate
            visible: number == "-1" ? false : true
            text: "+" + number
            color: "#ffffff"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
