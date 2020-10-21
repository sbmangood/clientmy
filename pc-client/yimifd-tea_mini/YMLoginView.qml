import QtQuick 2.0
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "./Configuration.js" as Cfg

Rectangle{
    id: loginView
    anchors.fill: parent
    border.width: 1
    border.color: "#e3e6e9"
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

    property int tipsMark: 0;

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

    Rectangle{//窗体移动
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

        Text{
            text: "×"
            font.bold: true
            font.pixelSize: 16 * widthRate
            color: parent.containsMouse ? "red" : "#3c3c3e"
            anchors.centerIn: parent
        }

        onClicked: {
            closed();
        }
    }

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


    Item{
        id: loginItem
        width: parent.width * 0.35
        height: parent.height * 0.25
        anchors.right: parent.right

        Image{
            width: 150 * widthRate
            height: 38 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            y: 90 * heightRate
            smooth: true
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/loginlogo@2x.png"
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

    //左侧图片
    Item{
        id: bgImg
        width: parent.width - 360 * heightRate
        height: parent.height
        Image{
            anchors.fill: parent
            source: 'qrc:/images/loginAds.jpg'
        }
    }

    Item{
        width: 360 * heightRate
        height:parent.height * 0.45
        anchors.top: loginItem.bottom
        anchors.topMargin: 52 * heightRate
        anchors.left: bgImg.right

        TextField{
            id: userText
            width: parent.width * 0.8
            height: 50 * heightRate
            x: (parent.width - width) * 0.5
            text: userName
            placeholderText: "请输入账号"
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
                    loginButtonItem.color = Cfg.TB_CLR
                    loginConfram = true;
                    userName= text;
                }else{
                    loginButtonItem.color = "#e0e0e0"
                }
            }
        }

        TextField{
            id: passwordText
            width: parent.width * 0.8
            height: 50 * heightRate
            x: (parent.width - width) * 0.5
            anchors.top:userText.bottom
            anchors.topMargin: 10*widthRate
            text: password
            placeholderText: "请输入密码"
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
                    loginButtonItem.color = Cfg.TB_CLR
                    loginConfram = true;
                    password = text;
                }else{
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
        }

        MouseArea{
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

        Item{
            width: parent.width
            height: 45 * widthRate
            anchors.top: loginMouseArea.bottom
            anchors.topMargin: 15 * widthRate
            Text{
                id: lbText
                visible: tips == "" ? false : true
                text: tips
                color: "red"
                anchors.centerIn: parent
                font.family: Cfg.LOGIN_FAMILY
                font.pixelSize: Cfg.LOGIN_FONTSIZE * widthRate
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
            //accountMgr.login(userText.text,passwordText.text);
        }
    }

    function startLoginAnimation(){
        animateLoginOpacity.start();
    }
    function clearPassword()
    {
        if( !savePassword )
        {
            passwordText.text = "";
        }
    }
}

