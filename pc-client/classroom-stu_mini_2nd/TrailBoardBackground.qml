import QtQuick 2.7
import TrailBoard 1.0
import MxResLoader 1.0
import QtQuick.Dialogs 1.2
import LoadInforMation 1.0
import ScreenshotSaveImage 1.0
import CurriculumData 1.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import WhiteBoard 1.0

Rectangle {
    id:trailBoardBackground
    //clip: true

    function setAllTrail(trailData)
    {
        trailBoard.setAllTrails(trailData);
    }

    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property double  imageWRate: 1.0;//当前显示的 image宽比例
    property double imageHRate: 1.0;
    property string bgImgUrl: ""

    //新课件信号
    //加载新的讲义课件
    signal sigShowNewCoursewares(var coursewareData);
    //加载新课件的对应的栏目
    signal sigShowNewCoursewareItems(var coursewareItemData);
    //开始练习
    signal sigStarAnswerQuestions(var questionData);
    //停止练习
    signal sigStopAnswerQuestions(var questionData);

    //打开答案解析 questionData 包含题目所在的 讲义id 对应的栏目 以及对应的 题的id
    signal sigOpenAnswerParsings(var questionData);
    //关闭答案解析
    signal sigCloseAnswerParsings(var questionData);
    //打开批改面板 /**/
    signal sigOpenCorrects(var questionData , var isVisible);
    //关闭批改面板
    signal sigCloseCorrects(var questionData);
    //开始批改界面
    signal sigCorrects(var questionData);
    //讲义题目自动转图
    signal sigAutoPictures(var questionData);

    //获取课件失败
    signal sigGetLessonListFails();

    //获取课程评价数据成功
    signal sigGetUnsatisfactoryOptionsT(var optionData);

    signal sigInterNetworks(var networkStatus);//当前是无线还是有线切换

    property bool  isMaxWidget: false

    //几何图形
    property var itemPolygonPanelFrame: null
    property int  itemPolygonPanelFrameData: 0

    //判断是否允许操作
    property bool isHandl: true

    //学生类型
    property  string  studentType: curriculumData.getCurrentUserType()

    //摄像头状态
    property string cameraStatus: "1"

    //麦克风状态
    property string microphoneStatus: "1"

    property bool hasShowCutSCreen: false;

    //当前被显示的图片的高度 //new
    property double currentBeShowedIamgeHeight: 960.0;
    //当前图片的偏移量
    property double currentOffsetY: 0.0;

    //发送延迟信息
    function setSigSendIpLostDelays(infor){
        trailBoard.setSigSendIpLostDelay(infor);
    }

    //主动退出
    function  setSelectWidgetType( types){
        trailBoard.selectWidgetType( types);
    }

    //主动断开连接
    function  disconnectSockets(){
        trailBoard.disconnectSocket();
    }

    //申请结束课程
    function setEndLesson(){
        trailBoard.setSendEndLessonRequest();
    }

    //设置申请翻页
    function setApplyPage(){
        toopBracund.visible = false;
        //        toopBracundImageText.text = qsTr("向老师发送翻页请求!")
        //        toopBracund.visible = false;
        //        toopBracund.visible = true;
        cloudTipView.setTipViewText(qsTr("向老师发送翻页请求!"));
        trailBoard.setApplyPage();
    }



    //控制本地摄像头
    function setOperationVideoOrAudio(userId ,  videos ,  audios) {
        trailBoard.setOperationVideoOrAudio(userId ,  videos ,  audios);
    }

    //设置画笔颜色
    function setPenColors(penColors) {
        whiteBoard.setPenColor(penColors);
    }
    //改变画笔尺寸
    function changeBrushSizes(penWidths) {
        whiteBoard.changeBrushSize(penWidths);
    }
    //设置橡皮擦
    function setCursorShapeType(types) {
        whiteBoard.setCursorShapeTypes(types);
    }
    //设置橡皮大小
    function setEraserSize(eraserSize){
        whiteBoard.setEraserSize(eraserSize);
    }

    //设置上传图片
    function setUpLoadPicture(){
        fileDialog.open();
    }

    //获取当前网络状态：有线、无线
    function getNetworkStatus(){
        return trailBoard.getNetworkStatus();
    }

    //截图
    function  setScreenShotPicture(){
        if(hasShowCutSCreen == true)
        {
            return;
        }

        screenshotSaveImage.grabImage(trailBoardBackground);
        hasShowCutSCreen = true;
    }

    //跳转页面
    function jumpToPage(pages){
        trailBoard.goPage(pages );
    }

    //发送评价
    function sendEvaluateContent( content ,  attitude ,  homework ,  contentText){
        trailBoard.setSendTopicContent( content ,  attitude ,  homework ,  contentText);
    }
    //保存学生的评价
    function saveStuEvaluationContents( stuSatisfiedFlag ,optionId , otherReason){
        trailBoard.setSaveStuEvaluationContents( stuSatisfiedFlag ,optionId , otherReason);
    }

    //设置留在教室
    function setStayInclassroom(){
        trailBoardBackground.sigPromptInterfaceHandl("22");
        isHandl = false;

    }
    //切换线路
    function setChangeOldIpToNews(){
        trailBoard.setChangeOldIpToNew();
    }

    //设置清屏操作
    function setClearCreeon(type,pageNo,totalNum){
        console.log("===setClearCreeon=====",type,pageNo,totalNum);
        whiteBoard.clearScreen(type,pageNo,totalNum);
    }

    //当前页数
    signal    sigChangeCurrentPages(int pages)

    //总页数
    signal    sigChangeTotalPages(int pages)
    //开始上课
    signal sigStartClassTimeDatas(string times);

    //控制界面信号
    signal sigPromptInterfaceHandl(string inforces);

    //发送离开教室的姓名跟类型
    signal sendExitRoomName(string types ,string cname);

    //视频控制流
    signal sigVideoAudioUrls( string avType,string startTime ,string controlType ,string avUrl );

    //课件资源加载失败 发信号传到服务端
    signal sigSendCoursewareErrorToServer(string errorString);

    // ===================================== >>>
    //修改bug: 9488 【stg】学生端图形显示变形
    //bug描述: 学生端单击下方最大化按钮后，圆形变椭圆形
    onHeightChanged:
    {
        //        console.log("======= onHeightChangedonHeightChanged", height)
        trailBoard.height = height;
    }

    onWidthChanged:
    {
        //        console.log("======= onWidthChangedonWidthChanged", width)
        trailBoard.width = width;
    }
    // <<< =====================================

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
    function okItemPolygonPanelFrame(contents) {
        if(trailBoardBackground.itemPolygonPanelFrame != null) {

            whiteBoard.drawLocalGraphic(contents,trailBoardBackground.height,bmgImages.y);
            trailBoardBackground.itemPolygonPanelFrame.destroy();
            trailBoardBackground.itemPolygonPanelFrame = null;
            geometricFigureBakcground.visible = false;
        }
    }


    //发送url网址
    function setInterfaceUrl(urls){
        animePlayBroundImage.source = "";
        animePlayBroundImage.paused = true;
        if(urls.length > 0) {
            animePlayBroundImage.paused = false;
            animePlayBroundImage.source = trailBoard.justImageIsExisting(urls);
            whiteBoard.setInterfaceUrls(urls);
            animePlayBround.focus = true;
            animePlayBroundImage.paused = false;
        }else {
            trailBoard.focus = true;
        }
    }
    //设置最后一页提醒
    function setLastPageRemind()
    {
        toopBracundImageText.text = qsTr("已经到最后一页了")
        toopBracund.visible = false;
        toopBracund.visible = true;
    }
    //设置最后一页提醒
    function setFirstPageRemind()
    {
        toopBracundImageText.text = qsTr("已经到第一页了")
        toopBracund.visible = false;
        toopBracund.visible = true;
    }

    //发送学生提交的答案信息给老师
    function sendAnsweerToTeacher(questionData)
    {
        trailBoard.sendStudentAnswerToTeacher(questionData);
    }
    //发送答案解析数据
    function sendOpenAnswerParse(planId,columnId,questionId,childQuestionId,isOpen)
    {
        console.log("sendOpenAnswerParse",planId,columnId,questionId,childQuestionId,isOpen);
        trailBoard.sendOpenAnswerParse(planId,columnId,questionId,childQuestionId,isOpen);
    }

    //发送打开批改数据
    function sendOpenCorrect(planId,columnId,questionId,childQuestionId,isOpen)
    {
        trailBoard.sendOpenCorrect(planId,columnId,questionId,childQuestionId,isOpen);
    }

    //点击栏目发送命令
    function selectedMenuCommand(pageIndex,planId,cloumnId){
        trailBoard.selectedMenuCommand(pageIndex,planId,cloumnId);
    }

    //长图滚动函数
    function scrollImage(scrollY){
        trailBoard.updataScrollMap(scrollY);
    }

    //进入音视频通道失败
    function createRoomFail()
    {
        trailBoard.creatRoomFail();
    }

    Rectangle{
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        color: "#ffffff"  //#eeeeee
        border.width: 1
        border.color: "#f6f6f6"
    }
    AnimatedImage
    {
        id: imageSourceChageRectangle
        width: 35 * ratesRates
        height: 35 * ratesRates
        source: "qrc:/images/loading.gif"
        anchors.centerIn: parent
        z: 500
        visible: false
    }
    //背景图
    Rectangle{
        id:bakcImages
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 1
        anchors.topMargin: 1
        width: trailBoard.width - 2
        height: trailBoard.height - 2
        color: "#00000000"
        z:9
        clip: true

        CourseWareControlView{
            id: bmgImages
            anchors.fill: parent
            z: 10
            currentBeshowViewType: coursewareType
        }

/*
        Image {
            id: bmgImages
            width: parent.width
            //height:parent.height
            smooth: true
            mipmap: true
            onProgressChanged:
            {
                if(bmgImages.progress < 1)
                {
                    imageSourceChageRectangle.visible= true;
                }else
                {
                    imageSourceChageRectangle.visible= false;
                }
            }

            onStatusChanged:
            {
                console.log("=====Flickable::statuschange======",status,imageWRate);
                if(status == Image.Ready)
                {

                }
                console.log("=====Flickable::status======222226666662",trailBoard.height, bakcImages.height)
                if(status == Image.Error)
                {
                    var tempString = "{\"domain\":\"system\",\"command\":\"statistics\",\"content\":{\"type\":\"exception\",\"coursewareException\":{ \"url\":\"";
                    if(tempString.indexOf(".jpg") == -1 && tempString.indexOf(".png") == -1)
                    {
                        tempString +=  bmgImages.source + "\",\"error\":\"Image Loading Error\",\"status\": \"" +status+"\"}}}";
                    }else {
                        tempString += bmgImages.source + "\",\"error\":\"Image Path Cannot Open\",\"status\": \"" +status+"\"}}}";
                    }
                    console.log("status == Image.Error",tempString)
                    sigSendCoursewareErrorToServer(tempString);
                    return;
                }
            }

        }
*/

        Connections
        {
            target: getOffSetImage
            onReShowOffsetImage:
            {
                currentCourwareType = trailBoard.getCurrentCourwareType();
                if(bgImgUrl == ""){
                    bmgImages.setCoursewareSource("",coursewareType,"",width,height,curriculumData.getCurrentToken());
                    return;
                }
                var imgSource = "image://offsetImage/" + Math.random();
                bmgImages.setCoursewareSource("",coursewareType,imgSource,width,height,curriculumData.getCurrentToken());
            }
        }

        WhiteBoard{
            id:whiteBoard
            z: 12
            clip: true
            width: parent.width
            height: parent.height
            smooth: true
            visible: netJustView.visible ? false : true
            enabled: isHandl

            onSigFocusTrailboard:{
                whiteBoard.focus = true;
            }

            //修改操作权限
            onSigAuthChange: {
                if(curriculumData.getCurrentUserId() == userId){
                    trailBoard.enabled = (trail == 0 ? true : false);
                    whiteBoard.enabled = (trail == 0 ? true : false);
                    bmgImages.updateH5EngineView(true);
                }
            }

            //图片的高度
            onSigCurrentImageHeight: {
                currentBeShowedIamgeHeight = height;
                console.log("**********currentImageHeight*************",currentBeShowedIamgeHeight)
                scrollbar.visible = false;
                if(currentBeShowedIamgeHeight > trailBoardBackground.height){
                    //scrollbar.visible = true;
                }
                whiteBoard.setCurrentImageHeight(height);
                whiteBoard.getOffSetImage(0.0,currentOffsetY,1.0);
            }

            onSigOffsetY: {
                currentOffsetY = offsetY;
                console.log("***********setYYYYYYY***************",currentBeShowedIamgeHeight,offsetY);
                if(currentBeShowedIamgeHeight == 0){
                    return;
                }

                var currentY =  -(scrollbar.height * offsetY * trailBoardBackground.height / currentBeShowedIamgeHeight);
                button.y  = currentY;

                scrollbar.visible = false;
                if(currentBeShowedIamgeHeight > trailBoardBackground.height){
                    //scrollbar.visible = true;
                }
                //console.log("=======sigOffsetY=======",offsetY,button.y,currentBeShowedIamgeHeight)
            }

            //老师操作教鞭
            onSigCursorPointer:{
                console.log("===sigCursorPointer===",pointx,pointy,statues);
                cursorPoint.x = pointx
                cursorPoint.y = pointy
                cursorPoint.visible = statues;
            }

            //教鞭
            onSigPointerPosition:{
                cursorPoint.x = xPoint * whiteBoard.width // -  cursorPoint.width / 2;
                cursorPoint.y = yPoint * trailBoardBackground.height //+ (- bmgImages.y / trailBoardBackground.height  )  )// bmgImages.height // -  cursorPoint.height / 2;
                cursorPoint.visible = true;
                cursorPointTime.restart();
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
                        whiteBoard.getOffsetImage(urlsa,0);
                        whiteBoard.getOffSetImage(0,0,1.0);
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
                        whiteBoard.getOffsetImage(urlsa,currentOffsetY);
                        whiteBoard.getOffSetImage(0,currentOffsetY,1.0);
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
                        whiteBoard.getOffsetImage(urlsa,currentOffsetY);
                        whiteBoard.getOffSetImage(0,currentOffsetY,1.0);
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

            //教鞭
            Item{
                id:cursorPoint
                width: 44 * ratesRates
                height: 44 * ratesRates
                x:0
                y:0
                visible: false
                z: 99
                Image{
                    anchors.fill: parent
                    source: "qrc:/miniClassImage/xbk_shubiao_brush.png"
                }
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



        }

        // 画布
        TrailBoard{
            id:trailBoard
            anchors.left: parent.left
            width: trailBoardBackground.width
            height: trailBoardBackground.height
            z:11
            clip: true
            onSigPageOpera: {
                if(type == "add"){
                    bmgImages.coursewareOperation(coursewareType,2,0,0);
                }
                if(type == "delete"){
                    bmgImages.coursewareOperation(coursewareType,3,0,0);
                }
            }

            onSigTeaOnline: {
                videoToolBackground.updateUserOnlineAuth("1",isOnline);
                if(isOnline == "0"){
                    cloudTipView.setTipViewText("老师不在教室内，不可进行操作");
                }
            }

            onSigClassBegin: {
                videoToolBackground.updateUserOnlineAuth("1",1);
            }

            onSigClearScreen: {
                coursewareType = 0;
                bmgImages.setCoursewareVisible(1,false);
                bmgImages.setCoursewareVisible(3,false);
                whiteBoard.clearScreen();
                videoToolBackground.resetStatus();
                rosterView.resetStatus();
                trailBoard.enabled = false;
                whiteBoard.enabled = false;
                cloudTipView.setTipViewText(qsTr("开始上课,课前操作将被清除!"));
            }

            onSigPlayAnimation: {
                bmgImages.coursewareOperation(coursewareType,5,pageId,step);
            }

            onSigSynCoursewareInfo: {
                bmgImages.coursewareSyn(jsonObj);
            }

            onSigH5Courseware: {
                coursewareType = docType;
                console.log("===onSigH5Courseware===",coursewareType,h5Url);
                if(docType == 3 && h5Url  != ""){
                    bmgImages.setCoursewareSource("",coursewareType,h5Url,parent.width,parent.height,curriculumData.getCurrentToken());
                }
                bmgImages.updateH5EngineView(false);
            }

            Component.onCompleted:
            {
                currentCourwareType = trailBoard.getCurrentCourwareType();
                if( trailBoard.checkReduceLesson() )
                {
                    trailBoard.getUnsatisfactoryOptions();
                }

            }

            onSigStartRandomSelectView:
            {
                if(3 == randomData.type )
                {
                    randomSelectionView.visible = false;
                    return;
                }

                randomSelectionView.randomByGiveData(curriculumData.getAllStudentInfo(),randomData.uid);
            }

            //抢答
            onSigStartResponder:
            {
                responderView.resetResponderView(responderData);
            }
            //计时器倒计时
            onSigResetTimerView: {
                timerView.resetViewData(timerData);
            }
            //音视频播放
            onSigPlayAv:
            {
                var suffix = avData.suffix;
                var controlType = avData.flagState
                var mediaPaht;// = loadInforMation.downLoadMedia(avData.path);
                console.log("onSigPlayAv",suffix,avData.path,mediaPaht);
                if(suffix.indexOf("mp3") != -1 || suffix.indexOf("wma") != -1 || suffix.indexOf("wav") != -1)
                {
                    mediaPlayer.stopVideo();
                    mediaPlayer.visible = false;
                    if(controlType == 2) {
                        audioPlayer.stopVideo();
                        return;
                    }else if(controlType == 0)
                    {
                        audioPlayer.pauseVideo();
                        audioPlayer.playTipContentTimes = parseInt(avData.playTimeSec) * 1000;
                        audioPlayer.setAudioUrl(avData.path);//"file:///" + mediaPaht);//
                    }else{
                        audioPlayer.playStatues = false;
                    }
                }else if(suffix.indexOf("mp4") != -1 || suffix.indexOf("avi") != -1 || suffix.indexOf("wmv") != -1 || suffix.indexOf("rmvb") != -1)
                {
                    audioPlayer.stopVideo();
                    if(controlType == 2) {
                        mediaPlayer.stopVideo();
                        mediaPlayer.visible = false;
                        return;
                    }else if(controlType == 0) {
                        mediaPlayer.pauseVideo();
                        mediaPlayer.playTipContentTimes = parseInt(avData.playTimeSec) * 1000;
                        mediaPlayer.setAudioUrl(avData.path);//"file:///" + mediaPaht);//
                    }else{
                        mediaPlayer.playStatues = false;

                    }
                    mediaPlayer.visible = true;
                }
            }

            onSigMuteChange: {//收到老是禁音或者恢复操作
                videoToolBackground.updateMute(userId,muteStatus);
            }

            onSigAuthChange: {//修改操作权限，上台，禁音，视频
                if(curriculumData.getCurrentUserId() == userId){
                    trailBoard.enabled = (trail == 0 ? false : true);
                    whiteBoard.enabled = (trail == 0 ? false : true);
                    bmgImages.updateH5EngineView(false);
                    console.log("==onSigAuthChange==",trailBoard.enabled);
                }
                //trailBoardBackground.enabled = (trail == 0 ? false : true);
                console.log("=====AuthChange===",userId,trail,up);
                isSynCompletes = isSynComplete;
                videoToolBackground.updateUserAuthorize(userId,up,trail,audio,video);
                rosterView.updateUserAuth(userId,up,trail,audio,video);
            }
            onSigTrophy: {//奖杯效果
                videoToolBackground.updateTrophy(userId);
                rosterView.updateReward(userId);
            }

            onSigInterNetChange: {
                sigInterNetworks(netStatus);
            }
            onSigGetUnsatisfactoryOptions:
            {
                sigGetUnsatisfactoryOptionsT(optionsData);
            }
            onSigCurrentImageHeight:
            {
                currentBeShowedIamgeHeight = 960.0;
                currentBeShowedIamgeHeight = imageHeight;
            }

            onSigFocusTrailboard:{
                trailBoard.focus = true;
            }

            onSigGetLessonListFail:
            {
                console.log(" onSigGetLessonListFail: onSigGetLessonListFail:");
                sigGetLessonListFails();
            }
            //视频控制流
            onSigVideoAudioUrl:{
                //  console.log("avType ==",avType ,"startTime ==",startTime ,"controlType ==",controlType,"avUrl ==",avUrl)
                trailBoardBackground.sigVideoAudioUrls(  avType, startTime , controlType , avUrl )
            }

            //重设 答案解析和 批改界面的显示
            onSigUpdateCloudModifyPageView:
            {
                cloudModifyPageView.resetAllItemView();
                modifyHomework.resetModifyView(questionData);
                knowledgesView.dataModel = questionData;
                // knowledgesView.answerModel = questionData.answer
                knowledgesView.childQuestionInfoModel = questionData.childQuestionInfo;

                console.log("重设 答案解析和 批改界面的显示",JSON.stringify(questionData))
            }

            onSigSendUrl:{
                console.log("onSigSendUrlonSigSendUrl",imageWRate,imageHRate,width,height,coursewareType,urls);
                currentCourwareType = trailBoard.getCurrentCourwareType();

                imageWRate = width;
                imageHRate = height;
                trailBoard.y = 0;
                currentBeShowedIamgeHeight = trailBoardBackground.height;
                bgImgUrl = urls;
                if(coursewareType == 3){
                    return;
                }

                var urlsa = urls.replace("https","http");
                if(urls.length > 0) {//
//                    bmgImages.source = ""; //这里刷新图片的时候必须先设置为空bmgImages.source = ""，否则无法刷新
//                    bmgImages.source = urlsa;
//                    bmgImages.update();
                    bmgImages.setCoursewareVisible(coursewareType,true);
                    bmgImages.setCoursewareSource("",coursewareType,urlsa,width,height,curriculumData.getCurrentToken());
                    if( bakcImages.height <  trailBoardBackground.height || trailBoard.getCurrentCourwareType() == 1 )
                    {
                        bakcImages.height = trailBoardBackground.height ;
                        trailBoard.height = trailBoardBackground.height ;
                        //bmgImages.y = 0;
                        trailBoard.y = 0;
                    }

                    screenshotSaveImage.deleteTempImage();

                    //截图
                    if( 0< width && width< 1)
                    {
//                        bmgImages.source = urlsa;
//                        bmgImages.update();
//                        bmgImages.height = trailBoardBackground.height * imageHRate;
//                        bmgImages.width = trailBoardBackground.width * imageWRate;
                        bmgImages.setCoursewareSource("",coursewareType,urlsa,trailBoardBackground.width * imageWRate, trailBoardBackground.height * imageHRate,curriculumData.getCurrentToken())
                    }
                }else {
                    console.log("******urls.length < 0************",coursewareType);
                    bmgImages.setCoursewareVisible(coursewareType,false);
                    //bmgImages.visible = false;
                    bakcImages.height = trailBoardBackground.height ;
                    trailBoard.height = trailBoardBackground.height ;
                    //bmgImages.y = 0;
                    trailBoard.y = 0;
                    currentBeShowedIamgeHeight = trailBoardBackground.height;
                    whiteBoard.setCurrentImgUrl("")
                    whiteBoard.setCurrentImageHeight(trailBoardBackground.height);
                    whiteBoard.getOffSetImage(0,0,1.0);
                }
            }

            onSigHideQuestionView:
            {
                //隐藏 新讲义页面
                console.log("onSigHideQuestionView 隐藏 新讲义页面");
                hideNewCursorView();
                cloudRoomMenu.visible = !hideColumnMenu;
                if( cloudRoomMenu.visible ==  true)
                {
                    cloudRoomMenu.visible = cloudRoomMenu.getModelCount() > 1 ? true : false;
                }
            }

            onSigUpdateCloumMenuIndex:
            {
                cloudRoomMenu.updateUiIndexview(columnId , "");
            }

            //提示打开跟关闭摄像头
            onSigUserIdCameraMicrophone: {

                //usrid , QString camera ,  QString microphone
                //   console.log("usrid ==",usrid ,"camera ==",camera ,"microphone ==",microphone);
                toopBracund.visible = false;
                toopBracundTimer.stop();
                //ids
                var isTeacher = curriculumData.isTeacher(usrid );
                var cname = curriculumData.getUserName(usrid);
                if(isTeacher == "1") {
                    if(curriculumData.getIsVideo() == "1")
                    {

                        if(cameraStatus != camera) {
                            if(camera != "1") {
                                //                                toopBracundImageText.text = qsTr("老师 ") + cname + qsTr(" 关闭本地摄像头");
                                //                                toopBracund.visible = false;
                                //                                toopBracund.visible = true;
                                cloudTipView.setTipViewText(qsTr("老师 ") + cname + qsTr(" 关闭本地摄像头"));
                            }

                        }else{
                            if(microphoneStatus != microphone) {
                                if(microphone != "1") {
                                    //                                    toopBracundImageText.text = qsTr("老师 ") + cname + qsTr(" 关闭本地麦克风");
                                    //                                    toopBracund.visible = false;
                                    //                                    toopBracund.visible = true;
                                    cloudTipView.setTipViewText(qsTr("老师 ") + cname + qsTr(" 关闭本地麦克风"));
                                }

                            }
                        }
                        cameraStatus =camera.toString();
                        microphoneStatus =microphone.toString();

                    }else
                    {
                        if(microphoneStatus != microphone) {
                            console.log("microphoneStatus",microphoneStatus,microphone,5);
                            if(microphone != "1") {
                                console.log("microphoneStatus",microphoneStatus,microphone,6);
                                //                                toopBracundImageText.text = qsTr("老师 ") + cname + qsTr(" 关闭本地麦克风");
                                //                                toopBracund.visible = false;
                                //                                toopBracund.visible = true;
                                cloudTipView.setTipViewText(qsTr("老师 ") + cname + qsTr(" 关闭本地麦克风"));
                            }

                        }
                        //cameraStatus =camera.toString();
                        microphoneStatus =microphone.toString();
                    }
                    console.log("microphoneStatus",cameraStatus,microphoneStatus,3);
                }else {
                    if(curriculumData.getIsVideo() == "1")
                    {
                        if(cameraStatus != camera) {
                            if(camera != "1") {
                                //                                toopBracundImageText.text = qsTr("学生 ") + cname + qsTr(" 关闭本地摄像头");
                                //                                toopBracund.visible = false;
                                //                                toopBracund.visible = true;
                                cloudTipView.setTipViewText(qsTr("学生 ") + cname + qsTr(" 关闭本地摄像头"));
                            }

                        }else{
                            if(microphoneStatus != microphone) {
                                if(microphone != "1") {
                                    //                                    toopBracundImageText.text = qsTr("学生 ") + cname + qsTr(" 关闭本地麦克风");
                                    //                                    toopBracund.visible = false;
                                    //                                    toopBracund.visible = true;
                                    cloudTipView.setTipViewText(qsTr("学生 ") + cname + qsTr(" 关闭本地麦克风"));
                                }

                            }
                        }

                        cameraStatus = camera.toString();
                        microphoneStatus = microphone.toString();

                    }else
                    {
                        if(microphoneStatus != microphone) {
                            if(microphone != "1") {
                                //                                toopBracundImageText.text = qsTr("学生 ") + cname + qsTr(" 关闭本地麦克风");
                                //                                toopBracund.visible = false;
                                //                                toopBracund.visible = true;
                                cloudTipView.setTipViewText(qsTr("学生 ") + cname + qsTr(" 关闭本地麦克风"));
                            }

                        }
                    }
                    microphoneStatus = microphone.toString();
                }

            }

            onSigSendHttpUrl:{
                animePlayBroundImage.source = "";
                animePlayBroundImage.paused = true;
                if(urls.length > 0) {
                    animePlayBroundImage.paused = false;
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
                if(coursewareType == 3 && currentPages != bottomToolbars.currentPage){
                    bmgImages.coursewareOperation(coursewareType,4,currentPage);
                }
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
                console.log("=====onSigStartClassTimeData====",times);
                toopBracund.visible = false;
                trailBoardBackground.sigStartClassTimeDatas(times);
                sigPromptInterfaceHandl("62");
                if(curriculumData.getUserBrushPermissions() == "1"){
                    isHandl = true;
                }else {
                    isHandl = false;
                }
            }

            onSigDroppedRoomIds:{
                toopBracund.visible = false;
                toopBracundTimer.stop();
                //ids
                var isTeacher = curriculumData.isTeacher(ids );
                var cname = curriculumData.getUserName(ids);
                if(isTeacher == "1") {
                    //                    toopBracundImageText.text = qsTr("老师 ") + cname + qsTr(" 掉线");
                    //                    toopBracund.visible = false;
                    //                    toopBracund.visible = true;
                    cloudTipView.setTipViewText(qsTr("老师 ") + cname + qsTr(" 掉线"));
                }else {
                    //                    toopBracundImageText.text = qsTr("学生 ") + cname + qsTr(" 掉线");
                    //                    toopBracund.visible = false;
                    //                    toopBracund.visible = true;
                    cloudTipView.setTipViewText(qsTr("学生 ") + cname + qsTr(" 掉线"));
                }

            }

            //有人退出教室
            onSigExitRoomIds:{
                toopBracund.visible = false;
                var ida = curriculumData.getUserType(ids );
                var cname = curriculumData.getUserName(ids);
                if(ida == "B") {
                    //                    toopBracundImageText.text = qsTr("学生 ") + cname + qsTr(" 退出教室");
                    //                    toopBracund.visible = false;
                    //                    toopBracund.visible = true;
                    cloudTipView.setTipViewText(qsTr("学生 ") + cname + qsTr(" 退出教室"));
                    return;
                }

                trailBoardBackground.sendExitRoomName(ida , cname);

            }

            onSigPromptInterface:{
                //处理老师结束课程 为a学生
                console.log("interfaces sssssssssss",interfaces)
                if(interfaces == "opencarm"){
                    videoToolBackground.setStartClassTimeData(100000);
                }
                if(interfaces == "65" ) {
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                //判断是否在线
                if(interfaces == "51") {
                    sigPromptInterfaceHandl(interfaces);
                }
                //改变频道跟音频
                if(interfaces == "61") {
                    sigPromptInterfaceHandl(interfaces);
                }
                //判断是否同意离开教室
                if(interfaces == "63" || interfaces == "64") {
                    //console.log("interfaces ==",interfaces)
                    sigPromptInterfaceHandl(interfaces);
                }

                //改编权限
                if(interfaces == "62") {
                    sigPromptInterfaceHandl(interfaces);
                    if( curriculumData.getAuthType() == true) //判断如果当期权限改变的不是本地用户 不弹窗
                    {
                        if(curriculumData.getUserBrushPermissions() == "1"){
                            //                            toopBracundImageText.text = qsTr("老师授权成功!")
                            //                            toopBracund.visible = false;
                            //                            toopBracund.visible = true;
                            cloudTipView.setTipViewText(qsTr("老师授权成功!"));
                            isHandl = true;

                        }else {
                            //                            toopBracundImageText.text = qsTr("老师取消授权!")
                            //                            toopBracund.visible = false;
                            //                            toopBracund.visible = true;
                            cloudTipView.setTipViewText(qsTr("老师取消授权!"));
                            isHandl = false;
                        }
                    }
                }
                if(interfaces == "0" || interfaces == "1" || interfaces == "2") {
                    sigPromptInterfaceHandl(interfaces);
                }
                //上过课
                if(interfaces == "22" ) {
                    //                    toopBracundImageText.text = qsTr("当前是自由操作模式只允许翻页!")
                    //                    toopBracund.visible = false;
                    //                    toopBracund.visible = true;
                    cloudTipView.setTipViewText(qsTr("当前是自由操作模式只允许翻页!"));
                    sigPromptInterfaceHandl("22");
                    isHandl = false;
                    return;
                }
                //上过课
                if(interfaces == "23" ) {
                    //                    toopBracundImageText.text = qsTr("当前是自由操作模式，开始上课后操作记录会被清空哦!")
                    //                    toopBracund.visible = false;
                    //                    toopBracund.visible = true;
                    //cloudTipView.setTipViewText(qsTr("当前是自由操作模式，开始上课后操作记录会被清空哦!"));
                    return;
                }

                //申请结束课程
                if(interfaces == "56"){
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }

                //翻页请求 同意
                if(interfaces == "70") {
                    sigPromptInterfaceHandl(interfaces);
                    //                    toopBracundImageText.text = qsTr("翻页请求已获得!")
                    //                    toopBracund.visible = false;
                    //                    toopBracund.visible = true;
                    cloudTipView.setTipViewText(qsTr("翻页请求已获得!"));
                    return;
                }
                //翻页请求 不同意
                if(interfaces == "71") {
                    sigPromptInterfaceHandl(interfaces);
                    //                    toopBracundImageText.text = qsTr("这一页还没讲完，先认真听讲吧!")//qsTr("这一页还没讲完，先认真听讲吧!")
                    //                    toopBracund.visible = false;
                    //                    toopBracund.visible = true;
                    cloudTipView.setTipViewText(qsTr("这一页还没讲完，先认真听讲吧!"));
                    return;
                }
                //老师收回权限
                if(interfaces == "72") {
                    sigPromptInterfaceHandl(interfaces);
                    //                    toopBracundImageText.text = qsTr("老师收回权限!")
                    //                    toopBracund.visible = false;
                    //                    toopBracund.visible = true;
                    cloudTipView.setTipViewText(qsTr("老师收回权限!"))
                    return;
                }
                //音视频的状态
                if(interfaces == "68") {
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                //B学生申请进入教室老师同意
                if(interfaces == "66")
                {
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                //B学生申请进入教室老师不同意
                if(interfaces == "67")
                {
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                //账号在其他地方登录
                if(interfaces == "80")
                {
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }


                //            if(interfaces == "2" ) {
                //                sigPromptInterfaceHandl("62");
                //                if(curriculumData.getUserBrushPermissions() == "1"){
                //                    isHandl = true;
                //                }else {
                //                    isHandl = false;
                //                }
                //                return;
                //            }


            }
            onJustNetConnect:
            {
                if(hasNetConnect)
                {
                    netJustView.visible = false;
                }else
                {
                    if(!curriculumData.isAutoDisconnectServer())
                    {
                        netJustView.visible = true;
                    }
                }
            }

            onAutoChangeIpResult:
            {
                console.log("sigPromptInterfaceHandl(autoChangeIpStatus)",autoChangeIpStatus)
                sigPromptInterfaceHandl(autoChangeIpStatus);
            }

            //新课件信号*********************************************************

            onSigShowNewCourseware:
            {
                sigShowNewCoursewares(coursewareData);
            }

            onSigShowNewCoursewareItem:
            {
                sigShowNewCoursewareItems(coursewareItemData);
            }

            onSigStarAnswerQuestion:
            {
                sigStarAnswerQuestions(questionData)
            }

            onSigStopAnswerQuestion:
            {
                sigStopAnswerQuestions(questionData)
            }

            onSigOpenAnswerParsing:
            {
                sigOpenAnswerParsings(questionData);
            }
            onSigCloseAnswerParsing:
            {
                sigCloseAnswerParsings(questionData);
            }

            onSigOpenCorrect:
            {
                sigOpenCorrects(questionData,isVisible);
            }

            onSigCloseCorrect:
            {
                sigCloseCorrects(questionData);
            }
            onSigCorrect:
            {
                sigCorrects(questionData);
            }
            onSigAutoPicture:
            {
                sigAutoPictures(questionData);
            }
            onSigZoomInOut:
            {
                button.y  = -(scrollbar.height * offsetY * trailBoardBackground.height / currentBeShowedIamgeHeight);
            }
        }
    }

    //滚动条
    Item {
        id: scrollbar
        anchors.right: parent.right
        anchors.top: parent.top
        width: 8 * heightRate
        height: parent.height
        visible: false//currentBeShowedIamgeHeight > trailBoardBackground.height ? true : false
        z: 166

        // 按钮
        Rectangle {
            id: button
            x: 2
            y: 0
            width: parent.width
            //new
            height: {
                var mutilValue = currentBeShowedIamgeHeight / parent.parent.height;
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
                // 拖动
                onMouseYChanged: {
                    var contentsY = button.y / scrollbar.height * currentBeShowedIamgeHeight
                    currentOffsetY = contentsY / trailBoardBackground.height;
                    console.log("onMouseYChanged: currentOffsetY",currentOffsetY);
                }


                onReleased: {
                    console.log("currentBeShowedIamgeHeight",currentBeShowedIamgeHeight,trailBoardBackground.height)
                    scrollImage( button.y / scrollbar.height * currentBeShowedIamgeHeight / trailBoardBackground.height  );
                    whiteBoard.getOffSetImage(0.0,button.y / scrollbar.height * currentBeShowedIamgeHeight / trailBoardBackground.height,1.0);
                }

            }

            MouseArea{
                anchors.fill: parent
                z:10
                enabled: !toobarWidget.teacherEmpowerment
                onClicked:
                {
                    console.log("toobarWidget.teacherEmpowerment",toobarWidget.teacherEmpowerment)
                    popupWidget.setPopupWidget("noselectpower");
                }
                onPressed:
                {
                    popupWidget.setPopupWidget("noselectpower");
                }
            }
        }
    }


    //没网的状态
    Rectangle{
        id: netJustView
        width: trailBoardBackground.width
        height: trailBoardBackground.height + 5 * ratesRates
        color: "white"
        visible: false
        z:10
        Image {
            width: 136 * ratesRates
            height: 154 * ratesRates
            anchors.centerIn: parent
            source: "qrc:/images/icon_nowifi.jpg"
        }
    }



    //动漫播放
    Rectangle{
        id:animePlayBround
        width: 118 * trailBoardBackground.height / 698
        height: 118 *trailBoardBackground.height / 698
        color: "#00000000"
        focus: false
        visible:false
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin:  ( parent.height - animePlayBround.height ) / 2
        anchors.leftMargin:   ( parent.width - animePlayBround.width ) / 2
        z:12
        AnimatedImage{
            id:animePlayBroundImage
            width: parent.width
            height: parent.height
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

    //奖杯动画
    Item{
        id: trophyView
        z: 12
        width: 130 * widthRate
        height: 130 * widthRate
        focus: false
        visible: false
        anchors.centerIn: parent

        AnimatedImage{
            id: animateTrophyImg
            anchors.fill: parent
            source: "qrc:/miniClassImage/xb_timg.gif"
        }
    }

    function showTrophy(){
        trophyView.visible = true;
        trophyTimer.restart();
    }

    Timer{
        id: trophyTimer
        interval: 3000
        repeat: false
        onTriggered: {
            trophyView.visible = false;
        }
    }

    //几何图形背景
    Rectangle{
        id:geometricFigureBakcground
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height:parent.height
        color:"#00000000"
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
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        visible: false
        z:19
        Image {
            id: digPicturesImage;
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectFit;
            asynchronous: true;
            source: ""
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
                    upAnimatedImage.visible = true;
                    var ad = 1.0 * maskPicture.maskPictureWidth / trailBoard.width;
                    var af = 1.0 * maskPicture.maskPictureHeight / trailBoard.height;
                    trailBoard.setPictureRate(ad ,af);
                    upAnimatedImage.visible = true;
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

        MouseArea{
            id:drawShape
            anchors.fill: parent
            cursorShape:Qt.ArrowCursor
            onPressed: {
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

    //上传图片等待界面
    Rectangle{
        id:upAnimatedImage
        anchors.left: parent.left
        anchors.top: parent.top
        width: trailBoard.width
        height: trailBoard.height
        color: "gray"
        visible: false
        z:20
        AnimatedImage{
            id:upAnimatedImages
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin:  parent.width / 2 - 15
            anchors.topMargin: parent.height / 2 - 15
            width: 30
            height: 30
            playing: true
            source: "qrc:/images/loading.gif"

        }
    }

    //提示框
    Rectangle{
        id:toopBracund
        color: "#3C3C3E"
        opacity: 0.6
        width: 400 * trailBoardBackground.widthRates
        height: 40 * trailBoardBackground.heightRates
        z:20
        anchors.left: trailBoardBackground.left
        anchors.bottom: trailBoardBackground.bottom
        anchors.leftMargin:  trailBoardBackground.width / 2 - 100 * trailBoardBackground.widthRates
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

    //截图
    ScreenshotSaveImage{
        id:screenshotSaveImage
        onSigSendScreenshotName:{
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
        onSigLoadingMedia:{
            cloudTipView.setTipViewText(qsTr("正在加载音视频课件,请稍后..."));
        }

        onSigUploadFileIamge:{
            upAnimatedImage.visible = false;
            if(!arrys) {
                //toopBracund.visible = true;
                //toopBracundImageText.text = qsTr("图片上传失败");
                cloudTipView.setTipViewText(qsTr("图片上传失败"));
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
        nameFilters: [ "Image files (*.jpg *.png)", "All files (*)" ]
        onAccepted: {
            var selectfiles = fileDialog.fileUrls;
            if(selectfiles.length > 0) {
                for(var i = 0; i < selectfiles.length; i++) {
                    var filesurlsa = "";
                    filesurlsa = selectfiles[i];

                    var filesurlsah = filesurlsa.replace("file:///","");
                    upAnimatedImage.visible = true;
                    trailBoard.setPictureRate(1.000,1.000);
                    loadInforMation.uploadFileIamge(filesurlsah);
                }


            }


            fileDialog.close();
        }
        onRejected: {
            fileDialog.close();
        }
    }

    CurriculumData{
        id:curriculumData
    }

    Rectangle{
        id:handlBakc
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        color: "#00000000"
        z:20
        visible: isHandl ? false : true
        MouseArea{
            anchors.fill: parent
        }
    }

    function sendResponderMsg(types,userName)
    {
        trailBoard.sendResponderMsg(types,userName);
    }

}

