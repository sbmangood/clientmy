import QtQuick 2.0
import "../Configuration.js" as Cfg

Item{
    id: lessonView
    width: parent.width - 2
    height: parent.height
    visible: false

    property double heightRate: widthRate/1.5337;
    property var dateId: 0;
    property var lessonId: 0;
    property var grade: "";
    property var subject: ""
    property var lessonStatus: 0;
    property var relateType: "";
    property var teacherName: ""
    property var startTime: [];
    property var endTime: [];
    property var scheduleId: 0;
    property var hasRecord: 0;
    property var lessonType: "";
    property var contentData: [];
    property var timeSchedule: [];

    property color fontColor: "black";

    Rectangle{
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        color: {
            if(lessonType == 'V'||relateType == 'V'){//请假的不显示
                fontColor = "#8a8fa9";
                //border.color="#d1daff";
                return "#f1f3ff";
            }
            if(analysisCurrentDate(startTime)){
                fontColor = "#ffffff";
                //border.color="#ff6633";
                return "#ff6633";
            }
            if(lessonType == 'O'){
                fontColor = "#3a80cd";
                //border.color="#4990e2";
                return "#dff6ff";
            }else if(lessonType == 'A'){
                fontColor = "#ff662d";
                //border.color="#ff8e68";
                return  "#ffe3d9";

            }else if(lessonType == 'L'){
                fontColor = "#8cbd5a";
                //border.color="#b9d09c";
                return  "#f0ffdd";

            }else{
                return "white";
            }
        }
    }

    MouseArea{
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if(lessonType == "L"){
                var url = URL_MyLive
                console.log(url);
                Qt.openUrlExternally(url)
                return;
            }
            lessonControl.contentData = contentData;
            lessonControl.visible = true;
            lessonControl.startFadeOut();
        }
    }

    onContentDataChanged: {
        if(contentData == undefined ||contentData == null || contentData.lessonId == undefined){
            lessonView.visible = false;
            return;
        }
        dateId = contentData.dateId;
        lessonId = contentData.lessonId;
        grade = contentData.grade;
        if(contentData.subject == undefined){
            subject = contentData.SUBJECT;
        }else{
            subject = contentData.subject;
        }
        lessonStatus = contentData.lessonStatus;
        relateType = contentData.relateType;
        teacherName = contentData.teacherName;
        startTime = contentData.startTime;
        endTime = contentData.endTime;
        scheduleId = contentData.scheduleId;
        hasRecord = contentData.hasRecord;
        lessonType = contentData.lessonType;
        if(lessonType == "V"||relateType == "V"){//请假的不显示
            lessonView.visible = false;
        }else
        {
            lessonView.visible = true;
        }
    }

    Text{
        width: parent.width
        height: parent.height * 0.5
        color: fontColor
        font.family: Cfg.LESSON_FONT_FAMILY
        font.bold: Cfg.LESSON_FONT_BOLD
        font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
        anchors.top:parent.top
        anchors.topMargin: 4*heightRate
        text: {
            if(lessonType == "L"){
                height = parent.height
                timeText.visible = false;
                return "直播课"
            }
            if(lessonType == "V"){
                height = parent.height
                timeText.visible = false;
                return "请假"
            }
            timeText.visible = true;
            height = parent.height * 0.5
            return teacherName + " " + subject;
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Text{
        id: timeText
        width: parent.width
        height:  parent.height * 0.5
        color: fontColor
        text: analysisDate(startTime,endTime)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -5*heightRate
        font.family: Cfg.LESSON_FONT_FAMILY
        font.bold: Cfg.LESSON_FONT_BOLD
        font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
    }

    //状态图标、请假、完成、旷课等
    Image{
        id: statusItem
        width: 20 * heightRate
        height: 18 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        anchors.right: parent.right
        anchors.rightMargin: 1
        source:{
            if(lessonType == "L"){
                statusItem.visible = false;
                return "";
            }
            if(lessonType == "V"){
                statusItem.visible = false;
                return "";
            }
            if(lessonStatus ==1){//完成状态
                statusItem.visible = true;
                if(analysisCurrentDate(startTime)){
                    return "qrc:/images/done_org@2x.png";
                }
                else{
                    return  "qrc:/images/done_blue@2x.png";
                }
            }
            if(lessonStatus == 2 || lessonStatus ==3){//请假状态
                statusItem.visible = true;
                if(lessonStatus ==2){
                    return "qrc:/images/dayoff_red@2x.png";
                }else{
                    return "qrc:/images/dayoff_yellow@2x.png";
                }
            }
            if(lessonStatus ==4){//旷课状态
                statusItem.visible = true;
                return "qrc:/images/icon_kuangke@2x.png"
            }
            else{
                statusItem.visible = false;
                return "";
            }
        }
    }

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

