import QtQuick 2.0
import "Configuration.js" as Cfg

//主程序, 右上角的"网络状态", "刷新", "设置"按钮
Row {
    id: menuItem
    width:  112 * heightRate * 0.75
    height:  45 * heightRate
    spacing: 23 * heightRate * 0.75

    property int currentInternetStatus: 4;//无线、有线
    property int pingValue: 16;//ping值
    property int interNetValue: 3;//网络优、普通、差
    property int netStatus: 3;

    signal refreshData();

    Component.onCompleted: {
        pingMgr.getCurrentInternetStatus();
    }

    function updateNetworkImage(){
        if(currentInternetStatus == 3){
            if(netStatus == 3){
                networkButton.pressedImage = "qrc:/networkImage/goodwifi.png";
                networkButton.imageUrl = "qrc:/networkImage/cr_goodwifi.png";
                return;
            }
            if(netStatus == 2){
                networkButton.pressedImage = "qrc:/networkImage/lowwifi.png";
                networkButton.imageUrl =  "qrc:/networkImage/cr_lowwifi.png";
                return;
            }
            if(netStatus == 1){
                networkButton.pressedImage = "qrc:/networkImage/badwifi.png"
                networkButton.imageUrl =  "qrc:/networkImage/badwifi.png";
                return;
            }
            if(netStatus == 0){
                networkButton.pressedImage = "qrc:/networkImage/cr_nowifi.png"
                networkButton.imageUrl =  "qrc:/networkImage/cr_nowifi.png";
                return;
            }
        }else{
            if(netStatus == 3){
                networkButton.pressedImage = "qrc:/networkImage/goodsignal.png";
                networkButton.imageUrl =  "qrc:/networkImage/cr_goodsignal.png";
                return;
            }
            if(netStatus == 2){
                networkButton.pressedImage = "qrc:/networkImage/lowsignal.png"
                networkButton.imageUrl =  "qrc:/networkImage/cr_lowsignal.png";
                return;
            }
            if(netStatus == 1){
                networkButton.pressedImage = "qrc:/networkImage/badsignal.png"
                networkButton.imageUrl =  "qrc:/networkImage/cr_badsignal.png";
                return;
            }
            if(netStatus == 0){
                networkButton.pressedImage = "qrc:/networkImage/nosignal.png";
                networkButton.imageUrl =  "qrc:/networkImage/cr_nosignal.png";
                return;
            }
        }
    }

    //主程序, 右上角的"网络状态"按钮
    YMButton{
        id: networkButton
        width: 22 * heightRate * 0.75
        height: 22 * heightRate * 0.75
        anchors.verticalCenter: parent.verticalCenter
        pressedImage: "qrc:/networkImage/cr_goodsignal.png"
        imageUrl:  "qrc:/networkImage/goodsignal.png"
        onClicked: {
            tipInterView.x = systemMenu.x - networkButton.x - 160 *widthRate;
            tipInterView.y = systemMenu.y + networkButton.height + 16 * heightRate;
            tipInterView.updateNetworkStatus(interNetValue,currentInternetStatus,pingValue);
            tipInterView.open();
        }
    }

    //主程序, 右上角的"刷新"按钮
    YMButton{
        id: refreshButton
        width: 22 * heightRate * 0.75
        height: 22 * heightRate * 0.75
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        pressedImage: "qrc:/images/index_btn_refresh03@2x.png" //主程序, 右上角的"刷新"按钮
        imageUrl: "qrc:/images/index_btn_refresh03@2x.png"

        onClicked: {
            rotationAnimation.start();
            refreshButton.enabled = false;
            refreshData();
        }
    }

    NumberAnimation {
        id:rotationAnimation
        target: refreshButton
        from: 0
        to: 360
        property: "rotation"
        duration: 2000
        onStopped: {
            refreshButton.enabled = true;
        }
    }

    //主程序, 右上角的"设置"按钮
    YMButton{
        id:settingButtonArea
        width: 22 * heightRate * 0.75
        height: 22 * heightRate * 0.75
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        pressedImage: "qrc:/images/index_btn_edit_sed@2x.png" //主程序, 右上角的"设置"按钮
        imageUrl: "qrc:/images/index_btn_edit@2x.png" //主程序, 右上角的"设置"按钮

        onPressed: {
            var location = contentItem.mapFromItem(settingButtonArea,0,0);
            exitButton.x = location.x - menuItem.width * 0.32;
            exitButton.y = location.y + menuItem.height * 0.6;
            exitButton.visible = true;
        }
    }
}

