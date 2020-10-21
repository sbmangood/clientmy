import QtQuick 2.3
import QtQuick.Window 2.0
import YMAccountManagerAdapter 1.1
import YMHomeWorkManagerAdapter 1.0
import "Configuration.js" as Cfg
import QtQml 2.2
import QtGraphicalEffects 1.0
import PingThreadManagerAdapter 1.0

Window {
    id: windowView
    visible: false
    width: Screen.width * 0.8;
    height: Screen.width * 0.8  / (1.778);
    title: topTitle;
    color: "transparent"
    //缩放参数
    property double widthRate: Screen.width * 0.8 / 966.0;
    property double heightRate: widthRate / 1.5337;

    property bool enterClassRoom: true;//进入教室标记，只能进一次
    property bool exitRequest: false;//退出重新登录刷新数据
    property string topTitle: qsTr("教师端V1.0.7");
    property string userId: "";
    property string userName: "";
    property string password: "";
    property string realName: "";
    property var clickPos: [];//移动窗体坐标
    property bool windowClick: false;
    property bool loadingStatus: true;//登录时不显示加载状态属性

    property int interNetStatus: 0;    //网络状态：有线，无线
    property int interNetValue: 5; //网络ping值
    property int interNetGrade: 3;//网络好，差，无状态
    property int routingPing: 5;//路由ping值
    property int routingGrade: 3;//路由网络状态，好、差、无
    property int wifiDevice: 1;//wifi设备台数
    property int wifiGrade: 3;//wifi设备数优先级

    property string strStage: "api";//运行环境

    property int debugNetType: -1;
    property string debugStage: "";

    flags: Qt.Window | Qt.FramelessWindowHint

    signal refreshPage();//刷新页面信号
    signal checkInterNetSuccess();//网络检测完成
    signal sigListenTips(var status);//CC/CR进入旁听提醒信号

    YMHomeWorkManagerAdapter{
        id: homeWorkMgr
        onSigStageInfo: {
            debugNetType = netType;
            debugStage = stageInfo;
            strStage = stageInfo;
            if(strStage == "api")
            {
                strStage = "";
            }
        }

        onSigMessageBoxInfo:
        {
            console.log("=======main.qml========");
            windowView.showMessageBox(strMsg);
        }
    }

    //内部测试使用的"网络环境设置"对话框
    YMInterNetSetting{
        id: interNetSetting
        z: 2222
        width: 280 * heightRate
        height: 360 * heightRate
        anchors.centerIn: parent
        visible: false
    }

    //连续左击5次版本号, 提示的密码框
    YMStageInputPasswordView{
        id: stagePwdView
        z: 666
        visible: false
        width: 280 * heightRate
        height: 160 * heightRate
        anchors.centerIn: parent
    }

    PingThreadManagerAdapter{
        id: pingMgr

        onSigCurrentInternetStatus: {
            interNetStatus = internetStatus;
            menuSetingView.currentInternetStatus = internetStatus;
        }

        onSigCurrentNetworkStatus: {
            interNetValue = netValue;
            interNetGrade = netStatus;
            menuSetingView.interNetValue = netStatus;
            menuSetingView.pingValue = netValue == undefined ? 0 : netValue;
            menuSetingView.netStatus = netStatus;
            menuSetingView.updateNetworkImage();
        }

        //wifi连接的设备个数
        onSigWifiDeviceCount: {
            wifiDevice = count;
        }

        //当前路由的ping值与网络等级
        onSigCurrentRoutingValue: {
            routingPing = routingValue;
            routingGrade = netStatus;
            checkInterNetSuccess();
            console.log("=======routingValue========",routingValue,netStatus);
        }
    }

    YMAccountManagerAdapter{
        id: accountMgr
        onLoginSucceed: {
            userName = loginView.userName.trim();
            password = loginView.password.trim();
            var savepwd = loginView.savePassword == true ? 1 : 0;
            var autologin = loginView.autoLogin == true ? 1 : 0;
            accountMgr.saveUserInfo(userName,password,savepwd,autologin);
            enterClassRoom = true;
            loadingStatus = false;
            navigation.setActiveView(0,0);
            loginView.tips = "";
            exitRequest = true;
            showMainWindow();
        }
        onSigTokenFail:
        {
            navigation.clearModel = false;
            tipsControl.visible = false;
            exitRequest = false;
            loginView.loginConfram = true;
            loginView.clearPassword();
            showLoginWindow();
            loginView.tips = "登录已过期，请重新登录";
        }

        onLoginFailed: {
            loginView.tips = message;
            loginView.loginConfram = true;
            //loginView.password = "";
        }

        onTeacherInfoChanged:{
            realName = teacherInfo.realName;
            navigation.teacherName = teacherInfo.realName;
            navigation.headPicture = teacherInfo.headPicture;
            topTitle = "教师端V" + teacherInfo.appVersion
            userId = teacherInfo.userId;
            //console.log("=====userId====",userId);
            //console.log("=headPicture=",systemMenu.headPicture)
        }
        onSetDownValue:{
            softWareView.updateProgressBarValue(min,max)
            softWareView.visible = true;
        }

    }

    //控制整体背景色
    Rectangle{
        id: bgItem
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        radius:  12 * widthRate
        border.color: "#dfe2e8"
        border.width: 2
    }

    Image{
        id: bgImage
        visible: false
        anchors.fill: parent
        source: "qrc:/images/index_bg.png"
    }

    YMTipNetworkView{
        id: tipInterView
        width: 200 * widthRate
        height: 160 * heightRate
    }

    OpacityMask{
        width: parent.width - 2
        height: parent.height - 2
        anchors.left: bgItem.left
        anchors.leftMargin: 1
        anchors.top: bgItem.top
        anchors.topMargin: 1
        source: bgImage
        maskSource: bgItem
    }

    YMSoftWareView{
        id: softWareView
        anchors.fill: parent
        visible: false
        onUpdateChanged: {
            if(updateStatus){
                accountMgr.updateFirmware = updateStatus;
            }else{
                showLoginWindow();
                loginView.userName = userInfo[0];
                loginView.password = userInfo[2] == 1 ? userInfo[1] : ""
                loginView.savePassword = userInfo[2] == 1 ? true : false
                loginView.autoLogin = userInfo[3] == 1 ? true : false
            }
        }

        onClosed: {
            accountMgr.doUplaodLogFile();
            windowView.close();
            Qt.quit();
        }
    }

    YMLoginView {
        id: loginView
        visible: false
        anchors.fill: parent
        window: windowView
        onClosed: {
            accountMgr.doUplaodLogFile();
            Qt.quit();
        }
        onLoginMined: {
            windowView.visibility = Window.Minimized;
        }
    }

    YMProgressbarControl{
        id: progressbar
        visible: false
        anchors.fill: parent
    }

    YMMassgeTipsControl{
        id: massgeTips
        visible: false
    }

    YMJoinClassroomTipsView{
        id: joinClasstipsView
        z: 6
        anchors.fill: parent
        visible: false
        onSigConfirm: {
            sigListenTips(status);
        }
    }
    YMCCHasInRoomTipView
    {
        id: ccHasInRoomView
        z: 6
        anchors.fill: parent
        visible: false
    }
    Item{
        id: mainView
        anchors.fill: parent

        MouseArea{
            width: parent.width
            height:  86 * heightRate * 0.75//40 * heightRate
            visible: mainView.visible

            Rectangle
            {
                anchors.fill: parent
                color: "#FFFFFF"
                border.color: "#e0e0e0"
                border.width: 1

                Image{
                    id: loginItem
                    width: 549 * heightRate * 0.25
                    height: 174 * heightRate * 0.25
                    anchors.top: parent.top
                    anchors.topMargin: 14 * heightRate * 0.75
                    anchors.left: parent.left
                    anchors.leftMargin: 18 * heightRate * 0.75
                    smooth: true
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/JrImage/Logo@3x.png"
                }

            }

            //主程序, 右上角的"网络状态", "刷新", "设置"按钮
            YMMenuSetting{
                id: menuSetingView
                anchors.right: parent.right
                anchors.rightMargin: 174 * heightRate * 0.75
                anchors.verticalCenter: parent.verticalCenter
                onRefreshData: {
                    navigation.getActiveView();
                }
            }

            //主程序, 右上角的"最小化", "最大化", "关闭"按钮
            YMSystemMenuBar{
                id: systemMenu
                anchors.right: parent.right
                anchors.rightMargin:  25 * heightRate * 0.75
                anchors.verticalCenter: parent.verticalCenter
                window: windowView

                onClosed: {
                    tipsControl.appExit = true;
                    tipsControl.visible = true;
                    tipsControl.startFadeOut();
                }
            }
            onDoubleClicked: {
                windowClick = true;
                if(windowView.visibility == Window.Maximized){
                    windowView.visibility = Window.Windowed;
                }else if (windowView.visibility === Window.Windowed){
                    windowView.visibility = Window.Maximized;
                }
            }

            onPressed: {
                clickPos  = Qt.point(mouse.x,mouse.y)
            }

            onPositionChanged: {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                windowView.setX(windowView.x+delta.x)
                windowView.setY(windowView.y+delta.y)
            }

            onReleased: {
                if(!windowClick){
                    var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y);
                    var contentPoint = Qt.point(windowView.x + delta.x,windowView.y +delta.y)
                    windowView.setX(contentPoint.x);
                    windowView.setY(contentPoint.y);
                }
                windowClick = false;
            }
        }

        YMNavigationView{
            id:navigation
            anchors.fill: parent

        }
    }

    YMExitControl{
        id: exitButton
        visible: false
        onExitConfirm: {
            tipsControl.visible = true;
        }

    }

    YMLessonDescribe{
        id: lessonDescribe
        visible: false
        anchors.fill: parent
    }

    YMLessonInfo{
        id: lessonControl
        visible: false
        onLessonRefreshData: {
            enterClassRoom = true;
            navigation.getActiveView();
        }
    }

    YMLiveLessonView{
        id: liveLessonView
        visible: false
    }

    YMExitTipsControl{
        id: tipsControl
        tips: "您确认要退出吗?"
        visible: false
        anchors.fill: parent
        onCancelConfirm: {
            tipsControl.visible = false;
        }

        onConfirmed: {

            navigation.clearModel = false;
            tipsControl.visible = false;
            exitRequest = false;
            enterClassRoom = true;
            loginView.loginConfram = true;
            loginView.clearPassword();
            showLoginWindow();
        }
        onConfirmExit: {
            accountMgr.doUplaodLogFile();
            windowView.close();
            Qt.quit();
        }
    }


    YMMessageBox{
        id: messagebox
        visible: false
        anchors.fill: parent

        onConfirmed: {
            console.log("YMMessageBox onConfirmed");
            messagebox.visible = false;
        }
    }

    YMClassIntoView{
        id: classView
        anchors.fill: parent
        visible: false
    }

    //    YMDevicetesting{
    //        id: deviceSettingView
    //        z: 33
    //        anchors.fill: parent
    //        visible: false
    //    }

    YMCloseWorkOrderView
    {
        id:closeWorkOrderView
        visible: false
        onCloseWorkerOrderSuccess:
        {
            navigation.reSetWorkOrderView();
        }
    }
    YMCreatWorkOrderView
    {
        id:creatWorkOrderView
        visible: false
        onCreatWorkOrderFinished:
        {
            navigation.reSetWorkOrderView();
        }
    }
    YMReCommitWorkOrderView
    {
        id: reCommitWorkOrderView
        visible: false
        onReNewWorkOrdrDetailView:
        {
            navigation.resetWorkOrderDetail(isCommitSuccess);
        }
    }

    YMShowWorkOrderImageView
    {
        id:showWorkOrderImageView
        visible: false
    }

    Component.onCompleted: {
        windowView.visible = true
        var isUpdate = versionInfo;
        topTitle = "教师端V" + versionSoftWare;
        softWareView.title = topTitle
        softWareView.isUpdate = versionValue == 0 ? false : true;
        //console.log("softWareView.isUpdate",softWareView.isUpdate,versionValue)
        addNavigation();
        homeWorkMgr.getCurrentStage();
        if(isUpdate){
            showUpdateSoftWare();
            return;
        }else{
            showLoginWindow();

            //如果userInfo是空的话, 从 userInfo[0] 取值, qml会抱错
            if(userInfo[0] == undefined || userInfo == null)
            {
                return;
            }
            loginView.userName = userInfo[0];
            loginView.password = userInfo[2] == 1 ? userInfo[1] : ""
            loginView.savePassword = userInfo[2] == 1 ? true : false
            loginView.autoLogin = userInfo[3] == 1 ? true : false
        }
    }

    function showMessageBox(strMsg){
        messagebox.tips = strMsg;
        classView.visible = false;  //隐藏"正在进入教室中..."的窗口
        messagebox.visible = true;  //显示: 服务器返回错误信息的窗口
    }

    function showUpdateSoftWare(){
        softWareView.visible = true;
        windowView.width = 430 * widthRate;
        windowView.height = 440 * heightRate;
        windowView.setX((Screen.width - windowView.width) * 0.5);
        windowView.setY((Screen.height - windowView.height) * 0.5);
        mainView.visible = false;
    }

    function showLoginWindow(){
        softWareView.visible = false;
        loginView.visible = true;
        loginView.startLoginAnimation();
        windowView.width = Screen.width /1366 * 780;
        windowView.height = Screen.width / 1366 * 500;
        windowView.setX((Screen.width - windowView.width)* 0.5);
        windowView.setY((Screen.height - windowView.height) * 0.5);
        mainView.visible = false;
    }

    function showMainWindow(){
        loginView.visible = false;
        softWareView.visible = false;
        windowView.width = 1439 * heightRate * 0.75;
        windowView.height = 1269 * heightRate * 0.75;
        windowView.setX((Screen.width - windowView.width) * 0.5);
        windowView.setY((Screen.height - windowView.height) * 0.5);
        mainView.visible = true;
        //navigation.setActiveView(0,0);//测试用
    }

    function addNavigation(){
        navigation.clearModel = true;
        navigation.addView("我的课表",
                           ":/../JRHomePage/YMStudentCoachView.qml",
                           "qrc:/images/btn_kechengbiao@2x.png",
                           "qrc:/images/btn_kechengbiao_sed@2x.png");



    }
}

