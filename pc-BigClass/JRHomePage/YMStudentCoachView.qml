import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import YMLessonManagerAdapter 1.0
//import QtQuick.Controls.Private 1.0
import "Configuration.js" as Cfg


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
    property string currentBufferDay: ""//当前记录的日期
    property string currentDate:"";
    property string currentEndDate: ""//结束日期，必要参数

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
            console.log("==onLessonlistRenewSignal==")
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
        source: "qrc:/JrImage/ditu@3x.png"
        visible: !netRequest.visible
    }

    //日历控件
    YMCalendarControl{
        id: calendarControl
        visible: true
        x: (parent.width - width) / 2
        y: 54 * heightRate * 0.75
        z:8


        onSigDayClick:
        {
            //查询当天显示的日期
            console.log("sigDayClick",dayData)
            getDayLessonData(dayData)
            currentBufferDay = dayData;
        }

        onSigMonthChange:
        {
            console.log("onSigMonthChange",startDate,endDate)

            var year = startDate.getFullYear();
            var month = addZero(startDate.getMonth() + 1);
            var day = addZero(startDate.getDate());
            var tempbookDate = year + "/" + month + "/" + day ;

            year = endDate.getFullYear();
            month = addZero(endDate.getMonth() + 1);
            day = addZero(endDate.getDate());
            var tempbookDateTwo = year + "/" + month + "/" + day ;

            //查询当月的是否有课状况
            //查询
            lessonMgr.getMonthLessonData(tempbookDate,tempbookDateTwo);
            // ["2019-10-01", "2019-10-02", "2019-10-29", "2019-10-22", "2019-10-23", "2019-10-09", "2019-10-16"];



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
        anchors.topMargin: 585 * heightRate * 0.75
        anchors.left: parent.left
        anchors.leftMargin: 32 * heightRate * 0.75
        text: "当日课程情况"
        font.family:"Microsoft YaHei"
        font.pixelSize: 14 * heightRate
        z: 67
        color: "#333333"
    }
    Rectangle
    {
        id:splitLine
        anchors.top: parent.top
        anchors.topMargin: 625 * heightRate * 0.75
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
        height: parent.height - 520 * heightRate//485 * heightRate * 0.75
        anchors.left: parent.left
        anchors.leftMargin: 13 * heightRate * 0.75
        anchors.top: splitLine.bottom
        anchors.topMargin: 26 * heightRate * 0.75
        model: teachModel
        delegate: teachDelegate
        currentIndex: -1
    }

    //背景图片
    Image{
        id: backgImage
        width: 546 * heightRate * 0.3
        height: 681 * heightRate * 0.3
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 110 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        visible: teachModel.count == 0
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
            Image{
                width: height * ( 43 / 24 )
                height: parent.height / ( 114 / 24 )
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                anchors.topMargin: 23 * heightRate * 0.75
                anchors.leftMargin: 16 * heightRate * 0.75
                source: "qrc:/JrImage/zhibo@3x.png"

                Text {
                    anchors.centerIn: parent
                    font.family: Cfg.LESSON_ALL_FAMILY
                    font.pixelSize: 14 * heightRate
                    color: "#333333"
                    text: "直播"
                }
            }

            //当天时间
            Text {
                id:currentDayTexts
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                anchors.topMargin: 25 * heightRate * 0.75
                anchors.leftMargin: 92 * heightRate * 0.75
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 16 * heightRate
                color: "#333333"
                text:
                {
                    var tempDate = bookDate;
                    if(bookDate.split("-").length == 3)
                    {
                        tempDate = bookDate.split("-")[1] + "月" + bookDate.split("-")[2] + "日"
                        return tempDate
                    }
                    return bookDate;
                }
            }

            //当前课程时间段
            Text {
                id:lessonTimeText
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                anchors.topMargin: 26 * heightRate * 0.75
                anchors.leftMargin: 222 * heightRate * 0.75
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 16 * heightRate
                color: "#666666"
                text: bookTime
            }

            //科目显示图
            Image{
                width: height * ( 135 / 57 )
                height: parent.height / ( 114 / 17 )
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                anchors.topMargin: 30 * heightRate * 0.75
                anchors.leftMargin: 410 * heightRate * 0.75
                source: "qrc:/JrImage/shuxue@3x.png" //物理 qrc:/JrImage/workList.png

                Text {
                    anchors.centerIn: parent
                    font.family: Cfg.LESSON_ALL_FAMILY
                    font.pixelSize: 11 * heightRate
                    color: "#ffffff"
                    text: subjectName
                }
            }

            //授课老师
            Text {
                id:lessonTeacherText
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                anchors.topMargin: 85 * heightRate * 0.75
                anchors.leftMargin: 18 * heightRate * 0.75
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 17 * heightRate
                color: "#999999"
                text: "授课老师： " + teacherName
            }

            //进入教室 查看课件
            Row{
                id: buttonRow
                width: parent.width * 0.32
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
                                "appId":"kiFBIeLYvxOuWFgwWOy1XFFFehdA2ovo",//"354937763033780224",
                                "appKey":"L6X0TIPFLQGkwEKM",//"354937763033780224",
                                "roomId":liveRoom.id,//"354937763033780224", //教室id
                                "userId": userType == "TEA" ? teacherId : studentId, //用户id
                                                              "userRole": (userType == "TEA" ? "0" : (userType == "STU" ? "1" : "2")), //0=老师、1=学生 2=班主任
                                                              "nickName":userType == "TEA" ? teacherName : studentName, //用户昵称或者名字
                                                                                             "envType": strStage,//运行环境类型，如sit01
                            };

                            if(!lessonHasEnd){
                                console.log("enterRoomClick:",userType,isStageEnvironment,calendarControl.currentDaytext)
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
                            console.log("查看学习资料",isStageEnvironment,strStage)

                            var lessonInfo = {
                                "roomId": liveRoom.id, //教室id
                                "appId":"7169a6c5ab5b4eeba2ca37b831fb9239",
                                "appKey":"yimi_324122469776515704_ccb123456_m9if1K_1566806110610",
                                "envType": strStage,//运行环境类型，如sit01
                            };
                            lessonMgr.runCourse(lessonInfo);
                        }
                    }
                }

            }

            Timer{
                id: timeClock
                interval: 2000
                running: startTimer
                repeat: true
                onTriggered: {
                    var startDate = new Date(startTime).getTime();
                    var endDate = new Date(endTime).getTime();
                    var currentDate = new Date().getTime();
                    if(currentDate <= endDate && startDate <=  currentDate)
                    {
                        enterRoomOrEnterRocordEnable = true;
                    }else
                    {
                        enterRoomOrEnterRocordEnable = false;
                        startTimer =  false;
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
        //获取当天课程情况
        var tempDate = new Date();
        var year = tempDate.getFullYear();
        var month = addZero(tempDate.getMonth() + 1);
        var day = addZero(tempDate.getDate());
        var tempbookDate = year + "/" + month + "/" + day ;
        currentBufferDay = tempbookDate;
        getDayLessonData(tempbookDate);
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
         teachModel.clear();
        for(var i = 0; i < lessonData.length; i++){
            var bookDate = lessonData[i].bookDate.replace("T00:00:00","");

            var tempbookDate = bookDate;
            var tempBookTime = lessonData[i].bookTime
            var startTime = "";
            var endTime = "";
            if(tempBookTime.split("-").length == 2)
            {
                startTime = tempbookDate + " " + tempBookTime.split("-")[0];
                endTime = tempbookDate + " " + tempBookTime.split("-")[1];
            }

            var liveRoom = lessonData[i].liveRoom;
            console.log("lessonTime ",tempbookDate,tempBookTime,bookDate,lessonData[i].bookDate)
            if(lessonData[i].liveRoom == undefined ||liveRoom.id == undefined || liveRoom.status == undefined )
            {
                console.log("课程数据有误",JSON.stringify( liveRoom) );
                continue;
            }

            var lessonHasEnd = false;

            if(liveRoom.status == 2 || liveRoom.status == 3 )
            {
                lessonHasEnd = true;
            }

            var startDate = new Date(startTime).getTime();
            var endDate = new Date(endTime).getTime();
            var currentDate = new Date().getTime();

            var startTimer = true;//是否开启定时器刷新进入课堂
            var enterRoomOrEnterRocordEnable = false;//进入教室 或者查看录播是否可用

            var hasDoc = true;//字段未给

            var hasRecord  = liveRoom.status == 3 ? false : true;

            console.log("analysisData",lessonHasEnd,hasDoc,hasRecord,new Date(startTime),new Date(endTime),startTime,endTime,startDate,endDate,currentDate)

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
                if(currentDate > endDate)
                {
                    startTimer = false;
                    enterRoomOrEnterRocordEnable = false;
                }else
                {
                    startTimer = true;
                    if(currentDate <= endDate && startDate <=  currentDate)
                    {
                        enterRoomOrEnterRocordEnable = true;
                    }else
                    {
                        enterRoomOrEnterRocordEnable = false;
                    }
                }
            }

            teachModel.append(
                        {
                            "lessonId":lessonData[i].id,
                            "studentId": lessonData[i].studentId,
                            "studentName":lessonData[i].studentName,
                            "teacherId":lessonData[i].teacherId,
                            "teacherName":lessonData[i].teacherName,
                            "bookDate":tempbookDate,
                            "bookTime":tempBookTime,
                            "startTime":startTime,
                            "endTime":endTime,
                            "createTime":lessonData[i].createTime,
                            "status":lessonData[i].status,//预约排课状态
                            "subjectName":lessonData[i].subject,
                            "gradeName":lessonData[i].grade,
                            "ifConfirm":lessonData[i].ifConfirm,//是否确认
                            //"confirmTime":"confirmTime",
                            "operator": lessonData[i].operator,
                            "liveRoom": lessonData[i].liveRoom,
                            "hasRecord":hasRecord,
                            "hasDoc":hasDoc,
                            "lessonHasEnd":lessonHasEnd,
                            "startTimer":startTimer,
                            "enterRoomOrEnterRocordEnable":enterRoomOrEnterRocordEnable,
                        })
        }

    }
    function queryData()
    {
        refreshPage();
    }

}

