import QtQuick 2.0
import "../../Configuration.js" as Cfg

Rectangle {
    id: lessonView
    width: parent.width - 1
    height: parent.height
    visible: false
    property double heightRate: widthRate / 1.5337;
    property bool workTimeVisible: false;

    anchors.bottom: parent.bottom

    property string lessonId: ""
    property string studentName: "";
    property string grade: "";
    property string lessonName: "";
    property var lessonStatus: []; //0，未完成；1，已完成；2，请假(不扣课时)；3，$请假((扣课时))；4，旷课
    property string lessonType: "";
    property string relateType: "";
    property var startTime: [];
    property var endTime: [];
    property var scheduleId: [];
    property var lessonDataInfo: [];
    property bool colorStatus: false;

    signal lessonIdConfirm(var lessonId);

    onLessonDataInfoChanged: {
        if(lessonDataInfo == null || lessonDataInfo == []){
            return;
        }
        var displayerMark = false;
        for(var i = 0; i < lessonDataInfo.count;i++){
            displayerMark = true;
            //console.log("sssssssssssss::",lessonDataInfo.get(i).lessonId,lessonDataInfo.get(i).startTime,lessonDataInfo.get(i).endTime)
            lessonId = lessonDataInfo.get(i).lessonId;
            lessonType = lessonDataInfo.get(i).lessonType;
            relateType = lessonDataInfo.get(i).relateType;
            studentName = lessonDataInfo.get(i).name;
            grade = lessonDataInfo.get(i).grade;
            lessonStatus = lessonDataInfo.get(i).lessonStatus;// == "" ? 0 : lessonDataInfo.get(i).lessonStatus;
            startTime = lessonDataInfo.get(i).startTime;// == "" ? "1507535400000" : lessonDataInfo.get(i).startTime.toString();//
            endTime = lessonDataInfo.get(i).endTime;// == "" ? "1507537800000" : lessonDataInfo.get(i).endTime.toString();//;
            scheduleId = lessonDataInfo.get(i).scheduleId;
            lessonName = lessonDataInfo.get(i).subject
            lessonView.height = 60 * heightRate * lessonDataInfo.get(i).lineHeight;
        }
        if(displayerMark){
            lessonView.visible = true;
            colorStatus = analysisDate(startTime,endTime);
        }

        // console.log(lessonDataInfo.get(0).scheduleId,lessonDataInfo.get(0).dateId,lessonDataInfo.get(0).lessonId,"scheduleId~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    }
    //工作时间和非工作时间标示
    Item {
        anchors.fill: parent
        visible: workTimeVisible
        Image {
            width: 12 * heightRate
            height: 12 * heightRate
            anchors.right: parent.right
            anchors.top: parent.top
            visible: lessonView.visible
            source: "qrc:/images/th_icon_rest@2x.png"
        }
    }
    //请假课图标 旷课图标
    Rectangle {
        width:lessonStatus == 4 ? 13 *widthRate : 25 * widthRate
        height: 16 * heightRate
        radius: 2 * heightRate
        visible: lessonStatus == 2 || lessonStatus == 3 || lessonStatus == 4
        color: lessonStatus == 2 ? "#E88D7D": lessonStatus == 3 ? "#FFD200" : "gray"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        Text {
            anchors.centerIn: parent
            font.family: Cfg.LESSON_FONT_FAMILY
            font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
            text: lessonStatus==2 ? "请假" : lessonStatus == 3 ? "￥请假" : "旷"
            color:"white"
        }
    }

    border.width: 1
    border.color:
    {
        //当天当前时间高亮
        if(lessonType == 'V' || relateType == "V"){
            return "#e3e6e9"//"#d1daff";
        }
        else if(colorStatus&&(lessonStatus !=2 ||lessonStatus !=3 && lessonStatus != 4 )){
            return "#ff6633"
        }else if(lessonType == 'O'){
            return "#4990e2";
        }else if(lessonType == 'A'){
            return  "#ff8e68";
        }else if(lessonType == 'L'){
            return  "#b9d09c";
        }else{
            return "transparent";
        }
    }

    color: {
        //当天当前时间高亮
        if(lessonType == 'V' || relateType == 'V'){
            return "#f1f3ff";
        }else if(colorStatus&&(lessonStatus !=2 ||lessonStatus !=3 && lessonStatus != 4 )){
            return "#ff6633"
        }else if(relateType == 'O'){
            return "#dff6ff";
        }else if(relateType == 'A'){
            return  "#ffe3d9";

        }else if(relateType == 'L'){
            return  "#f0ffdd";

        }
        else{
            return "#ffffff";
        }
    }

    MouseArea{
        anchors.fill: parent
        onClicked: {
            if(lessonType == 'V' || relateType == 'V'){
              return
            }
            if(lessonType == 'L' || lessonType == 'V' || relateType == 'V'){
                liveLessonView.getLiveLessonDetailData(lessonId);
                liveLessonView.visible=true;
                return
            }

            lessonIdConfirm(lessonId);
        }
        cursorShape: Qt.PointingHandCursor
    }
    //第一行字体显示
    Item{
        id: oneItem
        width: parent.width
        height: {
            if(studentName== "" && grade == ""){
                return 10;
            }
            return 20;
        }
        anchors.top: parent.top
        anchors.topMargin: (parent.height - 40) * 0.5

        Text{
            text: lessonType == 'L' ? " " : studentName + " " + grade
            anchors.centerIn: parent
            font.family: Cfg.LESSON_FONT_FAMILY
            font.pixelSize: Cfg.LESSON_2FONTSIZE * heightRate
            color: {
                //当天当前时间高亮
                if(lessonType == 'V'  || relateType == "V"){
                    return "#8a8fa9";
                }
                else if(colorStatus &&(lessonStatus !=2 ||lessonStatus !=3 && lessonStatus != 4 )){
                    return "#ffffff"
                }else if(lessonType == 'O'){
                    return "#3a80cd";
                }else if(lessonType == 'A'){
                    return  "#ff662d";

                }else if(lessonType == 'L'){
                    return  "#8cbd5a";

                }
                else{
                    return "#000000";
                }
            }
        }
    }
    //第二行字体显示
    Item{
        width: parent.width
        height: 20
        anchors.top: oneItem.bottom
        Text{
            text:{
                var type = ""
                if(lessonType == 'O'){
                    return lessonName + "(订)";
                }else if(lessonType == 'A'){
                    return  lessonName + "(试)";

                }else if(lessonType == 'L'){
                    return  "直播课";

                }else if(lessonType == 'V'){
                    return "请假";
                }
                lessonName + lessonType
            }
            color: {
                //当天当前时间高亮
                if(lessonType == 'V'  || relateType == "V"){
                    return "#8a8fa9";
                }
                else if(colorStatus &&(lessonStatus !=2 ||lessonStatus !=3 && lessonStatus != 4 )){
                    return "#ffffff"
                }else if(lessonType == 'O'){
                    return "#3a80cd";
                }else if(lessonType == 'A'){
                    return  "#ff662d";

                }else if(lessonType == 'L'){
                    return  "#8cbd5a";

                }else{
                    return "#000000";
                }
            }
            anchors.centerIn: parent
            font.family: Cfg.LESSON_FONT_FAMILY
            font.pixelSize: Cfg.LESSON_2FONTSIZE * heightRate
        }
    }

    //已完成
    Rectangle{
        id: statusItem
        width: 25 * widthRate
        height: 16 * heightRate
        radius: 2 * heightRate
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        color: {
            if(colorStatus){
                return "#ffffff"
            }
            if(lessonType == 'O'){
                return "#2f7ecf";
            }
            if(lessonType == 'A'){
                return  "#ff6633";
            }else{
                return "#ffffff";
            }
        }

        Text{
            text: {
                if(lessonStatus == 1){
                    if(lessonType == 'L'){
                        statusItem.visible = false
                        return
                    }

                    statusItem.visible = true;
                    return "已完成";
                }else{
                    statusItem.visible = false;
                    return "";
                }
            }
            color: {
                if(colorStatus){
                    return "#ff6633"
                }
                if(lessonType == 'O'){
                    return "#ffffff";
                }
                if(lessonType == 'A'){
                    return  "white";
                }else{
                    return "#ffffff";
                }
            }
            anchors.centerIn: parent
            font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
        }
    }


    function analysisDate(startTime,endTime){
        if(startTime == [] || endTime == [] || startTime == 0 || endTime == 0){
            //console.log("sssssssssssssssssss")
            return false;
        }

        var currentStartDate = new Date(parseInt(startTime));
        var year = currentStartDate.getFullYear();
        var month = currentStartDate.getMonth();
        var day = currentStartDate.getDate();
        var hours = currentStartDate.getHours();
        var minutes = currentStartDate.getMinutes();

        var endDateTime = new Date(parseInt(endTime));
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

