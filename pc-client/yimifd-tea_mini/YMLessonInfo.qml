import QtQuick 2.0
import QtQuick.Controls 1.4
import YMLessonManagerAdapter 1.0

import "Configuration.js" as Cfg

/***课程表详细信息***/

MouseArea {
    id: lessonView
    z: 8888
    anchors.fill: parent
    onWheel: {
        return;
    }

    property var lessonData: [];
    property bool displayerStatus: false;//显示窗体状态

    property string contractNo: "";
    property string subject: "";
    property string parentContactInfo: "";
    property string lessonId: "";
    property string clientNo: "";
    property string relateType: "";
    property var hasCourseware: false;
    property string chargeMobile: "";
    property string parentRealName: "";
    property string grade: "";
    property string name: "";
    property var startTime: [];
    property var endTime: [];
    property var nowTime: [];
    property string chargeName: "";
    property int hasRecord: 0;
    property string lessonType: "";
    property int lessonStatus: 3;
    property string teacherId: "";
    property var numbers: 0;

    property bool disableHasRecord: false; //禁用录播
    property bool enableClass: false;//禁用教室

    property double  widthRate : parent.width/ 1000.0;
    property double  heightRate : parent.height/ 600.0;

    signal lessonRefreshData();

    //遮罩颜色
    Rectangle{
        color: "black"
        opacity: 0.4
        radius:  12 * widthRate
        anchors.fill: parent
    }

    onDisplayerStatusChanged: {
        lessonView.visible = true;
        animateInOpacity.start();
    }
    //淡入效果
    NumberAnimation{
        id: animateInOpacity
        target: lessonView
        duration: 300
        properties: "opacity"
        from: 0.0
        to: 1.0
        onStarted: {
            animationHeight.start();
        }
    }

    //淡出效果
    NumberAnimation{
        id: animateOutOpactiy
        target: lessonView
        duration: 300
        properties: "opacity"
        from: 1.0
        to: 0.0
        onStopped: {
            lessonView.visible = false;
        }
        onStarted: {
            animation.start();
        }
    }

    //退出缩小动画
    PropertyAnimation{
        id: animation
        target: bodyItem
        property: "height"
        from: 270 * heightRate
        to: 0
        duration: 300
    }
    //弹出放大动画
    PropertyAnimation{
        id: animationHeight
        target: bodyItem
        property: "height"
        from: 0
        to: 270 * heightRate
        duration: 300
        onStarted:{
            bodyItem.visible = true;
        }
    }

    YMLessonManagerAdapter{
        id: lessonMgr
        onLessonlistRenewSignal: {
            lessonView.visible = false;
            classView.visible = false;
            enterClassRoom = true;
            lessonRefreshData();
        }
        onSigJoinClassroomFail: {
            enterClassRoom = true;
            massgeTips.tips = "进入教室失败!";
            massgeTips.visible = true
            classView.visible = false;
        }
        onSigJoinClassroom:{
            classView.visible = false;
            if(joinClassroomInfo.path == undefined){
                return;
            }

            var url = joinClassroomInfo.path;
            talkCloudClassroom.visible = true; //小班课二期, 不需要显示拓课云的小班课的view
            windowView.isMiniClassroom = true;
            talkCloudClassroom.resetWebViewUrl(url);
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
        onListenChange:{
            enterClassRoom = true;
            massgeTips.tips = "还未开始上课，暂时无法旁听!";
            massgeTips.visible = true
            classView.visible = false;
        }
        onProgramRuned:{
           // classView.visible = false;
            classView.hideAfterSeconds();
        }
        onRequstTimeOuted: {
            lessonView.visible = false;
            classView.visible = false;
            enterClassRoom = true;
        }
        onSigRepeatPlayer: {
            massgeTips.tips = "录播暂未生成，请在课程结束半小时后进行查看!";
            massgeTips.visible = true;
        }
        onSigPlaybackInfo:{
            var platform = playbackData.platform;
            var playInfoArry = playbackData.list;

            if(platform == 1){//拓课云录播状态
                playerDirectory.resetModelData(playInfoArry);
                playerDirectory.visible = true;
            }
        }
    }

    //数据接收
    onLessonDataChanged: {
        console.log("===lessonInfo===",JSON.stringify(lessonData))
        if(lessonData == null || lessonData == [] || lessonData.executionPlanId == undefined){
            return;
        }

        lessonId = lessonData.executionPlanId;//教室Id
        hasCourseware = lessonData.isCourseware;//是否有课件
        //grade = lessonData.grade;
        //lessonType = lessonData.lessonType;
        name = lessonData.name;//课程名称
        startTime = lessonData.startTime;//开始时间
        endTime = lessonData.endTime;//结束时间
        if(lessonData.handleStatus == undefined){
            lessonStatus = lessonData.status;//5：已结束，1:进入教室 2:录播未生成 3:录播视频生成 4:待开课 5:已结课
        }else{
            lessonStatus = lessonData.handleStatus;
        }

        teacherId = userId;
        numbers = lessonData.numbers == undefined ? 0 : lessonData.numbers;
        if(lessonStatus == 1){
            enableClass = true;
        }
    }

    Rectangle{
        id: bodyItem
        width: 270 * widthRate
        height: 270 * heightRate
        radius: 12 * widthRate
        color: "#ffffff"
        anchors.centerIn: parent

        MouseArea{
            id: closeButton
            z: 2
            width: 18 * widthRate
            height: 18 * widthRate
            hoverEnabled: true
            anchors.top: parent.top
            anchors.topMargin: 5*heightRate
            anchors.right: parent.right
            anchors.rightMargin: 5*heightRate
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                anchors.fill: parent
                radius: 100
                color: parent.containsMouse ? "red" : "gray"

                Text{
                    text: "×"
                    font.bold: true
                    font.pixelSize: 12 * heightRate
                    color: "white"
                    anchors.centerIn: parent
                }
            }
            onClicked: {
                animateOutOpactiy.start();
            }
        }

        Rectangle{
            id: headItem
            width: parent.width
            height: 75 * heightRate
            radius: 12 * widthRate
            anchors.top: parent.top
            Image{
                anchors.fill: parent
                source: lessonType == "O" ? "qrc:/images/dialog_bgblue.png" : "qrc:/images/sh_dialog_bgorg.png"
            }

            Row{
                id: oneRow
                width: parent.width
                height: 30*heightRate
                anchors.left: parent.left
                anchors.leftMargin: Cfg.LESSON_MARGIN*widthRate
                spacing: 10 * heightRate
                anchors.top: parent.top
                anchors.topMargin: 10 * heightRate

                Text{
                    height: parent.height
                    text: analysisDate(startTime)
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_INFO_2FONTSIZE  * heightRate
                    color:lessonType == "O" ? "#3a80cd" : "#ee5a5a"
                    verticalAlignment: Text.AlignVCenter
                }

                Text{
                    height: parent.height
                    text: analysisTime(startTime,endTime);
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_INFO_2FONTSIZE * heightRate
                    color:lessonType == "O" ? "#3a80cd" : "#ee5a5a"
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Row{
                id:nameGradeSubjectRow
                width: parent.width
                height: 30 * heightRate
                anchors.top: oneRow.bottom
                anchors.topMargin: 1 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: Cfg.LESSON_MARGIN * widthRate
                spacing: 10 * heightRate

                Item{
                    width: parent.width * 0.8
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                    Text{
                        width: parent.width * 1.2
                        height: parent.height
                        text: name
                        font.family: Cfg.LESSON_INFO_FAMILY
                        font.pixelSize: Cfg.LESSON_INFO_2FONTSIZE * heightRate
                        color:lessonType == "O" ? "#3a80cd" : "#ee5a5a"
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Column{
            width: parent.width
            height: parent.height - headItem.height
            anchors.top: headItem.bottom

            Row{
                width: parent.width - 40 * heightRate
                height: parent.height * 0.2
                spacing: 8 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: qsTr("教室ID：")
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 12 * widthRate
                    color: "#999999"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: lessonId
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 12 * widthRate
                    color: "#333333"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row{
                width: parent.width - 40 * heightRate
                height: parent.height * 0.2
                spacing: 8 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: qsTr("班级名称：")
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 12 * widthRate
                    color: "#999999"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: name
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 12 * widthRate
                    color: "#333333"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row{
                width: parent.width - 40 * heightRate
                height: parent.height * 0.2
                spacing: 8 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: qsTr("学生人数：")
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 12 * widthRate
                    color: "#999999"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: numbers + "人"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 12 * widthRate
                    color: "#333333"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        MouseArea{
            id: lessonButton
            width: 115 * widthRate
            height: 33 * heightRate
            enabled: hasCourseware ? true : false
            anchors.left: parent.left
            anchors.leftMargin: 15 * widthRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16 * heightRate
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                radius: 2 * heightRate
                anchors.fill: parent
                color: hasCourseware ? Cfg.TB_CLR : "#c3c6c9"
                border.width: 1
                border.color: hasCourseware ? Cfg.TB_CLR : "#c3c6c9"
                Text{
                    text: "查看课件"
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_INFO_3FONTSIZE * heightRate
                    color: "#ffffff"
                    anchors.centerIn: parent
                }
            }
            onClicked: {
                var lessonInfo = {
                    "lessonId": lessonId,
                    "startTime": analysisDate(startTime),
                    "lessonStatus":hasRecord == 0 ? 0 : 1
                }
                lessonView.visible = false;
                lessonMgr.browseCourseware(lessonId);
            }
        }

        MouseArea{
            width: 115 * widthRate
            height: 33 * heightRate
            enabled: (enableClass || lessonStatus == 3) ? true : false
            anchors.left: lessonButton.right
            anchors.leftMargin: 10 * widthRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16 * heightRate
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                radius: 2 * heightRate
                color: (enableClass || lessonStatus == 3) ? "#ff5000" : "#c3c6c9"
                anchors.fill: parent
                border.width: 1
                border.color: (enableClass ? Cfg.TB_CLR : "#c3c6c9")

                Text{
                    text: {
                        if(lessonStatus == 1)
                            return "进入教室";
                        if(lessonStatus == 2)
                            return "录播视频未生成";
                        if(lessonStatus == 3)
                            return "录播视频生成";
                        if(lessonStatus == 4)
                            return "待开课";
                        if(lessonStatus == 5)
                            return "已结课";
                        else{
                            return "待开课";
                        }
                    }
                    font.family: Cfg.LESSON_INFO_FAMILY
                    font.pixelSize: Cfg.LESSON_INFO_3FONTSIZE * heightRate
                    color: "#ffffff"
                    anchors.centerIn: parent
                }
            }

            onClicked: {
                if(lessonStatus == 1 && enterClassRoom ){
                    lessonMgr.setQosStartTime(startTime,endTime);
                    classView.visible = true;
                    enterClassRoom = false;
                    classView.tips = "进入教室中..."
                    lessonView.visible = false;
                    lessonMgr.getJoinClassRoomInfo(lessonId);
                }
                if(lessonStatus == 3){
                    var lessonDataInfo = {
                        "lessonId": lessonId,
                        "startTime": analysisDate(startTime),
                        "gradeName":grade,//年级
                        "subjectName": subject,//科目
                        "realName": realName,//姓名
                    }
                    progressbar.currentValue = 0;
                    lessonMgr.getPlayback(lessonId);
                    lessonView.visible = false
                }
            }
        }
    }

    function analysisDate(startTime){
        var currentStartDate = new Date(parseInt(startTime));
        //console.log("====analysisDate====",currentStartDate,startTime);
        var year = currentStartDate.getFullYear();
        var month = Cfg.addZero(currentStartDate.getMonth() + 1);
        var day = Cfg.addZero(currentStartDate.getDate());

        return year + "-" + month + "-" + day;
    }

    function analysisTime(startTime,endTime){
        var currentStartDate = new Date(parseInt(startTime));
        var currentEndDate = new Date(parseInt(endTime));
        var sTime = Cfg.addZero(currentStartDate.getHours()) + ":" + Cfg.addZero(currentStartDate.getMinutes());
        var eTime = Cfg.addZero(currentEndDate.getHours()) + ":" + Cfg.addZero(currentEndDate.getMinutes());
        return sTime + "-" + eTime;
    }

}

