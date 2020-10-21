import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuration.js" as Cfg

Popup {
    width: parent.width
    height: parent.height

    background: Rectangle{
        anchors.fill: parent
        color: "transparent"
    }

    function updateNetworkStatus(currentNetValue,networkStatus,pingValue){
        msText.text = pingValue.toString() + "ms";
        if(networkStatus == 3){
            if(currentNetValue == 3){
                networkImg.source = "qrc:/networkImage/cr_goodwifi.png";
                tipText.text = qsTr("当前网络状态良好");
                msText.color = "green";
                return;
            }
            if(currentNetValue == 2){
                networkImg.source =  "qrc:/networkImage/cr_lowwifi.png";
                tipText.text = qsTr("当前网络状态一般，建议切换其他网络上课");
                msText.color = "#df9d39";
                return;
            }
            if(currentNetValue == 1){
                networkImg.source =  "qrc:/networkImage/badwifi.png";
                tipText.text = qsTr("当前网络状态较差，建议切换其他网络上课");
                msText.color = "#ff3f3f";
                return;
            }
            if(currentNetValue == 0){
                networkImg.source =  "qrc:/networkImage/cr_nowifi.png";
                tipText.text = qsTr("当前无网络，请检查网络连接是否正常");
                msText.color = "#606070";
                return;
            }
        }else{
            if(currentNetValue == 3){
                networkImg.source =  "qrc:/networkImage/cr_goodsignal.png";
                tipText.text = qsTr("当前网络状态良好");
                msText.color = "green";
                return;
            }
            if(currentNetValue == 2){
                networkImg.source =  "qrc:/networkImage/cr_lowsignal.png";
                tipText.text = qsTr("当前网络状态一般，建议切换其他网络上课");
                msText.color = "#df9d39";
                return;
            }
            if(currentNetValue == 1){
                networkImg.source =  "qrc:/networkImage/cr_badsignal.png";
                tipText.text = qsTr("当前网络状态较差，建议切换其他网络上课");
                msText.color = "#ff3f3f";
                return;
            }
            if(currentNetValue == 0){
                networkImg.source =  "qrc:/networkImage/cr_nosignal.png";
                tipText.text = qsTr("当前无网络，请检查网络连接是否正常");
                msText.color = "#606070";
                return;
            }
        }
    }

    Rectangle{
        anchors.fill: parent
        radius: 12 * heightRate
        border.color: "#e0e0e0"
        border.width: 1

        Row{
            id: netRow
            height: 34 * heightRate
            width: parent.width * 0.4
            anchors.top: parent.top
            anchors.topMargin: 40 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                id: networkImg
                width: 32 * heightRate
                height: 24 * heightRate
            }

            Text {
                id: msText
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14 * heightRate
                font.family: Cfg.font_family
            }
        }

        Row{
            width: parent.width - 10 * heightRate
            anchors.top: netRow.bottom
            anchors.topMargin: 10 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                id: tipText
                width: parent.width
                wrapMode: Text.Center
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14 * heightRate
                font.family: Cfg.font_family
            }
        }

    }
}
