﻿import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import "../../Configuration.js" as Cfg

Popup {
    id: calendarMouseArea
    width: 260 * widthRate
    height: 340 * heightRate

    signal dateTimeconfirm(var dateTime);
    background:  Image {
        id: backImage
        anchors.fill: parent
        source: "qrc:/images/Rectanglecal.png"
        //fillMode: Image.PreserveAspectFit
    }

    Calendar{
        id: calendar
        width: parent.width - 23*widthRate
        height: parent.height-40*heightRate
        anchors.top: parent.top
        anchors.topMargin: 25*heightRate
        anchors.left: parent.left
        anchors.leftMargin: 19*heightRate

        style: CalendarStyle {
            gridVisible: false
            gridColor:"transparent"

            background: Rectangle
            {
                color:"transparent"
            }
            dayOfWeekDelegate: Item{//设置周的样式
                width: 25 * widthRate
                height: 20 * heightRate
                Text {
                    text: Qt.locale().dayName(styleData.dayOfWeek, control.dayOfWeekFormat)//转换为自己想要的周的内容的表达
                    font.family: Cfg.CALENDAR_FAMILY
                    font.pixelSize: Cfg.CALENDAR_FONTSIZE * heightRate
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            navigationBar: Item {
                height: 40*heightRate
                Rectangle {
                    color: "transparent"
                    height: 1
                    width: parent.width
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    height: 1
                    width: parent.width
                    color: "transparent" //color: "#ddd"
                }
                MouseArea {
                    id: previousMonth
                    width: 10*widthRate
                    height: 10*widthRate
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 60*widthRate
                    cursorShape: Qt.PointingHandCursor
                    Image {
                        anchors.fill: parent
                        source: "qrc:/images/cr_btn_lastpage_disable.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    //source: "images/leftanglearrow.png"
                    onClicked: control.showPreviousMonth()
                }
                Label {
                    id: dateText
                    text: styleData.title
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Cfg.CALENDAR_FAMILY
                    font.pixelSize: Cfg.CALENDAR_FONTSIZE * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: previousMonth.right
                    anchors.leftMargin: 2*widthRate
                    anchors.right: nextMonth.left
                    anchors.rightMargin: 2*widthRate
                }
                MouseArea {
                    id: nextMonth
                    width: 10 * widthRate
                    height: 10 * widthRate
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 60*widthRate
                    cursorShape: Qt.PointingHandCursor
                    Image {
                        anchors.fill: parent
                        source: "qrc:/images/cr_btn_nextpage_disable.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    // source: "images/rightanglearrow.png"
                    onClicked: control.showNextMonth()
                }
            }
        }

        onClicked:  {
            var year = date.getFullYear();
            var month = addZero(date.getMonth() + 1);
            var day = addZero(date.getDate());
            dateTimeconfirm(year + "-" + month + "-" + day);
            calendarMouseArea.close();
        }
    }

    function addZero(tmp){
        var fomartData;
        if(tmp < 10){
            fomartData = "0" + tmp;
        }else{
            fomartData = tmp;
        }
        return fomartData;
    }
}

