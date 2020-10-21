﻿import QtQuick 2.5
import TrailBoard 1.0
import MxResLoader 1.0
import QtQuick.Dialogs 1.2
import LoadInforMation 1.0
import ScreenshotSaveImage 1.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import "./Configuuration.js" as Cfg

Rectangle {
    id:trailBoardBackground
    color: "transparent"

    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property bool  isMaxWidget: false
    property string tipName: "";
    property bool hasShowCutSCreen: false;
    property int loadImgWidth: 0;//加载图片宽度
    property int loadImgHeight: 0;//加载图片高度
    property bool isClipImage: false;//是否时截图课件
    property bool isUploadImage: false;//是否是传的图片
    property double currentOffsetY: 0;//当前滚动条的坐标
    property bool isLongImage: false;//是否是长图
    property double currentImageHeight: 0.0;

    //适配截图
    property double clipWidthRate: 1.0;
    property double clipHeightRate: 1.0;


    //长图路径
    property string imagePath: "";// "file:///C:/Users/Administrator/Pictures/Feedback/debugImage.png"

    //几何图形
    property var itemPolygonPanelFrame: null
    property int  itemPolygonPanelFrameData: 0

    //判断是否允许操作
    property bool isHandl: true

    //学生类型
    property  string  studentType: curriculumData.getCurrentUserType()

    //设置学生退出教室
    function setApplyExitStart(status){
        if(status){
            trailBoard.handlLeaveClassroom(status);
        }else{
            trailBoard.handlLeaveClassroom(status);
        }
    }

    //修改验签状态
    function updateCourseOssSignStatus(status){
        trailBoard.updateOssSignStatus(status);
    }

    //设置清屏操作
    function setClearCreeon(){
        trailBoard.clearScreen();
    }

    //设置开始上课
    function setStartClassRoom(){
        trailBoard.startClassBegin();
    }

    //设置当前是老师T
    function setTeacherType(type){
        //console.log("setTeacherType223", type);
        trailBoard.setTeacherStatus(type);
    }

    //掉线重连提醒
    function setContinueLesson(){
        trailBoard.startClassBegin();
        showMessageTips("学生进入教室,开始上课!");
    }

    //发送延迟信息
    function setSigSendIpLostDelays( infor){
        trailBoard.setSigSendIpLostDelay( infor);
    }

    //主动退出
    function  setSelectWidgetType( types){
        trailBoard.selectWidgetType( types);
    }

    //申请结束课程
    function agreeEndLesson(types){
        trailBoard.agreeEndLesson(types);
    }

    //退出程序
    function setExitProject(){
        trailBoard.temporaryExitWidget();
    }

    //主动断开连接
    function  disconnectSockets(){
        trailBoard.disconnectSocket(false);
    }

    //增加一页
    function addPage(){
        trailBoard.addPage();
    }

    //删除一页
    function removerPage(){
        trailBoard.deletePage();
    }

    //撤销操作
    function undo(){
        trailBoard.undo();
    }

    //处理学生申请翻页
    function setApplyPage(status){
        trailBoard.handlePageRequest(status);
    }

    //控制本地摄像头
    function setOperationVideoOrAudio(userId ,  videos ,  audios) {
        trailBoard.setOperationVideoOrAudio(userId ,  videos ,  audios);
    }

    //音频、音视频切换
    function setOnOffVideoAudio(videoType){
        if(videoType == ""){
            return;
        }
        //console.log("===setOnOffVideoAudio====",videoType)
        trailBoard.setOpenSutdentVideo(videoType);
    }

    //发送给学生音频，视频播放
    function setVideoStream(types,status,times,address){
        trailBoard.setVideoStream(types,status,times,address);
    }

    //设置画笔颜色
    function setPenColors(penColors) {
        trailBoard.setPenColor(penColors);
    }
    //改变画笔尺寸
    function changeBrushSizes(penWidths) {
        trailBoard.changeBrushSize(penWidths);
    }
    //设置鼠标样式
    function setCursorShapeType(types) {
        trailBoard.setCursorShapeTypes(types);

    }

    //设置上传图片
    function setUpLoadPicture(){
        fileDialog.open();
    }

    //截图
    function  setScreenShotPicture(){
        //screenshotSaveImage.grabImage(trailBoardBackground);
        if(hasShowCutSCreen == true)
        {
            return;
        }
        screenshotSaveImage.grabImage(trailBoardBackground);
        hasShowCutSCreen = true;
    }

    //清除截图状态
    function cancelScreenPicture(){
        digPictures.visible = false;
        hasShowCutSCreen = false;
    }

    //跳转页面
    function jumpToPage(pages){
        trailBoard.goPage(pages );
    }

    //发送评价
    function sendEvaluateContent( contentText1 ,  contentText2 ,  contentText3){
        trailBoard.setSendTopicContent( contentText1 ,  contentText2 ,  contentText3);
    }
    //设置留在教室
    function setStayInclassroom(){
        trailBoardBackground.sigPromptInterfaceHandl("22");
    }
    //切换线路
    function setChangeOldIpToNews(){
        trailBoard.setChangeOldIpToNew();
    }

    //切换通道
    function setAisle(aisle){
        trailBoard.setAisle(aisle);
        showMessageTips("正在切换通道，请稍后...");
    }
    //提交工单提醒
    function showCommitWorkMessage(){
        showMessageTips("您的技术工单已提交!");
    }

    //设置用户权限
    function setUserAuth(userId,authStatus){
        trailBoard.setUserAuth(userId,authStatus);
    }

    //离线操作通道提醒
    function setTipsAisle(){
        showMessageTips("当前是自由操作模式!");
        sigPromptInterfaceHandl("22");
    }

    //显示删除课件提醒
    function setLessonShow(message){
        trailBoard.setCourseware(message);
    }
    //B学生进入教室处理
    function setBgotoClass(status){
        trailBoard.handlEnterClassroom(status);
    }

    //收回分页权限
    function setRecoverPage(){
        trailBoard.setRecoverPage();
    }
    /******云教室命令********/
    //点击栏目发送命令
    function selectedMenuCommand(pageIndex,planId,cloumnId){
        trailBoard.selectedMenuCommand(pageIndex,planId,cloumnId);
    }

    //点击讲义发送命令
    function lectureCommand(lectureObjecte){
        trailBoard.lectureCommand(lectureObjecte);
    }

    //发送练习题命令
    function startExercise(questionId,planId,columnId){
        trailBoard.startExercise(questionId,planId,columnId);
    }

    //获取课件当前页
    function getCoursePage(docId){
        return trailBoard.getCursorPage(docId);
    }

    //提交练习题命令
    function commitExercise(questionId,planId,columnId){
        trailBoard.commitExercise(questionId,planId,columnId);
    }

    //发送停止练习命令
    function stopExercise(questionId){
        trailBoard.stopExercise(questionId);
    }

    //老师结束练习命令
    function stopQuestion(questionId){
        trailBoard.stopQuestion(questionId);
    }

    //打开答案解析
    function openAnswerParsing(planId,questionId,columnId,childQuestionId){
        trailBoard.openAnswerAnalysis(planId,columnId,questionId,childQuestionId);
    }

    //关闭答案解析
    function closeAnswerParsing(planId,columnId,questionId){
        trailBoard.closeAnswerAnalysis(planId,columnId,questionId);
    }

    //批改命令 openCorrect
    function correctCommand(planId,columnId,questionId,childQuestionId ,correctType,score,errorReason,errorTypeId){
        trailBoard.correctCommand(planId,columnId,questionId,childQuestionId ,correctType,score,errorReason,errorTypeId);
    }

    //打开批改面板
    function openCorrect(planId,columnId,questionId){
        trailBoard.openCorrect(planId,columnId,questionId);
    }

    //关闭批改面板
    function closeCorrect(planId,columnId,questionId){
        trailBoard.closeModifyPanle(planId,columnId,questionId);
    }

    //传递自动转图片之后发送的讲义图片命令
    function autoConvertImage(pageIndex,imageUrl,imageWidth,imageHeight, planId, cloumnId, quetisonId) {
        trailBoard.autoConvertImage(pageIndex,imageUrl,imageWidth,imageHeight,planId,cloumnId,quetisonId);
    }

    //长图滚动函数
    function scrollImage(scrollY){
        trailBoard.updataScrollMap(scrollY);
    }

    //老师交麦 1 交麦 0 取消交麦
    function teacherHandMic(status)
    {
        trailBoard.sendUpperMic(curriculumData.getCCId(),"1", status);
    }

    function ccHandMic(status)
    {
        trailBoard.sendUpperMic(curriculumData.getCCId(),"2", status);
    }

    //当前页数
    signal sigChangeCurrentPages(int pages)

    //总页数
    signal sigChangeTotalPages(int pages)

    //开始上课
    signal sigStartClassTimeData(string times);

    //控制界面信号
    signal sigPromptInterfaceHandl(string inforces);

    //发送离开教室的姓名跟类型
    signal sendExitRoomName(string types ,string cname,string userId);

    //视频控制流
    signal sigVideoAudioUrls( string avType,string startTime ,string controlType ,string avUrl );

    //获取用户名信号
    signal sigUserName(string userName,string userId);

    //学生B退出教室
    signal sigBExitClass();

    //当前上课总时长
    signal sigCurrentCourseTimer(int currentTimer);

    signal sigAnalysisQuestionAnswers(var lessonId,var questionId,var planId,var columnId);//学生提交练习命令
    signal sigUploadWorkImage(var url,var imgWidth,var imgHeight); //作业上传图片成功信号
    signal sigCurrentTopic(var planId,var columnId,var questionId,var questionButStatus);//翻页题目信息信号
    signal sigDisplayerBlankPage();//显示空白页信号
    signal sigPlanSynchronize(var lessonId,var planId,var itemId);//讲义同步
    signal sigColumnSynchronize(var planId,var itemId); //栏目同步
    signal sigItemSynchronize();    //栏目同步
    signal sigIsOpenCorrects(var isOpenStatus);    //打开关闭批改面板
    signal sigIsOpenAnswers(var isOpenStatus,var questionId,var childQuestionId);    //打开关闭答案解析
    signal sigSynColumns(var planId,var columnId);    //同步菜单栏选择
    signal sigOneStartClassed();    //第一次开课重置讲义
    signal sigSynQuestionSta(var status);//开始做题按钮状态同步
    signal sigStudentAppVersioned(var status,var canImportReportImg);//学生使用的版本
    signal sigGetCoursewareFaills();//老课件获取失败提醒并重新获取信号
    signal sigInterNetworks(var networkStatus);//当前是无线还是有线切换

    signal sigGetbackAisles();//切换为原通道信号
    //响应是否同意上麦权限
    signal sigReponseMicrophones(var status);
    signal sigOtherGetMicOrders();//响应别人获得麦克风权限
    //申请上麦信号
    signal sigRequestMicphone(var status,var userId);

    signal sigListenMicophones();//老师退出或者异常退出，且学生仍留在教室信号
    signal sigDisapperListenMicophones(); //隐藏对话框: "老师已退出, 学生停留在教室, 是否立即开始与学生沟通?"

    //开始批改界面
    signal sigCorrects(var questionData);

    //设置课后作业导入不可用
    signal sigCancleInsertHomeWorks();

    signal sigShowAllCourseImgs(var imgArray,var contentArray,var courseIds);

    //评价主动退出教室命令
    function teaFinishClassroom(currentIsAuditionLessons){
        if(currentIsAuditionLessons)
        {
            trailBoard.setSendEndLesson();
        }

        trailBoard.finishClassRoom();
    }

    //设置几何图形
    function setDrawPolygon(polygons) {
        if(trailBoardBackground.itemPolygonPanelFrame != null) {
            return;
        }

        if(polygons == 1) {
            geometricFigureBakcground.visible = true;
            trailBoardBackground.itemPolygonPanelFrame = Qt.createQmlObject(mxResLoader.ellipsePanelFrame,geometricFigureBakcground);
            trailBoardBackground.itemPolygonPanelFrame.x = 0;
            trailBoardBackground.itemPolygonPanelFrame.y  = 0;
            trailBoardBackground.itemPolygonPanelFrame.width = geometricFigureBakcground.width;
            trailBoardBackground.itemPolygonPanelFrame.height = geometricFigureBakcground.height;
            trailBoardBackground.itemPolygonPanelFrame.setPolygonPanelType();
            trailBoardBackground.itemPolygonPanelFrame.sigClearItemPolygonPanelFrame.connect(trailBoardBackground.clearItemPolygonPanelFrame);
            trailBoardBackground.itemPolygonPanelFrame.sigOkItemPolygonPanelFrame.connect(trailBoardBackground.okItemPolygonPanelFrame);
        }
        if(polygons == 2) {
            geometricFigureBakcground.visible = true;
            trailBoardBackground.itemPolygonPanelFrame = Qt.createQmlObject(mxResLoader.polygonPanelFrame,geometricFigureBakcground);
            trailBoardBackground.itemPolygonPanelFrame.x = 0;
            trailBoardBackground.itemPolygonPanelFrame.y  = 0;
            trailBoardBackground.itemPolygonPanelFrame.width = geometricFigureBakcground.width;
            trailBoardBackground.itemPolygonPanelFrame.height = geometricFigureBakcground.height;
            trailBoardBackground.itemPolygonPanelFrame.setPolygonPanelType(polygons);
            trailBoardBackground.itemPolygonPanelFrame.sigClearItemPolygonPanelFrame.connect(trailBoardBackground.clearItemPolygonPanelFrame);
            trailBoardBackground.itemPolygonPanelFrame.sigOkItemPolygonPanelFrame.connect(trailBoardBackground.okItemPolygonPanelFrame);

        }
        if(polygons == 3) {
            geometricFigureBakcground.visible = true;
            trailBoardBackground.itemPolygonPanelFrame = Qt.createQmlObject(mxResLoader.polygonPanelFrame,geometricFigureBakcground);
            trailBoardBackground.itemPolygonPanelFrame.x = 0;
            trailBoardBackground.itemPolygonPanelFrame.y  = 0;
            trailBoardBackground.itemPolygonPanelFrame.width = geometricFigureBakcground.width;
            trailBoardBackground.itemPolygonPanelFrame.height = geometricFigureBakcground.height;
            trailBoardBackground.itemPolygonPanelFrame.setPolygonPanelType(polygons);
            trailBoardBackground.itemPolygonPanelFrame.sigClearItemPolygonPanelFrame.connect(trailBoardBackground.clearItemPolygonPanelFrame);
            trailBoardBackground. itemPolygonPanelFrame.sigOkItemPolygonPanelFrame.connect(trailBoardBackground.okItemPolygonPanelFrame);
        }
        if(polygons == 4) {
            geometricFigureBakcground.visible = true;
            trailBoardBackground.itemPolygonPanelFrame = Qt.createQmlObject(mxResLoader.polygonPanelFrame,geometricFigureBakcground);
            trailBoardBackground.itemPolygonPanelFrame.x = 0;
            trailBoardBackground.itemPolygonPanelFrame.y  = 0;
            trailBoardBackground.itemPolygonPanelFrame.width = geometricFigureBakcground.width;
            trailBoardBackground.itemPolygonPanelFrame.height = geometricFigureBakcground.height;
            trailBoardBackground.itemPolygonPanelFrame.setPolygonPanelType(polygons);
            trailBoardBackground.itemPolygonPanelFrame.sigClearItemPolygonPanelFrame.connect(trailBoardBackground.clearItemPolygonPanelFrame);
            trailBoardBackground.itemPolygonPanelFrame.sigOkItemPolygonPanelFrame.connect(trailBoardBackground.okItemPolygonPanelFrame);

        }
    }

    //清楚几何图形的指针
    function clearItemPolygonPanelFrame() {
        if(trailBoardBackground.itemPolygonPanelFrame != null) {
            trailBoardBackground.itemPolygonPanelFrame.destroy();
            trailBoardBackground.itemPolygonPanelFrame = null;
            geometricFigureBakcground.visible = false;
        }
    }

    //确定几何图形的指针
    function okItemPolygonPanelFrame(contents ) {
        if(trailBoardBackground.itemPolygonPanelFrame != null) {
            trailBoard.drawLocalGraphic(contents,trailBoardBackground.height,topicListView.y);
            trailBoardBackground.itemPolygonPanelFrame.destroy();
            trailBoardBackground.itemPolygonPanelFrame = null;
            geometricFigureBakcground.visible = false;
        }
    }

    //获取当前课程总时间
    function getCurrentCourse(){
        trailBoard.getCurrentCourseTotalTimer();
    }

    //加载讲义图片
    function lodingPlanImage(imageUrl,imgWidth,imgHeigth){
        button.y = 0;
        if(disibleOss)
        {
            trailBoard.getOffsetImage(imageUrl,currentOffsetY);
            trailBoard.getOffSetImage(0,currentOffsetY,1.0);
        }else{
            trailBoard.getOssSignUrl(imageUrl);
        }
        trailBoard.setCurrentImgUrl(imageUrl);
        //console.log("=========imageUrl=============",disibleOss,imageUrl,currentOffsetY,imgHeigth);
    }

    //发送url网址
    function setInterfaceUrl(urls){
        animePlayBroundImage.source = "";
        animePlayBroundImage.paused = true;
        if(urls.length > 0) {
            animePlayBroundImage.source = trailBoard.justImageIsExisting(urls);
            trailBoard.setInterfaceUrls(urls);
            animePlayBround.focus = true;
            animePlayBroundImage.paused = false;
        }else {
            trailBoard.focus = true;
        }
    }

    function setListenLessonTips(){
        showMessageTips(qsTr("学生 ") + tipName + qsTr(" 未注意听讲!"));
    }

    signal sigSetBmgUrls(var urls,var widths, var heights);
    signal sigSetBmgVisibles(var visibles);
    signal sigRemoveBmgUrls();
    signal sigHideCourseView(var visibles);
    function setBmgUrl(urls,widths,heights)
    {
        bmgImages.source = "";
        bmgImages.width = widths;
        bmgImages.height = heights;
        bmgImages.source = urls;

        sigSetBmgUrls(urls,widths,heights);
    }
    function setBmgVisible(visibles)
    {
        bmgImages.visible = visibles;
        sigSetBmgVisibles(visibles);
    }
    function removeBmgUrl()
    {
        bmgImages.source = "";
        sigRemoveBmgUrls();
    }

    //设置滚动条的显示状态
    function setButtonStatus()
    {
        if(currentOffsetY  != 0){
            button.y  =  -(scrollbar.height * currentOffsetY * trailBoardBackground.height / currentImageHeight);
        }
    }

    function changeScoreBarVisibles(visibles)
    {
        scrollbar.visible = visibles;
    }

    signal setBackgrundImages(var loadImgHeight,var loadImgWidth,var fullScreenType, var isClipImage,var isUploadImage,var isLongImage,var trailBoardBackgroundWidth,var trailBoardBackgroundHeigth,var columnType);
    //背景图
    Rectangle{
        id:topicListView//bakcImages
        anchors.fill: parent
        clip: true
        color:"#ffffff"

        property bool isLoading: false;

        Timer{
            id: loadingTimer
            interval: 10000
            repeat: false
            onTriggered: {
                imageSourceChageRectangle.visible= false;
            }
        }

        //背景图片显示
        Image {
            id: bmgImages
            width: parent.width
            height: parent.height
            smooth: true
            mipmap: true
            clip: true
            z: 10
            visible: false

            onProgressChanged: {
                if(source == ""){
                    return;
                }

                imageSourceChageRectangle.visible = true;
                loadingTimer.restart();
                if(bmgImages.progress < 1) {
                    parent.isLoading = true;
                }else {
                    loadingTimer.stop();
                    imageSourceChageRectangle.visible= false;
                    if(progress == 1 && parent.isLoading){
                        parent.isLoading = false;
                    }
                }
            }

            onStatusChanged: {
                if(status == Image.Error) {
                    var tempString = "{\"domain\":\"system\",\"command\":\"statistics\",\"content\":{\"type\":\"exception\",\"coursewareException\":{ \"url\":\"";
                    if(tempString.indexOf(".jpg") == -1 && tempString.indexOf(".png") == -1)
                    {
                        tempString +=  bmgImages.source + "\",\"error\":\"Image Loading Error\",\"status\": \"" +status+"\"}}}";
                    }else {
                        tempString += bmgImages.source + "\",\"error\":\"Image Path Cannot Open\",\"status\": \"" +status+"\"}}}";
                    }
                    //console.log("status == Image.Error",tempString)
                    imageSourceChageRectangle.visible= false;
                    showMessageTips("加载失败,请重新操作...");
                    trailBoard.uploadLoadingImgFailLog(tempString);//课件资源加载失败 发信号传到服务端
                }
                if(status == Image.Ready){
                    imageSourceChageRectangle.visible= false;
                }

                if(status == Image.Ready && currentOffsetY  != 0){
                    button.y  =  -(scrollbar.height * currentOffsetY * trailBoardBackground.height / currentImageHeight);
                }

                //                console.log("*******current::pland:height********",currentImageHeight,trailBoardBackground.height,loadImgWidth,loadImgHeight,bmgImages.sourceSize);

                console.log("=====source::====",isHomework,source,isLongImage,isClipImage,isUploadImage,fullScreenType);

                if(source == ""){
                    scrollbar.visible = false;
                    bmgImages.width = trailBoardBackground.width ;
                    bmgImages.height = trailBoardBackground.height;
                    return;
                }

                if(isClipImage){
                    bmgImages.width = trailBoardBackground.width * clipWidthRate;
                    bmgImages.height = trailBoardBackground.height * clipHeightRate;
                    scrollbar.visible = false;
                    return;
                }
                if(isUploadImage){
                    bmgImages.width = trailBoardBackground.width;
                    bmgImages.height = trailBoardBackground.height;
                    scrollbar.visible = false;
                    return;
                }

                if(isLongImage){
                    scrollbar.visible = false;
                    console.log("#########height#########",bmgImages.sourceSize.height,currentImageHeight , trailBoardBackground.height)
                    if(currentImageHeight < trailBoardBackground.height){
                        bmgImages.width =  bmgImages.sourceSize.width;
                        bmgImages.height =  bmgImages.sourceSize.height;
                        return;
                    }

                    //console.log("=====imagesourceSize:=======",trailBoardBackground.width,bmgImages.sourceSize,transImageHeight,imgheight,imgwidth,loadImgHeight,loadImgWidth);
                    bmgImages.width = trailBoardBackground.width;
                    bmgImages.height = bmgImages.sourceSize.height;//transImageHeight;
                    scrollbar.visible = true;
                }
            }
        }

        Connections{
            target: getOffSetImage
            onReShowOffsetImage:
            {
                //console.log("onReShowOffsetImage");
                var urlSourse = "image://offsetImage/" + Math.random();
                setBmgUrl(urlSourse,height,width);
                setBmgVisible(true);
                isUploadImage = false;
                isClipImage = false;
                isLongImage = true;

                scrollbar.visible = false;
                if(currentImageHeight > trailBoardBackground.height){
                    scrollbar.visible = true;
                }
                setBmgVisible(true);
            }
            onSigDownLoadSuccess:{
                //console.log("=====downImage=====",downStatus)
                if(downStatus){
                    loadingAnimate.visible = true;
                }else{
                    loadingText.text = "";
                    loadingAnimate.visible = false;
                }
            }
        }

        // 画布
        TrailBoard{
            id:trailBoard
            z: 12
            clip: true
            width: parent.width
            height: parent.height
            smooth: true
            visible: networkImage.visible ? false : true
            enabled: isHandl

            onSigShowAllCourseImg:
            {
                sigShowAllCourseImgs(imgArray,contentArray,courseId);
            }

            onSigCancleInsertHomeWork:
            {
                sigCancleInsertHomeWorks();
            }

            onSigVideoSpan:
            {
                console.log("onSigVideoSpan qml ",videoSpan);
                videoToolBackground.updateVideoSpan(videoSpan);
            }

            onSigShowCCWhetherHoldMicView:{
                popupWidget.showCCWhetherHoldMicView(handMic);
            }

            onSigHideTeaWaitHandMicView:
            {
                popupWidget.hideTeaWaitHandMicView(handMic);
            }

            onSigUpdateUserStatus:
            {
                videoToolBackground.updateUserStatus();
            }
            onSigQuestionAnswerFailed: {
                loadingAnimate.visible = false;
            }

            onSigReportFinished:
            {
                hasExistListenReport = true;
                reportTips.visible = true;
            }

            //开始上课发送上麦确认命令
            onSigJoinMicophon: {
                console.log("===onSigJoinMicophon=====")
                trailBoardBackground.reposeMicrophone(1,"1");
            }

            onSigGetbackAisle:
            {
                sigGetbackAisles();
            }

            onSigRequestMicrophone: {
                sigRequestMicphone(status,userId);
            }

            onSigReponseMicrophone: {
                sigReponseMicrophones(status);
            }
            onSigOtherGetMicOrder:
            {
               sigOtherGetMicOrders();//响应别人获得麦克风权限
            }

            //老师掉线且学生在线则弹出立即开始上课
            onSigListenMicophone: {
                sigListenMicophones();
            }

            onSigDisapperListenMicophone: {
                //console.log("=========onSigDisapperListenMicophone=============");
                sigDisapperListenMicophones();
            }

            //重新验签的Url
            onSigOssSignUrl: {
                trailBoard.getOffsetImage(ossUrl,currentOffsetY);
                trailBoard.getOffSetImage(0,currentOffsetY,1.0);
                console.log("=========imageUrl::new=============",ossUrl,currentOffsetY);
            }
            onSigFocusTrailboard:{
                trailBoard.focus = true;
            }
            //课件暂未生成消息提醒
            onSigGetCoursewareFaill: {
                sigGetCoursewareFaills();
            }

            onSigInterNetChange: {
                sigInterNetworks(netStatus);
            }

            //图片的高度
            onSigCurrentImageHeight: {
                currentImageHeight = height;
                console.log("**********currentImageHeight*************",currentImageHeight)
                scrollbar.visible = false;
                if(currentImageHeight > trailBoardBackground.height){
                    scrollbar.visible = true;
                }
                trailBoard.setCurrentImageHeight(height);
                trailBoard.getOffSetImage(0.0,currentOffsetY,1.0);
            }

            //学生使用的当前版本
            onSigStudentAppversion: {
                sigStudentAppVersioned(status,canImportReportImg);
            }

            onSigStuChangeVersionToOld:
            {
                //弹窗提示
                mainView.showMessageTips("学生版本过低，请提醒对方升级版本");
            }

            //第一次开课重置讲义
            onSigOneStartClass: {
                setBmgVisible(false);
                sigOneStartClassed();
            }

            //开始做题按钮状态
            onSigSynQuestionStatus: {
                sigSynQuestionSta(status);
            }
            //讲义同步
            onSigPlanChange: {
                sigPlanSynchronize(lessonId,planId,itemId);
            }

            //学生发送同步菜单栏选择
            onSigSynColumn: {
                sigSynColumns(planId,columnId);
            }
            onSigSyncCorrect: {
                isOpenCorrect = status;
            }

            onSigIsOpenAnswer: {
                //console.log("********onSigIsOpenAnswer**********",questionId,"===",childQuestionId);
                sigIsOpenAnswers(isOpenStatus,questionId,childQuestionId);
            }

            onSigIsOpenCorrect: {
                isOpenCorrect = isOpenStatus;
                //console.log("********onSigIsOpenCorrect**********",  isOpenStatus);
                sigIsOpenCorrects(isOpenStatus);
            }

            onSigCorrect:
            {
                sigCorrects(questionData);
            }

            //栏目同步
            onSigCurrentColumn: {
                //console.log("========onSigCurrentColumn===========",planId, columnId);
                sigColumnSynchronize(planId,columnId);
            }

            //翻页传递当前题目信息:讲义Id,栏目Id,题目Id
            onSigCurrentQuestionId: {
                currentOffsetY = offsetY;
                console.log("====currentOffsetY====",currentOffsetY);
                imageSourceChageRectangle.visible = false;
                scrollbar.visible = false;
                if(currentImageHeight > trailBoardBackground.height){
                    scrollbar.visible = true;
                }
                console.log("=========sigCurrentQuestionId=======",isHomework,planId,questionId,offsetY,questionBtnStatus);

                if(isHomework == 2){//如果是老课件则不处理新讲义操作
                    return;
                }

                if(questionId == "-1"){//新课件截图处理
                    sigDisplayerBlankPage();
                    return;
                }
                if(questionId == "-2"){//老课件截图处理
                    sigDisplayerBlankPage();
                    return;
                }

                if(questionId == ""){
                    imagePath = "";
                    removeBmgUrl();
                    sigDisplayerBlankPage();
                }
                sigCurrentTopic(planId,columnId,questionId,questionBtnStatus);
            }

            onSigOffsetY: {
                currentOffsetY = offsetY;
                console.log("***********setYYYYYYY***************",currentImageHeight,offsetY);
                if(currentImageHeight == 0){
                    return;
                }

                var currentY =  -(scrollbar.height * offsetY * trailBoardBackground.height / currentImageHeight);
                button.y  = currentY;

                scrollbar.visible = false;
                if(currentImageHeight > trailBoardBackground.height){
                    scrollbar.visible = true;
                }
                //console.log("=======sigOffsetY=======",offsetY,button.y,currentImageHeight)
            }

            //解析提交练习命令
            onSigAnalysisQuestionAnswer: {
                //console.log("=====onSigAnalysisQuestionAnswer======",lessonId,questionId,planId,columnId);
                sigAnalysisQuestionAnswers(lessonId,questionId,planId,columnId);
            }

            onSigCurrentLessonTimer:{
                sigCurrentCourseTimer(lessonTimer);
            }

            onSigAutoConnectionNetwork:{
                //console.log("======autoConnetionNetwork===");
                sigPromptInterfaceHandl("autoConnectionNetwork");
            }

            onSigNetworkOnline: {
                //console.log("======onSigNetworkOnline=======",online)
                networkImage.visible = isLessonAssess ? false : !online;
            }
            //自动切换IP
            onAutoChangeIpResult: {
                //console.log("sigPromptInterfaceHandl(autoChangeIpStatus)",autoChangeIpStatus)
                sigPromptInterfaceHandl(autoChangeIpStatus);
            }

            //视频控制流
            onSigVideoAudioUrl:{
                //console.log("avType ==",avType ,"startTime ==",startTime ,"controlType ==",controlType,"avUrl ==",avUrl)
                trailBoardBackground.sigVideoAudioUrls(  avType, startTime , controlType , avUrl )
            }

            //老师操作教鞭
            onSigCursorPointer:{
                //console.log("===sigCursorPointer===",pointx,pointy,statues);
                cursorPoint.x = pointx
                cursorPoint.y = pointy
                cursorPoint.visible = statues;
            }

            onSigMouseRelease: {
                cursorPointTime.restart();
            }

            onSigSendUrl:{
                var urlsa = urls.replace("https","http");
                isClipImage = false;
                isUploadImage = false;

                console.log("=======falseonSigSendUrl========",currentOffsetY,width,height,urlsa,isHomework,isClipImage,isLongImg,questionId);
                isLongImage = true;
                if(isHomework == 2) //老课件
                {
                    scrollbar.visible = false;
                }

                if(questionId == "" || questionId == "-1" || questionId == "-2"){
                    //console.log("========no::longImg=====",isLongImage);
                    isLongImage = false;
                }

                if(width < 1 && height < 1 && urls != ""){//截图
                    isClipImage = true;
                    toobarWidget.disableButton = teacherType == "T" ? true : false;
                    clipWidthRate = width;
                    clipHeightRate = height;
                    scrollbar.visible = false;

                    //可以使用新比例画板的话 按照16:9新比例模式来进行填充显示
                    if(couldUseNewBoard)
                    {
                        isUploadImage = true;
                        toobarWidget.disableButton = true;
                        trailBoard.getOffsetImage(urlsa,0);
                        trailBoard.getOffSetImage(0,0,1.0);
                        return;
                    }
                }
                if(width == 1 && height == 1 && urls != ""){//传图
                    //原逻辑传图老课件都是走这里(原来传图老课件都是一屏铺满显示) 现在逻辑把传图和老课件都按等比例缩放
                    console.log("======= test old img 1 ========",currentOffsetY);
                    isUploadImage = true;
                    toobarWidget.disableButton = teacherType == "T" ? true : false;

                    if(couldUseNewBoard)
                    {
                        trailBoard.getOffsetImage(urlsa,currentOffsetY);
                        trailBoard.getOffSetImage(0,currentOffsetY,1.0);
                    }else
                    {
                        setBmgUrl(urlsa,width,height);
                        setBmgVisible(true);
                    }

                    return;
                }

                //                console.log("=======false::new========",width,height,urlsa,isHomework,isClipImage,isLongImg,isLongImage,questionId,isUploadImage);
                console.log("=====currentOffsetY======",currentOffsetY);

                if(urls.length > 0){
                    loadImgHeight = height;
                    loadImgWidth = width;
                    if(isLongImage && !isClipImage && !isUploadImage){
                        isHomework = 3;
                        trailBoard.getOffsetImage(urlsa,currentOffsetY);
                        trailBoard.getOffSetImage(0,currentOffsetY,1.0);
                        //                        console.log("=======getOffsetImage========",currentOffsetY);
                    }else
                    {
                        setBmgUrl(urlsa,width,height);
                        setBmgVisible(true);
                    }

                    screenshotSaveImage.deleteTempImage();
                }else{
                    if(isHomework == 2){
                        removeBmgUrl();
                    }

                    if(questionId == "" && isHomework == 3){
                        scrollbar.visible = false;
                        setBmgVisible(false);
                    }

                    if(width == 1 && height == 1 && urlsa == ""){
                        //console.log("width == 1 && height =wwwwww= 1",isHomework,isLongImage);
                        //setBmgVisible(false);
                        if(isHomework == 1)
                        {
                            sigHideCourseView(false);
                        }
                        return
                    }

                    var visibles = (isHomework == 3 ? true : isLongImg);
                    setBmgVisible(visibles);
                    sigHideCourseView(visibles);
                }
            }

            //提示打开跟关闭摄像头
            onSigUserIdCameraMicrophone: {
                toopBracund.visible = false;
                toopBracundTimer.stop();

                //得到学生的姓名
                var cname = curriculumData.getUserName(usrid);

                if(status == 16) {
                    showMessageTips(qsTr("学生 ") + cname + qsTr(" 关闭本地摄像头"));
                }
                if(status == 15){
                    showMessageTips(qsTr("学生 ") + cname + qsTr(" 关闭本地麦克风"));
                }
            }

            onSigSendHttpUrl:{
                animePlayBroundImage.source = "";
                animePlayBroundImage.paused = true;

                if(urls.length > 0) {
                    animePlayBroundImage.source = trailBoard.justImageIsExisting(urls);
                    animePlayBround.focus = true;
                    animePlayBroundImage.paused = false;
                }else {
                    trailBoard.focus = true;
                }
            }
            //当前页
            onSigChangeCurrentPage: {
                var currentPages = currentPage + 1;
                sigChangeCurrentPages(currentPages);
                // pageNumInput.text = currentPages;
            }
            //全部页数
            onSigChangeTotalPage: {
                sigChangeTotalPages(totalPage);
                //  totalPageInput.text = "/"+ totalPage;
            }
            //开始上课
            onSigStartClassTimeData:{
                toopBracund.visible = false;
                trailBoardBackground.sigStartClassTimeData(times);
            }
            onSigDroppedRoomIds:{
                toopBracund.visible = false;
                toopBracundTimer.stop();

                //            var isTeacher = curriculumData.isTeacher(ids );
                var cname = curriculumData.getUserName(ids);
                showMessageTips(qsTr("学生 ") + cname + qsTr(" 掉线"));

                sigPromptInterfaceHandl("StayInclass");
            }

            //根据userId取得用户名
            onSigSendUserId:{
                var uName = curriculumData.getUserName(userId);
                tipName = uName;
                sigUserName(uName,userId);
            }

            //有人退出教室
            onSigExitRoomIds:{
                var ida = curriculumData.getUserType(ids );
                var cname = curriculumData.getUserName(ids);
                console.log("=====type:11", ida);
                if(ida == "B") {
                    showMessageTips(qsTr("学生 ") + cname + qsTr(" 退出教室"));
                    sigBExitClass();
                    return;
                }

                console.log("=====type:22", curriculumData.getCurrentIsAttend(), ids, curriculumData.getCurrentOrderId());
                // 非持麦者掉线改变音视频状态
                //需要考虑学生退出的时候, 提示: 某某学生退出教室了
                //非持麦者, 可能是学生
                if( curriculumData.getCurrentIsAttend() && ids !== curriculumData.getCurrentOrderId()  && !curriculumData.doCheck_ID_Is_Student(ids))
                {
                    sigBExitClass();
                    console.log("=====type:33");
                    return;
                }

                console.log("=====type:44");
                //显示: "学生退出教室"窗口
                trailBoardBackground.sendExitRoomName(ida , cname, ids);
            }

            onSigPromptInterface:{
                //处理老师结束课程 为a学生
                console.log("==onSigPromptInterface==",interfaces);

                if(interfaces == "1002" || interfaces == "1003"){
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                if(interfaces == "118"){
                    joinMicrophoneView.visible = false;
                    popupWidget.setPopupWidget("4");
                }

                if(interfaces == "2"){
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                if(interfaces == "visibleMic"){
                    console.log("=====visibleMic======");
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                if(interfaces == "117"){
                    isListenModel = true;
                    isChangeTeacherType = "L";
                    console.log("======isListenModel=====",isListenModel)
                    return;
                }

                if(interfaces == "65" ) {
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                //学生申请翻页权限
                if(interfaces == "8"){
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                //切换线路
                if(interfaces == "changedWay"){
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                //申请结束课程
                if(interfaces == "50"){
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }

                //学生进入教室信号
                if(interfaces == "51") {
                    sigPromptInterfaceHandl(interfaces);
                }

                //掉线重连
                if(interfaces== "14"){
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }

                //改变频道跟音频
                if(interfaces == "61") {
                    sigPromptInterfaceHandl(interfaces);
                }
                //判断是否同意离开教室
                if(interfaces == "63" || interfaces == "64") {
                    sigPromptInterfaceHandl(interfaces);
                }
                //申请退出教室
                if(interfaces == "10"){
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                //

                //申请进入教室 4上过课 5 未上过课
                if(interfaces == "4" || interfaces == "5"){
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }

                //改变权限
                if(interfaces == "62") {
                    sigPromptInterfaceHandl(interfaces);
                }
                if(interfaces == "0" || interfaces == "1" || interfaces == "2") {
                    sigPromptInterfaceHandl(interfaces);
                    teacherType = trailBoardBackground.getTeacherStatus();
                    return;
                }
                //上过课
                if(interfaces == "22" ) {
                    sigPromptInterfaceHandl("22");
                    return;
                }
                //上过课
                if(interfaces == "23" ) {
                    teacherType = trailBoardBackground.getTeacherStatus();
                    if( teacherType == "T")
                    {
                        showMessageTips("当前是自由操作模式，开始上课后操作记录会被清空哦!");
                    }

                    return;
                }
                //音视频的状态
                if(interfaces == "68") {
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                //B学生进入教室
                if(interfaces == "11"){
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                //B学生显示在线操作
                if(interfaces == "b_Online"){
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                //未认真听见提醒状态
                if(interfaces == "52"){
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                //断开不再重连
                if(interfaces == "88"){
                    sigPromptInterfaceHandl(interfaces);
                    return
                }
                if(interfaces == "lodingCourseFail"){
                    //loadingTimer.restart();
                    return;
                }
            }

            //删除课件提醒
            onSigIsCourseWare: {
                showMessageTips("课件不能删除!");
                return;
            }
        }
    }

    //滚动条
    Item {
        id: scrollbar
        anchors.right: parent.right
        anchors.rightMargin: 4 * heightRate
        anchors.top: parent.top
        width: 8 * heightRate
        height: parent.height
        visible: false
        z: 1666

        onVisibleChanged:
        {
            if(isHomework == 2)
            {
                //visible = false;
            }
        }

        // 按钮
        Rectangle {
            id: button
            width: parent.width
            height: {
                var mutilValue = currentImageHeight / trailBoardBackground.height
                if(mutilValue > 1){
                    return parent.height / mutilValue;
                }else{
                    return parent.height * mutilValue;
                }
            }
            color: "#dddddd"
            radius: 6 * heightRate

            // 鼠标区域
            MouseArea {
                id: mouseArea
                anchors.fill: button
                drag.target: button
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: scrollbar.height - button.height
                cursorShape: Qt.PointingHandCursor
                enabled: toobarWidget.disableButton

                onReleased: {
                    currentOffsetY = 0;
                    var contentY =  (button.y / scrollbar.height * currentImageHeight / trailBoardBackground.height);
                    scrollImage(-contentY);
                    trailBoard.getOffSetImage(0.0,contentY,1.0);
                    console.log("=====lsdkfjlsajflksdjflksd===========",contentY,currentImageHeight,trailBoardBackground.height);
                }
            }
        }
    }

    //教鞭
    Rectangle{
        id:cursorPoint
        width: 15 * ratesRates
        height: 15 * ratesRates
        radius: cursorPoint.height / 2
        color: "red"
        x:0
        y:0
        visible: false
        z: 99
    }

    //教鞭定时器
    Timer{
        id:cursorPointTime
        interval: 1000
        repeat: false
        running: false
        onTriggered: {
            cursorPoint.visible = false;
        }
    }

    //网络掉线提醒图标
    Rectangle{
        id: networkImage
        z: 11
        anchors.fill: parent
        visible: false
        Image{
            width: 120 * widthRate
            height: 150 * widthRate
            source: "qrc:/images/icon_nowifi.png"
            anchors.centerIn: parent
        }
    }

    //动漫播放
    Item{
        id:animePlayBround
        width: 118 * trailBoardBackground.height / 698
        height: 118 *trailBoardBackground.height / 698
        focus: false
        visible: false
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin:  ( parent.height - animePlayBround.height ) / 2
        anchors.leftMargin:   ( parent.width - animePlayBround.width ) / 2
        z:12
        AnimatedImage{
            id:animePlayBroundImage
            anchors.fill: parent
            source: ""
            onCurrentFrameChanged: {
                if(animePlayBroundImage.status == Image.Ready) {
                    if( animePlayBroundImage.frameCount !== 0) {
                        if(currentFrame == 0  ){
                            trailBoard.focus = true;
                            animePlayBroundImage.paused = true;
                            animePlayBround.visible = false;
                            animePlayBround.focus = false;

                        }
                    }
                }

            }
        }
        onFocusChanged: {
            if(animePlayBround.focus) {
                animePlayBround.visible = focus;
                animePlayBroundImage.playing = true;
            }else {
                //animePlayBround.visible = focus;
            }
        }
    }

    //几何图形背景
    Item{
        id:geometricFigureBakcground
        anchors.fill: parent
        visible: false
        z:12
    }

    //读取文件
    MxResLoader {
        id:mxResLoader
    }

    //挖取图片
    Rectangle{
        id:digPictures
        anchors.fill: parent
        visible: false
        z:19
        Image {
            id: digPicturesImage;
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit;
            asynchronous: true
            onSourceChanged: {
                maskPicture.maskPictureDx =  0;
                maskPicture.maskPictureDy = 0;
                maskPicture.maskPictureDw= 0;
                maskPicture.maskPictureDh= 0;

                maskPicture.maskPictureWidth= 0;
                maskPicture. maskPictureHeight= 0;
                maskPicture.requestPaint();
            }
        }

        Canvas {
            id: forSaveCanvas;
            width:  maskPicture.maskPictureWidth;
            height: maskPicture.maskPictureHeight;
            contextType: "2d";
            visible: false;
            z: 2;
            anchors.top: parent.top;
            anchors.left:  parent.left;
            anchors.margins: 4;

            property var imageData: null;

            onPaint: {
                if(imageData != null){
                    context.drawImage(imageData, 0, 0);
                    forSaveCanvas.save( screenshotSaveImage.tempGrabPicture);
                    digPictures.visible = false;
                    imageSourceChageRectangle.visible = true;
                    var ad = 1.0 * maskPicture.maskPictureWidth / trailBoard.width;
                    var af = 1.0 * maskPicture.maskPictureHeight / trailBoard.height;
                    trailBoard.setPictureRate(ad ,af);
                    clipWidthRate = ad;
                    clipHeightRate = af;
                    imageSourceChageRectangle.visible = true;
                    loadInforMation.uploadFileIamge(screenshotSaveImage.tempGrabPicture);
                }
            }

            function setImageData(data){
                imageData = data;
                requestPaint();
            }
        }

        Canvas {
            id: maskPicture;
            anchors.fill: parent;

            property real maskPictureW: digPictures.width;
            property real maskPictureH: digPictures.height;
            property real maskPictureDx: 0;
            property real maskPictureDy: 0;
            property real maskPictureDw: 0;
            property real maskPictureDh: 0;

            property real maskPictureWidth: 0;
            property real maskPictureHeight: 0;

            function getImageData(){
                var xStart = 0;
                var yStart = 0;
                var xEnd = 0;
                var yEnd = 0;

                if(maskPicture.maskPictureDw <  maskPicture.maskPictureDx) {
                    xStart = maskPicture.maskPictureDw;
                    xEnd = maskPicture.maskPictureDx

                }else {
                    xStart = maskPicture.maskPictureDx;
                    xEnd = maskPicture.maskPictureDw
                }
                if(maskPicture.maskPictureDh <  maskPicture.maskPictureDy) {
                    yStart = maskPicture.maskPictureDh;
                    yEnd = maskPicture.maskPictureDy;
                }else {
                    yStart = maskPicture.maskPictureDy;
                    yEnd = maskPicture.maskPictureDh;

                }

                return context.getImageData(xStart, yStart, xEnd - xStart ,  yEnd - yStart );
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, maskPicture.maskPictureW,  maskPicture.maskPictureH);
                ctx.drawImage(digPicturesImage,0, 0, maskPicture.maskPictureW,  maskPicture.maskPictureH);
                var xStart = 0;
                var yStart = 0;
                var xEnd = 0;
                var yEnd = 0;

                if(maskPicture.maskPictureDw <  maskPicture.maskPictureDx) {
                    xStart = maskPicture.maskPictureDw;
                    xEnd = maskPicture.maskPictureDx;
                }else {
                    xStart = maskPicture.maskPictureDx;
                    xEnd = maskPicture.maskPictureDw;
                }
                if(maskPicture.maskPictureDh <  maskPicture.maskPictureDy) {
                    yStart = maskPicture.maskPictureDh;
                    yEnd = maskPicture.maskPictureDy;
                }else {
                    yStart = maskPicture.maskPictureDy;
                    yEnd = maskPicture.maskPictureDh;
                }
                maskPicture.maskPictureWidth = xEnd - xStart;
                maskPicture.maskPictureHeight = yEnd - yStart;

                ctx.save();
                ctx.fillStyle = "#a0000000";
                ctx.fillRect(0, 0, maskPictureW, yStart);
                var yOffset = yStart + xEnd - yStart;
                ctx.fillRect(0, yStart, xStart, maskPictureH - yStart);
                ctx.fillRect(xStart, yEnd, maskPictureW - xStart , maskPictureH - yEnd);
                var xOffset = xEnd;
                ctx.fillRect(xOffset, yStart, maskPictureW - xOffset, yEnd - yStart );

                //see through area
                ctx.strokeStyle = "white";
                ctx.fillStyle = "#00000000";
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.rect(xStart, yStart, xEnd - xStart ,  yEnd - yStart );
                ctx.fill();
                ctx.stroke();
                ctx.closePath ();
                ctx.restore();
            }
        }

        //进入截图状态以后, 按住鼠标左键拖动, 指定截图的区域的事件
        MouseArea{
            id:drawShape
            anchors.fill: parent
            cursorShape:Qt.ArrowCursor
            onPressed: {
                mainView.doEnableDisableControls(true); //enable 部分控件
                console.log("=======MouseArea onPressed========");
                maskPicture.maskPictureDx = mouseX;
                maskPicture.maskPictureDy = mouseY;
            }
            onPositionChanged: {
                maskPicture.maskPictureDw = mouseX;
                maskPicture.maskPictureDh = mouseY;

                if(maskPicture.maskPictureDw > maskPicture.maskPictureDx && maskPicture.maskPictureDh > maskPicture.maskPictureDy ) {
                    drawShape.cursorShape = Qt.SizeFDiagCursor;
                }
                if(maskPicture.maskPictureDw > maskPicture.maskPictureDx && maskPicture.maskPictureDh < maskPicture.maskPictureDy ) {
                    drawShape.cursorShape = Qt.SizeBDiagCursor;
                }
                if(maskPicture.maskPictureDw < maskPicture.maskPictureDx && maskPicture.maskPictureDh > maskPicture.maskPictureDy ) {
                    drawShape.cursorShape = Qt.SizeBDiagCursor;
                }
                if(maskPicture.maskPictureDw < maskPicture.maskPictureDx && maskPicture.maskPictureDh < maskPicture.maskPictureDy ) {
                    drawShape.cursorShape = Qt.SizeFDiagCursor;
                }
                maskPicture.requestPaint();
            }

            onReleased: {
                forSaveCanvas.setImageData(maskPicture.getImageData())
            }
        }
    }

    //加载、上传图片等待动画
    AnimatedImage {
        id: imageSourceChageRectangle
        width: 35 * ratesRates
        height: 35 * ratesRates
        source: "qrc:/images/loading.gif"
        anchors.centerIn: parent
        z: 500
        visible: false
    }

    //截图
    ScreenshotSaveImage{
        id:screenshotSaveImage
        onSigSendScreenshotName:{
            console.log("=======sigSendScreenshotName=========",paths);
            if(paths.length > 0) {
                digPicturesImage.source = "";
                digPicturesImage.source = "file:///"+paths;
                digPictures.visible = true;
            }
            hasShowCutSCreen = true;
        }
    }

    //上传图片
    LoadInforMation{
        id:loadInforMation
        onSigUploadFileIamge:{
            imageSourceChageRectangle.visible = false;
            if(!arrys) {
                showMessageTips("图片上传失败");
            }
            hasShowCutSCreen = false;
        }
        onSigSendUrlHttp:{
            if(urls == "")
            {
                return;
            }
            trailBoard.upLoadSendUrlHttp(urls);
            hasShowCutSCreen = false;
            sigDisplayerBlankPage();
            console.log("=====onSigSendUrlHttp::onSigSendUrlHttp=====",isHomework,urls);
        }

        onSigLoadingMp3: {
            showMessageTips("正在加载Mp3,请稍后....");
        }
    }

    //选取文件
    FileDialog {
        id: fileDialog
        title: "选择图片"
        folder: shortcuts.home
        selectFolder: false
        selectMultiple: false
        modality: Qt.WindowModal
        nameFilters: [ "Image files (*.jpg *.png)" ,"All(*.*)"]
        onAccepted: {
            var selectfiles = fileDialog.fileUrls;
            if(selectfiles.length > 0) {
                for(var i = 0; i < selectfiles.length; i++) {
                    var filesurlsa = "";
                    filesurlsa = selectfiles[i];
                    console.log("==filesurlsa===",filesurlsa);
                    var filesurlsah = filesurlsa.replace("file:///","");
                    imageSourceChageRectangle.visible = true;
                    trailBoard.setPictureRate(1.000,1.000);
                    clipWidthRate = 1.0;
                    clipHeightRate = 1.0;
                    loadInforMation.uploadFileIamge(filesurlsah);
                }
            }
            fileDialog.close();
        }
        onRejected: {
            fileDialog.close();
        }
    }

    Item{
        id:handlBakc
        anchors.fill: parent
        z: 20
        visible:  isHandl ? false: true
        MouseArea{
            anchors.fill: parent
        }
    }

    Timer{
        id: repeatUploadTime
        interval: 6000
        repeat: false
        running: false
        onTriggered: {
            var dataObj = loadInforMation.getQuestionAnswer(currentPlanId,currentItemId,currentOrderNumber);
            uploadNumber++;
            if(uploadNumber > 2 && (dataObj.imageUrl == undefined)){
                trailBoard.commitAnserFail(currentQuestionId,currentPlanId,currentItemId);
                loadingAnimate.visible = false;
                showMessageTips("提交题目图片失败，请重新操作....");
                return;
            }

            //            var imagePath = loadInforMation.uploadQuestionImgOSS(currentPlanId,currentItemId,currentOrderNumber,currentImgName,currentFilePath);
            //            uploadNumber++;
            //            //console.log("*********uploadNumber*********",uploadNumber,imagePath);
            //            if(uploadNumber > 2 && imagePath == "str_Null"){
            //                trailBoard.commitAnserFail(currentQuestionId,currentPlanId,currentItemId);
            //                showMessageTips("提交题目图片失败，请重新操作....");
            //                return;
            //            }

            if(dataObj.imageUrl  == undefined){
                repeatUploadTime.restart();
                return;
            }
            sigUploadWorkImage(imagePath,currentImgWidth,currentImgHeight);
        }
    }
    property int uploadNumber: 0;//上传次数
    property var currentPlanId;
    property var currentItemId;
    property var currentOrderNumber;
    property var currentImgName;
    property var currentFilePath;
    property var currentImgWidth;
    property var currentImgHeight;

    function uploadWorkImage(planId,itemId,questionId,ImgName,filePath,imgWidth,imgHeight){
        uploadNumber = 0;
        currentPlanId = planId;
        currentItemId = itemId;
        currentOrderNumber = questionId;
        if(planId == "" && itemId == "" && questionId == ""){
            console.log("=====uploadWorkImage::null::id======",planId,itemId,questionId);
            return;
        }

        var dataObj = loadInforMation.getQuestionAnswer(planId,itemId,questionId);
        if(dataObj.imageUrl == undefined){
            repeatUploadTime.restart();
            return;
        }

        var img_width = dataObj.width;
        var img_height = dataObj.height;
        var img_url = dataObj.imageUrl;
        /*
        var imagePath = loadInforMation.uploadQuestionImgOSS(planId,itemId,orderNumber,ImgName,filePath);
        //console.log("*********imagePath***********",imagePath);
        if(imagePath == "str_Null"){
            currentPlanId = planId;
            currentItemId = itemId;
            currentOrderNumber = orderNumber;
            currentImgName = ImgName;
            currentFilePath = filePath;
            currentImgWidth = imgWidth;
            currentImgHeight = imgHeight;
            repeatUploadTime.restart();
            //console.log("*************repeat::upload***************")
            return;
        }*/

        sigUploadWorkImage(img_url,img_width,img_height);
    }

    function setBackgrundImage(){
        setBackgrundImages(loadImgHeight,loadImgWidth,fullScreenType,isClipImage,isUploadImage,isLongImage,trailBoardBackground.width,trailBoardBackground.heigth,columnType);
        console.log("======setBackgrundImage======",fullScreenType,isClipImage,isUploadImage,isLongImage)
        if(fullScreenType == false){
            if(bmgImages.source == ""){
                bmgImages.width = trailBoardBackground.width ;
                bmgImages.height = trailBoardBackground.height;
                return;
            }

            if(isClipImage){
                bmgImages.width = bmgImages.sourceSize.width;
                bmgImages.height = bmgImages.sourceSize.height;
                scrollbar.visible = false;
                return;
            }
            if(isUploadImage){
                bmgImages.width = trailBoardBackground.width;
                bmgImages.height = trailBoardBackground.height;
                scrollbar.visible = false;
                return;
            }

            if(isLongImage){
                var rate = 0.618;
                var imgheight = loadImgHeight == 0 ? bmgImages.sourceSize.height : loadImgHeight;
                var imgwidth = loadImgWidth == 0 ? bmgImages.sourceSize.width : loadImgWidth;
                var multiple = imgheight / imgwidth / rate
                var transImageHeight  = trailBoardBackground.height * multiple;
                var transImageWidth  = trailBoardBackground.width * multiple;

                if(bmgImages.sourceSize.height < trailBoardBackground.height){
                    bmgImages.width =  bmgImages.sourceSize.width;
                    bmgImages.height =  bmgImages.sourceSize.height;
                    scrollbar.visible = false;
                    return;
                }

                console.log("=====imagesourceSize:=======",trailBoardBackground.width,bmgImages.sourceSize,transImageHeight,imgheight,imgwidth,loadImgHeight,loadImgWidth);
                bmgImages.width = trailBoardBackground.width;
                bmgImages.height = transImageHeight;
                scrollbar.visible = true;
            }
            return;
        }

        if(fullScreenType && isClipImage){
            bmgImages.width = (bmgImages.sourceSize.width >  trailBoardBackground.width ||  bmgImages.sourceSize.width == 0)? trailBoardBackground.width : bmgImages.sourceSize.width;
            bmgImages.height = (bmgImages.sourceSize.height >  trailBoardBackground.height ||  bmgImages.sourceSize.height == 0)? trailBoardBackground.height : bmgImages.sourceSize.height;
            scrollbar.visible = false;
            return;
        }
        if(fullScreenType && isUploadImage){
            bmgImages.width = trailBoardBackground.width;
            bmgImages.height = trailBoardBackground.height;
            scrollbar.visible = false;
            return;
        }

        if(fullScreenType && columnType  != 0 && columnType  != 1){
            bmgImages.width = trailBoardBackground.width;
            bmgImages.height = trailBoardBackground.height;
            return;
        }
    }

    function getNetworkStatus(){
        return trailBoard.getNetworkStatus();
    }

    function downLoadMp3(mp3Path){
        return loadInforMation.downLoadMp3(mp3Path);
    }

    //上麦申请
    function applyMicrophoneRole(){
        trailBoard.applyMicrophoneRole();
    }

    //是否同意上麦权 idtype 1 传自己的id  0 就传别人的id
    function reposeMicrophone(status,idType){
        console.log("reposeMicrophone(",status,idType)
        trailBoard.reponseMicophone(status,idType);
    }

    //获取当前是老师还是旁听状态
    function getTeacherStatus(){
        return trailBoard.getTeacherStatus();
    }

    function sendReportImg(imgarry)
    {
        trailBoard.sendReportImgs(imgarry);
    }

    function sendReportFinisheds()
    {
        trailBoard.sendReportFinisheds();
    }

    function setRequestVideoSpans()
    {
        trailBoard.slotRequestVideoSpan();
        console.log("========TrailBoardBackground=====setRequestVideoSpans=");
    }

    function pushReportMsgToServer(pStatus,pMsg)
    {
        trailBoard.pushReportMsgToServer(pStatus,pMsg);
    }

    function pushInsertReportMsgToServer(pStatus,pMsg,firstReportUrl)
    {
        trailBoard.pushInsertReportMsgToServer(pStatus,pMsg,firstReportUrl);
    }

}
