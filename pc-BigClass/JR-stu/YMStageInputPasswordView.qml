import QtQuick 2.0
import QtQuick.Controls 1.4
import "./Configuration.js" as Cfg

//连续左击5次版本号, 提示的密码框
Rectangle {
    id: inputPwdView
    border.color: "#f3f3f3"
    border.width: 1

    onVisibleChanged: {
        if(visible){
            textField.text = "";
            textField.focus = true;
            textTips.visible = false;
        }
    }

    //关闭按钮
    MouseArea{
        width: 26 * heightRate
        height: 26 * heightRate
        hoverEnabled: true
        anchors.right: parent.right
        anchors.rightMargin: 5 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 5 * heightRate

        Rectangle{
            anchors.fill: parent
            color: parent.containsMouse ? "#e0e0e0" : "#f3f3f3"
            radius: 100
        }

        Text {
            anchors.centerIn: parent
            font.pixelSize: 14 * heightRate
            font.family: Cfg.DEFAULT_FONT
            text: qsTr("×")
            color: parent.containsMouse ? "red" : "#000000"
        }

        onClicked: {
            inputPwdView.visible = false;
            textField.text = ""; //点击"关闭"按钮, 再打开窗口的时候, 清空密码
        }
    }

    TextField{
        id: textField
        width: 140 * heightRate
        height: 35 * heightRate
        font.family: Cfg.DEFAULT_FONT
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - width - okBtn.width - 10 * heightRate) * 0.5
        echoMode: TextInput.Password
    }

    //提示框
    Text {
        id: textTips
        anchors.top: textField.bottom
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - textField.width - okBtn.width - 10 * heightRate) * 0.5
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 12 * heightRate
        color: "red"
        visible: false
        text: qsTr("请您输入正确的密码!")
    }

    //确定
    MouseArea{
        id: okBtn
        width: 80 * heightRate
        height: 35 * heightRate
        anchors.left: textField.right
        anchors.leftMargin: 10 * heightRate
        anchors.verticalCenter: parent.verticalCenter
        cursorShape: Qt.PointingHandCursor

        Rectangle{
            color: "#f55000"
            anchors.fill: parent
        }

        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 14 * heightRate
            anchors.centerIn: parent
            text: qsTr("确定")
        }

        onClicked: {
            checkPassWord();
        }
    }

    //按下回车键, 同: 按下"确定"按钮
    Keys.onPressed: {
        if(event.key === Qt.Key_Enter || event.key === (Qt.Key_Enter - 1)){
            checkPassWord()
        }
    }

    //密码正确, 就下一个窗口
    //密码不正确, 就提示
    function checkPassWord(){
        if(textField.text == "ymfudao"){
            textTips.visible = false;
            inputPwdView.visible = false;
            interNetSetting.visible = true;
        }else{
            textTips.visible = true;
        }

        textField.text = "";
    }
}
