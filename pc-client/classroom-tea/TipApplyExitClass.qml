﻿import QtQuick 2.0
import "./Configuuration.js" as Cfg
/*
*申请退出教室页面
*/

Item {
    id: exitClassView

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property string userName: "";//用户名称

    signal sigRefuse();//拒绝信号
    signal sigOk();//确认信号

    Rectangle{
        id: backView
        width: 270 * heightRates * 0.9;
        height: 152 * heightRates * 0.9;
        radius:  6 * heightRates
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
                    border.color: "#cccccc"
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
                    exitClassView.visible = false;
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
                    text: qsTr("确认")
                    color:  "#ffffff"
                    font.pixelSize: 14 * heightRates
                    font.family: Cfg.font_family
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigOk();
                    exitClassView.visible = false;
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
            text: qsTr("申请退出教室")
            horizontalAlignment: Text.AlignHCenter
        }
        Row{
            //width: parent.width
            height: 25 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("学生 ")
                font.family: Cfg.font_family
                font.pixelSize: 12 * heightRates                
                wrapMode: Text.WordWrap
                color: "#666666"
            }

            Text {
                horizontalAlignment: Text.AlignHCenter
                text: userName
                font.family: Cfg.font_family
                font.pixelSize: 12 * heightRates
            }

            Text {
                horizontalAlignment: Text.AlignHCenter
                text: qsTr(" 申请临时退出教室")
                font.family: Cfg.font_family
                font.pixelSize: 12 * heightRates
                color: "#666666"
            }
        }
    }
    //显示界面
    function showWindow(){
        exitClassView.visible = true;
    }

    //隐藏界面
    function hideWindow(){
        exitClassView.visible = false;
    }
}

