import QtQuick 2.5
import CurriculumData  1.0


MouseArea {
    id:popupWidget

    Rectangle{
        anchors.fill: parent
        color: Qt.rgba(0.5,0.5,0.5,0.6)
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
        //tipWaitIntoClassRoom.visible = false;
        tipDropClassroom.visible = false;
        //console.log("==setExitRoomName==",types,cname,studentType);

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
        hideTimeWidget();
        if(isDisplay){
            tipCourseView.lessonCurrentTime = analysisTime(playTime);
            var totalTimers = curriculumData.courseTimeTotalLength;
            tipCourseView.lessonTotalTime = analysisTime(totalTimers);
            tipCourseView.visible = true;
            popupWidget.visible = true;
            return;
        }else{
            sigFinishClass();
            popupWidget.visible = true;
            tipEvaluateWidgetItem.visible = true;
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
        //console.log("setPopupWidgetsetPopupWidget",popups)
        if(popups == "createRoomFail") {
            hideTimeWidget();
            kickOutView.tagNameContent = "加入音视频通道失败，请退出重试";
            kickOutView.visible = true;
            popupWidget.visible = true;
            return ;
        }
        if(tipLoginError.visible == true){
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
            tipWaitIntoClassRoom.tagNameContent = qsTr("正在连接服务,请稍后...");
            return;
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
            gotoClassroom.visible = true;
            popupWidget.visible = true;
            return;
        }
        //评价弹窗
        if(popups == "65" ) {
            sigFinishClass();
            popupWidget.visible = true;
            tipEvaluateWidgetItem.visible = true;
            return;
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
            popupWidget.visible = true;
            continueClassView.showWindow();
            return;
        }
       //开始上课
        if(popups == "5" || popups == "3"){
            if(popups == "5"){
                startLessonView.currentTips = "注:当前教室内如有操作将被清空";
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

    //隐藏界面
    function hideTimeWidget(){
        if(tipClassOverWidgetItem.visible == true) {
            popupWidget.sigCloseAllWidget();
        }
        tipEvaluateWidgetItem.visible = false;
        tipDropClassroom.visible = false;
        tipDropClassroomBstudentItem.visible = false;
        tipClassOverWidgetItem.visible = false
        applyRole.visible = false;
        startLessonView.visible = false;
        applyExitClass.visible = false;
        continueClassView.visible = false;
        courseView.visible = false;
        gotoClassroom.visible = false;
        //popupWidget.visible = false;
        tipCourseView.visible = false;
        applyEndLessonView.visible = false;
        kickOutView.visible = false;
        //createWorkView.visible = false;
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
            sigAgreeEndLesson(2);
            applyEndLessonView.visible = false;
            popupWidget.visible = false;
        }

        onSigRefuse: {
            applyEndLessonView.visible = false;
            popupWidget.visible = false;
            sigAgreeEndLesson(3);
        }
    }

    //结束课程未到时间提醒
    TipCourseTimeOutView{
        id: tipCourseView
        anchors.left: parent.left
        anchors.top: parent.top
        width: 300.0 * popupWidget.width / 1440
        height:  225.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipCourseView.width ) / 2
        anchors.topMargin: (popupWidget.height - tipCourseView.height ) / 2
        visible: false
        z:5
        onSigCancel: {
            tipCourseView.visible = false;
            popupWidget.visible = false;
        }
        onSigOk: {
            sigExitRoomName();
            sigFinishClass();
            hideTimeWidget();
            tipEvaluateWidgetItem.visible = true;
            popupWidget.visible = true;
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
    }

    //评价
    TipLessonAssessView{
        id:tipEvaluateWidgetItem
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: (popupWidget.width - tipEvaluateWidgetItem.width ) / 2
        anchors.topMargin: (popupWidget.height - tipEvaluateWidgetItem.height ) / 2
        visible: false
        z: 5

        //关闭窗体
        onConfirmClose: {
            sigExitProject();
//            tipEvaluateWidgetItem.visible = false;
//            assessView.visible = true;
//            popupWidget.visible = true
        }
        //提交评价并退出
        onContinueExit: {
            popupWidget.sigEvaluateContent(contentText1, contentText2, contentText3);
        }
    }

    //主动退出教室课程结束
    TipDropClassroom{
        id:tipDropClassroom
        anchors.left: parent.left
        anchors.top: parent.top
        width: 240.0 *  popupWidget.width  / 1440
        height:  224.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipDropClassroom.width ) / 2
        anchors.topMargin: (popupWidget.height - tipDropClassroom.height ) / 2
        visible: false
        z:5
        onSelectWidgetType: {
            console.log("===onSelectWidgetType======",types);
            if(types == 1) {//临时退出
                popupWidget.selectWidgetType(types);
                sigExitProject();
            }
            if(types == 2) {//结束课程退出
                sigGetLessonTime();
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

    //继续上课页面
    TipContinueClass{
        id: continueClassView
        z: 5
        visible: false
        anchors.fill: parent
        onSigContinue: {
            startLesson();
            continueClassView.hideWindow();
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
            startLesson();
            startLessonView.hideWindow();
            popupWidget.visible = false;
        }
    }

//    //创建工单
//    TipCreatWorkOrderView{
//        id: createWorkView
//        z: 5
//        anchors.fill: parent
//        visible: false
//        onCloseChanged: {
//            createWorkView.visible = false;
//            popupWidget.visible = false;
//        }

//        onCreatWorkOrderFinished: {
//            sigCommitWork();
//        }
//    }

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
        z:5
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
        onTriggered: {            
//            tipAutoChangeIpView.visible = false;
//            popupWidget.visible = false;
            hideTimeWidget();
        }
    }

    Component.onCompleted: {
         hideTimeWidget();
    }

    CurriculumData{
        id:curriculumData
    }

}

