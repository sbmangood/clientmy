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
        autoImage.source = autoLogin ? "qrc:/JrImage/btn_gou_pressed.png" : "qrc:/JrImage/btn_gou_normal.png"
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
            loginButtonItem.color = Cfg.LOGIN_BTN_COLOR;
            loginMouseArea.enabled = true;
        }
        else{
            loginMouseArea.enabled = false;
        }
    }

    onSavePasswordChanged: {
        saveImage.source = savePassword ? "qrc:/JrImage/btn_gou_pressed.png" : "qrc:/JrImage/btn_gou_normal.png"
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
                console.log("====onPositionChanged=====",delta,window.x,window.y)
                window.setX(window.x+delta.x)
                window.setY(window.y+delta.y)
            }
            onDoubleClicked:
            {
                window.visibility = Window.Windowed;
            }
        }
    }

    Rectangle{
        id:background1
        width: 400 * heightRate
        height:195 * heightRate
        anchors.top: parent.top
        anchors.left: bgImg.right
        color: "#FBFBFB"
    }
    //关闭按钮
    MouseArea{
        id: closeButton
        width: 35 * widthRate
        height: 35 * widthRate
        anchors.right: parent.right
        anchors.top: parent.top
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        Text{
            text: "×"
            font.bold: true
            font.pixelSize: 16 * widthRate
            color: parent.containsMouse ? "#FF5500" : "#E7E7E7"
            anchors.centerIn: parent
        }

        onClicked: {
            closed();
        }
    }
    //精锐公司标志
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
            source: "qrc:/JrImage/logo.png"
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
        width: parent.width - 400 * heightRate
        height: parent.height
        Image{
            anchors.fill: parent
            source: 'qrc:/JrImage/leftbg.png'
        }
    }
    //老师端标签
    Item {
        id: lbTeacher
        anchors.left: bgImg.right
        anchors.leftMargin: 14
        anchors.top: parent.top
        anchors.topMargin: 12
        width: 54
        height:18
        Text{
            text: "老师端"
            font.pixelSize: 18
            font.family: Cfg.LOGIN_FAMILY
            color:  "#949494"
            anchors.centerIn: parent
        }

    }
    Item{
        width: 400 * heightRate
        height:parent.height * 0.67
        anchors.top: loginItem.bottom
        anchors.topMargin: 80 * heightRate
        anchors.left: bgImg.right

        TextField{
            id: userText
            width: parent.width * 0.8
            height: 46 * heightRate
            x: (parent.width - width) * 0.5
            text: userName
            placeholderText: "请输入工号"
            font.family: Cfg.LOGIN_FAMILY
            font.pixelSize: Cfg.LOGIN_FONTSIZE * widthRate
            style: TextFieldStyle{
                background: Rectangle{
                    color: "#ffffff"
                    border.color:userText.text !== ""?"#FF5500":"#E4E4E4"
                    border.width: 1
                    radius: 23 * widthRate
                }
                textColor: "#FF5500"
                placeholderTextColor: "#ACACAC"
                padding.left: 10 * widthRate
            }
            menu:null

            onTextChanged: {
                tips = "" ;
                if(userText.text !== "" && passwordText.text !== ""){
                    loginButtonItem.color = Cfg.LOGIN_BTN_COLOR
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
            height: 46 * heightRate
            x: (parent.width - width) * 0.5
            anchors.top:userText.bottom
            anchors.topMargin: 20 * widthRate
            text: password
            placeholderText: "请输入密码"
            echoMode: TextInput.Password
            font.family: Cfg.LOGIN_FAMILY
            font.pixelSize: Cfg.LOGIN_FONTSIZE * widthRate
            style: TextFieldStyle{
                background: Rectangle{
                    color: "#ffffff"
                    border.color:passwordText.text !== ""?"#FF5500":"#E4E4E4"
                    border.width: 1
                    radius: 23 * widthRate
                }
                placeholderTextColor: "#ACACAC"
                textColor: "#FF5500"
                padding.left: 10 * widthRate
            }
            menu:null
            onTextChanged: {
                tips = "" ;
                if(userText.text !== "" && passwordText.text !== ""){
                    loginButtonItem.color = Cfg.LOGIN_BTN_COLOR
                    loginConfram = true;
                    password = text;
                }else{
                    loginButtonItem.color = "#e0e0e0"
                }
            }
        }
        Rectangle{
            id:background2
            color:"#FBFBFB"
            width: parent.width
            height: parent.width / 9.0
            anchors.top:loginMouseArea.bottom
            anchors.topMargin: 140 * heightRate

            Row{
            id:rowSavePassLoginSelf
            width: parent.width * 0.4
            height: parent.width / 9.0
            x: (parent.width - passwordText.width)-20
            spacing: 5* heightRate
            Image{
                id: saveImage
                width: 12 * widthRate
                height: 12 * widthRate
                source: "qrc:/JrImage/btn_gou_normal.png"
                anchors.verticalCenter: parent.verticalCenter
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        savePassword = !savePassword
                        saveImage.source = savePassword ? "qrc:/JrImage/btn_gou_pressed.png" : "qrc:/JrImage/btn_gou_normal.png"
                    }
                }
            }
            Text{
                width: 56 * widthRate
                height: parent.height
                text: "记住密码"
                color: "#C3C3C3"
                verticalAlignment: Text.AlignVCenter
                font.family: Cfg.LOGIN_FAMILY
                font.pixelSize: Cfg.LOGIN_FONTSIZE * widthRates
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        savePassword = !savePassword
                        saveImage.source = savePassword ? "qrc:/JrImage/btn_gou_pressed.png" : "qrc:/JrImage/btn_gou_normal.png"
                    }
                }
            }

        }

          Row{
          id:rowLoginSelf
          width: parent.width * 0.4
          height: parent.width / 9.0
          x: (parent.width - passwordText.width) + 150
          spacing: 5* heightRate
            Image{
                id: autoImage
                width: 12 * widthRate
                height: 12 * widthRate
                source: "qrc:/JrImage/btn_gou_normal.png"
                anchors.verticalCenter: parent.verticalCenter
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        autoLogin = !autoLogin
                        autoImage.source = autoLogin ? "qrc:/JrImage/btn_gou_pressed.png" : "qrc:/JrImage/btn_gou_normal.png"
                    }
                }
            }
            Text{
                width: 56 * widthRate
                height: parent.height
                text: "自动登录"
                color: "#C3C3C3"
                verticalAlignment: Text.AlignVCenter
                font.family: Cfg.LOGIN_FAMILY
                font.pixelSize: Cfg.LOGIN_FONTSIZE * widthRates
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        autoLogin = !autoLogin
                        autoImage.source = autoLogin ? "qrc:/JrImage/btn_gou_pressed.png" : "qrc:/JrImage/btn_gou_normal.png"
                    }
                }
            }

        }

        }

        MouseArea{
            id:loginMouseArea
            x: (parent.width - width) * 0.5
            anchors.top:passwordText.bottom
            anchors.topMargin: 40 * heightRate
            width: parent.width * 0.8
            height: 46 * heightRate
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
            accountMgr.login(userText.text,passwordText.text);
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
    function startTimer()
    {
       timer.running = true;

    }
}

