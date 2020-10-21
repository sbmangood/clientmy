import QtQuick 2.0
import QtQuick.Controls 1.4
import "./Configuuration.js" as Cfg
import QtQuick 2.5
/*抢答器*/
Item {
    id:responderView
    width: currentViewType != 1 ? 762 * widthRates * 0.26 : 610 * widthRates * 0.3
    height: currentViewType != 1 ? 764 * widthRates * 0.26 : 432 * widthRates * 0.3

    property bool currentUserCanOperation: false;//当前使用者是否有操作权限 控制是否可以操作开始随机选人
    property int currentViewType: 2;//当前的显示模式 1 为开始抢答视图显示 2 倒计时开始 3 无人抢答 4 抢答成功
    property var successUser: "等风来";//抢答成功的人
    signal sigCloseResponderView();//关闭抢答器
    signal sigStartResponder();//开始抢答
    property int addRunNum: 3;//三秒钟计时
    onVisibleChanged:
    {
        if(visible)
        {
             //currentViewType = 1;
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
        source: currentViewType == 1 ? "qrc:/miniClassImage/xb_xianshiqi4@2x.png" : (currentViewType == 2 ? "qrc:/miniClassImage/xb_xianshiqi2@2x.png" : "qrc:/miniClassImage/xb_xianshiqi3@2x.png")
    }

    //关闭按钮
    Image {
        width: 52 * widthRates * 0.6
        height: 40 * widthRates * 0.6
        visible: currentUserCanOperation
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
    //三秒计时  音乐播放 for stu

    //开始抢答按钮
    Image {
        id: startButton
        width: 538 * widthRates * 0.25
        height: 130 * widthRates * 0.25
        visible: currentViewType == 1
        source: "qrc:/miniClassImage/xb_button_ljqd1@2x.png"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24 * widthRates
        anchors.left: parent.left
        anchors.leftMargin:  17 * widthRates

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
                sigStartResponder();
            }

        }
    }


    Text{
        visible: currentViewType == 3
        anchors.top: parent.top
        anchors.topMargin: 85 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 29 * widthRates
        font.family: Cfg.font_family
        color: "#E5E3E1"
        text: "无人抢答  "
    }

    Text{
        visible: currentViewType == 2
        anchors.top: parent.top
        anchors.topMargin: 95 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 35 * widthRates
        font.family: Cfg.font_family
        color: "#333333"
        text: addRunNum  + " "
    }

    Text{
        visible: currentViewType == 4
        anchors.top: parent.top
        anchors.topMargin: 75 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 15 * widthRates
        font.family: Cfg.font_family
        color: "#999999"
        text:  successUser + "  "
    }

    Text{
        visible: currentViewType == 4
        anchors.top: parent.top
        anchors.topMargin: 95 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 29 * widthRates
        font.family: Cfg.font_family
        color: "#FF5500"
        text: "抢答成功 "
    }

    Timer
    {
        id:runTimer
        interval: 10000
        running: false
        repeat: false
        onTriggered: {
            currentViewType = 3;
        }
    }
    Timer
    {
        id:backTimer3
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            -- addRunNum;
            if(addRunNum == 0)
            {
                backTimer3.stop();
                addRunNum = 3;
                currentViewType = 1;
            }
        }
    }
    //设置抢答成功的人的名字
    function setSuccessUser(userName)
    {
        successUser = userName;
        currentViewType = 4;
        runTimer.stop();
    }

    //根据开始时间进行倒计时 设置抢答
    function setStartResponder(startTimes)
    {
        currentViewType = 2;
        backTimer3.start();
        runTimer.interval = startTimes * 1000;
        runTimer.start();
        responderView.visible = true;
    }

}

