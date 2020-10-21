import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtQuick.Window 2.0

/**
*@brief 网络状态组建
*@date      2019-07-31
*/

Item{

    property string currentDelay: "0";
    property string currentLossRate: "0";
    property string currentCpuRate: "30";
    property int currentNetType: 2;

    //屏幕比例
    property double widthRate: Screen.width * 0.8 / 966.0;
    property double heightRate: widthRate / 1.5337;


    width: 600 * heightRate
    height: 40 * heightRate

    Row{
        height: 30 * heightRate
        spacing: 30 * heightRate

        Text {
            text: qsTr("网络延迟：") + currentDelay + "ms"
            font.family: "Microsoft YaHei"
            font.pixelSize: 18 * heightRate
            color: "#333333"
        }
        Text {
            text: qsTr("丢包率：")+ currentLossRate + "%"
            font.family: "Microsoft YaHei"
            font.pixelSize: 18 * heightRate
            color: "#333333"
        }

        Item{
            width: 120 * heightRate
            height: parent.height
            Text {
                id: netText
                text: qsTr("网络状态：")
                font.family: "Microsoft YaHei"
                font.pixelSize: 18 * heightRate
                color: "#333333"
            }

            Text{
                anchors.left: netText.right
                text: {
                    if(currentNetType == 3){
                        color = "#55AE24";
                        return "优";
                    }
                    if(currentNetType == 2){
                        color = "#EECA00";
                        return "良";
                    }
                    if(currentNetType == 1){
                        color = "#FF0000";
                        return "差";
                    }else{
                        return "良";
                    }
                }
                font.family: "Microsoft YaHei"
                font.pixelSize: 18 * heightRate
                color: "#333333"
            }
        }

        Text {
            text: qsTr("系统CPU：") + currentCpuRate + "%"
            font.family: "Microsoft YaHei"
            font.pixelSize: 18 * heightRate
            color: "#333333"
        }
    }


    function updateNetValue(netType,delay,lossRate,cpuRate){
        currentNetType = netType;
        currentDelay = delay;
        currentLossRate = lossRate;
        currentCpuRate = cpuRate;
    }

}
