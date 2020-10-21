import QtQuick 2.0
import "./Configuuration.js" as Cfg

/*
*退出教室结束课程页面
*/

Item {
    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;

    signal sigFinishLesson();//结束课程信号
    signal sigExitRoom();
    signal sigClose();

    Item{
        id: backView
        width: 280 * widthRates
        height: 260 * heightRates
        anchors.centerIn: parent

        Image {
            anchors.fill: parent
            source: "qrc:/miniClassImage/TipsIcon.png"
        }

        MouseArea{
            width: 14 * heightRate
            height: 14 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.top: parent.top
            anchors.topMargin: 130 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 14 * heightRate

            Image{
                anchors.fill: parent
                source: "qrc:/miniClassImage/xbk_btn_close.png"
            }

            onClicked: {
                sigClose();
            }
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
                    text: qsTr("下课")
                    color:  "#cccccc"
                    font.pixelSize: 14 * heightRates
                    font.family: Cfg.font_family
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigFinishLesson();
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
                    text: qsTr("休息")
                    color:  "#ffffff"
                    font.pixelSize: 14 * heightRates
                    font.family: Cfg.font_family
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigExitRoom();
                }
            }
        }
    }

    Text {
        id: userNameText
        height: 45
        anchors.bottom: backView.bottom
        anchors.bottomMargin:  80 * heightRates
        anchors.horizontalCenter: backView.horizontalCenter
        font.pixelSize: 20 * heightRates
        font.family: "Microsoft YaHei"
        text: qsTr("您准备要下课还是休息？")
        wrapMode: Text.WordWrap
    }
}
