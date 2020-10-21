import QtQuick 2.0
import "./Configuuration.js" as Cfg
/*
*音视频课件是否播放页面
*/

Item {
    id: lessonView

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    signal sigOk();//开始上课信号
    signal sigCancel();

    Rectangle{
        id: backView
        width: 280 * widthRates
        height: 220 * heightRates
        anchors.centerIn: parent
        border.color: "#eeeeee"
        border.width: 2 * heightRate
        radius: 12 * heightRate

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
                    text: qsTr("拒绝")
                    color:  "#cccccc"
                    font.pixelSize: 14 * heightRates
                    font.family: Cfg.font_family
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigCancel();
                    hideWindow();
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
                    text: qsTr("允许")
                    color:  "#ffffff"
                    font.pixelSize: 14 * heightRates
                    font.family: Cfg.font_family
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigOk();
                    hideWindow();
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
        text: qsTr("当前课程有音视频文件，是否允许播放?")
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

