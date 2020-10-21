import QtQuick 2.0
import "./Configuration.js" as Cfg

/*
 *学生进入教室
 */

Rectangle {
    id: tipConfirmView
    color: "white"

    property string studentName: ""

    radius: 10 * ratesRates
    clip: true

    //确定
    signal sigConfirm();

    Text {
        id: tagName
        height: 40 * heightRate
        anchors.top: parent.top
        font.pixelSize: 18 * heightRate
        anchors.topMargin: 30 * heightRate
        color: "#222222"
        wrapMode:Text.WordWrap
        font.family: Cfg.DEFAULT_FONT
        text: qsTr("学生 ") + studentName + " 进入教室"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        text: qsTr("当前课程可以接着之前内容继续进行")
        font.pixelSize: 16 * heightRate
        font.family: Cfg.DEFAULT_FONT
        anchors.top: tagName.bottom
        anchors.topMargin: 10 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle{
        id:okBtn
        width:  240  *  heightRate
        height:  40 * heightRate
        color: "#ff5000"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10 *  heightRate
        radius: 6 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            id: okBtnName
            font.pixelSize: 14  * tipLoginError.ratesRates
            color: "#ffffff"
            font.family: Cfg.DEFAULT_FONT
            text: qsTr("继续上课")
            anchors.centerIn: parent
        }

        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: {
                okBtn.color = "#c3c6c9";
            }
            onReleased: {
                okBtn.color = "#ff5000";
                sigConfirm();
            }
        }
    }

    function resetShowText(showText)
    {
        tagName.text = showText;
    }

}
