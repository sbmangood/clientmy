import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import YMLessonManagerAdapter 1.0
//import QtQuick.Controls.Private 1.0
import "Configuration.js" as Cfg


/*******全部课程*******/
// 课程表页,学生教师通用
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
    property string currentBufferMonth:"" ;

    property var currentLessonId//当前的lessonId
    property var currentLessonReport//当前的lessonReport

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
        //接收到某一天的课程数据
        onSigGetDayLessonData:
        {
            //解析和填充数据
            analysisData(dayData);
            calendarControl.enabled = true;
            lodingView.visible = false;
        }
        //接收到当月有课程的日期
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
            console.log("==onLessonlistRenewSignal2==")
            classView.visible = false;
            enterClassRoom = true;
            updateTime.start()
//            queryData();
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
        source: "qrc:/JrImage/banner_lan@2x.png"
        visible: !netRequest.visible
    }

    //日历控件
    YMCalendarControl{
        id: calendarControl
        visible: true
        x: (parent.width - width ) / 2
        y: 16 * heightRate * 0.75
        width: parent.width - 10 * heightRate
        z:8

        //点击日历某一天之后
        onSigDayClick:
        {
            //查询当天显示的日期
            console.log("sigDayClick",dayData)
            getDayLessonData(dayData)
            currentBufferDay = dayData;
        }

        //改变日历的月份之后
        onSigMonthChange:
        {
            //日历表的起始日期,结束日期,月最后一天日期
            console.log("onSigMonthChange",startDate,endDate,currentVisibleDate)

            var year = currentVisibleDate.getFullYear();
            var month = addZero(currentVisibleDate.getMonth() + 1);
            var day = addZero(currentVisibleDate.getDate());
            var tempbookDate = year + "-" + month + "-" + day ;
            currentBufferMonth = tempbookDate;
            //查询当月的是否有课状况
            //查询
            //lessonMgr.getMonthLessonData(tempbookDate,tempbookDateTwo);
            lessonMgr.getCurrentMonthLessonData(tempbookDate);
            // ["2019-10-01", "2019-10-02", "2019-10-29", "2019-10-22", "2019-10-23", "2019-10-09", "2019-10-16"];
        }

    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: 68 * heightRate
        anchors.right: parent.right
        anchors.rightMargin: 52 * heightRate
        text: "课程列表>"
        font.family:"Microsoft YaHei"
        font.pixelSize: 16 * heightRate
        z: 67
        color: "#FF6643"
        visible: false
        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                miniLessonListView.visible = true;
            }
        }
    }


    Text {
        anchors.top: parent.top
        anchors.topMargin: 562 * heightRate * 0.75
        anchors.left: parent.left
        anchors.leftMargin: 26 * heightRate * 0.75
        text: "当日课程"
        font.family:"Microsoft YaHei"
        font.pixelSize: 20 * heightRate
        z: 67
        color: "#333333"
    }
    Rectangle
    {
        id:splitLine
        anchors.top: parent.top
        anchors.topMargin: 590 * heightRate * 0.75
        width: parent.width - 28 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        height: 1
        color: "#EEEEEE"
        z: 67
        visible: false
    }

    ListView{
        id: teachListView
        clip: true
        width: parent.width //1170 * heightRate * 0.75
        height: parent.height - 520 * heightRate//485 * heightRate * 0.75
        anchors.left: parent.left
        //anchors.leftMargin: 5 * heightRate * 0.75
        anchors.top: splitLine.bottom
        anchors.topMargin: 26 * heightRate * 0.75
        model: teachModel
        delegate: teachDelegate
        currentIndex: -1
        spacing: 12 * heightRate
    }

    //没有课程时显示的背景图片
    Image{
        id: backgImage
        width: 324 * heightRate * 0.45
        height: 334 * heightRate * 0.45
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        visible: teachModel.count == 0
        z:100
        fillMode: Image.PreserveAspectFit
        source: "qrc:/JrImage/empty@3x.png"
    }

    //存课程列表的model
    ListModel{
        id: teachModel
    }

    //显示课程列表信息的控件
    Component{
        id: teachDelegate

        Item{
            width: teachListView.width
            height: 114 * heightRate

            Rectangle{
                id: contentItem
                color: "#FFFFFF"
                width: parent.width - 20 * widthRate
                height: parent.height - 10 * heightRate
                border.color: "#EEEEEE"
                border.width: 1
                radius: 10 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            //直播显示图
            Text{
                width: height * ( 43 / 24 )
                height: parent.height / ( 114 / 24 )
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                anchors.topMargin: 23 * heightRate * 0.75
                anchors.leftMargin: 16 * heightRate * 0.75
                color: "#F7AB4A"
                text:"科目："
                visible: false
            }

            Text {
                id:subjectText
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                anchors.topMargin: 28 * heightRate * 0.75
                anchors.leftMargin: 26 * widthRate * 0.9
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 18 * heightRate
                color: "#999999"
                text: "科目: "// + lessonName + (userType == "TEA" ? ((lessonType == 0 || lessonType == 1) ? (subjectName != "演示" ? "(试)" : "") : (lessonType == 5 ? "(面)" : "(订)")) : "")
            }
            //科目名称
            Text {
                anchors.top: contentItem.top
                anchors.left: subjectText.left
                anchors.topMargin: 28 * heightRate * 0.75
                anchors.leftMargin: 38 * widthRate * 0.9
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 18 * heightRate
                color: "#666666"
                text: lessonName + (userType == "TEA" ? ((lessonType == 0 || lessonType == 1) ? (subjectName != "演示" ? "(试)" : "") : (lessonType == 5 ? "(面)" : "(订)")) : "")
            }


            Text {
                id:userNameText
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                anchors.topMargin: 28 * heightRate * 0.75
                anchors.leftMargin: 215 * widthRate * 0.9
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 18 * heightRate
                color: "#999999"
                text: userType == "TEA" ? ("学生: ") : ("授课老师: ")
            }
            //教师或学生名称
            Text {
                anchors.top: contentItem.top
                anchors.left: userNameText.left
                anchors.topMargin: 28 * heightRate * 0.75
                anchors.leftMargin: userType == "TEA" ?  38 * widthRate * 0.9 : 61 * widthRate * 0.9
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 18 * heightRate
                color: "#666666"
                text: userType == "TEA" ? (childName) : (teacherName)
            }

            Text {
                id:lessonIdText
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                anchors.topMargin: 82 * heightRate * 0.75
                anchors.leftMargin: 26 * widthRate * 0.9
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 18 * heightRate
                color: "#999999"
                text: "课程ID: "
            }
            //课程时间
            Text {
                id:lessonDateText
                anchors.top: contentItem.top
                anchors.left: contentItem.left
                anchors.topMargin: 82 * heightRate * 0.75
                anchors.leftMargin: 215 * widthRate * 0.9
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 18 * heightRate
                color: "#999999"
                text: lessonDateShowText
            }
            //课程ID值
            Text {
                anchors.top: contentItem.top
                anchors.left: lessonIdText.left
                anchors.topMargin: 82 * heightRate * 0.75
                anchors.leftMargin: 50 * widthRate * 0.9
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 18 * heightRate
                color: "#666666"
                text: lessonId
            }

            Image {
                width: parent.height - 12 * widthRate
                height: width
                source: {
                    var tempSource = "qrc:/JrImage/sk@2x.png";//进行中图片
                    if(lessonStatus == 0)
                    {
                        if(enterRoomOrEnterRocordEnable)
                        {
                            tempSource = "qrc:/JrImage/sk@2x.png";//进行中图片
                        }else
                        {
                            if(startTimer)
                            {
                                tempSource = "qrc:/JrImage/wks@2x.png";//未开始
                            }else
                            {
                                tempSource = "qrc:/JrImage/ygb@2x.png";//已关闭
                            }
                        }
                    }else if(lessonStatus == 1)
                    {
                        tempSource = "qrc:/JrImage/yjs@2x.png";//已结束
                    }else if(lessonStatus == 2 || lessonStatus == 3)
                    {
                        tempSource = "qrc:/JrImage/qj@2x.png";//请假
                    }else if(lessonStatus == 4)
                    {
                        tempSource = "qrc:/JrImage/kk@2x.png";//旷课
                    }
                    return tempSource;

                }

                //anchors.top: contentItem.top
                anchors.right: parent.right
                anchors.rightMargin: parent.width * 0.43
                anchors.verticalCenter: parent.verticalCenter
                visible: true
            }

            //进入教室 查看课件 试听课报告
            Row{
                id: buttonRow
                width: 400 * widthRates
                height: 44 * widthRates
                anchors.right: parent.right
                anchors.rightMargin: 85 * widthRates
                anchors.verticalCenter: parent.verticalCenter
                spacing: 16 * widthRates

                //占位
                Item{
                    height:  parent.height
                    width: height * (115 / 44)
                    enabled: false
                    anchors.verticalCenter: parent.verticalCenter

                }
                //学习资料
                Rectangle
                {
                    width: 100 * widthRates
                    height: 44 * widthRates
                    color: {
                        if(userType == "TEA"){
                            if (liveRoomId!="")
                                return "white"
                            else
                                return "#E1E1E1"
                        } else {
                            return "white"
                        }

                    }
                    radius: 10 * heightRate
                    border.color: {
                        if( userType == "TEA"){
                            if( liveRoomId!="")
                                return "#FF5500"
                            else
                                return "white"
                        } else {
                            return "#FF5500"
                        }
                    }
                    Text {
                        anchors.top: parent.top
                        anchors.topMargin: 2 * heightRate
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: Cfg.LESSON_ALL_FAMILY
                        font.pixelSize: 15 * heightRate
                        color: hasDoc ? "white" : "#999999"
                        text: "学习资料"
                        visible: false
                    }

                    Text {
                        anchors.top: parent.top
                        anchors.topMargin: 22 * heightRate
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: Cfg.LESSON_ALL_FAMILY
                        font.pixelSize: 12 * heightRate
                        color: hasDoc ?  "white" : "#999999"
                        text: hasDoc ? "点击查看" : "未发布"
                        visible: false
                    }

                    Text {
                        id:courseNameText
                        anchors.centerIn: parent
                        font.family: Cfg.LESSON_ALL_FAMILY
                        font.pixelSize: 18 * heightRate
                        color: {
                            if(userType == "TEA"){
                                if (liveRoomId!="")
                                    return "#FF5500"
                                else
                                    return "white"
                            } else {
                                return "#FF5500"
                            }
                        }
                        text: userType == "TEA" ? "课件管理" : "查看课件"
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: {
                            if(userType == "TEA"){
                                if(liveRoomId!="")
                                    return true
                                else
                                    return false
                            } else {
                                return true
                            }
                        }
                        hoverEnabled: true
                        onContainsMouseChanged:
                        {
                            if(containsMouse)
                            {
                                parent.color = "#FF874C";
                                parent.border.color = "#FF874C";
                                courseNameText.color = "#FFFFFF";
                            }else
                            {
                                parent.color = "white";
                                parent.border.color = "#FF5500";
                                courseNameText.color = "#FF5500";
                            }
                        }

                        onPressed:
                        {
                            parent.color = "#E94E00";
                            parent.border.color = "#E94E00";
                            courseNameText.color = "#FFA6A6";
                        }
                        onReleased:
                        {
                            if(containsMouse)
                            {
                                parent.color = "#FF874C";
                                parent.border.color = "#FF874C";
                                courseNameText.color = "#FFFFFF";
                            }else
                            {
                                parent.color = "white";
                                parent.border.color = "#FF5500";
                                courseNameText.color = "#FF5500";
                            }
                        }

                        onClicked: {
                            console.log("查看学习资料2",isStageEnvironment,strStage)
                            parent.color = "#E94E00";
                            parent.border.color = "#E94E00";
                            courseNameText.color = "#FFA6A6";
                            var lessonDataInfo = {
                                "lessonId": lessonId,
                                "startTime": startTime,
                                "lessonStatus":lessonStatus
                            }
                            var lessonInfo = {
                                "roomId": liveRoomId, //教室id
                                "appId":"3edaf2877c994a4e8739dbe34411e7d7",
                                "appKey":"a995732df99bc794",
                                "envType": strStage,//运行环境类型，如sit01
                                "userRole": (userType == "TEA" ? "0" : (userType == "STU" ? "1" : "2")), //0=老师、1=学生 2=班主任
                                "userId": userId, //用户id
                                "processingMethord":processingMethord,
                            };
                            currentLessonInfo = lessonInfo;
                            console.log("processingMethord = " + processingMethord)
                            if(processingMethord == 0)
                            {
                                lessonMgr.getLookCourse(lessonDataInfo);//查看旧课件
                            }
                            else if(processingMethord == 1)
                            {
                                if(userType == "TEA")
                                {
                                    currentClassroomId = liveRoomId;
                                    diskMainView.visible = true;
                                    //云盘查看课件列表
                                    diskMainView.getCloudDiskList(liveRoomId,true);
                                }
                                else
                                {
                                    lessonMgr.runCourse(lessonInfo);//查看新课件
                                }

                            }
                            //                            if(userType == "TEA")
                            //                            {
                            //                                if(processingMethord == 1)
                            //                                {
                            //                                    currentClassroomId = liveRoomId;
                            //                                    diskMainView.visible = true;
                            //                                    //云盘查看课件列表
                            //                                    diskMainView.getCloudDiskList(liveRoomId,true);
                            //                                }
                            //                                else if(processingMethord == 0)
                            //                                {
                            //                                    lessonMgr.getLookCourse(lessonDataInfo);//查看旧课件
                            //                                }


                            //                            }else
                            //                            {
                            //                                if(processingMethord == 0)
                            //                                {
                            //                                    lessonMgr.getLookCourse(lessonDataInfo);//查看旧课件
                            //                                }
                            //                                else if(processingMethord == 1)
                            //                                {
                            //                                    lessonMgr.runCourse(lessonInfo);//查看新课件
                            //                                }
                            //                            }
                        }
                    }
                }

                //进入教室
                Rectangle
                {
                    width: 100 * widthRates
                    height: 44 * widthRates
                    color: enterRoomTextTwo.text == "查看录播" ? "white" : ( enterRoomOrEnterRocordEnable ? "#FF5500" : "#E1E1E1" )
                    radius: 10 * heightRate
                    border.width: 1
                    border.color: enterRoomTextTwo.text == "查看录播" ? "#FF5500" : ( enterRoomOrEnterRocordEnable ? "#FF5500" : "#E1E1E1" )
                    Text {
                        anchors.top: parent.top
                        anchors.topMargin: 2 * heightRate
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: Cfg.LESSON_ALL_FAMILY
                        font.pixelSize: 15 * heightRate
                        color: enterRoomOrEnterRocordEnable ?  "white" : "#999999"
                        text: !lessonHasEnd ? "云课堂" : "课程回放"
                        visible: false
                    }

                    Text {
                        id:enterRoomText
                        anchors.top: parent.top
                        anchors.topMargin: 22 * heightRate
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: Cfg.LESSON_ALL_FAMILY
                        font.pixelSize: 12 * heightRate
                        color: enterRoomOrEnterRocordEnable ?  "white" : "#999999"
                        text: !lessonHasEnd ? ( enterRoomOrEnterRocordEnable ? "进入教室" : "未开始" ) : (hasRecord == 1 ? "查看录播" : "录播生成中")
                        visible: false
                    }

                    Text {
                        id:enterRoomTextTwo
                        anchors.centerIn: parent
                        font.family: Cfg.LESSON_ALL_FAMILY
                        font.pixelSize: 18 * heightRate
                        color: text == "查看录播" ? "#FF5500" : "white"//enterRoomOrEnterRocordEnable ?  "white" : "#999999"
                        text: !lessonHasEnd ? "进入教室" : (hasRecord == 1 ? "查看录播" : "录播生成中")
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: enterRoomOrEnterRocordEnable
                        hoverEnabled: true
                        onContainsMouseChanged:
                        {
                            if(containsMouse)
                            {
                                parent.color = "#FF874C";
                                parent.border.color = "#FF874C";
                                enterRoomTextTwo.color = "#FFFFFF";
                            }else
                            {
                                if(enterRoomTextTwo.text == "查看录播")
                                {
                                    parent.color = "white";
                                    parent.border.color = "#FF5500";
                                    enterRoomTextTwo.color = "#FF5500";
                                }else
                                {
                                    parent.color = "#FF5500";
                                    parent.border.color = "#FF5500";
                                    enterRoomTextTwo.color = "white";
                                }
                            }
                        }

                        onPressed:
                        {
                            parent.color = "#E94E00";
                            parent.border.color = "#E94E00";
                            enterRoomTextTwo.color = "#FFA6A6";
                        }

                        onReleased: {
                            if(containsMouse)
                            {
                                parent.color = "#FF874C";
                                parent.border.color = "#FF874C";
                                enterRoomTextTwo.color = "#FFFFFF";
                            }else
                            {
                                if(enterRoomTextTwo.text == "查看录播")
                                {
                                    parent.color = "white";
                                    parent.border.color = "#FF5500";
                                    enterRoomTextTwo.color = "#FF5500";
                                }else
                                {
                                    parent.color = "#FF5500";
                                    parent.border.color = "#FF5500";
                                    enterRoomTextTwo.color = "white";
                                }
                            }
                            var lessonInfo = {
                                "appId":"3edaf2877c994a4e8739dbe34411e7d7",//"354937763033780224",
                                "appKey":"a995732df99bc794",//"354937763033780224",
                                "roomId":liveRoomId,//"354937763033780224", //教室id
                                "userId": userId, //用户id
                                "userRole": (userType == "TEA" ? "0" : (userType == "STU" ? "1" : "2")), //0=老师、1=学生 2=班主任
                                "nickName": nameText, //用户昵称或者名字
                                "envType": strStage,//运行环境类型，如sit01
                                "lessonId":lessonId,
                            };

                            console.log("enterRoomClick2:",nameText,JSON.stringify(lessonInfo),userType,isStageEnvironment,calendarControl.currentDaytext)
                            console.log("processingMethord = "+processingMethord)
                            if(!lessonHasEnd){
                                classView.visible = true;
                                classView.tips =   "进入教室中..."
                                classView.hideAfterSeconds();
                                currentLessonId = lessonId;//记录当前进入教室课程的lessonId和lessonReport
                                if(userType == "TEA")
                                    currentLessonReport = lessonReport;
                                lessonMgr.runClassRoom(lessonInfo);
                            }
                            else
                            {
                                if(processingMethord == 0)
                                {
                                    //查看旧录播
                                    lessonMgr.getRepeatPlayer(lessonInfo);
                                }
                                else if(processingMethord == 1)
                                {
                                    //查看新录播
                                    lessonMgr.runPlayer(lessonInfo);
                                }
                            }
                        }
                    }
                }

                //试听课报告
                Rectangle
                {
                    id:reportRect
                    width: 100 * widthRates
                    height: 44 * widthRates
                    visible: userType == "TEA"? lessonReport != 0 : hasReport == 1
                    color: "white"
                    radius: 10 * heightRate
                    border.width: 1
                    border.color: "#FF5500"

                    Text {
                        id:reportText
                        anchors.centerIn: parent
                        font.family: Cfg.LESSON_ALL_FAMILY
                        font.pixelSize: 18 * heightRate
                        color: "#FF5500"
                        text: {
                            if(userType == "TEA")
                            {
                                return lessonReport == 1 ? "填写报告" :(lessonReport == 2 ? "试听课报告":" ")
                            }
                            else if(userType == "STU")
                            {
                                return hasReport == 1 ? "试听课报告" : " "
                            }

                        }
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
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
                            else if(reportText.text == "填写报告")//需编辑
                            {
                                viewType = 2;
                                windowView.showReportView(lessonInfo,viewType);
                            }
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
                    var currentDate = new Date().getTime();
                    if(currentDate <= endTimeMs &&  startTimeMs <= currentDate)
                    {
                        enterRoomOrEnterRocordEnable = true;
                    }else
                    {
                        enterRoomOrEnterRocordEnable = false;
                        if(currentDate > endTimeMs)
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

    YMMiniLessonListView
    {
        id:miniLessonListView
        anchors.fill: parent
        visible: false
        z:1000
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
        lessonMgr.getCurrentMonthLessonData(currentBufferMonth);
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

    //获取某一天的课程数据
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
        //lessonMgr.getDayLessonData(dayData);
        lessonMgr.getCurrentDayLessonData(dayData);
    }

    function analysisData(lessonData){
        if(interNetGrade == 0)
        {
            netRequest.visible = true;
            return;
        }
        netRequest.visible = false;
        teachModel.clear();
        teachListView.contentY = 0;
        //遍历获取到的所有的课程
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
            //课程是否已经结束
            if(lessonData[i].lessonStatus == 1)
            {
                lessonHasEnd = true;
            }

            var startDate = new Date(lessonData[i].startTime).getTime() - Math.abs(lessonData[i].beforeSecond * 1000);
            var endDate = new Date(lessonData[i].endTime).getTime() + Math.abs(lessonData[i].afterSecond * 1000);//345600000;//3600000;//
            var currentDate = new Date().getTime();

            var startTimer = true;//是否开启定时器刷新进入课堂
            var enterRoomOrEnterRocordEnable = false;//进入教室 或者查看录播是否可用
            //是否有课件
            var hasDoc = true;//lessonData[i].hasDoc != 0 ? true : false;
            //是否有录播
            var hasRecord  = lessonData[i].hasRecord == 1 ? true : false;

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
                if(lessonData[i].lessonStatus == 0)
                {
                    if(currentDate > endDate)
                    {
                        startTimer = false;
                    }else
                    {
                        startTimer = true;
                    }
                    //当前时间在课程开始和结束之间
                    if(currentDate <= endDate &&  startDate <= currentDate)
                    {
                        enterRoomOrEnterRocordEnable = true;
                    }else
                    {
                        enterRoomOrEnterRocordEnable = false;
                    }

                    if(lessonData[i].subjectName == "演示")
                    {
                        enterRoomOrEnterRocordEnable = true;
                        startTimer = false;
                    }

                }else
                {
                    startTimer = false;
                    enterRoomOrEnterRocordEnable = false;
                }

            }
            teachModel.append(
                        {
                            "studentId": userType == "TEA" ? lessonData[i].stuList[0].studentId:0,
                                                             "studentName":"studentName",
                                                             "teacherName":lessonData[i].teacherName,
                                                             "startTime":lessonData[i].startTime,
                                                             "endTime":lessonData[i].endTime,
                                                             "lessonStatus":lessonData[i].lessonStatus,//预约排课状态 0 未开始 1 已结束 2 3请假 4 旷课  5 作废
                                                             "subjectName":lessonData[i].subjectName,
                                                             "gradeName":"gradeName",
                                                             "liveRoomId": lessonData[i].roomId,
                                                             "lessonId": lessonData[i].lessonId,
                                                             "lessonName": lessonData[i].subjectName,
                                                             "lessonType": lessonData[i].lessonType,
                                                             "hasRecord":hasRecord,
                                                             "hasDoc":hasDoc,
                                                             "lessonHasEnd":lessonHasEnd,
                                                             "startTimer":startTimer,
                                                             "enterRoomOrEnterRocordEnable":enterRoomOrEnterRocordEnable,
                                                             "lessonDate":lessonDate,
                                                             "startTimeMs":startDate,
                                                             "endTimeMs":endDate,
                                                             "hasComment":1,
                                                             "lessonDateShowText":lessonData[i].lessonDateShowText,
                                                             "childName":lessonData[i].childName,
                                                             "lessonReport":lessonData[i].lessonReport,
                                                             "processingMethord":lessonData[i].processingMethord,//查看录播/课件方式,0旧1新
                                                             "hasReport":lessonData[i].hasReport,
                        })
            //检查是否需要立即弹出试听课报告填写界面
            if(userType == "TEA" && currentLessonId == lessonData[i].lessonId && currentLessonReport != lessonData[i].lessonReport && lessonData[i].lessonReport == 1)
            {
                //试听课结束后弹出报告编写界面
                editReport(lessonData[i].stuList[0].studentId)
            }

        }

    }
    function queryData()
    {
        refreshPage();
    }
    function editReport(studentId)
    {
        console.log("now edit report...")
        var viewType = 2;
        var lessonInfo = {
            "userId": userId, //用户id
            "userRole": (userType == "TEA" ? "0" : (userType == "STU" ? "1" : "2")), //0=老师、1=学生 2=班主任
            "nickName": nameText, //用户昵称或者名字
            "envType": strStage,//运行环境类型，如sit01
            "lessonId":currentLessonId,
            "token":windowView.token,
            "studentId":studentId,
        };
        currentLessonId = 0
        windowView.showReportView(lessonInfo,viewType);
    }
    Timer{
        id:updateTime
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            console.log("2s time over...")
            queryData();
        }
    }
}

