import QtQuick 2.0
import "./Configuuration.js" as Cfg

/*
*是否评价提醒窗
*/

Item {

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    signal sigRefuse();//拒绝信号
    signal sigOk();//同意信号

    signal goWriteReport();//填写试听课报告

    Rectangle{
        id: backView
        width: 240 * widthRates;
        height: 160 * heightRates;
        radius:  6
        anchors.centerIn: parent
        color: "#ffffff"

        Row{
            width: parent.width * 0.8
            height: 35
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10 * heightRates

            MouseArea{
                width: parent.width  * 0.5
                height: parent.height
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRates
                    color: !currentIsAuditionLesson ? "#ffffff" : "#ff5000"
                    border.color: "#cccccc"
                    border.width: 1
                }

                Text {
                    text: currentIsAuditionLesson ? qsTr("去填写") : qsTr("取消")
                    color: !currentIsAuditionLesson ? "#cccccc" : "#ffffff"
                    font.pixelSize: 16 * heightRates
                    font.family: "Microsoft YaHei"
                    anchors.centerIn: parent
                }
                onClicked: {
                    if(currentIsAuditionLesson)
                    {
                        goWriteReport();
                        return;
                    }

                    sigRefuse();
                }
            }

            MouseArea{
                width: parent.width  * 0.5
                height: parent.height
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRates
                    color:  !currentIsAuditionLesson ? "#ff5000" : "#ffffff"
                    border.color: "#cccccc"
                    border.width: 1
                }

                Text {
                    text: qsTr("确定")
                    color:  !currentIsAuditionLesson ? "#ffffff" : "#cccccc"
                    font.pixelSize: 16 * heightRates
                    font.family: "Microsoft YaHei"
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigOk();
                }
            }
        }
    }

    Column{
        width: backView.width * 0.8
        height: backView.height
        anchors.top: backView.top
        anchors.topMargin: 45 * heightRates
        anchors.horizontalCenter: backView.horizontalCenter

        Text {
            width: parent.width
            height: 35 * heightRates
            horizontalAlignment: Text.AlignHCenter
            text:currentIsAuditionLesson ?  qsTr("试听课报告未填写，将无法生成课堂报告确定要结束课程？") : qsTr("还没有评价呢，确定要退出教室吗? ")
            font.family: "Microsoft YaHei"
            font.pixelSize: 13 * heightRates
            wrapMode: Text.WordWrap
            color: "#666666"
        }
    }
}
