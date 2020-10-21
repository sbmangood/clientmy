import QtQuick 2.5
import QtQuick.Window 2.0
import YMAccountManagerAdapter 1.0
import "Configuration.js" as Cfg
import QtGraphicalEffects 1.0
import PingThreadManagerAdapter 1.0
import "./miniClass" //因为: YMMiniClassList.qml, 在miniClass目录下面

Window {
    id: windowView
    visible: false
    width: Screen.width * 0.8;
    height: Screen.width * 0.8 / (1.778);
    title:"一米辅导"+topTitle;
    color: "transparent"

    property string strStage: "api";//运行环境

    property double widthRate: Screen.width * 0.8 / 966.0;
    property double heightRate:widthRate/1.5337;
    property string topTitle: qsTr("学生端V");
    property string userId: "";
    property string token: "";
    property string nickName: "";
    property string headPicture: "";
    property string mobileNo: "";
    property string userName: "";
    property bool isFirstUsing:false;//用于判断是不是首次使用软件
    property bool isStudentUser:true;//用于判断当前用户是学生还是家长
    property bool enterClassRoom: true;// 用于判断是否可以重复进入教室
    property bool requstStatus: false;//页面跳转状态
    property var clickPos: [];
    property bool windowClick: false;
    property bool isPlatform: true;//判定拓课云还是自研属性 false:拓课云 true:自研

    property bool isParentRemindHadShowed: false;//用于判断家长切换角色界面是否被显示过
    property bool exitRequest: false;//退出再登录进行刷新标记
    property bool isAskForLeaveViewHasBeShowed: false;//用于判断首次请假的时候 请假提醒页面是否被显示过

    property int interNetStatus: 0;    //网络状态：有线，无线
    property int interNetValue: 5; //网络ping值
    property int interNetGrade: 3;//网络好，差，无状态
    property int routingPing: 5;//路由ping值
    property int routingGrade: 3;//路由网络状态，好、差、无
    property int wifiDevice: 1;//wifi设备台数
    property int wifiGrade: 3;//wifi设备数优先级
    property bool isMiniClassroom: false;//小班课是否在教室内
    property int currentMiniClassIndex: 3;//小班课教室打开索引

    property int debugNetType: -1;
    property string debugStage: "";

    flags: Qt.Window | Qt.FramelessWindowHint


    //传参信号
    signal transferPage(var index,var subIndex);
    signal checkInterNetSuccess();//网络检测完成
    signal sigMiniClassReback();//小班课教室返回

    onTransferPage: {
        navigation.pageTransferParm(index,subIndex);
    }
    onWindowStateChanged:
    {
        if(windowState == 2)
        {
            windowView.width = Screen.width;
            windowView.height = Screen.height;
            mainView.visible = true;
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

        onSigUpdateStage:
        {
            accountMgr.updateStage(stageData ,stageArray);
        }
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

    YMTipsExitClassroomView{
        id: tipsExitClassroomView
        z: 6666
        visible: false
        anchors.fill: parent
        onCancelConfirm: {
            tipsExitClassroomView.visible = false;
        }

        onConfirmed: {
            tipsExitClassroomView.visible = false;
            sigMiniClassReback();
            if(isMiniClassroom){
                isMiniClassroom = false;
                navigation.setActiveView(currentMiniClassIndex,0);
            }
        }
    }

    YMMassgeTipsControl{
        id: massgeTips
        visible: false
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
        }
    }

    YMAccountManagerAdapter{
        id: accountMgr
        onLoginSucceed: {
            var savepwd = loginView.savePassword == true ? 1 : 0;
            var autologin = loginView.autoLogin == true ? 1 : 0;
            var stu = isStudentUser == true ? 1 : 0;
            var isps = isParentRemindHadShowed == true ? 1 : 0;
            var isaskflv = isAskForLeaveViewHasBeShowed== true ? 1 :0;
            userName = loginView.userName;
            accountMgr.saveUserInfo(loginView.userName,loginView.password,savepwd,autologin,stu,isps,isaskflv);
            console.log("isFirstUsing:",isFirstUsing)

            if(isFirstUsing) {
                exitRequest = true;
                loginView.showSelectParentOrStudentView();
            }else {
                navigation.setActiveView(0,0);
                showMainWindow();
                exitRequest = true;
            }

            loginView.resetPasswordView();
        }
        onSigTokenFail: {
            loginView.tips = "登录已过期,请重新登录!"
            navigation.messageCount = 0;
            navigation.clearModel = false;
            tipsControl.visible = false;
            exitRequest = false;
            enterClassRoom = true;
            loginView.clearPassword();
            showLoginWindow();
        }

        onLoginFailed: {
            loginView.tips = message;
        }

        onTeacherInfoChanged:{
            var teacherName;
            if(teacherInfo.nickName != ""){
                teacherName = teacherInfo.nickName;
            }else{
                teacherName = teacherInfo.realName
            }
            //添加判断如果是家长身份加入 家长两个字
            navigation.teacherName = teacherName ;
            navigation.headPicture = teacherInfo.headPicture;
            topTitle =  "学生端V"+ teacherInfo.appVersion;
            userId = teacherInfo.userId;
            token = teacherInfo.token;
            nickName = teacherName;
            mobileNo = teacherInfo.mobileNo;
            headPicture = teacherInfo.headPicture;
        }
        onLinkManInfo:{
            //console.log("==linkManData==",JSON.stringify(linkManData));
            navigation.linkManData = linkManData;
            personalCoachView.linkDataInfo = linkManData;
        }
        onUpdatePasswordChanged:{
            navigation.clearModel = false;
            tipsControl.visible = false;
            showLoginWindow();
            loginView.clearPassword();

        }
        onSetDownValue:{
            softwareView.updateProgressBarValue(min,max)
            softwareView.visible = true;
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

    //右上角, 提示: "当前网络状态良好"的Tool Tip 小窗口
    YMTipNetworkView{
        id: tipInterView
        width: 200 * widthRate
        height: 160 * heightRate
    }

    Image{
        id: bgImage
        visible: false
        anchors.fill: parent
        source: "qrc:/images/index_bg.png"
    }

    OpacityMask{
        id: opacityMask
        width: parent.width - 2
        height: parent.height - 2
        anchors.left: bgItem.left
        anchors.leftMargin: 1
        anchors.top: bgItem.top
        anchors.topMargin: 1
        source: bgImage
        maskSource: bgItem
    }

    //    YMDevicetesting{
    //        id: deviceSettingView
    //        z: 33
    //        anchors.fill: parent
    //        visible: false
    //    }

    YMLoginView{
        id: loginView
        anchors.fill: parent
        window: windowView
        onConfirmClosed: {
            //accountMgr.doUplaodLogFile();
            Qt.quit();
        }
        onLoginMined: {
            windowView.visibility = Window.Minimized;
        }
        onIdentificationed:   {
            isStudentUser = isStudent;
            showMainWindow();
            navigation.setActiveView(0,0);
        }

        onSigLoginSuccess:
        {
            console.log("onSigLoginSuccess at main: ",loginBackData)
            navigation.teacherName = accountMgr.getLoginData(loginBackData);
            navigation.setActiveView(0,0);
            showMainWindow();
        }

    }

    YMUpdatePasswordControl{
        id: updatePwdView
        visible: false
        anchors.fill: parent
    }

    YMProgressbarControl{
        id: progressbar
        visible: false
        anchors.fill: parent
    }

    YMSoftWareView{
        id: softwareView
        anchors.fill: parent
        visible: false
        onAppClosed: {
            accountMgr.doUplaodLogFile();
            windowView.close();
            Qt.quit();

        }
        onUpdateChanged: {
            accountMgr.updateFirmware(updateStatus);
            if(!updateStatus)
            {
                addNavigation();
                showLoginWindow();
                if(userInfo[0] == undefined || userInfo == null){
                    isFirstUsing=true;
                    isParentRemindHadShowed = false;
                    isAskForLeaveViewHasBeShowed = false;
                    return;
                }
                loginView.userName = userInfo[0];
                loginView.password = userInfo[2] == 1 ? userInfo[1] : "";
                loginView.savePassword = userInfo[2] == 1 ? true : false;
                loginView.autoLogin = userInfo[3] == 1 ? true : false;
                loginView.version = version.version;
                isStudentUser=userInfo[4]==1 ? true : false//用户判断 1 为学生  0为老师
                isParentRemindHadShowed=userInfo[5]==1 ? true :false;
                isAskForLeaveViewHasBeShowed = userInfo[6] == 1 ? true : false;
            }
        }
    }

    YMLoadingStatuesView{
        id: lodingView
        z:666
        anchors.fill: parent
        visible: false
    }

    YMMessageBox{
        id: messagebox
        z:6
        visible: false
        anchors.fill: parent

        onConfirmed: {
            console.log("YMMessageBox onConfirmed");
            messagebox.visible = false;
        }
    }


    YMClassIntoView{
        id: classView
        z: 9999
        visible: false
        anchors.fill: parent
    }

    Item{
        id: mainView
        anchors.fill: parent

        //自研、拓课云切换按钮
        Rectangle{
            z: 8
            width: 80 * heightRate
            height: 32 * heightRate
            radius: 6 * heightRate
            color: "#ff5500"
            anchors.top: parent.top
            anchors.topMargin: 20 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: Cfg.NAV_LINE_HEIGHT * widthRate
            visible: false//isStageEnvironment

            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    isPlatform = !isPlatform;
                }
            }

            Text {
                color: "#ffffff"
                anchors.centerIn: parent
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: isPlatform ? "自研教室" : "拓课云"
            }
        }

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
                //                Rectangle
                //                {
                //                    width: parent.width
                //                    height: 1
                //                    anchors.bottom: parent.bottom
                //                    color: "#FFFFFF"
                //                }

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
            visible: mainView.visible
            width: parent.width
            height:parent.height

            onSigExitMiniClass: {
                tipsExitClassroomView.visible = true;
                currentMiniClassIndex = index;
            }
        }
    }

    YMPersonalCoachView{
        id: personalCoachView
        anchors.fill: parent
        visible: false
    }

    //点击右上角"设置"按钮以后, 弹出来的菜单
    YMExitControl{
        id: exitButton
        visible: false
        onExitConfirm: {
            tipsControl.visible = true;
            tipsControl.startFadeOut();
        }
        onUpdatePwd: {
            updatePwdView.keywords =  loginView.password;
            updatePwdView.visible = true;
        }
        onDeviceDisplayer: {
            //deviceSettingView.visible = true;
        }
        onShowInformation: {
            personalCoachView.visible = true;
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
            navigation.messageCount = 0;
            navigation.clearModel = false;
            tipsControl.visible = false;
            exitRequest = false;
            enterClassRoom = true;
            loginView.clearPassword();
            isMiniClassroom = false;
            showLoginWindow();
        }
        onConfirmExit: {
            accountMgr.doUplaodLogFile();
            windowView.close();
            Qt.quit();
        }
    }

    YMHomePageParentRemindView{
        id:parentRemindView
        anchors.fill: parent
        visible: false
    }

    YMEnterClassStatusTipView{
        id:enterClassStatusTipView
        visible: false
        anchors.centerIn: parent
    }

    YMAskForLeaveView {
        id:askForLeaveView
        anchors.fill: parent
        visible: false
        onAskForLeaveSuccess: {
            navigation.getActiveView();
        }
    }

    Component.onCompleted: {
        console.log("******************************",version.update)
        windowView.visible = true;
        console.log("===userInfo===",userInfo)
        title = "学生端V" + version.version;
        strStage = accountMgr.getCurrentStage();
        if(strStage == "api")
        {
            strStage = "";
        }        

        loginView.resetLoginViewUrl(version.stage);

        if(version.update){
            softwareView.isUpdate = version.status == 0 ? true : false;
            softwareView.visible = true;
            softwareView.title = version.version;
            showUpdateFrimeWare();
            return;
        }else{
            addNavigation();
            showLoginWindow();
            if(userInfo[0] == undefined || userInfo == null){
                isFirstUsing=true;
                isParentRemindHadShowed = false;
                isAskForLeaveViewHasBeShowed = false;
                return;
            }
            loginView.userName = userInfo[0];
            loginView.password = userInfo[2] == 1 ? userInfo[1] : "";
            loginView.savePassword = userInfo[2] == 1 ? true : false;
            loginView.autoLogin = userInfo[3] == 1 ? true : false;
            loginView.version = version.version;
            isStudentUser=userInfo[4]==1 ? true : false//用户判断 1 为学生  0为老师
            isParentRemindHadShowed=userInfo[5]==1 ? true :false;
            isAskForLeaveViewHasBeShowed = userInfo[6] == 1 ? true : false;
        }
    }

    function showMessageBox(strMsg){
        messagebox.tips = strMsg;
        classView.visible = false;  //隐藏"正在进入教室中..."的窗口
        messagebox.visible = true;  //显示: 服务器返回错误信息的窗口
    }

    function showUpdateFrimeWare() {
        softwareView.visible = true
        loginView.visible = false;
        windowView.width = 430 * widthRate;
        windowView.height = 440 * heightRate;
        windowView.setX((Screen.width - windowView.width) / 2);
        windowView.setY((Screen.height - windowView.height) / 2);
        mainView.visible = false;
    }

    function showLoginWindow(){
        loginView.visible = true;
        loginView.startFadeOut();
        softwareView.visible = false;
        windowView.width = 780 * widthRate * 0.9 ;
        windowView.height = 480 * widthRate * 0.9;
        windowView.setX((Screen.width - windowView.width) / 2);
        windowView.setY((Screen.height - windowView.height) / 2);
        mainView.visible = false;
    }

    function showMainWindow(){
        loginView.visible = false;
        softwareView.visible = false;
        windowView.width = 1439 * heightRate * 0.75;
        windowView.height = 1269 * heightRate * 0.75;
        windowView.setX((Screen.width - windowView.width) / 2);
        windowView.setY((Screen.height - windowView.height) / 2);
        mainView.visible = true;
        windowView.visible = true;
        //        if(isFirstUsing && !isStudentUser){
        //            parentRemindView.visible=true;
        //        }
    }

    function addNavigation(){
        navigation.clearModel = true;
        console.log("==topTilte==",title);
        navigation.addView("我的课表",
                           ":/../JRHomePage/YMStudentCoachView.qml",
                           "qrc:/images/btn_kechengbiao@2x.png",
                           "qrc:/images/btn_kechengbiao_sed@2x.png");
        //        navigation.addView("全部课程",
        //                           "qrc:/studentcoach/YMStudentCoachView.qml",
        //                           "qrc:/images/btn_allcourse@3x.png",
        //                           "qrc:/images/btn_allcourse_sed@3x.png");
        //        navigation.addView("直播课",
        //                           "",
        //                           "qrc:/images/index_btn_zhibo@3x.png",
        //                           "qrc:/images/btn_zhibo_sed@3x.png");

        //        navigation.addView("小组课",
        //                           "qrc:/miniClass/YMMiniClassList.qml",
        //                           "qrc:/miniClassImg/btn_xbk.png",
        //                           "qrc:/miniClassImg/btn_xbk_sed.png");

        //        navigation.addView("提醒",
        //                           "qrc:/studentMessageTips/YMMassgeView.qml",
        //                           "qrc:/images/btn_msg@3x.png",
        //                           "qrc:/images/btn_msg_sed@3x.png");
        //        navigation.addView("SQ学商",
        //                           "qrc:/studentSQText/YMSQTestView.qml",
        //                           "qrc:/images/btn_cepin@2x.png",
        //                           "qrc:/images/btn_cepin sed@2x.png");
        //        navigation.addView("课程规划",
        //                           "",
        //                           "qrc:/images/index_btn_kechengguihua@2x.png",
        //                           "qrc:/images/index_btn_kechengguihua_sed@2x.png");
    }
}

