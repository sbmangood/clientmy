import QtQuick 2.0
import QtQuick.Controls 1.4
import "./Configuuration.js" as Cfg
import QtQuick 2.5

/*抢答器*/
Item {
    id:responderView
    width: currentViewType != 1 ? 782 * widthRate * 0.26 : 610 * widthRate * 0.32
    height: currentViewType != 1 ? 644 * widthRate * 0.26 : 432 * widthRate * 0.32

    property bool currentUserCanOperation: false;//当前使用者是否有操作权限 控制是否可以操作开始随机选人
    property int currentViewType: 2;//当前的显示模式 1 为开始抢答视图显示 2 倒计时开始 3 无人抢答 4 抢答成功
    property var successUser: "等风来";//抢答成功的人
    signal sigCloseResponderView();//关闭抢答器
    signal sigStuStartResponder();//开始抢答
    property int addRunNum: 3;//三秒钟计时
    onVisibleChanged:
    {
        if(visible)
        {
            // currentViewType = 1;
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
        width: 52 * widthRate * 0.6
        height: 40 * widthRate * 0.6
        visible: currentUserCanOperation
        source: "qrc:/miniClassImage/xb_button_close1@2x.png"
        anchors.left: parent.left
        anchors.leftMargin: -3 * widthRate
        anchors.bottom:parent.bottom
        anchors.bottomMargin: -3 * widthRate
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
        width: 538 * widthRate * 0.25
        height: 130 * widthRate * 0.25
        visible: currentViewType == 1
        source: "qrc:/miniClassImage/xb_button_ljqd1@2x.png"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 29 * widthRate
        anchors.left: parent.left
        anchors.leftMargin:  22 * widthRate

        MouseArea
        {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: false

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
                sigStuStartResponder();
            }

        }
    }


    Text{
        visible: currentViewType == 3
        anchors.top: parent.top
        anchors.topMargin: 68 * widthRate
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 29 * widthRate
        font.family: Cfg.font_family
        color: "#E5E3E1"
        text: "无人抢答  "
        font.bold: true
    }

    Text{
        visible: currentViewType == 2
        anchors.top: parent.top
        anchors.topMargin: 76 * widthRate
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 35 * widthRate
        font.family: Cfg.font_family
        color: "#333333"
        text: addRunNum  + " "
        font.bold: true
    }

    Text{
        visible: currentViewType == 4
        anchors.top: parent.top
        anchors.topMargin: 62 * widthRate
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 15 * widthRate
        font.family: Cfg.font_family
        color: "#999999"
        text:  successUser + "  "
        font.bold: true
    }

    Text{
        visible: currentViewType == 4
        anchors.top: parent.top
        anchors.topMargin: 80 * widthRate
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 29 * widthRate
        font.family: Cfg.font_family
        color: "#FF5500"
        text: "抢答成功 "
        font.bold: true
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
        responderView.visible = true;
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

    function resetResponderView(viewData)
    {
        //"type":1, // 1 发起抢答，2 学生抢答，3 抢答失败，4关闭抢答,byte
        var viewType = viewData.type;
        console.log("resetResponderView",viewType,viewData.time);
        if(1 == viewType)
        {
            setStartResponder(viewData.time);
        }else if(4 == viewType)
        {
            responderView.visible = false;
        }else if(5 == viewType)//学生抢答成功
        {
            //根据uid查询对应的学生名字
//            var rosterInfoData = curriculumData.getRosterInfo();
            var tUserName = viewData.name;
//            for(var a = 0; a < rosterInfoData.length; a++)
//            {
//                if(rosterInfoData[a].userId == viewData.userId)
//                {
//                    tUserName = rosterInfoData[a].userName;
//                    break;
//                }
//            }
            setSuccessUser(tUserName);
        }
    }

}

