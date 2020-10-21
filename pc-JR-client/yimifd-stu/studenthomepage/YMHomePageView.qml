﻿import QtQuick 2.0
import QtQuick.Controls 1.4
import YMLessonManagerAdapter 1.0
import "../Configuration.js" as Cfg

/***课程表***/
Item{
    id: homePageView
    focus: true

    property var timeSchedule: [];
    property var currentDate: [];//当前日期
    property int columnWidth: (width -5) / 8;
    property int currentDateIndex: -1;

    property string keywords: "";//搜索传递参数，必须要
    signal transferPage(var pram);//页面传值信号，必须要

    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Up:
            if(filckable.contentY > 0) {
                filckable.contentY -= 20;
            }
            break;
        case Qt.Key_Down:
            if(button.y<scrollbar.height-button.height){
                filckable.contentY += 20;
            }
            break;
        default:
            return;
        }
        event.accepted = true
    }

    YMLoadingStatuesView{
        id: lodingView
        z:88
        anchors.fill: parent
        visible: false
    }

    YMLessonManagerAdapter{
        id: lessonMgr

        //显示错误提示对话框
        onSigMessageBoxInfo:
        {
            console.log("=======YMHomePageView.qml onSigMessageBoxInfo========");
            windowView.showMessageBox(strMsg);
        }

        onStudentLessonInfoChanged:{
            if(lessonInfo.data === undefined || lessonInfo.data == ""){
                netRequest.visible = true;
                return;
            }
            filckable.visible = true;
            netRequest.visible = false;
            currentDateIndex = -1;
            var dateOfWeek = lessonInfo.data.dateOfWeek;
            timeSchedule = lessonInfo.data.timeSchedule;
            dateControl.dateOfWeek = dateOfWeek;
            getWeekIndex(dateOfWeek);
            updateLessonModel(lessonInfo.data.lessonSchedules,lessonInfo.data.timeRule);
        }
        onLodingFinished:{
            lodingView.startFadeOut();
        }
        onRequestTimerOut:{
            clearModel();
            filckable.visible = false;
            lodingView.startFadeOut();
            netRequest.visible = true;
        }
        onSigRepeatPlayer: {
            massgeTips.tips = "录播暂未生成，请在课程结束半小时后进行查看!";
            massgeTips.visible = true;
        }
    }

    YMCalendarControl{
        id: calendar
        z: 99999
        visible: false
        onDateTimeconfirm: {
            seachLessonData(dateTime)
        }
    }

    //网络显示提醒
    YMInterNetView{
        id: netRequest
        z: 666
        anchors.fill: parent
        visible: false
    }

    //课程表样式
    Item{
        id: lessonItem
        z: 44
        width: parent.width
        height: 120 * heightRate
        anchors.top: parent.top

        Row{
            id: headRow
            width: 195 * widthRate
            height: 60 * heightRate
            spacing: 0
            anchors.left: parent.left
            anchors.leftMargin: 20 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 22 * heightRate

            //信息提醒图标
            MouseArea{
                width: 20 * widthRate
                height: parent.height * 0.56
                cursorShape: Qt.PointingHandCursor
                Image{
                    width: 16 * widthRate
                    height: 16 * widthRate
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    source: parent.pressed ? "qrc:/images/btn_i_sed@2x.png" : "qrc:/images/btn_i@2x.png"
                }
                onClicked: {
                    lessonDescribe.visible = true
                    lessonDescribe.startFadeOut();
                }
            }

            Text{
                width: 70 * widthRate
                text: "课程表"
                height: parent.height * 0.5
                font.family: Cfg.LESSON_FONT_FAMILY
                font.pixelSize:  Cfg.LESSON_HEAD_FONT_SIZE * heightRate
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea{
                width: 20 * widthRate
                height: 20 * widthRate
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: parent.pressed ? "qrc:/images/btn_calendar_pageup_sed@2x.png" :  "qrc:/images/btn_calendar_pageup@2x.png"
                }
                onClicked: {
                    var date = new Date(dateControl.year +"-"+dateControl.week7)
                    date.setDate(date.getDate() - 7);
                    var month = date.getMonth() + 1;
                    currentDate = date.getFullYear() + '-' + Cfg.addZero(month) + '-' + Cfg.addZero(date.getDate());
                    seachLessonData(currentDate);
                }
            }
            MouseArea{
                id: calendarButton
                width: 60 * widthRate
                height: 20 * widthRate
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: parent.pressed ? "qrc:/images/btn_calendar_sed@2x.png" : "qrc:/images/btn_calendar@2x.png"
                }

                onClicked: {
                    var location = contentItem.mapFromItem(calendarButton,0,0);
                    calendar.x = location.x - calendar.width - 25 * widthRate;
                    calendar.y = location.y - 35 * heightRate;
                    calendar.open();
                }
            }
            MouseArea{
                width: 20 * widthRate
                height: 20 * widthRate
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    smooth: true
                    source: parent.pressed ? "qrc:/images/btn_calendar_pagedown_sed@2x.png" : "qrc:/images/btn_calendar_pagedown@2x.png"
                }
                onClicked: {
                    var date = new Date(dateControl.year +"-"+ dateControl.week7)
                    date.setDate(date.getDate()+ 7);
                    var month = date.getMonth() + 1;
                    currentDate = date.getFullYear() + '-' + Cfg.addZero(month) + '-' + Cfg.addZero(date.getDate());
                    seachLessonData(currentDate);
                }
            }
        }

        MouseArea{
            width: 20 * widthRate
            height: 20 * widthRate
            anchors.left: headRow.right
            anchors.top: parent.top
            anchors.topMargin: 22 * heightRate
            cursorShape: Qt.PointingHandCursor
            enabled: lodingView.visible == false
            Image{
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                verticalAlignment: Image.AlignVCenter
                source: parent.pressed ?  "qrc:/images/calendar_today_sed@2x.png" : "qrc:/images/btn_calendar_today@2x.png"
            }
            onClicked: {
                currentDate = Cfg.getCurrentDates();
                seachLessonData(currentDate);
            }
        }

        MouseArea{
            width: 120 * widthRate
            height: 30 * heightRate
            hoverEnabled: true
            anchors.right: parent.right
            cursorShape: Qt.PointingHandCursor
            anchors.top:parent.top
            anchors.topMargin: 20 * heightRate
            Text{
                width: 120 * widthRate
                height: 35 * heightRate
                text: "查看全部课程 >"
                font.family: Cfg.LESSON_FONT_FAMILY
                font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
                color:"#3c3c3e"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            onClicked: {
                windowView.transferPage(1,0);
            }
        }

        YMHomePageDateControl{
            id: dateControl
            width: parent.width
            height: parent.height * 0.2
            anchors.top: headRow.bottom
            contentWidth: columnWidth
        }
    }

    Rectangle{
        width: lessonItem.width
        z:38
        height: 1
        color: "#e3e6e9"
        anchors.top: lessonItem.bottom
        anchors.horizontalCenter: lessonItem.horizontalCenter
    }

    Flickable{
        id: filckable
        width: parent.width -10
        height: parent.height - lessonItem.height
        contentWidth: width
        contentHeight: lessonModel.count * 240 * heightRate
        anchors.top: lessonItem.bottom
        anchors.topMargin: 2*heightRate
        clip: true;

        ListView{
            id: lessonListView
            clip: true
            anchors.fill: parent
            model: lessonModel
            delegate: lessonDelegate
        }
    }
    //滚动条
    Item {
        id: scrollbar
        width: 8
        height: filckable.height
        anchors.left: filckable.right
        anchors.top: lessonItem.bottom
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: filckable.visibleArea.yPosition * scrollbar.height
            width: 6
            height: filckable.visibleArea.heightRatio * scrollbar.height - 30;
            color: "#cccccc"
            radius: 4 * widthRate

            // 鼠标区域
            MouseArea {
                id: mouseArea
                anchors.fill: button
                drag.target: button
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: scrollbar.height - button.height

                // 拖动
                onMouseYChanged: {
                    filckable.contentY = button.y / scrollbar.height * filckable.contentHeight
                }
            }
        }
    }

    ListModel{
        id: lessonModel
    }

    //课程表Delegate
    Component{
        id: lessonDelegate
        Item{
            width: lessonListView.width
            height: 240 * heightRate

            Rectangle{
                width: columnWidth
                height: lessonListView.height
                color: "#f3f9ff"
                opacity: 0.4
                visible: (currentDateIndex != -1)
                x: currentDateIndex * columnWidth
            }

            Row{
                anchors.fill: parent
                Item{
                    width: columnWidth
                    height: parent.height
                    Text{
                        text: time
                        font.family: Cfg.LESSONINFO_FAMILY
                        font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
                        anchors.centerIn: parent
                    }

                    Rectangle{
                        width: 1
                        height: parent.height
                        color: "#e3e6e9"
                        anchors.right: parent.right
                    }
                }

                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    lessonData: lessonInfo1
                    timeSchedule: homePageView.timeSchedule
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    lessonData: lessonInfo2
                    timeSchedule: homePageView.timeSchedule
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    lessonData: lessonInfo3
                    timeSchedule: homePageView.timeSchedule
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    lessonData: lessonInfo4
                    timeSchedule: homePageView.timeSchedule
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    lessonData: lessonInfo5
                    timeSchedule: homePageView.timeSchedule
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    lessonData: lessonInfo6
                    timeSchedule: homePageView.timeSchedule
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    lessonData: lessonInfo7
                    timeSchedule: homePageView.timeSchedule
                }
            }

            Rectangle{
                width: parent.width - 4*widthRate
                height: 1
                // visible: index ==2 ? false : true
                color: "#e0e0e0"
                anchors.bottom: parent.bottom
            }
        }
    }

    Component.onCompleted: {
        for(var i = 1;i < 4; i++){
            var am = "上午"
            if(i == 2){
                am = "下午"
            }
            if(i ==3){
                am = "晚上"
            }
            lessonModel.append({
                                   "time": am,
                                   "amorpm": i,
                                   "lessonInfo1":[],
                                   "lessonInfo2":[],
                                   "lessonInfo3":[],
                                   "lessonInfo4":[],
                                   "lessonInfo5":[],
                                   "lessonInfo6":[],
                                   "lessonInfo7":[],
                               })
        }
        currentDate = Cfg.getCurrentDates();
    }

    function refreshPage(){
        console.log("YMHomePageView")
        netRequest.visible = false;
        seachLessonData(currentDate);
    }

    function seachLessonData(dateTime){
        lodingView.visible = true;
        lodingView.tips = "页面加载中"
        currentDate = dateTime;
        lessonMgr.getStudentLessonInfo(dateTime);
    }

    //菜单栏中继承的参数
    function queryData(){
        netRequest.visible = false;
        seachLessonData(currentDate);
    }

    //显示课程表
    function updateLessonModel(lessonSchedules,timeRule){
        //解析数据逻辑
        //1、判断课程是上午、下午、晚上，增加标志 1为上午、2下午、3晚上
        //2、判断当前数据属于哪一列，然后根据列显示数据
        //3、给当前列进行赋值传递参数
        var bufferData = [];
        var vdate = [];

        for(var i = 0; i < lessonSchedules.length;i++){
            var relateType = lessonSchedules[i].relateType;
            var lessonType = lessonSchedules[i].lessonType;
            var startTime = lessonSchedules[i].startTime;
            var endTime = lessonSchedules[i].endTime;
            var mark = gettimeRule(timeRule,startTime,endTime);
            var lessonData = lessonSchedules[i];

            if(mark == 1){
                bufferData.push({
                                    amorpm: 1,
                                    lessonInfo: lessonData,
                                })
            }
            if(mark == 2){
                bufferData.push({
                                    amorpm: 2,
                                    lessonInfo: lessonData,
                                })
            }
            if(mark == 3){
                bufferData.push({
                                    amorpm: 3,
                                    lessonInfo: lessonData,
                                })
            }
        }

        for(var z = 0; z < lessonModel.count; z++){
            var lessonInfoData1 = [];
            var lessonInfoData2 = [];
            var lessonInfoData3 = [];
            var lessonInfoData4 = [];
            var lessonInfoData5 = [];
            var lessonInfoData6 = [];
            var lessonInfoData7 = [];
            for(var k = 0; k < bufferData.length;k++){
                var amorpm = bufferData[k].amorpm;
                var lessonInfoData = bufferData[k].lessonInfo;
                if(lessonModel.get(z).amorpm == amorpm){
                    if(lessonInfoData.dateId == 0){
                        lessonInfoData1.push(lessonInfoData);
                        continue;
                    }
                    if(lessonInfoData.dateId == 1){
                        lessonInfoData2.push(lessonInfoData);
                        continue;
                    }
                    if(lessonInfoData.dateId == 2){
                        lessonInfoData3.push(lessonInfoData);
                        continue;
                    }
                    if(lessonInfoData.dateId == 3){
                        lessonInfoData4.push(lessonInfoData);
                        continue;
                    }
                    if(lessonInfoData.dateId == 4){
                        lessonInfoData5.push(lessonInfoData);
                        continue;
                    }
                    if(lessonInfoData.dateId == 5){
                        lessonInfoData6.push(lessonInfoData);
                        continue;
                    }
                    if(lessonInfoData.dateId == 6){
                        lessonInfoData7.push(lessonInfoData);
                        continue;
                    }
                }
            }
            lessonModel.get(z).lessonInfo1 = lessonInfoData1;
            lessonModel.get(z).lessonInfo2 = lessonInfoData2;
            lessonModel.get(z).lessonInfo3 = lessonInfoData3;
            lessonModel.get(z).lessonInfo4 = lessonInfoData4;
            lessonModel.get(z).lessonInfo5 = lessonInfoData5;
            lessonModel.get(z).lessonInfo6 = lessonInfoData6;
            lessonModel.get(z).lessonInfo7 = lessonInfoData7;
        }
    }

    //时间戳计算
    function gettimeRule(timeRule,startTime,endTime){
        var sDate = new Date(startTime);
        var eDate = new Date(endTime);

        var startDate = Cfg.addZero(sDate.getHours()) + ":" + Cfg.addZero(sDate.getMinutes());
        var endDate = Cfg.addZero(eDate.getHours()) + ":" + Cfg.addZero(eDate.getMinutes());

        if(startDate == "00:00" && endDate == "23:59"){
            return 1;
        }

        var spaceSDate = new Date("2017-01-01 " + startDate)
        var spaceEDate = new Date("2017-01-01 " + endDate)

        var morning = timeRule.morning;
        var afternoon = timeRule.afternoon;
        var night = timeRule.night;

        var morningArray = morning.split("-");
        var morningsSpace = new Date("2017-01-01 " + morningArray[0]);
        var morningeSpace = new Date("2017-01-01 " + morningArray[1]);

        if(spaceSDate.getTime() < morningeSpace.getTime()){
            return 1;
        }

        var afternoonArray = afternoon.split("-");
        var afternoonsSpace = new Date("2017-01-01 " + afternoonArray[0]);
        var afternooneSpace = new Date("2017-01-01 " + afternoonArray[1]);

        if(spaceSDate.getTime() < afternooneSpace.getTime()){
            return 2;
        }
        var nightArray =  night.split("-");
        var nightsSpace = new Date("2017-01-01 " + nightArray[0]);
        var nighteSpace = new Date("2017-01-01 " + nightArray[1]);

        if(spaceSDate.getTime() < nighteSpace.getTime()){
            return 3
        }

    }

    //查询数据时清除上一次记录
    function clearModel(){
        for(var i = 0; i < lessonModel.count; i++){
            lessonModel.get(i).lessonInfo1 = [];
            lessonModel.get(i).lessonInfo2 = [];
            lessonModel.get(i).lessonInfo3 = [];
            lessonModel.get(i).lessonInfo4 = [];
            lessonModel.get(i).lessonInfo5 = [];
            lessonModel.get(i).lessonInfo6 = [];
            lessonModel.get(i).lessonInfo7 = [];
        }
    }

    //获取是否为当前天
    function getWeekIndex(dateOfWeek){
        for(var i = 0; i < dateOfWeek.length;i++){
            var date2 = new Date(dateOfWeek[i]);
            var date = new Date();
            var year = date.getFullYear();
            var month = Cfg.addZero(date.getMonth() + 1);
            var day = Cfg.addZero(date.getDate());
            var date3 = new Date(year + "-" + month + "-" + day)
            if(date2.getTime() - date3.getTime() == 0){
                var day = date3.getDay();
                currentDateIndex = day == 0 ? 7 : day;
                return;
            }
        }
    }
}
