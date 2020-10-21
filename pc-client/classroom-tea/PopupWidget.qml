﻿import QtQuick 2.5

MouseArea {
    id:popupWidget

    Rectangle{
        anchors.fill: parent
        color: "#111111"
        opacity: 0.8
    }

    property double widthRates: popupWidget.width /  1440.0
    property double heightRates: popupWidget.height / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    //退出教室
    signal sigCloseAllWidget();

    //等待界面显示内容
    property string  waitWidgetContent: "0"

    //退出程序
    signal sigExitProject();

    //主动退出教室的
    signal selectWidgetType(int types);

    //拒绝学生申请离开教室信号
    signal sigRefuse();

    //同意学生离开教室
    signal sigAgree();

    //同意B学生进入教室
    signal sigApplyBClass(bool status);

    //开始上课信号
    signal startLesson();

    //学生分页权限信号
    signal sigApplyPageRole(bool status);

    //清屏信号
    signal sigClearScreen();

    //删除课件提醒信号
    signal sigTipCourseWare();

    //学生类型
    property  string  studentType: curriculumData.getCurrentUserType()

    //评价
    signal sigEvaluateContent(string contentText1 , string contentText2 ,string contentText3);

    //留在教室
    signal sigStayInclassroom();
    //退出教室
    signal sigExitRoomName();

    //评价之前发送退出教室信号
    signal sigFinishClass();

    //提交工单信号
    //signal sigCommitWork();

    //结束课程判断时间信号
    signal sigGetLessonTime();

    //同意结束课程
    signal sigAgreeEndLesson(int types);

    //试听课报告已生成 发送socket 通知其他人
    signal sigReportFinisheds();

    signal sigTeacherHandMic(var status);//老师交麦 1 交麦 0 取消交麦

    //设置用户名
    function setUserName(username){
        applyExitClass.userName = username;
        continueClassView.userName = username;
        startLessonView.userName = username;
        applyRole.userName = username;
        gotoClassroom.userName = username;
        applyEndLessonView.userName = username;
    }

    //设置留在教室窗口
    function setExitRoomName( types , cname){
        //hideTime.stop();
        hideTimeWidget();
        tipDropClassroom.visible = false;

        if(types == "A" )  {
            tipDropClassroomBstudentItem.exitName = "学生 " + cname  + " ";
            popupWidget.visible = true;
            tipDropClassroomBstudentItem.visible = true;
            return;
        }
        if(types == "B" )  {
            return;
        }
    }

    //结束课程当前上课时间
    function setCurrentTime(currentTime){
        tipCourseView.lessonCurrentTime = analysisTime(currentTime);
    }

    //结束课程弹窗
    function updateEndLesson( isDisplay, playTime){
        console.log("updateEndLesson(",analysisTime(playTime),playTime,isDisplay)
        hideTimeWidget();
        if(isDisplay){
            tipCourseView.lessonCurrentTime = analysisTime(playTime);
            var totalTimers = curriculumData.courseTimeTotalLength;
            tipCourseView.lessonTotalTime = analysisTime(totalTimers);
            tipCourseView.visible = true;
            popupWidget.visible = true;
            return;
        }else{
            if(currentListenRoleType == 1 && !hasFinishListenReport )
            {
                sigFinishClass();//结束课程退出教室命令
                if(currentIsAuditionLesson)
                {//试听课评价
                    assessView.visible = true;
                    popupWidget.visible = true;
                }else
                {//订单课评价
                    popupWidget.visible = true;
                    tipEvaluateWidgetItem.visible = true;
                    tipEvaluateWidgetItem.couldDirectExit = true;
                }
            }else
            {
                if(!currentIsAuditionLesson)
                {
                    sigFinishClass();
                    sigExitProject();
                }else
                {
                    popupWidget.visible = true;
                    ccExitRoomTips.visible = true;
                }
            }
            return;
        }
    }

    function analysisTime(currentLengthTime){
        var currentLengthTimeStr = "";
        var timelh = parseInt( currentLengthTime / 60 ) ;
        if(timelh > 9) {
            currentLengthTimeStr = timelh.toString() + ":";
        }else {
            currentLengthTimeStr = "0"+timelh.toString() + ":";
        }
        var timelm = Math.round( currentLengthTime % 60);
        if(timelm > 9) {
            return currentLengthTimeStr += timelm.toString() ;
        }else {
            return currentLengthTimeStr += "0"+timelm.toString() ;
        }
    }

    // 设置弹窗的界面
    function setPopupWidget(popups){
        console.log("setPopupWidgetsetPopupWidget",popups)
        if(popups == "createRoomFail") {
            hideTimeWidget();
            tipWaitIntoClassRoom.visible = false;
            kickOutView.tagNameContent = "加入音视频通道失败，请退出重试";
            kickOutView.visible = true;
            popupWidget.visible = true;
            return ;
        }
        if(kickOutView.visible == true){
            tipWaitIntoClassRoom.visible = false;
            return;
        }
        if(writeH5Report.visible)
        {
            return;
        }
        if(tipLoginError.visible == true){
            return;
        }
        if(tipEvaluateWidgetItem.visible == true )
        {
            return;
        }
        if(tipAutoChangeIpView.visible == true && popups !== "autoChangeIpSuccess" && popups !== "autoChangeIpFail")
        {
            console.log("popups ==",popups)
            if(popups == "1"){//如果是收到进入教室请求则隐藏连接窗口弹出开始上课窗口
                tipAutoChangeIpView.visible = false;
                tipWaitIntoClassRoom.visible = false;
                waitWidgetContent = "1";
                tipWaitIntoClassRoom.visible = true;
                popupWidget.visible = true;
                return;
            }else{
                tipWaitIntoClassRoom.visible = false;
                return;
            }
        }
        hideTime.stop();
        hideTimeWidget();
        console.log("setPopupWidget::popups:",popups)
        //        if(popups == "createWork"){
        //            createWorkView.visible = true;
        //            popupWidget.visible = true;
        //            return;
        //        }
        //连接服务器三次提醒
        if(popups =="autoConnectionNetwork"){
            tipWaitIntoClassRoom.visible = true;
            tipWaitIntoClassRoom.tagNameContent = "正在连接服务,请稍后...";
            popupWidget.visible = true;
            return;
        }
        if(popups == "joinMicrophone"){//上麦申请弹窗
            startLessonView.visible = false;
            tipAutoChangeIpView.visible = false;
            tipWaitIntoClassRoom.visible = false;
            agreeMicophoneView.visible = true;
            popupWidget.visible = true;
            return;
        }

        //显示对话框: "老师已退出, 学生停留在教室, 是否立即开始与学生沟通?"
        if(popups == "showStartClassPage"){
            continueClassView.visible = false;
            startLessonView.visible = false;
            startListenView.visible = true;
            popupWidget.visible = true;
            startLessonView.visible = false;
        }

        //隐藏对话框: "老师已退出, 学生停留在教室, 是否立即开始与学生沟通?"
        if(popups == "dispapperStartClassPage"){
            //console.log("=========dispapperStartClassPage=============");
            startListenView.visible = false;
            popupWidget.visible = false;
        }

        //ip自动切换
        if(popups == "showAutoChangeIpview"){
            tipAutoChangeIpView.visible = true;
            popupWidget.visible = true;
            console.log("=====showAutoChangeIpview========")
            return;
        }
        if(popups == "autoChangeIpSuccess") {
            hideTime.start();
            console.log("pup widget change success")
            return;
        }
        if(popups == "autoChangeIpFail"){
            kickOutView.visible = false;
            tipWaitIntoClassRoom.visible = false;
            tipAutoChangeIpView.visible = true;
            tipAutoChangeIpView.setAutoChangeIpFail();
            popupWidget.visible = true;
            console.log("====autoChangeIpFail======")
            return;
        }

        if(popups == "removerPage"){
            courseView.visible = true;
            popupWidget.visible = true;
            return;
        }
        //学生申请翻页权限
        if(popups == "8"){
            applyRole.visible = true;
            popupWidget.visible = true;
            return;
        }

        //B学生申请进入教室
        if(popups == "11"){
            tipAutoChangeIpView.visible = false;
            gotoClassroom.visible = true;
            popupWidget.visible = true;
            return;
        }
        //评价弹窗
        if(popups == "65" ) {
            isStudentEndLesson = true;
            sigFinishClass();
            if(currentListenRoleType == 1)
            {
                if(!currentIsAuditionLesson)
                {
                    popupWidget.visible = true;
                    tipEvaluateWidgetItem.couldDirectExit = true;
                    tipEvaluateWidgetItem.visible = true;
                    return;
                }else
                {
                    if(hasFinishListenReport)
                    {
                        sigExitProject();
                    }else
                    {
                        //显示 试听课评价
                        hideTimeWidget();
                        assessView.visible = true;
                        popupWidget.visible = true;
                    }
                }
            }else
            {
                sigExitProject();
            }
        }
        if(popups == "12"){
            popupWidget.visible = true;
            clearScreen.visible = true;
        }

        //申请退出教室
        if(popups == "10"){
            popupWidget.visible = true;
            applyExitClass.visible = true;
            return;
        }
        //继续上课
        if(popups == "4"){
            tipAutoChangeIpView.visible = false;
            tipWaitIntoClassRoom.visible = false;
            waitWidgetContent = "1";
            popupWidget.visible = true;
            continueClassView.visible = true;
            return;
        }
        //开始上课
        if(popups == "5" || popups == "3"){
            if(popups == "5"){
                startLessonView.currentTips = "开始上课后教室如有内容将被清空！";
            }else{
                startLessonView.currentTips = "当前课程可以接着之前内容继续进行";
            }
            popupWidget.visible = true;
            startLessonView.visible = true;
        }

        if(popups == "0") {
            tipWaitIntoClassRoom.visible = false;
            tipLoginError.visible = true;
            popupWidget.visible = true;
            return ;
        }
        if(popups == "1") {
            waitWidgetContent = "1";
            tipWaitIntoClassRoom.visible = true;
            popupWidget.visible = true;
            return;
        }
        if(popups == "2") {
            tipWaitIntoClassRoom.visible = false;
            popupWidget.visible = false;
            return;
        }
        //为b学生进入教室
        if(popups == "6") {
            tipWaitIntoClassRoom.visible = false;
            popupWidget.visible = false;
            return;
        }

        if(popups == "close" ) {
            tipWaitIntoClassRoom.visible = false;
            //writeH5Report.visible = false;
            popupWidget.visible = true;
            tipDropClassroom.visible = true;
            return;
        }

        if(popups == "63" ) {
            if(tipDropClassroom.visible == true || tipEvaluateWidgetItem.visible == true ) {
                return;
            }
            popupWidget.visible = true;
            tipClassOverWidgetItem.visible = true;
            //hideTime.start();
            return;
        }
        //允许进入
        if(popups == "66" ) {
            tipWaitIntoClassRoom.visible = false;
            popupWidget.visible = false;
        }
        //拒绝进入
        if(popups == "67" ) {
            popupWidget.sigCloseAllWidget();
        }
        //申请结束课程
        if(popups == "50"){
            applyEndLessonView.visible = true;
            popupWidget.visible = true;
            return;
        }
        //断开不再重连
        if(popups == "88"){
            kickOutView.tagNameContent = "当前账号在其他设备进入教室，您已被迫退出";
            kickOutView.visible = true;
            popupWidget.visible = true;
            return;
        }
        if(popups == "LoadLessonFail"){
            kickOutView.tagNameContent = "获取讲义失败，请您重新进入教室!";
            kickOutView.visible = true;
            popupWidget.visible = true;
            return;
        }
    }

    function visibleStartClassView(){
        continueClassView.visible = false;
        startLessonView.visible = false;
        if(mainView.teacherType == "L"){
            cloudMenu.disableButton = false;
            bottomToolbars.disabledButton = false;
            toobarWidget.disableButton = false;
            trailBoardBackground.isHandl = false;
            exercisePage.disabledButton = false;
            videoToolBackground.disabledButton = false;
        }
        if(!writeH5Report.visible)
        {
            popupWidget.visible = false;
            return 1;
        }
        return 2;
    }

    //隐藏界面
    function hideTimeWidget(){
        if(tipClassOverWidgetItem.visible == true) {
            popupWidget.sigCloseAllWidget();
        }
        ccJustHoldMicView.visible = false;
        askTeacherHandMicView.visible = false;
        ccExitRoomTips.visible = false;
        tipEvaluateWidgetItem.visible = false;
        tipDropClassroom.visible = false;
        tipDropClassroomBstudentItem.visible = false;
        tipClassOverWidgetItem.visible = false
        applyRole.visible = false;
        applyExitClass.visible = false;
        courseView.visible = false;
        gotoClassroom.visible = false;
        tipCourseView.visible = false;
        applyEndLessonView.visible = false;
        waitMicrophoneView.visible = false;
        applyMicView.visible = false;
        agreeMicophoneView.visible = false;
        startListenView.visible = false;
        writeH5Report.visible = false;
        kickOutView.visible = false;
    }

    function hideContinueClassView()
    {
        if(continueClassView.visible)
        {
            popupWidget.visible = false;
            continueClassView.visible = false;
        }
    }

    function hideTeaWaitHandMicView(handMic)
    {
        hideTimeWidget();
        if(handMic == 0)
        {
            showMessageTips("CC（协作CC、CR）已拒绝接麦");
        }else if(handMic == 1)
        {
            changeTeaTypeToL();
        }
        popupWidget.visible = true;
        writeH5Report.visible = true;
        writeH5Report.resetWebViewUrl("");
    }
    function showCCWhetherHoldMicView(handMic)
    {
        if(handMic == 0)
        {
            hideTimeWidget();
            ccJustHoldMicView.visible = false;
            popupWidget.visible = false;
        }else if(handMic == 1)
        {
            hideTimeWidget();
            ccJustHoldMicView.visible = true;
            popupWidget.visible = true;
        }
    }

    YMTipsExitClassroomView
    {
        id:ccExitRoomTips
        anchors.fill: parent
        visible: true
        z:5

        onCancelConfirm:
        {
            popupWidget.visible = false;
            hideTimeWidget();
        }

        onConfirmed:
        {
            //试听课学生不在线不能结束课程
            if( currentListenRoleType != 1 && currentIsAuditionLesson && !curriculumData.justStudentIsOnline())
            {
                showMessageTips(qsTr("结束课程失败，学生已离开教室"));
                popupWidget.visible = false;
                hideTimeWidget();
                return;
            }
            sigFinishClass();
            sigExitProject();
        }
    }

    YMAskTeacherHandMicView
    {
        id:askTeacherHandMicView
        anchors.fill: parent
        visible: false
        z:5

        //取消交麦
        onCancelConfirm:
        {
            hideTimeWidget();
            sigTeacherHandMic(0);
            writeH5Report.visible = true;
            writeH5Report.resetWebViewUrl("");
        }

        onWhetherHandMic:
        {
            if(handMic == 0)//不交麦
            {
                hideTimeWidget();
                writeH5Report.visible = true;
                writeH5Report.resetWebViewUrl("");
            }else if(handMic == 1)//交麦
            {
                sigTeacherHandMic(1);
            }

        }
    }

    YMCCJustHoldMicView
    {
        id:ccJustHoldMicView
        anchors.fill: parent
        visible: false
        z:5
        onCcWhetherHoldMic:
        {
            trailBoardBackground.ccHandMic(holdMic);
            popupWidget.visible = false;
            ccJustHoldMicView.visible = false;

            if(holdMic == 1) //同意上麦
            {

            }else if(holdMic == 0)//不同意上麦
            {

            }
        }

    }

    //继续上课页面
    TipContinueClass{
        id: continueClassView
        z: 5
        visible: false
        anchors.fill: parent
        onSigContinue: {
            mainView.currentIsAttend = false;
            mainView.teacherType = "T";
            trailBoardBackground.setTeacherType("T");
            bottomToolbars.disabledButton = true;
            toobarWidget.disableButton = true;
            videoToolBackground.disabledButton = true;
            trailBoardBackground.isHandl = true;
            joinMicrophoneView.visible = false;
            startLesson();
            continueClassView.visible = false;
            popupWidget.visible = false;
        }
    }

    //开始上课页面
    TipClassBegin{
        id: startLessonView
        z: 5
        visible: false
        anchors.fill: parent
        onSigStartLesson: {
            mainView.currentIsAttend = false;
            joinMicrophoneView.visible = false;
            mainView.teacherType = "T";
            trailBoardBackground.setTeacherType("T");
            bottomToolbars.disabledButton = true;
            toobarWidget.disableButton = true;
            videoToolBackground.disabledButton = true;
            trailBoardBackground.isHandl = true;
            startLesson();
            startLessonView.hideWindow();
            popupWidget.visible = false;
        }
    }

    //正在离开教室，稍后可以回来继续上课哦！
    TipClassOverWidgetItem{
        id:tipClassOverWidgetItem
        anchors.left: parent.left
        anchors.top: parent.top
        width: 300.0 * popupWidget.width / 1440
        height:  225.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipClassOverWidgetItem.width ) / 2
        anchors.topMargin: (popupWidget.height - tipClassOverWidgetItem.height ) / 2
        visible: false
        z:5
    }

    //退出不再重连
    TipKickOutView{
        id: kickOutView
        anchors.left: parent.left
        anchors.top: parent.top
        width: 300.0 * popupWidget.width / 1440
        height:  225.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - kickOutView.width ) / 2
        anchors.topMargin: (popupWidget.height - kickOutView.height ) / 2
        visible: false
        z: 6

        onSigCloseAllWidget: {
            sigExitProject();
        }
    }

    //自动切换IP画面
    TipAutoChageIpView{
        id:tipAutoChangeIpView
        anchors.left: parent.left
        anchors.top: parent.top
        width: 240.0 *  popupWidget.width / 1440
        height:  200.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipAutoChangeIpView.width ) / 2
        anchors.topMargin: (popupWidget.height - tipAutoChangeIpView.height ) / 2
        visible: false
        z: 5
        onSigCloseAllWidget: {
            popupWidget.sigCloseAllWidget();
        }
    }

    //学生申请结束课程
    TipApplyEndLessonView{
        id: applyEndLessonView
        anchors.left: parent.left
        anchors.top: parent.top
        width: 300.0 * popupWidget.width / 1440
        height:  225.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - applyEndLessonView.width ) / 2
        anchors.topMargin: (popupWidget.height - applyEndLessonView.height ) / 2
        visible: false
        z: 5
        onSigOk: {
            sigAgreeEndLesson(1);
            applyEndLessonView.visible = false;
            popupWidget.visible = false;
        }

        onSigRefuse: {
            applyEndLessonView.visible = false;
            popupWidget.visible = false;
            sigAgreeEndLesson(0);
        }
    }

    //结束课程未到时间提醒
    TipCourseTimeOutView{
        id: tipCourseView
        anchors.left: parent.left
        anchors.top: parent.top
        width: 360.0 * widthRates
        height: 343.0 * widthRates
        anchors.leftMargin: (popupWidget.width - tipCourseView.width ) / 2
        anchors.topMargin: (popupWidget.height - tipCourseView.height ) / 2
        visible: false
        z:5

        onVisibleChanged:
        {
            if(tipCourseView.visible && assessView.visible)
            {
               assessView.visible = false;
            }
        }

        onSigCancel: {
            tipCourseView.visible = false;
            popupWidget.visible = false;
        }
        onSigOk: {
            sigFinishClass();
            if(currentListenRoleType == 1 && !hasFinishListenReport)
            {
                if(currentIsAuditionLesson)
                {
                    //显示 试听课评价
                    hideTimeWidget();
                    assessView.visible = true;
                    popupWidget.visible = true;
                }else
                {
                    sigExitRoomName();
                    hideTimeWidget();
                    tipEvaluateWidgetItem.couldDirectExit = true;
                    tipEvaluateWidgetItem.visible = true;
                    popupWidget.visible = true;
                }

            }else
            {
                sigExitProject();
            }
        }
    }

    //课程暂时中断，请退出 学生 某某某某 退出教室 用于b学生
    TipDropClassroomBstudentItem{
        id:tipDropClassroomBstudentItem
        anchors.left: parent.left
        anchors.top: parent.top
        width: 300.0 *  popupWidget.width / 1440
        height:  200.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipDropClassroomBstudentItem.width ) / 2
        anchors.topMargin: (popupWidget.height - tipDropClassroomBstudentItem.height ) / 2
        visible: false
        z:5
        onSigExitRoom: {
            popupWidget.sigCloseAllWidget();
        }
        onSigStayInclassroom: {
            popupWidget.visible = false;
            popupWidget.sigStayInclassroom();
        }
    }
    //评价提醒窗
    TipAssessView{
        id: assessView
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: (popupWidget.width - assessView.width ) / 2
        anchors.topMargin: (popupWidget.height - assessView.height ) / 2
        visible: false
        z:5

        onSigOk: {
            tipEvaluateWidgetItem.visible = false;
            popupWidget.visible = false;
            sigExitProject();
        }
        onSigRefuse: {
            tipEvaluateWidgetItem.visible = true;
            popupWidget.visible = true;
        }

        onGoWriteReport:
        {
            //显示 试听课评价
            writeH5Report.visible = true;
            writeH5Report.couldDirectExit = true;
            writeH5Report.resetWebViewUrl("")
        }

    }

    //评价
    TipLessonAssessView{
        id:tipEvaluateWidgetItem
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: (popupWidget.width - tipEvaluateWidgetItem.width ) / 2
        anchors.topMargin: (popupWidget.height - tipEvaluateWidgetItem.height ) / 2
        visible: false
        z: 15

        onSigSendFinishClass:
        {
            sigFinishClass();
        }

        //关闭窗体
        onConfirmClose: {
            sigExitProject();
            //            tipEvaluateWidgetItem.visible = false;
            //            assessView.visible = true;
            //            popupWidget.visible = true
        }
        //提交评价并退出
        onContinueExit: {
            hasFinishListenReport = true;
            if(tipEvaluateWidgetItem.couldDirectExit == false)
            {
                tipEvaluateWidgetItem.visible = false;
                curriculumData.setCouldDirectExit(false);
            }else
            {
                curriculumData.setCouldDirectExit(true);
            }
            popupWidget.sigEvaluateContent(contentText1, contentText2, contentText3);
        }
    }

    TipShowH5ReportView
    {
        id:writeH5Report
        anchors.fill: parent
        z:10
        visible: false

        onSigPushReportLoadingStatus:
        {
            trailBoardBackground.pushReportMsgToServer(status,qsTr("系统错误"));
        }

        onSigReportFinished:
        {
            if(isStudentEndLesson)
            {
                sigExitProject();
            }

            sigReportFinisheds();
        }

        onConfirmClose: {
            sigExitProject();
            //            tipEvaluateWidgetItem.visible = false;
            //            assessView.visible = true;
            //            popupWidget.visible = true
        }
    }
    //主动退出教室课程结束
    TipDropClassroom{
        id:tipDropClassroom
        anchors.left: parent.left
        anchors.top: parent.top
        width: 270.0 *  popupWidget.width  / 1440 * 0.75
        height: (currentListenRoleType == 1 && !currentIsAttend) ? (currentIsAuditionLesson ? 348.0 *  popupWidget.height / 900 * 0.75 : 348.0 *  popupWidget.height / 900 * 0.75) :(294.0 *  popupWidget.height / 900 * 0.75)
        anchors.leftMargin: (popupWidget.width - tipDropClassroom.width ) / 2
        anchors.topMargin: (popupWidget.height - tipDropClassroom.height ) / 2
        visible: false
        z:5
        onSelectWidgetType: {
            console.log("===onSelectWidgetType======",types);
            // 1临时退出 2 老师结束课程退出  3 填写试听课报告 4 填写课堂报告 5老师退出旁听 6 学生 cr 退出旁听 7 cr结束课程

            if(types == 1) {//临时退出
                sigExitProject();
                return;
            }

            if(types == 2) {//老师结束课程退出

                if(subjectId == 0)//演示课直接结束课程
                {
                    sigFinishClass();
                    sigExitProject();
                    return;
                }

                sigGetLessonTime();
                return;
            }

            if(types == 7) {//cr结束课程
                sigGetLessonTime();
                return;
            }

            if(types == 3)//填写试听课报告
            {
                if(curriculumData.justCCIsOnline() && trailBoardBackground.getTeacherStatus() == "T")
                {
                    tipDropClassroom.visible = false;
                    askTeacherHandMicView.visible = true;
                }else
                {
                    writeH5Report.visible = true;
                    writeH5Report.resetWebViewUrl("");
                    //上报信息
                    trailBoardBackground.pushReportMsgToServer(1,"");
                }
                return;
            }
            if(types == 4) {//填写课堂报告
                popupWidget.visible = true;
                tipEvaluateWidgetItem.visible = true;
                tipEvaluateWidgetItem.couldDirectExit = false;
                return;
            }
            if(types == 5) {//老师退出旁听
                if(hasFinishListenReport)
                {
                    sigExitProject();
                }else
                {
                    if(currentIsAuditionLesson)
                    {
                        assessView.visible = true;
                        popupWidget.visible = true;
                    }else
                    {//订单课评价
                        popupWidget.visible = true;
                        tipEvaluateWidgetItem.visible = true;
                        tipEvaluateWidgetItem.couldDirectExit = true;
                    }
                }

                return;
            }
            if(types == 6) {//学生 cr 退出旁听
                sigExitProject();
                return;
            }

        }

        onCloseWidget: {
            hideTimeWidget();
            tipDropClassroom.visible = false;
            popupWidget.visible = false;
        }
    }

    //登录错误
    TipLoginError{
        id:tipLoginError
        anchors.left: parent.left
        anchors.top: parent.top
        width: 280.0 *  popupWidget.width / 1440
        height:  242.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipLoginError.width ) / 2
        anchors.topMargin: (popupWidget.height - tipLoginError.height ) / 2
        visible: false
        z:5
        onSigCloseAllWidget: {
            popupWidget.sigCloseAllWidget();
        }

    }

    //清屏提醒页面
    TipClearScreen{
        id: clearScreen
        z: 5
        visible: false
        anchors.fill: parent
        onSigOk: {
            sigClearScreen();
            clearScreen.visible = false;
            popupWidget.visible = false;
        }
        onSigRefuse: {
            clearScreen.visible = false;
            popupWidget.visible = false;
        }
    }
    //学生申请翻页权限页面
    TipApplyRole{
        id: applyRole
        z: 5
        visible:  false
        anchors.fill: parent
        onSigOk: {
            sigApplyPageRole(true);
            applyRole.visible = false;
            popupWidget.visible = false;
        }
        onSigRefuse: {
            sigApplyPageRole(false);
            applyRole.visible = false;
            popupWidget.visible = false;
        }
    }

    //学生申请离开教室页面
    TipApplyExitClass{
        id: applyExitClass
        z: 5
        visible: false
        anchors.fill: parent
        //同意离开教室
        onSigOk: {
            popupWidget.sigAgree();
            popupWidget.visible = false;
        }
        //拒绝离开
        onSigRefuse: {
            popupWidget.sigRefuse();
            popupWidget.visible = false;
        }
    }

    //B学生申请进入教室页面
    TipApplyGotoClassView{
        id: gotoClassroom
        z: 5
        visible: false
        anchors.fill: parent
        onSigRefuse: {
            popupWidget.sigApplyBClass(false);
            gotoClassroom.visible = false;
            popupWidget.visible = false;
        }

        onSigOk: {
            popupWidget.sigApplyBClass(true);
            gotoClassroom.visible = false;
            popupWidget.visible = false;
        }
    }

    //等待进入教室画面
    TipWaitIntoClassRoom{
        id:tipWaitIntoClassRoom
        anchors.left: parent.left
        anchors.top: parent.top
        width: 240.0 *  popupWidget.width / 1440
        height:  153.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipWaitIntoClassRoom.width ) / 2
        anchors.topMargin: (popupWidget.height - tipWaitIntoClassRoom.height ) / 2
        visible: true
        tagNameContent:waitWidgetContent == "0" ? "进入教室中…":(waitWidgetContent == "1" ? "正在同步上课记录...":"请求进入教室...")
        z: 5
        onSigCloseAllWidget: {
            popupWidget.sigCloseAllWidget();
        }
    }

    //删除课件提醒页面
    TipCourseWareView{
        id: courseView
        z: 5
        visible: false
        anchors.fill: parent
        onSigCancel: {
            courseView.visible = false;
            popupWidget.visible = false;
        }

        onSigOk: {
            courseView.visible = false;
            popupWidget.visible = false;
            sigTipCourseWare();
        }
    }


    Timer{
        id:hideTime
        interval: 3000
        repeat: false
        running: false
        onTriggered: {
            //            tipAutoChangeIpView.visible = false;
            //            popupWidget.visible = false;
            hideTimeWidget();
        }
    }

    //默认隐藏所有页面，否则会导致GPU达到100%
    Component.onCompleted: {
        hideTimeWidget();
    }

    //是否上麦提醒弹窗
    TipAgreeMicrophoneView{
        id: agreeMicophoneView
        z: 5
        anchors.centerIn: parent
        visible: false
        onSigMicrophoneCancenl: {
            agreeMicophoneView.visible = false;
            popupWidget.visible = false;
            joinMicrophoneView.visible = true;
        }

        onSigMicrophoneOk: {
            agreeMicophoneView.visible = false;
            waitMicrophoneView.tipsMessage = "正在等待老师同意...."
            waitMicrophoneView.buttonText = "";
            waitMicrophoneView.visible = true;
            popupWidget.visible = true;
            trailBoardBackground.applyMicrophoneRole();
        }
    }

    //申请上麦
    TipApplyMicrophoneView{
        id: applyMicView
        z: 5
        anchors.centerIn: parent
        visible: false
        onSigCancelMic: {
            applyMicView.visible = false;
            popupWidget.visible = false;
            trailBoardBackground.reposeMicrophone(0,"0");
        }

        onSigMicOk: {
            applyMicView.visible = false;
            confirmLessonView.visible = true;
        }
    }

    //当前是持麦者, 确认是否申请上麦
    TipConfirmLessonView{
        id: confirmLessonView
        z: 5
        visible: false
        anchors.centerIn: parent
        onSigCancelMic: {
            applyMicView.visible = true;
            confirmLessonView.visible = false;
            currentIsAttend = false;
        }

        onSigMicOk: {
            if(curriculumData.justUserIsOnline(applyMicView.applyUsersId))
            {
                changeTeaTypeToL();
            }else
            {
                popupWidget.visible = false;
                confirmLessonView.visible = false;
                currentIsAttend = false;
                showMessageTips(qsTr("上麦失败，老师已掉线"));
            }
        }
    }

    TipWaitMicrophoneView{
        id: waitMicrophoneView
        z: 5
        anchors.centerIn: parent
        visible: false
        onSigCancel: {
            waitMicrophoneView.visible = false;
            popupWidget.visible = false;
            joinMicrophoneView.visible = true;
        }
        onSigAutoVisible: {
            waitMicrophoneView.visible = false;
            popupWidget.visible = false;
        }
    }

    TipStartListenView{
        id: startListenView
        z:5
        anchors.centerIn: parent
        visible: false

        onSigTeacherRejoinRoom:
        {
            startListenView.visible = false;
            popupWidget.visible = false;
            showMessageTips("上麦失败，主麦在线");
        }

        onSigCloseClassroom: {
            trailBoardBackground.setExitProject();
        }
        onSigStartLesson: {
            startListenView.visible = false;
            popupWidget.visible = false;
            mainView.teacherType = "T";
            trailBoardBackground.setTeacherType("T");
            bottomToolbars.disabledButton = true;
            toobarWidget.disableButton = true;
            videoToolBackground.disabledButton = true;
            trailBoardBackground.isHandl = true;
            cloudMenu.disableButton = true;
            joinMicrophoneView.visible = false;
            startLesson();
        }
    }

    function waitMicrophoneShow(status){
        console.log("=====waitMicrophoneShow=======",status)
        if(status == 0){
            waitMicrophoneView.buttonText = "知道了";
            waitMicrophoneView.tipsMessage = "老师拒绝了您的上麦请求";
            toobarWidget.teacherEmpowerment = false;
        }else{
            waitMicrophoneView.buttonText = "好的（3）";
            waitMicrophoneView.tipsMessage = "上麦成功，请开始上课";
            waitMicrophoneView.runTime();
            toobarWidget.teacherEmpowerment = true;
        }
        waitMicrophoneView.visible = true;
        popupWidget.visible =  true;
    }

    function applyMicrophone(status,userId){
        continueClassView.visible = false;
        applyMicView.visible = true;
        applyMicView.applyUsersId = userId;
        popupWidget.visible = true;
    }

    function changeTeaTypeToL()
    {
        trailBoardBackground.setTeacherType("L");
        trailBoardBackground.reposeMicrophone(1,"0");
        confirmLessonView.visible = false;
        joinMicrophoneView.visible = true;
        popupWidget.visible = false;
        bottomToolbars.disabledButton = false;
        toobarWidget.disableButton = false;
        trailBoardBackground.isHandl = false;
        exercisePage.disabledButton = false;
        videoToolBackground.disabledButton = false;
        cloudMenu.disableButton = false;
        mainView.teacherType = "L";
        currentIsAttend = true;
        videoToolBackground.initChancel();
    }

}

