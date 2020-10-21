import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import "Configuration.js" as Cfg

Rectangle {
    id: calendarMouseArea
    width: 1137 * heightRate * 0.75
    height: 497 * heightRate * 0.75
    color: "transparent"
    property string currentDaytext : "";

    signal dateTimeconfirm(var dateTime);
    signal sigMonthChange(var startDay , var endDay);
   Image {
        id: backImage
        anchors.fill: parent
        fillMode: Image.Stretch
        source: "qrc:/JrImage/lessonListBackground@3x.png"
    }

    Calendar{
        id: calendar
        width: parent.width - 18 * widthRate
        height: parent.height - 15 * widthRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter

        onVisibleMonthChanged:
        {
            sigMonthChange();
            console.log("ssssssssssssssss",visibleMonth,visibleYear)
        }

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
                    font.pixelSize: Cfg.CALENDAR_FONTSIZE * heightRate
                    font.family: Cfg.CALENDAR_FAMILY
                    anchors.horizontalCenter:  parent.horizontalCenter
                }
            }
            navigationBar: Rectangle {
                height: 40*heightRate
                color: "transparent"
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
                    font.pixelSize: Cfg.CALENDAR_FONTSIZE * heightRate
                    font.family: Cfg.CALENDAR_FAMILY
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: previousMonth.right
                    anchors.leftMargin: 2*widthRate
                    anchors.right: nextMonth.left
                    anchors.rightMargin: 2*widthRate
                    color: "#49ACFF"
                }
                MouseArea {
                    id: nextMonth
                    width: 10*widthRate
                    height: 10*widthRate
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

            dayDelegate: Rectangle {
                Rectangle
                {
                    width: 35 *　heightRate
                    height: width
                    anchors.centerIn: parent
                    radius: 1000 * heightRate
                    color: styleData.selected ? "#49ACFF" : "white"//(styleData.visibleMonth && styleData.valid ? "#444" : "#666");

                    Text {
                        text: styleData.date.getDate()
                        font.family:"Microsoft YaHei"
                        font.pixelSize: 14 * heightRate
                        anchors.centerIn: parent
                        color: styleData.selected ? "white" : (styleData.visibleMonth && styleData.valid ? "#333333" : "#999999")
                    }

                    Rectangle//有课标示框
                    {
                        width: 5 *　heightRate
                        height: width
                        anchors.bottom:parent.bottom
                        anchors.horizontalCenter:parent.horizontalCenter
                        radius: 10 * heightRate
                        color: "#49ACFF"
                        //visible: 函数查询当天是否有课
                    }
                }

            }

        }
        onClicked: {
            var year = date.getFullYear();
            var month = addZero(date.getMonth() + 1);
            var day = addZero(date.getDate());
            dateTimeconfirm(year + "/" + month + "/" + day);
            currentDaytext = month + "/" + day;
        }

    }
    Component.onCompleted:
    {
        var tempDate = new Date();
        var month = addZero(tempDate.getMonth() + 1);
        var day = addZero(tempDate.getDate());
        currentDaytext = month + "月" + day + "日";
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

