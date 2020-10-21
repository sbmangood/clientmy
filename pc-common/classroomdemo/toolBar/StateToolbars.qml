import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import "./Configuration.js" as Cfg

Item {
    id: stateToolbars
    //屏幕比例
    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;

    property double widthRate: Screen.width * 0.8 / 966.0;
    property double heightRate: widthRate / 1.5337;



    //网络状态与设备状态
    Row {
        height: 30 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 3 * heightRate
        anchors.right: minButton.left
        anchors.rightMargin: 40 * heightRate
        spacing: 30 * heightRate
        Text {
            text: qsTr("网络延迟：") + pingValue + "ms"
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            color: "#333333"
        }
        Text {
            text: qsTr("丢包率：")+ lossrate + "%"
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            color: "#333333"
        }

        Item {
            width: 120 * heightRate
            height: parent.height
            Text {
                id: netText
                text: qsTr("网络状态：")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 18 * heightRate
                color: "#333333"
            }

            Text {
                anchors.left: netText.right
                text: {
                    if(networkValue == 3){
                        color = "#55AE24";
                        return "优";
                    }
                    else if(networkValue == 2){
                        color = "#EECA00";
                        return "良";
                    }
                    else if(networkValue == 1){
                        color = "#FF0000";
                        return "差";
                    }
                    else{
                        return "良";
                    }
                }
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 18 * heightRate
                color: "#333333"
            }
        }

        Text {
            text: qsTr("系统CPU：") + cpuValue + "%"
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            color: "#333333"
        }
    }
}
