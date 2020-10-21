import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "Configuration.js" as Cfg

MouseArea {
    z: 668
    id: updatePwdView
    hoverEnabled: true

    onWheel: {
        return;
    }

    property string oldPassword: "";
    property string keywords: navigation.keyWord;

    signal transferPage(var pram);

    onKeywordsChanged: {
        oldPassword = keywords;
        queryData();
        //console.log("key word test ",keywords);
    }
    onVisibleChanged: {
        if(visible){
            queryData();
        }
    }

    Rectangle{
        id: bgItem
        anchors.fill: parent
        opacity: 0.4
        color: "black"
        radius: 12 * widthRate
        anchors.centerIn: parent
    }

    Rectangle{
        width: 290 * widthRate
        height: 310 * widthRate
        color: "white"
        radius: 12
        anchors.centerIn: parent

        MouseArea{
            width: 15 * heightRate
            height: 15 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 8 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 8 * widthRate
            cursorShape: Qt.PointingHandCursor
            Image{
                anchors.fill: parent
                source: "qrc:/images/bar_btn_close.png"
            }
            onClicked: {
                updatePwdView.visible = false;
            }
        }

        Column{
            id: columnItem
            width: parent.width * 0.8
            height: parent.height - 20 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 20 * widthRate
            spacing: 10 * widthRate
            anchors.horizontalCenter: parent.horizontalCenter

            Text{
                id: titleText
                width: parent.width
                height: 35 * widthRate
                text: qsTr("修改密码")
                color: "#3c3c3e"
                font.family: Cfg.PASSWORD_FAMILY
                font.pixelSize:(Cfg.PASSWORD_FONTSIZE + 6) * widthRate
            }

            TextField{
                id: passwordTextField
                width: parent.width
                height: 35 * widthRate
                echoMode: TextInput.Password
                placeholderText: "请输入当前密码"
                font.family: Cfg.PASSWORD_FAMILY
                font.pixelSize:Cfg.PASSWORD_FONTSIZE * widthRate
                style: TextFieldStyle{
                    background: Rectangle{
                        color: "#ffffff"
                        border.color:"#e3e6e9"
                        border.width: 1 * widthRate
                        radius: 6
                    }
                    textColor: "#999999"
                    padding.left: 8 * widthRate
                    placeholderTextColor: "#999999"
                }
                onEditingFinished: {
                    if(oldPassword != text){
                        lbPwd.text = "当前密码不正确"
                    }else{
                        lbPwd.text = " "
                    }
                }
            }
            //当前密码提醒图标和文字
            Rectangle{
                width:  120 * heightRate
                height:  8 * widthRate
                Rectangle{
                    id: iItem
                    radius: 100
                    color: "red"
                    visible: lbPwd.text != " " ? true : false
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16 * heightRate
                    height: 16 * heightRate
                    Text{
                        text: "!"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 6 * widthRate
                        anchors.centerIn: parent
                    }
                }

                Label{
                    id: lbPwd
                    anchors.left: iItem.right
                    anchors.leftMargin: 6* heightRate
                    text: " "
                    color: "red"
                    font.family: Cfg.PASSWORD_FAMILY
                    font.pixelSize: 12 * widthRate
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            TextField{
                id: newPwdTextField
                width: parent.width
                height: 35 * widthRate
                echoMode: TextInput.Password
                placeholderText: "请输入新密码"
                font.family: Cfg.PASSWORD_FAMILY
                font.pixelSize:Cfg.PASSWORD_FONTSIZE * widthRate
                style: TextFieldStyle{                   
                    background: Rectangle{
                        color: "#ffffff"
                        border.color:"#e3e6e9"
                        border.width: 1 * widthRate
                        radius: 6
                    }
                    textColor: "#999999"
                    padding.left: 8 * widthRate
                    placeholderTextColor: "#999999"
                }

            }
            //新密码提醒图标和文字
            Rectangle{
                width:  120 * heightRate
                height:  8 * widthRate
                Rectangle{
                    id: iItem2
                    radius: 100
                    color: "red"
                    visible: lbNewPwd.text != " " ? true : false
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16 * heightRate
                    height: 16 * heightRate
                    Text{
                        text: "!"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 6 * widthRate
                        anchors.centerIn: parent
                    }
                }
                Label{
                    id: lbNewPwd
                    color: "red"
                    text: " "
                    anchors.left: iItem2.right
                    anchors.leftMargin: 6* heightRate
                    font.family: Cfg.PASSWORD_FAMILY
                    font.pixelSize: 12 * widthRate
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            TextField{
                id: confirmText
                width: parent.width
                height: 35 * widthRate
                echoMode: TextInput.Password
                placeholderText: "请再次输入新密码"
                font.family: Cfg.PASSWORD_FAMILY
                font.pixelSize:Cfg.PASSWORD_FONTSIZE * widthRate
                style: TextFieldStyle{
                    background: Rectangle{
                        color: "#ffffff"
                        radius: 6
                        border.color:"#e3e6e9"
                        border.width: 1*widthRate
                    }
                    textColor: "#999999"
                    padding.left: 8 * widthRate
                    placeholderTextColor: "#999999"
                }
            }

            //确认密码提醒图标和文字
            Rectangle{
                width:  120 * heightRate
                height:  8 * widthRate
                Rectangle{
                    id: iItem3
                    radius: 100
                    color: "red"
                    visible: lbConframPwd.text != " " ? true : false
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16 * heightRate
                    height: 16 * heightRate
                    Text{
                        text: "!"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 6 * widthRate
                        anchors.centerIn: parent
                    }
                }
                Label{
                    id: lbConframPwd
                    color: "red"
                    text: " "
                    anchors.left: iItem3.right
                    anchors.leftMargin: 6* heightRate
                    font.family: Cfg.PASSWORD_FAMILY
                    font.pixelSize: 12 * widthRate
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea{
                width: columnItem.width
                height: 35 * widthRate
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: "qrc:/images/btn_jianbian.png"
                }

                Text{
                    text: "确认"
                    anchors.centerIn: parent
                    color:"#ffffff"
                    font.family: Cfg.PASSWORD_FAMILY
                    font.pixelSize: (Cfg.PASSWORD_FONTSIZE + 4) * heightRate
                }

                onClicked: {
                    if(newPwdTextField.text == ""){
                        lbNewPwd.text = "请输入新密码";
                        return;
                    }
                    lbNewPwd.text = " ";
                    if(passwordTextField.text != oldPassword){
                        return;
                    }

                    if(confirmText.text == ""){
                        lbConframPwd.text = "请再次输入新密码";
                        return;
                    }
                    if(newPwdTextField.text != confirmText.text){
                        lbConframPwd.text = "再次输入密码不一致!"
                        return;
                    }
                    lbConframPwd.text = "请再次输入新密码"
                    lbNewPwd.text = " ";
                    lbConframPwd.text = " ";
                    updatePwdView.visible = false;
                    //console.log("newpassword: ",confirmText.text)
                    accountMgr.updatePassword(oldPassword,confirmText.text);
                }
            }
        }
    }

    //清空控件显示数据
    function queryData(){
        passwordTextField.text = "";
        newPwdTextField.text = "";
        confirmText.text = "";
        lbPwd.text = " ";
        lbConframPwd.text = " ";
        lbNewPwd.text = " ";
    }
}

