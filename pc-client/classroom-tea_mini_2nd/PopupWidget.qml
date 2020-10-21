import QtQuick 2.5

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
        startLessonView.userName = username;
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

        //连接服务器三次提醒
        if(popups =="autoConnectionNetwork"){
            tipWaitIntoClassRoom.visible = true;
            tipWaitIntoClassRoom.tagNameContent = "正在连接服务,请稍后...";
            popupWidget.visible = true;
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
            tipWaitIntoClassRoom.visible = false;
            popupWidget.visible = false;
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

        if(popups == "12"){
            popupWidget.visible = true;
            clearScreen.visible = true;
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
                startLessonView.currentTips = "注:当前教室内如有操作将被清空";
            }else{
                startLessonView.currentTips = "当前课程可以接着之前内容继续进行";
            }

            startLessonView.visible = true;
            popupWidget.visible = true;
            return;
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

        if(popups == "close" ) {
            tipWaitIntoClassRoom.visible = false;
            popupWidget.visible = true;
            exitroomView.visible = true;
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
        popupWidget.visible = false;
        courseView.visible = false;
    }

    //关闭下课休息页面
    YMExitroomView{
        id: exitroomView
        z: 5
        anchors.fill: parent
        visible: false
        onSigExitRoom: {
            sigExitProject();
        }
        onSigFinishLesson: {
            sigFinishClass();
        }
        onSigClose: {
            exitroomView.visible = false;
            popupWidget.visible = false;
        }
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
            Qt.quit();
            //sigExitProject();
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
        z: 14
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
            showLessonView.visible = false;
        }
        onSigCancel: {
            showLessonView.visible = true;
            continueClassView.hideWindow();
            popupWidget.visible = false;
            sigExitProject();
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
        onSigCancel: {
            showLessonView.visible = true;
            startLessonView.hideWindow();
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
        visible: false
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
        onTriggered: {
            hideTimeWidget();
        }
    }

    //默认隐藏所有页面，否则会导致GPU达到100%
    Component.onCompleted: {
        hideTimeWidget();
    }
}

