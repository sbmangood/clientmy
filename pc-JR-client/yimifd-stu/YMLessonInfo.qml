import QtQuick 2.0
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import "Configuration.js" as Cfg
//import QtQuick.Window 2.2
import YMLessonManagerAdapter 1.0

/* 学生端课程表中的课时按钮被点击时  显示具体课时信息的弹窗*/

MouseArea {//背景遮罩
    id: lessonView
    z: 66666
    anchors.fill: parent
    hoverEnabled: true

    onWheel: {
        return
    }

    Rectangle{
        anchors.fill: parent
        opacity: 0.4
        radius: 12 * widthRate
        color: "black"
    }

    property var contentData: [];
    property var roomId ;


    property var dateId: 0;
    property var lessonId: 0;
    property var grade: "";
    property var subject: ""
    property var lessonStatus: 0;
    property var relateType: "";
    property var teacherName: ""
    property var startTime: [];
    property var endTime: [];
    property var scheduleId: 0;
    property var hasRecord: 0;
    property var lessonType: "";
    property var hasCourseware: 0;
    property var afterSecond;

    property bool enableClass: false;//禁用教室
    property bool disableHasRecord: false;//禁用录播

    property double  widthRate : parent.width/ 1000.0;
    property double  heightRate : parent.height/ 600.0;
    property bool studentStatus: isStudentUser;

    signal refreshData();

    onStudentStatusChanged: {
        lessonMgr.isStuUser = isStudentUser;
        lessonMgr.setUserType(isStudentUser);
        // console.log(" isStuUser:isStudentUser",lessonMgr.isStuUser,isStudentUser);
    }

    YMLessonManagerAdapter{
        id: lessonMgr

        //显示错误提示对话框
        onSigMessageBoxInfo:
        {
            console.log("=======YMLessonInfo.qml onSigMessageBoxInfo========");
            windowView.showMessageBox(strMsg);
        }

        onSetDownValue:{
            progressbar.min = min;
            progressbar.max = max;
            progressbar.visible = true;
        }
        onDownloadChanged:{
            progressbar.currentValue = currentValue;
        }
        onDownloadFinished:{
            progressbar.visible = false;
        }
        onShowEnterRoomStatusTips:{
            enterClassStatusTipView.startTimer(statusText);
            enterClassRoom = true;
            classView.visible = false;
        }
        onLessonlistRenewSignal: {
            enterClassRoom = true;
            exitRequest = false;
            classView.visible = false;
            requstStatus = false;
            transferPage(0,0);
            accountMgr.getUserLoginStatus();
        }
        onHideEnterClassRoomItem:
        {
            //classView.visible = false;
            classView.hideAfterSeconds();
        }
        onSigRepeatPlayer: {
            massgeTips.tips = "录播暂未生成，请在课程结束半小时后进行查看!";
            massgeTips.visible = true;
        }
    }

    onContentDataChanged: {
        if(contentData == undefined || contentData == null || contentData == []){
            return;
        }

        dateId = contentData.dateId;
        lessonId = contentData.lessonId;
        grade = contentData.grade;
        if(contentData.subject == undefined || contentData.subject == ""){
            subject = contentData.SUBJECT;
        }else{
            subject = contentData.subject;
        }
        roomId = contentData.roomId;
        afterSecond = contentData.afterSecond;
        lessonStatus = contentData.lessonStatus;
        relateType = contentData.relateType;
        teacherName = contentData.teacherName;
        startTime = contentData.startTime;
        endTime = contentData.endTime;
        scheduleId = contentData.scheduleId;
        hasRecord = contentData.hasRecord;
        lessonType = contentData.lessonType;
        hasCourseware = 1; //contentData.hasCourseware;
        updateDisableClass();
        updateHasRecord();
        setAskLeaveButtonVisible();
    }

    Rectangle{
        id: bodyItem
        width: 270*widthRate
        height:210*heightRate
        radius: 12 *widthRate
        color: "#ffffff"
        anchors.centerIn: parent

        MouseArea{
            id: closeButton
            z: 2
            width: 22 * heightRate
            height: 22 * heightRate
            hoverEnabled: true
            anchors.top: parent.top
            anchors.topMargin: 5*heightRate
            anchors.right: parent.right
            anchors.rightMargin: 5*heightRate
            cursorShape: Qt.PointingHandCursor
            Image{
                anchors.fill: parent
                source: "qrc:/images/alert_worktime_close.png"
            }

            onClicked: {
                animation.restart();
            }
        }

        Rectangle{
            id: headItem
            width: parent.width
            height: 75*heightRate
            radius: 12 * widthRate
            anchors.top: parent.top
            Image{
                anchors.fill: parent
                source: lessonType =="O" ? "qrc:/images/dialog_bgblue.png" : "qrc:/images/sh_dialog_bgorg.png"
            }
            //color:  lessonType=="O"? "#D8F4DA":"#ffead9"
            Text{
                id: markText
                text: "课程时间"
                width: 120 * widthRate
                height: 35 * heightRate
                color:lessonType == "O" ? "#3a80cd" : "#ee5a5a"
                font.pixelSize: Cfg.LESSONINFO_FONTSIZE * heightRate
                font.family: Cfg.LESSONINFO_FAMILY
                font.bold: Cfg.LESSONINFO_FONTBOLD
                anchors.left: parent.left
                anchors.leftMargin: Cfg.LESSON_MARGIN * widthRate
                anchors.top: parent.top
                anchors.topMargin: 10*heightRate
                verticalAlignment: Text.AlignVCenter
            }

            Text{
                width: 160 * widthRate
                height: 15 * heightRate
                anchors.top: markText.bottom
                anchors.left: parent.left
                anchors.leftMargin: Cfg.LESSON_MARGIN * widthRate
                text: analysisTime(startTime,endTime)
                color:lessonType == "O" ? "#3a80cd" : "#ee5a5a"
                font.pixelSize: (Cfg.LESSONINFO_FONTSIZE + 4) * heightRate
                font.family: Cfg.LESSONINFO_FAMILY
                font.bold: Cfg.LESSONINFO_FONTBOLD
                verticalAlignment: Text.AlignVCenter
                textFormat: Text.RichText
            }
        }

        Item{
            id: textAreaRectangle
            width: parent.width
            height: parent.height - 160 * heightRate
            anchors.top: headItem.bottom
            Row{
                id: body1
                width: parent.width
                height: 50*heightRate
                anchors.left: parent.left
                anchors.leftMargin:20 * widthRate
                Text{
                    width: 40*widthRate
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    text: "老师:"
                    font.bold: Cfg.LESSONINFO_FONTBOLD
                    font.family: Cfg.LESSONINFO_FAMILY
                    font.pixelSize: Cfg.LESSONINFO_BUTTON_SIZE * heightRate
                    color:"#9b9b9b"
                }
                Text{
                    width: 100 * widthRate
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    text: teacherName == undefined ? "" : teacherName
                    font.bold: Cfg.LESSONINFO_FONTBOLD
                    font.family: Cfg.LESSONINFO_FAMILY
                    font.pixelSize: Cfg.LESSONINFO_BUTTON_SIZE * heightRate
                    color:"#666666"
                }
                Text{
                    width:40*widthRate
                    text: "科目:"
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    font.bold: Cfg.LESSONINFO_FONTBOLD
                    font.family: Cfg.LESSONINFO_FAMILY
                    font.pixelSize: Cfg.LESSONINFO_BUTTON_SIZE * heightRate
                    color:"#9b9b9b"
                }
                Text{
                    text: subject == undefined ? "" : subject
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    font.bold: Cfg.LESSONINFO_FONTBOLD
                    font.family: Cfg.LESSONINFO_FAMILY
                    font.pixelSize: Cfg.LESSONINFO_BUTTON_SIZE * heightRate
                    color: "#666666"
                }
            }

            Row{
                id: body2
                width: parent.width
                height: 10 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: 20 * widthRate
                anchors.top: body1.bottom
                Text{
                    width: 40*widthRate
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    font.bold: Cfg.LESSONINFO_FONTBOLD
                    font.family: Cfg.LESSONINFO_FAMILY
                    font.pixelSize: Cfg.LESSONINFO_BUTTON_SIZE * heightRate
                    color:"#9b9b9b"
                    text: "学段:"
                }
                Text{
                    width: 73*widthRate
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    font.bold: Cfg.LESSONINFO_FONTBOLD
                    font.family: Cfg.LESSONINFO_FAMILY
                    font.pixelSize: Cfg.LESSONINFO_BUTTON_SIZE * heightRate
                    color:"#666666"
                    text: grade  == undefined ? "" : grade

                }
                Text{
                    width:67*widthRate
                    font.bold: Cfg.LESSONINFO_FONTBOLD
                    font.family: Cfg.LESSONINFO_FAMILY
                    font.pixelSize: Cfg.LESSONINFO_BUTTON_SIZE * heightRate
                    color:"#9b9b9b"
                    text: "课程编号:"
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                }
                Text{
                    font.bold: Cfg.LESSONINFO_FONTBOLD
                    font.family: Cfg.LESSONINFO_FAMILY
                    font.pixelSize: Cfg.LESSONINFO_BUTTON_SIZE * heightRate
                    color:"#666666"
                    text: '<strong>' + lessonId + '</strong>'
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    width: 70 * widthRate
                    elide: Text.ElideRight
                }
            }
        }
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15 * heightRate
            spacing: askLeaveButton.visible ? 8 * widthRate : 12 * widthRate
            //请假按钮
            MouseArea{
                id: askLeaveButton
                width: visible ? 77 * widthRate : 110 * widthRate
                height: 35 * heightRate
                visible: false
                cursorShape: Qt.PointingHandCursor
                Rectangle{
                    radius: 3 * heightRate
                    anchors.fill: parent
                    color: "#ff5000"
                    Text{
                        text: "请假"
                        anchors.centerIn: parent
                        color: "#ffffff"
                        font.bold: Cfg.LESSONINFO_FONTBOLD
                        font.family: Cfg.LESSONINFO_FAMILY
                        font.pixelSize: Cfg.LESSONINFO_BUTTON_SIZE * heightRate
                    }
                }

                onClicked: {
                    lessonView.visible=false;
                    askForLeaveView.showAskForLeaveView();
                    askForLeaveView.visible = true;
                    askForLeaveView.lessonId = lessonId;
                }
            }
            MouseArea{
                id: lessonButton
                width: askLeaveButton.visible ? 77 * widthRate : 110 * widthRate
                height: 35 * heightRate
                enabled: hasCourseware == 1 ? true : false
                Rectangle{
                    radius: 2
                    anchors.fill: parent
                    color: hasCourseware == 1 ? Cfg.TB_CLR : "#c3c6c9"
                    border.width: 1
                    border.color: hasCourseware == 1 ? Cfg.TB_CLR : "#c3c6c9"
                    Text{
                        text: "查看课件"
                        anchors.centerIn: parent
                        color: "#ffffff"
                        font.bold: Cfg.LESSONINFO_FONTBOLD
                        font.family: Cfg.LESSONINFO_FAMILY
                        font.pixelSize: Cfg.LESSONINFO_BUTTON_SIZE * heightRate
                    }
                }

                onClicked: {

                    //                    var lessonInfo = {
                    //                        "lessonId": lessonId,
                    //                        "startTime": analysisDate(startTime),
                    //                        "lessonStatus":hasRecord == 0 ? 0 : 1
                    //                    };
                    //                    lessonMgr.getLookCourse(lessonInfo);
                    var lessonInfos = {
                        "appId":"3edaf2877c994a4e8739dbe34411e7d7",//"354937763033780224",
                        "appKey":"a995732df99bc794",
                        "roomId":roomId,//"354937763033780224", //教室id
                        "userId": userId, //用户id
                        "userRole": isStudentUser ? "1" : "3",
                                                    "nickName": userName, //用户昵称或者名字
                                                    "envType": strStage,//运行环境类型，如sit01
                    };
                    lessonMgr.runCourse(lessonInfos);
                    animation.restart();
                }
            }
            MouseArea{
                id:joinRoombutton
                width: askLeaveButton.visible ? 77 * widthRate : 110 * widthRate
                height: 33 * heightRate
                enabled: (enableClass ? true : false)
                cursorShape: Qt.PointingHandCursor
                Rectangle{
                    radius: 2 * heightRate
                    color: hasRecord == 1 ? (enableClass ? "#ff5000" : "#c3c6c9") : (enableClass ? "#ff5000" : "#c3c6c9")
                    anchors.fill: parent
                    border.width: 1
                    border.color: (enableClass ? Cfg.TB_CLR : "#c3c6c9")
                    Text{
                        id:joinRoomButtonTextItem
                        //"课程表"中, 点击某一节课的"进入教室"
                        text:lessonStatus == 1 ? (hasRecord == 0  ? "录播生成中" : "查看录播") : (isStudentUser ? "进入教室" : "进入旁听")
                        //text: hasRecord == 0 ? (isStudentUser ? "进入教室" : "进入旁听") : "查看录播"
                        font.bold: Cfg.LESSONINFO_FONTBOLD
                        font.family: Cfg.LESSONINFO_FAMILY
                        font.pixelSize: Cfg.LESSONINFO_BUTTON_SIZE * heightRate
                        color: hasRecord == 1 ? (enableClass ? "#ffffff" : "#ffffff") : "#ffffff"
                        anchors.centerIn: parent
                    }
                }

                onClicked: {
                    animation.restart();

                    var lessonInfos = {
                        "appId":"3edaf2877c994a4e8739dbe34411e7d7",//"354937763033780224",
                        "appKey":"a995732df99bc794",
                        "roomId":roomId,//"354937763033780224", //教室id
                        "userId": userId, //用户id
                        "userRole": isStudentUser ? "1" : "3",
                                                    "nickName": userName, //用户昵称或者名字
                                                    "envType": strStage,//运行环境类型，如sit01
                    };
                    if(lessonStatus == 0){
                        if(enterClassRoom){
                            //"课程表"中, , 点击某一节课的"进入教室", 然后显示: "正在进入教室..."对话框
                            classView.visible = true;
                            //                            enterClassRoom = false; //"进入教室"按钮, 一直都可以点击, 因为在classroom程序中, 已经控制了, 只有一个实例
                            classView.tips = isStudentUser ? "正在进入教室..." : "正在进入旁听..."
                            lessonMgr.lessonType = lessonType;
                            lessonMgr.lessonPlanStartTime = getDateTimeString(contentData.startTime);
                            lessonMgr.lessonPlanEndTime = getDateTimeString(contentData.endTime);
                            //lessonMgr.getEnterClass(lessonId,interNetGrade);
                            //classView.visible = false;
                            classView.hideAfterSeconds();
                            lessonMgr.runClassRoom(lessonInfos);
                        }
                    }else{
                        var lessonInfo = {
                            "lessonId": lessonId,
                            "startTime": analysisDate(startTime),
                            "subject": subject,
                            "name": teacherName,
                        };
                        progressbar.currentValue = 0;
                        //lessonMgr.getRepeatPlayer(lessonInfo);
                        lessonMgr.runPlayer(lessonInfos);
                    }
                }
            }
        }
    }
    //动画过渡
    NumberAnimation {
        id: animateOpacity
        target: lessonView
        duration: 500
        properties: "opacity"
        from: 0.0
        to: 1.0
    }
    NumberAnimation {
        id: animateOpacityFadeout
        target: lessonView
        duration: 500
        properties: "opacity"
        from: 1.0
        to: 0.0
    }

    //退出缩小动画
    PropertyAnimation{
        id: animation
        target: bodyItem
        property: "height"
        from: 210 * heightRate
        to: 0
        duration:300
        onStarted: {
            animateOpacityFadeout.start();
            textAreaRectangle.visible=false;
            joinRoombutton.visible=false;
            lessonButton.visible=false;
            askLeaveButton.visible = false;
        }

        onStopped:{
            lessonView.visible = false;
        }
    }
    //弹出放大动画
    PropertyAnimation{
        id: animationHeight
        target: bodyItem
        property: "height"
        from: 0
        to: 210 * heightRate
        duration:300
        onStarted:
        {
            textAreaRectangle.visible=true;
            joinRoombutton.visible=true;
            lessonButton.visible=true;
        }
    }
    function startFadeOut(){
        animateOpacity.stop();
        animateOpacity.start();
        // animation.restart();
        animationHeight.restart();
    }
    function getDateTimeString(dateTime)
    {
        Date.prototype.format = function(format)
        {
            var o = {
                "M+" : this.getMonth()+1, //month
                "d+" : this.getDate(),    //day
                "h+" : this.getHours(),   //hour
                "m+" : this.getMinutes(), //minute
                "s+" : this.getSeconds(), //second
                "q+" : Math.floor((this.getMonth()+3)/3),  //quarter
                "S" : this.getMilliseconds() //millisecond
            }
            if(/(y+)/.test(format)) format=format.replace(RegExp.$1,
                                                          (this.getFullYear()+"").substr(4 - RegExp.$1.length));
            for(var k in o)if(new RegExp("("+ k +")").test(format))
                    format = format.replace(RegExp.$1,
                                            RegExp.$1.length==1 ? o[k] :
                                                                  ("00"+ o[k]).substr((""+ o[k]).length));
            return format;
        }

        return (new Date(parseInt(dateTime))).format('yyyy-MM-dd hh:mm');
    }

    /*进入教室按钮：距课程开始时间小于等于30分钟、课程时间段内、课程时间段结束1小时内（课程未完成），
    点击进入教室按钮可进入教室，其余时间段按钮disable；
    课程时间结束后（双方曾进入教室上课）、教师与学生双方完成课程后，进入教室按钮disable；*/

    //进入教室函数
    function updateDisableClass(){
        //请假课 不可进教室
        if(lessonStatus == 2 || lessonStatus == 3){
            enableClass = false;
            return;
        }
        var startDateTime = new Date(startTime);
        var endDateTime = new Date(endTime);
        var currentDate = new Date();

        //开始结束时间大于一天则禁用进入教室
        var year = startDateTime.getFullYear() - currentDate.getFullYear();
        var date = startDateTime.getDate() - currentDate.getDate();
        var mother = startDateTime.getMonth() - currentDate.getMonth();

        var e = endDateTime.getHours()* 3600 + endDateTime.getMinutes() * 60 + endDateTime.getSeconds();
        var s = startDateTime.getHours() * 3600 + startDateTime.getMinutes() * 60 + startDateTime.getSeconds();
        var c = currentDate.getHours() * 3600 + currentDate.getMinutes() * 60 + currentDate.getSeconds();

        //全天课
        if(startDateTime.getHours() == 0 && startDateTime.getMinutes() == 0
                && endDateTime.getHours() == 23 && endDateTime.getMinutes() == 59
                && date == 0 && mother == 0 && year == 0){
            enableClass = true;
            return;
        }

        //c - s <= 30 * 60 当前时间 - 开始时间 小于等于30分钟内
        //小于等于30分钟
        if(c - s <= 30 * 60 && year == 0 && date == 0 && mother == 0){
            if(c -s <= -1800){
                enableClass = false;
                //console.log("enableClass:221",enableClass);
                return;
            }
            enableClass = true;
            //console.log("enableClass:22",enableClass);
            return;
        }

        if(afterSecond != undefined)
        {
            //课程未结束根据 afterSecond 判定进入时间
            var endMs = endDateTime.valueOf() / 1000;
            var currentMs = currentDate.valueOf() / 1000;

            if(lessonStatus == 0 && endMs - currentMs <= 0 && endMs + afterSecond - currentMs >=0){
                enableClass = true;
                return;
            }
        }

        //课程结束时间1小时内可以进入教室
        if(e + 3600 - c <= 3600 && year == 0 && date == 0 && e + 3600 - c >= 0 && mother == 0){
            enableClass = true;
            //console.log("enableClass:3",enableClass);
            return;
        }

        if(lessonStatus == 0 && currentDate.getTime() >= startDateTime.getTime() && currentDate.getTime() <= endDateTime.getTime())
        {
            enableClass = true;
            return;
        }

        //当天当、前时间段内、 //e > c && s < c为课程时间段内
        if(e >= c && s <= c && year == 0 &&  date == 0 && mother == 0){
            enableClass = true;
            //console.log("enableClass:1",enableClass);
            return;
        }
        //课程时间段未结束1小时内
        if(lessonStatus == 0 && e + 3600 - c <= 3600 && e + 3600 -c >=0 && year == 0 && date == 0 && mother == 0){
            enableClass = true;
            //console.log("enableClass:2",enableClass,e + 3600 - c);
            return;
        }
        //console.log("enableClass:5",enableClass);

        if((endDateTime.getTime()-currentDate.getTime()) / 1000 / 60 > -60 && lessonStatus == "0" && (endDateTime.getTime() < currentDate.getTime()))
        {
            enableClass = true;
            return;
        }

        enableClass = false;
    }

    //禁用录播函数
    function updateHasRecord(){
        var date = new Date();
        var endDate = new Date(endTime);
        var c = date.getHours() * 3600 + date.getMinutes() * 60 + date.getSeconds();//开始时间
        var e = endDate.getHours() * 3600 + endDate.getMinutes() * 60 + endDate.getSeconds();//课程结束时间

        //课程结束一小时后查看录播
        if(lessonStatus == 1 && hasRecord == 1 && c  - e >= 3600){
            hasRecord = 1;
            enableClass = true;
            return;
        }
        //课程完成并且有课件查看录播
        if(lessonStatus  == 1 && hasRecord == 1){
            hasRecord = 1;
            enableClass = true;
            return;
        }
        //课程完成但是无录播则查看录播禁用
        if(lessonStatus == 1 && hasRecord == 0){
            hasRecord = 0;
            enableClass = false;
            return;
        }
        hasRecord = 0;
    }

    function analysisDate(startTime){
        var currentStartDate = new Date(startTime);
        var year = currentStartDate.getFullYear();
        var month = Cfg.addZero(currentStartDate.getMonth() + 1);
        var day = Cfg.addZero(currentStartDate.getDate());

        return year + "-" + month + "-" + day;
    }

    function analysisTime(startTime,endTime){
        var date = analysisDate(startTime);
        var currentStartDate = new Date(startTime);
        var currentEndDate = new Date(endTime);
        var sTime = Cfg.addZero(currentStartDate.getHours()) + ":" + Cfg.addZero(currentStartDate.getMinutes());
        var eTime = Cfg.addZero(currentEndDate.getHours()) + ":" + Cfg.addZero(currentEndDate.getMinutes());
        return date + " " + sTime + "-" + eTime;
    }

    function setAskLeaveButtonVisible() {
        askLeaveButton.visible = false;
        var startDateTime = new Date(startTime);
        var currentDate = new Date();
        //是订单课 并且课程没有结束或过期  并且当前时间不可以进入教室  才可以请假
        if(lessonStatus == 0 && lessonType == "O"
                && joinRoomButtonTextItem.text.indexOf("进入")>=0
                && (startDateTime.getTime()-currentDate.getTime() > 0)
                /*&& joinRoombutton.enabled == false*/) {
            /* var startDateTime = new Date(startTime);
              var currentDate = new Date();
           */
            //console.log("可以请假",currentDate.getTime()-startDateTime.getTime());

            if(startDateTime.getTime()-currentDate.getTime() > 0) {
                // 24小时之外  不扣除课时
                if(startDateTime.getTime()-currentDate.getTime() >= 86400000) {
                    //console.log("24时之外 不扣除课时");
                    askForLeaveView.isWithinTwentyFourHoursLesson = false;
                }else {//24小时之内  扣除课时
                    //console.log("24时之内 扣除课时");
                    askForLeaveView.isWithinTwentyFourHoursLesson = true;
                }
                askLeaveButton.visible = true;
            }
        }
        else {
            //console.log("不可以请假")
            askLeaveButton.visible = false;
        }
    }
}

