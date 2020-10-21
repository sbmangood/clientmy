import QtQuick 2.0
import "Configuration.js" as Cfg

//主程序, 右上角的"网络状态", "刷新", "设置"按钮
Row {
    id: menuItem
    width:  3 * 45 * heightRate + 80
    height:  45 * heightRate

    property int currentInternetStatus: 4;//无线、有线
    property int pingValue: 16;//ping值
    property int interNetValue: 3;//网络优、普通、差
    property int netStatus: 3;

    signal refreshData();

    Component.onCompleted: {
        pingMgr.getCurrentInternetStatus();
    }

    function updateNetworkImage(){
     }

    //主程序, 右上角的"网络状态"按钮

    Row{
        width:  95
        height: 14
        anchors.verticalCenter: parent.verticalCenter

        Text{
            id: networkText
            text: "网络状态: "
            font.pixelSize: 14
            font.family: Cfg.CALENDAR_FAMILY
            color: "#333333"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text{
            id: networkStatusText
            text: netStatus == 1 ? "很差" : netStatus == 2 ? "一般" : "良好"
            color: netStatus == 1 ? "#FF5A39" : netStatus == 2 ? "#FF5A39" : "#5ED144"
            font.pixelSize: 14
            font.family: Cfg.CALENDAR_FAMILY
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    //主程序, 右上角的"刷新"按钮
    YMButton{
        id: refreshButton
        width: parent.height
        height: parent.height * 0.5
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
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

    //主程序, 右上角的"设置"按钮
    YMButton{
        id:settingButtonArea
        width: parent.height * 0.8
        height: parent.height * 0.5
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        pressedImage: "qrc:/images/shezhi_focused@2x.png"
        imageUrl:  "qrc:/images/shezhi_normal@2x.png"
        onPressed: {
            var location = contentItem.mapFromItem(settingButtonArea,0,0);
            exitButton.x = location.x - menuItem.width * 0.32;
            exitButton.y = location.y + menuItem.height * 0.6;
            exitButton.visible = true;
        }
    }
}

