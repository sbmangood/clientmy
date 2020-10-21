import QtQuick 2.0
import "./Configuration.js" as Cfg

/*
* 菜单栏页面
*/

Rectangle {
    width: parent.width
    height: parent.height
    color: "#363744"

    property string currentTime: "10:50am";
    property int netwrokStatus: 3;//3:优 2:良 1:差
    property int setUserRole: 0;//设置用户权限属性
    property int tophyNum: 0;
    property int stuIntegral: 0;
    property int lessonStatus: 0;// 0=未开课，1=开课，2=离开，3=结束

    signal sigTipFeedBack();    //问题反馈信号
    signal sigDownLesson();
    signal sigDeviceCheck();
    signal sigMin();
    signal sigExit();
    signal sigIM();

    Rectangle{
        width: parent.width
        height: 1
        color: "#609BFD"
        anchors.bottom: parent.bottom
    }

    Text {
        id: titelTxt
        font.pixelSize: 20 * heightRate
        font.family: Cfg.DEFAULT_FONT
        color: "#ffffff"
        text: className
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 18 * heightRate
    }

    //开始上课图标
    Item{
        id: startLog
        width: 92 * heightRate
        height: 34 * heightRate
        anchors.left: titelTxt.right
        anchors.leftMargin: 20 * heightRate
        anchors.verticalCenter: parent.verticalCenter

        Image {
            id: lessonState
            anchors.fill: parent
            source: {
                if(0 == lessonStatus)   //未开课
                {
                    "qrc:/classImage/img_title_class_not.png"
                }
                else if(1 == lessonStatus)  //开课中
                {
                    "qrc:/classImage/img_title_class_start.png"
                }
                else if(2 == lessonStatus)  //中途离开
                {
                    "qrc:/classImage/img_title_class_leave.png"
                }
                else if(3 == lessonStatus)  //结束
                {
                    "qrc:/classImage/img_title_class_end.png"
                }
            }
        }
    }

    //奖杯、积分
    Row{
        id: tophyRow
        visible: false
        width: item1.width + item2.width + 20 * heightRate
        height: 42 * heightRate
        spacing: 20 * heightRate
        anchors.left: startLog.right
        anchors.leftMargin: 20 * heightRate
        anchors.verticalCenter: parent.verticalCenter

        Item{
            id: item1
            width: 42 * heightRate + tophyText.width
            height: parent.height
            Image{
                width: 42 * heightRate
                height: 42 * heightRate
                source: "qrc:/bigclassImage/jiangbei.png"
            }

            Text {
                id: tophyText
                anchors.left: parent.left
                anchors.leftMargin: 42 * heightRate
                font.pixelSize: 20 * heightRate
                font.family: Cfg.DEFAULT_FONT
                color: "#FEC859"
                text: "X" + tophyNum.toString();
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item{
            id: item2
            width: 80 * heightRate
            height: parent.height


            Image{
                width: 32 * heightRate
                height: 32 * heightRate
                source: "qrc:/bigclassImage/jifen.png"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 42 * heightRate
                font.pixelSize: 20 * heightRate
                font.family: Cfg.DEFAULT_FONT
                color: "#FEC859"
                text: qsTr("X") + stuIntegral.toString()
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    //时间显示
    Row{
        width: 100 * heightRate
        height: 54 * heightRate
        anchors.right: btnRow.left
//        anchors.rightMargin: setUserRole == 0 ? 320 * heightRate : 248 * heightRate
        anchors.verticalCenter: parent.verticalCenter
        spacing: 24 * heightRate

        Text {
            font.pixelSize: 20 * heightRate
            font.family: Cfg.DEFAULT_FONT
            color: "#ffffff"
            text: currentTime
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    //网络显示
    Row{
        width: 120 * heightRate
        height: 54 * heightRate
        anchors.left: startLog.right
        anchors.leftMargin: 10 * heightRate
        anchors.verticalCenter: parent.verticalCenter
        spacing: 24 * heightRate

        Text {
            font.pixelSize: 20 * heightRate
            font.family: Cfg.DEFAULT_FONT
            color: "#585B75"
            text: "网络:"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: nettext
            font.pixelSize: 20 * heightRate
            font.family: Cfg.DEFAULT_FONT
            text: {
                if(netwrokStatus == 3){
                    nettext.color = "#C5F756";
                    return "优";
                }
                if(netwrokStatus == 2){
                    nettext.color = "#FFC646";
                    return "良";
                }
                if(netwrokStatus == 1){
                    nettext.color = "#FF4D4D";
                    return "差";
                }
            }
            anchors.verticalCenter: parent.verticalCenter
        }
    }


    //退出、最小化、设备检测、IM等按钮
    Row{
        id: btnRow
        width: 312 * heightRate
        height: 38 * heightRate
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10 * heightRate
        spacing: 2 * heightRate

        MouseArea{
            id: lessonBtn
            width: 52 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                visible: setUserRole == 0 ? true : false
                source: isStartLesson ? (parent.containsMouse ? "qrc:/classImage/but_menu_inclass_focused.png" : "qrc:/classImage/but_menu_inclass_normal.png") : (parent.containsMouse ? "qrc:/classImage/but_menu_notclass_focused.png" : "qrc:/classImage/but_menu_notclass_normal.png")
            }

            onClicked: {
                sigDownLesson();
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.top: parent.bottom
                anchors.topMargin: 10 * heightRate
                color: "#353746"
                visible: lessonBtn.containsMouse ? true : false
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: isStartLesson ? "下课" : "上课";
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }


        }

        MouseArea{
            id: imBtn
            width: 52 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: parent.containsMouse ?  "qrc:/classImage/but_menu_chat_focused.png" : "qrc:/classImage/but_menu_chat_normal.png"
            }

            onClicked: {
                sigIM();
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.top: parent.bottom
                anchors.topMargin: 10 * heightRate
                color: "#353746"
                visible: imBtn.containsMouse ? true : false
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "聊天"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }
        }


        MouseArea{
            id: deviceBtn
            width: 52 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: parent.containsMouse ?  "qrc:/classImage/but_menu_detect_focused.png" : "qrc:/classImage/but_menu_detect_normal.png"
            }

            onClicked: {
                sigDeviceCheck();
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.top: parent.bottom
                anchors.topMargin: 10 * heightRate
                color: "#353746"
                visible: deviceBtn.containsMouse ? true : false
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "设备检测"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }

        //问题反馈
        MouseArea {
            id: feedBack
            width: 52 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/classImage/but_menu_help_focused(2).png" :"qrc:/classImage/but_menu_help_normal(2).png"
            }

            onClicked: {
                sigTipFeedBack();
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.top: parent.bottom
                anchors.topMargin: 10 * heightRate
                color: "#353746"
                visible: feedBack.containsMouse ? true : false
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "问题反馈"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }

        MouseArea{
            id: minBtn
            width: 52 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/classImage/but_menu_narrow_focused.png" : "qrc:/classImage/but_menu_narrow_normal.png"
            }

            onClicked: {
                sigMin();
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.top: parent.bottom
                anchors.topMargin: 10 * heightRate
                color: "#353746"
                visible: minBtn.containsMouse ? true : false
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "最小化"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }

        MouseArea{
            id: exitBtn
            width: 52 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/classImage/but_menu_withdraw_focused.png" : "qrc:/classImage/but_menu_withdraw_normal.png"
            }

            onClicked: {
                sigExit();
            }
            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.top: parent.bottom
                anchors.topMargin: 10 * heightRate
                color: "#353746"
                visible: exitBtn.containsMouse ? true : false
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "退出"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }


        }
    }

    Timer{
        id: timers
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            getCurrentTimer();
        }
    }

    Component.onCompleted: {
        timers.start();
    }

    function getCurrentTimer(){
        var currentTimer = new Date();
        var hours = currentTimer.getHours();
        var minutes = currentTimer.getMinutes();
        var timeValue = "" +((hours >= 12) ? "pm " : "am " );
        currentTime = addZero(hours > 12 ? hours - 12 : hours) + ":" + addZero(minutes) + timeValue;
    }

    function addZero(number){
        if(number < 10){
            return "0" + number.toString();
        }else{
            return number.toString();
        }
    }

    function setLessonState(state){
        console.log("setLessonState -- ", state);
        lessonStatus = state;
    }

}
