import QtQuick 2.0
import QtQuick.Controls 1.4
import "./Configuration.js" as Cfg
import QtQuick 2.5

/*
* 计时器 倒计时
*/

Rectangle {
    id:timerManager
    width: 510 * heightRate
    height: 322 * heightRate
    color: "#363847"
    radius: 8 * heightRate

    property int currentIndex: 1;//当前选项的索引
    property int addTimeCount: 0;//计时器
    property int lessTimerCount: 0;//倒计时值
    property int assistRole: 2; //助教角色
    property int teacherRole: 0; //老师角色
    property int userRole: 0;

    property bool timerIsRunning: false;

    signal sigShowAddTimerView();//显示计时器界面
    signal sigShowCountDownTimerView();//显示倒计时界面

    signal sigStartAddTimer(var currentTime);//开始计时
    signal sigStopAddTimer(var currentTime);//停止计时
    signal sigResetAddTimer();//重置计时器
    signal sigCloseTimerView(var currentViewType,var currentTime);//关闭界面

    signal sigStartCountDownTimer(var currentTime);//开始倒计时
    signal sigStopCountDownTimer(var currentTime);//停止倒计时
    signal sigResetCountDownTimer();//重置倒计时

    MouseArea{
        anchors.fill: parent
        onClicked: {

        }
    }

    onVisibleChanged: {
        if(visible)
        {
            resetAddtTimer();
            resetCountDown();
            if(currentIndex == 1)
            {
                sigShowAddTimerView();
            }else
            {
                sigShowCountDownTimerView();
            }
        }else{
            if(1 == currentIndex)
            {
                sigCloseTimerView(1,addTimeCount);
            }else
            {
                sigCloseTimerView(2,lessTimerCount);
            }
        }
    }

    MouseArea{
        width: 8 * widthRate
        height: 8 * widthRate
        anchors.right: parent.right
        anchors.rightMargin: 16 * widthRate
        anchors.top:parent.top
        anchors.topMargin: 16 * widthRate
        z:5
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        visible: currentUserRole != 0 ? false : true

        onClicked:
        {
            timerManager.visible = false;
            addTimeCount = 0;
            addTimer.stop();
            lessTimer.stop();
            lessTimerCount = 0;
        }

        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 32 * heightRate
            anchors.centerIn: parent
            color: parent.containsMouse ? "#ffffff" : "#5F6485"
            text: qsTr("×")
        }
    }

    MouseArea{
        width: parent.width
        height: 48 * heightRate
        cursorShape: Qt.PointingHandCursor

        property point clickPos: "0,0"

        onPressed: {
            clickPos  = Qt.point(mouse.x,mouse.y)
        }

        onPositionChanged: {
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
            var moveX = timerManager.x + delta.x;
            var moveY = timerManager.y + delta.y;
            var moveWidth = timerManager.parent.width - timerManager.width;
            var moveHeight = timerManager.parent.height - timerManager.height;

            if( moveX > 0 && moveX < moveWidth) {
                timerManager.x = timerManager.x + delta.x;
            }else{
                var loactionX = moveX < 0 ? 0 : (moveX > moveWidth ? moveWidth : moveX);
                timerManager.x = loactionX;
            }

            if(moveY  > 0 && moveY < moveHeight){
                timerManager.y = timerManager.y + delta.y;
            }else{
                timerManager.y = moveY < 0 ? 0 : (moveY > moveHeight ? moveHeight : moveY);
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
        triggeredOnStart: true
        onTriggered: {
            ++addTimeCount;
            secondsToMinutes(addTimeCount);
        }
    }

    Timer{//倒计时定时器
        id: lessTimer
        interval: 1000
        repeat: true
        onTriggered: {
            lessTimerCount--;
            startCountDown(lessTimerCount)
            if(lessTimerCount == 0){
                lessTimer.stop();
                timerIsRunning = false;
            }
        }
    }

    //展示头样式
    Row{
        id:tRows
        width: parent.width * 0.2
        height: 42 * heightRate
        spacing: 10 * widthRate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:parent.top
        anchors.topMargin: 8 * widthRate

        Text{
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * widthRate
            text: "计时器"
            wrapMode: Text.WordWrap
            color: currentIndex == 1 ? "#4D90FF" : "#7F8091"
            MouseArea{
                anchors.fill:parent
                cursorShape: Qt.PointingHandCursor
                enabled: (timerIsRunning == true || currentUserRole != 0) ? false : true
                onClicked:{
                    currentIndex = 1;
                    reciprocalRow.visible = false;
                    timingRow.visible = true;
                }
            }
        }

        Text{
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * widthRate
            text: "|"
            wrapMode: Text.WordWrap
            color: "#999999"
        }

        Text{

            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * widthRate
            text:"倒计时"
            wrapMode: Text.WordWrap
            color: currentIndex == 2 ? "#4D90FF" : "#7F8091"
            MouseArea {
                anchors.fill:parent
                cursorShape: Qt.PointingHandCursor
                enabled: (timerIsRunning == true || currentUserRole != 0) ? false : true
                onClicked:{
                    currentIndex = 2;
                    reciprocalRow.visible = true;
                    timingRow.visible = false;
                }
            }
        }
    }

    //倒计时
    Row{
        id: reciprocalRow
        visible: false
        width: userRole == 0 ? 460 * heightRate : 360 * heightRate
        height: 150 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: tRows.bottom
        anchors.topMargin: 10 * heightRate
        spacing: 6 * heightRate

        //最大99:59
        YMClockControl{//分十位
            id: clockButtonOne
            isStart: timerIsRunning;
            maxValue: 9
            isVisible: userRole == 0 ? true : false
            onSigAdd: {
                lessTimerCount += (10 * 60);
            }

            onSigLess: {
                lessTimerCount -= (10 * 60);
            }
        }
        YMClockControl{//分个位
            id: clockButtonTow
            isStart: timerIsRunning;
            maxValue: 9
            isVisible: userRole == 0 ? true : false
            onSigAdd: {
                lessTimerCount += 60;
            }

            onSigLess: {
                lessTimerCount -= 60;
            }
        }
        Item{// 时钟冒号
            width: 10 * heightRate
            height: parent.height //- 20 * heightRate

            Text {
                text: qsTr(":")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 72 * heightRate
                color: "#ffffff"
                anchors.centerIn: parent
            }
        }
        YMClockControl{//秒十位
            id: clockButtonThree
            isStart: timerIsRunning;
            maxValue: 5
            isVisible: userRole == 0 ? true : false
            onSigAdd: {
                lessTimerCount +=10;
            }

            onSigLess: {
                lessTimerCount -=10;
            }
        }
        YMClockControl{//秒个位
            id: clockButtonFour
            isStart: timerIsRunning;
            maxValue: 9
            isVisible: userRole == 0 ? true : false
            onSigAdd: {
                lessTimerCount +=1;
            }

            onSigLess: {
                lessTimerCount -=1;
            }
        }
        Item{//30 1分钟 5分钟选择器
            width: 72 * heightRate
            height: 140 * heightRate * 0.5
            anchors.verticalCenter: parent.verticalCenter
            enabled: !timerIsRunning
            visible: currentUserRole != 0 ? false : true
            Column{
                width: 54 * heightRate
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8 *  heightRate

                MouseArea{//30s
                    width: 80 * heightRate
                    height: 32 * heightRate
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        lessTimerCount = 30;
                        startCountDown(lessTimerCount);
                    }

                    Rectangle{
                        anchors.fill: parent
                        color: "#3D3F4E"
                        radius: 2 * heightRate
                        border.width: 1
                        border.color: parent.containsMouse ? "#4D90FF" : "#363847"
                    }

                    Text {
                        text: qsTr("30秒")
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 18 * heightRate
                        anchors.centerIn: parent
                        color: parent.containsMouse ? "#ffffff" : "#797E9F"
                    }
                }

                MouseArea{//60s
                    width: 80 * heightRate
                    height: 32 * heightRate
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        lessTimerCount = 60;
                        startCountDown(lessTimerCount);
                    }

                    Rectangle{
                        anchors.fill: parent
                        color: "#3D3F4E"
                        radius: 2 * heightRate
                        border.width: 1
                        border.color: parent.containsMouse ? "#4D90FF" : "#363847"
                    }

                    Text {
                        text: qsTr("1分钟")
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 18 * heightRate
                        anchors.centerIn: parent
                        color: parent.containsMouse ? "#ffffff" : "#797E9F"
                    }
                }

                MouseArea{//300s
                    width: 80 * heightRate
                    height: 32 * heightRate
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        lessTimerCount = 300;
                        startCountDown(lessTimerCount);
                    }

                    Rectangle{
                        anchors.fill: parent
                        color: "#3D3F4E"
                        radius: 2 * heightRate
                        border.width: 1
                        border.color: parent.containsMouse ? "#4D90FF" : "#363847"
                    }

                    Text {
                        text: qsTr("5分钟")
                        anchors.centerIn: parent
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 18 * heightRate
                        color: parent.containsMouse ? "#ffffff" : "#797E9F"
                    }
                }
            }
        }
    }

    //计时器
    Row{
        id: timingRow
        width: 400 * heightRate
        height: 150 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: tRows.bottom
        anchors.topMargin: 40 * heightRate
        spacing: 10 * heightRate
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
            width: 40 * heightRate
            height: parent.height //- 20 * heightRate

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

    //开始重置按钮
    Row{
        id: bottomRow
        width: 374 * widthRate
        height: 40 * widthRate
        spacing: 22 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 10 * heightRate
        visible: currentUserRole != 0 ? false : true

        MouseArea{
            width: 176 * widthRate
            height: parent.height
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            Rectangle{
                color: "#000000"
                opacity: 0.12
                anchors.fill: parent
            }

            Rectangle{
                color: "#00000000"
                anchors.fill: parent
                border.width: 2
                border.color: parent.containsMouse ? "#4D90FF" : "#363847"
            }

            Text{
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * widthRate
                text: "重置"
                wrapMode: Text.WordWrap
                color: parent.containsMouse ? "#ffffff" : "#727797"
                anchors.centerIn: parent
            }

            onClicked:{
                if(currentIndex == 1)
                {
                    resetAddtTimer();
                    sigResetAddTimer();
                }else{
                    resetCountDown();
                    sigResetCountDownTimer();
                }
            }

        }

        MouseArea{
            id:mousT
            width: 176 * widthRate
            height: parent.height
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            Rectangle{
                anchors.fill: parent
                color: "#000000"
                opacity: 0.12
            }

            Rectangle{
                anchors.fill: parent
                color: "#00000000"
                border.width: 2
                border.color: parent.containsMouse ? "#4D90FF" : "#363847"
            }

            Text{
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * widthRate
                text: !timerIsRunning ? "开始" : "暂停"
                wrapMode: Text.WordWrap
                color: parent.containsMouse ? "#ffffff" : "#797E9F"
                anchors.centerIn: parent
            }

            onClicked:{
                if(currentIndex == 1)
                {
                    if(!timerIsRunning)
                    {
                        //开始计时
                        addTimer.start();
                        sigStartAddTimer(addTimeCount)
                    }else
                    {
                        addTimer.stop();
                        sigStopAddTimer(addTimeCount);
                    }
                    timerIsRunning = !timerIsRunning;
                }else
                {
                    if(lessTimerCount == 0){
                        return;
                    }
                    if(!timerIsRunning){
                        lessTimer.start();
                        sigStartCountDownTimer(lessTimerCount);
                    }else{
                        lessTimer.stop();
                        sigStopCountDownTimer(lessTimerCount);
                    }
                    timerIsRunning = !timerIsRunning;
                }
            }

        }

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

    //重置计时
    function resetAddtTimer(){
        addTimer.stop();
        addTimeCount = 0;
        timerIsRunning = false;
        secondsToMinutes(addTimeCount);
    }

    //根据操作类型 来重置计时器的状态 timerCount 要显示的计时器秒数 opeartionType 1 开始，2 暂停， 3 重置
    function resetTimerRunStatus( timeCount, operationType)
    {
        if( 1 == operationType )
        {
            timerManager.visible = true;
            addTimeCount = timeCount;
            addTimer.start();

        }else if( 2 == operationType )
        {
            timerManager.visible = true;
            addTimeCount = timeCount;
            addTimer.stop();

        }else if( 3 == operationType )
        {
            timerManager.visible = true;
            addTimeCount = timeCount;
            addTimer.stop();
            resetAddtTimer();

        }else if(4 == operationType)//暂定关闭
        {
            timerManager.visible = false;
            addTimeCount = 0;
            addTimer.stop();
        }
    }

    //倒计时设置时间
    function startCountDown(values){
        var minute = parseInt(values / 60);//分
        var second = values % 60;//秒

        var mTen = parseInt(minute / 10);//分钟取十位
        var mOne = minute % 10;//分钟取个位

        var sTen = parseInt(second / 10);//秒取十位
        var sOne = second % 10;//秒取个位

        clockButtonOne.clockValue = mTen;
        clockButtonTow.clockValue = mOne;
        clockButtonThree.clockValue = sTen;
        clockButtonFour.clockValue = sOne;
    }

    //重置倒计时
    function resetCountDown(){
        lessTimerCount = 0;
        startCountDown(lessTimerCount);
        lessTimer.stop();

        timerIsRunning = false;
    }


    //倒计时处理 opeartionType 1 开始，2 暂停， 3 重置 4关闭
    function resetCountDownOperationStatus( timeCount, operationType)
    {
        lessTimerCount = timeCount;
        if( 1 == operationType )
        {
            startCountDown(timeCount);
            lessTimer.start();

        }else if( 2 == operationType )
        {
            startCountDown(timeCount);
            lessTimer.stop();
        }else if( 3 == operationType )
        {
            resetCountDown();
        }else if(operationType == 4)
        {
            lessTimer.stop();
        }
    }

    function resetViewData(viewData)
    {
        if(currentUserRole == assistRole){
            bottomRow.enabled = false;
            tRows.enabled = false;
        }
        if(viewData.flag == 4)
        {
            timerManager.visible = false;
        }else if(viewData.flag == 1 || viewData.flag == 2 || viewData.flag == 3)
        {
            timerManager.visible = true;
        }

        if(viewData.type == 1)
        {
            currentIndex = 1;
            reciprocalRow.visible = false;
            timingRow.visible = true;
            resetTimerRunStatus( viewData.time, viewData.flag);
        }else if(viewData.type == 2)
        {
            currentIndex = 2;
            reciprocalRow.visible = true;
            timingRow.visible = false;
            resetCountDownOperationStatus( viewData.time, viewData.flag);
        }
    }}
