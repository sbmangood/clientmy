import QtQuick 2.0
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import YMStageManagerAdapter 1.0
import "./Configuration.js" as Cfg

Rectangle {

    property double widthRate: Screen.width * 0.8 / 966.0;
    property double heightRate: widthRate / 1.5337;

    id: loginView
    anchors.fill: parent
    border.width: 1
    border.color: "#e3e6e9"
    radius: 4 * widthRate
    signal closed();
    signal loginMined();
    signal loginMessage();

    property bool savePassword: false;
    property bool autoLogin: false;
    property string userName: "";
    property string password: ""
    property string tips: "";

    property bool loginConfram: false;
    property int checkNumber: 0;
    property var window: null
    property int tipsMark: 0;

    onAutoLoginChanged: {
        autoImage.source = autoLogin ? "qrc:/images/login_btn_right.png" : "qrc:/images/login_btn_right_grey.png"
        if(autoLogin){
            timer.running = true;
        }else{
            timer.stop();
        }
    }

    Timer{
        id: stageTimer
        interval: 1500
        running: false
        onTriggered: {
            checkNumber = 0;
        }
    }

    YMStageManagerAdapter {
        id: ymStageManagerAdapter
    }

    onLoginConframChanged: {
        loginText.text = "登 录"
        loginTipsTime.stop();
        if(loginConfram){
            loginButtonItem.color = Cfg.TB_CLR;
            loginMouseArea.enabled = true;
        }
        else{
            loginMouseArea.enabled = false;
        }
    }

    onSavePasswordChanged: {
        saveImage.source = savePassword ? "qrc:/images/login_btn_right.png" : "qrc:/images/login_btn_right_grey.png"
    }

    Timer{
        id: timer
        interval: 3000
        running: false
        onTriggered: {
            checkLogin();
        }
    }

    Timer{
        id: loginTipsTime
        interval: 200
        running: false
        repeat: true
        onTriggered: {
            if(tipsMark > 2){
                tipsMark = -1;
                loginText.text = "登录中";
            }
            if(tipsMark == 0){
                loginText.text = "登录中.";
            }
            if(tipsMark == 1){
                loginText.text = "登录中..";
            }
            if(tipsMark == 2){
                loginText.text = "登录中...";
            }
            tipsMark++;
        }
    }

    //窗体移动
    Rectangle{
        width: parent.width
        height: Cfg.TB_HEIGHT
        color: "transparent"
        MouseArea {
            id: dragRegion
            anchors.fill: parent
            property point clickPos: "0,0"
            onPressed: {
                clickPos  = Qt.point(mouse.x,mouse.y)
            }
            onPositionChanged: {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                window.setX(window.x+delta.x)
                window.setY(window.y+delta.y)
            }
            onDoubleClicked:
            {
                window.visibility = Window.Windowed;
            }
        }
    }

    //关闭按钮
    MouseArea{
        id: closeButton
        width: 35 * widthRate
        height: 35 * widthRate
        anchors.right: parent.right
        anchors.top: parent.top
        hoverEnabled: true
        cursorShape: Qt.pointingHandCursor

        /*
        Text{
            text: "×"
            font.bold: true
            font.pixelSize: 16 * widthRate
            color: parent.containsMouse ? "red" : "#3c3c3e"
            anchors.centerIn: parent
        }
        */
        Image {
            id: closeImg
            anchors.fill: parent
            source: "qrc:/images/close.png"
        }
        onClicked: {
            closed();
        }
    }

    /*
    MouseArea{
        width: 15 * widthRate
        height: 35 * widthRate
        anchors.right: closeButton.left
        anchors.top: parent.top
        cursorShape: Qt.PointingHandCursor
        Text{
            text: "—"
            font.bold: true
            font.pixelSize: 12 * widthRate
            color: parent.containsMouse ? "#3c3c3e" : "#3c3c3e"
            anchors.centerIn: parent
        }
        onClicked: {
            loginMined();
        }
    }
    */

    //左侧图片
    Item {
        id: bgImg
        width: parent.width - 360 * heightRate
        height: parent.height
        Image{
            anchors.fill: parent
            source: 'qrc:/images/loginAds.png'
        }
    }

    // logo
    Item {
        id: loginItem
        width: parent.width * 0.35
        height: parent.height * 0.25
        anchors.right: parent.right

        Image{
            width: 117 * widthRate
            height: 91 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            y: 90 * heightRate
            smooth: true
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/loginlogo.png"
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    stageTimer.restart();
                    checkNumber++;
                    if(checkNumber >= 5){
                        stagePwdView.visible = true;
                        checkNumber = 0;
                    }
                }
            }
        }
    }

    // 账号、密码、登录
    Item {
        width: 360 * heightRate
        height: parent.height * 0.45
        anchors.top: loginItem.bottom
        anchors.topMargin: 52 * heightRate
        anchors.left: bgImg.right

        TextField{
            id: userText
            width: parent.width * 0.8
            height: 50 * heightRate
            x: (parent.width - width) * 0.5
            text: userName
            placeholderText: "账号:"
            font.family: Cfg.LOGIN_FAMILY
            font.pixelSize: Cfg.LOGIN_FONTSIZE * widthRate
            style: TextFieldStyle{
                background: Rectangle{
                    color: "#ffffff"
                    border.color:"#cccccc"
                    border.width: 1 * widthRate
                    radius: 22 * widthRate
                }
                textColor: "#222222"
                placeholderTextColor: "#999999"
                padding.left: 10 * widthRate
            }
            menu:null

            onTextChanged: {
                tips = "" ;
                if(userText.text !== "" && passwordText.text !== ""){
                    //loginButtonItem.color = Cfg.TB_CLR
                    imgLogin.visible = true;
                    loginConfram = true;
                    userName= text;
                }
                else{
                    imgLogin.visible = false;
                    loginButtonItem.color = "#e0e0e0"
                }
            }
        }

        TextField {
            id: passwordText
            width: parent.width * 0.8
            height: 50 * heightRate
            x: (parent.width - width) * 0.5
            anchors.top:userText.bottom
            anchors.topMargin: 10*widthRate
            text: password
            placeholderText: "密码:"
            echoMode: TextInput.Password
            font.family: Cfg.LOGIN_FAMILY
            font.pixelSize: Cfg.LOGIN_FONTSIZE * widthRate
            style: TextFieldStyle{
                background: Rectangle{
                    color: "#ffffff"
                    border.color:"#cccccc"
                    border.width: 1 * widthRate
                    radius: 22 * widthRate
                }
                placeholderTextColor: "#999999"
                textColor: "#222222"
                padding.left: 10 * widthRate
            }
            menu:null
            onTextChanged: {
                if(userText.text !== "" && passwordText.text !== ""){
                    tips = "" ;
                    //loginButtonItem.color = Cfg.TB_CLR
                    imgLogin.visible = true;
                    loginConfram = true;
                    password = text;
                }
                else{
                    imgLogin.visible = false;
                    loginButtonItem.color = "#e0e0e0"
                }
            }
        }

        Row{
            id:rowSavePassLoginSelf
            anchors.top:passwordText.bottom
            anchors.topMargin: 20 * heightRate
            width: parent.width * 0.8
            height: parent.width / 9.0
            x: (parent.width - passwordText.width) * 0.6
            spacing: 10 * heightRate

            Image{
                id: saveImage
                width: 12 * widthRate
                height: 12 * widthRate
                source: "qrc:/images/login_btn_right_grey.png"
                anchors.verticalCenter: parent.verticalCenter
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        savePassword = !savePassword
                        saveImage.source = savePassword ? "qrc:/images/login_btn_right.png" : "qrc:/images/login_btn_right_grey.png"
                    }
                }
            }
            Text{
                width: 70 * widthRate
                height: parent.height
                text: "记住密码"
                color: "#999999"
                verticalAlignment: Text.AlignVCenter
                font.family: Cfg.LOGIN_FAMILY
                font.pixelSize: (Cfg.LOGIN_FONTSIZE -2) * widthRate
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        savePassword = !savePassword
                        saveImage.source = savePassword ? "qrc:/images/login_btn_right.png" : "qrc:/images/login_btn_right_grey.png"
                    }
                }
            }
            /*
            Image{
                id: autoImage
                width: 12 * widthRate
                height: 12 * widthRate
                source: "qrc:/images/login_btn_right_grey.png"
                anchors.verticalCenter: parent.verticalCenter
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        autoLogin = !autoLogin
                        autoImage.source = autoLogin ? "qrc:/images/login_btn_right.png" : "qrc:/images/login_btn_right_grey.png"
                    }
                }
            }
            Text{
                width: 70 * widthRate
                height: parent.height
                text: "自动登录"
                color: "#999999"
                verticalAlignment: Text.AlignVCenter
                font.family: Cfg.LOGIN_FAMILY
                font.pixelSize: (Cfg.LOGIN_FONTSIZE  - 2) * widthRate
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        autoLogin = !autoLogin
                        autoImage.source = autoLogin ? "qrc:/images/login_btn_right.png" : "qrc:/images/login_btn_right_grey.png"
                    }
                }
            }
            */
        }

        MouseArea {
            id:loginMouseArea
            x: (parent.width - width) * 0.5
            anchors.top:rowSavePassLoginSelf.bottom
            anchors.topMargin: 40 * heightRate
            width: parent.width * 0.8
            height: 50 * heightRate
            enabled: loginConfram
            cursorShape: Qt.PointingHandCursor

            Rectangle{
                id: loginButtonItem
                color: "#e0e0e0"
                radius: 22 * widthRate
                anchors.fill: parent
                Image {
                    id: imgLogin
                    visible: false
                    anchors.fill: parent
                    source: "qrc:/images/loginBtn.png"
                }
                Text{
                    id: loginText
                    text: "登 录"
                    color: "#ffffff"
                    anchors.centerIn: parent
                    font.family: Cfg.LOGIN_FAMILY
                    font.pixelSize: (Cfg.LOGIN_FONTSIZE + 1) * widthRate
                }

            }
            onClicked: {
                userName = userText.text;
                password = passwordText.text;
                timer.stop();
                checkLogin();
            }
        }

        Item {
            id: tipItem
            width: parent.width
            height: 45 * widthRate
            anchors.top: loginMouseArea.bottom
            anchors.topMargin: 5 * widthRate
            Text{
                id: lbText
                visible: tips == "" ? false : true
                text: tips
                color: "#FF6363"
                anchors.centerIn: parent
                font.family: Cfg.LOGIN_FAMILY
                font.pixelSize: Cfg.LOGIN_FONTSIZE * widthRate
            }
        }

        Item {
            id: appVer
            width: parent.width
            height: 45 * widthRate
            anchors.top: tipItem.bottom
            anchors.topMargin: 5 * widthRate
            Text {
                id: appVersionTxt
                text: "版本号：" + ymStageManagerAdapter.getAppVersion()
                anchors.centerIn: parent
                font.family: Cfg.LOGIN_FAMILY
                font.pixelSize: Cfg.LOGIN_FONTSIZE
                color: "#8C8C8C"
            }
        }
    }

    Keys.onPressed: {
        if(event.key === Qt.Key_Enter || event.key === (Qt.Key_Enter - 1)){
            timer.stop();
            checkLogin();
        }
    }

    //控制当前窗口, 光标的默认位置
    Component.onCompleted: {
        if(userText.text.trim() == "")
        {
            userText.focus = true;
        }
        else if(passwordText.text.trim() == "")
        {
            passwordText.focus = true;
        }
        else
        {
            userText.focus = true;
        }
    }

    //登录渐出动画
    NumberAnimation {
        id: animateLoginOpacity
        target: loginView
        duration: 1000
        properties: "opacity"
        from: 0.0
        to: 1.0
    }

    function checkLogin(){
        if(userText.text != "" && passwordText.text != ""){
            userName = userText.text;
            password = passwordText.text;
            loginConfram = false;
            loginTipsTime.start()
            accountMgr.talkUserLogin(userText.text,passwordText.text);
        }
    }

    function startLoginAnimation(){
        animateLoginOpacity.start();
    }
    function clearPassword()
    {
        if(!savePassword)
        {
            passwordText.text = "";
        }
    }
}
