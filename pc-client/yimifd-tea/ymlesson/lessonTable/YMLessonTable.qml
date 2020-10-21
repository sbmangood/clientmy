import QtQuick 2.0
import QtQuick.Controls 1.4
import "../../Configuration.js" as Cfg
import YMLessonManagerAdapter 1.0

/***课程表***/

Item {
    id: lessonView
    anchors.fill: parent
    focus: true
    property string year: "2016";
    property string week1: "周一";
    property string week2: "周二";
    property string week3: "周三";
    property string week4: "周四";
    property string week5: "周五";
    property string week6: "周六";
    property string week7: "周日";
    property int columnWidth: (lessonListView.width) / 8;//8列宽度
    property int currentDateIndex: -1;//当前日期高亮
    property var contentDate: [];
    property var lessonInfo: [];
    property var timeSchedule: [];
    property var workTime: [];

    YMLessonManagerAdapter{
        id: lessonMgr

        //显示错误提示对话框
        onSigMessageBoxInfo:
        {
            console.log("=======YMLessonTable.qml onSigMessageBoxInfo========");
            windowView.showMessageBox(strMsg);
        }

        onTeachLessonInfoChanged:{
            var jsonObject = lessonInfo;
            if(jsonObject.data == undefined){

                networkItem.visible = true;
                return;
            }

            //console.log("data.dateOfWeek",jsonObject.data.dateOfWeek);
            updateWeek(jsonObject.data.dateOfWeek);
            timeSchedule = jsonObject.data.timeSchedule;
            updateLesonTime(timeSchedule);
            updateModelData(jsonObject.data.lessonSchedules);
            workTime = jsonObject.data.workTime;
        }
        onLoadingFinished:{
            loadingView.opacityAnimation = !loadingView.opacityAnimation;
        }
        onRequstTimeOuted:{
            enterClassRoom = true;
            networkItem.visible = true;
            classView.visible = false;
            loadingView.opacityAnimation = !loadingView.opacityAnimation;
        }

        onLessonlistRenewSignal: {
            enterClassRoom = true;
            accountMgr.getUserLoginStatus();
        }
        onSigRepeatPlayer: {
            massgeTips.tips = "录播暂未生成，请在课程结束半小时后进行查看!";
            massgeTips.visible = true;
        }
    }

    YMLoadingStatuesView{
        id:loadingView
        z: 100
        anchors.fill: parent
        visible: false
        onChangeVisible:
        {
            loadingView.visible=false;
        }
    }

    YMCalendarControl{
        id: calendar
        z: 95
        visible: false
        onDateTimeconfirm: {
            contentDate = dateTime;
            updateDateData(dateTime);
        }
    }

    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Up:
            if(filckable.contentY > 0){
                filckable.contentY -= 20;
            }
            break;
        case Qt.Key_Down:
            if(button.y < scrollbar.height-button.height){
                filckable.contentY += 20;
            }
            break;
        default:
            return;
        }
        event.accepted = true
    }

    //课程表页面的 上层 课程表使用说明 日历 今天  布局
    Rectangle{
        id: headItem
        z: 3
        width: parent.width - 2
        height: 65 * heightRate
        radius: 12 * widthRate
        anchors.top:parent.top
        anchors.left: parent.left
        anchors.leftMargin: 2
        enabled: loadingView.visible == false
        Row{
            id: headRow
            width: 195 * widthRate
            height: 60 * heightRate
            spacing: 0
            anchors.left: parent.left
            anchors.leftMargin: 20 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 22 * heightRate

            MouseArea{
                width: 20 * widthRate
                height: parent.height * 0.6
                cursorShape: Qt.PointingHandCursor
                Image{
                    width: 16 * widthRate
                    height: 16 * widthRate
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    source: parent.pressed ? "qrc:/images/btn_i_sed@2x.png" : "qrc:/images/btn_i@2x.png"
                }
                onClicked: {
                    lessonDescribe.startAnimate();
                }
            }

            Text{//显示  课程表 三个字体
                id: titleText
                text: "课程表"
                width: 70 * widthRate
                height: parent.height * 0.5
                font.family: Cfg.LESSON_FONT_FAMILY
                font.pixelSize: Cfg.LESSON_MAX_FONTSIZE * heightRate
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
                    var week = week7.split(" ");
                    var date = new Date(year + "-" + week[1])
                    date.setDate(date.getDate() - 7);
                    var month = date.getMonth() + 1;
                    contentDate = date.getFullYear() + '-' + Cfg.addZero(month) + '-' + Cfg.addZero(date.getDate());
                    updateDateData(contentDate);
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
                    var location = contentItem.mapFromItem(calendarButton,0,0)
                    calendar.x = location.x - calendar.width - 25 * widthRate;
                    calendar.y = location.y - 30 * heightRate;
                    calendar.visible = true;
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
                    var week = week7.split(" ");
                    var date = new Date(year +"-"+ week[1])
                    date.setDate(date.getDate()+ 7);
                    var month = date.getMonth() + 1;
                    contentDate = date.getFullYear() + '-' + Cfg.addZero(month) + '-' + Cfg.addZero(date.getDate());
                    updateDateData(contentDate);
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
            Image{
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                verticalAlignment: Image.AlignVCenter
                source: parent.pressed ?  "qrc:/images/btn_calendar_today@2x.png" : "qrc:/images/btn_calendar_today@2x.png"
            }
            onClicked: {
                contentDate = getCurrentDate()
                updateDateData(contentDate);
            }
        }
    }

    //星期显示
    Rectangle{
        id: headItem2
        z: 4
        radius: 12 * widthRate
        width: parent.width -2
        height: 55 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.top: headItem.bottom
        Row{
            anchors.fill: parent

            Text{
                width: columnWidth
                height: parent.height
                text: year
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: Cfg.WEEK_FAMILY
                font.pixelSize: (Cfg.WEEK_FONTSIZE + 2) * heightRate
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week1
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: Cfg.WEEK_FAMILY
                font.pixelSize: Cfg.WEEK_FONTSIZE * heightRate
                color: currentDateIndex == 1 ? Cfg.WEEK_HIGHLIGHTCOLOR : Cfg.WEEK_BACKGROUND_COLOR
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: Cfg.WEEK_FAMILY
                font.pixelSize: Cfg.WEEK_FONTSIZE * heightRate
                color: currentDateIndex == 2 ? Cfg.WEEK_HIGHLIGHTCOLOR : Cfg.WEEK_BACKGROUND_COLOR
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week3
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: Cfg.WEEK_FAMILY
                font.pixelSize: Cfg.WEEK_FONTSIZE * heightRate
                color: currentDateIndex == 3 ? Cfg.WEEK_HIGHLIGHTCOLOR : Cfg.WEEK_BACKGROUND_COLOR
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week4
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: Cfg.WEEK_FAMILY
                font.pixelSize: Cfg.WEEK_FONTSIZE * heightRate
                color: currentDateIndex == 4 ? Cfg.WEEK_HIGHLIGHTCOLOR : Cfg.WEEK_BACKGROUND_COLOR
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week5
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: Cfg.WEEK_FAMILY
                font.pixelSize: Cfg.WEEK_FONTSIZE * heightRate
                color: currentDateIndex == 5 ? Cfg.WEEK_HIGHLIGHTCOLOR : Cfg.WEEK_BACKGROUND_COLOR
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week6
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: Cfg.WEEK_FAMILY
                font.pixelSize: Cfg.WEEK_FONTSIZE * heightRate
                color: currentDateIndex == 6 ? Cfg.WEEK_HIGHLIGHTCOLOR : Cfg.WEEK_BACKGROUND_COLOR
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week7
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: Cfg.WEEK_FAMILY
                font.pixelSize: Cfg.WEEK_FONTSIZE * heightRate
                color: currentDateIndex == 0 ? Cfg.WEEK_HIGHLIGHTCOLOR : Cfg.WEEK_BACKGROUND_COLOR

            }
        }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                exitButton.visible = false;
                calendar.visible = false;
            }
        }
    }

    Flickable{
        id :filckable
        z: 1
        width: parent.width
        height: parent.height - headItem2.height - headItem.height - 5
        contentWidth: width
        contentHeight: lessonModel.count * 60 * heightRate
        anchors.top: headItem2.bottom

        ListView{
            id:lessonListView
            width: parent.width - 20
            height: lessonModel.count * 60 * heightRate
            delegate: contentComponent
            model: lessonModel
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle{//表格左侧的线
            width: 1 * widthRate
            height: lessonListView.height
            anchors.left: lessonListView.left
            color: "#e0e0e0"
            anchors.top: parent.top
        }
    }

    //网络显示提醒
    Rectangle{
        id: networkItem
        z: 86
        visible: false
        anchors.fill: parent
        radius: 12 * widthRate
        anchors.top: headItem2.bottom
        Image{
            id: netIco
            width: 60 * widthRate
            height: 60 * widthRate
            source: "qrc:/images/icon_nowifi.png"
            anchors.top: parent.top
            anchors.topMargin: (parent.height - (30 * heightRate) * 2 - (10 * heightRate) - height) * 0.5
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text{
            id: netText
            height: 30 * heightRate
            text: "网络不给力,请检查您的网络～"
            anchors.top: netIco.bottom
            anchors.topMargin: 10 * heightRate
            font.family: Cfg.LESSON_FONT_FAMILY
            font.pixelSize: Cfg.LESSON_2FONTSIZE * heightRate
            verticalAlignment: Text.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Rectangle{
            width: 80 * widthRate
            height: 30 * heightRate
            border.color: "#808080"
            border.width: 1
            radius: 4
            anchors.top: netText.bottom
            anchors.topMargin: 10 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            Text{
                text: "刷新"
                font.family: Cfg.LESSON_FONT_FAMILY
                font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
                anchors.centerIn: parent
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    refreshPage();
                }
            }
        }
    }

    //滚动条
    Rectangle {
        id: scrollbar
        z: 66
        width: 10
        height: parent.height - headItem2.height - headItem.height
        anchors.top: headItem2.bottom
        anchors.right: parent.right
        Rectangle{
            width: 2
            height: lessonListView.height
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: filckable.visibleArea.yPosition * scrollbar.height
            width: 6
            height: filckable.visibleArea.heightRatio * scrollbar.height;
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
                cursorShape: Qt.PointingHandCursor
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

    Component{
        id: contentComponent
        Item{
            id: bodyItem
            width: lessonListView.width
            height: 60 * heightRate
            //站位button  平铺成table形式
            property bool workVisible1: displayerWorkTime(0,index);
            property bool workVisible2: displayerWorkTime(1,index);
            property bool workVisible3: displayerWorkTime(2,index);
            property bool workVisible4: displayerWorkTime(3,index);
            property bool workVisible5: displayerWorkTime(4,index);
            property bool workVisible6: displayerWorkTime(5,index);
            property bool workVisible7: displayerWorkTime(6,index);
            Row{
                anchors.fill: parent
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    text: time
                    workTimeVisible: false
                }

                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    workTimeVisible: bodyItem.workVisible1
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    workTimeVisible: bodyItem.workVisible2
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    workTimeVisible: bodyItem.workVisible3
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    workTimeVisible: bodyItem.workVisible4
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    workTimeVisible: bodyItem.workVisible5
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    workTimeVisible: bodyItem.workVisible6
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    workTimeVisible: bodyItem.workVisible7
                }
            }
            //当天高亮框
            Rectangle{
                width: columnWidth
                height: lessonModel.count * parent.height
                color: "#F3F8FF"
                opacity: 0.2
                visible: (currentDateIndex != -1)
                x: currentDateIndex * columnWidth
                z: 5
            }
            //真正数据框
            YMLessonInfoControl{
                z: 6
                width: columnWidth-1
                height: parent.height * lessonInfoData.count
                x: 1 * columnWidth
                lessonDataInfo: lessonInfoData
                workTimeVisible: parent.workVisible1
                onLessonIdConfirm: {
                    lessonControl.displayerStatus = !lessonControl.displayerStatus;
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData,1,lessonId);
                }
            }
            YMLessonInfoControl{
                z: 7
                width: columnWidth-1
                height: parent.height * lessonInfoData2.count
                x: 2 * columnWidth
                lessonDataInfo: lessonInfoData2
                workTimeVisible: parent.workVisible2
                onLessonIdConfirm: {
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData2,2,lessonId);
                    lessonControl.displayerStatus = !lessonControl.displayerStatus;
                }
            }
            YMLessonInfoControl{
                z: 8
                width: columnWidth-1
                height: parent.height * lessonInfoData3.count
                x: 3 * columnWidth
                lessonDataInfo: lessonInfoData3
                workTimeVisible: parent.workVisible3
                onLessonIdConfirm: {
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData3,3,lessonId);
                    lessonControl.displayerStatus = !lessonControl.displayerStatus;
                }
            }
            YMLessonInfoControl{
                z: 9
                width: columnWidth-1
                height: parent.height * lessonInfoData4.count
                x: 4 * columnWidth
                lessonDataInfo: lessonInfoData4
                workTimeVisible: parent.workVisible4
                onLessonIdConfirm: {
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData4,4,lessonId);
                    lessonControl.displayerStatus = !lessonControl.displayerStatus;
                }
            }
            YMLessonInfoControl{
                z: 10
                width: columnWidth-1
                height: parent.height * lessonInfoData5.count
                x: 5 * columnWidth
                lessonDataInfo: lessonInfoData5
                workTimeVisible: parent.workVisible5
                onLessonIdConfirm: {
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData5,5,lessonId);
                    lessonControl.displayerStatus = !lessonControl.displayerStatus;
                }
            }
            YMLessonInfoControl{
                z: 11
                width: columnWidth-1
                height: parent.height * lessonInfoData6.count
                x: 6 * columnWidth
                lessonDataInfo: lessonInfoData6
                workTimeVisible: parent.workVisible6
                onLessonIdConfirm: {
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData6,6,lessonId);
                    lessonControl.displayerStatus = !lessonControl.displayerStatus;
                }
            }
            YMLessonInfoControl{
                z: 12
                width: columnWidth-1
                height: parent.height * lessonInfoData7.count
                x: 7 * columnWidth
                lessonDataInfo: lessonInfoData7
                workTimeVisible: parent.workVisible7
                onLessonIdConfirm: {
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData7,7,lessonId);
                    lessonControl.displayerStatus = !lessonControl.displayerStatus;
                }
            }
            //线框
            Rectangle{
                width: columnWidth * 8
                height: 1
                anchors.bottom: parent.bottom
                color: "#e0e0e0"
            }

            Rectangle{
                width: columnWidth * 8
                height: 1
                anchors.top: parent.top
                color: "#e0e0e0"
                visible: index == 0 ? true: false
            }
        }
    }

    Component.onCompleted: {
        var timeList = Cfg.timeSchedule;
        for(var i = 0; i < timeList.length;i++){
            lessonModel.append({
                                   time: timeList[i],
                                   check: false,
                                   lessonInfoData: [],
                                   lessonInfoData2: [],
                                   lessonInfoData3: [],
                                   lessonInfoData4: [],
                                   lessonInfoData5: [],
                                   lessonInfoData6: [],
                                   lessonInfoData7: [],
                               })
        }
        contentDate = getCurrentDate();
        updateDateData(contentDate);
        //console.log("Component.onCompleted: {",lessonModel.count);
    }

    //刷新页面数据
    function refreshPage(){
        updateDateData(contentDate);
        //console.log("=======lessonTabl21332131e::onRefreshPage========",loadingView.visible);

    }

    function getWeek(dateString){
        var dateArray = dateString.split("-");
        var date = new Date(dateArray[0], parseInt(dateArray[1] - 1), dateArray[2]);
        var date3 = new Date();
        var yearTmp = date3.getFullYear(); //避免与当前文件中的全局year变量冲突, 所以这里修改了变量名
        var month = Cfg.addZero(date3.getMonth() + 1);
        var day = Cfg.addZero(date3.getDate());
        var date2 = new Date(yearTmp + "-" + month + "-" + day + " 00:00:00");

        if(date2.getTime() - date.getTime() == 0){
            currentDateIndex = date.getDay();
            //console.log("week::day",currentDateIndex);
        }

        var weeks = ["日", "一", "二", "三", "四", "五", "六"];
        return "周" + weeks[date.getDay()];
    }

    function updateLesonTime(timeList){
        for(var i = 0; i < timeList.length;i++){
            lessonModel.get(i).time = timeList[i];
        }
    }

    function updateDateData(date){
        if(loadingStatus){
            loadingView.visible = true;
        }
        clearModel();
        lessonMgr.getTeachLessonInfo(date);
    }

    function updateWeek(dateOfWeek){
        //console.log("dateOfWeek",dateOfWeek);
        var yearArray = dateOfWeek[0].split("-");
        var yearArray1 = dateOfWeek[1].split("-");
        var yearArray2 = dateOfWeek[2].split("-");
        var yearArray3 = dateOfWeek[3].split("-");
        var yearArray4 = dateOfWeek[4].split("-");
        var yearArray5 = dateOfWeek[5].split("-");
        var yearArray6 = dateOfWeek[6].split("-");

        //一年最后一周的时候, yearArray[0] 可能是2018年, yearArray6[0]可能就是2019年了, 所以这里修改为: yearArray6[0],
        //不然, 当前是2018/12/28, 点击按钮: >, 再点击按钮: < 的以后, 请求API接口: getTeacherLessonSchedule的时候, 就变成2017年了, 即:
        //void YMLessonManagerAdapter::getTeachLessonInfo(QString dateTime) 这个参数dateTime是2017年
        year = yearArray6[0]; //修改当前文件全局的变量: year

        currentDateIndex = -1;
        week1 = getWeek(dateOfWeek[0]) + " " + yearArray[1] + "-" + yearArray[2];
        week2 = getWeek(dateOfWeek[1]) + " " + yearArray1[1] + "-" + yearArray1[2];
        week3 = getWeek(dateOfWeek[2]) + " " + yearArray2[1] + "-" + yearArray2[2];
        week4 = getWeek(dateOfWeek[3]) + " " + yearArray3[1] + "-" + yearArray3[2];
        week5 = getWeek(dateOfWeek[4]) + " " + yearArray4[1] + "-" + yearArray4[2];
        week6 = getWeek(dateOfWeek[5]) + " " + yearArray5[1] + "-" + yearArray5[2];
        week7 = getWeek(dateOfWeek[6]) + " " + yearArray6[1] + "-" + yearArray6[2];
    }

    function updateModelData(temp){
        lessonInfo = temp;//所有的课程数据信息 list 形式
        //console.log("===updateModelData==",JSON.stringify(lessonInfo));
        if(lessonInfo == [] || lessonInfo == {} || lessonInfo == null){
            return;
        }
        networkItem.visible = false;
        for(var i = 0; i < lessonModel.count; i++) {
            //1、遍历所有数据判断当前行有几条数据，增加至缓存
            var bufferData = []; //bufferdata 存储第i行的所有课程数据
            for(var z = 0; z < lessonInfo.length;z++){
                if(i === lessonInfo[z].scheduleId){
                    bufferData.push(lessonInfo[z]);
                }
            }

            //2、遍历缓存数据当前行的lessonId是否是最后一行
            for(var a = 0; a < bufferData.length;){
                var resolveData = bufferData[a];
                var mark = true;
                //如果相同的课程只有一节课请假，则都显示为请假
                for(var s = 0; s < lessonInfo.length;s++){
                    lessonInfo[s].startTime = lessonInfo[s].startTime.toString();
                    lessonInfo[s].endTime = lessonInfo[s].endTime.toString();
                    lessonInfo[s].lessonStatus = lessonInfo[s].lessonStatus.toString();
                    //console.log("value::",lessonInfo[s].lessonId,lessonInfo[s].startTime,lessonInfo[s].endTime,lessonInfo[s].lessonStatus)
                    if(resolveData.lessonId === lessonInfo[s].lessonId){
                        if(lessonInfo[s].lessonId == 0 || lessonInfo[s].relateType == "V"
                                || lessonInfo[s].lessonType == "V"){
                            bufferData[a].relateType = 'V';
                        }
                    }
                }
                for(var b = 0; b < lessonInfo.length;b++){
                    if(resolveData.lessonId === lessonInfo[b].lessonId
                            && lessonInfo[b].scheduleId > i
                            && lessonInfo[b].dateId == resolveData.dateId){
                        //如果是老师请假则显示请假，如果是有课程请假则显示课程
                        if(lessonInfo[b].relateType == "V" && lessonInfo[b].lessonType == "V"
                                && lessonInfo[b].lessonId == 0){
                            break;
                        }
                        bufferData.splice(a,1);
                        a = 0;
                        mark = false;
                        break;
                    }
                }
                if(mark){
                    a++;
                }
            }

            for(var c = 0; c < bufferData.length; c++){
                //3、遍历缓存数据存在的lessonId一共有多少条数据
                var lessonInfoData = [];
                var lessonId = bufferData[c].lessonId;
                var cospanSum = 0;
                var leave = true;
                for(var d = 0; d < lessonInfo.length; d++){
                    if(bufferData[c].relateType == "V" && bufferData[c].lessonType == "V"){
                        cospanSum = 1;
                        break;
                    }
                    if(lessonId == lessonInfo[d].lessonId){
                        cospanSum++;
                    }
                    //请假课的行高处理
                    /*if(lessonInfo[d].lessonId == bufferData[c].lessonId
                            && lessonInfo[d].scheduleId < i
                            && bufferData[c].relateType == "V"
                            && lessonInfo[d].dateId == bufferData[c].dateId){
                        if(lessonInfo[d + 1].relateType == "V"
                                && lessonInfo[d + 1].dateId == bufferData[c].dateId){
                            cospanSum++;
                        }
                        cospanSum = cospanSum == 0 ? 1 : cospanSum;
                        console.log("111111111111111")
                        continue;
                    }

                    if(lessonId === lessonInfo[d].lessonId && bufferData[c].relateType !== "V"){
                        cospanSum++;
                        continue;
                    }
                    if(bufferData[c].relateType == 'V' && cospanSum == 0){
                        cospanSum = 1;
                    }*/
                }

                var dateIdIndex = bufferData[c].dateId + 1;
                //console.log("cccccccccccccccccc::",bufferData[c].lessonId,bufferData[c].startTime,bufferData[c].endTime)
                lessonInfoData.push({
                                        dateId: dateIdIndex,
                                        enableClass: false,
                                        lessonId: lessonId,
                                        lineHeight: cospanSum,
                                        name: bufferData[c].name,
                                        grade: bufferData[c].grade,
                                        subject: bufferData[c].subject,
                                        lessonStatus: bufferData[c].lessonStatus,
                                        contractNo: bufferData[c].contractNo.toString(),
                                        parentContactInfo: bufferData[c].parentContactInfo,
                                        clientNo: bufferData[c].clientNo.toString(),
                                        relateType: bufferData[c].relateType,
                                        hasCourseware: bufferData[c].hasCourseware,
                                        chargeMobile: bufferData[c].chargeMobile,
                                        parentRealName: bufferData[c].parentRealName,
                                        startTime: bufferData[c].startTime,
                                        endTime: bufferData[c].endTime,
                                        chargeName: bufferData[c].chargeName,
                                        hasRecord: bufferData[c].hasRecord,
                                        lessonType: bufferData[c].lessonType,
                                        scheduleId: bufferData[c].scheduleId,
                                        teacherId: bufferData[c].teacherId,
                                        studentId: bufferData[c].studentId,
                                        reportFlag: bufferData[c].reportFlag,
                                    })

                //4、是则添加，否则下次循环增加到model里面
                var addMark = true;
                for(var e = 0; e < lessonModel.count; e++){
                    if(lessonModel.get(e).currentLessonId === lessonId){
                        addMark = false;
                        break;
                    }
                }
                if(addMark){
                    if(dateIdIndex == 1){
                        lessonModel.get(i).lessonInfoData = lessonInfoData;
                        continue;
                    }
                    if(dateIdIndex == 2){
                        lessonModel.get(i).lessonInfoData2 = lessonInfoData;
                        continue;
                    }
                    if(dateIdIndex == 3){
                        lessonModel.get(i).lessonInfoData3 = lessonInfoData;
                        continue;
                    }
                    if(dateIdIndex == 4){
                        lessonModel.get(i).lessonInfoData4 = lessonInfoData;
                        continue;
                    }
                    if(dateIdIndex == 5){
                        lessonModel.get(i).lessonInfoData5 = lessonInfoData;
                        continue;
                    }
                    if(dateIdIndex == 6){
                        lessonModel.get(i).lessonInfoData6 = lessonInfoData;
                        continue;
                    }
                    if(dateIdIndex == 7){
                        lessonModel.get(i).lessonInfoData7 = lessonInfoData;
                        continue;
                    }
                }
            }
        }
    }

    function clearModel(){
        lessonModel.clear();
        var timeList = Cfg.timeSchedule;
        for(var i = 0; i < timeList.length;i++){
            lessonModel.append({
                                   time: timeList[i],
                                   check: false,
                                   lessonInfoData: [],
                                   lessonInfoData2: [],
                                   lessonInfoData3: [],
                                   lessonInfoData4: [],
                                   lessonInfoData5: [],
                                   lessonInfoData6: [],
                                   lessonInfoData7: [],
                               })
        }
    }

    function getCurrentLessonInfo(temp,dateId,lessonId){
        for(var i = 0; i < temp.count; i++){
            if(temp.get(i).dateId == dateId && temp.get(i).lessonId == lessonId){
                //console.log("======",temp.get(i).endTime,temp.get(i).startTime)
                //console.log("getCurrentLessonInfo::",JSON.stringify(temp.get(i)))
                return temp.get(i);
            }
        }
    }

    function getCurrentDate(){
        var date = new Date();
        var yearTmp = date.getFullYear(); //避免与当前文件中的全局year变量冲突, 所以这里修改了变量名
        var month = Cfg.addZero(date.getMonth() + 1);
        var day = Cfg.addZero(date.getDate());

        return yearTmp + "-" + month + "-" + day;
    }

    //是否显示非工作时间图标
    function displayerWorkTime(dateId,scheduleId){
        //console.log("displayerWorkTime::",dateId,scheduleId)
        for(var i = 0; i < workTime.length; i++){
            if(workTime[i].dateId == dateId && workTime[i].scheduleId == scheduleId ){
                return false;
            }
        }
        return true;
    }
}

