import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import CurriculumData 1.0
import ExternalCallChanncel 1.0
import YMHomeWorkManagerAdapter 1.0
import "./Configuuration.js" as Cfg
import PanDuWriteBoard 1.0

Window {
    id: mainView
    visible: true
    width: Screen.width
    height: Screen.height + 1
    flags: Qt.Window | Qt.FramelessWindowHint
    title: "老师端教室"

    property int topMargins: leftWidthY - 6.0  * leftMidWidth  / 66
    property double leftMidWidths: leftMidWidth / 66.0;
    property bool isStartLesson: false;//是否开始上课
    property bool isLessonAssess: false;//是否结束课程评价
    property int isHomework: 2; //习题模式 1:练习模式 2：老课件模式 3：批改模式 4:浏览模式
    property int topicModel: -1;//1做题模式，2对答案模式
    property string currentQuestionId: "";//当前题目Id
    property bool isMultiTopic: false;//当前题目是否有多题
    property bool isMenuMultiTopic: true;//栏目是否有多题
    property string planId: "";//当前讲义Id
    property var currentPlanInfo: [];//当前选择的讲义信息
    property string columnId: "";//当前栏目Id
    property string orderNumber: "";//题号
    property int columnType: 0;//栏目类型 0：知识类型，1：题目类型 2：试题练习
    property bool isDisplayerAnswerCorrec: false;//是否显示答案解析和批改
    property var bufferColumnArray: [];//点击栏目缓存
    property int planTypes: -1;//讲义类型
    property var lessonCommentConfigInfo: [];//课程评价配置信息
    property string teacherType: trailBoardBackground.getTeacherStatus(); //teacherType的值, T是持麦者, L是旁听, 教室中, 上麦逻辑切换的过程中, 记录当前的身份是: 持麦者, 还是旁听
    property bool isListenModel: false;//是否是旁听模式
    property string isCurrentTeacherType: trailBoardBackground.getTeacherStatus();//旁听进入程序的时候用一次, 进入教室, 从temp.ini文件中, 获取的plat的值, 教室内, 上麦逻辑切换的时候, 这个值, 不会改变
    property string isChangeTeacherType: isCurrentTeacherType;
    property int homeworkClipImgType: -1;//课后作业截图的类型 -1 不是截图  0 单题截图  1 综合题截图
    property bool init_listen: false;//初始化旁听状态

    property var currentLessonTime: ;//当前上课时间

    //课程类型
    //===========================
    //lessonType 0,1    试听课
    //lessonType 10     订单课
    //subjectId  0      演示课
    //课程类型
    property var  lessonType: -1
    property var  subjectId: -1
    //判断是否是标准试听课, //0不是标准试听课，1是
    property var  applicationType: 0;

    //===========================
    //根据旁听状态和视频初始化来判断是否进入旁听模式
    onIsListenModelChanged: {
        console.log("=====onIsListenModelChanged=====",isListenModel,init_listen,isChangeTeacherType)
        if(isListenModel && init_listen && isChangeTeacherType == "L"){
            teacherType = "L";
            joinMicrophoneView.visible = true;
            videoToolBackground.initChancel();
            externalCallChanncel.closeVideo("0");
            externalCallChanncel.closeAudio("0");
        }
    }

    //做题缓存
    ListModel{
        id: questionBufferModel
    }

    //课件列表model
    ListModel
    {
        id:coursewareListViewModel
    }

    //音视频课件列表
    ListModel{
        id: audioModel
    }

    //开始上课同步数据
    property var synchronizePlanId: 0;//讲义Id
    property var synchronizeItemId: 0;//栏目Id
    property var synCurrentPlanId: 0;////同步的题目讲义Id
    property var synCurrentColumnId: 0;////同步的题目栏目Id
    property var synchronizeQuestionId: 0;//同步的题目Id
    property bool isSynLesson: false;//同步完成
    property bool isStartTopice: false;//是否开始练题
    property bool isStartQuestionStatus: true;//开始做题按钮状态
    property bool isBlanckPage: true;//当前是否是空白页
    property bool isCommitAnswer: false;//是否提交答案
    property var currentCommitParm: [];//批改缓存参数
    property bool isOpenCorrect: false;

    //批改属性定义
    property string childQuestionId: "";//小题Id
    property double currentScore: 0;//得分
    property int correctType: -1;//批改类型
    property string correctChildQuestionId: "";//批改题目子Id
    property string errorReason: "";//错因
    property int errorId: 0;//错因Id

    //批改、答案解析状态
    property bool answerStatus: false;
    property bool correctStatus: false;

    //学生端app是旧版本
    property bool stuApp_IsOldVer: false;

    //是否可以使用新比例的画板
    property bool couldUseNewBoard: true;

    //老师端"答案解析"的开关
    property bool bAnswer_Parse_OnOff: false;

    //****

    //当前是不是旁听
    property bool currentIsAttend: false;

    //当前的 角色类型 1 老师 2 cc 3 cr 4 stu(退出教室时用)
    property int currentListenRoleType: 1;

    //是否填写过试听课报告
    property bool hasFinishListenReport: false;

    //CC/CCM/CC协助是否关闭过试听课报告
    property bool isCloseReport: false;

    //当前的课程是不是标准试听课
    property bool currentIsAuditionLesson: false;

    property var endLessonH5Url ;//结束课程时填写试听课报告的Url

    property bool isStudentEndLesson: false;//是不是学生发起的结束课程


    //是否已生成课堂报告
    property bool hasExistListenReport: false;

    //课后作业和课堂报告导入是否可用 版本兼容 使用
    property bool canImportReportImgs: true;

    //当前题目截图的方式 区分课堂作业截图和题目截图
    property bool currentIsHomeWorkClipImg: false;

    //TipShowH5ReportView
    //{//测试用
    //    id:writeH5Report
    //    anchors.fill: parent
    //    z:1000
    //    visible: true
    //}

    onIsBlanckPageChanged: {
        console.log("********onIsBlanckPageChanged*************",isBlanckPage)
        if(isBlanckPage){
            exercisePage.isVisibleStartButton = false;
        }
    }

    onIsHomeworkChanged: {
        console.log("======onIsHomeworkChanged=========",isHomework)
        if(isHomework == 2){
            exercisePage.visible = false;
            cloudMenu.visible = false;
            if(!fullScreenType)
            {
                bottomToolbars.visible = true;
            }
        }
        if(isHomework == 1 && !fullScreenType){
            cloudMenu.visible = true;
        }
    }

    Component.onCompleted: {
        currentIsAuditionLesson = curriculumData.getIsStandardLesson();
        hasExistListenReport = curriculumData.getLessonReportStatus();
        currentListenRoleType = curriculumData.getCurrentRoleType();
        currentIsAttend = curriculumData.getCurrentIsAttend();
        isCloseReport = curriculumData.getIsReportStatus()
        console.log("====isCloseReport====",isCloseReport);

        if(hasExistListenReport)//试听课报告已生成的话 表明已经填写过试听课报告了
        {
            hasFinishListenReport = true;
        }

        var currentNetStatus = trailBoardBackground.getNetworkStatus();
        videoToolBackground.networkStatus = currentNetStatus;
        videoToolBackground.updateNetworkStatus(3);
        videoToolBackground.getLessonCommentConfigInfo();
        videoToolBackground.getStudentHomeWorkData();
        //teacherType = trailBoardBackground.getTeacherStatus();
        console.log("=====teacherType===",teacherType,isListenModel);
        trailBoardBackground.getCurrentCourse();

    }

    onTeacherTypeChanged: {
        console.log("=====onTeacherTypeChanged====",teacherType);
        if(teacherType == "T"){
            toobarWidget.disableButton = true;
            bottomToolbars.disabledButton = true;
            videoToolBackground.disabledButton = true;
            exercisePage.disabledButton = true;
            joinMicrophoneView.visible = false;
        }else{
            exercisePage.disabledButton = false;
            bottomToolbars.disabledButton = false;
            toobarWidget.disableButton = false;
            videoToolBackground.disabledButton = false;
            trailBoardBackground.isHandl = false;
        }
    }

    //列改变
    onColumnTypeChanged: {
        if(columnType == 1 || columnType == 0){
            console.log("**********isStartQuestionStatus*************",columnType, isStartQuestionStatus);
            updateStartButtonStatus(false);
            exercisePage.isVisibleStartButton = false; //选中: "知识梳理", "基础例题"的时候, 不显示"开始练习"按钮, 修复对应的jira BUG-399
        }
    }

    //关闭窗体
    onClosing: {
        trailBoardBackground.disconnectSockets();
        externalCallChanncel.closeAlllWidget();
    }

    //视频播放缓存
    property var videoPlayerBuffer: [];
    property var audioPlayerBuffer: [];
    //屏幕比例
    property double widthRate: Screen.width * 0.8 / 966.0;
    property double heightRate:widthRate / 1.5337;

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;

    //全屏类型
    property bool   fullScreenType: false

    //学生类型
    property  string  studentType: curriculumData.getCurrentUserType()

    //边框阴影
    property int borderShapeLen : (rightWidthX - midWidth - midWidthX) > 10 ? 10 : (rightWidthX - midWidth - midWidthX)

    //设置全屏
    function setFullScrreen(types){
        //console.log("=====types::types=====",types)
        if(types) {
            trailBoardBackground.width = fullWidth;
            //trailBoardBackground.height = fullHeight;
            trailBoardBackground.anchors.leftMargin = fullWidthX - 5  * heightRates;

            var tempHeight = titelImg.visible ? titelImg.height : fullHeightY;
            trailBoardBackground.anchors.topMargin = tempHeight;

            if(!couldUseNewBoard)
            {
                trailBoardBackground.anchors.topMargin = (mainView.height - trailBoardBackground.height) / 2
            }

            exercisePage.visible = false;
            bottomToolbars.visible = false;

            if(isHomework)
            {
                cloudMenu.visible = false;
            }

        }else{
            trailBoardBackground.width = midWidth;
            //trailBoardBackground.height = midHeight;

            var tempHeights = titelImg.visible ? midHeightYs : midHeightY;

            trailBoardBackground.anchors.leftMargin = midWidthX - 15  * heightRates;
            trailBoardBackground.anchors.topMargin = tempHeights;

            if(!couldUseNewBoard)
            {
                trailBoardBackground.anchors.topMargin = (mainView.height - trailBoardBackground.height) / 2
            }
            exercisePage.visible = true;
            bottomToolbars.visible = true;

            if(isHomework)
            {
                cloudMenu.visible = true;
            }
        }
        trailBoardBackground.setBackgrundImage();
        trailBoardBackground.jumpToPage(bottomToolbars.currentPage - 1);
    }

    //状态灯model
    ListModel {
        id:showMemberStatusViewModel
    }

    //手写板
    PanDuWriteBoard
    {
        id:panDuWriteBoard

        onConnectWriteBoardStatus:
        {
            console.log("==onConnectWriteBoardStatus==",codes);
            //断开链接 拔掉了
            if(codes == 3)
            {
                showMessageTips("溢米手写板连接断开");
                //cloudTipView.setBreakWriteBoard();
                // 提示内容： 溢米手写板连接断开
            }
        }

        onWriteBoardClick:
        {
            //手写板单击, 下一页, 翻页
            console.log("onConnectWriteBoardStatus click");
            bottomToolbars.updateNextPage();
        }

        onWriteBoardDoubleClick:
        {
            //手写板双击, 上一页, 翻页
            console.log("onConnectWriteBoardStatus double click");
            bottomToolbars.updatePrePage();
        }
    }

    MouseArea{
        id: newCourse
        anchors.fill: parent
        visible: isShowNewCourseTips
        z: 6666
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        property int clickTimes: 0;
        onClicked:
        {
            if(applicationType != 1)
            {
                visible = false;
            }

            ++ newCourse.clickTimes;
            if(2 == newCourse.clickTimes)
            {
                visible = false;
            }
        }

        Rectangle{
            color: "#c0c0c0"
            opacity: 0.6
            anchors.fill: parent
        }

        Image {
            id: commonCourseImg
            height: 350 * widthRates * 0.5;
            width: 1436 * widthRates * 0.5;
            visible: (newCourse.clickTimes == 0) && (applicationType != 1)
            anchors.top:parent.top
            anchors.topMargin: 20 * heightRates
            anchors.right: parent.right
            anchors.rightMargin: 7 * widthRates
            //anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/auditionLessonImage/th_popwindow_guide_new.png"
        }

        Image {
            id: courseImg
            height: 350 * widthRates * 0.5;
            width: 1436 * widthRates * 0.5;
            visible: (newCourse.clickTimes == 0) && (applicationType == 1)
            anchors.top:parent.top
            anchors.topMargin: 20 * heightRates
            anchors.right: parent.right
            anchors.rightMargin: 7 * widthRates
            //anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/auditionLessonImage/th_popwindow_guide.png"
        }

        Image {
            id: joinMicImg
            height: 508 * widthRates * 0.5;
            width: 1162 * widthRates * 0.5;
            visible: (newCourse.clickTimes == 1) && (applicationType == 1)
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 10 * heightRates
            anchors.right: parent.right
            anchors.rightMargin: 180 * widthRates
            //anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/auditionLessonImage/th_guide_macrioon@2x.png"
        }
    }

    //加载长图等待动画
    MouseArea{
        id: loadingAnimate
        anchors.fill: parent
        visible: false
        z: 6666
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle{
            color:loadingText.text.indexOf(qsTr("学生正在提交练习")) != -1 ? "transparent" : "#c0c0c0"
            opacity: 0.6
            anchors.fill: parent
        }

        Image {
            width: 317 * heightRate * 0.8
            height: 70 * heightRate * 0.8
            anchors.centerIn: parent
            source: "qrc:/newStyleImg/popwindow_loading@2x.png"
            visible: loadingText.text.indexOf(qsTr("学生正在提交练习")) != -1
        }
        AnimatedImage {
            id: animateImg
            width: 20 * heightRate
            height: 20 * heightRate
            source: "qrc:/images/loading.gif"
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.5 - width * 5
            anchors.verticalCenter: parent.verticalCenter
        }

        Text{
            id: loadingText
            anchors.left: animateImg.right
            anchors.leftMargin: 10 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 13 * heightRate
            font.family: Cfg.font_family
            color: loadingText.text.indexOf(qsTr("学生正在提交练习")) != -1 ? "black" : "gray"

        }

        onVisibleChanged: {
            if(!currentIsAuditionLesson)
            {
                return;
            }

            if(visible){
                bottomToolbars.disabledButton = false;
            }else{
                bottomToolbars.disabledButton = teacherType == "T" ? true : false;
            }
        }

        onClicked: {
            console.log("====check::noChange====");
        }
    }

    //全屏时显示logo
    Image{
        z: 1
        width: 60 * heightRate
        height: 72  * heightRate
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 10 * widthRate
        anchors.topMargin: 20 * heightRate
        source: "qrc:/images/fullLogo.png"
        visible: fullScreenType ? true : false
    }

    //背景颜色
    Rectangle{
        anchors.fill: parent
        color:  "#f7f7f7"//"#eeeeee"

        //全屏显示Logo

        //课程讲义主菜单
        CloudRoomMeun{
            id: cloudMenu
            z: 5
            visible: (isHomework  == 2 || fullScreenType) ? false : true
            width: 220 * widthRate
            height: 70 * heightRate
            disableButton: !exercisePage.isStartMake && teacherType =="T" ? true : false
            anchors.top: parent.top
            //anchors.left: parent.left
            //anchors.leftMargin: (parent.width - rightWidth  - width + 70 * widthRates) * 0.5
            x:trailBoardBackground.x + trailBoardBackground.width / 2 - width / 2

            onSigShowItemNamesInMainView:
            {
                midTipTexts.text = itemName;
            }

            onSigLoadingSuccess: {
                console.log("**********mainView::updateSelected************",synchronizePlanId,synchronizeItemId,isSynLesson)
                for(var i = bufferColumnArray.length -1; i > 0 ; i --){
                    if(bufferColumnArray[i].planId == synchronizePlanId){
                        synchronizeItemId = bufferColumnArray[i].columnId;
                        console.log("****************",bufferColumnArray[i].planId,synchronizeItemId);
                        break;
                    }
                }

                if(isSynLesson){
                    cloudMenu.updateSelected(synchronizePlanId,synchronizeItemId);
                }
            }
            //根据栏目id 课件id 获取课件的数据信息
            onSigExplainMode: {
                console.log("====onSigExplainMode====", planId,itemId, lessonId, questionId,itemType, exercisePage.isVisibleStartButton)
                currentQuestionId = questionId;
                mainView.planId = planId;
                mainView.columnId = itemId;
                mainView.columnType = itemType;

                if(isSynLesson == false){
                    return;
                }
                bufferColumnArray.push(
                            {
                                "planId": planId,
                                "columnId": itemId,
                            });
                isHomework = 3;
                var docId =mainView.planId + "|" +mainView.columnId;
                var currentPage = trailBoardBackground.getCoursePage(docId);
                var pages = currentPage == 0 ? 1 : currentPage;
                console.log("*********pages************",pages,docId,currentPage);
                trailBoardBackground.selectedMenuCommand(pages,mainView.planId,mainView.columnId);
                trailBoardBackground.jumpToPage(pages); //课堂讲义, 切换的时候, 不用发送goto命令
                //videoToolBackground.changeItem(planId,itemId);
            }
        }

        CoursewareThumbnailView
        {
            id:coursewareThumbnailView
            anchors.fill: parent
            z:5
            x:trailBoardBackground.x
            y:150
            visible: false
            currentColumnText: midTipTexts.text

            onSigJumpPage:
            {
                bottomToolbars.currentPage = indexs;
                trailBoardBackground.jumpToPage(indexs);
            }

        }

        Rectangle{
            id: homeworkItem
            visible: isHomework != 2 ? true : false
            width: trailBoardBackground.width
            height: trailBoardBackground.height
            x:trailBoardBackground.x
            y:trailBoardBackground.y

            //5大题型：单选、判断、多选、简答、填空
            ShowQuestionHandlerView{
                id: showQuestionHandlerView

                anchors.fill: parent
                isCompleStatus: false

                onSigCurrentClipImagePath:
                {
                    console.log("=======onSigCurrentClipImagePath========")
                    if(homeworkClipImgType == 1)
                    {
                        topicBrowsView.visible = false;
                    }
                    isHomework = 3;
                    showQuestionHandlerView.visible = false;

                    auditionLessonCoursewareView.bufferHomeWorkClipImg(imageUrl, imgWidth, imgHeight);
                }

                onSigShowCorrectPage: {
                    console.log("======ShowQuestionHandlerView::onSigShowCorrectPage==========",isHomework,isMenuMultiTopic,filePath,status)

                    showQuestionHandlerView.visible = false;
                    compositeTopicView.visible = false;
                    topicBrowsView.visible = false;
                    if(status == 0){
                        showQuestionHandlerView.visible = true;
                    }

                    var filePaths = "";
                    if(status == 5){
                        showQuestionHandlerView.visible = true;
                        return;
                    }

                    if(status == 1){
                        isHomework = 3;
                        //filePaths = "file:///" + filePath;
                        var fileName = "";//filePath.substring(filePath.lastIndexOf("/")+1,filePath.length);
                        trailBoardBackground.uploadWorkImage(mainView.planId,
                                                             mainView.columnId,
                                                             mainView.currentQuestionId,
                                                             fileName,
                                                             filePath,
                                                             imgWidth,
                                                             imgHeight);
                        console.log("======imgHeight======",imgWidth,imgHeight)
                        //trailBoardBackground.lodingPlanImage(filePaths,imgWidth,imgHeight);
                        exercisePage.disabledButton = true;

                        if(modifyHomework.isErrorList() == 0){
                            videoToolBackground.getErrorList(mainView.planId);
                        }
                        return;
                    }
                    if(status == 2 || status == 4){
                        filePaths = filePath;
                        isHomework = 3;
                        if(teacherType == "T"){
                            cloudMenu.disableButton = true;
                        }else{
                            cloudMenu.disableButton = false;
                        }

                        trailBoardBackground.lodingPlanImage(filePaths,imgWidth,imgHeight);
                    }
                    console.log("=======status==111111========",status);
                }
            }

            //综合题
            CloudCompositeTopicView{
                id: compositeTopicView
                visible: isHomework != 2 ? true : false
                anchors.fill: parent
                onSigIsMultipleTopic: {
                    exercisePage.isVisiblePage = true;
                    isMultiTopic = childStatus;
                    //console.log("=======CloudCompositeTopicView========",childStatus);
                }
                onSigScrollImage:{
                    trailBoardBackground.scrollImage(contentY);
                }

                onSigJumpTopic: {
                    console.log("====jump====",jump);
                    var page = 0;
                    if(jump == "next"){
                        page = exercisePage.currentPage;
                    }else{
                        page =  exercisePage.currentPage - 1;
                    }
                    trailBoardBackground.jumpToPage(page);
                }

                onSigCorrectInfos: {
                    console.log("*******CloudCompositeTopicView::onSigCorrectInfos********",questionId,childQuestionId,score,correctType,errorReason);
                    mainView.currentQuestionId = questionId;
                    mainView.currentScore = score;
                    mainView.correctType = correctType;
                    mainView.errorReason = errorReason;
                }

                onSigCorrect:{
                    showQuestionHandlerView.visible = false;
                    compositeTopicView.visible = true;
                    topicBrowsView.visible = false;
                    console.log("======compositeTopicView::=======",isMenuMultiTopic,filePath,status,imgWidth,imgHeight);

                    var filePaths = "";
                    if(status == 1){
                        isHomework = 3;
                        //filePaths = "file:///" + filePath;
                        var fileName = "";//filePath.substring(filePath.lastIndexOf("/")+1,filePath.length);
                        trailBoardBackground.uploadWorkImage(mainView.planId,
                                                             mainView.columnId,
                                                             mainView.currentQuestionId,
                                                             fileName,
                                                             filePath,
                                                             imgWidth,
                                                             imgHeight);
                        //trailBoardBackground.lodingPlanImage(filePaths,imgWidth,imgHeight);
                        cloudMenu.disableButton = true;
                        if(modifyHomework.isErrorList() == 0){
                            videoToolBackground.getErrorList(mainView.planId);
                        }
                        return;
                    }

                    if(status == 2 || status == 4){
                        isHomework = 3;
                        filePaths = filePath;
                        trailBoardBackground.lodingPlanImage(filePaths,imgWidth,imgHeight);

                        if(teacherType == "T"){
                            cloudMenu.disableButton = true;
                        }else{
                            cloudMenu.disableButton = false;
                        }

                        //trailBoardBackground.imagePath = filePaths;
                    }
                }
            }

            //综合题预览模式
            CloudTopicBrowsView{
                id: topicBrowsView
                visible: isHomework == 1 || isHomework == 3 ? true : false
                anchors.fill: parent

                onSigLoadingSuccess: {
                    console.log("====CloudTopicBrowsView=======");
                    showQuestionHandlerView.visible = false;
                    compositeTopicView.visible = false;
                    topicBrowsView.visible = false;
                    isHomework = 3;
                    //课后作业截图
                    if(auditionLessonCoursewareView.currentSelectIndex == 3){
                        showQuestionHandlerView.clipImage(topicBrowsView.clipBrowsViewImage());
                    }else{
                        trailBoardBackground.uploadWorkImage(mainView.planId,mainView.columnId,mainView.currentQuestionId,"","",0,0);
                    }
                }
            }

            //开始练习、停止练习弹窗
            TipExerciseView{
                id: tipExercise
                z: 2
                visible: false
                anchors.fill: parent
                onSigStartExercise: {
                    tipExercise.visible = false;
                    toobarWidget.disableButton = false;
                    exercisePage.isVisiblePage = false;
                    addQuestionDo(mainView.planId,mainView.columnId ,mainView.currentQuestionId ,0);
                    trailBoardBackground.startExercise(mainView.currentQuestionId,mainView.planId,mainView.columnId);
                }
            }
            //停止练习弹窗
            TipStopPracticeView{
                id: tipStopExercise
                z: 2
                visible: false
                anchors.fill: parent
                onSigStopExercise: {
                    if(status){
                        toobarWidget.disableButton = true;
                        exercisePage.isVisiblePage = true;
                        exercisePage.disabledButton = false;//结束练习无法操作翻页
                        trailBoardBackground.stopQuestion(mainView.currentQuestionId);
                    }else{
                        exercisePage.isStartMake = true;
                        exercisePage.visible = true;
                    }
                }
            }
        }

        //开始练习栏
        CloudExercisePageView{
            id: exercisePage
            z: 2
            width: midWidth//240 * widthRate
            height: 35  * widthRate
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: (parent.width + (leftMidWidth + 12.0 * leftMidWidth / 66) - (rightWidth + borderShapeLen) -width) * 0.5
            anchors.bottomMargin:  5  * fullHeights / 900
            onSigStartExercise: {
                console.log("========onSigStartExercise========",status);
                if(status){
                    if(videoToolBackground.getIsOneStartLesson()){
                        tipExercise.visible = true;
                        return;
                    }
                    toobarWidget.disableButton = false;
                    exercisePage.isVisiblePage = false;
                    addQuestionDo(mainView.planId,mainView.columnId ,mainView.currentQuestionId ,0);
                    trailBoardBackground.startExercise(mainView.currentQuestionId,mainView.planId,mainView.columnId);
                }else{
                    tipStopExercise.visible = true;
                    exercisePage.visible = false;
                    addQuestionDo(mainView.planId,mainView.columnId ,mainView.currentQuestionId ,0);
                }
            }
            //上一题、下一题信号
            onSigPage: {
                console.log("======CloudExercisePageView========",status,isMultiTopic,isHomework,pages);
                if(status == "pre"){//上一题
                    trailBoardBackground.jumpToPage(pages);
                    return;
                }
                if(status == "next"){//下一题
                    if(isMultiTopic){
                        compositeTopicView.updateTopicBody(status);
                    }else{
                        trailBoardBackground.jumpToPage(pages);
                    }
                    return;
                }
            }
            //跳转某一题
            onSigJumpPage: {
                trailBoardBackground.jumpToPage(pages);
            }
            //第一与最后一页提醒
            onSigTipPage:{
                if(message == "lastPage"){
                    showMessageTips("已经到最后一页了!");
                }
                if(message == "onePage"){
                    showMessageTips("已经到第一页了!");
                }
            }
            //分页权限收回
            onSigRecoverPage: {
                trailBoardBackground.setRecoverPage();
            }
        }

        //批改页面
        CloudModifyHomeworkView{
            id: modifyHomework
            z: 3
            x: rightWidthX - borderShapeLen - width - 15 * heightRate
            y: homeworkItem.y
            height: homeworkItem.height
            onClosed: {
                isOpenCorrect = false;
                trailBoardBackground.closeCorrect(mainView.planId,mainView.columnId,mainView.currentQuestionId);
            }
            //提交批改信号
            onSigCommitTopic: {
                videoToolBackground.saveTeacherComment(mainView.planId,columnId,commitParm);
            }
            //提交批改命令
            onSigCommitTopicComand: {
                console.log("=====onSigCommitTopicComand=======",questionId,childQuestionId)
                mainView.errorReason = errorReason;
                mainView.correctType = correctType;
                mainView.currentScore = score;
                mainView.correctChildQuestionId = childQuestionId;
                mainView.errorId = errorTypeId;
            }
            onSigLoadingFinish: {
                console.log("ssssssssssssssssssss")
                if(isOpenCorrect){
                    modifyHomework.open();
                }
            }
        }

        //答案解析
        KnowledgesView{
            id: knowledgesView
            z: 3
            x: rightWidthX - borderShapeLen - 15 * heightRate - width
            y: homeworkItem.y
            height: homeworkItem.height
            onClosed: {
                //老师关闭"答案解析"窗口的时候, 同时也置开关为"关"的状态
                bAnswer_Parse_OnOff = false
                trailBoardBackground.closeAnswerParsing(planId,columnId,currentQuestionId);

                answerStatus = false
                //console.log("========answerStatus========", answerStatus)
            }

            onSigOpenAnserParsing: {
                //trailBoardBackground.openAnswerParsing(mainView.planId,questionId,mainView.columnId,childQuestionId);
            }
        }

        //消息提示框
        Rectangle{
            id:toopBracund
            color: "#3C3C3E"
            opacity: 0.6
            width: 400 * trailBoardBackground.widthRates
            height: 40 * trailBoardBackground.heightRates
            z:  20
            anchors.left: trailBoardBackground.left
            anchors.bottom: trailBoardBackground.bottom
            anchors.leftMargin:  (trailBoardBackground.width - width) * 0.5  //2 - 150 * trailBoardBackground.widthRates
            anchors.bottomMargin: 100 * trailBoardBackground.heightRates
            visible: false
            radius: 5 * trailBoardBackground.heightRates
            onVisibleChanged: {
                toopBracundTimer.stop();
                if(visible){
                    toopBracundTimer.start();
                }
            }

            Timer {
                id:toopBracundTimer
                interval: 3000;
                running: false;
                repeat: false
                onTriggered: {
                    toopBracund.visible = false;
                }
            }
            Image {
                id: toopBracundImage
                anchors.top: parent.top
                anchors.left: parent.left
                width: 20 * trailBoardBackground.ratesRates
                height: 20 * trailBoardBackground.ratesRates
                anchors.leftMargin: 20 * trailBoardBackground.heightRates
                anchors.topMargin:   20 * trailBoardBackground.heightRates  - 10 * trailBoardBackground.ratesRates
                source: "qrc:/images/progessbar_logo.png"
            }
            Text {
                id: toopBracundImageText
                width: 350 * trailBoardBackground.ratesRates
                height: 20 * trailBoardBackground.ratesRates
                anchors.left: toopBracundImage.right
                anchors.top: toopBracundImage.top
                font.pixelSize: 14 * trailBoardBackground.ratesRates
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode:Text.WordWrap
                font.family: "Microsoft YaHei"
                color: "#ffffff"
                text: qsTr("")
            }
        }

        TipVersionMessageView{
            id: versionPlanView
            width: 300 * trailBoardBackground.widthRates
            height: 200 * trailBoardBackground.heightRates
            anchors.centerIn: parent
            visible: false
            z: 5
        }

        //上麦弹窗
        TipJoinMicrophoneView{
            id: joinMicrophoneView
            z: 1
            anchors.left: parent.left
            anchors.leftMargin: midWidth + midWidthX - width + 10 * heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -(12 * heightRate)
            visible: currentIsAuditionLesson ? ( teacherType == "T" ? false : true ) : false
            disableButton: true//isStartLesson
            onSigJoinMicrophone: {
                //joinMicrophoneView.visible = false;
                popupWidget.setPopupWidget("joinMicrophone");
            }
        }

        Image {
            id: titelImg
            //source: "qrc:/images/pc_fixtitle_bg@2x.png"
            width: trailBoardBackground.width
            height:width / ( 1150 / 46 )
            anchors.bottom: trailBoardBackground.top
            anchors.left: parent.left
            anchors.leftMargin: fullScreenType ? fullWidthX - 5  * heightRates : midWidthX - 15 * heightRates
            visible: planTypes == 1 && couldUseNewBoard

            onWidthChanged:
            {
                console.log(" id: titelImg",width,height)
            }

            Rectangle
            {
                width: parent.width
                height:width / ( 1150 / 46 )
                color: "#FFFFFF"
                anchors.bottom: parent.bottom
                Rectangle
                {
                    width: parent.width
                    height: 1
                    color: "#EAEAEA"
                    anchors.bottom: parent.bottom
                }
            }

            Text {
                anchors.right: midTipTexts.left
                anchors.rightMargin: 20 * heightRates
                text: qsTr("——")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 21 * heightRate
                color: "#CECECE"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: midTipTexts
                anchors.centerIn: parent
                text: qsTr("知识梳理")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 20 * heightRate
                color: "#737373"
            }

            Text {
                anchors.left: midTipTexts.right
                anchors.leftMargin: 20 * heightRates
                text: qsTr("——")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 21 * heightRate
                color: "#CECECE"
                anchors.verticalCenter: parent.verticalCenter
            }

            onVisibleChanged:
            {

                if(trailBoardBackground.width == midWidth)
                {
                    trailBoardBackground.anchors.leftMargin = midWidthX - 15 * heightRates
                    trailBoardBackground.anchors.topMargin = titelImg.visible ? midHeightYs : midHeightY;
                    if(!couldUseNewBoard)
                    {
                        trailBoardBackground.anchors.topMargin = (mainView.height - trailBoardBackground.height) / 2
                    }

                }else
                {

                }
            }
        }

        //报告已生成Tips
        Rectangle{
            id: reportTips
            z: 13
            visible: hasExistListenReport && isCloseReport
            width: 135 * widthRate
            height: 25 * heightRate
            anchors.top: parent.top
            anchors.topMargin: titelImg.visible ? midHeightYs + 10 * heightRate : midHeightY + 10 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ff6666"
            radius: 4 * heightRate

            MouseArea{
                width: 15 * heightRate
                height: 15 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    reportTips.visible = false;
                    curriculumData.writeReport(videoToolBackground.courseNameId);
                }

                Rectangle{
                    anchors.fill: parent
                    radius: 100
                    opacity: 0.6
                }

                Text {
                    text: qsTr("×")
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                    color: "#FF6666"
                }
            }

            Text {
                color: "#ffffff"
                anchors.centerIn: parent
                font.family: Cfg.DEFAULT_FONT
                text: qsTr("试听课报告已生成~")
            }
        }

        CourseWareControlView
        {
            id:courseWareControlView
            width:trailBoardBackground.width
            height: trailBoardBackground.height
            //visible: isHomework  == 2 ||
            x:trailBoardBackground.x
            y:trailBoardBackground.y
            onSigImageLoadReadys:
            {
                trailBoardBackground.setButtonStatus();
            }
            onSigChangeScoreBarVisibles:
            {
                trailBoardBackground.changeScoreBarVisibles(visibles);
            }
        }

        //画布
        TrailBoardBackground{
            id:trailBoardBackground
            width: midWidth
            height: couldUseNewBoard ? midWidth * 9 / 16 : midWidth * 10 / 16 //midHeight
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: midWidthX - 15 * heightRates
            anchors.topMargin: titelImg.visible ? midHeightYs : midHeightY
            visible: isHomework == 3 || isHomework == 2  ? true : false

            Component.onCompleted:
            {
                setFullScrreen(false);
            }

            onSigShowAllCourseImgs:
            {
                coursewareThumbnailView.resetAllBeShowedCourseData(imgArray,contentArray,courseIds,bottomToolbars.currentPage);
                //coursewareThumbnailView.visible = true;
            }

            onSigCancleInsertHomeWorks:
            {
                auditionLessonCoursewareView.setCancleInsertHomework();
            }

            //课件抽离相关 begin
            onSigRemoveBmgUrls:
            {
                courseWareControlView.removeImgViewUrl();
            }
            onSigSetBmgUrls:
            {
                courseWareControlView.setBeShowedImg(urls,widths,heights);
            }
            onSigSetBmgVisibles:
            {
                courseWareControlView.setImgViewVisible(visibles);
            }

            onSigHideCourseView:
            {
                console.log("onSigHideCourseView",visibles)
                courseWareControlView.visible = visibles;
            }

            //课件抽离相关 end

            //切换为原来的通道
            onSigGetbackAisles:
            {
                externalCallChanncel.changeChanncel();
                if(teacherType == "L")
                {
                    externalCallChanncel.closeVideo("0");
                    externalCallChanncel.closeAudio("0");
                }
            }

            //显示对话框: "老师已退出, 学生停留在教室, 是否立即开始与学生沟通?"
            onSigListenMicophones: {
                popupWidget.setPopupWidget("showStartClassPage");
            }

            //隐藏对话框: "老师已退出, 学生停留在教室, 是否立即开始与学生沟通?"
            onSigDisapperListenMicophones: {
                //console.log("=========onSigDisapperListenMicophones=============");
                popupWidget.setPopupWidget("dispapperStartClassPage");
            }

            onSigOtherGetMicOrders:
            {
                console.log("onSigOtherGetMicOrders")
                trailBoardBackground.setTeacherType("L");
                joinMicrophoneView.visible = true;
                popupWidget.visible = false;
                bottomToolbars.disabledButton = false;
                toobarWidget.disableButton = false;
                trailBoardBackground.isHandl = false;
                exercisePage.disabledButton = false;
                videoToolBackground.disabledButton = false;
                cloudMenu.disableButton = false;
                mainView.teacherType = "L";
                currentIsAttend = true;
            }

            onSigReponseMicrophones: {//响应上麦
                if(status == 0){//拒绝 禁用操作工具栏
                    toobarWidget.disableButton = false;
                    bottomToolbars.disabledButton = false;
                    videoToolBackground.disabledButton = false;
                    exercisePage.disabledButton = false;
                    cloudMenu.disableButton = false;
                    currentIsAttend = true;
                }else{
                    currentIsAttend = false;
                    isStartLesson = true;
                    trailBoardBackground.setTeacherType("T");
                    teacherType = "T";
                    exercisePage.disabledButton = true;
                    bottomToolbars.disabledButton = true;
                    toobarWidget.disableButton = true;
                    videoToolBackground.disabledButton = true;
                    trailBoardBackground.isHandl = true;
                    cloudMenu.disableButton = true;
                    trailBoardBackground.setOperationVideoOrAudio("0","1","1");
                    trailBoardBackground.setStartClassRoom();
                    videoToolBackground.initChancel();
                }
                popupWidget.waitMicrophoneShow(status);
            }

            onSigRequestMicphone: {
                popupWidget.applyMicrophone(status,userId);
            }

            //发送离开教室的姓名跟类型
            onSendExitRoomName: {
                videoToolBackground.exitClassUserId = userId;
                popupWidget.setExitRoomName(types , cname);
                videoToolBackground.setStayInclassroom();
                isStartLesson = false;
                exercisePage.isVisiblePage = (mainView.isMenuMultiTopic  ? true : false);
            }

            onSigInterNetworks: {
                videoToolBackground.networkStatus = networkStatus;
            }

            onSigGetCoursewareFaills: {
                showMessageTips("讲义暂未生成,请您稍后再选择该讲义!");
                videoToolBackground.getCoursewareInfo();
            }

            onSigStudentAppVersioned: {
                if(canImportReportImg)
                {
                    canImportReportImgs = true;
                }else
                {
                    canImportReportImgs = false;
                }

                couldUseNewBoard = status;
                console.log("====onSigStudentAppVersioned=====",status);
                return;


                //1. 老师正在上新讲义的课, 学生旧版本进来, 老师这边, 需要显示提示信息
                //console.log("wuneng 22222=================", mainView.planTypes, mainView.stuApp_IsOldVer);
                if(status == false)
                {
                    stuApp_IsOldVer = true;
                    //console.log("wuneng 33333=================");
                    if(mainView.planTypes == 1)
                    {
                        versionPlanView.visible = true;
                    }
                    detectionNetwork.resetAisleModelForCAisle(true);
                }
                else
                {
                    stuApp_IsOldVer = false;
                    detectionNetwork.resetAisleModelForCAisle(false);
                }

                videoToolBackground.updatePlanStatus(status);
            }

            //第一次上课重选讲义信号
            onSigOneStartClassed: {
                videoToolBackground.updatePlanSelecte();
            }

            onSigSynQuestionSta: { //开始做题按钮同步状态
                console.log("=======onSigSynQuestionSta========",status)
                isStartQuestionStatus = status;
            }

            //打开关闭答案解析
            onSigIsOpenAnswers: {
                if(isOpenStatus){
                    //console.log("=======knowledgesView.open()111========")
                    knowledgesView.open();
                    knowledgesView.updateCheckQuestion(questionId,childQuestionId);
                }else{
                    //console.log("=======knowledgesView.open()222========")
                    //接收到学生端, 关闭"答案解析"的command
                    bAnswer_Parse_OnOff = false
                    knowledgesView.close();
                }
            }
            //接收学生端操作栏目的信号
            onSigSynColumns: {
                console.log("*******onSigSynColumns*********",planId,columnId)
                if(planTypes == -1){
                    videoToolBackground.getPlandIndex(planId);
                }
                cloudMenu.updateSelected(planId,columnId);
            }

            //打开关闭批改面板
            onSigIsOpenCorrects: {
                if(isOpenStatus){
                    modifyHomework.open();
                }else{
                    modifyHomework.close();
                }
            }

            onSigCorrects:
            {
                //modifyHomework.open();
                //答案批改
                console.log("答案批改信号",JSON.stringify(questionData));
                modifyHomework.resetModifyView(questionData)
            }

            //栏目同步
            onSigColumnSynchronize: {
                synchronizePlanId = planId;
                synchronizeItemId = itemId;
                bufferColumnArray.push(
                            {
                                "planId": planId,
                                "columnId": itemId,
                            });
                //console.log("=======planId,itemId=========",planId,itemId);
            }

            onSigPlanSynchronize: {
                synchronizePlanId = planId;
                synchronizePlanInfo();
                console.log("=====onSigPlanSynchronize=====",planId);
            }

            //翻页题目信息
            onSigCurrentTopic:{
                synchronizeQuestionId = questionId;
                synCurrentPlanId = planId;
                synCurrentColumnId = columnId;
                isStartQuestionStatus = questionButStatus;
                console.log("=====onSigCurrentTopic=====",planId,columnId,questionId,questionButStatus,isMenuMultiTopic);
                videoToolBackground.getQuestionInfo(planId,columnId,questionId);
            }

            //显示空白页
            onSigDisplayerBlankPage:{
                isDisplayerAnswerCorrec = false;//设置不显示批改答案解析
                showQuestionHandlerView.displayerBlankPage();
                compositeTopicView.baseImages = "";
                compositeTopicView.visible = false;
                isBlanckPage = true;
                if(mainView.planTypes == -1 || mainView.planTypes == 2 || mainView.planTypes == 100){
                    console.log("======onSigDisplayerBlankPage======")
                    isHomework = 2;
                }else{
                    isHomework = 3;
                }
                if(fullScreenType){
                    bottomToolbars.visible = false;
                }else{
                    bottomToolbars.visible = true;
                }
                console.log("===onSigDisplayerBlankPage===",isBlanckPage,isHomework,planTypes);
            }

            //返回上传做题图片路径
            onSigUploadWorkImage: {
                console.log("=====mainView::currentQuestionId=======",mainView.currentQuestionId)
                updateQuestionDo(mainView.planId,mainView.columnId,mainView.currentQuestionId,1);
                /*新需求不要保存图片
                videoToolBackground.saveBaseImage(mainView.planId,mainView.columnId,mainView.currentQuestionId,
                                                  "",url,imgWidth,imgHeight);
                */
                trailBoardBackground.lodingPlanImage(url,imgWidth,imgHeight);
                trailBoardBackground.autoConvertImage(exercisePage.currentPage - 1,url,imgWidth,imgHeight, mainView.planId,mainView.columnId,mainView.currentQuestionId);
            }

            onSigUserName: {
                videoToolBackground.bUserId = userId;
                popupWidget.setUserName(userName);
                //console.log("onSigUserName>>",userId,userName)
            }

            onSigCurrentCourseTimer: {
                popupWidget.setCurrentTime(parseInt(currentTimer / 60));
                currentLessonTime = currentTimer / 60;
                //console.log("====",currentTimer)
            }

            //当前页
            onSigChangeCurrentPages: {
                //coursewareThumbnailView.resetCurrentBeShowedCoursedata(pages);
                bottomToolbars.currentPage = pages;
                exercisePage.currentPage = pages;
                //                console.log("======onSigChangeCurrentPages=========",pages)
            }
            //总页数
            onSigChangeTotalPages: {
                bottomToolbars.totalPage = pages;
                exercisePage.totalPage = pages;
                //                console.log("======onSigChangeTotalPages=========",pages)
            }
            //开始上课
            onSigStartClassTimeData: {
                toobarWidget.handlEraserImageColor(-1);
                brushWidget.setPenColor();
                brushWidget.setPenWidth();
                var intType = popupWidget.visibleStartClassView();
                if( 1 == intType)
                {
                    popupWidget.hideTimeWidget();
                }
                videoToolBackground.setStartClassTimeData(times);
                videoToolBackground.initChancel();
            }
            //学生B退出信号
            onSigBExitClass: {
                videoToolBackground.setBStatus();
            }

            onSigPromptInterfaceHandl: {
                console.log("=====onSigPromptInterfaceHandl======",inforces)

                if(inforces == "1002") //有人进入教室
                {
                    if(isCurrentTeacherType == "T") //如果自己是老师T, 那进教室的是CC
                    {
                        showMessageTips("CC进入教室");
                    }
                    else if(isCurrentTeacherType == "L") //如果自己是CC (L), 那进教室的是老师
                    {
                        showMessageTips("老师进入教室");
                        if(teacherType == "T")
                        {
                            return;
                        }
                        popupWidget.hideContinueClassView();
                    }
                    else
                    {
                        showMessageTips("有人进入教室");
                    }

                    return;
                }
                else if(inforces == "1003") //有人退出教室
                {
                    if(isCurrentTeacherType == "T") //如果自己是老师T, 那退教室的是CC
                    {
                        showMessageTips("CC退出教室");
                    }
                    else if(isCurrentTeacherType == "L") //如果自己是CC (L), 那退教室的是老师
                    {
                        showMessageTips("老师退出教室");
                    }
                    else
                    {
                        showMessageTips("有人退出教室");
                    }

                    return;
                }

                if(inforces == "68") {
                    videoToolBackground.handlPromptInterfaceHandl(inforces);
                    return;
                }
                if(inforces == "visibleMic"){
                    exercisePage.disabledButton = true;
                    bottomToolbars.disabledButton = true;
                    toobarWidget.disableButton = true;
                    videoToolBackground.disabledButton = true;
                    trailBoardBackground.isHandl = true;
                }

                if(inforces == "autoConnectionNetwork"){
                    popupWidget.setPopupWidget(inforces);
                    return;
                }

                //自动切换ip
                if(inforces == "showAutoChangeIpview" || inforces == "autoChangeIpSuccess" || inforces == "autoChangeIpFail" ){
                    popupWidget.setPopupWidget(inforces);
                    return;
                }
                //学生掉线设置留在教室
                if(inforces == "StayInclass"){
                    isStartLesson = false;
                    videoToolBackground.setStayInclassroom();
                    popupWidget.hideTimeWidget();
                    return;
                }

                if(inforces == "changedWay"){
                    externalCallChanncel.changeChanncel();
                    if(teacherType == "L")
                    {
                        externalCallChanncel.closeVideo("0");
                        externalCallChanncel.closeAudio("0");
                    }
                    return;
                }

                //处理老师结束课程 为a学生
                if(inforces == "65") {
                    popupWidget.setPopupWidget(inforces);
                    return;
                }

                //申请离开教室
                if(inforces == "10"){
                    popupWidget.setPopupWidget(inforces);
                    return;
                }

                //申请进入教室
                if(inforces == "4" || inforces =="5"){
                    popupWidget.setPopupWidget(inforces);
                    return;
                }

                if(inforces == "0" || inforces == "1" ) {
                    popupWidget.setPopupWidget(inforces);
                    return;
                }
                if(inforces == "2") {
                    console.log("==inforces::data==",inforces)
                    isSynLesson = true;
                    popupWidget.setPopupWidget(inforces);
                    cloudMenu.updateSelected(synchronizePlanId,synchronizeItemId);
                    return;
                }

                videoToolBackground.handlPromptInterfaceHandl(inforces);

                //学生申请翻页
                if(inforces == "8"){
                    popupWidget.setPopupWidget(inforces);
                    return;
                }
                //掉线退出重连处理
                if(inforces == "51"){
                    trailBoardBackground.setStartClassRoom();
                }
                //掉线重连
                if(inforces == "14"){
                    popupWidget.setPopupWidget("5");
                    //trailBoardBackground.setContinueLesson();
                }

                //B学生进入教室
                if(inforces == "11"){
                    popupWidget.setPopupWidget(inforces);
                    return;
                }
                //B学生在线操作
                if(inforces == "b_Online"){
                    videoToolBackground.handlPromptInterfaceHandl(inforces);
                    return;
                }

                //上过课
                if(inforces == "22") {
                    isSynLesson = true;
                    bottomToolbars.whetherAllowedClick = true;
                    return;
                }
                //未认真听讲提醒
                if(inforces == "52"){
                    trailBoardBackground.setListenLessonTips();
                    return;
                }
                //申请结束课程
                if(inforces == "50"){
                    popupWidget.setPopupWidget(inforces);
                    return;
                }
                //断开不再重连
                if(inforces == "88"){
                    popupWidget.setPopupWidget(inforces)
                    return;
                }
            }
            onSigVideoAudioUrls: {
                var fileName = videoToolBackground.getFileName(avUrl)
                //console.log("====fileName=====",fileName,avType,startTime);
                if(avType == "video"){
                    mediaPlayer.ymVideoPlayerManagerPlayFielByFileUrl(avUrl, fileName,startTime);
                }
                if(avType == "audio"){
                    audioPlayer.ymAudioPlayerManagerPlayFileByUrl(avUrl,fileName,startTime);
                }
            }

            //学生提交答题信号处理
            onSigAnalysisQuestionAnswers: {
                isStartQuestionStatus = false;
                exercisePage.visible = false;
                toobarWidget.disableButton = true;
                isCommitAnswer = true;
                loadingAnimate.visible = true;
                bottomToolbars.visible = true;
                loadingText.text = "学生正在提交练习，请稍候...";
                videoToolBackground.getAnalysisQuestionAnswer(lessonId,questionId,planId,columnId);
                if(teacherType =="L"){
                    addQuestionDo(planId,columnId ,questionId ,1);
                }
            }
        }

        //底部工具栏
        BottomToolbars{
            id:bottomToolbars
            width: midWidth//240 * widthRate
            height: 35  * widthRate
            visible: fullScreenType ? false : ((mainView.columnType == 0 || mainView.columnType ==1) ? true : false) //true
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: (parent.width + (leftMidWidth + 12.0 * leftMidWidth / 66) - (rightWidth + borderShapeLen) -width) * 0.5
            anchors.bottomMargin:  5  * fullHeights / 900
            disableAnswer: (isHomework == 3 || isHomework == 4) ? ( isDisplayerAnswerCorrec ? true : false) : false
            disableCorrec: isHomework == 3 && (mainView.columnType == 2) ? ( isDisplayerAnswerCorrec ? true : false) : false
            disabledButton: teacherType == "T" ? true : false
            //答案解析
            onSigAnswer: {
                answerStatus = !answerStatus;
                //console.log("========******answerStatus******==========", bottomToolbars.answerIsOpen, knowledgesView.visible, answerStatus, knowledgesView.modal)
                if(answerStatus)
                {
                    //console.log("=======knowledgesView.open() open========")
                    knowledgesView.open();
                }else
                {
                    //console.log("=======knowledgesView.open() close========")
                    knowledgesView.close();
                }
            }

            //批改信号
            onSigModify: {
                correctStatus = !correctStatus;
                if(correctStatus){
                    modifyHomework.open();
                    trailBoardBackground.openCorrect(mainView.planId, mainView.columnId, mainView.currentQuestionId);
                }else{
                    modifyHomework.close();
                }
            }
            //收回分页权限
            onSigRecoverPage: {
                trailBoardBackground.setRecoverPage();
            }

            //跳转页面
            onSigJumpPage: {
                console.log("=====onSigJumpPage====",pages)
                trailBoardBackground.jumpToPage(pages);
                videoToolBackground.requstLessonInfo();
            }

            //添加分页
            onSigAddPage: {
                //console.log("===addPage===")
                trailBoardBackground.addPage();
                //coursewareThumbnailView.insertPage(bottomToolbars.currentPage);
            }
            //删除分页
            onSigRemoverPage: {
                popupWidget.setPopupWidget("removerPage");
                //coursewareThumbnailView.insertPage(bottomToolbars.currentPage);
            }
            //翻页首末页提醒
            onSigTipPage:  {
                if(message == "lastPage"){
                    showMessageTips("已经到最后一页了!");
                }
                if(message == "onePage"){
                    showMessageTips("已经到第一页了!");
                }
            }
        }

        //新课件及课后作业显示模块
        AuditionLessonCoursewareView{
            id:auditionLessonCoursewareView
            height:trailBoardBackground.height
            width: trailBoardBackground.width / 2.036
            visible: false
            x:trailBoardBackground.x + trailBoardBackground.width - auditionLessonCoursewareView.width
            y:midHeightY

            onStartClipHMImgs:
            {
                //auditionLessonCoursewareView.visible = false;
                loadingText.text = "正在导入课堂，请稍候...";
                loadingAnimate.visible = true;
                if(1 == status)//试听课报告导入课堂信息上报
                {
                    trailBoardBackground.pushInsertReportMsgToServer(1,"","");
                }
            }

            onFinishedClipHmImgs:
            {
                console.log("=====::imagsseUrl====222");
                loadingAnimate.visible = false;
                loadingText.text = "学生正在提交练习，请稍候...";
            }

            onSendReportImgSockets:
            {
                var hasEmptyImg = false;
                if(imgarry.length > 0)
                {
                    for(var a = 0; a < imgarry.length; a++)
                    {
                        if("str_Null" == imgarry[a].imageUrl)
                        {
                            hasEmptyImg = true;
                            break;
                        }
                    }
                }

                if(!hasEmptyImg && imgarry.length > 0)
                {
                    trailBoardBackground.sendReportImg(imgarry);

                    if(1 == status )//试听课报告导入课堂信息上报
                    {
                        trailBoardBackground.pushInsertReportMsgToServer(2,"",imgarry[0].imageUrl);
                    }
                }else
                {
                    showMessageTips("导入失败。。");
                    if(1 == status && imgarry.length <= 0)
                    {
                        trailBoardBackground.pushInsertReportMsgToServer(3,qsTr("系统错误"),"");
                    }else if(1 == status && hasEmptyImg)
                    {
                        trailBoardBackground.pushInsertReportMsgToServer(3,qsTr("图片上传失败"),"");
                    }
                }
            }

            onShowHomeWorkDetails:
            {
                videoToolBackground.getHomeWorkDetail(homeWorkId);
            }

            onClipCurrentImgs:
            {
                var answerArray = [];
                getQuestionItems(questionData,answerArray,imgArr,true);
            }
        }

        //右边视频工具栏
        VideoToolBackground{
            id:videoToolBackground
            width: rightWidth + borderShapeLen
            height: rightHeight
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: rightWidthX - borderShapeLen
            anchors.topMargin: rightWidthY
            visible: fullScreenType ? false : true

            onSigHomeWorkLists:{
                auditionLessonCoursewareView.setHomeWorkListData(objData);
            }

            onSigHomeWorkDetails:
            {
                auditionLessonCoursewareView.setHomeWorkdetailData(objData);
            }

            onSigCloseWidget: {
                //                var isOnline = curriculumData.justTeacherOnline();
                //                console.log("=====onSigCloseWidget=========",studentType,isOnline);
                //                if(isOnline) {
                popupWidget.setPopupWidget("close");
                //                }else {
                //                    trailBoardBackground.disconnectSockets();
                //                    externalCallChanncel.closeAlllWidget()
                //                }
            }

            //获取题目失败重新做题
            onSigGetQuestionFailed: {
                exercisePage.visible = true;
                exercisePage.isStartMake = false;
                exercisePage.isVisibleStartButton = true;
            }

            //批改成功
            onSigCorreSuccessed: {
                trailBoardBackground.correctCommand(mainView.planId,
                                                    mainView.columnId,
                                                    mainView.currentQuestionId,
                                                    mainView.correctChildQuestionId,
                                                    mainView.correctType,
                                                    mainView.currentScore,
                                                    mainView.errorReason,
                                                    mainView.errorId);
            }

            onSigLoadLessonFails: {
                popupWidget.setPopupWidget("LoadLessonFail");
            }

            //            //讲义同步完成
            onSigSynPlanSuccess: {
                synchronizePlanInfo();
            }

            //控制本地摄像头
            onSigOperationVideoOrAudio: {
                trailBoardBackground.setOperationVideoOrAudio(userId ,  videos ,  audios);
            }
            //控制学生进行音频、音视频  音频模式 视频模式切换
            onSigOnOffVideoAudio: {
                console.log("onSigOnOffVideoAudio",videoType)
                trailBoardBackground.setOnOffVideoAudio(videoType)
            }
            //用户授权
            onSigSetUserAuth: {
                trailBoardBackground.setUserAuth(userId,authStatus);
            }
            //选择课件显示当前课件
            onSigSetLessonShow: {
                trailBoardBackground.setLessonShow(message);
                //coursewareThumbnailView.resetAllBeShowedCourseData(message);
            }
            //播放音频文件
            onSigPlayerVideo: {
                audioPlayer.visible = false;
                mediaPlayer.ymVideoPlayerManagerPlayFielByFileUrl(videoSoucre,videoName,0);
                //trailBoardBackground.setVideoStream("video","play","00:00:00",videoSoucre);
            }
            //播放MP3
            onSigPlayerAudio: {
                mediaPlayer.visible = false;
                var audioPath = trailBoardBackground.downLoadMp3(audioSoucre);
                audioPlayer.ymAudioPlayerManagerPlayFileByUrl("file:///" + audioPath,audioName,0,audioSoucre)
                //trailBoardBackground.setVideoStream("audio","play","00:00:00",audioSoucre);
            }
            //创建教室成功发送进入教室指令
            onSigCreateClassrooms: {
                //trailBoardBackground.setStartClassRoom();
            }
            //最小化
            onSigMinFrom: {
                mainView.visibility = Window.Minimized;
            }
            //结束课程弹窗操作
            onSigGetCourse: {
                popupWidget.updateEndLesson(isDisplay,playerTime);
            }
            //讲义信息处理 显示结构话课件顶部栏目信息
            onSigHandoutMenuInfos: {
                var dataModel = [];
                for(var i = 0; i < dataArray.length; i++){
                    dataModel.push(
                                {
                                    "itemId":dataArray[i].itemId,
                                    "itemName": dataArray[i].itemName,
                                    "itemType": dataArray[i].itemType,
                                    "orderNo": dataArray[i].orderNo,
                                    "lessonId": dataArray[i].lessonId,
                                    "questionId": dataArray[i].questionId,
                                    "planId": dataArray[i].planId,
                                })
                }
                cloudMenu.dataModels = dataModel;
            }

            //题目信息
            onSigQuestionInfos: {
                //modifyHomework.dataModel = questionInfo;
                getQuestionItems(questionInfo,answerArray,photosArray,browseStatus);
            }

            //学习目标
            onSigLearningTargets: {
                var type = 0;
                compositeTopicView.visible = false;
                topicBrowsView.visible = false;
                showQuestionHandlerView.visible = true;
                topicModel = 1;
                isDisplayerAnswerCorrec = false;
                showQuestionHandlerView.setCurrentBeShowedView(targetData,type,topicModel);
                console.log("======学习目标========");
            }

            //点击讲义发送命令
            onSigSendHandoutInfos: {
                currentPlanInfo = handoutData;
                trailBoardBackground.lectureCommand(handoutData);
            }
            //讲义题目显示上一题下一题
            onSigMultiTopic: {
                exercisePage.isVisiblePage = true;
                exercisePage.totalPage = totalPage;
                console.log("======onSigMultiTopic=======",currentPage)
            }
            //点击下一题时改变 当前题目Id
            onSigTopicIds: {
                console.log("=====onSigTopicIds========",questionId)
                mainView.currentQuestionId = questionId;
            }

            //是否有子题
            onSigIsTopicChild: {
                isMultiTopic = childStatus;
                console.log("====onSigIsTopicChild====",childStatus);
            }
            //栏目是否有子题
            onSigIsMenuMultiTopics:{
                mainView.isMenuMultiTopic = status;
                console.log("======onSigIsMenuMultiTopics========",status);
            }

            //错因列表
            onSigErrorListed: {
                modifyHomework.updateErrorList(errorList);
            }
        }

        YMTipNetworkView{
            id: networkView
            width:rightWidth + 20 * heightRate
            height:  160 * heightRate
            x: parent.width - rightWidth - 10 * heightRate
            y: 40 * heightRates
        }

        //全屏按键
        MouseArea{
            id:fullScreenBtn
            width: 30 * widthRate
            height: 30 * widthRate
            anchors.right: parent.right
            anchors.rightMargin:coursewareThumbnailButton.visible ? midWidth * 0.4135  : midWidth * 0.5
            anchors.bottom: parent.bottom
            anchors.bottomMargin:  2  * heightRates
            hoverEnabled: true
            visible: bottomToolbars.visible ? true : (fullScreenType ? true : false)
            enabled: bottomToolbars.disabledButton

            Image {
                id: fullScreenBtnImage
                anchors.left: parent.left
                anchors.top: parent.top
                width: parent.width
                height: parent.height
                source: fullScreenType ? ("qrc:/newStyleImg/pc_btn_smallscreen@2x.png") : ("qrc:/newStyleImg/pc_btn_fullscreen@2x.png")
                //source: fullScreenType ? (parent.containsMouse ? "qrc:/images/cr_btn_xiaopingmu_sed@2x.png" :  "qrc:/images/cr_btn_xiaopingmutwox.png" ) : (parent.containsMouse ? "qrc:/images/fullscreen@2x.png" : "qrc:/images/fullscreentwox.png")
            }

            onClicked: {
                fullScreenBtn.focus = true;
                fullScreenType = !fullScreenType;
                setFullScrreen(fullScreenType);
            }
        }

        MouseArea
        {
            id:coursewareThumbnailButton
            width: 328 * heightRates * 0.32
            height: 108 * heightRates * 0.32
            anchors.right: parent.right
            anchors.rightMargin: midWidth * 0.45
            anchors.bottom: parent.bottom
            anchors.bottomMargin:  4  * heightRates
            hoverEnabled: true
            visible:  ( planTypes == -1 || teacherType == "L" || exercisePage.isStartMake || tipStopExercise.visible) ? false : (fullScreenType ? false : true)

            Image {
                anchors.left: parent.left
                anchors.top: parent.top
                width: parent.width
                height: parent.height
                source: parent.containsMouse ? ("qrc:/newStyleImg/suoluetuClick.png") : ("qrc:/newStyleImg/suoluetuCommon.png")
            }

            onClicked: {
                console.log("planTypes",planTypes,isHomework,columnType)
                coursewareThumbnailView.resetCurrentBeShowedCoursedata(bottomToolbars.currentPage);
                coursewareThumbnailView.visible = !coursewareThumbnailView.visible;
            }
        }


        //工具栏
        ToobarWidget{
            id: toobarWidget
            width: leftMidWidth //+ 12.0 * leftMidWidth / 66
            height: leftMidHeight + 45.0  * leftMidWidth  / 66
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin:  - 3.0 * leftMidWidth  / 66
            anchors.topMargin:  - 5.0  * leftMidWidth  / 66
            visible:  fullScreenType ? false : true

            onSigSendFunctionKey: {
                trailBoardBackground.cancelScreenPicture();
                //画笔
                if(keys == 1) {
                    if(brushWidget.focus == false) {
                        brushWidget.focus = true;
                        brushWidget.setPenColor();
                        brushWidget.setPenWidth();
                    }else {
                        brushWidget.focus = false;
                    }

                    return;
                }
                //橡皮擦
                if(keys == 2) {
                    if(eraserWidget.focus == false) {
                        eraserWidget.focus = true;
                    }else {
                        eraserWidget.focus = false;
                    }
                    return;
                }

                //表情
                if(keys == 3){
                    if ( interfaceWidget.focus == false ){
                        interfaceWidget.focus = true;
                    }else{
                        interfaceWidget.focus = false;

                    }
                    return;
                }

                //截图
                if(keys == 4) {
                    if( pictureWidget.focus == false) {
                        pictureWidget.focus = true;
                    } else {
                        pictureWidget.focus = false;

                    }
                    return;
                }

                //几何图形
                if(keys == 5) {
                    if(graphicWidget.focus == false) {
                        graphicWidget.focus = true;
                    }else {
                        graphicWidget.focus = false;

                    }
                    return;
                }

                //网络优化
                if(keys == 6) {
                    if(detectionNetwork.focus == false) {
                        detectionNetwork.focus = true;
                    }else {
                        detectionNetwork.focus = false;
                    }
                    return;
                }
                //教鞭
                if(keys == 7){
                    toobarWidget.focus = true;
                    trailBoardBackground.setCursorShapeType(4);
                }
                //回撤
                if(keys ==8){
                    toobarWidget.focus = true;
                    trailBoardBackground.undo();
                }
                //技术工单
                if(keys ==9){
                    toobarWidget.focus = true;
                    createWorkView.visible = true;
                    return;
                }
            }

        }

        //创建工单
        TipCreatWorkOrderView{
            id: createWorkView
            z: 66
            anchors.fill: parent
            visible: false
            onCloseChanged: {
                createWorkView.visible = false;
            }

            onCreatWorkOrderFinished: {
                trailBoardBackground.showCommitWorkMessage();
            }
        }

        //画笔操作
        BrushWidget{
            id:brushWidget
            anchors.left: toobarWidget.right
            anchors.leftMargin: -8 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin: topMargins + 62 * fullHeight / 900//80 * fullHeights / 900
            width: 255 * widthRate * 0.8
            height: 198  * widthRate * 0.8
            visible: false
            focus: false
            z:10
            onFocusChanged: {
                if(brushWidget.focus) {
                    brushWidget.visible = true;
                }else {
                    brushWidget.visible = false;
                }
            }
            onSendPenColor: {
                trailBoardBackground.setPenColors(penColors);
                toobarWidget.handlBrushImageColor(penColors);
                //setBrushImage();
            }
            onSendPenWidth: {
                trailBoardBackground.changeBrushSizes(penWidths);
                //setBrushImage();

            }

        }

        //橡皮
        EraserWidget{
            id:eraserWidget
            anchors.left: toobarWidget.right
            anchors.leftMargin: -6 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin: 58 * 3 * leftMidWidths - 18 * leftMidWidths//topMargins + 180 * fullHeights / 900//220 * heightRate
            width: 133 * widthRate * 0.6
            height: 180 * widthRate * 0.6
            z:10
            visible: false
            focus: false
            onFocusChanged: {
                if(eraserWidget.focus) {
                    eraserWidget.visible = true;
                }else {
                    eraserWidget.visible = false;
                }
            }

            onSigSendEraserInfor: {
                trailBoardBackground.focus = true;
                trailBoardBackground.setCursorShapeType(types);
                toobarWidget.handlEraserImageColor(types);
            }

            onSigClearsCreeon: {
                eraserWidget.visible = false;
                popupWidget.setPopupWidget("12");
            }
        }

        //表情
        InterfaceWidget{
            id:interfaceWidget
            anchors.left: toobarWidget.right
            anchors.leftMargin: -8 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin: 58 * 3 * leftMidWidths + 6 * leftMidWidths
            width: 308 * widthRate * 0.9
            height: 274  * widthRate * 0.9
            z:10
            visible: false
            focus: false
            onFocusChanged: {
                if(interfaceWidget.focus) {
                    interfaceWidget.visible = true;
                }else {
                    interfaceWidget.visible = false;

                }
            }
            onSigSendHttpsUrl: {
                trailBoardBackground.focus = true;
                trailBoardBackground.setInterfaceUrl(urls);

            }

        }

        //截图
        PictureWidget{
            id:pictureWidget
            anchors.left: toobarWidget.right
            anchors.leftMargin: -6 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin: 58 * 6 * leftMidWidths + 10 * leftMidWidths
            width: 268 * heightRate / 2.5
            height: 264  * heightRate / 2.5
            z:10
            visible: false
            focus: false
            disableClipButton: isHomework == 1 ? false : true

            onFocusChanged: {
                if(focus) {
                    pictureWidget.visible = true;
                }else {
                    pictureWidget.visible = false;
                }
            }
            onSigUpLoadPicture: {
                trailBoardBackground.focus = true;
                trailBoardBackground.setUpLoadPicture();

            }
            onSigScreenShotPicture: {
                trailBoardBackground.focus = true;
                trailBoardBackground.setScreenShotPicture();
                //   screenshotSaveImage.grabImage(idTrailItem);
            }
        }

        //几何界面
        GraphicWidget{
            id:graphicWidget
            anchors.left: toobarWidget.right
            anchors.leftMargin: -10 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin:  58 * 7 * leftMidWidths + 7 *   leftMidWidths
            width: 258 * widthRate * 0.65
            height: 60  * widthRate * 0.65
            z:10
            visible: false
            focus: false
            onFocusChanged: {
                if(focus) {
                    graphicWidget.visible = true;
                }else {
                    graphicWidget.visible = false;

                }
            }
            onSigPolygon: {
                trailBoardBackground.focus = true;
                trailBoardBackground.setDrawPolygon(polygons);
            }
        }

        Rectangle
        {
            anchors.fill: parent
            visible: detectionNetwork.visible
            color: "#111111"
            opacity: 0.8
            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    return;
                }
            }
        }
        //设备检测
        DetectionNetwork{
            id:detectionNetwork
            anchors.centerIn: parent
            width: 270 * heightRate * 0.9
            height: 255  * heightRate * 0.9
            z:18
            visible: false
            focus: false

            onFocusChanged: {
                if(detectionNetwork.focus) {
                    detectionNetwork.currentAisle = curriculumData.getUserChanncel();
                    detectionNetwork.visible = true;
                }else {
                    //detectionNetwork.visible = false;
                }
            }

            onSigCurrentNetStatus: {
                videoToolBackground.updateNetworkStatus(netStatus,netValue);
            }

            //发送当前网络状态
            onSigSendCurrentNetworks: {
                toobarWidget.networkIcon =  parseInt(status);

            }
            //切换网络
            onSigChangeOldIpToNews:{
                if(currentAisle == "2"){
                    externalCallChanncel.exitWayB();
                }
                trailBoardBackground.setChangeOldIpToNews();

            }
            //发送延迟的信息
            onSigSendIpLostDelays:{
                trailBoardBackground.setSigSendIpLostDelays(strList);
            }
            //通道切换
            onSigChangeAisle: {
                console.log("onSigChangeAisle 1",aisle)
                trailBoardBackground.setAisle(aisle);
                externalCallChanncel.changeChanncel();
                if(teacherType == "L")
                {
                    externalCallChanncel.closeVideo("0");
                    externalCallChanncel.closeAudio("0");
                }
            }
        }

        //音频播放
        YMAudioPlayer{
            id:audioPlayer
            visible: false
            z: 17
            width: 550 * widthRates
            height:  60 * heightRates
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 60  * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            onSigClose: {
                videoToolBackground.selectedLessonIndex();
                trailBoardBackground.setVideoStream(vaType,controlType,times,address);
            }
            onSigPlayerMedia:  {
                trailBoardBackground.setVideoStream(vaType,controlType,times,address);
            }
        }

        //视频播放器
        YMVideoPlayer{
            id:mediaPlayer
            width: 600 * widthRates
            height: 430 * heightRates
            y:fullHeightY + ( fullHeight - mediaPlayer.height) / 2
            x:fullWidthX  + ( fullWidth - mediaPlayer.width) / 2
            z:17
            visible: false
            onSigClose: {
                videoToolBackground.selectedLessonIndex()
                trailBoardBackground.setVideoStream(vaType,controlType,times,address);
            }
            onSigPlayerMedia:  {
                trailBoardBackground.setVideoStream(vaType,controlType,times,address);
            }
        }

        //学生所有弹窗提示封装
        PopupWidget{
            id: popupWidget
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            z:18
            visible: true

            onSigTeacherHandMic:
            {
                trailBoardBackground.teacherHandMic(status);
            }

            onSigReportFinisheds:
            {
                trailBoardBackground.sendReportFinisheds();
            }

            onSigCloseAllWidget: {
                trailBoardBackground.disconnectSockets();
                externalCallChanncel.closeAlllWidget()
            }
            onSelectWidgetType: {
                trailBoardBackground.setSelectWidgetType(types);
            }
            onSigEvaluateContent: {
                trailBoardBackground.sendEvaluateContent(contentText1 ,  contentText2 ,  contentText3);
            }
            //留在教室
            onSigStayInclassroom: {
                trailBoardBackground.setStayInclassroom();
            }
            onSigExitRoomName: {
                videoToolBackground.setStayInclassroom();
                //videoToolBackground.closeVideo();
            }
            //开始上课弹窗
            onStartLesson: {
                //先初始化线路
                //再发送进入教室命令
                isStartLesson = true;
                var  way = videoToolBackground.getWay()
                console.log("=====way===",way);
                if(way == "1"){
                    videoToolBackground.initChancel();
                }
                if(way == "2"){
                    videoToolBackground.initChancel();
                }

                if(way == "3"){
                    videoToolBackground.initChancel();
                }

                if(isCurrentTeacherType == "L"){
                    trailBoardBackground.setOperationVideoOrAudio("0","0","1");
                }
                trailBoardBackground.setStartClassRoom();
                trailBoardBackground.reposeMicrophone("1","1");
            }
            //同意学生离开教室
            onSigAgree: {
                trailBoardBackground.setApplyExitStart(true);
            }
            //拒绝学生离开教室
            onSigRefuse: {
                trailBoardBackground.setApplyExitStart(false);
            }
            //清屏操作
            onSigClearScreen: {
                trailBoardBackground.setClearCreeon();
            }
            //退出程序
            onSigExitProject: {
                if(audioPlayer.visible){
                    trailBoardBackground.setVideoStream("audio","stop","0",audioPlayer.filePath);
                }
                if(mediaPlayer.visible){
                    trailBoardBackground.setVideoStream("video","stop","0",mediaPlayer.filePath);
                }
                trailBoardBackground.setExitProject();

            }
            //删除课件提醒页面
            onSigTipCourseWare: {
                trailBoardBackground.removerPage();
            }
            //申请翻页权限
            onSigApplyPageRole: {
                trailBoardBackground.setApplyPage(status);
            }
            //同意B学生进入教室
            onSigApplyBClass: {
                trailBoardBackground.setBgotoClass(status);
                videoToolBackground.setBStatus();
            }
            //评价之前主动退出教室命令
            onSigFinishClass: {
                isLessonAssess = true;
                trailBoardBackground.teaFinishClassroom(currentIsAuditionLesson);
            }
            //结束课程退出获取时间信号
            onSigGetLessonTime: {
                console.log("======sigGetLessonTime=======")
                trailBoardBackground.getCurrentCourse();
                videoToolBackground.getEndCourseStatus();
            }
            //同意结束课程申请
            onSigAgreeEndLesson: {
                if(types == 2){ //2同意
                    trailBoardBackground.agreeEndLesson(types);
                }else{
                    trailBoardBackground.agreeEndLesson(types);
                }
            }
        }
    }

    CurriculumData{
        id:curriculumData
    }

    ExternalCallChanncel{
        id:externalCallChanncel
        //通道切换完成发送命令
        onSigAisleFinished: {
            console.log("onSigAisleFinished",isSuccess);
            if(isSuccess)
            {
                trailBoardBackground.setOnOffVideoAudio("");
                var isVideo = videoToolBackground.getIsVideo();
                trailBoardBackground.setOnOffVideoAudio(isVideo);
                showMessageTips("通道切换成功...");

                if(teacherType == "L")
                {
                    externalCallChanncel.closeVideo("0");
                    externalCallChanncel.closeAudio("0");
                }

            }else
            {
                popupWidget.setPopupWidget("createRoomFail");
            }
        }

        onSigRequestVideoSpan: {
            trailBoardBackground.setRequestVideoSpans();
        }
    }

    YMHomeWorkManagerAdapter{
        id: coludClassMgr
    }

    function getQuestionItems(questionItemsData,answerArray,photosArray,browseStatus){//true
        if(questionItemsData.questionType == undefined || questionItemsData == null){
            console.log("======getQuestionItems::null========");
            return;
        }

        var knowledgesModels = questionItemsData.knowledges //Cfg.zongheti.knowledges;
        var answerModel = questionItemsData.answer //Cfg.zongheti.answer;
        var questionItems = questionItemsData.questionItems //Cfg.zongheti.questionItems;
        var type = questionItemsData.questionType //Cfg.zongheti.questionType;
        var childQuestionInfo = questionItemsData.childQuestionInfo;
        var questionStatus = questionItemsData.status;

        mainView.orderNumber = questionItemsData.orderNumber;//题目编号
        knowledgesView.dataModel = questionItemsData;
        knowledgesView.answerModel = answerArray;
        knowledgesView.childQuestionInfoModel = childQuestionInfo;
        modifyHomework.dataModel = questionItemsData;

        if(currentIsHomeWorkClipImg){
            isDisplayerAnswerCorrec = false;
        }else{
            isDisplayerAnswerCorrec = true;
        }

        //console.log("========photosArray==========",JSON.stringify(photosArray),questionStatus);
        //console.log("#######answerArray#########", JSON.stringify(answerArray));
        var baseImages = "";
        if(questionItemsData.baseImage != null ){//&& questionStatus == 2 || questionStatus == 4) {
            baseImages = (questionItemsData.baseImage.imageUrl == null || questionItemsData.baseImage.imageUrl =="") ? "" : questionItemsData.baseImage.imageUrl;
        }

        console.log("**********browseStatus::Data**************",browseStatus,baseImages,type)

        isBlanckPage = false;
        isHomework = 1;
        //console.log("*****main::getQuestionItems******",isHomework,questionStatus,browseStatus,type,topicModel,isMenuMultiTopic);

        var questionId = questionItemsData.id;
        var questionMake = false;
        for(var i = 0; i < questionBufferModel.count; i++){

            var modelQuestionId = questionBufferModel.get(i).questionId;
            var modelQuestionStatus = questionBufferModel.get(i).status;

            console.log("**********1111111111111***************",modelQuestionId,modelQuestionStatus);
            if(modelQuestionId == questionId && (modelQuestionStatus == 1)){
                questionMake = true;
                isHomework = 3;
                updateStartButtonStatus(true)
                break;
            }
        }

        if(baseImages != ""){
            questionMake = true;
            isHomework = 3;
            updateStartButtonStatus(true);
            console.log("=========isHomework::values========",isHomework)
        }
        console.log("**********111baseImages111**********",baseImages,isHomework,questionMake);
        if(questionMake == false){
            updateStartButtonStatus(false);
        }
        toobarWidget.disableButton = questionMake || browseStatus ? (teacherType == "T" ? true : false) : false;//题目已做未作禁用打开工具栏

        topicModel = (browseStatus ? 2 : 1);
        browseStatus = teacherType == "T" ? browseStatus  : false;
        topicBrowsView.setStatus(false);
        console.log("=====questionItemsData=====", JSON.stringify(questionItemsData));
        if(type == 6){
            showQuestionHandlerView.visible = false;
            showQuestionHandlerView.isCompleStatus = true;

            topicBrowsView.visible = false;
            topicBrowsView.setStatus(browseStatus);
            topicBrowsView.photosData = photosArray;
            topicBrowsView.dataModel = questionItemsData;
            topicBrowsView.childQuestionInfoModel = childQuestionInfo;

            //browseStatus = true;//调试用

            //综合题
            if(browseStatus){//学生提交作业显示截图
                compositeTopicView.visible = false;
                topicBrowsView.visible = true;
                console.log("========browseStatus===========",browseStatus);
                return;
            }
            console.log("======综合题6=======");
            compositeTopicView.visible = true;
            compositeTopicView.answerModel = answerArray;
            compositeTopicView.dataModel = questionItemsData;
            return;
        }

        compositeTopicView.visible = false;
        topicBrowsView.visible = false;
        mainView.childQuestionId = "";
        mainView.currentScore = questionItemsData.score;
        mainView.correctType = questionItemsData.isRight;
        mainView.errorReason = questionItemsData.errorType;

        //五大题型展示
        showQuestionHandlerView.isCompleStatus = false;
        showQuestionHandlerView.knowledgesModels = knowledgesModels;
        showQuestionHandlerView.answerModel = answerModel;
        showQuestionHandlerView.questionItemsData = questionItems;
        showQuestionHandlerView.setCurrentBeShowedView(questionItemsData,type,browseStatus,topicModel);
        showQuestionHandlerView.visible = true;
    }

    //同步讲义函数
    function synchronizePlanInfo(){
        if(synchronizePlanId != 0){
            console.log("======synchronizePlanInfo========",synchronizePlanId,synchronizeItemId);
            videoToolBackground.selectePlanItem(synchronizePlanId);
        }
    }

    //显示所有消息提醒窗
    function showMessageTips(message){
        if(message.length > 30){
            toopBracundTimer.interval = 10000;
        }else{
            toopBracundTimer.interval = 3000;
        }

        toopBracundImageText.text = message;
        toopBracund.visible = false;
        toopBracund.visible = true;
    }

    //添加做题缓存
    function addQuestionDo(planId,columnId,questionId,status){
        //planId:讲义Id  columnId: 栏目Id questionId:题目Id status:做题状态(0:未做,1已做)
        questionBufferModel.append(
                    {
                        "planId": planId,
                        "columnId": columnId,
                        "questionId": questionId,
                        "status": status,
                    })
    }

    //修改题目状态
    function updateQuestionDo(planId,columnId,questionId,status){
        for(var i = 0; i < questionBufferModel.count; i++){
            var m_planId = questionBufferModel.get(i).planId;
            var m_columnId= questionBufferModel.get(i).columnId;
            var m_questionId = questionBufferModel.get(i).questionId;
            //console.log("*******AAAAAAAAAAAAA**********",questionId,m_questionId);
            if(planId == m_planId && columnId ==m_columnId && questionId == m_questionId){
                questionBufferModel.get(i).status = status;
                break;
            }
        }
    }

    //修改按钮状态,status(true：已做  false：未作)
    function updateStartButtonStatus(status){
        //        exercisePage.isVisibleStartButton =  true// isStartLesson ?  (status == true ? false : true)  : false; //
        //        exercisePage.isVisiblePage =  true; // mainView.isMenuMultiTopic ? (isStartQuestionStatus ? false : true ) : false; //
        //        exercisePage.isStartMake=  false; // isStartQuestionStatus; //
        //        return;

        exercisePage.isVisibleStartButton = isStartLesson ?  (status == true ? false : true)  : false; //
        exercisePage.isVisiblePage = mainView.isMenuMultiTopic ? (isStartQuestionStatus ? false : true ) : false; //
        exercisePage.isStartMake = isStartQuestionStatus; //
        console.log("*******updateBottomStatus********",isStartLesson,fullScreenType,isHomework,status,isBlanckPage,isStartQuestionStatus, exercisePage.isVisibleStartButton)
        if(fullScreenType){
            exercisePage.visible = false;
            bottomToolbars.visible = false;
            return;
        }

        if(mainView.columnType == 1 || mainView.columnType == 0){
            exercisePage.visible = false;
            bottomToolbars.visible = true;
            toobarWidget.disableButton = teacherType == "T" ? true : false;
            console.log("***********columnType*************",columnType);
            return
        }
        if(status){
            exercisePage.visible = false;
            bottomToolbars.visible = true;
        }else{
            if(isBlanckPage){
                exercisePage.visible = false;
                bottomToolbars.visible = true;
                isBlanckPage = false;
                return;
            }

            if(isCommitAnswer){
                exercisePage.visible = false;
                bottomToolbars.visible = true;
                isCommitAnswer = false;
                return;
            }

            if(isHomework == 2 || isHomework == 3){
                exercisePage.visible = false;
                bottomToolbars.visible = true;
                return
            }
            if(isHomework == 1){
                if(!isStartQuestionStatus)
                {
                    exercisePage.isVisiblePage = true;
                }

                exercisePage.visible = true;
                bottomToolbars.visible = false;
                return
            }

            if(mainView.columnType == 0 || mainView.columnType == 1){
                exercisePage.visible = false;
                bottomToolbars.visible = true;
                return;
            }

            exercisePage.visible = (exercisePage.currentPage -1) <= 1 ? false : true //true;
            bottomToolbars.visible = (exercisePage.currentPage -1) <= 1 ? true : false;
        }
    }


    //设置这几项: videoToolBackground, bottomToolbars, toobarWidget, cloudMenu 控件的enable状态
    //点击圆形, 或者几何图形的时候,
    //出现取消× 按钮, 和√按钮, 没有点击这两个按钮,
    //这个时候, 这些videoToolBackground, bottomToolbars, toobarWidget, cloudMenu 控件, 都不能操作
    function doEnableDisableControls(status)
    {
        videoToolBackground.disableButton = status
        bottomToolbars.disabledButton = status;
        toobarWidget.disableButton = status;
        cloudMenu.disableButton = status;
    }
}

