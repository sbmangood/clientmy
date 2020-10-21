import QtQuick 2.0
import "./Configuuration.js" as Cfg
/*
*结束课程未达标提醒
*/
Item {
    id: courseMainView
    anchors.fill: parent

    property string lessonTotalTime: "00:00";
    property string lessonCurrentTime: "00:00";

    signal sigCancel();
    signal sigOk();

    Image{
        z: 1
        width: 140 * widthRates
        height: 110 * heightRates
        source: "qrc:/images/laba@2x.png"
        anchors.bottom: backView.top
        anchors.bottomMargin:  -(height * 0.5)
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle{
        id: backView
        width: 280 * widthRates;
        height: 380 * heightRates;
        radius:  6 * heightRates
        anchors.centerIn: parent
        color: "#ffffff"

        Text {
            id: tipText
            width: parent.width
            height: 45 * heightRate
            font.pixelSize: 24 * heightRate
            font.family: Cfg.font_family
            text: qsTr("-未达标提醒-")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.top: parent.top
            anchors.topMargin: 60 * heightRates
        }

        Text {
            id: tipContentText
            width: parent.width * 0.8
            height: 30 * heightRate
            font.pixelSize: 18 * heightRate
            font.family: Cfg.font_family
            text: qsTr("实际上课时长 未达到 课程总时长")
            anchors.top: tipText.bottom
            anchors.topMargin: 20 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#c6c6c6"
        }

        Row{
            id: totalText
            width: parent.width * 0.8
            height: 30 * heightRate
            anchors.top: tipContentText.bottom
            anchors.topMargin: 20 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                width: parent.width * 0.6
                font.pixelSize: 18 * heightRate
                font.family: Cfg.font_family
                text: qsTr("课程总时长:")
                color: "#c6c6c6"
            }

            Text {
                font.pixelSize: 18 * heightRate
                font.family: Cfg.font_family
                text: lessonTotalTime
            }
        }

        Row{
            id: currentTimeText
            width: parent.width * 0.8
            height: 30 * heightRate
            anchors.top: totalText.bottom
            anchors.topMargin: 20 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                width: parent.width * 0.6
                font.pixelSize: 18 * heightRate
                font.family: Cfg.font_family
                text: qsTr("实际上课时长:")
                color: "#c6c6c6"
            }

            Text {
                font.pixelSize: 18 * heightRate
                font.family: Cfg.font_family
                text:  lessonCurrentTime
            }
        }

        Rectangle{
            id: lineItem
            width: parent.width
            height: 1
            color: "gray"
            anchors.top: currentTimeText.bottom
            anchors.topMargin: 20 * heightRates
        }

        Text {
            id: descText
            width: parent.width
            height: 30 * heightRate
            font.pixelSize: 20 * heightRate
            font.family: Cfg.font_family
            text: qsTr("是否确定要结束课程？ ")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.top: lineItem.bottom
            anchors.topMargin: 30 * heightRates
        }

        Row {
            width: parent.width * 0.8
            height: 40 * heightRate
            anchors.top: descText.bottom
            anchors.topMargin: 20 * heightRates

            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10 * widthRates

            MouseArea{
                id: continueItem
                width: parent.width * 0.5
                height: parent.height
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    color: "#ff5000"
                    radius: 6 * heightRates
                }

                Text {
                    text: qsTr("确定")
                    font.family: Cfg.font_family
                    font.pixelSize: 14 * heightRates
                    anchors.centerIn: parent
                    color: "white"
                }

                onClicked: {
                    sigOk();
                }

            }

            MouseArea{
                width: parent.width * 0.5
                height: parent.height
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    border.width: 1
                    border.color: "gray"
                    radius: 6 * heightRates
                }

                Text {
                    text: qsTr("取消")
                    font.family: Cfg.font_family
                    font.pixelSize: 14 * heightRates
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigCancel();
                }
            }
        }

    }


}
