import QtQuick 2.0
import QtQuick.Controls 2.0
import"./Configuuration.js" as Cfg

/**
*@brief 小组课信息展示页面
*@date  2019-05-13
*/

Popup {
    id: lessonClassInfoView
    width:  300 * heightRate
    height: 156 * heightRate

    property string lessonName: "此处显示此课程的完整名称，允许换行。";
    property string lessonTime: "9:30-12:00";
    property string lessonTea: "李老师";
    property string lessonId: "242330488922968064";

    background: Image{
        anchors.fill: parent
        source: "qrc:/miniClassImage/shadowback.png"
    }

    Column{
        width: parent.width -20
        height: parent.height - 20
        anchors.top: parent.top
        anchors.topMargin: 10 * heightRate
        spacing: 10 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter

        Row{
            width: parent.width
            spacing: 4 * heightRate

            Image{
                id: imgOne
                width: 20 * heightRate
                height: 20 * heightRate
                source: "qrc:/miniClassImage/xb_yunjiaoshi_name@2x.png"
            }

            Text {
                id: lessonTxt
                text: qsTr("课节名称：")
                color: "#666666"
                font.pixelSize: 14 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }

            Text {
                text: lessonName
                width: parent.width - lessonTxt.width - imgOne.width
                color: "#333333"
                font.pixelSize: 14 * heightRate
                font.family: Cfg.DEFAULT_FONT
                wrapMode: Text.WordWrap
                onHeightChanged: {
                    lessonClassInfoView.height += height * 0.5;
                }
            }
        }

        Row{
            width: parent.width
            spacing: 4 * heightRate

            Image{
                width: 20 * heightRate
                height: 20 * heightRate
                source: "qrc:/miniClassImage/xb_yunjiaoshi_time@2x.png"
            }

            Text {
                text: qsTr("上课时段：")
                color: "#666666"
                font.pixelSize: 14 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }

            Text {
                text: lessonTime
                color: "#333333"
                font.pixelSize: 14 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }
        }

        Row{
            width: parent.width
            spacing: 4 * heightRate

            Image{
                width: 20 * heightRate
                height: 20 * heightRate
                source: "qrc:/miniClassImage/xb_yunjiaoshi_teacher@2x.png"
            }

            Text {
                text: qsTr("授课老师：")
                color: "#666666"
                font.pixelSize: 14 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }

            Text {
                text: lessonTea
                color: "#333333"
                font.pixelSize: 14 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }
        }

        Row{
            width: parent.width
            spacing: 4 * heightRate

            Image{
                width: 20 * heightRate
                height: 20 * heightRate
                source: "qrc:/miniClassImage/xb_yunjiaoshi_crid@2x.png"
            }

            Text {
                text: qsTr("教室ID：    ")
                color: "#666666"
                font.pixelSize: 14 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }

            Text {
                text: lessonId
                color: "#333333"
                font.pixelSize: 14 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }
        }

    }
}
