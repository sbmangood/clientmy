import QtQuick 2.0
import "./Configuuration.js" as Cfg

/*
* 上麦弹窗页面展示
*/

Rectangle {
    id: msgView
    color: "white"
    width: 260 * heightRate
    height: 160 * heightRate
    radius: 12 * heightRate

    property string tipsMessage: "";//提醒文本
    property string buttonText: ""; //按钮文字展示

    signal sigCancel();//取消连麦
    signal sigAutoVisible();//自动隐藏界面信号

    Text{
        id: tipText
        text: tipsMessage
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 18 * heightRate
        anchors.top: parent.top
        anchors.topMargin: buttonText == "" ? (parent.height - height ) * 0.5 : 40 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
    }

    MouseArea{//取消上麦, 知道了,上麦成功按钮
        width: 160 * heightRate
        height: 40 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        cursorShape: Qt.PointingHandCursor
        visible:  buttonText == "" ? false : true

        Rectangle{
            color: "#ff5000"
            anchors.fill: parent
            radius: 6 * heightRate
        }

        Text{
            text: buttonText
            color: "#ffffff"
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 14 * heightRate
            anchors.centerIn: parent
        }

        onClicked: {
            if(buttonText.indexOf("好的") != -1 && buttonText  != "")
            {
                sigAutoVisible();
                return;
            }
            sigCancel();
        }

    }

    property int make: 3;
    Timer{
        id: reciprocalTime
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            make--;
            buttonText = "好的（"+ make +"）"
            if(make == 0){
                sigAutoVisible();
                reciprocalTime.stop();
                reciprocalTime.repeat = true;
            }
        }
    }

    function runTime(){
        make = 3;
        reciprocalTime.restart();
    }
}
