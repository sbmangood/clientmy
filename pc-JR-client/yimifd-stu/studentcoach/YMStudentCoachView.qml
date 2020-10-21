import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import YMLessonManagerAdapter 1.0
//import QtQuick.Controls.Private 1.0
import "../Configuration.js" as Cfg

/*******全部课程*******/
//学生端课程列表
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
        //获取到了学生课程列表
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
            console.log("==onLessonlistRenewSignal5==")
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
        anchors.horizontalCenter: parent.horizontalCenter
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
        border.width: 1 * widthRates
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
        source: "qrc:/JrImage/empty@3x.png"
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
            height: 100 * widthRates

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
                color: teachListView.currentIndex == index ?  "#F8F8F8" : "#FFFFFF"
                width: parent.width - 20 * widthRate
                height: parent.height - 20 * widthRates
                border.color: "#EEEEEE"  //#99aacc
                border.width: 1
                radius: 8
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
                width: parent.width
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Row{
                    id: oneRow
                    width: 400 * widthRates
                    height: parent.height * 0.5
                    anchors.top:parent.top
                    anchors.topMargin: 10 * widthRates
                    anchors.left: parent.left
                    anchors.leftMargin: 44 * widthRates

                    YMTextControl{
                        width: 200 * widthRates
                        height: parent.height
                        text1: "科目："
                        text2: subjectName
                    }

                    YMTextControl{
                        width: 200 * widthRates
                        height: parent.height
                        text1: "老师："
                        text2: teacherName
                    }

                }

                Row{
                    width: 400 * widthRates
                    height: parent.height * 0.5
                    anchors.top: parent.top
                    anchors.topMargin: 40 * widthRates
                    anchors.left: parent.left
                    anchors.leftMargin: 44 * widthRates

                    YMTextControl{
                        width: 200 * widthRates
                        height: parent.height
                        text1: "课程ID："
                        text2: lessonId
                    }

                    YMTextControl{
                        width: 200 * widthRates
                        height: parent.height

                        text1:{
                            var endTimeArray = endTime.split(" ");
                            return  startTime + "~" + endTimeArray[1]
                        }
                        text2:  ""
                    }

                }

                Image {
                    id: lessonStateImg
                    width: 71 * widthRates
                    height: 71 * widthRates
                    anchors.right: parent.right
                    anchors.rightMargin: parent.width * 0.44
                    anchors.verticalCenter: parent.verticalCenter

                    source: (hasRecord != 1 && enableClass) ? "qrc:/JrImage/sk@2x.png" : getLessonStatusImg(lessonStatus, new Date(startTime).getTime() + lessonSecondCount*1000)
                }

                Row{
                    width: 400 * widthRates
                    height: 44 * widthRates
                    anchors.right: parent.right
                    anchors.rightMargin: 85 * widthRates
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20

                    //占位
                    Item{
                        width: 100 * widthRates
                        height: 44 * widthRates
                        enabled: false
                        anchors.verticalCenter: parent.verticalCenter

                    }

                    //查看课件
                    MouseArea{
                        id: lessonButton
                        width: 100 * widthRates
                        height: 44 * widthRates
                        enabled: hasDoc == 1 ? true : false
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        Rectangle{
                            id:lessonRect
                            radius: 6
                            color: hasDoc == 1 ? "white" : "#E1E1E1"
                            anchors.fill: parent
                            border.width: 1 * widthRates
                            border.color: hasDoc ? "#FF5500" : "#E1E1E1"
                        }

                        Text{
                            id:lessonText
                            text: "查看课件"
                            color: hasDoc ? "#FF5500" : "white"
                            font.bold: Cfg.LESSON_ALL_FONTBOLD
                            font.family: Cfg.LESSON_ALL_FAMILY
                            font.pixelSize: 16 * widthRates
                            anchors.centerIn: parent
                        }
                        onContainsMouseChanged:
                        {
                            if(containsMouse)
                            {
                                lessonRect.color = "#FF874C";
                                lessonRect.border.color = "#FF874C";
                                lessonText.color = "#FFFFFF";
                            }else
                            {
                                lessonRect.color = "white";
                                lessonRect.border.color = "#FF5500";
                                lessonText.color = "#FF5500";
                            }
                        }
                        onClicked: {
                            console.log("stu lessons list look course")
                            console.log("processingMethord = " + processingMethord)
                            lessonRect.color = "#E94E00";
                            lessonRect.border.color = "#E94E00";
                            lessonText.color = "#FFD5C0";
                            var lessonInfo = {
                                "lessonId": lessonId,
                                "startTime": Cfg.analysisDate(startTime),
                                "lessonStatus":lessonStatus
                            };

                            var lessonInfos = {
                                "appId":"3edaf2877c994a4e8739dbe34411e7d7",//"354937763033780224",
                                "appKey":"a995732df99bc794",
                                "roomId":roomId,//"354937763033780224", //教室id
                                "userId": userId, //用户id
                                "userRole": isStudentUser ? "1" : "3",
                                                            "nickName": nameText, //用户昵称或者名字
                                                            "envType": strStage,//运行环境类型，如sit01
                            };
                            if(processingMethord == 0)
                            {
                                lessonMgr.getLookCourse(lessonInfo);//查看旧课件
                            }
                            else if(processingMethord == 1)
                            {
                                lessonMgr.runCourse(lessonInfos); //查看新课件
                            }
                        }
                        onReleased:
                        {
                            if(containsMouse)
                            {
                                lessonRect.color = "#FF874C";
                                lessonRect.border.color = "#FF874C";
                                lessonText.color = "#FFFFFF";
                            }else
                            {
                                lessonRect.color = "white";
                                lessonRect.border.color = "#FF5500";
                                lessonText.color = "#FF5500";
                            }
                        }

                    }

                    //进入教室
                    MouseArea{
                        width: 100 * widthRates
                        height: 44 * widthRates
                        enabled: enableClass ? true : false
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        Rectangle{
                            id:enterRoomRect
                            radius: 6
                            color: hasRecord == 1 ? (enableClass ? "white" : "#E1E1E1") : (enableClass ? "#FF5500" : "#E1E1E1")
                            anchors.fill: parent
                            border.width: 1 * widthRates
                            border.color: enableClass ? "#FF5500" : "#E1E1E1"
                        }

                        Text{
                            id:enterRoomText
                            //"全部课程"中的"进入教室"
                            text:lessonStatus == 1 ? (hasRecord == 0  ? "录播生成中" : "查看录播") : (isStudentUser ? "进入教室" : "进入旁听")
                            //text: hasRecord == 0  ? (isStudentUser ? "进入教室" : "进入旁听") : "查看录播"
                            anchors.centerIn: parent
                            font.bold: Cfg.LESSON_ALL_FONTBOLD
                            font.family: Cfg.LESSON_ALL_FAMILY
                            font.pixelSize: 16 * widthRates
                            color: (hasRecord == 1 && enableClass ==1) ? "#FF5500" : "white"
                        }
                        onContainsMouseChanged:
                        {
                            if(containsMouse)
                            {
                                enterRoomRect.color = "#FF874C";
                                enterRoomRect.border.color = "#FF874C";
                                enterRoomText.color = "#FFFFFF";
                            }else
                            {
                                enterRoomRect.color = hasRecord == 1 ? (enableClass ? "white" : "#E1E1E1") : (enableClass ? "#FF5500" : "#E1E1E1");
                                enterRoomRect.border.color = enableClass ? "#FF5500" : "#E1E1E1";
                                enterRoomText.color = (hasRecord == 1 && enableClass ==1) ? "#FF5500" : "white";
                            }
                        }
                        onPressed: {
                            enterRoomRect.color = "#E94E00";
                            enterRoomRect.border.color = "#E94E00";
                            enterRoomText.color = "#FFD5C0";

                            if(enterClassRoom && lessonStatus == 0){
                                //"全部课程"中, 点击"进入教室", 然后提示: "正在进入教室..."对话框
                                classView.visible = true;
                                classView.tips =  isStudentUser ? "进入教室中..." : "正在进入旁听..."
                            }
                        }

                        onReleased: {
                            if(containsMouse)
                            {
                                enterRoomRect.color = "#FF874C";
                                enterRoomRect.border.color = "#FF874C";
                                enterRoomText.color = "#FFFFFF";
                            }else
                            {
                                enterRoomRect.color = hasRecord == 1 ? (enableClass ? "white" : "#E1E1E1") : (enableClass ? "#FF5500" : "#E1E1E1");
                                enterRoomRect.border.color =  enableClass ? "#FF5500" : "#E1E1E1";
                                enterRoomText.color = (hasRecord == 1 && enableClass ==1) ? "#FF5500" : "white";

                            }

                            var lessonInfos = {
                                "appId":"3edaf2877c994a4e8739dbe34411e7d7",//"354937763033780224",
                                "appKey":"a995732df99bc794",
                                "roomId":roomId,//"354937763033780224", //教室id
                                "userId": userId, //用户id
                                "userRole": isStudentUser ? "1" : "3",
                                                            "nickName": nameText, //用户昵称或者名字
                                                            "envType": strStage,//运行环境类型，如sit01
                            };

                            if(lessonStatus == 0){
                                //console.log("===listen===",enterClassRoom)
                                if(enterClassRoom){
                                    //                                    enterClassRoom = false; //"进入教室"按钮, 一直都可以点击, 因为在classroom程序中, 已经控制了, 只有一个实例
                                    showProcess = 1;
                                    lessonMgr.lessonType = lessonType;
                                    lessonMgr.lessonPlanStartTime = startTime;
                                    lessonMgr.lessonPlanEndTime = endTime;
                                    //lessonMgr.getEnterClass(lessonId,windowView.interNetGrade);//进入教室
                                    console.log("课程类型qml",lessonType);
                                    classView.hideAfterSeconds();
                                    lessonMgr.runClassRoom(lessonInfos);

                                }
                            }else{
                                showProcess = 0;
                                progressbar.currentValue = 0;
                                //lessonMgr.getRepeatPlayer(lessonInfo);//查看录播

                                lessonMgr.runPlayer(lessonInfos);
                            }
                        }
                    }
                    //试听课报告
                    MouseArea{
                        width: 100 * widthRates
                        height: 44 * widthRates
                        visible: userType == "TEA"? lessonReport != 0 : hasReport == 1
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        Rectangle{
                            id:reportRect
                            radius: 6 * widthRates
                            visible: userType == "TEA"? lessonReport != 0 : hasReport == 1
                            color: "white"
                            anchors.fill: parent
                            border.width: 1 * widthRates
                            border.color: "#FF5500"
                        }

                        Text{
                            id:reportText
                            //"全部课程"中的"进入教室"
                            text:{
                                if(userType == "TEA")
                                {
                                    return lessonReport == 1 ? "填写报告" :(lessonReport == 2 ? "试听课报告":" ")
                                }
                                else if(userType == "STU")
                                {
                                    return hasReport == 1 ? "试听课报告" : " "
                                }
                            }

                            anchors.centerIn: parent
                            font.bold: Cfg.LESSON_ALL_FONTBOLD
                            font.family: Cfg.LESSON_ALL_FAMILY
                            font.pixelSize: 16 * widthRates
                            color: "#FF5500"
                        }
                    onContainsMouseChanged:
                    {
                        if(containsMouse)
                        {
                            reportRect.color = "#FF874C";
                            reportRect.border.color = "#FF874C";
                            reportText.color = "#FFFFFF";
                        }else
                        {
                            reportRect.color = "white";
                            reportRect.border.color = "#FF5500";
                            reportText.color = "#FF5500";
                        }
                    }

                    onReleased:
                    {

                        if(containsMouse)
                        {
                            reportRect.color = "#FF874C";
                            reportRect.border.color = "#FF874C";
                            reportText.color = "#FFFFFF";
                        }else
                        {
                            reportRect.color = "white";
                            reportRect.border.color = "#FF5500";
                            reportText.color = "#FF5500";
                        }
                        var lessonInfo = {
                            "userId": userId, //用户id
                            "userRole": (userType == "TEA" ? "0" : (userType == "STU" ? "1" : "2")), //0=老师、1=学生 2=班主任
                            "nickName": nameText, //用户昵称或者名字
                            "envType": strStage,//运行环境类型，如sit01
                            "lessonId":lessonId,
                            "token":windowView.token,
                            "studentId":studentId,
                        };
                        var viewType;
                        if(reportText.text == "试听课报告")//需选择编辑/查看
                        {
                            if(userType == "TEA")
                            {
                                console.log("shitingke ...baogao..")
                                viewType = 1;
                                windowView.showReportView(lessonInfo,viewType);
                            }

                            else {
                                var url = URL_ClassroomReport + lessonId;
                                console.log( "url..." +url);
                                url = url.replace("classroomreport?lessonId","freeTrialResult?classId");
                                url = url + "&report=1";
                                Qt.openUrlExternally(url);
                            }

                        }
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
                            "roomId":items[i].roomId,
                            "lessonStatus":items[i].lessonStatus,
                            "gradeName":items[i].gradeName,
                            "teacherName":items[i].teacherName,
                            "keywords":items[i].keywords,
                            //                            "homeworkStatus":items[i].homeworkStatus,
                            "lessonId":items[i].lessonId,
                            //                            "title":items[i].title,
                            "remaining":items[i].remaining,
                            //                            "hasLesson":items[i].hasLesson,
                            //                            "studentPwd":items[i].studentPwd,
                            "beforeSecond":items[i].beforeSecond,
                            "isShare": 0, //items[i].isShare,
                            "startTime":items[i].startTime,
                            "afterSecond":items[i].afterSecond,
                            "hasDoc": 1,//items[i].hasDoc,
                            "endTime":items[i].endTime,
                            "hasRecord":items[i].hasRecord,
                            "hasComment":items[i].hasComment == undefined ? 1 : items[i].hasComment,
                                                                            "lessonType":items[i].lessonType,
                                                                            "subjectName":items[i].subjectName,
                                                                            "lessonSecondCount":items[i].lessonSecondCount,
                                                                            "processingMethord":items[i].processingMethord,
                                                                            "courseHours": items[i].courseHours == undefined ? "0" : items[i].courseHours,
                                                                                                                               "timerStart": false,
                                                                                                                               "lessonDownText": "",
                                                                                                                               "lessonMsg": "距离上课时间",
                                                                                                                               "status1": "black",//控制文本1颜色
                                                                                                                               "status2": "black",//控制文本2颜色
                                                                                                                               "statusFontSize1": 16,//控制文本1字体大小
                                                                                                                               "statusFontSize2": 16,//控制文本2字体大小
                                                                                                                               "listenFlag": lessonMgr.getLessonComment(items[i].lessonId),
                                                                                                                                "hasReport":items[i].hasReport,
                                                                                                                               "studentId": 0,
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

    function getLessonStatusImg(lessonState, endTime){
        var imgUrl = "";
        if(0 == lessonState)
        {
            var currentDate = new Date();//当前时间

            if(currentDate.getTime() - endTime > 3600*1000)
            {
                imgUrl = "qrc:/JrImage/ygb@2x.png";
            }
            else
            {
                imgUrl = "qrc:/JrImage/wks@2x.png";
            }
        }
        else if(1 == lessonState)
        {
            imgUrl = "qrc:/JrImage/yjs@2x.png";
        }
        else if(2 == lessonState)
        {
            imgUrl = "qrc:/JrImage/qj@2x.png";
        }
        else if(3 == lessonState)
        {
            imgUrl = "qrc:/JrImage/qj@2x.png";
        }
        else if(4 == lessonState)
        {
            imgUrl = "qrc:/JrImage/kk@2x.png";
        }

        return imgUrl;
    }

}

