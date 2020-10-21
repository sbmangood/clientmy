import QtQuick 2.0
import  "./Configuuration.js" as Cfg
/*
*申请翻页权限页面
*/

Item {
    id: roleView

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property string userName: "";//用户名称

    signal sigRefuse();//拒绝信号
    signal sigOk();//同意信号

    Rectangle{
        id: backView
        width: 270 * heightRates * 0.9;
        height: 152 * heightRates * 0.9;
        radius:  6
        anchors.centerIn: parent
        color: "#ffffff"

        Row{
            width: parent.width * 0.88
            height: 37 * heightRates
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 6 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10 * heightRates

            MouseArea{
                width: 115 * heightRates * 0.88
                height: 34 * heightRates * 0.88
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRates
                    color: "#ffffff"
                    border.color: "#999999"
                    border.width: 1
                }

                Text {
                    text: qsTr("拒绝")
                    color:  "#666666"
                    font.pixelSize: 14 * heightRates
                    font.family: Cfg.font_family
                    anchors.centerIn: parent
                }

                onClicked: {
                    sigRefuse();
                }
            }

            MouseArea{
                width: 115 * heightRates * 0.88
                height: 34 * heightRates * 0.88
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRates
                    color: "#ff5000"
                }

                Text {
                    text: qsTr("同意")
                    color:  "#ffffff"
                    font.pixelSize: 14 * heightRates
                    font.family: Cfg.font_family
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
        anchors.topMargin: 16 * heightRates
        anchors.horizontalCenter: backView.horizontalCenter
        spacing: 10 * heightRates

        Text {
            id: userNameText
            height: 25 * heightRates
            width: parent.width
            font.pixelSize: 20 * heightRates
            font.family: "Microsoft YaHei"
            text: qsTr("申请权限")
            horizontalAlignment: Text.AlignHCenter
        }

        Text{
            width: parent.width
            height: 25 * heightRates
            text: "学生 <strong>" + userName + "</strong> 正在申请翻页权限"
            wrapMode: Text.WordWrap
            font.family: Cfg.font_family
            font.pixelSize: 12 * heightRates
            color: "#333333"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    //显示界面
    function showWindow(){
        roleView.visible = true;
    }

    //隐藏界面
    function hideWindow(){
        roleView.visible = false;
    }
}

