﻿import QtQuick 2.0
import "Configuuration.js" as Cfg

MouseArea {
    property string tips: "课程结束后无法再次进入教室，确认退出？";

    signal cancelConfirm();
    signal confirmed();

    hoverEnabled: true
    onWheel: {
        return;
    }

    Rectangle{
        width: 250 * widthRate
        height: 180 * heightRate
        color: "#ffffff"
        radius: 8*heightRate
        anchors.centerIn: parent

        Item{
            width: parent.width
            height: 40 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 30 * heightRate
            Text{
                text: tips
                anchors.centerIn: parent
                font.family: "Microsoft YaHei"
                font.pixelSize: 16 * tipDropClassroom.ratesRates
                color:"#222222"
            }
        }

        Row{
            width: parent.width*0.9
            height: 40*heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 12*widthRate
            MouseArea{
                width: parent.width * 0.5
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                Rectangle{
                    id: cancelItem
                    width: 92*widthRate
                    height: 43*heightRate
                    border.color: "#96999c"
                    border.width: 1
                    anchors.centerIn: parent
                    radius:4*heightRate
                    Text{
                        text: "取消"
                        anchors.centerIn: parent
                        font.family: "Microsoft YaHei"
                        font.pixelSize: 18 * tipDropClassroom.ratesRates
                        color:"#96999c"
                    }
                }
                onClicked: {
                    cancelConfirm();
                }
            }

            MouseArea{
                width: parent.width * 0.5
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                Rectangle{
                    id: confirmItem
                    width: 92*widthRate
                    height: 43*heightRate
                    color: "#ff5000"

                    anchors.centerIn: parent
                    radius:4*heightRate
                    Text{
                        text: "确定"
                        anchors.centerIn: parent
                        font.family: "Microsoft YaHei"
                        font.pixelSize: 18 * tipDropClassroom.ratesRates
                        color: "#ffffff"
                    }
                }
                onClicked: {
                    confirmed();
                }
            }
        }
    }
}

