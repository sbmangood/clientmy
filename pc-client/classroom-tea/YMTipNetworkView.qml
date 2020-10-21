import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuuration.js" as Cfg

Popup {
    width: parent.width
    height: parent.height

    background: Rectangle{
        anchors.fill: parent
        color: "transparent"
    }

    function updateNetworkStatus(currentNetValue,networkStatus,pingValue){
        msText.text = pingValue.toString() + "ms";

        if(currentNetValue == 0){
            goodNetImg.source = "qrc:/newStyleImg/noNet@2x.png";
            msText.color = "#606070";
            msText.text = "";
            goodNetImg.anchors.rightMargin = 216 * heightRates;
            goodNetImg.anchors.topMargin = -40 * heightRates;
            goodNetImg.width = 458 * heightRate * 0.7;
            goodNetImg.height = 76 * heightRate * 0.7;

            return;
        }

        if(currentNetValue == 1){
            goodNetImg.source = "qrc:/newStyleImg/netBad@2x.png";
            msText.color = "#ff3f3f";

            goodNetImg.anchors.rightMargin = 216 * heightRates;
            goodNetImg.anchors.topMargin = -40 * heightRates;
            goodNetImg.width = 514 * heightRate * 0.7;
            goodNetImg.height = 88 * heightRate * 0.7;

            return;
        }

        if(currentNetValue == 3){
            goodNetImg.source = "qrc:/newStyleImg/gooNet@2x.png";
            msText.color = "#80C000";

            goodNetImg.anchors.rightMargin = 216 * heightRates;
            goodNetImg.anchors.topMargin = -40 * heightRates;
            goodNetImg.width = 268 * heightRate * 0.7;
            goodNetImg.height = 88 * heightRate * 0.7;

            return;
        }
        if(currentNetValue == 2){
            goodNetImg.source = "qrc:/newStyleImg/net@2x.png";
            msText.color = "#df9d39";

            goodNetImg.anchors.rightMargin = 216 * heightRates;
            goodNetImg.anchors.topMargin = -40 * heightRates;
            goodNetImg.width = 458 * heightRate * 0.7;
            goodNetImg.height = 88 * heightRate * 0.7;

            return;
        }

        //        if(networkStatus == 3){
        //            if(currentNetValue == 3){
        //                networkImg.source = "qrc:/networkImage/cr_goodwifi.png";
        //                tipText.text = qsTr("当前网络状态良好");

        //                goodNetImg.source = "qrc:/newStyleImg/gooNet@2x.png";
        //                msText.color = "green";
        //                return;
        //            }
        //            if(currentNetValue == 2){
        //                networkImg.source =  "qrc:/networkImage/cr_lowwifi.png";
        //                tipText.text = qsTr("当前网络状态一般，建议切换其他网络上课");
        //                msText.color = "#df9d39";
        //                return;
        //            }
        //            if(currentNetValue == 1){
        //                networkImg.source =  "qrc:/networkImage/badwifi.png";
        //                tipText.text = qsTr("当前网络状态较差，建议切换其他网络上课");
        //                msText.color = "#ff3f3f";
        //                return;
        //            }
        //            if(currentNetValue == 0){
        //                networkImg.source =  "qrc:/networkImage/cr_nowifi.png";
        //                tipText.text = qsTr("当前无网络，请检查网络连接是否正常");
        //                msText.color = "#606070";
        //                return;
        //            }
        //        }else{
        //            if(currentNetValue == 3){
        //                networkImg.source =  "qrc:/networkImage/cr_goodsignal.png";
        //                tipText.text = qsTr("当前网络状态良好");
        //                msText.color = "green";
        //                return;
        //            }
        //            if(currentNetValue == 2){
        //                networkImg.source =  "qrc:/networkImage/cr_lowsignal.png";
        //                tipText.text = qsTr("当前网络状态一般，建议切换其他网络上课");
        //                msText.color = "#df9d39";
        //                return;
        //            }
        //            if(currentNetValue == 1){
        //                networkImg.source =  "qrc:/networkImage/cr_badsignal.png";
        //                tipText.text = qsTr("当前网络状态较差，建议切换其他网络上课");
        //                msText.color = "#ff3f3f";
        //                return;
        //            }
        //            if(currentNetValue == 0){
        //                networkImg.source =  "qrc:/networkImage/cr_nosignal.png";
        //                tipText.text = qsTr("当前无网络，请检查网络连接是否正常");
        //                msText.color = "#606070";
        //                return;
        //            }
        //        }

    }

    Image{
        id: goodNetImg
        width: 268 * heightRate * 0.7
        height: 88 * heightRate * 0.7
        anchors.right: parent.right
        anchors.rightMargin: 216 * heightRates
        anchors.top: parent.top
        anchors.topMargin: -40 * heightRates
        z:2
        source: "qrc:/newStyleImg/gooNet@2x.png"

        Text {
            anchors.top: parent.top
            anchors.topMargin: 3 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 14 * heightRate
            font.family: Cfg.font_family
            text: msText.text
            color: msText.color
        }
    }

    Rectangle{
        anchors.fill: parent
        radius: 12 * heightRate
        border.color: "#e0e0e0"
        border.width: 1
        visible: false

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
