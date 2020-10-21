import QtQuick 2.0
import "./Configuration.js" as Cfg

/*
* 答题中页面
*/

Rectangle {
    id: beingAnswer
    width: 416 * heightRate
    height: 290 * heightRate
    color: "#474A5B"
    radius: 8 * heightRate

    property int addTimeCount: 0;//计时器
    property string answerSrt: "";//正确答案
    property int userRole: 0;//用户角色 0：老师 1：学生 2：助教

    signal sigResetAnswer();//重置答题
    signal sigEndAnswer();//结束答题

    MouseArea{
        anchors.fill: parent
        onClicked: {
        }
    }

    //head bar
    MouseArea{
        id: headView
        width: parent.width
        height: 48 * heightRate

        Rectangle{
            anchors.fill: parent
            color: "#474a5b"
            radius: 8 * heightRate
        }

        Text{
            font.pixelSize: 24 * heightRate
            font.family: Cfg.DEFAULT_FONT
        }

        property point clickPos: "0,0"

        onPressed: {
            clickPos  = Qt.point(mouse.x,mouse.y)
        }

        onPositionChanged: {
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
            var moveX = beingAnswer.x + delta.x;
            var moveY = beingAnswer.y + delta.y;
            var moveWidth = beingAnswer.parent.width - beingAnswer.width;
            var moveHeight = beingAnswer.parent.height - beingAnswer.height;

            if( moveX > 0 && moveX < moveWidth) {
                beingAnswer.x = beingAnswer.x + delta.x;
            }else{
                var loactionX = moveX < 0 ? 0 : (moveX > moveWidth ? moveWidth : moveX);
                beingAnswer.x = loactionX;
            }

            if(moveY  > 0 && moveY < moveHeight){
                beingAnswer.y = beingAnswer.y + delta.y;
            }else{
                beingAnswer.y = moveY < 0 ? 0 : (moveY > moveHeight ? moveHeight : moveY);
            }
        }

        Text {
            anchors.centerIn: parent
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 22 * heightRate
            text: qsTr("答题中")
            color: "#ffffff"
        }

        MouseArea{
            width: 42 * heightRate
            height: 42 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8 * heightRate
            cursorShape: Qt.PointingHandCursor
            visible: currentUserRole == 0 ? true : false

            Text {
                font.bold: true
                font.pixelSize: 26 * heightRate
                font.family: Cfg.DEFAULT_FONT
                text:  "一"
                anchors.centerIn: parent
                color: "#ffffff"
            }

            onClicked: {
                beingAnswer.visible = false;
            }
        }

        Rectangle{
            width: parent.width
            height: 1
            color: "#4D90FF"
            anchors.bottom: parent.bottom
        }
    }

    Timer{//计时定时器
        id:addTimer
        interval: 1000
        repeat: true
        running: false
        onTriggered: {
            secondsToMinutes(addTimeCount);
            addTimeCount--;
            if(addTimeCount == 0){
                resetStatus();
                sigEndAnswer();
            }
        }
    }

    Text {
        id: answerText
        text: qsTr("正确答案: ") +answerSrt
        anchors.left: parent.left
        anchors.leftMargin: 20  * heightRate
        color: "#ffffff"
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 18 * heightRate
        anchors.top: headView.bottom
        anchors.topMargin: 10 * heightRate
    }

    //计时器
    Row{
        id: timingRow
        width: parent.width - 20 * heightRate
        height: 150 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: answerText.bottom
        anchors.topMargin: 10 * heightRate
        spacing: 16 * heightRate
        //99:59
        YMClockControl{
            id: timingButtonOne
            maxValue: 9
            isVisible: false
        }
        YMClockControl{
            id: timingButtonTow
            maxValue: 9
            isVisible: false
        }

        Item{
            width: 12 * heightRate
            height: parent.height - 10 * heightRate

            Text {
                text: qsTr(":")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 80 * heightRate
                color: "#ffffff"
                anchors.centerIn: parent
            }
        }

        YMClockControl{
            id: timingButtonThree
            maxValue: 5
            isVisible: false
        }
        YMClockControl{
            id: timingButtonFour
            maxValue: 9
            isVisible: false
        }
    }

    //按钮
    Row{
        id: buttonRow
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 28 * heightRate
        width: parent.width - 28 * heightRate
        height: 42 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 40 * heightRate

        MouseArea{
            width: 176 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            visible:  currentUserRole == 0 ?  true : false

            Rectangle{
                anchors.fill: parent
                color: "#363847"
                radius: 4 * heightRate
                border.width: 2
                border.color: parent.containsMouse ? "#4D90FF" : "#363847"
            }

            Text {
                color: "#ffffff"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 18 * heightRate
                text: "重置"
                anchors.centerIn: parent
            }

            onClicked: {
                sigResetAnswer();
                resetStatus();
            }
        }

        MouseArea{
            width: 176* heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            visible:  currentUserRole == 0 ?  true : false

            Rectangle{
                anchors.fill: parent
                color: "#363847"
                radius: 4 * heightRate
                border.width: 2
                border.color: parent.containsMouse ? "#4D90FF" : "#363847"
            }

            Text {
                color: "#ffffff"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 18 * heightRate
                text: "结束答题"
                anchors.centerIn: parent
            }

            onClicked: {
                sigEndAnswer();
                resetStatus();
            }
        }
    }

    Text {
        font.pixelSize: 12 * heightRate
        font.family: Cfg.DEFAULT_FONT
        color: "#a0a4cb"
        text: qsTr("撤回后本轮答题作废")
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: buttonRow.bottom
        anchors.topMargin: 2 * heightRate
    }

    //重置状态
    function resetStatus(){
        addTimer.stop();
        addTimeCount = 0;
        answerSrt = "";
        secondsToMinutes(0);
        beingAnswer.visible = false;
    }

    //计时设置时间
    function secondsToMinutes(values){
        var minute = parseInt(values / 60);//分
        var second = values % 60;//秒

        var mTen = parseInt(minute / 10);//分钟取十位
        var mOne = minute % 10;//分钟取个位

        var sTen = parseInt(second / 10);//秒取十位
        var sOne = second % 10;//秒取个位

        timingButtonOne.clockValue = mTen;
        timingButtonTow.clockValue = mOne;
        timingButtonThree.clockValue = sTen;
        timingButtonFour.clockValue = sOne;
    }

    function startTime(){
        addTimer.restart();
    }
}
