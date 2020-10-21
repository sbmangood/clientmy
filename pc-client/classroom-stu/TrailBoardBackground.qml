import QtQuick 2.7
import TrailBoard 1.0
import MxResLoader 1.0
import QtQuick.Dialogs 1.2
import LoadInforMation 1.0
import ScreenshotSaveImage 1.0
import CurriculumData 1.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
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
    property  string  studentType: videoToolBackground.getCurrentUserType()

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
    function setOperationVideoOrAudio(userId ,  videos ,  audios , pingValue) {
        trailBoard.setOperationVideoOrAudio(userId ,  videos ,  audios , pingValue);
    }

    //设置画笔颜色
    function setPenColors(penColors) {
        trailBoard.setPenColor(penColors);
    }
    //改变画笔尺寸
    function changeBrushSizes(penWidths) {
        trailBoard.changeBrushSize(penWidths);
    }
    //设置橡皮擦
    function setCursorShapeType(types) {
        trailBoard.setCursorShapeTypes(types);

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

    //当前页数
    signal    sigChangeCurrentPages(int pages)

    //总页数
    signal    sigChangeTotalPages(int pages)
    //开始上课
    signal sigStartClassTimeData(string times);

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

            trailBoard.drawLocalGraphic(contents,trailBoardBackground.height,bmgImages.y);
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
            trailBoard.setInterfaceUrls(urls);
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

    function createRoomSuccess()
    {
        trailBoard.creatRoomSuccess();
    }

    Rectangle{
        id:cursorPoint
        width: 15 * ratesRates
        height: 15 * ratesRates
        radius: cursorPoint.height / 2
        color: "red"
        x:0
        y:0
        visible: false
        z:11
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
                    //                    var rate = 0.618;
                    //                    var imgheight = bmgImages.sourceSize.height;
                    //                    var imgwidth = bmgImages.sourceSize.width;
                    //                    var multiple = imgheight / imgwidth / rate
                    //                    var transImageHeight  = trailBoardBackground.height * multiple;

                    //                    bakcImages.height = transImageHeight ;
                    //                    trailBoard.height = transImageHeight ;
                    //                    bmgImages.height = transImageHeight ;

                    //                    console.log("=====Flickable::status======7777777777777",imgwidth,imgheight,trailBoard.height, bmgImages.height,trailBoardBackground.height,multiple)
                    //                    if( bakcImages.height <  trailBoardBackground.height || trailBoard.getCurrentCourwareType() == 1 )
                    //                    {
                    //                        bakcImages.height = trailBoardBackground.height ;
                    //                        trailBoard.height = trailBoardBackground.height ;
                    //                        bmgImages.y = 0;
                    //                        trailBoard.y = 0;
                    //                    }
                    //                    scrollbar.visible = false;
                    //                    if(bakcImages.height > trailBoardBackground.height){
                    //                        scrollbar.visible = true;
                    //                        console.log("******trailBoardBackground.height************")
                    //                    }
                    //                    console.log("=====Flickable::statuschange imageready ======",status,imageWRate);
                    //                    if( 0< imageWRate && imageWRate< 1)
                    //                    {
                    //                        bmgImages.height = trailBoardBackground.height * imageHRate;
                    //                        bmgImages.width = trailBoardBackground.width * imageWRate;
                    //                    }

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
                //                var rate = 0.618;
                //                var imgheight = bmgImages.sourceSize.height;
                //                var imgwidth = bmgImages.sourceSize.width;
                //                var multiple = imgheight / imgwidth / rate
                //                var transImageHeight  = Screen.height * multiple;

            }

        }


        Connections
        {
            target: getOffSetImage
            onReShowOffsetImage:
            {
                currentCourwareType = trailBoard.getCurrentCourwareType();
                console.log("onReShowOffsetImage");
                bmgImages.source = "";
                bmgImages.source = "image://offsetImage/" + Math.random();
                // console.log("bmgImages.source",bmgImages.source)
                bmgImages.width = trailBoardBackground.width;
                bmgImages.height = bmgImages.sourceSize.height < trailBoardBackground.height ? bmgImages.sourceSize.height :trailBoardBackground.height;
                bmgImages.visible = true;

            }
        }

        // 画布
        TrailBoard{
            id:trailBoard
            anchors.left: parent.left
            width: trailBoardBackground.width
            height: trailBoardBackground.height
            z:10
            clip: true

            Component.onCompleted:
            {
                currentCourwareType = trailBoard.getCurrentCourwareType();
                if( trailBoard.checkReduceLesson() )
                {
                    trailBoard.getUnsatisfactoryOptions();
                }

            }

            onSigVideoSpan:{
                videoToolBackground.updateVideoSpan(videoSpan);
            }

            onSigCouldUseNewBoard:
            {
                console.log("dsssssssdfwe132222qd",could)
                couldUseNewBoard = could;
            }

            onSigTeaChangeVersionToOld:
            {
                cloudTipView.setTeaCherVersionIsOld();
            }

            onSigInterNetChange: {
                sigInterNetworks(netStatus);
            }
            onSigGetUnsatisfactoryOptions:
            {
                sigGetUnsatisfactoryOptionsT(optionsData);
            }

            //new currentBeShowedIamgeHeight
            onHeightChanged:
            {
                console.log("trainBoardWidthChange",width,height)
            }
            onWidthChanged:
            {
                console.log("trainBoardheightChange",width,height)
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

            //教鞭
            onSigPointerPosition:{
                cursorPoint.x = xPoint * trailBoard.width // -  cursorPoint.width / 2;
                cursorPoint.y = yPoint * trailBoardBackground.height //+ (- bmgImages.y / trailBoardBackground.height  )  )// bmgImages.height // -  cursorPoint.height / 2;
                cursorPoint.visible = true;
                cursorPointTime.restart();
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
                console.log("onSigSendUrlonSigSendUrl",imageWRate,imageHRate,width,height);
                currentCourwareType = trailBoard.getCurrentCourwareType();

                imageWRate = width;
                imageHRate = height;
                bmgImages.visible = true;
                bmgImages.height = trailBoardBackground.height;
                bmgImages.width = trailBoardBackground.width;
                bmgImages.y = 0;
                trailBoard.y = 0;
                currentBeShowedIamgeHeight = trailBoardBackground.height;
                //scrollbar.visible = false;
                //                bmgImages.width = trailBoardBackground.width;
                //                bmgImages.source = "";
                //                imageSourceChageRectangle.visible= false;
                var urlsa = urls.replace("https","http");
                if(urls.length > 0) {//


                    //                                //bakcImages.width = trailBoard.width //* width;
                    //                                //bakcImages.height = trailBoard.height //* height;

                    //                                var rate = 0.618;
                    //                                var imgheight = bmgImages.sourceSize.height;
                    //                                var imgwidth = bmgImages.sourceSize.width;
                    //                                var multiple = imgheight / imgwidth / rate
                    //                                var transImageHeight  = trailBoardBackground.height * multiple  ;


                    //                                bakcImages.height = transImageHeight ;
                    //                                trailBoard.height = transImageHeight ;
                    //                                bmgImages.height = transImageHeight ;
                    bmgImages.source = ""; //这里刷新图片的时候必须先设置为空bmgImages.source = ""，否则无法刷新
                    bmgImages.source = urlsa;
                    bmgImages.update();
                    if( bakcImages.height <  trailBoardBackground.height || trailBoard.getCurrentCourwareType() == 1 )
                    {
                        bakcImages.height = trailBoardBackground.height ;
                        trailBoard.height = trailBoardBackground.height ;
                        bmgImages.y = 0;
                        trailBoard.y = 0;
                    }

                    //                                scrollbar.visible = false;
                    //                                if(bakcImages.height > trailBoardBackground.height){
                    //                                    scrollbar.visible = true;
                    //                                    console.log("******trailBoardBackground.height************")
                    //                                }

                    //                                bakcImages.visible = true;
                    //                                bmgImages.visible = true;
                    screenshotSaveImage.deleteTempImage();
                    //                                console.log("******urls.length > 0***********",width,bakcImages.height,trailBoard.height);

                    //截图
                    if( 0< width && width< 1)
                    {
                        bmgImages.source = urlsa;
                        bmgImages.update();
                        bmgImages.height = trailBoardBackground.height * imageHRate;
                        bmgImages.width = trailBoardBackground.width * imageWRate;
                    }
                }else {
                    console.log("******urls.length < 0************");
                    bmgImages.visible = false;
                    bakcImages.height = trailBoardBackground.height ;
                    trailBoard.height = trailBoardBackground.height ;
                    bmgImages.y = 0;
                    trailBoard.y = 0;
                    currentBeShowedIamgeHeight = 0;
                    // scrollbar.visible = false;

                    //trailBoard.visible = true;
                    //                    if(height == 1 )
                    //                    {
                    //                        bakcImages.height = trailBoard.parent.height ;
                    //                        trailBoard.height = trailBoard.parent.height ;
                    //                    }
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
                var isTeacher = videoToolBackground.isTeacher(usrid );
                var cname = videoToolBackground.getUserName(usrid);
                if(isTeacher == "1") {
                    if(videoToolBackground.getIsVideo() == "1")
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
                    if(videoToolBackground.getIsVideo() == "1")
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
                sigPromptInterfaceHandl("62");
                if(videoToolBackground.getUserBrushPermissions() == "1"){
                    isHandl = true;
                }else {
                    isHandl = false;
                }

            }
            onSigDroppedRoomIds:{
                toopBracund.visible = false;
                toopBracundTimer.stop();
                //ids
                var isTeacher = videoToolBackground.isTeacher(ids );
                var cname = videoToolBackground.getUserName(ids);
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
                var ida = videoToolBackground.getUserType(ids);
                var cname = videoToolBackground.getUserName(ids);
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
                    if( videoToolBackground.getAuthType() == true) //判断如果当期权限改变的不是本地用户 不弹窗
                    {
                        if(videoToolBackground.getUserBrushPermissions() == "1"){
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
                    cloudTipView.setTipViewText(qsTr("当前是自由操作模式，开始上课后操作记录会被清空哦!"));
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
                else if(interfaces == "1101")
                {
                    videoToolBackground.getListAllUserId(); //上麦以后, 更新老师视频窗口绑定的UserID
                    return;
                }


                //            if(interfaces == "2" ) {
                //                sigPromptInterfaceHandl("62");
                //                if(videoToolBackground.getUserBrushPermissions() == "1"){
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
                    if(!videoToolBackground.isAutoDisconnectServer())
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

                //                //重设书写面板
                //                console.log("重设书写面板",questionData.imageUrl,questionData.imgWidth,questionData.imgHeight)
                //                var urls = questionData.imageUrl.replace("https","http");
                //                if(urls.length > 0) {
                //                    //bakcImages.width = trailBoard.width ;
                //                    //bakcImages.height = bakcImages.height
                //                    bmgImages.source = urls;
                //                    bakcImages.visible = true;
                //                    screenshotSaveImage.deleteTempImage();
                //                    hideNewCursorView();
                //                    //cloudRoomMenu.visible = true;
                //                    trailBoardBackground.visible = true;
                //                }else {
                //                    bakcImages.visible = false;
                //                }
            }
            //            onSigZoomInOut:
            //            {
            //                scrollbar.visible = true;
            //                button.y  = -(scrollbar.height * offsetY * trailBoardBackground.height / bmgImages.height);
            //                bmgImages.y = (offsetY * trailBoardBackground.height);
            //                trailBoard.y = (offsetY * trailBoardBackground.height);
            //            }
            //new
            onSigZoomInOut:
            {
                //scrollbar.visible = true;
                button.y  = -(scrollbar.height * offsetY * trailBoardBackground.height / currentBeShowedIamgeHeight);
                //                bmgImages.y = (offsetY * trailBoardBackground.height);
                //                trailBoard.y = (offsetY * trailBoardBackground.height);
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
        visible: currentBeShowedIamgeHeight > trailBoardBackground.height ? true : false
        z: 166
        //        Rectangle{
        //            anchors.fill: parent
        //            color: "#eeeeee"
        //            anchors.horizontalCenter: parent.horizontalCenter
        //        }
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: 0
            width: parent.width
            /*  height: {
                var mutilValue = bakcImages.height / parent.parent.height;
                if(mutilValue > 1){
                    return parent.height / mutilValue;
                }else{
                    return parent.height * mutilValue;
                }
            }*/
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
                //                onMouseYChanged: {
                //                    var contentsY = button.y / scrollbar.height * bmgImages.height
                //                    bmgImages.y = -contentsY;
                //                    trailBoard.y = -contentsY;
                //                    //console.log("======contentsY=========",contentsY, contentsY + button.height);
                //                    //topicListView.contentY = button.y / scrollbar.height * topicListView.contentHeight
                //                }

                //                onReleased: {
                //                    scrollImage( - bmgImages.y / trailBoardBackground.height * bmgImages.height );
                //                }

                //                onMouseYChanged: {
                //                    var contentsY = button.y / scrollbar.height * currentBeShowedIamgeHeight
                //                    bmgImages.y = -contentsY;
                //                    trailBoard.y = -contentsY;
                //                    //console.log("======contentsY=========",contentsY, contentsY + button.height);
                //                    //topicListView.contentY = button.y / scrollbar.height * topicListView.contentHeight
                //                }
                onMouseYChanged: {
                    var contentsY = button.y / scrollbar.height * currentBeShowedIamgeHeight
                    currentOffsetY = contentsY / trailBoardBackground.height;
                    console.log("onMouseYChanged: currentOffsetY",currentOffsetY, currentBeShowedIamgeHeight, trailBoardBackground.height);
                }


                onReleased: {
                    console.log("currentBeShowedIamgeHeight",currentBeShowedIamgeHeight,trailBoardBackground.height)
                    scrollImage( button.y / scrollbar.height * currentBeShowedIamgeHeight / trailBoardBackground.height  );
                    trailBoard.getOffSetImage(0.0,button.y / scrollbar.height * currentBeShowedIamgeHeight / trailBoardBackground.height,1.0);
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



    //定时器
    Timer{
        id:cursorPointTime
        interval: 3000
        repeat: false
        running: false
        onTriggered: {
            cursorPoint.visible = false;
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

        //进入截图状态以后, 按住鼠标左键拖动, 指定截图的区域的事件
        MouseArea{
            id:drawShape
            anchors.fill: parent
            cursorShape:Qt.ArrowCursor
            onPressed: {
                mainView.doEnableDisableControls(true); //enable 部分控件
                //console.log("=======MouseArea onPressed========");

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

    function setRequestVideoSpans()
        {
            trailBoard.slotRequestVideoSpan();
            //console.log("========TrailBoardBackground=====setRequestVideoSpans=");
        }

}

