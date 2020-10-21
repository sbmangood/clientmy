import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import YMLessonManagerAdapter 1.0
import "../../Configuration.js" as Cfg

/*******课程列表******/
//教师端课程列表
MouseArea {
    z: 8890
    anchors.fill: parent
    hoverEnabled: true
    focus: true
    property int mark: 0;// 0起始日期 1结束日期
    property int pageIndex: 1;
    property int pageSize: 10;
    property int totalPage: 1;
    property string keywords: "";
    property string startDate: "";
    property string endDate: "";
    property string queryStatus: "";
    property string queryPeriod: "TODAY";
    property var currentLessonId: [];
    property var currentLessonReport//当前的lessonReport
    property bool isFirstLoadLessonList: true;//是否是第一次加载课程列表

    //按键盘上下进行滚动页面
    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Up:
            if(teachListView.contentY > 0){
                teachListView.contentY -= 20;
            }
            break;
        case Qt.Key_Down:
            if(button.y < scrollbar.height - button.height){
                teachListView.contentY += 20;
            }
            break;
        default:
            return;
        }
        event.accepted = true
    }

    YMLessonManagerAdapter{
        id: lessonMgr

        onSigCCHasInRoom:
        {
            classView.visible = false;
            ccHasInRoomView.visible = true;
        }

        //显示错误提示对话框
        onSigMessageBoxInfo:
        {
            console.log("=======YMLessonListTable.qml onSigMessageBoxInfo========");
            windowView.showMessageBox(strMsg);
        }

        onSigIsJoinClassroom: {
            //如果老师在上课则弹窗
            //没有上课则直接进入旁听
            classView.visible = false;
            joinClasstipsView.teacherName = teacherName;
            joinClasstipsView.isShowLessonInfo = false;
            joinClasstipsView.fromStatus = 2;
            joinClasstipsView.visible = true;
        }

        //获得到教师课程列表
        onTeacherLesonListInfoChanged:{
            analysisData(lessonInfo);
        }
        onLessonlistRenewSignal: {
            console.log("teacher lesson update....")
            enterClassRoom = true;
            loadingView.opacityAnimation = !loadingView.opacityAnimation;
            classView.visible = false;
            updateTime.start();
//            queryData();
            accountMgr.getUserLoginStatus();
        }
        onSetDownValue:{
            progressbar.min = min;
            progressbar.max = max;
            progressbar.visible = true;
        }
        onDownloadChanged:{
            progressbar.currentValue = currentValue;
        }
        onDownloadFinished:{
            progressbar.visible = false;
        }
        onListenChange: {
            enterClassRoom = true;
            classView.visible = false;
            if(status ==0){
                massgeTips.tips = "还未开始上课，暂时无法旁听!";
                massgeTips.visible = true;
                loadingView.opacityAnimation = !loadingView.opacityAnimation;
            }
            //console.log("listenChange",enterClassRoom);
        }
        onLoadingFinished:{
            loadingView.opacityAnimation = !loadingView.opacityAnimation;
        }
        onRequstTimeOuted: {
            enterClassRoom = true;
            networkItem.visible = true;
            classView.visible = false;
        }
        onProgramRuned:{
            // classView.visible = false;
            classView.hideAfterSeconds();
        }
        onSigRepeatPlayer: {
            massgeTips.tips = "录播暂未生成，请在课程结束半小时后进行查看!";
            massgeTips.visible = true;
        }
    }

    YMLoadingStatuesView{
        id: loadingView
        z: 68
        anchors.fill: parent
    }

    //网络显示提醒
    Rectangle{
        id: networkItem
        z: 86
        visible: false
        anchors.fill: parent
        radius:  12 * widthRate
        anchors.top: listItem.top
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
            font.family: Cfg.LESSON_LIST_FAMILY
            font.pixelSize: (Cfg.LESSON_LIST_FONTSIZE - 4) * widthRate
            verticalAlignment: Text.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        MouseArea{
            width: 80 * widthRate
            height: 30 * heightRate
            cursorShape: Qt.PointingHandCursor
            anchors.top: netText.bottom
            anchors.topMargin: 10 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle{
                anchors.fill: parent
                border.color: "#808080"
                border.width: 1 * widthRates
                radius: 4 * widthRates
            }

            Text{
                text: "刷新"
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                anchors.centerIn: parent
            }

            onClicked: {
                console.log("=====refreshPage======")

                refreshPage();
            }
        }
    }

    //搜索框
    Rectangle{
        id: seacheItem
        width: parent.width - 40 * widthRate
        height: 32 * widthRates
        border.color: "#e3e6e9"
        border.width: 1 * widthRates
        radius: 4 * widthRates
        anchors.top: parent.top
        anchors.topMargin: 12 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: loadingView.visible == false
        Image{
            id: searchImage
            width: 20 * widthRates
            height: 20 * widthRates
            anchors.left: parent.left
            anchors.leftMargin: 10*widthRate
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/JrImage/ico_sousuo@2x.png"
            //            fillMode: Image.PreserveAspectFit
        }

        TextField{
            id: filterText
            width: parent.width - 40*widthRate
            height: parent.height
            anchors.left: searchImage.right
            anchors.leftMargin: 8*widthRate
            anchors.verticalCenter: parent.verticalCenter
            placeholderText: "请输入学生名称/客户编号/课程编号"
            menu:null
            style: TextFieldStyle{
                background: Item{
                    anchors.fill: parent
                }
                placeholderTextColor: "#999999"
            }
            font.family: Cfg.LESSON_LIST_FAMILY
            font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * widthRates
            onAccepted: {
                pageIndex = 1;
                keywords = filterText.text;
                if(keywords == ""){
                    startTimeText.text = getCurrentDate();
                }
                comboBox.currentIndex = 0;
                pagtingControl.currentPage = 1;
                queryData();
            }
        }
    }

    YMCalendarControl{
        id: calendarControl
        z: 96
        visible: false
        onDateTimeconfirm: {
            var sdate;
            var edate;
            pagtingControl.currentPage = 1;
            pageIndex = 1;
            if(mark == 0){
                startDate = dateTime.replace("年","-").replace("月","-").replace("日","");
                sdate = new Date(startDate);
                if(endDate == ""){
                    startTimeText.text = startDate;
                    calendarControl.visible = false;
                    queryData();
                    return;
                }
                edate = new Date(endDate);
                if(edate.getTime() - sdate.getTime() >= 0){
                    startTimeText.text = startDate;
                    calendarControl.visible = false;
                    queryData();
                }
            }else{
                endDate = dateTime.replace("年","-").replace("月","-").replace("日","");

                edate = new Date(endDate);
                if(startDate == ""){
                    endTimeText.text = dateTime;
                    calendarControl.visible = false;
                    queryData();
                    return;
                }
                sdate = new Date(startDate);
                if(edate.getTime() - sdate.getTime() >= 0){
                    endTimeText.text = dateTime;
                    calendarControl.visible = false;
                    queryData();
                }
            }

        }
    }

    Item{
        id: filterItem
        width: parent.width - 40 * widthRate
        height: 32 * widthRates
        anchors.top: seacheItem.bottom
        anchors.topMargin: 16 * widthRates
        anchors.left: parent.left
        anchors.leftMargin: 10 * widthRates

        Text{
            height: parent.height
            anchors.left: parent.left
            anchors.leftMargin: 18 * widthRates

            text:"筛选课程状态:"
            verticalAlignment: Text.AlignVCenter
            font.family: Cfg.LESSON_LIST_FAMILY
            font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * widthRates
            color: "#666666"
        }

        YMComboxControl {
            id: comboBox
            height: 32 * widthRates
            width: 159 * widthRates
            anchors.left: parent.left
            anchors.leftMargin: 109 * widthRates
            model: ["全部课程","预排课程","请假课程","旷课课程","已完成课程"]

            onCurrentTextChanged: {
                if(isFirstLoadLessonList)
                {
                    isFirstLoadLessonList = false;
                    return;
                }
                pagtingControl.currentPage = 1;
                pageIndex = 1;
                queryData();
            }
        }

        Row{
            width: filterItem.width  - 220*widthRate
            height: 32 * widthRates
            anchors.left: comboBox.right
            anchors.leftMargin: 25 * widthRate
            spacing: 10*widthRate

            Text{
                height: parent.height
                text:"选择课程开始时间:"
                verticalAlignment: Text.AlignVCenter
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * widthRates
                color: "#666666"
            }

            Rectangle{
                id: startItem
                width: 100 * widthRate
                height: parent.height
                border.color: "#d3d8dc"
                border.width: 1 * widthRates
                anchors.verticalCenter: parent.verticalCenter
                radius: 4*heightRate
                TextField{
                    id: startTimeText
                    placeholderText:  "年/月/日"
                    width: parent.width
                    height: parent.height
                    anchors.centerIn: parent
                    readOnly: true
                    style: TextFieldStyle{
                        background: Rectangle{
                            color: "transparent"
                        }
                        placeholderTextColor: "#666666"
                    }
                    menu:null
                    font.family: Cfg.LESSON_LIST_FAMILY
                    font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * widthRates
                    textColor: "#666666"
                    onTextChanged:{
                        startTimeText.length>0?clearTimeText.color="#222222":clearTimeText.color="#aaaaaa"
                    }
                }
                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mark = 0;
                        var location = contentItem.mapFromItem(startItem,0,0);
                        calendarControl.x = location.x - 260 * widthRate;
                        calendarControl.y = location.y - 30 * heightRate;
                        calendarControl.open();
                    }
                }
            }

            Text{
                height: parent.height
                text: "至"
                verticalAlignment: Text.AlignVCenter
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                color: "#aaaaaa"
                visible: false
            }

            Rectangle{
                id: endTimeItem
                width: 100*widthRate
                height: parent.height
                border.color: "#d3d8dc"
                border.width: 1 * widthRates
                anchors.verticalCenter: parent.verticalCenter
                radius: 4*heightRate
                visible: false
                enabled: false

                TextField{
                    id: endTimeText
                    readOnly: true
                    placeholderText: "年/月/日"
                    width: parent.width
                    anchors.centerIn: parent
                    style: TextFieldStyle{
                        background: Rectangle{
                            color: "transparent"
                        }
                        placeholderTextColor: "#666666"
                    }
                    menu:null
                    font.family: Cfg.LESSON_LIST_FAMILY
                    font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                    onTextChanged:{
                        endTimeText.text.length>0||startTimeText.length>0?clearTimeText.color="#222222":clearTimeText.color="#aaaaaa"
                    }
                }
                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mark = 1;
                        var location = contentItem.mapFromItem(endTimeItem,0,0);
                        calendarControl.x = location.x - 260 * widthRate;
                        calendarControl.y = location.y - 30 * heightRate;
                        calendarControl.open();
                    }
                }
            }

            Rectangle{
                width: 60*widthRate
                height: parent.height
                border.color: "#d3d8dc"
                border.width: 1 * widthRates
                anchors.verticalCenter: parent.verticalCenter
                radius: 4*heightRate
                visible: false
                enabled: false
                Text{
                    id:clearTimeText
                    text: "清空时间"
                    anchors.centerIn: parent
                    font.family: Cfg.LESSON_LIST_FAMILY
                    font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                    color: "#aaaaaa"
                }
                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        startDate = "";
                        endDate = "";
                        startTimeText.text = "";
                        endTimeText.text = "";
                        pagtingControl.currentPage = 1;
                        queryData();
                    }
                }
            }
        }
    }

    //背景框
    Rectangle{
        id: listItem
        width: parent.width - 20*widthRate
        height: parent.height - 180 * heightRate
        anchors.top: filterItem.bottom
        anchors.topMargin: 24 * widthRates
        color: "transparent"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    //显示课程列表
    ListView{
        id: teachListView
        clip: true
        anchors.fill: listItem
        anchors.top: listItem.top
        anchors.topMargin: 12 * heightRate
        model: teachModel
        delegate: teachDelegate
    }

    //滚动条
    Item {
        id: scrollbar
        anchors.left: listItem.right
        anchors.top: listItem.top
        anchors.topMargin: 12 * heightRate
        width:10 * widthRate
        height:listItem.height
        z: 23
        Rectangle{
            width: 2 * widthRates
            height: parent.height
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: teachListView.visibleArea.yPosition * scrollbar.height
            width: 6 * widthRate
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

    Image{
        id: backgImage
        width: 150 * heightRate
        height: 173 * heightRate
        anchors.centerIn: listItem
        visible: false
        fillMode: Image.PreserveAspectFit
        source: "qrc:/JrImage/ico_meike@2x.png"
    }

    //存教师课程列表数据
    ListModel{
        id: teachModel
    }

    //翻页框
    YMPagingControl{
        id: pagtingControl
        anchors.bottom: parent.bottom
        z: 67
        enabled: loadingView.visible == false
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
    //显示课程信息的控件
    Component{
        id: teachDelegate
        Item{
            width: teachListView.width
            height: 100 * widthRates

            Rectangle{//border
                id: contentItem
                width: parent.width - 30 * widthRates
                height: parent.height - 20 * widthRates
                color: "transparent"
                border.color: "#EEEEEE"
                border.width: 1 * widthRates
                radius: 8 * widthRates
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
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
                    anchors.leftMargin: 40 * widthRates
                    YMTextControl{
                        width: 180 * widthRates
                        height: parent.height
                        text1: "科目："
                        text2: subjectName
                    }

                    YMTextControl{
                        width: 200 * widthRates
                        height: parent.height
                        text1: "学生："
                        text2: {
                            var studentNames = "";
                            var stuArray = JSON.parse(stuList)
                            for(var i  = 0; i < stuArray.length; i ++){
                                if(studentNames != "")
                                {
                                    studentNames += "、";
                                }
                                studentNames += stuArray[i].clientName;
                            }
                            return studentNames;
                        }
                    }

                }

                Row{
                    width: 400 * widthRates
                    height: parent.height * 0.5
                    anchors.top:parent.top
                    anchors.topMargin: 40 * widthRates
                    anchors.left: parent.left
                    anchors.leftMargin: 40 * widthRates

                    YMTextControl{
                        width: 180 * widthRates
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
                        text2: ""
                    }

                }

                Image {
                    id: lessonStateImg
                    width: 71 * widthRates
                    height: 71 * widthRates
                    anchors.right: parent.right
                    anchors.rightMargin:parent.width * 0.44
                    anchors.verticalCenter: parent.verticalCenter

                    source: (hasRecord != 1 && enableClass) ? "qrc:/JrImage/sk@2x.png" : getLessonStatusImg(lessonStatus, new Date(startTime).getTime() + lessonSecondCount*1000)
                }

                Row{
                    width: 400 * widthRates
                    height: 44 * widthRates
                    anchors.right: parent.right
                    anchors.rightMargin: 85 * widthRates
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20 * widthRates

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
                            radius: 6 * widthRates
                            color: hasDoc == 1 ? "white" : "#E1E1E1"
                            anchors.fill: parent
                            border.width: 1 * widthRates
                            border.color: hasDoc ? "#FF5500" : "#E1E1E1"
                        }

                        Text{
                            id:lessonText
                            text: "查看课件"
                            anchors.centerIn: parent
                            color: hasDoc ? "#FF5500" : "white"
                            font.family: Cfg.LESSON_LIST_FAMILY
                            font.pixelSize: 16 * widthRates
                            verticalAlignment: Text.AlignVCenter
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
                            lessonRect.color = "#E94E00";
                            lessonRect.border.color = "#E94E00";
                            lessonText.color = "#FFD5C0";

                            var lessonDataInfo = {
                                "lessonId": lessonId,
                                "startTime": startTime,
                                "lessonStatus":lessonStatus
                            }
                            console.log("lessonStatuslessonStatus",lessonStatus,processingMethord)

                            var lessonInfo = {
                                "appId":"3edaf2877c994a4e8739dbe34411e7d7",//"354937763033780224",
                                "appKey":"a995732df99bc794",
                                "roomId":roomId,//"354937763033780224", //教室id
                                "userId": userId, //用户id
                                "userRole": teacherId == userId ? "0" : "3",
                                                                  "nickName": nameText, //用户昵称或者名字
                                                                  "envType": strStage,//运行环境类型，如sit01
                            };

                            console.log("processingMethord = "+processingMethord)
                            if(processingMethord == 0)
                            {
                                lessonMgr.getLookCourse(lessonDataInfo);//查看旧课件
                            }
                            else if(processingMethord == 1)
                            {
                                lessonMgr.runCourse(lessonInfo);//查看新课件
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
                        id: classRoomButton
                        width: 100 * widthRates
                        height: 44 * widthRates
                        enabled: enableClass ? true : false
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        Rectangle{
                            id:enterRoomRect
                            radius: 6 * widthRates
                            color: hasRecord == 1 ? (enableClass ? "white" : "#E1E1E1") : (enableClass ? "#FF5500" : "#E1E1E1")
                            anchors.fill: parent
                            border.width: 1 * widthRates
                            border.color: enableClass ? "#FF5500" : "#E1E1E1"
                        }

                        Text{
                            id:enterRoomText
                            text:lessonStatus == 1 ? (hasRecord == 0  ?  "录播生成中" : "查看录播") : (lessonUserRole == "TEACHER" ? "进入教室" : "进入旁听")
                            //text: hasRecord == 0  ?  "进入教室" : "查看录播"//(teacherId == userId ? "进入教室" : "进入旁听") : "查看录播"
                            anchors.centerIn: parent
                            font.family: Cfg.LESSON_LIST_FAMILY
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
                                enterRoomRect.color = hasRecord == 1 ? (enableClass ? "white" : "#E1E1E1") : (enableClass ? "#FF5500" : "#E1E1E1")
                                enterRoomRect.border.color = enableClass ? "#FF5500" : "#E1E1E1";
                                enterRoomText.color = (hasRecord == 1 && enableClass ==1) ? "#FF5500" : "white";
                            }
                        }

                        onPressed: {
                            enterRoomRect.color = "#E94E00";
                            enterRoomRect.border.color = "#E94E00";
                            enterRoomText.color = "#FFD5C0";

                            if(lessonStatus == 0){
                                if(enterClassRoom){
                                    classView.visible = true;
                                    lessonMgr.lessonType = lessonType;
                                    lessonMgr.lessonPlanStartTime = startTime;
                                    lessonMgr.lessonPlanEndTime = endTime;
                                    classView.tips = "进入教室中..."
                                    //                                    if(teacherId == userId){
                                    //                                        classView.tips = "进入教室中..."
                                    //                                    }else{
                                    //                                        classView.tips = "进入旁听中..."
                                    //                                    }

                                }
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
                                enterRoomRect.color = hasRecord == 1 ? (enableClass ? "white" : "#E1E1E1") : (enableClass ? "#FF5500" : "#E1E1E1")
                                enterRoomRect.border.color = enableClass ? "#FF5500" : "#E1E1E1";
                                enterRoomText.color = (hasRecord == 1 && enableClass ==1) ? "#FF5500" : "white";

                            }


                            //teachListView.focus = false;
                            console.log("====enterClassRoom11=====", lessonId)
                            var lessonInfo = {
                                "appId":"3edaf2877c994a4e8739dbe34411e7d7",//"354937763033780224",
                                "appKey":"a995732df99bc794",
                                "roomId":roomId,//"354937763033780224", //教室id
                                "userId": userId, //用户id
                                "userRole": teacherId == userId ? "0" : "3",
                                                                  "nickName": nameText, //用户昵称或者名字
                                                                  "envType": strStage,//运行环境类型，如sit01
                                                                  "processingMethord":processingMethord,
                                                                  "lessonId":lessonId,
                            };

                            if(lessonStatus == 0){
                                if(enterClassRoom){
                                    //enterClassRoom = false;  //"进入教室"按钮, 一直都可以点击, 因为在classroom程序中, 已经控制了, 只有一个实例

                                    //roomid envtype userid
                                    console.log("=====listen::id=======",JSON.stringify(lessonInfo),strStage,userType,teacherId,userId)
                                    classView.hideAfterSeconds();
                                    currentLessonId = lessonId;//记录当前进入教室课程的lessonId和lessonReport
                                    currentLessonReport = lessonReport;
                                    lessonMgr.runClassRoom(lessonInfo);//进入教室
                                    if(teacherId == userId){
                                        console.log("teacherId == userId.......")
                                        //lessonMgr.getEnterClass(lessonId,interNetGrade);
                                    }else{
                                        console.log("teacherId != userId.......")
                                        currentLessonId = lessonId;
                                        //lessonMgr.getListen(lessonId);
                                    }
                                }
                            }
                            else{
                                progressbar.currentValue = 0;
                                console.log("processingMethord = " + processingMethord)
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

                    //试听课报告
                    MouseArea{
                        id: reportButton
                        width: 100 * widthRates
                        height: 44 * widthRates
                        visible: lessonReport != 0
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        Rectangle{
                            id:reportRect
                            radius: 6 * widthRates
                            color: "white"
                            anchors.fill: parent
                            border.width: 1 * widthRates
                            border.color: "#FF5500"
                        }

                        Text{
                            id:reportText
                            text: lessonReport == 1 ? "填写报告" :(lessonReport == 2 ? "试听课报告":" ")
                            anchors.centerIn: parent
                            color: lessonReport > 0 ? "#FF5500" : "white"
                            font.family: Cfg.LESSON_LIST_FAMILY
                            font.pixelSize: 16 * widthRates
                            verticalAlignment: Text.AlignVCenter
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
                                console.log("shitingke ...baogao..")
                                viewType = 1;
                                windowView.showReportView(lessonInfo,viewType);
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
        }
    }

    Component.onCompleted: {
        startTimeText.text = getCurrentDate();
    }

    Connections{
        target: windowView
        onSigListenTips:{
            if(2 == status)
            {
                classView.visible = false;
                lessonMgr.getCloudServer();
                //lessonMgr.getListen(currentLessonId);
            }
        }
    }

    function refreshPage(){
        console.log("on refresh...")
        queryData();
    }

    function analysisData(objectData){
        var items = objectData.items;
        if(items == null || items == {}){
            if(interNetGrade == 0)
            {
                backgImage.visible = false;
                networkItem.visible = true;
            }else
            {
                queryData();
            }

            return;
        }
        teachModel.clear();
        console.log("items::data",JSON.stringify(items),JSON.stringify())
        networkItem.visible = false;
        backgImage.visible = false;

        for(var i = 0; i < items.length; i++){
            teachModel.append({
                                  "studentId": items[i].stuList[0].studentId,
                                  "roomId":items[i].roomId,
                                  "enableClass": false,
                                  "afterSecond":items[i].afterSecond,
                                  "beforeSecond":items[i].beforeSecond,
                                  "endTime":items[i].endTime,
                                  "gradeName":items[i].gradeName,
                                  "hasDoc":items[i].hasDoc,
                                  "hasRecord":items[i].hasRecord,
                                  "hasComment":items[i].hasComment == undefined ? 1 : items[i].hasComment,
                                                                                  "keywords":items[i].keywords,
                                                                                  "lessonId":items[i].lessonId,
                                                                                  "lessonSecondCount":items[i].lessonSecondCount,
                                                                                  "lessonStatus":items[i].lessonStatus,
                                                                                  "lessonType":items[i].lessonType,
                                                                                  "remaining":items[i].remaining,
                                                                                  "startTime":items[i].startTime,
                                                                                  "studentAppraiseType":items[i].studentAppraiseType,
                                                                                  "studentAppraises":items[i].studentAppraises,
                                                                                  "stuList":JSON.stringify(items[i].stuList),
                                                                                  "subjectName":items[i].subjectName,
                                                                                  "teacherId": items[i].teacherId,
                                                                                  "title":items[i].title,
                                                                                  "courseHours":items[i].courseHours,
                                                                                  "processingMethord":items[i].processingMethord,//0 旧方式  1新方式
                                                                                  "lessonReport":items[i].lessonReport,
                                                                                  "lessonUserRole":(items[i].lessonUserRole == null || items[i].lessonUserRole == undefined)? "TEACHER" : items[i].lessonUserRole,
                                                                                                                                                                              "timerStart": false,
                                                                                                                                                                              "lessonDownText": "",
                                                                                                                                                                              "lessonMsg": "距离上课时间",
                                                                                                                                                                              "status1": "black",//控制文本1颜色
                                                                                                                                                                              "status2": "black",//控制文本2颜色
                                                                                                                                                                              "statusFontSize1": 16,//控制文本1字体大小
                                                                                                                                                                              "statusFontSize2": 16,//控制文本2字体大小
                                                                                                                                                                              "listenFlag": (items[i].applicationType == null) ? -1 : items[i].applicationType
                              })
            lessonSecondSum(items[i].remaining,items[i].startTime,items[i].endTime,i);

            //检查是否需要立即弹出试听课报告填写界面
            if(userType == "TEA" && currentLessonId == items[i].lessonId && currentLessonReport != items[i].lessonReport && items[i].lessonReport == 1)
            {
                //试听课结束后弹出报告编写界面
                editReport(items[i].stuList[0].studentId)
            }
        }
        totalPage = Math.ceil(objectData.total / pageSize);
        pagtingControl.totalPage = totalPage;
        backgImage.visible = teachModel.count == 0 ? true : false;
    }

    function lessonSecondSum(remaining,startTime,endTime,index){
        var date = remaining / 60 / 60 / 24;
        var minutes = remaining / 60;

        disableClassButton(remaining,startTime,endTime,index);
        disableHasRecord(index,startTime,endTime);
        teachModel.get(index).remaining = remaining;

        if(teachModel.get(index).lessonStatus == 3 )
        {
            teachModel.get(index).lessonMsg = "请假";
            teachModel.get(index).lessonDownText = "扣除" +teachModel.get(index).courseHours + "课时";
            teachModel.get(index).status1 = "#ff5000";
            teachModel.get(index).status2 = "#ff5000";
            teachModel.get(index).statusFontSize1=22;
            teachModel.get(index).statusFontSize2=22;

            return;
        }
        if(teachModel.get(index).lessonStatus == 2)
        {
            teachModel.get(index).lessonMsg = "请假";
            teachModel.get(index).lessonDownText = "扣除0课时";
            teachModel.get(index).status1 = "#ff5000";
            teachModel.get(index).status2 = "#ff5000";
            teachModel.get(index).statusFontSize1=22;
            teachModel.get(index).statusFontSize2=22;
            return;
        }
        if(teachModel.get(index).lessonStatus == 4 )
        {
            teachModel.get(index).lessonMsg = "旷课";
            teachModel.get(index).lessonDownText = "扣除" +teachModel.get(index).courseHours + "课时";
            teachModel.get(index).status1 = "gray";
            teachModel.get(index).status2 = "gray";
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
            teachModel.get(index).status1 = "black";
            teachModel.get(index).status2 = "#ff5000";
            teachModel.get(index).statusFontSize1=20;
            teachModel.get(index).statusFontSize2=22;
            return;
        }

        if(date > 1){
            teachModel.get(index).lessonMsg = "距离上课时间";
            teachModel.get(index).lessonDownText = Math.floor(date) + "天";
            teachModel.get(index).status1 = "black";
            teachModel.get(index).status2 = "#55aaee";
            teachModel.get(index).statusFontSize1=20;
            teachModel.get(index).statusFontSize2=22;
            return;
        }
    }

    function disableClassButton(remaining,startTime,endTime,index){

        //请假课 不可进教室
        if(teachModel.get(index).lessonStatus == "2" || teachModel.get(index).lessonStatus == "3" || teachModel.get(index).lessonStatus == "4")
        {
            teachModel.get(index).enableClass = false;
            return;
        }
        //小于一天不能进入教室
        //console.log("===disableClass====",startTime,endTime)
        var startDate = new Date(startTime);
        var endDate = new Date(endTime);
        var currentDate = new Date();//当前时间


        //console.log("====disableClassButton ===",startDate,endDate);
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
        //演示课只要未结束都可以进入教室
        var subjectName = teachModel.get(index).subjectName;
        var lessonStatus = teachModel.get(index).lessonStatus

        if(subjectName == "演示" && lessonStatus !== 1){
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

        if(status == 0 && currentDate.getTime() >= startDate.getTime() && currentDate.getTime() <= endDate.getTime())
        {
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
        //课程未结束 并且少于1小时可以进入教室
        var status = teachModel.get(index).lessonStatus;
        if(status == 0 && e + 3600 - c <= 3600 && e + 3600 -c >=0 && date == 0  && monther == 0  && yaer == 0){
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
        loadingView.visible = true;
        keywords = filterText.text;
        startDate = startTimeText.text.replace("年","-").replace("月","-").replace("日","");
        endDate = endTimeText.text.replace("年","-").replace("月","-").replace("日","");
        queryStatus = ""
        if(comboBox.currentText.indexOf("已完成课程") >= 0 ){
            queryStatus = "1"
        }
        if(comboBox.currentText.indexOf("预排课程") >= 0){
            queryStatus = "0"
        }
        if(comboBox.currentText.indexOf("请假") >= 0){
            queryStatus = "2"
        }
        if(comboBox.currentText.indexOf("旷课") >= 0){
            queryStatus = "4"
        }
        var seachPram = {
            "keywords": keywords,
            "pageIndex": pageIndex == 0 ? 1 : pageIndex.toString(),
                                          "pageSize": pageSize,
                                          "queryStartDate": startDate,
                                          "queryEndDate": endDate,
                                          "queryPeriod": queryPeriod,
                                          "queryStatus": queryStatus,
        }
        queryPeriod = "ALL";

        console.log("====seachPram====",JSON.stringify(seachPram));
        lessonMgr.getTeachLessonListInfo(seachPram);//获取课程列表
    }

    function getCurrentDate(){
        var date = new Date();
        var year = date.getFullYear();
        var month = Cfg.addZero(date.getMonth() + 1);
        var day = Cfg.addZero(date.getDate());
        return year + "-" + month + "-" + day;
    }

    function analysisDate(startTime){
        var currentStartDate = new Date(startTime);
        var year = currentStartDate.getFullYear();
        var month = Cfg.addZero(currentStartDate.getMonth() + 1);
        var day = Cfg.addZero(currentStartDate.getDate());

        return year + "-" + month + "-" + day;
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

