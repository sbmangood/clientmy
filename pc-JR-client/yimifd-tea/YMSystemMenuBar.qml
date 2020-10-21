import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import "Configuration.js" as Cfg
import QtGraphicalEffects 1.0
import PingThreadManagerAdapter 1.0

Row {
    id: systemMenuBar
    width: 7 * 36 * widthRate
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
    }

    Row{
        width:  95 * widthRates
        height: 14 * widthRates
        anchors.verticalCenter: parent.verticalCenter

        Text{
            id: networkText
            text: "网络状态: "
            font.pixelSize: 14 * widthRates
            font.family: Cfg.CALENDAR_FAMILY
            color: "#333333"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text{
            id: networkStatusText
            text: netStatus == 1 ? "很差" : netStatus == 2 ? "一般" : "良好"
            color: netStatus == 1 ? "#FF5A39" : netStatus == 2 ? "#FF5A39" : "#5ED144"
            font.pixelSize: 14 * widthRates
            font.family: Cfg.CALENDAR_FAMILY
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Item{
        width: 16 * widthRates
        height: 25 * heightRate
    }

    YMButton{
        id: refreshButton
        width: 23 * widthRates
        height: 23 * widthRates
        anchors.verticalCenter: parent.verticalCenter
        pressedImage: "qrc:/images/jiazai_focused@2x.png"
        imageUrl:  "qrc:/images/jiazai_normal@2x.png"

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

    Item{
        width: 18 * widthRates
        height: 25 * heightRate
    }
    YMButton{
        id:settingButtonArea
        width: 23 * widthRates
        height: 23 * widthRates
        anchors.verticalCenter: parent.verticalCenter
        pressedImage: "qrc:/images/shezhi_focused@2x.png"
        imageUrl:  "qrc:/images/shezhi_normal@2x.png"

        onPressed: {
            exitButton.x = systemMenu.x + settingButtonArea.x- 58 * widthRate;
            exitButton.y = systemMenu.y + settingButtonArea.height+12*heightRate;
            exitButton.visible = true;
        }
    }

    Item{
        id: lineItem
        width: 18 * widthRates
        height: 25 * heightRate
    }

    YMButton {
        id:minButton
        width: parent.height
        height: parent.height
        pressedImage: "qrc:/images/zuixaohua_pressed@2x.png"
        imageUrl:  "qrc:/images/zuixaohua_normal@2x.png"
        hoverImg: "qrc:/images/zuixaohua_focused@2x.png"
        onClicked: {
            window.visibility = Window.Minimized;
        }
    }

    YMButton {
        id: maxButton
        width: parent.height + 4 * heightRate
        height: parent.height
        pressedImage:window.visibility == Window.Maximized ? "qrc:/images/quanping_pressed2@2x.png" : "qrc:/images/quanping_pressed@2x.png"
        imageUrl: window.visibility == Window.Maximized ? "qrc:/images/quanping_normal2@2x.png" :"qrc:/images/quanping_normal@2x.png"
        hoverImg:window.visibility == Window.Maximized ? "qrc:/images/quanping_focused2@2x.png" :"qrc:/images/quanping_focused@2x.png"

        onClicked: {
            if (window.visibility === Window.Maximized){
                window.visibility = Window.Windowed;
            }else if (window.visibility === Window.Windowed){
                window.visibility = Window.Maximized;
            }
        }
    }

    YMButton {
        id: closeButton
        width: parent.height
        height: parent.height
        imageUrl: "qrc:/images/guanbi_normal@2x.png"
        pressedImage: "qrc:/images/guanbi_pressed@2x.png"
        hoverImg: "qrc:/images/guanbi_focused@2x.png"
        onClicked: {
            closed();
        }
    }
}


