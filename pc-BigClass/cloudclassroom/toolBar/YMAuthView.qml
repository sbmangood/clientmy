import QtQuick 2.0
import "./Configuration.js" as Cfg

/*
*授权管理页面
*/

Item {
    id: authViews
    width: parent.width
    height: parent.height

    Rectangle{
        width: parent.width
        height: 34 * heightRate
        color: "#333333"
        opacity: 0.5
    }

    property int mirophon: 1;//0关闭 1开
    property int camera: 1;//0关闭 1开
    property int auth: 1;//0关闭 1开
    property int rewardNum: 1;//奖杯数量
    property string userIds: "";
    property string userType: "0";
    property int userRoles: 0;

    signal sigOperating(var userId,var operaType,var operaStatus);//操作信号 operaType: 1:麦克风 2:摄像头 3:授权 4:奖杯

    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
    }

    Row{
        width: parent.width - 40 * heightRate
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10 * heightRate

        MouseArea{
            width: 36 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
                width: 24 * heightRate
                height: 24 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 5 * heightRate
                source: mirophon== 0 ? "qrc:/toolBarImage/but_view_mike_enabled@2x.png" : (parent.containsMouse ? "qrc:/toolBarImage/but_view_mike_focused@2x.png" : "qrc:/toolBarImage/but_view_mike_normal@2x.png")
            }

            Text {
                z: 1
                color: "#ffffff"
                font.pointSize: 10 * heightRate
                font.family: Cfg.DEFAULT_FONT
                text: qsTr("麦克风")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 1 * heightRate
                visible:  parent.containsMouse ? true : false
            }

            Rectangle{
                width: 53 * heightRate
                height: 18 * heightRate
                color: "#000000"
                opacity: 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                visible:  parent.containsMouse ? true : false
                radius: 2 * heightRate
            }

            onClicked: {
                var mirophons = mirophon == 0 ? 1 : 0;
                sigOperating(userId,1,mirophons);
            }
        }

        MouseArea{
            width: 36 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
                width: 24 * heightRate
                height: 24 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 5 * heightRate
                source: camera == 0 ? "qrc:/toolBarImage/but_view_camera_enabled@2x.png" : (parent.containsMouse ? "qrc:/toolBarImage/but_view_camera_focused@2x.png" : "qrc:/toolBarImage/but_view_camera_normal@2x.png")
            }

            Text {
                z: 1
                color: "#ffffff"
                font.pointSize: 10 * heightRate
                font.family: Cfg.DEFAULT_FONT
                text: qsTr("摄像头")
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 1 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                visible:  parent.containsMouse ? true : false
            }

            Rectangle{
                width: 53 * heightRate
                height: 18 * heightRate
                color: "#000000"
                opacity: 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                visible:  parent.containsMouse ? true : false
                radius: 2 * heightRate
            }

            onClicked: {
                var cameras = camera == 0 ? 1 : 0;
                sigOperating(userId,2,cameras);
            }
        }

        MouseArea{
            width: 36 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            visible: userIds == "0" ? false : true

            Image{
                width: 24 * heightRate
                height: 24 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 5 * heightRate
                source: auth == 0 ? "qrc:/toolBarImage/but_view_warrant_enabled@2x.png" : (parent.containsMouse ? "qrc:/toolBarImage/but_view_warrant_focused@2x.png" : "qrc:/toolBarImage/but_view_warrant_normal@2x.png")
            }

            Text {
                z: 1
                color: "#ffffff"
                font.pointSize: 10 * heightRate
                font.family: Cfg.DEFAULT_FONT
                text: qsTr("授权")
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 1 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                visible:  parent.containsMouse ? true : false
            }

            Rectangle{
                width: parent.width
                height: 18 * heightRate
                color: "#000000"
                opacity: 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                visible:  parent.containsMouse ? true : false
                radius: 2 * heightRate
            }

            onClicked: {
                var auths = auth == 0 ? 1 : 0;
                sigOperating(userId,3,auths);
            }
        }

        MouseArea{
            width: 36 * heightRate
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            visible: userIds == "0" ? false : true

            Image{
                width: 24 * heightRate
                height: 24 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 5 * heightRate
                source: parent.containsMouse ? "qrc:/toolBarImage/but_view_cup_focused@2x.png" : "qrc:/toolBarImage/but_view_cup_normal@2x.png"
            }

            Text {
                z: 1
                color: "#ffffff"
                font.pointSize: 10 * heightRate
                font.family: Cfg.DEFAULT_FONT
                text: qsTr("奖杯")
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 1 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                visible:  parent.containsMouse ? true : false
            }

            Rectangle{
                width: parent.width
                height: 18 * heightRate
                color: "#000000"
                opacity: 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                visible:  parent.containsMouse ? true : false
                radius: 2 * heightRate
            }
            onClicked: {
                sigOperating(userId,4,1);
            }
        }
    }
}
