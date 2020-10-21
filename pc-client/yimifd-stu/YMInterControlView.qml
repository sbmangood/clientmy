import QtQuick 2.0
import "./Configuration.js" as Cfg

Item {
    width: 120 * widthRate
    height: 120 * widthRate

    property string wifiValue: "5";//ping值
    property string networkTips: ""; //当前网络 ：有线，无线
    property string networkStatus: "";//网络优，良，差, 无
    property int colorGrade: 3;

    Item{
        id: rundView
        width: parent.width - 20 * heightRate
        height: parent.width - 20 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        Image{
            anchors.fill: parent
            source: {
                if(colorGrade == 0){
                    return "qrc:/networkImage/roundNoInter.png";
                }
                if(colorGrade == 3){
                 return "qrc:/networkImage/roundgreen.png";
                }
                if(colorGrade == 2 || colorGrade == 1){
                    return "qrc:/networkImage/roundred.png";
                }

                return "qrc:/networkImage/roundgreen.png";
            }
        }

        Text{
            id: networkText
            text: networkTips
            visible: colorGrade != 0 ? true : false
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.5 - wifiText.height
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text{
            id: wifiText
            text: wifiValue
            visible: colorGrade != 0 ? true : false
            font.pixelSize: 14 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.top: networkText.bottom
            anchors.topMargin: 10 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            color: {
                if(colorGrade == 3)
                    return "green";
                if(colorGrade == 2)
                    return "#df9d39";
                if(colorGrade == 1)
                    return "#ff3f3f";
                if(colorGrade == 0)
                    return "#606070";
                return "#000000";
            }
        }

        Text {
            visible: colorGrade == 0 ? true : false
            text: qsTr("×")
            color: "red"
            anchors.centerIn: parent
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 48 * heightRate
        }
    }

    Text {
        width: parent.width
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 16 * heightRate
        text: networkStatus
        anchors.top: rundView.bottom
        anchors.topMargin: 5 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

}
