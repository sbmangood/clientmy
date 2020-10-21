import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import YMLessonManagerAdapter 1.0
//import QtQuick.Controls.Private 1.0
import "../Configuration.js" as Cfg

/*******全部课程*******/
Item {
    focus: true

    property int mark: 0;// 0起始日期 1结束日期
    property int pageIndex: 1;
    property int pageSize: 10;
    property int lessonIndex: -1;
    property int subjectIndex: -1;
    property int showProcess: 0;//0显示课件进度 1显示教室进度

    property string querySubject: "";
    property string queryPeriod : "TODAY";
    property string keywords: "";//搜索传递参数，必须要
    property string currentDate: ""//当前开始日期参数，必须要
    property string currentEndDate: ""//结束日期，必要参数

    signal transferPage(var pram);//页面传值信号，必须要

    //键盘上下滚动页
    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Up:
            if(teachListView.contentY > 0)
            {
                teachListView.contentY -= 20;
            }
            break;
        case Qt.Key_Down:
            if(button.y<scrollbar.height-button.height)
            {
                teachListView.contentY += 20;
            }
            break;
        default:
            return;
        }
        event.accepted = true
    }
    onLessonIndexChanged: {
        filterItem.selecteLessonIndex = lessonIndex;
    }

    onSubjectIndexChanged: {
        filterItem.selecteSubjectIndex = subjectIndex;
    }

    YMLoadingStatuesView{
        id: lodingView
        z: 88
        anchors.fill: parent
        visible: false
    }

    //网络显示页面
    YMInterNetView{
        id:netRequest
        z: 89
        visible: false
        anchors.fill: parent
    }

    YMLessonManagerAdapter{
        id: lessonMgr

        //显示错误提示对话框
        onSigMessageBoxInfo:
        {
            console.log("=======YMStudentCoachView.qml onSigMessageBoxInfo========");
            windowView.showMessageBox(strMsg);
        }

        onStudentLesonListInfoChanged:{
            //console.log("==onStudentLesonListInfoChanged==")
            if(lessonInfo.items == undefined){
                teachModel.clear();
                backgImage.visible = true;
                //netRequest.visible = true;
                return;
            }
            backgImage.visible = false;
            netRequest.visible = false;
            analysisData(lessonInfo);
        }
        onLodingFinished:{
            lodingView.startFadeOut();
        }
        onLessonlistRenewSignal:{
            console.log("==onLessonlistRenewSignal==")
            classView.visible = false;
            enterClassRoom = true;
            if(isStudentUser){
                queryData();
            }

            accountMgr.getUserLoginStatus();
        }
        onShowEnterRoomStatusTips:
        {
            console.log("==onShowEnterRoomStatusTips==")
            enterClassStatusTipView.startTimer(statusText);
            enterClassRoom = true;
        }
        onRequestTimerOut:{
            teachModel.clear();
            classView.visible = false;
            enterClassRoom = true;
            netRequest.visible = true;
        }
        onSetDownValue: {
            if(showProcess == 0){
                progressbar.min = min;
                progressbar.max = max;
                progressbar.visible = true;
            }
        }

        onDownloadChanged: {
            if(showProcess == 0){
                progressbar.currentValue = currentValue;
            }
        }
        onDownloadFinished: {
            if(showProcess == 0){
                progressbar.visible = false;
            }else{
                //classView.visible = false;
                classView.hideAfterSeconds();
            }
        }
        onSigRepeatPlayer: {
            massgeTips.tips = "录播暂未生成，请在课程结束半小时后进行查看!";
            massgeTips.visible = true;
        }
    }

    //日历控件
    YMCalendarControl{
        id: calendarControl
        z: 66
        visible: false
        onDateTimeconfirm: {
            var sdate;
            var edate;
            pageIndex = 1;
            pagtingControl.currentPage = 1;
            if(mark == 0){
                sdate = new Date(dateTime);
                if(currentEndDate == ""){
                    currentDate = dateTime;
                    calendarControl.close();
                    queryData();
                    return;
                }
                edate = new Date(currentEndDate);
                if(edate.getTime() - sdate.getTime() >= 0){
                    calendarControl.close();
                    currentDate = dateTime;
                    queryData();
                }
            }else{
                edate = new Date(dateTime);
                if(currentDate == ""){
                    currentEndDate = dateTime;
                    calendarControl.close();
                    queryData();
                    return;
                }
                sdate = new Date(currentDate);
                if(edate.getTime() - sdate.getTime() >= 0){
                    currentEndDate = dateTime;
                    calendarControl.close();
                    queryData();
                }
            }
        }
    }
    //搜索输入框
    YMCoachFilterControl{
        id: seacheItem
        width: parent.width - 40 * widthRate
        height: 45 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 20 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        displayerText: keywords == "-1" ?  "" : keywords
        enabled: lodingView.visible == false
        onFilterChange: {
            pageIndex = 1;
            pagtingControl.currentPage = 1;
            keywords = text;
            if(keywords == ""){
                currentDate = Cfg.getCurrentDate();
            }
            queryData();
        }
    }

    //筛选课程、日期等控件
    YMDateFilterControl{
        id: filterItem
        width: parent.width - 40 * widthRate
        height: 45 * heightRate
        anchors.top: seacheItem.bottom
        anchors.topMargin: 20 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 15 * heightRate
        enabled: lodingView.visible == false
        onLessonChanged: {
            pageIndex = 1;
            pagtingControl.currentPage = 1;
            lessonIndex = index;
            queryData();
        }
        onSubjectChanged: {
            pageIndex = 1;
            pagtingControl.currentPage = 1;
            querySubject = key;
            queryData();
        }
        onClearChanged: {
            currentEndDate = "";
            currentDate = "";
            pageIndex = 1;
            pagtingControl.currentPage = 1;
            queryData();
        }
    }
    //请假按钮
    Rectangle {
        id: askForLeaveButton
        width: 50 * widthRate
        height: 35 * heightRate
        border.color: "#d3d8dc"
        border.width: 1
        anchors.top: seacheItem.bottom
        anchors.topMargin: 20 * heightRate
        anchors.right: parent.right
        anchors.rightMargin: 32 * heightRate
        radius: 4 * heightRate
        visible: false
        Text{
            text: "请假"
            anchors.centerIn: parent
            font.family: Cfg.LESSON_ALL_FAMILY
            font.pixelSize: 16*heightRate
            color: "#222222"
        }

        MouseArea{
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                //经过筛选条件之后才显示的 请假按钮
                askForLeaveView.showAskForLeaveView();
                askForLeaveView.visible = true;
            }
        }
    }

    ListView{
        id: teachListView
        clip: true
        width: parent.width - 20 * widthRate
        height: parent.height - 180 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 15 * heightRate
        anchors.top: filterItem.bottom
        anchors.topMargin: 12 * heightRate
        model: teachModel
        delegate: teachDelegate
        currentIndex: -1
        onCurrentIndexChanged: {
            askForLeaveButton.visible = false;
        }
    }

    //背景图片
    Image{
        id: backgImage
        width: 150 * heightRate
        height: 173 * heightRate
        anchors.centerIn: parent
        visible: false
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/pic_empty2x.jpg"
    }

    ListModel{
        id: teachModel
    }
    //分页
    YMPagingControl{
        id: pagtingControl
        visible: teachModel.count > 0 ? true : false
        anchors.bottom: parent.bottom
        enabled: lodingView.visible == false
        onPageChanged: {
            pageIndex = page;
            currentPage = pageIndex;
            queryData()
        }
        onPervPage: {
            pageIndex -= 1;
            currentPage = pageIndex;
            queryData()
        }
        onNextPage: {
            pageIndex += 1;
            currentPage = pageIndex;
            queryData()
        }
    }

    Component{
        id: teachDelegate

        Item{
            width: teachListView.width
            height: 140 * heightRate

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    teachListView.currentIndex=index;
                    askForLeaveView.lessonId=teachModel.get(index).lessonId;
                    var startDateTime = new Date(startTime);
                    var currentDate = new Date();
                    //是订单课 且不是邀请课和 请假课 并且课程没有结束或过期  并且当前时间不可以进入教室  才可以请假
                    if(teachModel.get(index).isShare == 0
                            && teachModel.get(index).lessonStatus != 3
                            && teachModel.get(index).lessonStatus != 2
                            && teachModel.get(index).lessonType == 10
                            /*&&　teachModel.get(index).enableClass == false*/
                            && (startDateTime.getTime()-currentDate.getTime() > 0)
                            && (timeText.text.indexOf("天") >= 0
                                || timeText.text.indexOf("秒") >= 0)) {
                        //console.log("可以请假")
                        askForLeaveButton.visible = true;
                        // 24小时之外  不扣除课时
                        if( timeText.text.indexOf("天") >= 0 ){
                            //console.log("24时之外 不扣除课时");
                            askForLeaveView.isWithinTwentyFourHoursLesson = false;
                        }else {//24小时之内  扣除课时
                            //console.log("24时之内 扣除课时");
                            askForLeaveView.isWithinTwentyFourHoursLesson = true;
                        }
                    }
                    else {
                        //console.log("不可以请假")
                        askForLeaveButton.visible = false;
                    }
                }
            }
            Rectangle{
                id: contentItem
                color: "#f9f9f9"
                width: parent.width - 20 * widthRate
                height: parent.height - 10 * heightRate
                border.color:   teachListView.currentIndex == index ?  "#99aacc" : "#e3e6e9" //#99aacc
                border.width: 1
                radius: 6 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Image{
                width: 20 * widthRate
                height: 20 * widthRate
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                visible: isShare == 0 ? false : true
                source: "qrc:/images/yaoqing2x.png"
            }

            Item{
                id: timeItem
                width: parent.width * 0.2
                height: contentItem.height
                anchors.left: contentItem.left
                anchors.verticalCenter: contentItem.verticalCenter
                Text{
                    id: spatimeText
                    width: parent.width
                    text: lessonMsg
                    anchors.top: parent.top
                    anchors.topMargin: lessonStatus== 0 ? 30 * heightRate: 25 * heightRate
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Cfg.LESSON_FONT_FAMILY
                    font.pixelSize: statusFontSize1 * heightRate
                    color: status1
                }

                Text{
                    id: timeText
                    width: parent.width
                    anchors.top: spatimeText.bottom
                    anchors.topMargin: 10 * heightRate
                    font.family: Cfg.LESSON_FONT_FAMILY
                    font.pixelSize: statusFontSize2 * heightRate
                    text: lessonDownText
                    color: status2
                    horizontalAlignment: Text.AlignHCenter
                }

                Timer{
                    id: timeClock
                    interval: 1000
                    running: timerStart
                    repeat: true
                    onTriggered: {
                        lessonSecondSum(remaining - 1,startTime,endTime,index);
                    }
                }
            }
            //分割线
            Rectangle{
                width: 1
                height: contentItem.height - 20 * heightRate
                color: "#e3e6e9"
                anchors.left: timeItem.right
                anchors.verticalCenter: contentItem.verticalCenter
            }

            Item{
                width: parent.width - timeItem.width - 2
                height: contentItem.height
                anchors.verticalCenter: contentItem.verticalCenter
                anchors.left: timeItem.right
                anchors.leftMargin: 20 * widthRate
                Row{
                    id: oneRow
                    width: parent.width - 60 * widthRate
                    height: parent.height * 0.5
                    anchors.top:parent.top
                    anchors.topMargin: 8 * heightRate

                    YMTextControl{
                        width: 200 * widthRate
                        height: parent.height
                        text1:  "课程时间："
                        text2:   startTime + "-" + endTime
                    }
                    YMTextControl{
                        width: 100 * widthRate
                        height: parent.height
                        text1: "年级："
                        text2: gradeName
                    }
                    YMTextControl{
                        width: 150 * widthRate
                        height: parent.height
                        text1: "老师："
                        text2: teacherName
                    }

                    Item{
                        width: parent.width - 150 * widthRate - 200 * widthRate - 100 * widthRate -120* widthRate
                        height: parent.height
                    }

                    MouseArea{
                        width: 115 * widthRate
                        height: 35 * heightRate
                        enabled: enableClass ? true : false
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor
                        Rectangle{
                            radius: 4 * heightRate
                            color: hasRecord == 1 ? (enableClass ? "#ffffff" : "#c3c6c9") : (enableClass ? "#ff5000" : "#c3c6c9")
                            anchors.fill: parent
                            border.color: (enableClass ? "#ff5000" : "#c3c6c9")
                            border.width: 1
                        }

                        Text{
                            //"全部课程"中的"进入教室"
                            text:lessonStatus == 1 ? (hasRecord == 0  ? "录播生成中" : "查看录播") : (isStudentUser ? "进入教室" : "进入旁听")
                            //text: hasRecord == 0  ? (isStudentUser ? "进入教室" : "进入旁听") : "查看录播"
                            anchors.centerIn: parent
                            font.bold: Cfg.LESSON_ALL_FONTBOLD
                            font.family: Cfg.LESSON_ALL_FAMILY
                            font.pixelSize: Cfg.LESSON_ALL_FONTSIZE * heightRate
                            color: hasRecord == 1 ? (enableClass ? "#ff5000" : "#ffffff") : "#ffffff"
                        }
                        onPressed: {
                            if(enterClassRoom && lessonStatus == 0){
                                //"全部课程"中, 点击"进入教室", 然后提示: "正在进入教室..."对话框
                                classView.visible = true;
                                classView.tips =  isStudentUser ? "正在进入教室..." : "正在进入旁听..."
                            }
                        }

                        onReleased: {
                            if(lessonStatus == 0){
                                //console.log("===listen===",enterClassRoom)
                                if(enterClassRoom){
                                    //                                    enterClassRoom = false; //"进入教室"按钮, 一直都可以点击, 因为在classroom程序中, 已经控制了, 只有一个实例
                                    showProcess = 1;
                                    lessonMgr.lessonType = lessonType;
                                    lessonMgr.lessonPlanStartTime = startTime;
                                    lessonMgr.lessonPlanEndTime = endTime;
                                    lessonMgr.getEnterClass(lessonId,windowView.interNetGrade);//进入教室
                                    console.log("课程类型qml",lessonType);

                                }
                            }else{
                                showProcess = 0;
                                var lessonInfo = {
                                    "lessonId": lessonId,
                                    "startTime": startTime,
                                    "subject":gradeName,
                                    "name": subjectName,
                                    "teacherName":teacherName,
                                };
                                progressbar.currentValue = 0;
                                lessonMgr.getRepeatPlayer(lessonInfo);//查看录播
                            }
                        }
                    }
                }

                Row{
                    width: parent.width-60*widthRate
                    height: parent.height * 0.5
                    anchors.top: parent.top
                    anchors.topMargin: 55 * heightRate
                    YMTextControl{
                        width: 200 * widthRate
                        height: parent.height
                        text1: "课程编号："
                        text2: lessonId
                    }

                    YMTextControl{
                        width: 100 * widthRate
                        height: parent.height
                        text1: "科目："
                        text2: subjectName
                    }

                    Item{
                        width: parent.width - 200 * widthRate -  100 * widthRate - 125 * widthRate
                        height: parent.height
                    }

                    MouseArea{
                        id: lessonButton
                        width: 70 * widthRate
                        height: 35 * heightRate
                        enabled: hasDoc == 1 ? true : false
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor

                        Image{
                            id: lookLessonImg
                            width: 12 * widthRate
                            height: 20 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                            source: hasDoc == 1 ? "qrc:/images/list-chakankejian@2x.png" : "qrc:/images/list_chakankejian_disable@2x.png"
                        }

                        Text{
                            text: "查看课件"
                            height: parent.height
                            anchors.left: lookLessonImg.right
                            anchors.leftMargin: 3 * widthRate
                            color: hasDoc == 1 ? "#ff5000" : "#96999c"
                            font.bold: Cfg.LESSON_ALL_FONTBOLD
                            font.family: Cfg.LESSON_ALL_FAMILY
                            font.pixelSize: Cfg.LESSON_ALL_FONTSIZE * heightRate
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            var lessonInfo = {
                                "lessonId": lessonId,
                                "startTime": Cfg.analysisDate(startTime),
                                "lessonStatus":lessonStatus
                            };
                            lessonMgr.getLookCourse(lessonInfo);
                        }
                    }

                    //课堂报告
                    MouseArea{
                        width: 80 * widthRate
                        height: 35 * heightRate
                        enabled: lessonStatus == 1 ? true : false
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor

                        Image{
                            id: lookreportImg
                            width: 12 * widthRate
                            height: 20 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                            source: lessonStatus == 1 ? "qrc:/images/list_report@2x.png" : "qrc:/images/ketangbaogao.png"
                        }

                        Text{
                            text: {
                                console.log("=====lessonType=======",lessonType)
                                if(lessonType == 10){
                                    return "课堂报告";
                                }
                                if(lessonType == 0){
                                    if(listenFlag == 1)
                                    {
                                        return "试听课报告";
                                    }
                                    if(listenFlag == 2 && lessonStatus == 1)
                                    {
                                        return "填写试听报告"
                                    }
//                                    return "试听课报告";
                                }
                                return  "课堂报告";
                            }
                            height: parent.height
                            anchors.left: lookreportImg.right
                            anchors.leftMargin: 3 * widthRate
                            color: lessonStatus == 1 ? "#ff5000" : "#96999c"
                            font.bold: Cfg.LESSON_ALL_FONTBOLD
                            font.family: Cfg.LESSON_ALL_FAMILY
                            font.pixelSize: Cfg.LESSON_ALL_FONTSIZE * heightRate
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            //课堂报告
                            var url = URL_ClassroomReport + lessonId;
                            console.log(url);
                            //http://h5.yimifudao.com.cn/freeTrialResult?classId=4175511&report=1
                            //http://h5.yimifudao.com/freeTrialResult?classId=4175511&report=1
                            //http://h5.yimifudao.com/classroomreport?lessonId=4175511
                            if(listenFlag == 1)
                            {
                                url = url.replace("classroomreport?lessonId","freeTrialResult?classId");
                                url = url + "&report=1";
                            }
                            Qt.openUrlExternally(url);
                        }
                    }
                }
            }
        }
    }

    // 滚动条
    Item {
        id: scrollbar
        visible: teachModel.count > 4 ? true : false
        width: 8
        height: teachListView.height
        anchors.right: parent.right
        anchors.top: filterItem.bottom
        anchors.topMargin: 12 * heightRate
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: teachListView.visibleArea.yPosition * scrollbar.height
            width: 6
            height: teachListView.visibleArea.heightRatio * scrollbar.height;
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
                    teachListView.contentY = button.y / scrollbar.height * teachListView.contentHeight
                }
            }
        }
    }

    Component.onCompleted: {
        lodingView.tips = "页面加载中"
        currentDate = Cfg.getCurrentDate();
    }

    function refreshPage(){
        netRequest.visible = false;
        //console.log("YMStudentCoachView::refreshPage")
        queryData();
    }

    function analysisData(objectData){
        teachModel.clear();
        var items = objectData.items;
        console.log("items::Data",JSON.stringify(items))
        for(var i = 0; i < items.length; i++){
            teachModel.append(
                        {
                            "enableClass": false,
                            "lessonStatus":items[i].lessonStatus,
                            "gradeName":items[i].gradeName,
                            "teacherName":items[i].teacherName,
                            "keywords":items[i].keywords,
                            "homeworkStatus":items[i].homeworkStatus,
                            "lessonId":items[i].lessonId,
                            "title":items[i].title,
                            "remaining":items[i].remaining,
                            "hasLesson":items[i].hasLesson,
                            "studentPwd":items[i].studentPwd,
                            "beforeSecond":items[i].beforeSecond,
                            "isShare":items[i].isShare,
                            "startTime":items[i].startTime,
                            "afterSecond":items[i].afterSecond,
                            "hasDoc":items[i].hasDoc,
                            "endTime":items[i].endTime,
                            "hasRecord":items[i].hasRecord,
                            "lessonType":items[i].lessonType,
                            "subjectName":items[i].subjectName,
                            "lessonSecondCount":items[i].lessonSecondCount,
                            "courseHours": items[i].courseHours == undefined ? "0" : items[i].courseHours,
                           "timerStart": false,
                           "lessonDownText": "",
                           "lessonMsg": "距离上课时间",
                           "status1": "black",//控制文本1颜色
                           "status2": "black",//控制文本2颜色
                           "statusFontSize1": 16,//控制文本1字体大小
                           "statusFontSize2": 16,//控制文本2字体大小
                           "listenFlag": lessonMgr.getLessonComment(items[i].lessonId),
                        })
            lessonSecondSum(items[i].remaining,items[i].startTime,items[i].endTime,i);
        }
        var totalPage = Math.ceil(objectData.total / pageSize);
        pagtingControl.totalPage = totalPage;
        backgImage.visible = teachModel.count == 0 ? true : false;
    }

    function lessonSecondSum(remaining,startTime,endTime,index){
        if(remaining == undefined){
            return
        }
        var date = remaining / 60 / 60 / 24;
        var minutes = remaining / 60;

        disableClassButton(remaining,startTime,endTime,index);
        disableHasRecord(index,startTime,endTime);
        teachModel.get(index).remaining = remaining;

        if(teachModel.get(index).lessonStatus == 4){
            teachModel.get(index).lessonMsg = "旷课";
            teachModel.get(index).lessonDownText = "扣除" + teachModel.get(index).courseHours + "课时";
            teachModel.get(index).status1 = "#ff5000";
            teachModel.get(index).status2 = "#ff5000";
            teachModel.get(index).statusFontSize1=22;
            teachModel.get(index).statusFontSize2=22;
            return;
        }

        if(teachModel.get(index).lessonStatus == 3 ){
            teachModel.get(index).lessonMsg = "请假";
            teachModel.get(index).lessonDownText = "扣除" +teachModel.get(index).courseHours + "课时";
            teachModel.get(index).status1 = "#ff5000";
            teachModel.get(index).status2 = "#ff5000";
            teachModel.get(index).statusFontSize1=22;
            teachModel.get(index).statusFontSize2=22;
            return;
        }
        if(teachModel.get(index).lessonStatus == 2) {
            teachModel.get(index).lessonMsg = "请假";
            teachModel.get(index).lessonDownText = "扣除0课时";
            teachModel.get(index).status1 = "#ff5000";
            teachModel.get(index).status2 = "#ff5000";
            teachModel.get(index).statusFontSize1=22;
            teachModel.get(index).statusFontSize2=22;
            return;
        }

        if(date < 0){
            if(teachModel.get(index).lessonStatus == 1){
                teachModel.get(index).lessonMsg = "此课程";
                teachModel.get(index).lessonDownText = "已完成";
                teachModel.get(index).status1 = "#669999";
                teachModel.get(index).status2 = "#669999";
                teachModel.get(index).statusFontSize1=22;
                teachModel.get(index).statusFontSize2=22;
                return;
            }

            teachModel.get(index).lessonMsg = "请在授课完成";
            teachModel.get(index).lessonDownText = "后结束课程";
            teachModel.get(index).status1 = "#ff5000";
            teachModel.get(index).status2 = "#ff5000";
            teachModel.get(index).statusFontSize1=22;
            teachModel.get(index).statusFontSize2=22;
            return;
        }

        if(date < 1){
            teachModel.get(index).timerStart = true;
            teachModel.get(index).lessonMsg = "距上课时间";
            teachModel.get(index).lessonDownText = Cfg.addZero(Math.floor(minutes / 60)) + "时" + Cfg.addZero(Math.floor(minutes % 60)) + "分" + Cfg.addZero(Math.floor(remaining % 60))+ "秒";
            teachModel.get(index).status1 = "#3c3c3e";
            teachModel.get(index).status2 = "#ff5000";
            teachModel.get(index).statusFontSize1=20;
            teachModel.get(index).statusFontSize2=22;
            return;
        }

        if(date > 1){
            teachModel.get(index).lessonMsg = "距上课时间";
            teachModel.get(index).lessonDownText = Math.floor(date) + "天";
            teachModel.get(index).status1 = "#3c3c3e";
            teachModel.get(index).status2 = "#55aaee";
            teachModel.get(index).statusFontSize1=20;
            teachModel.get(index).statusFontSize2=22;
            return;
        }
    }

    /*进入教室按钮：*/
    function disableClassButton(remaining,startTime,endTime,index){
        //请假课 不可进教室
        if(teachModel.get(index).lessonStatus == 2 ||teachModel.get(index).lessonStatus == 3){
            teachModel.get(index).enableClass = false;
            return;
        }
        //小于一天不能进入教室
        //console.log("==disableClass=",startTime,endTime)
        var startDate = new Date(startTime);
        var hm = startDate.getTime();//开始时间转换为毫秒数
        var endTimes = teachModel.get(index).lessonSecondCount * 1000 + hm;

        var endDate = new Date(endTimes);

        var currentDate = new Date();//当前时间
        //console.log("====disableClassBu tton ===",startDate,endDate);
        var date = startDate.getDate() - currentDate.getDate();
        var yaer = startDate.getFullYear() - currentDate.getFullYear();
        var monther = startDate.getMonth() - currentDate.getMonth();

        var s = startDate.getHours() * 3600 + startDate.getMinutes() * 60  + startDate.getSeconds();
        var e = endDate.getHours() * 3600 + endDate.getMinutes() * 60 + endDate.getSeconds();
        var c = currentDate.getHours() * 3600 + currentDate.getMinutes() * 60 + currentDate.getSeconds();

        //全天课
        if(startDate.getHours() == 0 && startDate.getMinutes() == 0
                && endDate.getHours() == 23 && endDate.getMinutes() == 59
                && date == 0 && monther == 0 && yaer == 0){
            teachModel.get(index).enableClass = true;
            return;
        }
        //演示课未结束都可以进入教室
        var subjectName = teachModel.get(index).subjectName;
        var lessonStatus = teachModel.get(index).lessonStatus

        if(subjectName == "演示" && lessonStatus !== 1 ){
            teachModel.get(index).enableClass = true;
            return;
        }

        //距开课时间小于30分钟可以进入教室
        if(c - s <= 1800 && date == 0  && monther == 0  && yaer == 0){
            if(c - s <= -1800){
                teachModel.get(index).enableClass = false;
                //console.log("enterClass2");
                return;
            }
            teachModel.get(index).enableClass = true;
            //console.log("enterClass3");
            return;
        }

        //课程未结束根据 afterSecond 判定进入时间
        var endMs = endDate.valueOf() / 1000;
        var currentMs = currentDate.valueOf() / 1000;
        var status = teachModel.get(index).lessonStatus;

        if(status == 0 && endMs - currentMs <= 0 && endMs + teachModel.get(index).afterSecond - currentMs >=0){
            teachModel.get(index).enableClass = true;
            return;
        }

        //课程结束时间1小时内可以进入教室
        if(e + 3600 - c <= 3600   && yaer == 0  && monther == 0 && date == 0 && e + 3600 - c >= 0){
            teachModel.get(index).enableClass = true;
            //console.log("enterClass4",e + 3600 - c);
            return;
        }

        //当天、当前时间段可以进入教室
        if(e >= c && s <= c  && yaer == 0 && date == 0  && monther == 0){
            //console.log("enterClass5")
            teachModel.get(index).enableClass = true;
            return;
        }
        if(status == 0 && currentDate.getTime() >= startDate.getTime() && currentDate.getTime() <= endDate.getTime())
        {
            teachModel.get(index).enableClass = true;
            return;
        }

        //课程未结束 并且少于1小时可以进入教室
        var status = teachModel.get(index).lessonStatus;
        if(status == 0 && e + 3600 - c <= 3600 && e + 3600 -c >=0 && yaer == 0 && date == 0  && monther == 0){
            //console.log("enterClass6")
            teachModel.get(index).enableClass = true;
            return;
        }
        if((endDate.getTime()-currentDate.getTime()) / 1000 / 60 > -60 && status == 0 && (endDate.getTime() < currentDate.getTime()))
        {
            teachModel.get(index).enableClass = true;
            return;
        }

        teachModel.get(index).enableClass = false;
        //console.log("enterClass7");
        return;
    }

    function disableHasRecord(index,startTime,endTime){
        //查看录播按钮：
        //1）课程提交完成后，系统生成录播，进入教室按钮变更为“查看录播”按钮，点击查看录播进入录播页面；
        //2）临时退出教室，在课程时间段结束1小时后，系统生成录播，进入教室按钮变更为“查看录播”按钮；点击查看录播进入录播页面，
        //3）无录播时按钮disable。
        var lessonStatus = teachModel.get(index).lessonStatus;
        var hasRecord = teachModel.get(index).hasRecord;

        var date = new Date();
        var endDate = new Date(endTime);
        var c = date.getHours() * 3600 + date.getMinutes() * 60 + date.getSeconds();//开始时间
        var e = endDate.getHours() * 3600 + endDate.getMinutes() * 60 + endDate.getSeconds();//课程结束时间

        //课程结束一小时后查看录播
        if(lessonStatus == 1 && hasRecord == 1 && c  - e >= 3600){
            teachModel.get(index).hasRecord = 1;
            teachModel.get(index).enableClass = true;
            return;
        }
        //课程完成并且有课件查看录播
        if(lessonStatus  == 1 && hasRecord == 1){
            teachModel.get(index).hasRecord = 1;
            teachModel.get(index).enableClass = true;
            return;
        }
        //课程完成但是无录播则查看录播禁用
        if(lessonStatus == 1 && hasRecord == 0){
            teachModel.get(index).hasRecord = 0;
            teachModel.get(index).enableClass = false;
            return;
        }
        teachModel.get(index).hasRecord = 0;
    }

    function queryData(){
        lodingView.visible = true;
        netRequest.visible = false;
        askForLeaveButton.visible=false;
        if(keywords == "-1"){
            return;
        }
        keywords = seacheItem.currentText;
        var queryStatus = ""
        if(lessonIndex == 2){
            queryStatus = "4";
        }
        if(lessonIndex == 1){
            queryStatus = "0";
        }
        if(lessonIndex == 3){
            queryStatus = "2";
        }
        if(lessonIndex == 4){
            queryStatus = "1"
        }

        //querySubject = getSubject(comboBoxSubject.currentText);
        var seachPram = {
            "keywords": keywords,
            "pageIndex": pageIndex == 0 ? 1 : pageIndex,
                                          "pageSize": pageSize,
                                          "querySubject": querySubject,
                                          "queryStartDate": currentDate,
                                          "queryEndDate": currentEndDate,
                                          "queryPeriod": queryPeriod,
                                          "queryStatus": queryStatus,
        }
        //console.log()
        pagtingControl.currentPage = pageIndex;
        lessonMgr.getStudentLessonListInfo(seachPram);
        queryPeriod = "ALL";
    }
}

