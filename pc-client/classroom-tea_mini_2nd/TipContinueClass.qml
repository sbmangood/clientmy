import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuuration.js" as Cfg
/*
*继续上课页面
*/

Item {
    id: continueView

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;

    property string userName: "";//用户名称
    property bool disableButton: true;

    signal sigContinue();//继续上课信号
    signal sigCancel();

    onVisibleChanged: {
        if(visible){
            disableButton = true;
        }else{
            disableButton = false;
        }
    }

    Rectangle{
        id: backView
        width: 280 * widthRates;
        height: 160 * heightRates;
        radius:  6 * heightRate
        anchors.centerIn: parent
        color: "#ffffff"

        Image{
            id:bgImg
            anchors.fill: parent
            source: "qrc:/miniClassImage/shadowback.png"
            visible: false
        }

        MouseArea{
            id: continueBtn
            width: 260 * heightRate
            height: 74 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.centerIn: parent
            visible: false
            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/continue2.png" : "qrc:/miniClassImage/continue1.png"
            }

            onClicked: {
                setControlVisible(true);
                continueView.visible = false;
            }
        }

        Row{
            id: clickRowView
            width: parent.width * 0.8
            height: 30 * heightRates
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10 * heightRates
            visible: true

            MouseArea{
                width: parent.width  * 0.5
                height: parent.height * heightRates
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRates
                    color: "#ffffff"
                    border.color: "#cccccc"
                    border.width: 1
                }

                Text {
                    text: qsTr("退出教室")
                    color:  "#cccccc"
                    font.pixelSize: 14 * heightRates
                    font.family: Cfg.font_family
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigCancel();
                }
            }

            MouseArea{
                width: parent.width  * 0.5
                height: parent.height * heightRates
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRates
                    color: "#ff5000"
                    border.color: "#cccccc"
                    border.width: 1
                }

                Text {
                    text: qsTr("继续上课")
                    color:  "#ffffff"
                    font.pixelSize: 14 * heightRates
                    font.family: Cfg.font_family
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigContinue();
                }
            }
        }
    }

    Text {
        id: userNameText
        height: 45
        anchors.bottom: backView.bottom
        anchors.bottomMargin: 80 * heightRates
        anchors.horizontalCenter: backView.horizontalCenter
        font.pixelSize: 20 * heightRates
        font.family: "Microsoft YaHei"
        text: qsTr("您确认要继续上课吗？")
        wrapMode: Text.WordWrap
        visible: true
    }

    function setControlVisible(visible){
        clickRowView.visible = visible;
        userNameText.visible = visible;
    }

    //显示界面
    function showWindow(){
        continueView.visible = true;
    }

    //隐藏界面
    function hideWindow(){
        continueView.visible = false;
    }
}
