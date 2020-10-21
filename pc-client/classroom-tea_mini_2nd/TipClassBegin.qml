import QtQuick 2.0
import "./Configuuration.js" as Cfg
/*
*开始上课页面
*/

Item {
    id: lessonView

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property string userName: "";//用户名称
    property bool disableButton: true;
    property string currentTips: "注:当前教室内如有操作将被清空";//

    signal sigStartLesson();//开始上课信号
    signal sigCancel();

    onVisibleChanged: {
        if(visible){
            disableButton = true;
        }else{
            disableButton = false;
        }
    }

    Item{
        id: backView
        width: 280 * widthRates
        height: 260 * heightRates
        anchors.centerIn: parent

        Image{
            anchors.fill: parent
            source: "qrc:/miniClassImage/TipsIcon.png"
        }

        Row{
            width: parent.width * 0.8
            height: 30 * heightRates
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10 * heightRates

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
                    text: qsTr("取消")
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
                    text: qsTr("确认")
                    color:  "#ffffff"
                    font.pixelSize: 14 * heightRates
                    font.family: Cfg.font_family
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigStartLesson();
                }
            }
        }
    }

    Text {
        id: tipText
        height: 45
        anchors.bottom: backView.bottom
        anchors.bottomMargin: 80 * heightRates
        anchors.horizontalCenter: backView.horizontalCenter
        text: qsTr("您确认要开始上课吗？")
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 16 * heightRates
    }

    //显示界面
    function showWindow(){
        lessonView.visible = true;
    }

    //隐藏界面
    function hideWindow(){
        lessonView.visible = false;
    }
}

