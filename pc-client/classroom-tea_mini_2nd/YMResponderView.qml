import QtQuick 2.0
import QtQuick.Controls 1.4
import "./Configuuration.js" as Cfg
import QtQuick 2.5
/*抢答器*/
Item {
    id:responderView
    width: currentViewType != 1 ? 782 * widthRates * 0.26 : 610 * widthRates * 0.32
    height: currentViewType != 1 ? 644 * widthRates * 0.26 : 432 * widthRates * 0.32

    property bool currentUserCanOperation: true;//当前使用者是否有操作权限 控制是否可以操作开始随机选人
    property int currentViewType: 1;//当前的显示模式 1 为开始抢答视图显示 2 抢答中 3 无人抢答和抢答成功
    property var successUser: "等风来";//抢答成功的人
    signal sigCloseResponderView();//关闭抢答器
    signal sigStartResponder(var runTimes);//开始抢答 runTimes 抢答倒计时

    onVisibleChanged:
    {
       if(visible){
           currentViewType = 1;
       }else{
           sigCloseResponderView();
       }
    }

    MouseArea{
        anchors.fill: parent
        onClicked:
        {

        }
    }

    //背景
    Image {
        anchors.fill: parent
        source: currentViewType == 1 ? "qrc:/miniClassImage/xb_xianshiqi4@2x.png" : (currentViewType == 2 ? "qrc:/miniClassImage/xb_xianshiqi2@2x.png" : "qrc:/miniClassImage/xb_xianshiqi2@2x.png")
    }

    //关闭按钮
    Image {
        width: 52 * widthRates * 0.6
        height: 40 * widthRates * 0.6
        visible: currentUserCanOperation && currentViewType != 2
        source: "qrc:/miniClassImage/xb_button_close1@2x.png"
        anchors.left: parent.left
        anchors.leftMargin: -3 * widthRates
        anchors.bottom:parent.bottom
        anchors.bottomMargin: -3 * widthRates
        z:15
        MouseArea
        {
            anchors.fill:parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onPressed:
            {
                parent.source = "qrc:/miniClassImage/xb_button_close2@2x.png";
            }

            onReleased:
            {
                parent.source = "qrc:/miniClassImage/xb_button_close1@2x.png";
            }
            onClicked:
            {
                responderView.visible = false;
            }
        }
    }

    //开始抢答按钮
    Image {
        id: startButton
        width: 538 * widthRates * 0.25
        height: 130 * widthRates * 0.25
        visible: currentUserCanOperation && currentViewType == 1
        source: "qrc:/miniClassImage/xb_button_ljqd1@2x.png"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 27 * widthRates
        anchors.left: parent.left
        anchors.leftMargin:  19 * widthRates

        MouseArea
        {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onPressed:
            {
                startButton.source = "qrc:/miniClassImage/xb_button_ljqd2@2x.png";
            }

            onReleased:
            {
                startButton.source = "qrc:/miniClassImage/xb_button_ljqd1@2x.png";
            }

            onClicked:
            {
                sigStartResponder(10);
                currentViewType = 2;
                //开始计时
                runTimer.start();
            }
        }
    }

//重新开始抢答按钮
    Image {
        id: reStartButton
        width: 538 * widthRates * 0.2
        height: 124 * widthRates * 0.2
        visible: currentUserCanOperation && currentViewType == 3
        source: "qrc:/miniClassImage/xb_button_cxks1@2x.png"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12 * widthRates
        anchors.left: parent.left
        anchors.leftMargin: 37 * widthRates

        MouseArea
        {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onPressed:
            {
                startButton.source = "qrc:/miniClassImage/xb_button_cxks2@2x.png";
            }

            onReleased:
            {
                startButton.source = "qrc:/miniClassImage/xb_button_cxks1@2x.png";
            }

            onClicked:
            {
                sigStartResponder(10);
                currentViewType = 2;
                //开始计时
                runTimer.start();
            }

        }
    }

    Text{
        visible: currentUserCanOperation && currentViewType == 2
        anchors.top: parent.top
        anchors.topMargin: 80 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 29 * widthRates
        font.family: Cfg.font_family
        color: "#E5E3E1"
        text: "抢答中...  "
        font.bold: true
    }

    Text{
        visible: currentUserCanOperation && currentViewType == 3
        anchors.top: parent.top
        anchors.topMargin: 68 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 29 * widthRates
        font.family: Cfg.font_family
        color: "#E5E3E1"
        text: "无人抢答  "
        font.bold: true
    }

    Text{
        visible: currentUserCanOperation && currentViewType == 4
        anchors.top: parent.top
        anchors.topMargin: 72 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 15 * widthRates
        font.family: Cfg.font_family
        color: "#999999"
        text:  successUser + "  "
        font.bold: true
    }

    Text{
        visible: currentUserCanOperation && currentViewType == 4
        anchors.top: parent.top
        anchors.topMargin: 90 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 29 * widthRates
        font.family: Cfg.font_family
        color: "#FF5500"
        text: "抢答成功 "
        font.bold: true
    }

    Timer{
        id:runTimer
        interval: 10000
        running: false
        repeat: false
        onTriggered: {
            currentViewType = 3;
        }
    }

    //设置抢答成功的人的名字
    function setSuccessUser(userName)
    {
        runTimer.stop();
        successUser = userName;
        currentViewType = 4;
    }



}
