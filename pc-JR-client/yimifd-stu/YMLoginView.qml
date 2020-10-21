import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "./Configuration.js" as Cfg
import QtGraphicalEffects 1.0

Rectangle {    
    id:loginViewItem
    color: "white"
    border.color: "#e3e6e9"
    border.width: 1
    anchors.fill: parent

    signal confirmClosed();
    signal loginMined();
    signal loginMessage();
    signal identificationed(var isStudent)

    property bool savePassword: false;
    property bool autoLogin: false;
    property bool loginConfram: false;
    property string userName: "";
    property string password: "";
    property string version: "";
    property string tips: "";
    property int checkNumber: 0;

    property var window: null

    onTipsChanged:
    {
        console.log("tieoadsa",tips);
    }

    Timer{
        id: stageTimer
        interval: 1500
        running: false
        onTriggered: {
            checkNumber = 0;
        }
    }

    onAutoLoginChanged: {
        autoImage.source = autoLogin ? "qrc:/JrImage/btn_gou_pressed.png" : "qrc:/JrImage/btn_gou_normal.png"
        if(userText.text == "" ){
            tips = "请您输入用户名";
            return;
        }
        if(passwordText.text == ""){
            tips = "请您输入密码";
            return;
        }

        if(autoLogin){
            timer.running = true;
            loginButtonItemTextAnimation.running = true;
        }else{
            timer.stop();
            loginButtonItemTextAnimation.running = false;
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

    //窗体移动
    MouseArea {
        id: dragRegion
        width: parent.width
        height: Cfg.TB_HEIGHT

        property point clickPos: "0,0"

        onPressed: {
            clickPos  = Qt.point(mouse.x,mouse.y)
        }

        onPositionChanged: {
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
            window.setX(window.x+delta.x)
            window.setY(window.y+delta.y)
        }
        onDoubleClicked: {
            window.visibility = Window.Windowed;
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

    MouseArea{
        width: 30 * widthRate
        height: 30 * widthRate
        anchors.right: parent.right
        anchors.rightMargin: 1 * widthRate
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
            confirmClosed();
        }
    }

    Item{
        id: loginItem
        width: parent.width * 0.35
        height: parent.height * 0.25
        anchors.right: parent.right

        Image{
            width: 150 * widthRate
            height: 35 * heightRate
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
            source: "qrc:/JrImage/leftbg.png"
        }
    }
    //学生端标签
    Item {
        id: lbStudent
        anchors.left: bgImg.right
        anchors.leftMargin: 14
        anchors.top: parent.top
        anchors.topMargin: 12
        width: 54
        height:18
        Text{
            text: "学生端"
            font.pixelSize: 18
            font.family: Cfg.LOGIN_FAMILY
            color:  "#949494"
            anchors.centerIn: parent
        }

    }
    Item{
        width: 400 * heightRate
        height:parent.height * 0.45
        anchors.top: loginItem.bottom
        anchors.topMargin: 80 * heightRate
        anchors.left: bgImg.right

        TextField{
            id: userText
            width: parent.width * 0.8
            height:  46 * heightRate
            x: (parent.width - width) * 0.5
            text: userName
            placeholderText: "请输入手机号"
            font.family: Cfg.LOGIN_FAMILY
            font.pixelSize: Cfg.LOGIN_INPUT_FONTSIZE * widthRate
            style: TextFieldStyle{
                background: Rectangle{
                    color: "#ffffff"
                    border.color:userText.text !== ""?"#FF5500":"#E4E4E4"
                    border.width: 1
                    radius: 23 * widthRate
                }
                textColor: "#FF5500"
                padding.left: 10 *widthRate
                placeholderTextColor: "#ACACAC"
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
            anchors.topMargin: 20*widthRate
            text: password
            placeholderText: "请输入密码"
            echoMode: TextInput.Password
            font.family: Cfg.LOGIN_FAMILY
            font.pixelSize: Cfg.LOGIN_INPUT_FONTSIZE * widthRate
            style: TextFieldStyle{
                background: Rectangle{
                    color: "#ffffff"
                    border.color:passwordText.text !== ""?"#FF5500":"#E4E4E4"
                    border.width: 1
                    radius: 23 * widthRate
                }
                textColor: "#FF5500"
                padding.left: 10 * widthRate
                placeholderTextColor: "#ACACAC"
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
            anchors.topMargin: 150 * heightRate

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


        //登录按钮
        MouseArea{
            id:loginMouseArea
            width: parent.width * 0.8
            height: 45 * heightRate
            x: (parent.width - width) * 0.5
            anchors.top:passwordText.bottom
            anchors.topMargin: 30 * heightRate
            enabled: loginConfram
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                id: loginButtonItem
                color: "#e0e0e0"
                radius: 22 * widthRate
                anchors.fill: parent
                Text{
                    id:loginButtonText
                    text: "登 录"
                    color: "#ffffff"
                    anchors.centerIn: parent
                    font.family: Cfg.LOGIN_FAMILY
                    font.pixelSize: (Cfg.LOGIN_FONTSIZE + 1) * widthRate

                    SequentialAnimation {
                        id: loginButtonItemTextAnimation
                        loops: Animation.Infinite;
                        PropertyAnimation {
                            target: loginButtonText
                            property: "text"
                            to: "登录中"
                            duration: 250
                        }
                        PropertyAnimation {
                            target: loginButtonText
                            property: "text"
                            to: "登录中."
                            duration: 250
                        }
                        PropertyAnimation {
                            target: loginButtonText
                            property: "text"
                            to: "登录中.."
                            duration: 250
                        }
                        PropertyAnimation {
                            target: loginButtonText
                            property: "text"
                            to: "登录中..."
                            duration: 250
                        }
                    }
                }
            }
            onClicked: {
                loginMouseArea.enabled=false;
                loginButtonItemTextAnimation.running = true;
                timer.stop();
                tips = "" ;
                checkLogin();
                loginButtonItemTextAnimation.running=false;
                loginButtonText.text="登 录";
                loginMouseArea.enabled=true;

            }
        }

        //注册忘记密码
        Row{
            id: registeredRow
            width:  parent.width
            height: 45 * heightRate
            x: (parent.width - passwordText.width) + 150
            anchors.top:loginMouseArea.bottom
            anchors.topMargin: 10 * heightRate


            MouseArea{
                width:  60 * widthRate
                height: parent.height
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Text{
                    text: "立即注册"
                    height: parent.height
                    color: parent.containsMouse ? "#ff5000" : "#999999"
                    verticalAlignment: Text.AlignVCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10 * widthRate
                    font.family: Cfg.LOGIN_FAMILY
                    font.pixelSize: (Cfg.LOGIN_FONTSIZE -2) * widthRate
                }
                onClicked: {
                    var url = URL_SignUp;
                    console.log(url);
                    Qt.openUrlExternally(url);
                }
            }
        }
        Row{
            id: updatePasswordRow
            width:  parent.width
            height: 45 * heightRate
            x: (parent.width - passwordText.width)-20
            anchors.top:loginMouseArea.bottom
            anchors.topMargin: 10 * heightRate


            MouseArea{
                width: 60 * widthRate
                height: parent.height
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Text{
                    text: "忘记密码"
                    height: parent.height
                    color: parent.containsMouse ? "#ff5000" : "#999999"
                    verticalAlignment: Text.AlignVCenter
                    anchors.right: parent.right
                    font.family: Cfg.LOGIN_FAMILY
                    font.pixelSize: (Cfg.LOGIN_FONTSIZE -2) * widthRate
                }
                onClicked: {
                    var url = URL_ForgetPassword;
                    console.log(url);
                    Qt.openUrlExternally(url)
                }
            }


        }
        Item{
            width: parent.width
            height: 45 * widthRate
            anchors.top:updatePasswordRow.bottom
            anchors.topMargin: 15 * widthRate

            Text{
                id: lbText
                visible: tips == "" ? false : true
                text: tips
                color: "red"
                anchors.centerIn: parent
                font.family: Cfg.LOGIN_FAMILY
                font.pixelSize: (Cfg.LOGIN_FONTSIZE - 2) * widthRate
            }
        }
    }


    Keys.onPressed: {
        if(event.key === Qt.Key_Enter || event.key === (Qt.Key_Enter - 1)){
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

//    YMSelectParentOrStudentView {
//        id:selectParentOrStudentView
//        anchors.fill: parent
//        visible: false
//        onCurrentRole: {
//            identificationed(isStudent);
//        }
//    }

    function checkLogin(){
        if(userText.text !== "" && passwordText.text !== ""){
            userName = userText.text;
            password = passwordText.text;
            accountMgr.login(userText.text,passwordText.text);
            loginButtonText.text="登 录";
            loginButtonItemTextAnimation.running = false;
        }/*else{
            if(userText.text == ""){
                tips = "请您如输入用户名";
            }
            if(passwordText.text == ""){
                tips = "请您输入用户密码";
            }
            loginButtonText.text="登 录";
            timer.stop();
            loginButtonItemTextAnimation.running = false;
        }*/
    }

    function showSelectParentOrStudentView(){
        //selectParentOrStudentView.visible = true;
    }

    //动画过渡
    NumberAnimation {
        id: animateOpacity
        target: loginViewItem
        duration: 1000
        properties: "opacity"
        from: 0.0
        to: 1.0
        onStopped: {

        }
    }

    function startFadeOut() {
        animateOpacity.stop();
        animateOpacity.start();
    }
    function resetPasswordView()
    {
        if( !savePassword ) // 非记住密码状态下 清空密码框数据
        {
            passwordText.text = "";
        }
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

