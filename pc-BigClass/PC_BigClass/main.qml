import QtQuick 2.3
import QtQuick.Window 2.0
import QtQml 2.2
import QtGraphicalEffects 1.0
import YMAccountManagerAdapter 1.1
import YMStageManagerAdapter 1.0
import "Configuration.js" as Cfg

Window {
    id: windowView
    visible: false
    width: Screen.width * 0.8 - Cfg.NAV_LINE_HEIGHT * widthRate;
    height: Screen.width * 0.65;
    flags: Qt.Window | Qt.FramelessWindowHint
    title: topTitle
    color: "transparent"
    property double widthRate: Screen.width * 0.8 / 966.0;
    property double heightRate: widthRate / 1.5337;
    property bool enterClassRoom: true;
    property bool exitRequest: false;
    property string topTitle: qsTr("大班课");
    property string userId: "";
    property string userName: "";
    property string password: "";
    property string realName: "";
    property int debugNetType: -1;
    property string debugStage: "";

    // 控制整体背景色
    Rectangle {
        id: bgItem
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        radius:  4 * widthRate
        border.color: "#dfe2e8"
        border.width: 2
    }

    // 连续左击5次版本号, 提示的密码框
    YMStageInputPasswordView {
        id: stagePwdView
        z: 666
        visible: false
        width: 280 * heightRate
        height: 160 * heightRate
        anchors.centerIn: parent
    }

    //内部测试使用的"网络环境设置"对话框
    YMInterNetSetting {
        id: interNetSetting
        z: 2222
        width: 280 * heightRate
        height: 360 * heightRate
        anchors.centerIn: parent
        visible: false
    }

    YMStageManagerAdapter {
        id: stageWorkMgr
        onSigStageInfo: {
            debugNetType = netType;
            debugStage = stageInfo;
        }
    }

    // 账号管理类
    YMAccountManagerAdapter {
        id: accountMgr
        onLoginSucceed: {
            console.log("===loginSuccess==")
            userName = loginView.userName;
            password = loginView.password;
            var savepwd = loginView.savePassword == true ? 1 : 0;
            var autologin = loginView.autoLogin == true ? 1 : 0;
            accountMgr.saveUserInfo(userName,password,savepwd,autologin);
            enterClassRoom = true;;
            loginView.tips = "";
            exitRequest = true;
            showEnterClass();
        }
        onSigTokenFail: {
            navigation.clearModel = false;
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
        onTeacherInfoChanged: {
            realName = teacherInfo.realName;
            topTitle = topTitle
            userId = teacherInfo.userId;
        }
    }

    // 登陆界面
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

    // 输入规划Id进入教室界面
    YMEnterClassView {
        id: enterclassview
        visible: false
        anchors.fill: parent
        window: windowView
        onClosed: {
            Qt.quit();
        }
        onEnterMini: {
            windowView.visibility = Window.Minimized;
        }
    }

    Component.onCompleted: {
        windowView.visible = true
        topTitle = topTitle;
        showLoginWindow();
        if(userInfo[0] == undefined || userInfo == null)
        {
            return;
        }
        loginView.userName = userInfo[0];
        loginView.password = userInfo[2] == 1 ? userInfo[1] : ""
        loginView.savePassword = userInfo[2] == 1 ? true : false
        loginView.autoLogin = userInfo[3] == 1 ? true : false
    }

    // 显示登陆界面
    function showLoginWindow() {
        loginView.visible = true;
        loginView.startLoginAnimation();
        windowView.width = Screen.width /1366 * 780;
        windowView.height = Screen.width / 1366 * 460;
        windowView.setX((Screen.width - windowView.width)* 0.5);
        windowView.setY((Screen.height - windowView.height) * 0.5);
    }

    // 输入执行Id进入教室
    function showEnterClass() {
        loginView.visible = false;
        windowView.width = Screen.width /1366 * 780;
        windowView.height = Screen.width / 1366 * 460;
        windowView.setX((Screen.width - windowView.width)* 0.5);
        windowView.setY((Screen.height - windowView.height) * 0.5);
        enterclassview.visible = true;
    }
}
