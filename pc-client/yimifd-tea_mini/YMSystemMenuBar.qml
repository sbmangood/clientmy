import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import "Configuration.js" as Cfg
import QtGraphicalEffects 1.0
import PingThreadManagerAdapter 1.0

Row {
    id: systemMenuBar
    width: 6 * 36 * widthRate
    height: 45 * heightRate

    property var window: null
    property string teacherName: "老师账号";
    property string headPicture: "qrc:/images/adlist_icon_mycenter_sed2x.png";
    property int currentInternetStatus: 4;//无线、有线
    property int pingValue: 16;//ping值
    property int interNetValue: 3;//网络优、普通、差
    property int netStatus: 3;

    signal minimized();
    signal maximized();
    signal windowed();
    signal closed();
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

    YMButton{
        id: networkButton
        width: parent.height
        height: parent.height * 0.5
        anchors.verticalCenter: parent.verticalCenter
        pressedImage: "qrc:/networkImage/cr_goodsignal.png"
        imageUrl:  "qrc:/networkImage/goodsignal.png"
        onClicked: {
            tipInterView.x = systemMenu.x - networkButton.x - 38 *widthRate;
            tipInterView.y = systemMenu.y + networkButton.height + 16 * heightRate;
            tipInterView.updateNetworkStatus(interNetValue,currentInternetStatus,pingValue);
            tipInterView.open();
        }
    }

    YMButton{
        id: refreshButton
        width: parent.height
        height: parent.height * 0.5
        anchors.verticalCenter: parent.verticalCenter
        pressedImage: "qrc:/images/index_btn_refresh03@2x.png"
        imageUrl:  "qrc:/images/index_btn_refresh03@2x.png"

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

    YMButton{
        id:settingButtonArea
        width: parent.height * 0.8
        height: parent.height * 0.5
        anchors.verticalCenter: parent.verticalCenter
        pressedImage: "qrc:/images/index_btn_edit_sed@2x.png"
        imageUrl:  "qrc:/images/index_btn_edit@2x.png"

        onPressed: {
            exitButton.x = systemMenu.x + settingButtonArea.x- 58 * widthRate;
            exitButton.y = systemMenu.y + settingButtonArea.height+12*heightRate;
            exitButton.visible = true;
        }
    }

    Item{
        id: lineItem
        width: 25 * widthRate
        height: 25 * heightRate
    }

    //最小化按钮
    YMButton {
        id:minButton
        width: parent.height
        height: parent.height
        pressedImage: "qrc:/images/btn_zuixiaohua_sed@2x.png"
        imageUrl:  "qrc:/images/btn_zuixiaohua@2x.png"
        onClicked: {
            window.visibility = Window.Minimized;
        }
    }

    //最大化
    YMButton {
        id: maxButton        
        width: parent.height
        height: parent.height
        pressedImage:window.visibility == Window.Maximized ? "qrc:/images/btn_xiaopin_sed@2x.png" : "qrc:/images/btn_zuidahua_sed@2x.png"
        imageUrl: window.visibility == Window.Maximized ? "qrc:/images/btn_xiaopin@2x.png" :"qrc:/images/btn_zuidahua@2x.png"
        onClicked: {
            if (window.visibility === Window.Maximized){
                window.visibility = Window.Windowed;
            }else if (window.visibility === Window.Windowed){
                window.visibility = Window.Maximized;
            }
        }
    }

    //关闭按钮
    YMButton {
        id: closeButton
        width: parent.height
        height: parent.height
        imageUrl: "qrc:/images/btn_guanbi@2x.png"
        pressedImage: "qrc:/images/btn_guanbi_sed@2x.png"

        onClicked: {
            closed();
        }
    }
}


