import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuration.js" as Cfg

/*
* 旁听账号进入教室提醒窗
*/

Item{
    id: listenView
    anchors.fill: parent

    property string teacherName: "";//上课老师名称
    property bool isShowLessonInfo: false;//是否显示课程信息
    property int fromStatus: -1;//调用此页面来源  1 为 课程表 2 为 课程列表


    signal sigConfirm(var status);

    Rectangle{
        color: "black"
        opacity: 0.4
        radius:  12 * widthRate
        anchors.fill: parent
    }

    Rectangle{
        z: 2
        width: 250 * widthRate
        height: 220 * heightRate
        color: "#ffffff"
        radius: 8*heightRate
        anchors.centerIn: parent

        Column{
            width: parent.width
            height: 80 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 50 * heightRate

            Text{
                width: parent.width
                text: teacherName + "老师正在上课，确定进入教室吗？"
                horizontalAlignment: Text.AlignHCenter
                font.family: Cfg.EXIT_FAMILY
                font.pixelSize: 18 * heightRate
                color:"#222222"
            }

            Text{
                width: parent.width
                text: "确定以后将以旁听身份进入教室"
                horizontalAlignment: Text.AlignHCenter
                font.family: Cfg.EXIT_FAMILY
                font.pixelSize: 16 * heightRate
                color:"gray"
            }
        }




        Row
        {
            width: parent.width * 0.9
            height: 80 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 150 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: parent.width * 0.1
            MouseArea{
                width: parent.parent.width * 0.4
                height: 40 * heightRate
                cursorShape: Qt.PointingHandCursor
                Rectangle{
                    width:parent.width
                    height: 43*heightRate
                    color: "#ff5000"

                    anchors.centerIn: parent
                    radius:4*heightRate
                    Text{
                        text: "取消"
                        anchors.centerIn: parent
                        font.family: Cfg.EXIT_FAMILY
                        font.pixelSize: Cfg.EXIT_BUTTON_FONTSIZE * heightRate
                        color: "#ffffff"
                    }
                }
                onClicked: {
                    listenView.visible = false;
                }
            }

            MouseArea{
                width: parent.parent.width * 0.4
                height: 40 * heightRate
                cursorShape: Qt.PointingHandCursor
                Rectangle{
                    id: confirmItem
                    width:parent.width
                    height: 43*heightRate
                    color: "#ff5000"

                    anchors.centerIn: parent
                    radius:4*heightRate
                    Text{
                        text: "确定"
                        anchors.centerIn: parent
                        font.family: Cfg.EXIT_FAMILY
                        font.pixelSize: Cfg.EXIT_BUTTON_FONTSIZE * heightRate
                        color: "#ffffff"
                    }
                }
                onClicked: {
                    listenView.visible = false;
                    sigConfirm(fromStatus);
                }
            }
        }
    }


}

