import QtQuick 2.0
import "./Configuuration.js" as Cfg

Item {
    id: tipCoursewareView
    width: parent.width
    height: parent.width

    property string suffix: "";
    property string fileId: "";

    Rectangle{
        anchors.fill: parent
        color: "#000000"
        opacity: 0.6
        z: 1
    }

    signal sigRefuse();//拒绝信号
    signal sigOk(var suffix,var fileId);//同意信号

    Rectangle{
        id: backView
        z: 2
        width: 240 * widthRates;
        height: 180 * heightRates;
        radius:  6
        anchors.centerIn: parent
        color: "#ffffff"

        Text {
            font.pixelSize: 18 * heightRate
            font.family: Cfg.DEFAULT_FONT
            text: qsTr("打开课件将开始上课")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.4 - height
        }

        Row{
            width: parent.width - 40
            height: 30 * heightRates
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: parent.width * 0.1

            MouseArea{
                width: parent.width  * 0.45
                height: parent.height * heightRates
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRates
                    color: "#fff3e9"
                    border.color: "#ff5000"
                    border.width: 1
                }

                Text {
                    text: qsTr("再等等")
                    color:  "#ff5000"
                    font.pixelSize: 16 * heightRates
                    font.family: Cfg.font_family
                    anchors.centerIn: parent
                }

                onClicked: {
                    sigRefuse();
                    tipCoursewareView.visible = false;
                }
            }

            MouseArea{
                width: parent.width  * 0.45
                height: parent.height * heightRates
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRates
                    color: "#ff5000"
                    border.color: "#ff5000"
                    border.width: 1
                }

                Text {
                    text: qsTr("确定")
                    color:  "#ffffff"
                    font.pixelSize: 16 * heightRates
                    font.family: Cfg.font_family
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigOk(suffix,fileId);
                    tipCoursewareView.visible = false;
                }
            }
        }
    }

}
