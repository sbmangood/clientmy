import QtQuick 2.0
import "./Configuration.js" as Cfg

/*
* 菜单栏页面
*/

Rectangle {
    width: parent.width
    height: parent.height
    color: "#3d3f4e"

    property string currentTime: "10:50am";
    property int netwrokStatus: 3;//3:优 2:良 1:差
    property int setUserRole: 0;//设置用户权限属性
    property int tophyNum: 0;
    property int stuIntegral: 0;
    property int lessonStatus: 0;// 0=未开课，1=开课，2=离开，3=结束

    signal sigDownLesson();
    signal sigDeviceCheck();
    signal sigMin();
    signal sigExit();

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
                    "qrc:/redPackge/wks1.png"
                }
                else if(1 == lessonStatus)  //开课中
                {
                    "qrc:/redPackge/skz1.png"
                }
                else if(2 == lessonStatus)  //中途离开
                {
                    "qrc:/redPackge/img_ym_room_status_tea_leave(1).png"
                }
                else if(3 == lessonStatus)  //结束
                {
                    "qrc:/redPackge/img_ym_room_status_tea_leave.png"
                }
            }
        }
    }

    //奖杯、积分
    Row{
        id: tophyRow
        visible: setUserRole == 1 ?  true : false
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
    //时间、网络显示
    Row{
        width: 220 * heightRate
        height: 54 * heightRate
        anchors.right: parent.right
        anchors.rightMargin: setUserRole == 0 ? 320 * heightRate : 248 * heightRate
        anchors.verticalCenter: parent.verticalCenter
        spacing: 24 * heightRate

        Text {
            font.pixelSize: 20 * heightRate
            font.family: Cfg.DEFAULT_FONT
            color: "#ffffff"
            text: currentTime
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            font.pixelSize: 20 * heightRate
            font.family: Cfg.DEFAULT_FONT
            color: "#ffffff"
            text: "网络:"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: nettext
            font.pixelSize: 20 * heightRate
            font.family: Cfg.DEFAULT_FONT
            text: {
                if(netwrokStatus == 3){
                    nettext.color = "#A5DA2E";
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

    //退出、最小化、设备检测等按钮
    Row{
        id: btnRow
        width: 280 * heightRate
        height: 54 * heightRate
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 20 * heightRate
        spacing: 12 * heightRate

        MouseArea{
            width: 64 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                visible: setUserRole == 0 ? true : false
                source: isStartLesson ? (parent.containsMouse ? "qrc:/redPackge/xk2.png" : "qrc:/redPackge/xk1.png") : (parent.containsMouse ? "qrc:/redPackge/sk1.png" : "qrc:/redPackge/sk2.png")
            }

            onClicked: {
                sigDownLesson();
            }
        }

        MouseArea{
            width: 64 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: parent.containsMouse ?  "qrc:/redPackge/sbjc2.png" : "qrc:/redPackge/sbjc1.png"
            }

            onClicked: {
                sigDeviceCheck();
            }
        }

        MouseArea{
            width: 64 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/redPackge/zxh2.png" : "qrc:/redPackge/zxh1.png"
            }

            onClicked: {
                sigMin();
            }
        }

        MouseArea{
            width: 64 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/redPackge/tc2.png" : "qrc:/redPackge/tc1.png"
            }

            onClicked: {
                sigExit();
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
