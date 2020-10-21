import QtQuick 2.0
import "Configuration.js" as Cfg
/*********菜单栏个人顾问信息页面**********/

MouseArea {
    id: personalView
    hoverEnabled: true
    onWheel: {
        return;
    }

    property var linkDataInfo: [];
    property string teacherMobile: ""
    property string adviserMobile: ""

    onLinkDataInfoChanged: {
        if(linkDataInfo == null || linkDataInfo.data == undefined){
            return
        }

        var data = linkDataInfo.data;
        teacherMobile = data.crInfo.userMobile;
        adviserMobile = data.ccInfo.userMobile;
    }

    Rectangle{
        anchors.fill: parent
        color: "black"
        opacity: 0.4
        radius: 12 * widthRate
    }

    Rectangle{
        id: bgItem
        width: 240 * widthRate
        height: 260 * heightRate
        radius: 12 * widthRate
        color: "white"
        anchors.centerIn: parent

        MouseArea{
            z: 2
            width: 25 * heightRate
            height: 25 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 5 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 5 * heightRate
            cursorShape: Qt.PointingHandCursor
            Image{
                anchors.fill: parent
                source: "qrc:/images/alert_worktime_close.png"
            }
            onClicked: {
                personalView.visible = false;
            }
        }

        Image{
            id: headImage
            width: parent.width
            height: parent.height * 0.35
            source: "qrc:/images/alert_worktime_bg.png"
        }

        Text{
            id: workText
            text: "工作时间"
            color: "#606076"
            font.family: Cfg.HEAD_FAMILY
            font.pixelSize: Cfg.HEAD_FONTSIZE * heightRate
            anchors.top: parent.top
            anchors.topMargin:  parent.height * 0.08
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text{
            text: "09:00-21:00"
            color: "#606076"
            font.family: Cfg.HEAD_FAMILY
            font.pixelSize: Cfg.HEAD_FONTSIZE * heightRate
            anchors.top: workText.bottom
            anchors.topMargin: 5 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Column{
            id: columnItem
            width: parent.width
            height:  parent.height * 0.3
            anchors.top: headImage.bottom
            anchors.topMargin: {
                if(adviserMobile == "" || teacherMobile == ""){
                    return 40 * heightRate
                }
                return 20 * heightRate
            }
            spacing: 10 * heightRate

            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                visible: adviserMobile == "" ? false : true
                Text{
                    height: 14 * widthRate
                    text: "课程顾问："
                    color:"#96999c"
                    font.family: Cfg.HEAD_FAMILY
                    font.pixelSize: Cfg.HEAD_FONTSIZE * heightRate
                }
                Text{
                    height: 14 * widthRate
                    text: adviserMobile
                    font.family: Cfg.HEAD_FAMILY
                    font.pixelSize: Cfg.HEAD_FONTSIZE * heightRate
                }
            }

            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                visible:  teacherMobile == "" ? false : true
                Text{
                    height: 14 * widthRate
                    text: "班 主 任："
                    color:"#96999c"
                    font.family: Cfg.HEAD_FAMILY
                    font.pixelSize: Cfg.HEAD_FONTSIZE * heightRate
                }

                Text{
                    height: 14 * widthRate
                    text: teacherMobile
                    width: 110 * heightRate
                    font.family: Cfg.HEAD_FAMILY
                    font.pixelSize: Cfg.HEAD_FONTSIZE * heightRate
                }
            }
        }

        Rectangle{
            id: okButton
            width: parent.width * 0.9
            height: 40 * heightRate
            anchors.bottom:  parent.bottom
            anchors.bottomMargin: 20 * heightRate
            //radius: 6
            anchors.horizontalCenter: parent.horizontalCenter
            Image{
                anchors.fill: parent
                source: "qrc:/images/btn_jianbian.png"
            }

            Text{
                text: "确定"
                color: "white"
                font.family: Cfg.HEAD_FAMILY
                font.pixelSize: (Cfg.HEAD_FONTSIZE) * heightRate
                anchors.centerIn: parent
            }

            MouseArea{
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    personalView.visible = false;
                }
            }
        }
    }
}

