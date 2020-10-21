import QtQuick 2.0
import QtQuick.Controls 1.4
import YMLessonManagerAdapter 1.0

import "Configuration.js" as Cfg

/***课程表详细信息***/

MouseArea {
    id: lessonView
    z: 8888
    anchors.fill: parent
    onWheel: {
        return;
    }

    property var lessonData: [];
    property bool displayerStatus: false;//显示窗体状态

    property string contractNo: "";
    property string subject: "";
    property string parentContactInfo: "";
    property int lessonId: 0;
    property string clientNo: "";
    property string relateType: "";
    property int hasCourseware: 0;
    property string chargeMobile: "";
    property string parentRealName: "";
    property string grade: "";
    property string name: "";
    property var startTime: [];
    property var endTime: [];
    property var nowTime: [];
    property string chargeName: "";
    property int hasRecord: 0;
    property string lessonType: "";
    property string lessonStatus: "";
    //property int name: value
    property string teacherId: "";
    property var afterSecond;

    property bool disableHasRecord: false; //禁用录播
    property bool enableClass: false;//禁用教室
    property int listenFlag: 0;//是否有试听报告 0 无， 1有 2填写报告

    property double  widthRate : parent.width/ 1000.0;
    property double  heightRate : parent.height/ 600.0;

    signal lessonRefreshData();

    //遮罩颜色
    Rectangle{
        color: "black"
        opacity: 0.4
        radius:  12 * widthRate
        anchors.fill: parent
    }

    onDisplayerStatusChanged: {
        lessonView.visible = true;
        animateInOpacity.start();
    }
    //淡入效果
    NumberAnimation{
        id: animateInOpacity
        target: lessonView
        duration: 300
        properties: "opacity"
        from: 0.0
        to: 1.0
        onStarted: {
            animationHeight.start();
        }
    }

    //淡出效果
    NumberAnimation{
        id: animateOutOpactiy
        target: lessonView
        duration: 300
        properties: "opacity"
        from: 1.0
        to: 0.0
        onStopped: {
            lessonView.visible = false;
        }
        onStarted: {
            animation.start();
        }
    }

    //退出缩小动画
    PropertyAnimation{
        id: animation
        target: bodyItem
        property: "height"
        from: 380 * heightRate
        to: 0
        duration: 300
    }
    //弹出放大动画
    PropertyAnimation{
        id: animationHeight
        target: bodyItem
        property: "height"
        from: 0
        to: 380 * heightRate
        duration: 300
        onStarted:{
            bodyItem.visible = true;
        }
    }

    YMLessonManagerAdapter{
        id: lessonMgr

        //显示错误提示对话框
        onSigMessageBoxInfo:
        {
            console.log("=======YMLessonInfo.qml onSigMessageBoxInfo========");
            windowView.showMessageBox(strMsg);
        }

        onLessonlistRenewSignal: {
            lessonView.visible = false;
            classView.visible = false;
            enterClassRoom = true;
            lessonRefreshData();
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
        onListenChange:{
            enterClassRoom = true;
            massgeTips.tips = "还未开始上课，暂时无法旁听!";
            massgeTips.visible = true
            classView.visible = false;
        }
        onProgramRuned:{
            // classView.visible = false;
            classView.hideAfterSeconds();
        }
        onRequstTimeOuted: {
            lessonView.visible = false;
            classView.visible = false;
            enterClassRoom = true;
        }
        onSigRepeatPlayer: {
            massgeTips.tips = "录播暂未生成，请在课程结束半小时后进行查看!";
            massgeTips.visible = true;
        }
    }

    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
    }

    //数据接收
    onLessonDataChanged: {
        if(lessonData == null || lessonData == [] || lessonData.lessonId == undefined){
            return;
        }
        console.log("===lessonInfo===",JSON.stringify(lessonData))
        afterSecond = lessonData.afterSecond;
        lessonId = lessonData.lessonId;
        contractNo = lessonData.contractNo;
        subject = lessonData.subject;
        parentContactInfo = lessonData.parentContactInfo;
        clientNo = lessonData.clientNo;
        relateType = lessonData.relateType;
        hasCourseware = lessonData.hasCourseware;
        chargeMobile = lessonData.chargeMobile;
        parentRealName = lessonData.parentRealName;
        grade = lessonData.grade;
        chargeName = lessonData.chargeName;
        lessonType = lessonData.lessonType;
        name = lessonData.name;
        hasRecord = lessonData.hasRecord;
        startTime = lessonData.startTime;
        endTime = lessonData.endTime;
        lessonStatus = lessonData.lessonStatus;
        nowTime = lessonData.systemNowTime;
        teacherId = lessonData.teacherId;

        updateDisableClass();
        updateHasRecord();
        listenFlag = lessonMgr.getLessonComment(lessonId);
        //console.log("teacherId:",teacherId,userId)
    }

    Rectangle{
        id: bodyItem
        z: 2
        width: 270 * widthRate
        height: 280 * heightRate
        radius: 12 * widthRate
        color: "#ffffff"
        anchors.centerIn: parent

        MouseArea{
            id: closeButton
            z: 2
            width: 22 * widthRate
            height: 22 * widthRate
            hoverEnabled: true
            anchors.top: parent.top
            anchors.topMargin: 5*heightRate
            anchors.right: parent.right
            anchors.rightMargin: 5*heightRate
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: "qrc:/images/closeBtn.png"
            }

            onClicked: {
                animateOutOpactiy.start();
            }
        }

        Rectangle{
            id: headItem
            width: parent.width
            height: 95 * heightRate
            radius: 12 * widthRate
            anchors.top: parent.top
            Image{
                anchors.fill: parent
                source: lessonType == "O" ? "qrc:/images/dialog_bgblue.png" : "qrc:/images/sh_dialog_bgorg.png"
            }

            //color: lessonType == "O" ? "#D8F4DA" : "#ffead9"
            Row{
                id: oneRow
                width: parent.width
                height: 22*heightRate
                anchors.left: parent.left
                anchors.leftMargin: Cfg.LESSON_MARGIN * heightRate
                spacing: 10 * heightRate
                anchors.top: parent.top
                anchors.topMargin: 12 * heightRate

                Text{
                    height: parent.height
                    text: analysisDate(startTime)
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_INFO_3FONTSIZE  * heightRate
                    color:lessonType == "O" ? "#3a80cd" : "#ee5a5a"
                    verticalAlignment: Text.AlignVCenter
                }

                Text{
                    height: parent.height
                    text: {
                        analysisTime(startTime,endTime);
                    }
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_INFO_3FONTSIZE * heightRate
                    color:lessonType == "O" ? "#3a80cd" : "#ee5a5a"
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Row{
                id:nameGradeSubjectRow
                width: parent.width * 0.5
                height: 24 * heightRate
                anchors.top: oneRow.bottom
                anchors.left: parent.left
                anchors.leftMargin: Cfg.LESSON_MARGIN * heightRate
                spacing: 10 * heightRate

                Text{
                    height: parent.height
                    text: lessonView.name
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_INFO_2FONTSIZE * heightRate
                    color:lessonType == "O" ? "#3a80cd" : "#ee5a5a"
                    verticalAlignment: Text.AlignVCenter
                }

                Text{
                    width: 40 * widthRate
                    height: parent.height
                    text: grade + subject
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_INFO_2FONTSIZE * heightRate
                    color:lessonType == "O" ? "#3a80cd" : "#ee5a5a"
                    verticalAlignment: Text.AlignVCenter
                    //elide: Text.ElideRight
                }
            }
            Row{
                anchors.left: parent.left
                anchors.leftMargin: Cfg.LESSON_MARGIN * widthRate
                anchors.top: nameGradeSubjectRow.bottom
                anchors.topMargin: 2 * heightRate
                width: 68 * widthRate
                height: 24 * heightRate
                spacing: 5 * widthRate
                Rectangle{
                    width: 30 * widthRate
                    height: 16 * heightRate
                    color:lessonType == "O" ? "#3a80cd" : "#ee5a5a"
                    radius: 2 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    Text{
                        text: lessonStatus == "1" ? "已完成" : "预排"
                        color: "#ffffff"
                        font.family: Cfg.LESSON_FONT_FAMILY
                        font.pixelSize: 10 * heightRate
                        anchors.centerIn: parent
                    }
                }
                Rectangle{
                    width: 45 * widthRate
                    height: 16 * heightRate
                    color:lessonType == "O" ? "#3a80cd" : "#ee5a5a"
                    radius: 2 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    Text{
                        text: {
                            if(lessonType == "O"){
                                return "订单课";
                            }
                            if(lessonType == "A"){
                                return "试听课";
                            }
                            if(lessonType == "L"){
                                return "直播课";
                            }
                            if(lessonType == "V"){
                                return "请假";
                            }
                            return "订单课"
                        }
                        color: "#ffffff"
                        font.family: Cfg.LESSON_FONT_FAMILY
                        font.pixelSize: 10 * heightRate
                        anchors.centerIn: parent
                    }
                }
            }
        }

        Item{
            id: lessonInfoItem
            width: parent.width
            height: parent.height - headItem.height - 140 * heightRate
            anchors.top: headItem.bottom

            Column{
                id: body1
                width: parent.width
                height: parent.height
                anchors.left: parent.left
                anchors.leftMargin: Cfg.LESSON_MARGIN*heightRate
                anchors.top: parent.top
                anchors.topMargin: 10 * heightRate
                spacing: 10 * widthRate

                Text{
                    verticalAlignment: Text.AlignVCenter
                    text: "客户编号：" + clientNo
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
                    color: Cfg.LESSON_HEAD_FONT_COLOR
                }

                Text{
                    text: "订单编号：" + contractNo
                    verticalAlignment: Text.AlignVCenter
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
                    color: Cfg.LESSON_HEAD_FONT_COLOR
                }

                Text{
                    verticalAlignment: Text.AlignVCenter
                    text: "课程编号：" + lessonId
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_FONT_SIZE*heightRate
                    color: Cfg.LESSON_HEAD_FONT_COLOR
                }


                Text{
                    width: parent.width
                    verticalAlignment: Text.AlignVCenter
                    text: "班主任：" + chargeName + " - " + chargeMobile
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
                    color: Cfg.LESSON_HEAD_FONT_COLOR
                }

                Text{
                    width: parent.width
                    verticalAlignment: Text.AlignVCenter
                    text: "家长：" + parentRealName  + " - " + parentContactInfo
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
                    color: Cfg.LESSON_HEAD_FONT_COLOR
                }
            }
        }

        MouseArea{
            id: lessonButton
            width: 115 * widthRate
            height: 67 * heightRate
            enabled: hasCourseware == 1 ? true : false
            anchors.left: parent.left
            anchors.leftMargin: 15 * widthRate
            anchors.top: lessonInfoItem.bottom
            anchors.topMargin: 10 * heightRate
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                radius: 2 * heightRate
                anchors.fill: parent
                color: hasCourseware == 1 ? "#f3f6f9" : "#f9f9f9"
                border.width: 1
                border.color: hasCourseware == 1 ? "#f3f6f9" : "#f9f9f9"
                Image {
                    id: courseImg
                    width: 24 * heightRate
                    height: 24 * heightRate
                    anchors.top: parent.top
                    anchors.topMargin: (parent.height - height - courseText.height) * 0.5
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: hasCourseware == 1 ? "qrc:/images/popwindow_btn_classfile_defult.png" : "qrc:/images/popwindow_btn_classfile_disable.png"
                }
                Text{
                    id: courseText
                    text: "查看课件"
                    color: hasCourseware == 1 ? "#333333" : "#aaaaaa"
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: (Cfg.LESSON_FONT_SIZE - 2) * heightRate
                    anchors.top: courseImg.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            onClicked: {
                var lessonInfo = {
                    "lessonId": lessonId,
                    "startTime": analysisDate(startTime),
                    "lessonStatus":hasRecord == 0 ? 0 : 1
                }
                lessonView.visible = false;
                lessonMgr.getLookCourse(lessonInfo);
            }
        }

        MouseArea{//试听课报告按钮
            id: trialButton
            width: 115 * widthRate
            height: 67 * heightRate
            enabled: ((listenFlag == 1 || listenFlag == 2) && lessonStatus == 1) ? true : false
            anchors.left: lessonButton.right
            anchors.leftMargin: 10 * widthRate
            anchors.top: lessonInfoItem.bottom
            anchors.topMargin: 10 * heightRate
            cursorShape: Qt.PointingHandCursor

            Rectangle{
                radius: 2 * heightRate
                color: (listenFlag == 1 || listenFlag == 2) && lessonStatus == 1 ? "#f3f6f9" : "#f9f9f9"
                anchors.fill: parent
                border.width: 1
                border.color: ((listenFlag == 1 || listenFlag == 2) && lessonStatus == 1  ?  "#f3f6f9" : "#f9f9f9")

                Image {
                    id: listenImg
                    width: 24 * heightRate
                    height: 24 * heightRate
                    anchors.top: parent.top
                    anchors.topMargin: (parent.height - height - courseText.height) * 0.5
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: ((listenFlag == 1 || listenFlag == 2) && lessonStatus == 1)  ? "qrc:/images/popwindow_btn_report_defult.png" : "qrc:/images/popwindow_btn_report_disable.png"
                }

                Text{
                    text: {
                        if(listenFlag == 2 && lessonStatus == 1)
                        {
                            return "填写试听报告"
                        }
                        if(lessonType == "O"){
                            return "查看课堂报告";
                        }
                        if(lessonType == "A"){
                            return "查看试听课报告";
                        }
                        return  "查看试听课报告";
                    }
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: (Cfg.LESSON_FONT_SIZE - 2) * heightRate
                    color: (listenFlag == 1 || listenFlag == 2) && lessonStatus == 1 ? "#333333" : "#aaaaaa"
                    anchors.top: listenImg.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            onClicked: {
                var url = "";
                if(listenFlag == 0){
                    url = URL_ClassroomReport + lessonId;
                    console.log(url);
                    Qt.openUrlExternally(url);
                }
                if(listenFlag == 1){
                    url = ListenUrl + lessonId + "&report=1";
                    console.log(url);
                    Qt.openUrlExternally(url);
                }
                if(listenFlag == 2){
                    url = Write_ListenUrl + lessonId;
                    console.log(url);
                    Qt.openUrlExternally(url);
                }
            }
        }

        MouseArea{//进入教室查看录播
            id: joinClassBtn
            width: 240 * widthRate
            height: 33 * heightRate
            enabled: enableClass ? true : false
            anchors.left: parent.left
            anchors.leftMargin: 15 * widthRate
            anchors.top: trialButton.bottom
            anchors.topMargin: 10 * heightRate
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                radius: 2 * heightRate
                color: hasRecord == 1 ? (enableClass ? "#ff5000" : "#c3c6c9") : (enableClass ? "#ff5000" : "#c3c6c9")
                anchors.fill: parent
                border.width: 1
                border.color: (enableClass ? Cfg.TB_CLR : "#c3c6c9")

                Text{
                    text:lessonStatus == 1 ? (hasRecord == 0  ?  "录播生成中" : "查看录播") : "进入教室"
                    //text: hasRecord == 0 ? "进入教室" : "查看录播"//( teacherId == userId ? "进入教室" : "进入旁听") :"查看录播"
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_INFO_3FONTSIZE * heightRate
                    color: hasRecord == 1 ? (enableClass ? "#ffffff" : "#ffffff") : "#ffffff"
                    anchors.centerIn: parent
                }
            }
            onClicked: {
                if(lessonStatus == 0 ){
                    if(enterClassRoom){
                        classView.visible = true;
                        //enterClassRoom = false;
                        if(teacherId == userId){
                            classView.visible = true;
                            //                            enterClassRoom = false; //"进入教室"按钮, 一直都可以点击, 因为在classroom程序中, 已经控制了, 只有一个实例
                            classView.tips = "进入教室中..."
                            lessonControl.visible = false;
                            lessonMgr.lessonType = lessonType;
                            lessonMgr.lessonPlanStartTime = getDateTimeString(lessonData.startTime);
                            lessonMgr.lessonPlanEndTime = getDateTimeString(lessonData.endTime);
                            lessonMgr.getEnterClass(lessonId,interNetGrade);
                        }else{//进入旁听
                            //                            classView.tips = "进入旁听中..."
                            //                            lessonMgr.getListen(lessonId)
                            var isStartLesson = true;
                            //如果老师在上课则弹窗
                            if(isStartLesson){
                                lessonView.visible = false;
                                joinClasstipsView.isShowLessonInfo = true;
                                joinClasstipsView.fromStatus = 1;
                                joinClasstipsView.visible = true;
                            }
                            else{//没有上课则直接进入旁听
                                classView.tips = "进入教室中..."
                                lessonMgr.getListen(lessonId)
                            }
                        }
                        //console.log("====enterClassRoom===",enterClassRoom)
                    }
                }
                else{
                    var lessonDataInfo = {
                        "lessonId": lessonId,
                        "startTime": analysisDate(startTime),
                        "gradeName":grade,//年级
                        "subjectName": subject,//科目
                        "realName": realName,//姓名
                    }
                    progressbar.currentValue = 0;
                    lessonMgr.getRepeatPlayer(lessonDataInfo);
                    lessonView.visible = false
                }
            }
        }

    }

    Connections{
        target: windowView
        onSigListenTips:{
            if(1 == status)
            {
                classView.visible = true;
                //            enterClassRoom = false;  //"进入教室"按钮, 一直都可以点击, 因为在classroom程序中, 已经控制了, 只有一个实例
                classView.tips = "进入教室中..."
                lessonMgr.getListen(lessonId);
            }
        }
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

    function analysisDate(startTime){
        var currentStartDate = new Date(parseInt(startTime));
        //console.log("====analysisDate====",currentStartDate,startTime);
        var year = currentStartDate.getFullYear();
        var month = Cfg.addZero(currentStartDate.getMonth() + 1);
        var day = Cfg.addZero(currentStartDate.getDate());

        return year + "-" + month + "-" + day;
    }

    function analysisTime(startTime,endTime){
        var currentStartDate = new Date(parseInt(startTime));
        var currentEndDate = new Date(parseInt(endTime));
        var sTime = Cfg.addZero(currentStartDate.getHours()) + ":" + Cfg.addZero(currentStartDate.getMinutes());
        var eTime = Cfg.addZero(currentEndDate.getHours()) + ":" + Cfg.addZero(currentEndDate.getMinutes());
        return sTime + "-" + eTime;
    }

    /*5、查看录播按钮：
    1）课程提交完成后，系统生成录播，进入教室按钮变更为“查看录播”按钮，点击查看录播进入录播页面；
    2）临时退出教室，在课程时间段结束1小时后，系统生成录播，进入教室按钮变更为“查看录播”按钮；点击查看录播进入录播页面，
    3）无录播时按钮disable。*/

    function updateHasRecord(){
        var date = new Date();
        var endDate = new Date(parseInt(endTime));
        var c = date.getHours() * 3600 + date.getMinutes() * 60 + date.getSeconds();//开始时间
        var e = endDate.getHours() * 3600 + endDate.getMinutes() * 60 + endDate.getSeconds();//课程结束时间

        //课程结束一小时后查看录播
        if(lessonStatus == "1" && hasRecord == 1 && c  - e >= 3600){
            hasRecord = 1;
            enableClass = true;
            //console.log("disibleHasRecord1")
            return;
        }
        //课程完成并且有课件查看录播
        if(lessonStatus  == "1" && hasRecord == 1){
            hasRecord = 1;
            enableClass = true;
            //console.log("disibleHasRecord2")
            return;
        }
        //课程完成但是无录播则查看录播禁用
        if(lessonStatus == "1" && hasRecord == 0){
            hasRecord = 0;
            enableClass = false;
            //console.log("disibleHasRecord3")
            return;
        }
        //console.log("disibleHasRecord4")
        hasRecord = 0;
    }

    /*进入教室按钮：距课程开始时间小于等于30分钟、课程时间段内、课程时间结束1小时内（课程未完成），
    点击进入教室按钮可进入教室，其余时间段按钮disable；
    课程时间结束后（双方曾进入教室上课）、教师与学生双方完成课程后，进入教室按钮disable；
    */
    function updateDisableClass(){
        //请假课 不可进教室
        if(lessonStatus == "2" || lessonStatus == "3" || lessonStatus == "4")
        {
            enableClass = false;
            return;
        }

        var startDateTime = new Date(parseInt(startTime));
        var endDateTime = new Date(parseInt(endTime));

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

        //当天当、前时间段内、 //e > c && s < c为课程时间段内
        if(e >= c && s <= c && year == 0 &&  date == 0 && mother == 0){
            enableClass = true;
            //console.log("enableClass:1",enableClass);
            return;
        }
        //课程时间段未结束1小时内
        if(lessonStatus == "0" && e + 3600 - c <= 3600 && e + 3600 -c >=0){
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

}

