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
    height: Screen.width * 0.65;
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
    property bool isPublicText: true;//拓课云，自研切换 false:拓课云

    property int interNetStatus: 0;    //网络状态：有线，无线
    property int interNetValue: 5; //网络ping值
    property int interNetGrade: 3;//网络好，差，无状态
    property int routingPing: 5;//路由ping值
    property int routingGrade: 3;//路由网络状态，好、差、无
    property int wifiDevice: 1;//wifi设备台数
    property int wifiGrade: 3;//wifi设备数优先级
    property bool isMiniClassroom: false;//小班课是否在教室内
    property int currentMiniClassIndex: 0;//小班课教室打开索引

    property int debugNetType: -1;
    property string debugStage: "";
    property var currentCourseTableDate: [];//当前课程表日期

    flags: Qt.Window | Qt.FramelessWindowHint

    signal refreshPage();//刷新页面信号
    signal checkInterNetSuccess();//网络检测完成
    signal sigVisiblePlay();//隐藏录播页面信号

    YMHomeWorkManagerAdapter{
        id: homeWorkMgr
        onSigStageInfo: {
            debugNetType = netType;
            debugStage = stageInfo;
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
            systemMenu.currentInternetStatus = internetStatus;
        }

        onSigCurrentNetworkStatus: {
            interNetValue = netValue;
            interNetGrade = netStatus;
            systemMenu.interNetValue = netStatus;
            systemMenu.pingValue = netValue == undefined ? 0 : netValue;
            systemMenu.netStatus = netStatus;
            systemMenu.updateNetworkImage();
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
            console.log("===loginSuccess==")
            userName = loginView.userName;
            password = loginView.password;
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
            loginView.password = "";
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

    //拓课云的小班课的web engine view, 只在小班课一期的时候使用, 二期不使用了
    YMTalkCloudClassRoom{
        id: talkCloudClassroom
        z: 6
        width: parent.width - Cfg.NAV_LINE_HEIGHT * widthRate - 20
        height: parent.height -Cfg.TB_HEIGHT * heightRate - 20
        anchors.top: parent.top
        anchors.topMargin: Cfg.TB_HEIGHT * heightRate
        anchors.left: parent.left
        anchors.leftMargin: Cfg.NAV_LINE_HEIGHT * widthRate
        visible: false
        onSigReback: {
            exitClassroomView.visible = true;
        }
    }

    YMTipsExitClassroomView{
        id: exitClassroomView
        z: 8
        anchors.fill: parent
        visible: false
        onCancelConfirm: {
            exitClassroomView.visible = false;
        }
        onConfirmed: {
            exitClassroomView.visible = false;
            talkCloudClassroom.reBack();
            if(isMiniClassroom){
                isMiniClassroom = false;
                navigation.setActiveView(currentMiniClassIndex,0);
            }
        }
    }

    Item{
        id: mainView
        anchors.fill: parent

        Rectangle{
            width: 80 * heightRate
            height: 32 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: Cfg.NAV_LINE_HEIGHT * widthRate
            anchors.top: parent.top
            anchors.topMargin: 20 * heightRate
            radius: 6 * heightRate
            color: "#ff5500"
            z: 8
            visible: false//isStageEnvironment
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    isPublicText  = !isPublicText;
                }
            }

            Text {
                font.pixelSize: 14 * heightRate
                font.family: Cfg.DEFAULT_FONT
                color: "#ffffff"
                text: isPublicText ? "自研教室" : "拓课云"
                anchors.centerIn: parent
            }
        }

        MouseArea{
            width: parent.width
            height: Cfg.TB_HEIGHT * heightRate

            YMSystemMenuBar{
                id: systemMenu
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                window: windowView
                onClosed: {
                    tipsControl.exitSystem = true;
                    tipsControl.visible = true;
                }
                onRefreshData: {
                    navigation.getActiveView();
                    refreshPage();
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
            onShowCloseOrderView:
            {
                closeWorkOrderView.visible = true;
                closeWorkOrderView.showCloseWorkOrderView(id);
            }
            onSigExitMiniClass: {
                exitClassroomView.visible = true;
                currentMiniClassIndex = index;
            }
        }
    }

    YMExitControl{
        id: exitButton
        visible: false
        z: 7
        onExitConfirm: {
            if(isMiniClassroom){
                exitClassroomView.visible = true;
                return;
            }
            tipsControl.visible = true;
        }
        onShowDeviceTestWidget:
        {
            deviceSettingView.visible = true;
        }
        onShowWorkOrderView:
        {
            navigation.showWorkOrderView();
        }
    }

    YMLessonDescribe{
        id: lessonDescribe
        visible: false
        anchors.fill: parent
    }

    YMLessonInfo{
        id: lessonControl
        z: 8
        visible: false
        onLessonRefreshData: {
            enterClassRoom = true;
            navigation.getActiveView();
        }
    }

    YMMiniClassPlayerDirectory{
        id: playerDirectory
        z: 8
        visible: false
        anchors.fill: parent
        onSigSetVisible: {
            sigVisiblePlay();
        }
    }

    YMLiveLessonView{
        id: liveLessonView
        visible: false
    }

    YMExitTipsControl{
        id: tipsControl
        z:7
        tips: "确认退出吗？"
        visible: false
        anchors.fill: parent
        onCancelConfirm: {
            tipsControl.visible = false;
        }

        onAppExited: {
            accountMgr.doUplaodLogFile();
            Qt.quit();
        }

        onConfirmed: {
            navigation.clearModel = false;
            tipsControl.visible = false;
            exitRequest = false;
            loginView.loginConfram = true;
            loginView.clearPassword();
            showLoginWindow();

        }
    }

    YMClassIntoView{
        id: classView
        anchors.fill: parent
        visible: false
    }

    YMDevicetesting{
        id: deviceSettingView
        z: 33
        anchors.fill: parent
        visible: false
    }

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
        mainView.visible = false;
        loginView.visible = true;
        loginView.startLoginAnimation();
        windowView.width = Screen.width /1366 * 780;
        windowView.height = Screen.width / 1366 * 460;
        windowView.setX((Screen.width - windowView.width)* 0.5);
        windowView.setY((Screen.height - windowView.height) * 0.5);
    }

    function showMainWindow(){
        loginView.visible = false;
        softWareView.visible = false;
        windowView.width =Screen.width*0.8;
        windowView.height = Screen.width*0.8/(1.778);
        windowView.setX((Screen.width - windowView.width) * 0.5);
        windowView.setY((Screen.height - windowView.height) * 0.5);
        mainView.visible = true;
    }

    function addNavigation(){
        navigation.clearModel = true;
//        navigation.addView("课程表",
//                           "qrc:/ymlesson/lessonTable/YMLessonTable.qml",
//                           "qrc:/images/btn_kechengbiao@2x.png",
//                           "qrc:/images/btn_kechengbiao_sed@2x.png");
//        navigation.addView("课程列表",
//                           "qrc:/ymlesson/lessonListTable/YMLessonListTable.qml",
//                           "qrc:/images/btn_allcourse@3x.png",
//                           "qrc:/images/btn_allcourse_sed@3x.png");

        navigation.addView("课程表",
                           "qrc:/ymtalkcloud/YMTalkCloudLessonTableView.qml",
                           "qrc:/images/btn_kechengbiao@2x.png",
                           "qrc:/images/btn_kechengbiao_sed@2x.png");
        navigation.addView("我的课程",
                           "qrc:/ymtalkcloud/YMLessonTalkCloudView.qml",
                           "qrc:/talkcloudImage/xbkth_btn_mine@2x.png",
                           "qrc:/talkcloudImage/xbkth_btn_mine_sed@2x.png");

        navigation.addView("旁听教室",
                           "qrc:/attendclassroom/YMAttendClassroom.qml",
                           "qrc:/talkcloudImage/xb_th_btn_pt@2x.png",
                           "qrc:/talkcloudImage/xb_th_btn_pt_sed@2x.png");

//        navigation.addView("溢米教研",
//                           "qrc:/ymresearch/YMResearchView.qml",
//                           "qrc:/images/th_btn_yimijiaoyan@2x.png",
//                           "qrc:/images/th_btn_yimijiaoyan_sed@2x.png")

        //        navigation.addView(
        //                    "我的工单",
        //                    "qrc:/workorder/YMWorkOrder.qml",
        //                    "qrc:/images/btn_allcourse_sed@3x.png",
        //                    "qrc:/images/btn_allcourse_sed@3x.png"
        //                    );

    }
}

