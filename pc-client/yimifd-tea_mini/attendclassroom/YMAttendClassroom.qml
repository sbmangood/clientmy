import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import YMLessonManagerAdapter 1.0
import "../Configuration.js" as Cfg

/*******旁听******/
Item {
    anchors.fill: parent
    property int pageIndex: 1;
    property int page: 1;
    property int pageSize: 20;
    property int totalPage: 1;
    property int status: 0 ;//状态，0:预课、2:上课中、3:休息、5:下课、4:掉线、1:已结束、6:未上课
    property string roomId: ""; // 教室ID
    property string chapterName:"";// 课节名称
    property string teacherName: "";// 老师姓名
    property string planStartTime: "";// 开始时间
    property string planEndTime: "";// 结束时间

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
        // 旁听课程列表信号
        onAttendLessonListInfoChanged:{
            lessonMgr.getListenTeachers();
            lessonMgr.findGradeAndSubject();
            analysisData(lessonListInfo);
        }
        // 加载旁听课程列表完成信号
        onLoadingAttendLessonListInfoFinished:{
            loadingView.opacityAnimation = !loadingView.opacityAnimation;
        }
        // 老师列表信号
        onListenTeachersListInfoChanged:{
            analysisTeachersData(teacherListInfo);
        }
        // 当前老师学科和年级
        onGradeAndSubjectInfoChanged:{
            analysisGradeSubjectData(gradeSubjectInfo);
        }
        // 进入教室完成信号
        onProgramRuned:{
            classView.visible = false;
            //classView.hideAfterSeconds();
        }
        // 查看回放信号
        onSigPlaybackInfo:{
            massgeTips.tips = "录播暂未生成，请在课程结束半小时后进行查看!";
            massgeTips.visible = true;
        }
        // 回放下载完成
        onDownloadFinished:{
            progressbar.visible = false;
        }
        onSetDownValue:{
            progressbar.min = min;
            progressbar.max = max;
            progressbar.visible = true;
        }
        onDownloadChanged:{
            progressbar.currentValue = currentValue;
        }
    }

    //网络显示提醒
    Rectangle{
        id: networkItem
        z: 86
        visible: false
        anchors.fill: parent
        radius:  12 * widthRate
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
                border.width: 1
                radius: 4
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

    // 查询条件栏
    Grid {
        id: filterItem
        anchors.top: parent.top
        anchors.topMargin: 25 * heightRate
        width: parent.width - 40 * widthRate
        height: 30 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 30 * heightRate
        columns: 6
        spacing: filterItem.width/35

        // 老师姓名
        Rectangle {
            height: parent.height
            width: parent.width/7
            Text {
                id: teaNameTxt
                height: parent.height
                width: parent.width*2/5
                text:"老师姓名:"
                font.bold: false
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                color: "#aaaaaa"
                verticalAlignment: Text.AlignVCenter
            }
            YMComboxControl {
                id: comboBox
                height: parent.height
                width: parent.width*3/5
                anchors.left: teaNameTxt.right
                anchors.leftMargin: 2*widthRate
                model: teacherModel
                currentIndex: 0
                onCurrentTextChanged: {
                    pagtingControl.currentPage = 1;
                    pageIndex = 1;
                }
            }
        }

        // 学科
        Rectangle {
            height: parent.height
            width: parent.width/7
            Text {
                id: subTxt
                height: parent.height
                width: 35*widthRate
                text:"学科:"
                font.bold: false
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                color: "#aaaaaa"
                verticalAlignment: Text.AlignVCenter
            }
            YMComboxControl {
                id: comboBoxSub
                height: parent.height
                width: 75*widthRate
                anchors.left: subTxt.right
                model: subjectModel
                onCurrentTextChanged: {
                    pagtingControl.currentPage = 1;
                    pageIndex = 1;
                }
            }
        }

        // 年级
        Rectangle {
            height: parent.height
            width: parent.width/7
            Text {
                id: gradTxt
                height: parent.height
                width: 35*widthRate
                text:"年级:"
                font.bold: false
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                color: "#aaaaaa"
                verticalAlignment: Text.AlignVCenter
            }
            YMComboxControl {
                id: comboBoxGrad
                height: parent.height
                width: 75*widthRate
                anchors.left: gradTxt.right
                model: gradeModel
                onCurrentTextChanged: {
                    pagtingControl.currentPage = 1;
                    pageIndex = 1;
                }
            }
        }

        // 状态
        Rectangle {
            height: parent.height
            width: parent.width/7
            Text {
                id: staTxt
                height: parent.height
                width: 35*widthRate
                text:"状态:"
                font.bold: false
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                color: "#aaaaaa"
                verticalAlignment: Text.AlignVCenter
            }
            YMComboxControl {
                id: comboBoxStat
                height: parent.height
                width: 75*widthRate
                anchors.left: staTxt.right
                model: ["全部状态","预课","上课中","休息","下课","掉线","已结束","未上课"]
                onCurrentTextChanged: {
                    pagtingControl.currentPage = 1;
                    pageIndex = 1;
                }
            }
        }

        // 教室ID
        Rectangle {
            height: parent.height
            width: parent.width/7
            Text {
                id: schIDTxt
                height: parent.height
                width: 35*widthRate
                text:"教室ID:"
                font.bold: false
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                color: "#aaaaaa"
                verticalAlignment: Text.AlignVCenter
            }
            YMComboxControl {
                id: comboBoxSchID
                height: parent.height
                width: 75*widthRate
                anchors.left: schIDTxt.right
                anchors.leftMargin: 5*widthRate
                model: classIdModel
                onCurrentTextChanged: {
                    pagtingControl.currentPage = 1;
                    pageIndex = 1;
                 }
            }
        }
        // 查询按钮
        Rectangle {
            width: parent.width/14
            height: parent.height
            border.color: "#d3d8dc"
            border.width: 1
            Text {
                id:clearTimeText
                text: "查询"
                anchors.centerIn: parent
                font.bold: false
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                verticalAlignment: Text.AlignVCenter
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    queryData();
                    teachListView.visible = true
                    pagtingControl.visible = true
                }
            }
        }
    }

    // 课程列表标题
    Rectangle {
        id: listviewTitle
        width: parent.width - 40 * widthRate
        height: 30 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 30 * heightRate
        anchors.top: filterItem.bottom
        anchors.topMargin: 20 * heightRate
        color: "#e3e6e9"
        // 课程ID
        Item {
            id: classIDTitle
            anchors.left: listviewTitle.left
            width: listviewTitle.width*3/20
            height: listviewTitle.height
            Text {
                anchors.fill: parent
                font.bold: false
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("教室ID")
                color: "#333333"
                verticalAlignment: Text.AlignVCenter
            }
        }
        // 课程名称
        Item {
            id: subjectTitle
            width: listviewTitle.width/5
            height: listviewTitle.height
            anchors.left: classIDTitle.right
            Text {
                anchors.fill: parent
                font.bold: false
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("课节名称")
                color: "#333333"
                verticalAlignment: Text.AlignVCenter
            }
        }
        // 老师姓名
        Item {
            id: teaNameTitle
            width: listviewTitle.width/10
            height: listviewTitle.height
            anchors.left: subjectTitle.right
            Text {
                anchors.fill: parent
                font.bold: false
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("老师姓名")
                color: "#333333"
                verticalAlignment: Text.AlignVCenter
            }
        }
        // 开始时间
        Item {
            id: startTimeTitle
            width: listviewTitle.width/5
            height: listviewTitle.height
            anchors.left: teaNameTitle.right
            Text {
                anchors.fill: parent
                font.bold: false
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("开始时间")
                color: "#333333"
                verticalAlignment: Text.AlignVCenter
            }
        }
        // 结束时间
        Item {
            id: endTimeTitle
            width: listviewTitle.width/5
            height: listviewTitle.height
            anchors.left: startTimeTitle.right
            Text {
                anchors.fill: parent
                font.bold: false
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("结束时间")
                color: "#333333"
                verticalAlignment: Text.AlignVCenter
            }
        }
        // 状态
        Item {
            id: stateTitle
            width: listviewTitle.width*3/40
            height: listviewTitle.height
            anchors.left: endTimeTitle.right
            Text {
                anchors.fill: parent
                font.bold: false
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("状态")
                color: "#333333"
                verticalAlignment: Text.AlignVCenter
            }
        }
        // 操作
        Item {
            id: operateTitle
            width: listviewTitle.width*3/40
            height: listviewTitle.height
            anchors.left: stateTitle.right
            Text {
                anchors.fill: parent
                font.bold: false
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("操作")
                color: "#333333"
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // 加载状态
    YMLoadingStatuesView{
        id: loadingView
        z: 68
        anchors.fill: parent
    }

    // 课程列表
    ListView {
        id: teachListView
        clip: true
        width: parent.width - 40 * widthRate
        height: parent.height - 180 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 30 * heightRate
        anchors.top: listviewTitle.bottom
        model: teachModel
        delegate: teachDelegate
        visible: false
    }

    // 课程列表模型
    ListModel {
        id: teachModel
    }
    // 教师列表模型
    ListModel {
        id: teacherModel
    }
    // 学科列表模型
    ListModel {
        id: subjectModel
    }
    // 年级列表模型
    ListModel {
        id: gradeModel
    }
    //教室ID列表模型
    ListModel {
        id: classIdModel
    }

    //滚动条
    Item {
        id: scrollbar
        anchors.right: parent.right
        anchors.top: listviewTitle.bottom
        width:10 * widthRate
        height: parent.height
        z: 23
        visible: false
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

    // 提示无课程
    Image {
        id: backgImage
        width: 150 * heightRate
        height: 173 * heightRate
        anchors.centerIn: parent
        visible: false
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/pic_empty2x.jpg"
    }

    // 翻页框
    YMPagingControl{
        id: pagtingControl
        anchors.bottom: parent.bottom
        z: 67
        visible: false
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

    // 课程列表里面的内容
    Component{
        id: teachDelegate
        Item {
            width: teachListView.width
            height: 60 * heightRate // 列表行高度
            anchors.left: parent.left

            Item {
                id: listItem
                width: parent.width
                height: parent.height
                Row {
                    id: oneRow
                    width: parent.width
                    height: parent.height
                    // 教室ID
                    Text{
                        width: parent.width*3/20
                        height: parent.height
                        text: roomId
                        color: "#333333"
                        font.bold: false
                        font.family: Cfg.LESSON_LIST_FAMILY
                        font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    // 课节名称
                    Text{
                        width: parent.width/5
                        height: parent.height
                        text: chapterName
                        color: "#333333"
                        font.bold: false
                        font.family: Cfg.LESSON_LIST_FAMILY
                        font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    // 老师姓名
                    Text{
                        width: parent.width/10
                        height: parent.height
                        text: teacherName
                        color: "#333333"
                        font.bold: false
                        font.family: Cfg.LESSON_LIST_FAMILY
                        font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    // 开始时间
                    Text{
                        width: parent.width/5
                        height: parent.height
                        text: planStartTime
                        color: "#333333"
                        font.bold: false
                        font.family: Cfg.LESSON_LIST_FAMILY
                        font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    // 结束时间
                    Text{
                        width: parent.width/5
                        height: parent.height
                        text: planEndTime
                        color: "#333333"
                        font.bold: false
                        font.family: Cfg.LESSON_LIST_FAMILY
                        font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    // 状态
                    Text{
                        width: parent.width*3/40
                        height: parent.height
                        text: status            //lessonStatus
                        color: "#333333"
                        font.bold: false
                        font.family: Cfg.LESSON_LIST_FAMILY
                        font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    // 操作
                    MouseArea {
                        width: parent.width*3/40
                        height: parent.height
                        enabled: handleStatus == "查看回放" || handleStatus == "进入旁听" ? true : false
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor
                        Text{
                            text: handleStatus
                            color: handleStatus == "查看回放" ? "#338FFF"  : ((handleStatus == "进入旁听") ? "#FF5000" : "#666666")
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Cfg.LESSON_LIST_FAMILY
                            font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                        }
                        // 鼠标按下
                        onPressed: {
                            if(handleStatus == "进入旁听"){
                                classView.visible = true;
                                classView.tips = qsTr("正在进入旁听...")
                            }
                        }
                        // 鼠标释放
                        onReleased: {
                            if(handleStatus == "进入旁听"){
                                lessonMgr.getListenClassroom(executionPlanId);//进入教室
                            }else if(handleStatus == "查看回放"){
                                lessonMgr.getPlayback(executionPlanId);//查看录播
                            }
                        }
                    }
                }
                // 分割线
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#e3e6e9"
                    anchors.bottom: listItem.bottom
                }
            }
        }
    }

    // 课程列表内容加载完成
    Component.onCompleted: {}

    Connections {
        target: windowView
//        onSigListenTips: {
////            classView.visible = false;
////            lessonMgr.getCloudServer();
//            //lessonMgr.getListen(currentLessonId);
//        }
    }

    function refreshPage(){
        queryData();
    }

    // 以下三个ListModel用于存储name-id键值对
    ListModel {
        id: teaListModel;
    }
    ListModel {
        id: subListModel;
    }
    ListModel {
        id: gradListModel;
    }

    // 将时间戳转成标准时间格式
    function analysisDate(planTime){
        var currentDate = new Date(parseInt(planTime));
        var year = currentDate.getFullYear();
        var month = Cfg.addZero(currentDate.getMonth() + 1);
        var day = Cfg.addZero(currentDate.getDate());
        var hour = Cfg.addZero(currentDate.getHours());
        var minute = Cfg.addZero(currentDate.getMinutes());
        return year + "-" + month + "-" + day + " " + hour + ":" + minute;
    }
    // 分析旁听课程列表信息
    function analysisData(objectData){
        teachModel.clear();
        classIdModel.clear();
        classIdModel.append({"roomId": "全部教室"});
        networkItem.visible = false;
        backgImage.visible = false;
        if(objectData.data === {} || objectData.data === undefined){
            backgImage.visible = true;
            networkItem.visible = false;
            return;
        }

        if(objectData.data.list == null || objectData.data.list == undefined){
            backgImage.visible = true;
            networkItem.visible = false;
            return;
        }

        var dataList = objectData.data.list;
        for(var i = 0; i < dataList.length; i++){
            var dataListObj = dataList[i];
            // 课程状态
            var statusLesson = "";
            if(dataListObj.status === 0){
                statusLesson = "预课";
            }else if(dataListObj.status === 1){
                statusLesson = "已结束";
            }else if(dataListObj.status === 2){
                statusLesson = "上课中";
            }else if(dataListObj.status === 3){
                statusLesson = "休息";
            }else if(dataListObj.status === 4){
                statusLesson = "掉线";
            }else if(dataListObj.status === 5){
                statusLesson = "下课";
            }else if(dataListObj.status === 6){
                statusLesson = "未上课";
            }else{}
            //操作状态
            var statusOperate = "";
            if(dataListObj.handleStatus === 1){
                statusOperate = "进入旁听";
            }else if(dataListObj.handleStatus === 2){
                //statusOperate = "录播视频未生成";
                statusOperate = "回放生成中";
            }else if(dataListObj.handleStatus === 3){
                //statusOperate = "录播视频生成";
                statusOperate = "查看回放";
            }else if(dataListObj.handleStatus === 4){
                statusOperate = "待开课";
            }else if(dataListObj.handleStatus === 5){
                statusOperate = "已结课";
            }else{}
            teachModel.append({
                                  "executionPlanId": dataListObj.executionPlanId,  // 执行计划ID
                                  "status": statusLesson,    //状态，0:预课、2:上课中、3:休息、5:下课、4:掉线、1:已结束、6:未上课
                                  "handleStatus": statusOperate,    // 操作状态 1：进入教室  2：录播视频未生成 3：录播视频生成 4：待开课 5：已结课
                                  "roomId": dataListObj.roomId.toString(),    // 教室ID
                                  "chapterName": dataListObj.chapterName,  // 课节名称
                                  "teacherName": dataListObj.teacherName,  // 老师姓名
                                  "planStartTime": analysisDate(dataListObj.planStartTime),  // 开始时间
                                  "planEndTime": analysisDate(dataListObj.planEndTime)   // 结束时间
                              });
            classIdModel.append({"roomId": dataListObj.roomId.toString()});
            //console.log("{status:",dataListObj.status,"handleStatus:",dataListObj.handleStatus,"chapterName:",dataListObj.chapterName,"teacherName:",dataListObj.teacherName,"planStartTime:",analysisDate(dataListObj.planStartTime),"planEndTime:",analysisDate(dataListObj.planEndTime),"}");
         }
        totalPage = Math.ceil(objectData.data.total / pageSize);
        pagtingControl.totalPage = totalPage;
        backgImage.visible = teachModel.count == 0 ? true : false;
    }
    // 分析旁听-教师列表数据
    function analysisTeachersData(objectData){
        teacherModel.clear();
        teaListModel.clear();
        teacherModel.append({"name":"全部老师"});
        if(objectData.data === {} || objectData.data === undefined){
            console.log("######### analysisTeachersData return #######");
            return;
        }
        var dataTeachers = objectData.data;
        //console.log("====objectData.data===", JSON.stringify(objectData));
        for(var i = 0; i < dataTeachers.length; i++){
            var dataTeachersObj = dataTeachers[i];
            teacherModel.append({"name": dataTeachersObj.name});
            teaListModel.append({"name": dataTeachersObj.name,
                                 "id": dataTeachersObj.id});
        }
    }

    // 分析当前老师学科和年级
    function analysisGradeSubjectData(objectData){
        subjectModel.clear();
        gradeModel.clear();
        subListModel.clear();
        gradListModel.clear();
        subjectModel.append({"subjectName":"全部科目"});
        gradeModel.append({"gradeName":"全部年级"});
        if(objectData.data === {} || objectData.data === undefined){
            return;
        }
        var dataGrade = objectData.data;
        for(var i = 0; i < dataGrade.length; i++){
            var dataGradeObj = dataGrade[i];
            gradeModel.append({"gradeName":dataGradeObj.gradeName});
            gradListModel.append({"gradeName":dataGradeObj.gradeName,
                                  "gradeId":dataGradeObj.gradeId});
            var dataSubject = dataGradeObj.subjectDtoList;
            for(var j = 0; j < dataSubject.length; j++){
                var dataSubjectObj = dataSubject[j];
                subjectModel.append({"subjectName":dataSubjectObj.subjectName});
                subListModel.append({"subjectName":dataSubjectObj.subjectName,
                                     "subjectId":dataSubjectObj.subjectId});
            }
        }
    }
    // 查询数据
    function queryData(){
        loadingView.visible = true;
        // 状态
        var queryStatus = "";
        if(comboBoxStat.currentText.indexOf("预课") >= 0 ){
            queryStatus = "0";
        }else if(comboBoxStat.currentText.indexOf("已结束") >= 0){
            queryStatus = "1";
        }else if(comboBoxStat.currentText.indexOf("上课中") >= 0){
            queryStatus = "2";
        }else if(comboBoxStat.currentText.indexOf("休息") >= 0){
            queryStatus = "3";
        }else if(comboBoxStat.currentText.indexOf("掉线") >= 0){
            queryStatus = "4";
        }else if(comboBoxStat.currentText.indexOf("下课") >= 0){
            queryStatus = "5";
        }else if(comboBoxStat.currentText.indexOf("未上课") >= 0){
            queryStatus = "6";
        }else{
            queryStatus = "";
        }
        // 教师姓名
        var queryTeacher = comboBox.currentText;
        var queryTeacherId = "";
        for(var i = 0; i < teaListModel.count; i++){
            if(teaListModel.get(i).name === queryTeacher){
                queryTeacherId = teaListModel.get(i).id;
            }
        }
        // 学科
        var querySubject = comboBoxSub.currentText;
        var querySubjectId = "";
        for(var j = 0; j < subListModel.count; j++){
            if(subListModel.get(j).subjectName === querySubject){
                querySubjectId = subListModel.get(j).subjectId;
            }
        }
        // 年级
        var queryGrade = comboBoxGrad.currentText;
        var queryGradeId = "";
        for(var k = 0; k < gradListModel.count; k++){
            if(gradListModel.get(k).gradeName === queryGrade){
                queryGradeId = gradListModel.get(k).gradeId;
            }
        }
        // 教室ID
        var queryRoomId = "";
        if(comboBoxSchID.currentText != "全部教室"){
            queryRoomId = comboBoxSchID.currentText;
        }

        var seachPram = {
            "page": pageIndex == 0 ? 1 : pageIndex.toString(),
                                          "pageSize": pageSize,
                                          "status": queryStatus.toString(),    // 状态，0:预课、2:上课中、3:休息、5:下课、4:掉线、1:已结束、6:未上课
                                          "roomId": queryRoomId.toString(),
                                          "teacherIds": queryTeacherId.toString(),
                                          "gradeIds": queryGradeId.toString(),
                                          "subjectIds": querySubjectId.toString(),
                                          "roomId": queryRoomId.toString()
        };
        lessonMgr.getAttendLessonListInfo(seachPram);
    }
}
