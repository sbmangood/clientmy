import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import CurriculumData 1.0
import ExternalCallChanncel 1.0
import YMHomeWorkManagerAdapter 1.0
import "./Configuuration.js" as Cfg

Window {
    id: mainView
    visible: true
    width: Screen.width * 0.7
    height:  Screen.width*0.7/966.0*655.0 //Screen.height + 1
    flags: Qt.Window | Qt.FramelessWindowHint //| Qt.WindowStaysOnTopHint
    title: "查看课件"
    x:(Screen.width-width)/2
    y:(Screen.height-height)/2

    property  bool idShowClassTrail: false;//是否显示课堂轨迹
    MouseArea{
        anchors.fill: parent
        onClicked: {
            mainImageView.hideRectangle();
            if(mainWindowTop.isOpenedStates)
            {
                mainWindowTop.isOpenedStates =  !mainWindowTop.isOpenedStates;
            }
        }
    }
    property int topMargins: leftWidthY - 6.0  * leftMidWidth  / 66
    property double leftMidWidths: leftMidWidth / 66.0;
    property bool isStartLesson: false;//是否开始上课
    property bool   isLessonAssess: false;//是否结束课程评价
    property int isHomework: 2; //习题模式 1:练习模式 2：老课件模式 3：批改模式 4:浏览模式
    property int topicModel: -1;//1做题模式，2对答案模式
    property string currentQuestionId: "";//当前题目Id
    property bool isMultiTopic: false;//当前题目是否有多题
    property bool isMenuMultiTopic: false;//栏目是否有多题
    property string planId: "";//当前讲义Id
    property var currentPlanInfo: [];//当前选择的讲义信息
    property string columnId: "";//当前栏目Id
    property string orderNumber: "";//题号
    property int columnType: 0;//栏目类型 0：知识类型，1：题目类型 2：试题练习
    property bool isDisplayerAnswerCorrec: true;//是否显示答案解析和批改
    property var bufferColumnArray: [];//点击栏目缓存

    property bool isfirstShow: true;

    property bool hasClicked: false;


    //做题缓存
    ListModel{
        id: questionBufferModel
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

    //批改属性定义
    property string childQuestionId: "";//小题Id
    property double currentScore: 0;//得分
    property int correctType: -1;//批改类型
    property string errorReason: "";//错因
    property int errorId: 0;//错因Id

    //批改、答案解析状态
    property bool answerStatus: false;
    property bool correctStatus: false;

    onIsBlanckPageChanged: {
        console.log("********onIsBlanckPageChanged*************",isBlanckPage)
        if(isBlanckPage){
            exercisePage.isVisibleStartButton = false;
        }
    }

    onIsHomeworkChanged: {
        if(isHomework == 2){
            // exercisePage.visible = false;
            bottomToolbars.visible = true;
        }
    }

    //列改变
    onColumnTypeChanged: {
        if(columnType == 1 || columnType == 0){
            console.log("**********isStartQuestionStatus*************",isStartQuestionStatus);
            updateStartButtonStatus(false);
        }
    }

    //关闭窗体
    onClosing: {
        trailBoardBackground.disconnectSockets();
        externalCallChanncel.closeAlllWidget()
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
        if(types) {
            var tempVisible = false;
            if(trailBoardBackground.visible )
            {
                tempVisible = true;
                trailBoardBackground.visible = false;
            }

            mainView.visible = false;
            trailBoardBackground.width = fullWidth * 0.89
            trailBoardBackground.height = fullHeight * 0.89
            //trailBoardBackground.anchors.leftMargin = fullWidthX
            //trailBoardBackground.anchors.topMargin = fullHeightY
            //            if(titelImg.visible)
            //            {
            //                trailBoardBackground.anchors.centerIn = trailBoardBackground.parent;
            //            }else
            //            {
            //                trailBoardBackground.anchors.top = titelImg.bottom
            //            }
            mainView.width = Screen.width
            mainView.height =  Screen.desktopAvailableHeight - 1//-1 避免最大化的时候黑屏
            mainView.x = 0;
            mainView.y = 0;
            if(tempVisible)
            {
                trailBoardBackground.visible = true;
            }
            mainView.visible = true;
        }else{
            var tempVisibles = false;
            if(trailBoardBackground.visible )
            {
                tempVisibles = true;
                trailBoardBackground.visible = false;
            }
            mainView.visible = false;
            trailBoardBackground.width = midWidth
            trailBoardBackground.height = midHeight
            //trailBoardBackground.anchors.leftMargin = midWidthX
            //trailBoardBackground.anchors.topMargin = midHeightY
            //            if(titelImg.visible)
            //            {
            //                trailBoardBackground.anchors.centerIn = trailBoardBackground.parent;
            //            }else
            //            {
            //                trailBoardBackground.anchors.top = titelImg.bottom
            //            }

            mainView.width = Screen.width * 0.7
            mainView.height =  Screen.width*0.7/966.0*655.0 //Screen.height + 1

            if(tempVisibles)
            {
                trailBoardBackground.visible = true;
            }
            mainView.visible = true;
        }
        //updateBottomStatus();
        trailBoardBackground.jumpToPage(bottomToolbars.currentPage - 1);
        trailBoardBackground.setBackgrundImage();
        console.log("fullScreenTypefullScreenType",fullScreenType)
    }

    //    //全屏时显示logo
    //    Image{
    //        z: 1
    //        width: 60 * heightRate
    //        height: 72  * heightRate
    //        anchors.left: parent.left
    //        anchors.top: parent.top
    //        anchors.leftMargin: 10 * widthRate
    //        anchors.topMargin: 20 * heightRate
    //        source: "qrc:/images/fullLogo.png"
    //        visible: fullScreenType ? true : false
    //    }




    //课件列表model
    ListModel
    {
        id:coursewareListViewModel
    }
    //音视频列表model
    ListModel
    {
        id:audioVideoListViewModel
    }
    ListModel{
        id: audioModel

    }
    YMCourwareListView
    {
        id:mainImageView
        width: parent.width
        height:  parent.height-mainWindowTop.height
        clip: true
        anchors.top:mainWindowTop.bottom
        z:10000
    }
    YMMainWindowTopSetting
    {
        id:mainWindowTop
        window: mainView
        height:55 * heightRate
        width: parent.width
        z:1000
        opacity: 1
        isOpenedStates:true
        //visible: false
        onShowcoursewareListViewRectangle:
        {//判断是否显示课件列表页
            // mainImageView.controlcoursewareListViewRectangleShow();
        }
    }
    CloudTipView
    {
        id:cloudTipView
        anchors.centerIn: cloudTipView.parent
        z:10000000
        visible: false

    }

    //课程讲义主菜单
    CloudRoomMeun{
        id: cloudMenu
        z: 105
        visible: hideOrShow == true ? hasClicked == true ? isHomework  != 2 ? true : false : false : false;
        width: 220 * widthRate
        height: 50 * heightRate
        enabled: true
        anchors.top: mainWindowTop.bottom
        anchors.topMargin: 5 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter


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

        onSigExplainMode: {
            console.log("====onSigExplainMode====", planId,itemId, lessonId, questionId,itemType)
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
            console.log("*********pages************",pages,docId);
            trailBoardBackground.selectedMenuCommand(pages,mainView.planId,mainView.columnId);
            trailBoardBackground.jumpToPage(pages);
        }
    }



    //右边视频工具栏
    VideoToolBackground{
        id:videoToolBackground
        width: rightWidth + borderShapeLen
        height: rightHeight * 0.15
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 160 * heightRate//rightWidthX - borderShapeLen
        anchors.topMargin: 50 * heightRate//rightWidthY
        visible: false//fullScreenType ? false : true
        z:110
        onSigCloseWidget: {
            if(studentType == "TEA") {
                if(curriculumData.justTeacherOnline() ) {
                    popupWidget.setPopupWidget("close");
                }else {
                    trailBoardBackground.disconnectSockets();
                    externalCallChanncel.closeAlllWidget()
                }
            }
        }

        //获取题目失败重新做题
        onSigGetQuestionFailed: {
            // exercisePage.visible = true;
            exercisePage.isStartMake = false;
            exercisePage.isVisibleStartButton = true;
        }

        //批改成功
        onSigCorreSuccessed: {
            trailBoardBackground.correctCommand(mainView.planId,
                                                mainView.columnId,
                                                mainView.currentQuestionId,
                                                mainView.childQuestionId,
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
        onAllWriteTrail:
        {
            trailBoardBackground.setAllTrail(trailData);
        }
        //控制本地摄像头
        onSigOperationVideoOrAudio: {
            trailBoardBackground.setOperationVideoOrAudio(userId ,  videos ,  audios);
        }
        //控制学生进行音频、音视频
        onSigOnOffVideoAudio: {
            trailBoardBackground.setOnOffVideoAudio(videoType)
        }
        //用户授权
        onSigSetUserAuth: {
            trailBoardBackground.setUserAuth(userId,authStatus);
        }
        //选择课件显示当前课件
        onSigSetLessonShow: {
            trailBoardBackground.setLessonShow(message);
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
            audioPlayer.ymAudioPlayerManagerPlayFileByUrl(audioSoucre,audioName,0)
            //trailBoardBackground.setVideoStream("audio","play","00:00:00",audioSoucre);
        }
        //创建教室成功发送进入教室指令
        onSigCreateClassrooms: {
            trailBoardBackground.setStartClassRoom();
        }
        //最小化
        onSigMinFrom: {
            mainView.visibility = Window.Minimized;
        }
        //结束课程弹窗操作
        onSigGetCourse: {
            popupWidget.updateEndLesson(isDisplay,playerTime);
        }
        //讲义信息处理
        onSigSubjectInfo: {
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
        onSigHandoutInfos: {
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
        }

        //错因列表
        onSigErrorListed: {
            modifyHomework.updateErrorList(errorList);
        }
    }
    //音频播放
    YMAudioPlayer{
        id:audioPlayer
        visible: false
        z: 17000
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
        z:17000
        visible: false
        onSigClose: {
            videoToolBackground.selectedLessonIndex()
            trailBoardBackground.setVideoStream(vaType,controlType,times,address);
        }
        onSigPlayerMedia:  {
            trailBoardBackground.setVideoStream(vaType,controlType,times,address);
        }
    }


    //背景颜色
    Rectangle{
        anchors.fill: parent
        color:  "#eeeeee"
        z:11
        Image {
            anchors.fill: parent
            source: "qrc:/images/ckkj_bg@2x.png"
        }

        Image {
            id: titelImg
            source: "qrc:/images/pc_fixtitle_bg@2x.png"
            width: trailBoardBackground.width
            height: width / 16
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false //cloudMenu.visible
            anchors.top:parent.top
            //anchors.topMargin: 380 * widthRates
            onWidthChanged:
            {
                console.log(" id: titelImg",width,height)
            }

            Text {
                id: midTipTexts
                anchors.centerIn: parent
                text: qsTr("")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 21 * heightRate
                color: "#333333"
            }

            onVisibleChanged:
            {

                if(trailBoardBackground.width == midWidth)
                {
                    trailBoardBackground.anchors.leftMargin = midWidthX - 5 * heightRates
                    trailBoardBackground.anchors.topMargin = titelImg.visible ? midHeightYs : midHeightY;
                }else
                {

                }

            }
        }
        //画布
        TrailBoardBackground{
            id:trailBoardBackground
            width: midWidth
            height:  midHeight
            color: "red"
            visible: hasClicked == true ? isHomework == 3 || isHomework == 2  ? true : false : false
            anchors.centerIn: parent;
            //            Component.onCompleted:
            //            {
            //                if(!titelImg.visible)
            //                {

            //                    anchors.centerIn = parent;
            //                }else
            //                {
            //                    anchors.top = titelImg.bottom;
            //                }
            //            }

            //发送离开教室的姓名跟类型
            onSendExitRoomName: {
                videoToolBackground.exitClassUserId = userId;
                popupWidget.setExitRoomName(types , cname);
                videoToolBackground.setStayInclassroom();
                isStartLesson = false;
                exercisePage.isVisiblePage = (mainView.isMenuMultiTopic  ? true : false);
            }

            onSigStudentAppVersioned: {
                videoToolBackground.updatePlanStatus(status);
            }

            //第一次上课重选讲义信号
            onSigOneStartClassed: {
                isHomework = 2;
                videoToolBackground.updatePlanSelecte();
            }

            onSigSynQuestionSta: { //开始做题按钮同步状态
                console.log("=======onSigSynQuestionSta========",status)
                isStartQuestionStatus = status;
            }

            //打开关闭答案解析
            onSigIsOpenAnswers: {
                if(isOpenStatus){
                    knowledgesView.open();
                    knowledgesView.updateCheckQuestion(questionId,childQuestionId);
                }else{
                    knowledgesView.close();
                }
            }
            //接收学生端操作栏目的信号
            onSigSynColumns: {
                console.log("*******onSigSynColumns*********",planId,columnId)
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
                console.log("=====onSigCurrentTopic=====",planId,columnId,questionId,questionButStatus);
                videoToolBackground.getQuestionInfo(planId,columnId,questionId);
            }
            //显示空白页
            onSigDisplayerBlankPage:{
                isDisplayerAnswerCorrec = false;//设置不显示批改答案解析
                showQuestionHandlerView.displayerBlankPage();
                compositeTopicView.baseImages = "";
                compositeTopicView.visible = false;
                isBlanckPage = true;
                isHomework = 3;
                console.log("===onSigDisplayerBlankPage===",isBlanckPage,isHomework);
            }

            //返回上传做题图片路径
            onSigUploadWorkImage: {
                console.log("=====mainView::currentQuestionId=======",mainView.currentQuestionId)
                updateQuestionDo(mainView.planId,mainView.columnId,mainView.currentQuestionId,1);
                videoToolBackground.saveBaseImage(mainView.planId,mainView.columnId,mainView.currentQuestionId,
                                                  "",url,imgWidth,imgHeight);
                trailBoardBackground.autoConvertImage(exercisePage.currentPage - 1,url,imgWidth,imgHeight, mainView.planId,mainView.columnId,mainView.currentQuestionId);
            }

            //课件页加载完成后请求获取音视频课件
            onSigLoadingLesson: {
                //console.log("=====onSigLoadingLesson=======");
                videoToolBackground.requstLessonInfo();
            }

            onSigUserName: {
                videoToolBackground.bUserId = userId;
                popupWidget.setUserName(userName)
                //console.log("onSigUserName>>",userId,userName)
            }

            onSigCurrentCourseTimer: {
                popupWidget.setCurrentTime(parseInt(currentTimer / 60));
                //console.log("====",currentTimer)
            }

            //当前页
            onSigChangeCurrentPages: {
                bottomToolbars.currentPage = pages;
                exercisePage.currentPage = pages;
                console.log("======onSigChangeCurrentPages=========",pages)
            }
            //总页数
            onSigChangeTotalPages: {
                bottomToolbars.totalPage = pages;
                exercisePage.totalPage = pages;
                console.log("======onSigChangeTotalPages=========",pages)
            }
            //开始上课
            onSigStartClassTimeData: {
                toobarWidget.handlEraserImageColor(-1);
                brushWidget.setPenColor();
                brushWidget.setPenWidth();
                videoToolBackground.setStartClassTimeData(times);
            }
            //学生B退出信号
            onSigBExitClass: {
                videoToolBackground.setBStatus();
            }

            onSigPromptInterfaceHandl: {
                console.log("=====onSigPromptInterfaceHandl======",inforces)
                if(inforces == "68") {
                    videoToolBackground.handlPromptInterfaceHandl(inforces);
                    return;
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
                // exercisePage.visible = false;
                toobarWidget.disableButton = true;
                isCommitAnswer = true;
                showMessageTips("学生正在提交练习，请稍候...");
                videoToolBackground.getAnalysisQuestionAnswer(lessonId,questionId,planId,columnId);
            }
        }

        Rectangle{
            id: homeworkItem
            visible: isHomework != 2 ? true : false
            width: trailBoardBackground.width
            height:  trailBoardBackground.height
            color:  "transparent"
            //            anchors.left: parent.left
            //            anchors.top: parent.top
            //            anchors.leftMargin: midWidthX - 5  * heightRates
            //            anchors.topMargin: midHeightY + 20  * heightRates
            anchors.centerIn: parent

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    mainImageView.hideRectangle();
                    if(mainWindowTop.isOpenedStates)
                    {
                        mainWindowTop.isOpenedStates =  !mainWindowTop.isOpenedStates;
                    }
                }
            }

            //5大题型：单选、判断、多选、简答、填空
            ShowQuestionHandlerView{
                id: showQuestionHandlerView
                anchors.fill: parent
                onVisibleChanged:
                {
                    if(trailBoardBackground.visible)
                    {
                        showQuestionHandlerView.visible = false;
                    }
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
                        filePaths = "file:///" + filePath;
                        var fileName = filePath.substring(filePath.lastIndexOf("/")+1,filePath.length);
                        trailBoardBackground.uploadWorkImage(mainView.planId,
                                                             mainView.columnId,
                                                             mainView.orderNumber,
                                                             fileName,
                                                             filePath,
                                                             imgWidth,
                                                             imgHeight);
                        console.log("======imgHeight======",imgWidth,imgHeight)
                        trailBoardBackground.lodingPlanImage(filePaths,imgWidth,imgHeight);
                        exercisePage.disabledButton = true;

                        if(modifyHomework.isErrorList() == 0){
                            videoToolBackground.getErrorList(mainView.planId);
                        }
                        return;
                    }
                    if(status == 2 || status == 4){
                        filePaths = filePath;
                        isHomework = 3;
                        trailBoardBackground.lodingPlanImage(filePaths,imgWidth,imgHeight);
                    }
                    console.log("=======status==111111========",status);
                }
            }

            //综合题
            CloudCompositeTopicView{
                id: compositeTopicView
                visible: isHomework != 2 ? true : false
                width:  trailBoardBackground.width
                height: fullScreenType ? fullHeight : trailBoardBackground.height
                onHeightChanged:
                {
                    console.log("compositeTopicView,height",compositeTopicView.height,trailBoardBackground.height);
                }

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
                    mainView.childQuestionId = childQuestionId;
                    mainView.currentScore = score;
                    mainView.correctType = correctType;
                    mainView.errorReason = errorReason;
                }

                onSigCorrect:{
                    showQuestionHandlerView.visible = false;
                    compositeTopicView.visible = true;
                    //topicBrowsView.visible = false;
                    console.log("======compositeTopicView::=======",isMenuMultiTopic,filePath,status,imgWidth,imgHeight);

                    var filePaths = "";
                    if(status == 1){
                        isHomework = 3;
                        filePaths = "file:///" + filePath;
                        var fileName = filePath.substring(filePath.lastIndexOf("/")+1,filePath.length);
                        trailBoardBackground.uploadWorkImage(mainView.planId,
                                                             mainView.columnId,
                                                             mainView.orderNumber,
                                                             fileName,
                                                             filePath,
                                                             imgWidth,
                                                             imgHeight);
                        trailBoardBackground.lodingPlanImage(filePaths,imgWidth,imgHeight);
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
                    console.log("====CloudTopicBrowsView=======")
                    showQuestionHandlerView.clipImage(topicBrowsView.clipBrowsViewImage());
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
                        // exercisePage.visible = true;
                    }
                }
            }
        }

        //开始练习栏
        CloudExercisePageView{
            id: exercisePage
            z: 200000
            width: parent.width//240 * widthRate //midWidth
            height: 35  * widthRate
            //   visible: hasClicked == true ?  fullScreenType ? false : true : false//true

            visible: hasClicked == true ?  true : false//true

            //anchors.left: parent.left
            anchors.bottom: parent.bottom
            //anchors.leftMargin: (parent.width + (leftMidWidth + 12.0 * leftMidWidth / 66) - (rightWidth + borderShapeLen) -width) * 0.5
            anchors.bottomMargin:  12  * fullHeights / 900
            anchors.horizontalCenter: parent.horizontalCenter

            //            onVisibleChanged:
            //            {
            //                visible = hasClicked == true ?  fullScreenType ? false : true : false
            //                console.log(" onVisibleChanged: onVisibleChanged:",visible,hasClicked,fullScreenType)
            //            }

            onSigStartExercise: {
                console.log("========onSigStartExercise========",status);
                if(status){
                    if(videoToolBackground.getIsOneStartLesson()){
                        tipExercise.visible = true;
                    }
                    toobarWidget.disableButton = false;
                    //exercisePage.isVisiblePage = false;
                    addQuestionDo(mainView.planId,mainView.columnId ,mainView.currentQuestionId ,0);
                    trailBoardBackground.startExercise(mainView.currentQuestionId,mainView.planId,mainView.columnId);
                }else{
                    tipStopExercise.visible = true;
                    // exercisePage.visible = false;
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
                    if(isMultiTopic && trailBoardBackground.visible == false ){
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
            x: rightWidthX - borderShapeLen  - 5 - width
            y: midHeightY
            height: homeworkItem.height
            onVisibleChanged:
            {
                visible = false;
            }
            onClosed: {
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
                mainView.childQuestionId = childQuestionId;
                mainView.errorId = errorTypeId;
            }
        }

        //答案解析
        KnowledgesView{
            id: knowledgesView
            z: 3
            x: mainView.width - width
            y: midHeightY
            height: homeworkItem.height
            onClosed: {
                console.log("========answerStatus========",answerStatus)
                trailBoardBackground.closeAnswerParsing(planId,columnId,currentQuestionId);
            }
            onSigOpenAnserParsing: {
                trailBoardBackground.openAnswerParsing(mainView.planId,questionId,mainView.columnId,childQuestionId);
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


        //底部工具栏
        BottomToolbars{
            id:bottomToolbars
            width: parent.width//240 * widthRate //midWidth
            height: 35 * heightRate
            visible: hasClicked == true ?  fullScreenType ? false : (isHomework == 1 ? false : true) : false//true
            //anchors.left: parent.left
            anchors.bottom: parent.bottom
            //anchors.leftMargin: (parent.width + (leftMidWidth + 12.0 * leftMidWidth / 66) - (rightWidth + borderShapeLen) -width) * 0.5
            anchors.bottomMargin:  5  * fullHeights / 900
            anchors.horizontalCenter: parent.horizontalCenter
            disableAnswer: (isHomework == 3 || isHomework == 4) ? ( isDisplayerAnswerCorrec ? true : false) : false
            disableCorrec: isHomework == 3 && (mainView.columnType == 2) ? ( isDisplayerAnswerCorrec ? true : false) : false
            //            onVisibleChanged:
            //            {
            //                if(hasClicked == true)
            //                {
            //                    visible = false;
            //                }
            //            }
            //答案解析
            onSigAnswer: {
                answerStatus = !answerStatus;
                console.log("========******answerStatus******==========",answerStatus,knowledgesView.visible)
                if(answerStatus){
                    knowledgesView.open();
                    trailBoardBackground.openAnswerParsing(mainView.planId,currentQuestionId,columnId,childQuestionId);
                }else{
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
                trailBoardBackground.jumpToPage(pages);




                //videoToolBackground.requstLessonInfo();
            }

            //添加分页
            onSigAddPage: {
                //console.log("===addPage===")
                trailBoardBackground.addPage();
            }
            //删除分页
            onSigRemoverPage: {
                //console.log("===RemoverPage===")
                popupWidget.setPopupWidget("removerPage");
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


        //全屏按键
        MouseArea{
            id:fullScreenBtn
            width: 35 * widthRate
            height: 35 * widthRate
            anchors.left: bottomToolbars.right
            anchors.leftMargin: 25 * heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1  * fullHeights / 900
            hoverEnabled: true
            visible: isHomework  == 1 || isHomework == 3 ? false : true
            onVisibleChanged: {
                visible = true;
            }
            Image {
                id: fullScreenBtnImage
                anchors.left: parent.left
                anchors.top: parent.top
                width: parent.width
                height: parent.height
                source: fullScreenType ? (parent.containsMouse ? "qrc:/images/cr_btn_xiaopingmu_sed@2x.png" :  "qrc:/images/cr_btn_xiaopingmutwox.png" ) : (parent.containsMouse ? "qrc:/images/fullscreen@2x.png" : "qrc:/images/fullscreentwox.png")
            }

            onClicked: {
                fullScreenBtn.focus = true;
                fullScreenType = !fullScreenType;
                setFullScrreen(fullScreenType);
            }
        }

        //工具栏
        ToobarWidget{
            id:toobarWidget
            width: leftMidWidth + 12.0 * leftMidWidth / 66
            height: leftMidHeight + 12.0  * leftMidWidth  / 66
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: leftWidthX -  6.0 * leftMidWidth  / 66
            anchors.topMargin: leftWidthY - 6.0  * leftMidWidth  / 66
            visible:  false
            onSigSendFunctionKey: {
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
            anchors.leftMargin: -15 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin: topMargins + 80 * fullHeight / 900//80 * fullHeights / 900
            width: 160 * widthRate
            height: 186  * heightRate
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
            anchors.leftMargin: -15 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin: 58 * 3 * leftMidWidths + 40 *   leftMidWidths//topMargins + 180 * fullHeights / 900//220 * heightRate
            width: 70 * widthRate
            height: 160  * heightRate
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
            anchors.leftMargin: -15 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin: 58 * 4 * leftMidWidths + 50 *   leftMidWidths
            width: 297 * widthRate
            height: 261  * heightRate
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
            anchors.leftMargin: -15 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin: 58 * 6 * leftMidWidths + 50 * leftMidWidths
            width: 80 * widthRate
            height: 105  * heightRate
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
            anchors.leftMargin: -15 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin:  58 * 7 * leftMidWidths + 60 *   leftMidWidths
            width: 130 * widthRate
            height: 63  * heightRate
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

        //设备检测
        DetectionNetwork{
            id:detectionNetwork
            anchors.left: trailBoardBackground.left
            anchors.top:   trailBoardBackground.top
            anchors.topMargin:  trailBoardBackground.height / 2  - 125  * heightRate
            anchors.leftMargin:  trailBoardBackground.width / 2 - 120 * widthRate
            width: 200 * widthRate
            height: 300  * heightRate
            z:18
            visible: false
            focus: false
            onFocusChanged: {
                if(detectionNetwork.focus) {
                    detectionNetwork.currentAisle = curriculumData.getUserChanncel();
                    detectionNetwork.visible = true;
                }else {
                    detectionNetwork.visible = false;
                }
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
                trailBoardBackground.setAisle(aisle);
                externalCallChanncel.changeChanncel();
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
            visible: false
            onVisibleChanged:
            {
                visible = false;
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
                if(way == "1"){
                    videoToolBackground.initChancel();
                    trailBoardBackground.setStartClassRoom();
                }
                if(way == "2"){
                    videoToolBackground.initChancel();
                }
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
                trailBoardBackground.teaFinishClassroom();
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
                    trailBoardBackground.setApplyExitStart(false);
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
            trailBoardBackground.setOnOffVideoAudio("");
            var isVideo = videoToolBackground.getIsVideo();
            trailBoardBackground.setOnOffVideoAudio(isVideo);
        }
    }

    YMHomeWorkManagerAdapter{
        id: coludClassMgr
    }

    function getQuestionItems(questionItemsData,answerArray,photosArray,browseStatus){
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
        isDisplayerAnswerCorrec = true;

        //console.log("========photosArray==========",JSON.stringify(photosArray),questionStatus);
        //console.log("#######answerArray#########", JSON.stringify(answerArray));
        var baseImages = "";
        if(questionItemsData.baseImage != null ){//&& questionStatus == 2 || questionStatus == 4) {
            baseImages = (questionItemsData.baseImage.imageUrl == null || questionItemsData.baseImage.imageUrl =="") ? "" : questionItemsData.baseImage.imageUrl;
            //            if(baseImages == ""){
            //                browseStatus = true;
            //            }
        }

        console.log("**********browseStatus::Data**************",browseStatus,baseImages,type)

        isBlanckPage = false;
        isHomework = 1;
        console.log("***********main::getQuestionItems********",mainView.orderNumber,isHomework,questionStatus,browseStatus,type,topicModel,isMenuMultiTopic);

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

        topicModel = (browseStatus ? 2 : 1);
        topicBrowsView.setStatus(false);


        if(type == 6){
            showQuestionHandlerView.visible = false;
            topicBrowsView.visible = false;

            //综合题
            if(browseStatus){//学生提交作业显示截图
                compositeTopicView.visible = false;
                topicBrowsView.visible = true;
                topicBrowsView.photosData = photosArray;
                topicBrowsView.dataModel = questionItemsData;
                topicBrowsView.childQuestionInfoModel = childQuestionInfo;
                topicBrowsView.setStatus(true);
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
        if(message.indexOf("一页")!=-1)
        {
            toopBracundImageText.text = message;
            toopBracund.visible = false;
            toopBracund.visible = true;
        }
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
        exercisePage.isVisibleStartButton = isStartLesson ?  (status == true ? false : true)  : false; //true//
        exercisePage.isVisiblePage = mainView.isMenuMultiTopic ? (isStartQuestionStatus ? false : true ) : false; //true;//
        exercisePage.isStartMake=  isStartQuestionStatus; // false;//
        //return;
        console.log("*******updateBottomStatus********",isStartLesson,fullScreenType,isHomework,status,isBlanckPage,isCommitAnswer)
        if(fullScreenType){
            // exercisePage.visible = false;
            bottomToolbars.visible = false;
            return;
        }

        if(mainView.columnType == 1 || mainView.columnType == 0){
            // exercisePage.visible = false;
            bottomToolbars.visible = true;
            console.log("***********columnType*************",columnType);
            return
        }
        if(status){
            // exercisePage.visible = false;
            bottomToolbars.visible = true;
        }else{
            if(isBlanckPage){
                //  exercisePage.visible = false;
                bottomToolbars.visible = true;
                isBlanckPage = false;
                return;
            }

            if(isCommitAnswer){
                // exercisePage.visible = false;
                bottomToolbars.visible = true;
                isCommitAnswer = false;
                return;
            }

            if(isHomework == 2 || isHomework == 3){
                // exercisePage.visible = false;
                bottomToolbars.visible = true;
                return
            }
            if(isHomework == 1){
                // exercisePage.visible = true;
                bottomToolbars.visible = false;
                return
            }

            if(mainView.columnType == 0 || mainView.columnType == 1){
                // exercisePage.visible = false;
                bottomToolbars.visible = true;
                return;
            }

            // exercisePage.visible = (exercisePage.currentPage -1) <= 1 ? false : true //true;
            bottomToolbars.visible = (exercisePage.currentPage -1) <= 1 ? true : false;
        }
    }


}

