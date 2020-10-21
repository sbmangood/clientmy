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
        visible: false
    }

    Rectangle{
        id: backView
        width: 360.0 * widthRates * 0.65
        height: 343.0 * widthRates * 0.65
        radius:  6 * heightRates
        anchors.centerIn: parent
        color: "#ffffff"


        Rectangle
        {
            id:midBackView
            width: 328 * widthRates * 0.65
            height: 205 * widthRates * 0.65
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 16 * widthRates * 0.65
            radius: 5 * widthRates
            color: "#FFFAD9"

            Text {
                id: tipText
                font.pixelSize: 13 * heightRate
                font.family: Cfg.font_family
                text: qsTr("未达标提醒")
                anchors.top: parent.top
                anchors.topMargin: 16 * widthRates * 0.65
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#C9930C"
                font.bold: true
            }

            Text {
                id: tipContentText
                font.pixelSize: 12 * heightRate
                font.family: Cfg.font_family
                text: qsTr("实际上课时长 未达到 课程总时长")
                anchors.top: tipText.bottom
                anchors.topMargin: 5 * heightRates
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#C9930C"
            }
            Image{
                z: 1
                width: parent.width
                height: width / ( 656 / 6 )
                source: "qrc:/newStyleImg/groupMid@2x.png"
                anchors.top: tipContentText.bottom
                anchors.topMargin:  22 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Row{
                id: totalText
                height: 20 * heightRate
                anchors.top: tipContentText.bottom
                anchors.topMargin: 40 * heightRates
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    font.pixelSize: 12 * heightRate
                    font.family: Cfg.font_family
                    text: qsTr("课程总时长:  ")
                    color: "#C9930C"
                    font.bold: true
                }

                Text {
                    font.pixelSize: 12 * heightRate
                    font.family: Cfg.font_family
                    text: lessonTotalTime
                    color: "#C9930C"
                }
            }

            Row{
                id: currentTimeText
                anchors.top: totalText.bottom
                anchors.topMargin: 10 * heightRates
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    font.pixelSize: 12 * heightRate
                    font.family: Cfg.font_family
                    text: qsTr("实际上课时长:  ")
                    color: "#C9930C"
                    font.bold: true
                }

                Text {
                    font.pixelSize: 12 * heightRate
                    font.family: Cfg.font_family
                    text:  lessonCurrentTime
                    color: "#C9930C"
                }
            }

        }

        Text {
            id: descText
            width: parent.width
            height: 30 * heightRate
            font.pixelSize: 12 * heightRate
            font.family: Cfg.font_family
            text: qsTr("是否确定要结束课程？ ")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.top: midBackView.bottom
            anchors.topMargin: 20 * heightRates * 0.65
        }

        Row {
            width: parent.width * 0.925
            height: 40 * heightRate
            anchors.top: descText.bottom
            anchors.topMargin: 10 * heightRates

            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10 * widthRates

            MouseArea{
                id: continueItem
                width: 158 * widthRates * 0.65
                height: 34 * widthRates * 0.65
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    color: "#ff5000"
                    radius: 4 * heightRates
                }

                Text {
                    text: qsTr("确定")
                    font.family: Cfg.font_family
                    font.pixelSize: 11 * heightRates
                    anchors.centerIn: parent
                    color: "white"
                }

                onClicked: {
                    sigOk();
                }

            }

            MouseArea{
                width: 158 * widthRates * 0.65
                height: 34 * widthRates * 0.65
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    border.width: 1
                    border.color: "gray"
                    radius: 4 * heightRates
                }

                Text {
                    text: qsTr("取消")
                    font.family: Cfg.font_family
                    font.pixelSize: 11 * heightRates
                    anchors.centerIn: parent
                    color: "#333333"
                }
                onClicked: {
                    sigCancel();
                }
            }
        }

    }


}
