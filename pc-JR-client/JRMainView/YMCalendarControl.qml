import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import "Configuration.js" as Cfg

Rectangle {
    id: calendarMouseArea
    width: 1137 * heightRate * 0.75
    height: 527 * heightRate * 0.75
    color: "transparent"
    property string currentDaytext : "";
    property var currentMonthStartDate: new Date();
    property var currentMonthEndDate: new Date();
    property var currentVisibleDate: new Date();
    property var hasLessonDataLists: [];
    property bool hasSendTrueData: false;
    property bool isFirstClick: true;

    signal dateTimeconfirm(var dateTime);
    signal sigMonthChange(var startDate , var endDate, var currentVisibleDate);
    signal sigDayClick(var dayData);

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
        anchors.bottomMargin: 20 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter

        onVisibleMonthChanged:
        {
            // sigMonthChange();
            // console.log("ssssssssssssssss",visibleMonth,visibleYear)
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
                    color: "#858585"
                }
            }
            navigationBar: Rectangle {
                height: 60*heightRate
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
                    width: 15 * widthRate
                    height: 15 * widthRate
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: dateText.left
                    anchors.rightMargin: 20 * widthRate
                    cursorShape: Qt.PointingHandCursor
                    Image {
                        anchors.fill: parent
                        source: "qrc:/JrImage/zuo_nor@2x.png"
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
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 12 * widthRate
                    //anchors.right: nextMonth.left
                    //anchors.rightMargin: 2*widthRate
                    color: "#FF5500"
                }
                MouseArea {
                    id: nextMonth
                    width: 15 * widthRate
                    height: 15 * widthRate
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: dateText.right
                    anchors.leftMargin: 20*widthRate
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    Image {
                        anchors.fill: parent
                        source:  "qrc:/JrImage/you_nor@2x.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    // source: "images/rightanglearrow.png"
                    onClicked: control.showNextMonth()
                }
            }

            dayDelegate: Rectangle {
                property var hasLessonDataList: hasLessonDataLists;
                color: "transparent"
                //更新当月的课程日期,显示红色小圆点
                onHasLessonDataListChanged:
                {
                    hasLessonItem.visible = false;
                    for(var a = 0; a < hasLessonDataList.length; a ++)
                    {
                        var year = styleData.date.getFullYear();
                        var month = addZero(styleData.date.getMonth() + 1);
                        var day = addZero(styleData.date.getDate());
                        var tempDateString = year + "-" + month + "-" + day;
                        //如果日历中日期与有课日期相同
                        if(hasLessonDataList[a] == tempDateString)
                        {
                            hasLessonItem.visible = true;
                            break;
                        }
                    }
                }

                Rectangle
                {
                    width: 35 *　heightRate
                    height: width
                    anchors.centerIn: parent
                    radius: 1000 * heightRate
                    color: styleData.selected ? "#FF5500" : "white"//(styleData.visibleMonth && styleData.valid ? "#444" : "#666");
                    onColorChanged:
                    {
                        //该日期被选中时
                        if(styleData.selected)
                        {
                            var year = styleData.date.getFullYear();
                            var month = addZero(styleData.date.getMonth() + 1);
                            var day = addZero(styleData.date.getDate());
                            currentDaytext = month + "-" + day;
                            sigDayClick(year + "/" + month + "/" + day);
                        }
                    }
                    //显示日期的day
                    Text {
                        text:  {
                            if(new Date().toLocaleDateString() === styleData.date.toLocaleDateString())
                                return "今天"
                            return  styleData.date.getDate()
                        }
                        font.family:"Microsoft YaHei"
                        font.pixelSize: 14 * heightRate
                        anchors.centerIn: parent
                        color: styleData.selected ? "white" : (styleData.visibleMonth && styleData.valid ? "#858585" : "#C9C9C9")
                        onTextChanged:
                        {
                            if(styleData.visibleMonth)
                            {
                                currentVisibleDate = styleData.date;
                            }

                            if(styleData.index == 0)
                            {
                                currentMonthStartDate = styleData.date;
                            }else if(styleData.index == 41)
                            {
                                currentMonthEndDate = styleData.date;
                                sigMonthChange( currentMonthStartDate , currentMonthEndDate , currentVisibleDate);
                            }

                        }
                    }

                    Rectangle//有课标示框
                    {
                        id:hasLessonItem
                        width: 5 *　heightRate
                        height: width
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: 10 * heightRate
                        color: "#FF5500"
                        visible: false
                    }
                }
            }

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

