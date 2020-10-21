import QtQuick 2.0
import YMLessonManagerAdapter 1.0
import "../Configuration.js" as Cfg

Item{
    id: lessonView
    width: parent.width - 2
    height: parent.height
    visible: false

    property double heightRate: widthRate/1.5337;
    property var lessonId: 0;
    property var lessonStatus: 0;//0 课程结束 1 进入教室 2备课
    property var startTime: [];
    property var endTime: [];
    property var scheduleId: 0;
    property string lessonName: "";
    property var contentData: [];
    property string executionPlanId: "";//执行计划Id
    property var isCourseware: false;

    property color fontColor: "black";

    signal sigJoinClassroomUrl(var url);
    signal sigReadyLesson(var classId,var dataJson);

    YMLessonManagerAdapter{
        id: lessonMgr
        onSigJoinClassroom: {
            if(windowView.isPublicText == false){
                if(joinClassroomInfo.data == null || joinClassroomInfo.data.path == null){
                    return;
                }

                if(joinClassroomInfo.data.path == undefined || joinClassroomInfo == {}){
                    return;
                }
                var url = joinClassroomInfo.data.path;
                sigJoinClassroomUrl(url);
                return
            }

            if(joinClassroomInfo.path == undefined || joinClassroomInfo == {}){
                return;
            }
            var urls = joinClassroomInfo.path;
            sigJoinClassroomUrl(urls);
        }

        onSigJoinClassroomStaus: {
            massgeTips.visible = true;
            massgeTips.tips = "正在进入教室,请稍候..."
        }

        onProgramRuned: {
            massgeTips.visible = false;
        }
    }

    Rectangle{//课背景颜色
        id: bgItem
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        color: {
            if(lessonStatus == 5 || lessonStatus == 4 || lessonStatus == 3 || lessonStatus == 2){//课程结束
                fontColor = "#666d76";
                return "#eff3f6";
            }
            if(lessonStatus == 1){//进入教室
                fontColor = "#ff6633";
                return "#fff3ed";
            }
            if(isCourseware){//备课
                fontColor = "#80c000";
                return "#f3ffdd";
            }
            return "#eff3f6";
        }
    }

    MouseArea{//进入教室或者查看备课、结束课程则无操作
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            lessonMgr.setQosStartTime(startTime,endTime);
            if(lessonStatus == 1 || lessonStatus == 3 || lessonStatus == 5){
                if(windowView.isPublicText == false){
                    lessonMgr.getJoinTalkClassRoomInfo(executionPlanId);
                    return;
                }
                lessonControl.lessonData = contentData;
                lessonControl.displayerStatus = !lessonControl.displayerStatus;
                return;
            }
            if(isCourseware){
                var jsonData = {
                    "classId": lessonId,
                    "name": lessonName,
                    "teachText": "",
                    "bigCoverUrl": "",
                    "categoryName": "",
                    "startTime": startTime,
                    "endTime":endTime,
                }
                sigReadyLesson(lessonId,jsonData);
            }
        }
    }

    onContentDataChanged: {
        if(contentData == undefined ||contentData == null || contentData.classGroupId == undefined){
            lessonView.visible = false;
            return;
        }
        lessonView.visible = true;
        lessonId = contentData.classGroupId;
        if(contentData.handleStatus == undefined){
            lessonStatus = contentData.status;
        }else{
            lessonStatus = contentData.handleStatus;
        }
        startTime = contentData.startTime;
        endTime = contentData.endTime;
        scheduleId = contentData.scheduleId;
        lessonName = contentData.name;
        executionPlanId = contentData.executionPlanId;
        isCourseware = contentData.isCourseware;
    }

    Text{
        id: lessonNameText
        width: parent.width - 10 * heightRate
        color: fontColor
        font.family: Cfg.LESSON_FONT_FAMILY
        font.bold: Cfg.LESSON_FONT_BOLD
        font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
        anchors.top:parent.top
        anchors.topMargin: 2 * heightRate
        text: lessonName
        anchors.left: parent.left
        anchors.leftMargin: 5 * heightRate
        wrapMode: Text.WordWrap
    }

    Text{
        id: timeText
        width: parent.width
        color: fontColor
        text: analysisDate(startTime,endTime)
        anchors.top: lessonNameText.bottom
        anchors.topMargin: 2 * heightRate
        font.family: Cfg.LESSON_FONT_FAMILY
        font.bold: Cfg.LESSON_FONT_BOLD
        font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 5 * heightRate
    }

    //状态图标、请假、完成、旷课等
    Rectangle{
        id: itemView
        width: 36 * heightRate
        height: 20 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        anchors.right: parent.right
        anchors.rightMargin: 1
        color: "#ff5500"
        z: 1
        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 10 * heightRate
            color: "#ffffff"
            anchors.centerIn: parent
            text: {
                if(lessonStatus == 1)
                    return "进教室";
                if(lessonStatus == 2 || lessonStatus == 3)
                    return "生成录播"
                if(lessonStatus == 4)
                    return "待开课";
                 if(lessonStatus ==5)//已结束
                     return "已结课";
                 else{
                     return"";
                 }
            }
        }
    }

/*
    Image{
        id: statusItem
        width: 36 * heightRate
        height: 20 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        anchors.right: parent.right
        anchors.rightMargin: 1
        source:{
            //lessonStatus: 1进入教室 2录播视频未生成 3录播视频生成 4待开课 5已结课
            if(lessonStatus ==5){//已结束
                statusItem.visible = true;
                return "qrc:/talkcloudImage/xbk_btn_finish@2x.png";
            }
            if(lessonStatus ==1){//进入教室
                statusItem.visible = true;
                return "qrc:/talkcloudImage/xbk_btn_jinjiaoshi@2x.png"
            }
            if(lessonStatus){//备课
                statusItem.visible = true;
                return "qrc:/talkcloudImage/xbk_stats_beike@2x.png"
            }
            else{
                statusItem.visible = false;
                return "";
            }
        }
    }*/

    function analysisDate(startTime,endTime){
        var currentStartDate = new Date(startTime);
        var hours = Cfg.addZero(currentStartDate.getHours());
        var minutes = Cfg.addZero(currentStartDate.getMinutes());

        var endDateTime = new Date(endTime);
        var eHours = Cfg.addZero(endDateTime.getHours());
        var eMinutes = Cfg.addZero(endDateTime.getMinutes());

        return hours + ":" + minutes + "-" + eHours + ":" + eMinutes
    }

    function analysisCurrentDate(startTime){
        var currentStartDate = new Date(startTime);
        var year = currentStartDate.getFullYear();
        var month = currentStartDate.getMonth();
        var day = currentStartDate.getDate();
        var hours = currentStartDate.getHours();
        var minutes = currentStartDate.getMinutes();

        var endDateTime = new Date(endTime);
        var e_hours = endDateTime.getHours();
        var e_minutes = endDateTime.getMinutes();

        var contentDate = new Date();
        var contentYear = contentDate.getFullYear();
        var contentMonth = contentDate.getMonth();
        var contentDay = contentDate.getDate();
        var contentHours = contentDate.getHours();
        var contentMinutes = contentDate.getMinutes();
        if(year == contentYear && month == contentMonth && day ==contentDay){
            if(minutes == 0 && hours == 0 && e_hours == 23 && e_minutes == 59){
                return true;
            }

            var sdate = currentStartDate.getHours() * 3600 + currentStartDate.getMinutes() * 60 + currentStartDate.getSeconds();
            var edate = endDateTime.getHours() * 3600 + endDateTime.getMinutes() * 60 + endDateTime.getSeconds();
            var cdata = contentDate.getHours() * 3600 + contentDate.getMinutes() * 60 + contentDate.getSeconds();
            if(cdata >= sdate && cdata <= edate && day == contentDay){
                return true;
            }
            return false;
        }else{
            return false;
        }
    }
}

