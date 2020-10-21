import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import YMLessonManagerAdapter 1.0
import "../Configuration.js" as Cfg

//课程目录
Item {
    anchors.fill: parent

    property var dataModel: [];
    property bool isClassRomm: false;//false 不能进入教室 true 能进教室
    property string executionPlanId: "";

    property string bigCoverUrl: "";
    property string categoryName:"913-920";
    property string endTime:"12:01";
    property string courseName:"测试课程-xgl";
    property string startTime: "10:01";

    property int currentPageIndex: 1;

    signal sigCourseCatalog(var id,var dataJson,var currentPage);
    signal sigRoback(var currentPage);

    onDataModelChanged: {
        lessonMgr.getCatalogs(dataModel.classId);
    }

    YMLessonManagerAdapter{
        id: lessonMgr

        onSigJoinClassroomFail: {
            massgeTips.tips = "进入教室失败!";
            massgeTips.visible = true;
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

        onSigPlaybackInfo: {
            var platform = playbackData.platform;
            var playInfoArry = playbackData.list;

            if(platform == 1){//拓课云录播状态
                playerDirectory.resetModelData(playInfoArry);
                playerDirectory.visible = true;
                setPlanVisible(false);
            }
        }

        onSigBrowseCoursewareFail: {
            massgeTips.tips = "备课资料正在生成中，请稍后再试....";
            massgeTips.visible = true;
        }

        onSigJoinClassroom: {
            console.log("====joinClassroom===",JSON.stringify(joinClassroomInfo));
            isClassRomm = true;
            if(windowView.isPublicText == false){
                if(joinClassroomInfo.data.path == undefined || joinClassroomInfo == {}){
                    return;
                }
                var url = joinClassroomInfo.data.path;
                talkCloudClassroom.visible = true; //小班课二期, 不需要显示拓课云的小班课的view
                talkCloudClassroom.resetWebViewUrl(url);
                return
            }

            if(joinClassroomInfo.path == null || joinClassroomInfo.path == undefined){
                isClassRomm = false;
                return;
            }

            talkCloudClassroom.visible = true; //小班课二期, 不需要显示拓课云的小班课的view
            talkCloudClassroom.resetWebViewUrl(joinClassroomInfo.path);
        }

        onSigJoinClassroomStaus: {
            massgeTips.visible = true;
            massgeTips.tips = "正在进入教室,请稍候..."
        }

        onProgramRuned: {
            massgeTips.visible = false;
        }

        onSigCatalogsInfo: {
            console.log("===onSigCatalogsInfo===",JSON.stringify(catalogsInfo))
            var listData = catalogsInfo.data.list;
            var courseInfo = catalogsInfo.data.info;
            executionPlanId = "";
            isClassRomm = true;
            if(courseInfo == null){
                isClassRomm = false;
                console.log("===onSigCatalogsInfo::null====");
                return;
            }

            if(courseInfo == undefined || courseInfo == []){
                isClassRomm = false;
            }else{
                startTime = courseInfo.startTime;
                endTime = courseInfo.endTime;
                categoryName = courseInfo.categoryName;
                courseName = courseInfo.name;
                bigCoverUrl = courseInfo.bigCoverUrl;
            }

            if(courseInfo.executionPlanId == null || courseInfo.executionPlanId == undefined){
                isClassRomm = false;
            }else{
                executionPlanId = courseInfo.executionPlanId;
            }
            console.log("====isClassRomm=====",isClassRomm,executionPlanId);
            courseModel.clear();
            for(var i = 0; i < listData.length; i++){
                var dataListObj = listData[i];
                var isHighligth = executionPlanId== "" ? false : (dataListObj.executionPlanId == executionPlanId ? true : false);
                courseModel.append(
                            {
                                highlight: isHighligth,
                                executionPlanId: dataListObj.executionPlanId,
                                className: dataListObj.className,
                                title: dataListObj.title,
                                startTime: formartStartDate(dataListObj.startTime),
                                endTime: formartEndDate(dataListObj.endTime),
                                isCourseware: dataListObj.isCourseware,
                                type: dataListObj.type,
                                tips: dataListObj.tips,
                                title: dataListObj.title,
                                handleStatus: dataListObj.handleStatus == null ? 4 : dataListObj.handleStatus,
                            });
            }
        }
    }

    function setPlanVisible(visibles){
        robackBtn.visible = visibles;
        headRec.visible = visibles;
        lineView.visible = visibles;
        courseView.visible = visibles;
    }

    MouseArea{//返回按钮
        id: robackBtn
        z: 66
        width: 24 * widthRate
        height: 24 * widthRate
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        anchors.top: parent.top
        anchors.topMargin: 16 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 5 * heightRate

        Image{
            anchors.fill: parent
            source: "qrc:/talkcloudImage/xbk_btn_back@2x.png"
        }

        onClicked: {
            sigRoback(currentPageIndex);
        }
    }

    Item{//头内容展示
        id: headRec
        width: parent.width
        height: 160 * heightRate

        Image {
            id: lessonImg
            width: 160 * heightRate
            height: 90 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 45 * heightRate
            source:  bigCoverUrl
            anchors.top: parent.top
            anchors.topMargin: (parent.height - height) * 0.5 + 20 * heightRate
            asynchronous: true
            sourceSize.width: width
            sourceSize.height: height
        }

        Text{
            id: classText
            anchors.top: parent.top
            anchors.topMargin: 50 * heightRate
            anchors.left: lessonImg.right
            anchors.leftMargin: 20 * heightRate
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 20 * heightRate
            text: courseName
        }

        Column{
            width: parent.width * 0.4
            height: parent.height - 20 * heightRate
            anchors.left: lessonImg.right
            anchors.leftMargin: 20 * heightRate
            anchors.top: classText.bottom
            anchors.topMargin: 14 * heightRate
            spacing: 10 * heightRate

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: qsTr("开课时间：") + categoryName
                color: "#666666"
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: qsTr("上课时段：") + startTime + "-" + endTime
                color: "#666666"
            }
        }

        MouseArea{//进入教室按钮
            id: joinBtn
            width: 90 * widthRate
            height: 43 * widthRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 65 * heightRate
            enabled: isClassRomm

            Image{
                anchors.fill: parent
                source: joinBtn.enabled ? "qrc:/talkcloudImage/xbkth_btn)_jinrujiaoshi@2x.png" : "qrc:/talkcloudImage/xbkth_btn_jinrujiaoshi_disable@2x.png"
            }

            onClicked: {
                windowView.isMiniClassroom = true;
                lessonMgr.setQosStartTime(startTime,endTime);
                //自研教室上线则去掉此代码
                if(windowView.isPublicText == false){
                    lessonMgr.getJoinTalkClassRoomInfo(executionPlanId);
                    return;
                }

                console.log("==executionPlanId==",executionPlanId,windowView.isMiniClassroom);
                lessonMgr.getJoinClassRoomInfo(executionPlanId);
            }
        }

    }

    Rectangle{//横线
        id: lineView
        width: parent.width - 90 * heightRate
        height: 1
        color: "#e0e0e0"
        anchors.top: headRec.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ListView{
        id: courseView
        clip: true
        width: parent.width
        height: parent.height - headRec.height
        anchors.top: headRec.bottom
        anchors.topMargin: 2
        model: courseModel
        delegate: courseComponent
    }

    ListModel{
        id: courseModel
    }

    Component{
        id: courseComponent
        Item{
            width: courseView.width
            height: 120 * heightRate

            Rectangle{
                width: parent.width - 90 * heightRate
                height: parent.height
                color: "#fffef9"
                visible: highlight
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: numberText
                color: highlight ? "#ff6633" : "#bbbbbb"
                text: className
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 17.5 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: 45 * heightRate
                anchors.verticalCenter: parent.verticalCenter
            }

            Row{
                id: rowOne
                width: parent.width * 0.5
                anchors.left: numberText.right
                anchors.leftMargin: 30 * heightRate
                anchors.top: parent.top
                anchors.topMargin:  (parent.height - height - height ) * 0.5
                spacing: 10 * heightRate


                Image{
                    id: examImg
                    width: 52 * heightRate
                    height: 25 * heightRate
                    visible: false
                    source: "qrc:/talkcloudImage/xbk_icon_exam.png"
                }

                Text {
                    text: title
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 17.5 * heightRate
                }
            }

            Text {
                text: startTime + "-" + endTime
                color: "#666666"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                anchors.top: rowOne.bottom
                anchors.topMargin: 10 * heightRate
                anchors.left: numberText.right
                anchors.leftMargin: 30 * heightRate
            }

            MouseArea{
                width: 90 * heightRate
                height: 45 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: 150 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                cursorShape: Qt.PointingHandCursor
                visible: isCourseware

                Image {
                    id: readyImg
                    width: 16 * widthRate
                    height: 16 * widthRate
                    source: "qrc:/talkcloudImage/xbkth_btn_beike@2x.png"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    color: "#788190"
                    text: qsTr("备课资料")
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    anchors.left: readyImg.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: {
                    if(isCourseware){
                        lessonMgr.browseCourseware(executionPlanId);
                    }
                }
            }

            MouseArea{
                width: 90 * heightRate
                height: 32 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: 45 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                cursorShape: Qt.PointingHandCursor
                enabled: (handleStatus == 3 || handleStatus == 1) ? true : false

                onClicked: {
                    console.log("====onClicked=====",handleStatus)
                    if(handleStatus == 1){
                        lessonMgr.getJoinClassRoomInfo(executionPlanId);
                    }

                    if(handleStatus == 3){
                        lessonMgr.getPlayback(executionPlanId);
                    }
                }

                Rectangle{
                    id: playerBtn
                    anchors.fill: parent
                    radius: 14 * heightRate
                    border.width: 1
                    border.color: {
                        switch(handleStatus){//查看录播的状态
                            case 1: //进入教室
                                playerBtn.border.color = "#ff5500";
                                playerBtn.color = "#ff5500";
                                playerText.text = "进入教室";
                                playerText.color = "#ffffff";
                                break;
                            case 2: //录播生成中
                                playerBtn.border.color = "#aaaaaa";
                                playerBtn.color = "#ffffff"
                                playerText.text = "录播生成中";
                                playerText.color = "#aaaaaa";
                                break;
                            case 3: //查看录播
                                playerBtn.border.color = "#ff6633";
                                playerBtn.color = "#ffffff";
                                playerText.text = "查看录播";
                                playerText.color = "#ff6633";
                                break;
                            case 4: //待开课
                                playerBtn.border.color = "#FFF9F6";
                                playerBtn.color = "#FFF9F6";
                                playerText.text = "待开课";
                                playerText.color = "#ff6633";
                                break;
                            case 5: //已结束
                                playerBtn.border.color = "#F3F6F9";
                                playerBtn.color = "#F3F6F9";
                                playerText.text = "已结束";
                                playerText.color = "#a3a9af";
                                break;
                            default :
                                playerBtn.border.color ="#a3a9af";
                                playerBtn.color = "#ffffff";
                                playerText.color = "#a3a9af";
                        }
                    }

                    Text {
                        id: playerText
                        text: "查看录播"
                        font.pixelSize: 12 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        anchors.centerIn: parent
                    }
                }
            }

            Rectangle{
                width: parent.width - 90 * heightRate
                height: 1
                color: "#f3f6f9"
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }
    }

    Connections{
        target: windowView
        onSigVisiblePlay:{
            setPlanVisible(true);
        }
    }

    function refreshPage(){
        //talkCloudClassroom.visible = false;
        //talkCloudClassroom.resetWebViewUrl(joinClassroomInfo.data.path);
        lessonMgr.getCatalogs(dataModel.classId);
    }

    function formartEndDate (endDateTime){
        var formartEndDate = new Date(endDateTime);
        var endHours = Cfg.addZero(formartEndDate.getHours());
        var endMinutes = Cfg.addZero(formartEndDate.getMinutes());

        return  endHours + ":" +endMinutes;
    }

    function formartStartDate(startDateTime){
        var formartStartDate = new Date(startDateTime);
        var year = formartStartDate.getFullYear();
        var month = Cfg.addZero(formartStartDate.getMonth() + 1);
        var day = Cfg.addZero(formartStartDate.getDate());
        var hours = Cfg.addZero(formartStartDate.getHours());
        var minutes = Cfg.addZero(formartStartDate.getMinutes());
        var week = formartStartDate.getDay();
        var weekData = "";
        switch(week){
        case 1:
            weekData =  "星期一";
            break;
        case 2:
            weekData =  "星期二";
            break;
        case 3:
            weekData =  "星期三";
            break ;
        case 4:
            weekData =  "星期四";
            break;
        case 5:
            weekData =  "星期五";
            break;
        case 6:
            weekData =  "星期六";
            break;
        default :
            weekData =  "星期日";
            break;
        }

        return  year + "年" + month + "月" + day + "日" + "  " + weekData + "  " + hours + ":" + minutes;
    }
}
