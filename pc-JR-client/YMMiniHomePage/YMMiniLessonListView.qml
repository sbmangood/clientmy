import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import YMLessonManagerAdapter 1.0
//import QtQuick.Controls.Private 1.0
import "Configuration.js" as Cfg


/*******全部课程*******/
Rectangle {
    focus: true
    id:lessonListView
    property int mark: 0;// 0起始日期 1结束日期
    property int pageIndex: 1;
    property int pageSize: 10;
    property int lessonIndex: -1;
    property int subjectIndex: -1;
    property int showProcess: 0;//0显示课件进度 1显示教室进度

    property string querySubject: "";
    property string queryPeriod : "TODAY";
    property string keywords: "";//搜索传递参数，必须要
    property string currentBufferDay: ""//当前记录的日期
    property string currentDate:"";
    property string currentEndDate: ""//结束日期，必要参数
    property int currentViewType: 1;//2 has end 1 not end 3 search
    property bool hasNextPage: true;
    property int currentPage: 1;
    property bool isFirstLoad: true;

    signal transferPage(var pram);//页面传值信号，必须要
    signal sigInvalidTokens();
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

    //    YMLoadingStatuesView{
    //        id: lodingView
    //        z: 101
    //        anchors.fill: parent
    //        visible: false
    //    }

    //网络显示页面
    YMInterNetView{
        id:netRequest
        z: 189
        visible: false
        anchors.fill: parent
    }

    YMLessonManagerAdapter{
        id: lessonMgr

        onSigGetLessonListDate:
        {
            lodingView.visible = false;
            hasNextPage = lessonData.hasNextPage;
            analysisData(lessonData.list);
        }

        onSigInvalidToken:
        {
            sigInvalidTokens();
        }

        onSigGetDayLessonData:
        {
            //填充数据
            analysisData(dayData);
            calendarControl.enabled = true;
            lodingView.visible = false;
        }

        onSigGetMonthLessonData:
        {
            //重置日历样式
            calendarControl.hasLessonDataLists = monthData;
        }

        //显示错误提示对话框
        onSigMessageBoxInfo:
        {
            console.log("=======YMStudentCoachView.qml onSigMessageBoxInfo========");
            windowView.showMessageBox(strMsg);
        }

        onLessonlistRenewSignal:{
            console.log("==onLessonlistRenewSignal3==")
            classView.visible = false;
            enterClassRoom = true;
            if(isStudentUser){
                queryData();
            }
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

    Image {
        width: parent.width
        height: 252 * heightRate * 0.75
        source: "qrc:/JrImage/miniBackG@2x.png"
        visible: false
    }

    //日历控件
    YMCalendarControl{
        id: calendarControl
        visible: false
        x: (parent.width - width + 10 * heightRate ) / 2
        y: 54 * heightRate * 0.75
        width: parent.width - 10 * heightRate
        z:8


        //        onSigDayClick:
        //        {
        //            //查询当天显示的日期
        //            console.log("sigDayClick",dayData)
        //            getDayLessonData(dayData)
        //            currentBufferDay = dayData;
        //        }

        //        onSigMonthChange:
        //        {
        //            console.log("onSigMonthChange",startDate,endDate)

        //            var year = startDate.getFullYear();
        //            var month = addZero(startDate.getMonth() + 1);
        //            var day = addZero(startDate.getDate());
        //            var tempbookDate = year + "/" + month + "/" + day ;

        //            year = endDate.getFullYear();
        //            month = addZero(endDate.getMonth() + 1);
        //            day = addZero(endDate.getDate());
        //            var tempbookDateTwo = year + "/" + month + "/" + day ;

        //            //查询当月的是否有课状况
        //            //查询
        //            lessonMgr.getMonthLessonData(tempbookDate,tempbookDateTwo);
        //            // ["2019-10-01", "2019-10-02", "2019-10-29", "2019-10-22", "2019-10-23", "2019-10-09", "2019-10-16"];



        //        }

    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: 30 * heightRate
        anchors.right: parent.right
        anchors.rightMargin: 52 * heightRate
        text: "课程表>"
        font.family:"Microsoft YaHei"
        font.pixelSize: 16 * heightRate
        z: 67
        color: "#FF6643"
        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                lessonListView.visible = false;
            }
        }
    }
    MouseArea
    {
        id:tempMouseArea
        x: (parent.width - width) / 2
        y: 54 * heightRate * 0.75
        z:10
        width: calendarControl.width
        height: calendarControl.height
        anchors.fill: parent
        hoverEnabled: true
        enabled: false
        onClicked:
        {
            enabled = false
            calendarControl.enabled = true;
        }

    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: 45 * heightRate * 0.75
        anchors.left: parent.left
        anchors.leftMargin: 32 * heightRate * 0.75
        text: "未结束"
        font.family:"Microsoft YaHei"
        font.pixelSize: 14 * heightRate
        z: 67
        color: currentViewType == 1 ? "#FF6640" : "#666666"
        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                currentViewType = 1;
                teachModel.clear();
                getLessonList( "","",1,1 ,6,"-1" );
            }
        }
    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: 45 * heightRate * 0.75
        anchors.left: parent.left
        anchors.leftMargin: 130 * heightRate * 0.75
        text: "已结束"
        font.family:"Microsoft YaHei"
        font.pixelSize: 14 * heightRate
        z: 67
        color: currentViewType == 2 ? "#FF6640" : "#666666"

        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                currentViewType = 2;
                teachModel.clear();
                getLessonList( "","",2,1 ,6,"-1" );
            }
        }
    }
    Rectangle{
        border.color: "#EEEEEE"
        border.width: 1
        width: 330 * heightRate
        height: 35 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 25 * heightRate * 0.75
        anchors.right: parent.right
        anchors.rightMargin: 330 * heightRate
        Image {
            height: 20 * heightRate
            width: height * 36 / 40
            anchors.left: parent.left
            anchors.leftMargin: 12 * heightRate
            source: "qrc:/images/search@2x.png"
            anchors.verticalCenter: parent.verticalCenter
            z:5
            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    console.log("filterText.text",filterText.text)
                    if(filterText.text != "")
                    {
                        currentViewType = 3;
                        teachModel.clear();
                        getLessonList( "","",-1,1 ,6,filterText.text);
                    }
                }
            }
        }

        TextField{
            id: filterText
            width: 280 * heightRate
            height: 33 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 4 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            //menu:null
            font.family: Cfg.LESSON_ALL_FAMILY
            font.pixelSize: Cfg.LESSON_ALL_FONTSIZE * heightRate
            placeholderText: "请输入课程编号"
            validator: RegExpValidator{regExp:/^[0-9]*$/}
            style: TextFieldStyle{
                background: Rectangle{
                    anchors.fill: parent
                    border.color: "#EEEEEE"
                    border.width: 0
                }
                placeholderTextColor: "#999999"
            }
        }
    }

    Rectangle
    {
        id:splitLine
        anchors.top: parent.top
        anchors.topMargin: 95 * heightRate * 0.75
        width: parent.width - 28 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        height: 1
        color: "#EEEEEE"
        z: 67
    }

    ListView{
        id: teachListView
        clip: true
        width: parent.width - 10 * heightRate //1170 * heightRate * 0.75
        height: parent.height - 180 * heightRate//485 * heightRate * 0.75
        anchors.left: parent.left
        anchors.leftMargin: 13 * heightRate * 0.75
        anchors.top: splitLine.bottom
        anchors.topMargin: 26 * heightRate * 0.75
        model: teachModel
        delegate: teachDelegate
        currentIndex: -1

        onAtYEndChanged:
        {
            if(!teachListView.atYEnd)
            {
                return;
            }
            if(isFirstLoad)
            {
                isFirstLoad = false;
                return;
            }
            console.log("onAtYEndChanged",teachListView.atYEnd,currentPage,hasNextPage)

            if(hasNextPage)
            {
                var tempPage = currentPage + 1;
                if(currentViewType == 1)
                {
                    getLessonList( "","",1,tempPage,6,"-1" );
                    console.log("onAtYEndChanged has data 1",teachListView.atYEnd,currentPage)
                }else if(currentViewType == 2)
                {
                    getLessonList( "","",2,tempPage,6,"-1" );
                    console.log("onAtYEndChanged has data 2",teachListView.atYEnd,currentPage)
                }
            }else
            {
                getLessonList( "","",1,currentPage + 1,6,"-1" );
                console.log("onAtYEndChanged no data",teachListView.atYEnd)
            }
        }

    }

    //背景图片
    Image{
        id: backgImage
        width: 546 * heightRate * 0.3
        height: 681 * heightRate * 0.3
        anchors.centerIn: parent
        visible: teachModel.count == 0 ? !lodingView.visible : false
        z:100
        fillMode: Image.PreserveAspectFit
        source: "qrc:/JrImage/empty@3x.png"
    }

    ListModel{
        id: teachModel
    }

    Component{
        id: teachDelegate

        Item{
            width: teachListView.width
            height: 114 * heightRate

            Rectangle{
                id: contentItem
                color: "#F8F8F8"
                width: parent.width - 20 * widthRate
                height: parent.height - 10 * heightRate
                border.color: "#EEEEEE"
                border.width: 1
                radius: 6 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            //直播显示图
            Rectangle{
                width: height * ( 43 / 24 )
                height: parent.height / ( 114 / 24 )
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                anchors.topMargin: 23 * heightRate * 0.75
                anchors.leftMargin: 16 * heightRate * 0.75
                color: "#F7AB4A"
                radius: 1

                Text {
                    anchors.centerIn: parent
                    font.family: Cfg.LESSON_ALL_FAMILY
                    font.pixelSize: 14 * heightRate
                    color: "white"
                    text:
                    {
                        if(type == 0)
                        {
                            return "1对1"
                        }else if (type == 1)
                        {
                            return "1对6"
                        }else if (type == 2)
                        {
                            return "1对12"
                        }else if (type == 3)
                        {
                            return "大班课"
                        }
                    }
                }
            }

            Text {
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                anchors.topMargin: 25 * heightRate * 0.75
                anchors.leftMargin: 92 * heightRate * 0.75
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 16 * heightRate
                color: "#333333"
                text: lessonName
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 410 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 16 * heightRate
                color: "#858585"
                text: "授课老师："  + teacherName
            }

            Text {
                id:lessonDateText
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                anchors.topMargin: 85 * heightRate * 0.75
                anchors.leftMargin: 18 * heightRate * 0.75
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 17 * heightRate
                color: "#999999"
                text: lessonDate
            }

            Text {
                anchors.top: contentItem.top
                anchors.left: lessonDateText.right
                anchors.topMargin: 85 * heightRate * 0.75
                anchors.leftMargin: 18 * heightRate
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 17 * heightRate
                color: "#999999"
                text: "课程ID:" + liveRoomId
            }

            //进入教室 查看课件
            Row{
                id: buttonRow
                width: parent.width * 0.24
                height: parent.height / (114 / 44)
                anchors.top:parent.top
                anchors.topMargin: 38 * heightRate
                anchors.right: parent.right
                spacing: 20 * heightRate

                //进入教室
                Rectangle
                {
                    height:  parent.height
                    width: height * (115 / 44)
                    color: enterRoomOrEnterRocordEnable ? "#19ABFF" : "#F1F1F1"
                    radius: 5 * heightRate
                    Text {
                        anchors.top: parent.top
                        anchors.topMargin: 2 * heightRate
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: Cfg.LESSON_ALL_FAMILY
                        font.pixelSize: 15 * heightRate
                        color: enterRoomOrEnterRocordEnable ?  "white" : "#999999"
                        text: !lessonHasEnd ? "云课堂" : "课程回放"
                    }

                    Text {
                        anchors.top: parent.top
                        anchors.topMargin: 22 * heightRate
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: Cfg.LESSON_ALL_FAMILY
                        font.pixelSize: 12 * heightRate
                        color: enterRoomOrEnterRocordEnable ?  "white" : "#999999"
                        text: !lessonHasEnd ? ( enterRoomOrEnterRocordEnable ? "进入教室" : "未开始" ) : "查看录播"
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: enterRoomOrEnterRocordEnable

                        onReleased: {
                            var lessonInfo = {
                                "appId":"3edaf2877c994a4e8739dbe34411e7d7",//"354937763033780224",
                                "appKey":"a995732df99bc794",//"354937763033780224",
                                "roomId":liveRoomId,//"354937763033780224", //教室id
                                "userId": userType == "TEA" ? teacherId : userId, //用户id
                                                              "userRole": (userType == "TEA" ? "0" : (userType == "STU" ? "1" : "2")), //0=老师、1=学生 2=班主任
                                                              "nickName":userType == "TEA" ? teacherName : nickName, //用户昵称或者名字
                                                                                             "envType": strStage,//运行环境类型，如sit01
                            };
                            console.log("enterRoomClick3:",JSON.stringify(lessonInfo),userType,isStageEnvironment,calendarControl.currentDaytext)

                            if(!lessonHasEnd){
                                classView.visible = true;
                                classView.tips =   "正在进入教室..."
                                lessonMgr.runClassRoom(lessonInfo);
                            }else{
                                //查看录播
                                lessonMgr.runPlayer(lessonInfo);
                            }
                        }
                    }
                }

                //学习资料
                Rectangle
                {
                    height:  parent.height
                    width: height * (115 / 44)
                    color: hasDoc ? "#19ABFF" : "#F1F1F1"
                    radius: 5 * heightRate
                    border.color: "#EEEEEE"
                    Text {
                        anchors.top: parent.top
                        anchors.topMargin: 2 * heightRate
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: Cfg.LESSON_ALL_FAMILY
                        font.pixelSize: 15 * heightRate
                        color: hasDoc ? "white" : "#999999"
                        text: "学习资料"
                    }

                    Text {
                        anchors.top: parent.top
                        anchors.topMargin: 22 * heightRate
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: Cfg.LESSON_ALL_FAMILY
                        font.pixelSize: 12 * heightRate
                        color: hasDoc ?  "white" : "#999999"
                        text: hasDoc ? "点击查看" : "未发布"
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: hasDoc
                        onClicked: {
                            console.log("查看学习资料3",isStageEnvironment,strStage)

                            var lessonInfo = {
                                "roomId": liveRoomId, //教室id
                                "appId":"3edaf2877c994a4e8739dbe34411e7d7",
                                "appKey":"a995732df99bc794",
                                "envType": strStage,//运行环境类型，如sit01
                                "processingMethord":processingMethord,
                            };
                            lessonMgr.runCourse(lessonInfo);
                        }
                    }
                }

            }

            Timer{
                id: timeClock
                interval: 1000
                running: startTimer
                repeat: true
                onTriggered: {
                    --beforeDiff;
                    --afterDiff;
                    if(beforeDiff<= 0 && afterDiff >= 0)
                    {
                        enterRoomOrEnterRocordEnable = true;
                    }else
                    {
                        enterRoomOrEnterRocordEnable = false;
                        if( afterDiff <= 0 )
                        {
                            startTimer = false;
                        }
                    }

                }
            }

        }
    }

    // 滚动条
    Item {
        id: scrollbar
        visible: teachModel.count > 5 ? true : false
        width: 8
        height: teachListView.height
        anchors.right: parent.right
        anchors.top: splitLine.bottom
        anchors.topMargin: 26 * heightRate * 0.75
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
    MouseArea{
        id: lodingView
        anchors.fill: parent
        visible: false
        z:1118
        onClicked: {
            console.log("===loding::check===")
            return;

        }
        AnimatedImage{
            id: nameImage
            width: 18 * heightRate
            height: 18 * heightRate
            source: ""
            anchors.centerIn: parent
        }
        onVisibleChanged:
        {
            if(visible)
            {
                nameImage.source="qrc:/images/loading.gif"
            }else
            {
                nameImage.source = "";
            }
        }
    }
    Component.onCompleted: {
        //        //获取当天课程情况
        //        var tempDate = new Date();
        //        var year = tempDate.getFullYear();
        //        var month = addZero(tempDate.getMonth() + 1);
        //        var day = addZero(tempDate.getDate());
        //        var tempbookDate = year + "/" + month + "/" + day ;
        //        currentBufferDay = tempbookDate;
        //        getDayLessonData(tempbookDate);

        getLessonList( "","",1,1 ,6,"-1" );
    }

    function getLessonList( startDay,endDay,opationType,pageNum ,pageSize,roomId )
    {
        lodingView.visible = true;
        currentPage = pageNum;
        lessonMgr.getMiniClassLessonList( startDay,endDay,opationType,pageNum ,pageSize,roomId );
    }

    function refreshPage(){
        getDayLessonData(currentBufferDay);
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

    function getDayLessonData(dayData)
    {
        if(interNetGrade == 0)
        {
            netRequest.visible = true;
            return;
        }
        netRequest.visible = false;

        lodingView.visible = true;
        lodingView.focus = true;
        calendarControl.enabled = false;
        //获取数据
        lessonMgr.getDayLessonData(dayData);
    }

    function analysisData(lessonData){
        if(interNetGrade == 0)
        {
            netRequest.visible = true;
            return;
        }
        netRequest.visible = false;
        //teachModel.clear();
        for(var i = 0; i < lessonData.length; i++){
            //            var bookDate = lessonData[i].bookDate.replace("T00:00:00","");

            //            var tempbookDate = bookDate;
            //            var tempBookTime = lessonData[i].bookTime
            //            var startTime = "";
            //            var endTime = "";
            //            if(tempBookTime.split("-").length == 2)
            //            {
            //                startTime = tempbookDate + " " + tempBookTime.split("-")[0];
            //                endTime = tempbookDate + " " + tempBookTime.split("-")[1];
            //            }

            //console.log("lessonTime ",tempbookDate,tempBookTime,bookDate,lessonData[i].bookDate)


            var lessonHasEnd = false;

            if(lessonData[i].status == 2 ||lessonData[i].status == 3 )
            {
                lessonHasEnd = true;
            }

            var startDate = new Date(lessonData[i].startTime).getTime();
            var endDate = new Date(lessonData[i].endTime).getTime();
            var currentDate = new Date().getTime();

            var startTimer = true;//是否开启定时器刷新进入课堂
            var enterRoomOrEnterRocordEnable = false;//进入教室 或者查看录播是否可用

            var hasDoc = lessonData[i].resourceCount > 0 ? true : false;//字段未给

            var hasRecord  = lessonData[i].status == 3 ? true : false;

            var startDateT = lessonData[i].startTime;
            var endDateT = lessonData[i].endTime;
            var lessonDate = startDateT;
            if(startDateT.split(":").length == 3)
            {
                lessonDate = startDateT.split(":")[0] + ":" + startDateT.split(":")[1];
            }

            if(endDateT.split(":").length == 3 && endDateT.split(" ").length == 2)
            {
                lessonDate = lessonDate +　"-";
                var tempString = endDateT.split(" ")[1];
                lessonDate =  lessonDate + tempString.split(":")[0] + ":" + tempString.split(":")[1];
            }
            console.log("analysisData",lessonDate,lessonHasEnd,hasDoc,hasRecord,new Date(lessonData[i].startTime),new Date(lessonData[i].endTime),startDate,endDate,currentDate)

            // 1.判断课程是否已经结束
            if(lessonHasEnd)
            {
                startTimer = false;
                if(hasRecord == 0)
                {
                    enterRoomOrEnterRocordEnable = false;
                }else
                {
                    enterRoomOrEnterRocordEnable = true;
                }
            }else
            {
                startTimer = true;

                if(lessonData[i].beforeDiff<= 0 && lessonData[i].afterDiff >= 0)
                {
                    enterRoomOrEnterRocordEnable = true;
                }else
                {
                    enterRoomOrEnterRocordEnable = false;
                }

            }

            teachModel.append(
                        {
                            "studentId": "studentId",
                            "studentName":"studentName",
                            "teacherId":lessonData[i].teacherId,
                            "teacherName":lessonData[i].teacherName,
                            "startTime":lessonData[i].startTime,
                            "endTime":lessonData[i].endTime,
                            "type":lessonData[i].type,
                            "status":lessonData[i].status,//预约排课状态 0 未开始 1 上课中 2 已结束
                            "subjectName":"subjectName",
                            "gradeName":"gradeName",
                            "liveRoomId": lessonData[i].liveRoomId,
                            "lessonName": lessonData[i].lessonName,
                            "hasRecord":hasRecord,
                            "hasDoc":hasDoc,
                            "lessonHasEnd":lessonHasEnd,
                            "startTimer":startTimer,
                            "enterRoomOrEnterRocordEnable":enterRoomOrEnterRocordEnable,
                            "lessonDate":lessonDate,
                            "beforeDiff":lessonData[i].beforeDiff,
                            "afterDiff":lessonData[i].afterDiff

                        })
        }

    }

    function queryData()
    {
        refreshPage();
    }

}

