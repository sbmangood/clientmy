import QtQuick 2.5
import QtQuick.Window 2.2
import PainterBoard 1.0
import QtQuick.Controls 2.0
import QtMultimedia 5.5
import QtGraphicalEffects 1.0
import YMCloudClassManagerAdapter 1.0

Window {
    id: windowView
    width: Screen.width// * 0.7
    height:  Screen.height - 45//Screen.width * 0.7 / 966.0 * 700
    visibility: Window.Windowed
    visible: true
    color: "#00000000"
    flags: Qt.Window | Qt.FramelessWindowHint
    property double widthRate: Screen.width * 0.8 / 966.0;
    property double heightRate: widthRate / 1.5337;

    property var clickPos: [];
    property bool windowClick: false;
    property var currentLessonId: [];//当前课程Id
    property var currentPlanType: 0;//当前讲义类型
    property var orderNumber: [];//题目编号
    property bool isLoadingImage: false;//是否长图
    property bool isUploadImage: false;//是否是上传图片
    property int isHomework: 1;//习题模式 1:练习模式 2：老课件模式 3：批改模式 4:浏览模式
    property int currentImgWidth: 0;//当前图片宽度
    property int currentImgHeight: 0;//当前图片高度
    property string currentQuestionId: "";//当前题目Id
    property string currentImagePath: "";
    property var dataModel: [];

    property int loadImgWidth: 0;//加载图片宽度
    property int loadImgHeight: 0;//加载图片高度
    property int planTypes: -1;//head图片

    property double clipImgWidth: 0.0;//截图比例宽度
    property double clipImgHeight: 0.0;//截图比例高度

    //批改属性定义
    property string childQuestionId: "";//小题Id
    property int currentScore: 0;//得分
    property int correctType: -1;//批改类型
    property string errorReason: "";//错因

    property bool isClipImage: false;//是否时截图课件
    property double currentOffsetY: 0;//当前滚动条的坐标

    property int totalTime: 0;//结束总时间

    Video{
        id: audioMedia
        autoLoad: true
        autoPlay: true
    }

    ListModel{
        id: planModel
    }

    TipKickOutView{
        id: kickOutView
        z: 66
        width: 300 * widthRate
        height:  240 *  heightRate
        anchors.centerIn: parent
        visible: false
    }

    YMCloudClassManagerAdapter{
        id: cloudMgr
        onSigQuestionInfo: {
            getQuestionItems(dataObjecte,answerArray,photosArray,false);
            console.log("========onSigQuestionInfo==========",dataObjecte.questionType);
        }
        //获取讲义失败
        onSigGetQuestionFail: {
            kickOutView.visible = true;
        }

        onSigErrorList: {
            modifyHomework.updateErrorList(errorList);
        }

        onSigLearningTarget: {
            var type = 0;
            compositeTopicView.visible = false;
            showQuestionHandlerView.visible = true;
            showQuestionHandlerView.setCurrentBeShowedView(dataObjecte,type,1,1);
        }

        onSigHandoutInfo: {
            planModel.clear();
            for(var i = 0; i < dataArray.length; i++){
                //console.log("=====dataArray======",dataArray[i].id,dataArray[i].planName,dataArray[i].createName,dataArray[i].planType);
                planModel.append(
                            {
                                "id": dataArray[i].id,
                                "key": dataArray[i].planName,
                                "value": dataArray[i].id,
                                "createName": dataArray[i].createName,
                                "planDesc": dataArray[i].planDesc,
                                "planName": dataArray[i].planName,
                                "planType": dataArray[i].planType,
                            })
            }
        }
        onSigHandoutMenuInfo: {
            if(dataModel.length > 0){
                dataModel.splice(0,dataModel.length);
            }
            for(var i = 0; i < dataArray.length; i++){
                dataModel.push(
                            {
                                "itemId":dataArray[i].itemId,
                                "itemName": dataArray[i].itemName,
                                "itemType": dataArray[i].itemType,
                                "planId": dataArray[i].planId,
                            })
            }
            cloudMenu.dataModels = dataModel;
            cloudMenu.visible = true;
        }
    }

    Rectangle{
        id: bgItem
        anchors.fill: parent
        radius:  16
        color: "#f3f3f3"
        border.color: "#3c3c3e"
        border.width: 1
    }

    MouseArea{
        id: loadingImageAnimate
        anchors.fill: parent
        z: 100
        visible: false
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle{
            anchors.fill: parent
            color: "#c0c0c0"
            opacity: 0.2
        }

        AnimatedImage {
            width: 32 * widthRate
            height: 32 * widthRate
            source: "qrc:/images/loading.gif"
            anchors.centerIn: parent
        }
    }

    //头显示信息
    Rectangle{
        id: headView
        width: parent.width
        height: 45 * heightRate
        anchors.top: parent.top

        Rectangle{
            anchors.fill: parent
            color: "#3c3c3e"
            radius:  12
        }
        Rectangle{
            width: parent.width
            height: parent.height * 0.5
            color: "#3c3c3e"
            anchors.bottom: parent.bottom
        }
        MouseArea{
            anchors.fill: parent
            onPressed: {
                clickPos  = Qt.point(mouse.x,mouse.y)
            }

            onPositionChanged: {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                windowView.setX(windowView.x+delta.x)
                windowView.setY(windowView.y+delta.y)
            }
            onReleased: {
                if(!windowClick){
                    var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y);
                    var contentPoint = Qt.point(windowView.x + delta.x,windowView.y +delta.y)
                    windowView.setX(contentPoint.x);
                    windowView.setY(contentPoint.y);
                }
                windowClick = false;
            }
        }

        YMMenuView{
            id: menuView
            anchors.fill: parent
            onSetMin: {
                windowView.visibility = Window.Minimized;
            }
            onSetMax: {
                if(windowView.visibility == Window.Windowed){
                    windowView.width = Screen.width* 0.7;
                    windowView.height = Screen.width * 0.7 / 966.0 * 700.0
                    windowView.setX((Screen.width - windowView.width) * 0.5);
                    windowView.setY((Screen.height - windowView.height) * 0.5);
                }else{
                    windowView.visibility = Window.Maximized;
                }
            }

            onSetClose: {
                cloudMgr.doUpload_LogFile(); //上传本地日志, 到服务器
                Qt.quit();
            }
        }
    }

    Timer{
        id: loadingImg
        interval: 800
        repeat: false
        running: false
        onTriggered: {
            backImage.visible = true;
            painterBoardMgr.getOffsetImage(currentImagePath,currentOffsetY);
            painterBoardMgr.getOffSetImage(0,currentOffsetY,1.0);
        }
    }

    //新课件则显示head
    //新课件则显示当前菜单栏的标题
    //老课件不显示head但是要居中显示
    Image {
        id: titelImg
        source: "qrc:/images/pc_fixtitle_bg@2x.png"
        width: midWidth
        height: width / 16
        anchors.top: headView.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        visible: planTypes == 1
        onWidthChanged:{
            console.log(" id: titelImg",width,height)
        }

        Text {
            id: midTipTexts
            anchors.centerIn: parent
            text: qsTr("例题精讲")
            font.family: "Microsoft YaHei"
            font.pixelSize: 21 * heightRate
            color: "#333333"
        }

        onVisibleChanged:{
            if(visible){
                mainView.anchors.topMargin = headView.height + height;
            }else{
                mainView.anchors.topMargin = (windowView.height - midHeight ) * 0.5;
            }
        }
    }

    //画布区域
    Rectangle{
        id: mainView
        z: 2
        clip: true
        width: midWidth//parent.width
        height: midHeight//parent.height - headView.height - playerControl.height
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        Image{
            id: backImage
            z: 5
            clip: true
            width: parent.width
            height: parent.height
            mipmap: true

            onStatusChanged: {
                backImage.y = 0;
                if(status == Image.Error){
                    return;
                }

                //console.log("===onStatusChanged===",source,isClipImage,isLoadingImage,isUploadImage);
                if(source == ""){
                    backImage.width = mainView.width ;
                    backImage.height = mainView.height;
                    return;
                }

                if(isClipImage){
                    //console.log("======isClipImage=========",clipImgWidth,clipImgHeight)
                    backImage.width = mainView.width * clipImgWidth;//backImage.sourceSize.width > mainView.width ? mainView.width : backImage.sourceSize.width;
                    backImage.height = mainView.height * clipImgHeight;//backImage.sourceSize.height > mainView.height ? mainView.height : backImage.sourceSize.height;
                    return;
                }
                if(isUploadImage){
                    backImage.width = mainView.width;
                    backImage.height = mainView.height;
                    return;
                }
                if(isClipImage == false && isUploadImage == false && isLoadingImage == false){
                    backImage.width = backImage.sourceSize.width > mainView.width ? mainView.width : backImage.sourceSize.width;
                    backImage.height = backImage.sourceSize.height > mainView.height ? mainView.height : backImage.sourceSize.height;
                    return;
                }

                if(isLoadingImage){
                    var rate = 0.618;
                    var imgheight = loadImgHeight == 0 ? backImage.sourceSize.height : loadImgHeight;
                    var imgwidth = loadImgWidth == 0 ? backImage.sourceSize.width : loadImgWidth;
                    var multiple = imgheight / imgwidth / rate
                    var transImageHeight  = mainView.height * multiple;
                    var transImageWidth  = mainView.width * multiple;
//                    if(transImageHeight < currentImgHeight){
//                        transImageHeight = transImageHeight + headView.height +playerControl.height;
//                    }

                    //console.log("=====imagesourceSize:=======",mainView.width,backImage.sourceSize,transImageHeight,imgheight,imgwidth,loadImgHeight,loadImgWidth);
                    backImage.width = mainView.width;
                    backImage.height = transImageHeight;
                }
            }
        }

        Connections{
            target: getOffSetImage
            onReShowOffsetImage: {
                //console.log("onReShowOffsetImage",width,height);
                if(width == 0 && height == 0){
                    return
                }

                loadImgWidth = width;
                loadImgHeight = height;
                isClipImage = false;
                isLoadingImage = true;
                backImage.source = "image://offsetImage/" + Math.random();
                backImage.visible = true;
                showQuestionHandlerView.visible = false;
                compositeTopicView.visible = false;
                //console.log("===onReShowOffsetImage===",width,height);
            }
            onSigDownLoadSuccess:{
                //console.log("=====downStatus======",downStatus);
                if(downStatus){
                    loadingImageAnimate.visible = true;
                }else{
                    loadingImageAnimate.visible = false;
                }
            }
        }

        YMVideoPlayer{
            id: videoPlayer
            z: 6
            visible: false
            width: 450 * widthRate
            height: 430 * heightRate
            x:((parent.width - windowView.width) * 0.5);
            y:((parent.height - windowView.height) * 0.5);
        }

        CloudRoomMeun{
            id: cloudMenu
            z: 8
            visible: false
            height: 50 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            onSigSendMenuName:{
                midTipTexts.text = menuName;
            }
        }

        //答案解析
        KnowledgesView{
            id: knowledgesView
            z: 3           
            height: parent.height - 30 * heightRate
            onClosed: {
                //trailBoardBackground.closeAnswerParsing(planId,columnId,currentQuestionId);
            }
        }

        //批改页面
        CloudModifyHomeworkView{
            id: modifyHomework
            z: 3
            height: parent.height - 30 * heightRate
        }

        //五大题型
        ShowQuestionHandlerView{
            id: showQuestionHandlerView
            z: 5
            x: 0
            width: parent.width
            height: parent.height
            anchors.top: parent.top
            anchors.topMargin: 40 * heightRate
            onSigShowCorrectPage: {
                //console.log("======ShowQuestionHandlerView::onSigShowCorrectPage==========",filePath,status,imgWidth,imgHeight)
                showQuestionHandlerView.visible = false;
                compositeTopicView.visible = false;

                if(status == 0){
                    showQuestionHandlerView.visible = true;
                }

                if(status == 5){
                    showQuestionHandlerView.visible = false;
                    return;
                }

                if(status == 2 || status == 4){
                    currentImgHeight = imgHeight;
                    currentImagePath = filePath;
                    loadingImg.restart();
                    //console.log("**************status*************",status);
                }
            }
        }

        //综合题页面
        CloudCompositeTopicView{
            id: compositeTopicView
            z: 5
            visible:  false
            width: parent.width
            height: parent.height
            anchors.top: parent.top
            anchors.topMargin: 40 * heightRate
            onSigCorrect:{
                showQuestionHandlerView.visible = false;
                compositeTopicView.visible = true;
                console.log("======compositeTopicView::=======",filePath,status)

                if(status == 2 || status == 4){
                    currentImagePath = filePath;
                    currentImgHeight =imgHeight;
                    loadingImg.restart();
                    compositeTopicView.visible = false;
                }
            }
        }

        //教鞭
        Rectangle{
            id:cursorPoint
            width: 12 * heightRate
            height: 12 * heightRate
            radius: height / 2
            color: "red"
            x:0
            y:0
            visible: false
            z: 6
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

        PainterBoard{
            id: painterBoardMgr
            z: 5
            clip: true
            visible: true
            focus: true
            anchors.fill: parent

            onSigCursorPointer: {
                cursorPoint.x = pointx;
                cursorPoint.y = pointy;
                cursorPoint.visible = true;
                cursorPointTime.restart();
            }

            //图片的高度
            onSigCurrentImageHeight: {
                currentImgHeight = height;
                //console.log("=======onSigCurrentImageHeight==========",height,currentOffsetY);
                painterBoardMgr.getOffSetImage(0.0,currentOffsetY,1.0);
            }

            //讲义显示信号
            onSigPlanInfo: {
                if(planType == "2" || planType == 100){
                    planType = -1;
                }else{
                    planType = 1;
                }
                cloudMgr.getIdByColumnInfo(0,planId,0,"");
            }
            //栏目选中信号
            onSigColumnInfo: {
                cloudMenu.updateSelected(planId,columnId);
            }

            //题目信号
            onSigQuestionInfo: {
                cloudMgr.filterQuestionInfo(planId,columnId,questionId);
            }
            //翻页题目信号
            onSigCurrentQuestionId: {
                cloudMgr.filterQuestionInfo(planId,columnId,questionId);
            }

            //答案解析面板信号
            onSigIsOpenAnswer: {
                if(answerStatus){
                    knowledgesView.x = parent.width - knowledgesView.width;
                    knowledgesView.y = 0;
                    knowledgesView.updateCheckQuestion(questionId,childQuestionId);
                    knowledgesView.open();
                }
                if(answerStatus == false){
                    knowledgesView.close();
                }
            }

            //批改面板
            onSigIsOpenCorrect: {
                if(correctStatus){
                    modifyHomework.x =  parent.width - modifyHomework.width;
                    modifyHomework.y = 0;
                    modifyHomework.open();
                }
                if(correctStatus == false){
                    modifyHomework.close();
                }
            }
            //显示做题图片
            onSigCommitImage: {
                isLoadingImage = true;
                currentOffsetY = 0;
                painterBoardMgr.getOffsetImage(imageUrl,0);
                backImage.width = parent.width;
                backImage.source = imageUrl;
                console.log("=======onSigCommitImage========",imageUrl)
            }
            //滚动图片
            onSigZoomInOut:{
                currentOffsetY = offsetY;
                //painterBoardMgr.setCurrentImgHeight(currentImgHeight);
                painterBoardMgr.getOffSetImage(0.0,offsetY,1.0);
                console.log("======currentOffsetY========",currentOffsetY,currentImgHeight);
            }

            onSigSetCurrentTime:{
                playerControl.sliderValue = time;
                playerControl.startTimeText =  dateFromart(time);

                //播放结束以后, 将按钮置为播放状态
                if(time == 0){
                    playerControl.playerStatus = false;
                }

                if(time > totalTime){
                    painterBoardMgr.stop();
                    cloudMenu.visible = false;
                }
            }

            onSigSetTotalTime:{
                totalTime = seconds;
                playerControl.mediaTotalTimer = seconds;
                playerControl.endTimeText = dateFromart(seconds);
            }

            onChangeBgimg: {
                isClipImage = false;
                isUploadImage = false;
                isLoadingImage = true;
                showQuestionHandlerView.visible = false;
                compositeTopicView.visible = false;
                var d_currentHeight = currentImgHeight > parent.height ? parent.height : currentImgHeight;
                painterBoardMgr.setCurrentImgHeight(d_currentHeight);//parent.height);
                console.log("====onChangeBgimg::old======",url,width,height,isClipImage,isLoadingImage,questionId,isUploadImage,currentImgHeight);
                if(width < 1 && height < 1 && url  != ""){
                    isClipImage = true;
                    clipImgWidth = width;
                    clipImgHeight = height;
                    loadingImg.stop();
                }

                if(questionId  == "" || questionId == "-1" || questionId == "-2"){
                    isLoadingImage = false;
                }
                if(width == 1 && height == 1 && url != ""){
                    currentImgHeight = parent.height;
                    isUploadImage = true;
                }
                if(isUploadImage){
                    currentImgHeight = parent.height;
                    loadingImg.stop();
                }
                if(newPlay && isUploadImage){
                    console.log("====loadingImage===")
                    painterBoardMgr.getOffsetImage(url,currentOffsetY);
                    painterBoardMgr.getOffSetImage(0,currentOffsetY,1.0);
                    return;
                }
                if(isLoadingImage){
                    painterBoardMgr.getOffSetImage(0,currentOffsetY,1.0);
                }

                loadImgWidth =width
                loadImgHeight = height;
                backImage.source = url;
                backImage.visible = true;
                //console.log("====onChangeBgimg::new======",url,width,height,isClipImage,isLoadingImage,questionId,isUploadImage);
            }
            onSigChangePlayBtnStatus: {
                playerControl.playerStatus = false;
                videoPlayer.visible = false;
                audiaPlayer.visible = false;                
                cloudMenu.visible = false;
                videoPlayer.closeVideo();
                audiaPlayer.closeAudio();
                //console.log("====onSigChangePlayBtnStatus====");
            }
            onSigPlayerMedia: {
                //console.log("=====onSigPlayerMedia====",vaType,fileUrl);
                if(vaType == "audio" && fileUrl  != ""){
                    videoPlayer.visible == false;
                    if(controlType == "stop"){
                        audiaPlayer.visible = false;
                        videoPlayer.visible = false;
                        return;
                    }
                    audiaPlayer.ymAudioPlayerManagerPlayFileByUrl(fileUrl,"",startTime,controlType)
                }
                if(vaType == "video" && fileUrl  != ""){
                    audiaPlayer.visible = false;
                    if(controlType == "stop"){
                        videoPlayer.visible = false;
                        audiaPlayer.visible = false;
                        return;
                    }
                    videoPlayer.ymVideoPlayerManagerPlayFielByFileUrl(fileUrl, "", startTime);
                }
            }

            onSigPlayerAudio: {
                //console.log("===========",audioPaht)
                audioMedia.source = audioPaht;
            }

            onSigPlayer: {
                audioMedia.play();
                //console.log("=====play======")
            }
            onSigSeek: {
                audioMedia.seek(values * 1000);
                //console.log("=====values======",values)
            }
        }
    }

    YMAudioPlayer{
        id: audiaPlayer
        z: 66
        visible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: playerControl.top
    }

    //播放暂停时间区域
    YMPlayerControl{
        id: playerControl
        z: 99
        width: parent.width
        height: 60 * heightRate
        radius: 12
        anchors.bottom: parent.bottom
        onPlayerMedia: {
            audioMedia.play();
            painterBoardMgr.start();
        }
        onPauseMedia: {
            audioMedia.pause()
            painterBoardMgr.pause();
        }
        onSeekMedia: {
            knowledgesView.close();
            modifyHomework.close();
            painterBoardMgr.redirect(position,true);
        }
    }

    Component.onCompleted: {
        menuView.displayerText = boardList[2];
        var lessonId =  boardList[0];//"623124"//
        var date =  boardList[1];//"201708"//
        var filePath = boardList[3];//"C:/Users/Administrator/Documents/YiMi/201712/623124";//
        var trailName = boardList[4]//"8.encrypt";//

//        menuView.displayerText = "2618219";
//        var lessonId =  "2618219"//
//        var date =  "201907"//
//        var filePath = "C:/Users/Administrator/Documents/YiMi/201907/2618219";//
//        var trailName = "1.encrypt";//

        currentLessonId = lessonId;
        painterBoardMgr.setVideoPram(lessonId,date,filePath,trailName);
        cloudMgr.getLessonList(lessonId);
    }

    function dateFromart(time){
        var hours =  time / 60 / 60;
        var minutes  = time / 60 % 60;
        var second =  time % 60
        return addZero(hours) + ":" + addZero(minutes) + ":" + addZero(second);
    }

    //时间小于2位加0
    function addZero(temp){
        if(temp < 10){
            return "0" + parseInt(temp);
        }else{
            return parseInt(temp);
        }
    }

    function getQuestionItems(questionItemsData,answerArray,photosArray,browseStatus){
        if(questionItemsData.questionType == undefined || questionItemsData == null){
            console.log("*******getQuestionItems::return********",questionItemsData)
            return;
        }
        backImage.visible = false;
        var knowledgesModels = questionItemsData.knowledges //Cfg.zongheti.knowledges;
        var answerModel = questionItemsData.answer //Cfg.zongheti.answer;
        var questionItems = questionItemsData.questionItems //Cfg.zongheti.questionItems;
        var type = questionItemsData.questionType //Cfg.zongheti.questionType;
        var childQuestionInfo = questionItemsData.childQuestionInfo;
        var questionStatus = questionItemsData.status;

        windowView.orderNumber = questionItemsData.orderNumber;//题目编号
        knowledgesView.dataModel = questionItemsData;
        //knowledgesView.answerModel = answerModel;
        knowledgesView.childQuestionInfoModel = childQuestionInfo;
        modifyHomework.dataModel = questionItemsData;

        //console.log("========questionItemsData==========",JSON.stringify(questionItemsData));

        if(type == 6){
            showQuestionHandlerView.visible = false;
            console.log("======综合题6=======");
            compositeTopicView.visible = true;
            compositeTopicView.answerModel = answerArray;
            compositeTopicView.dataModel = questionItemsData;
            return;
        }

        compositeTopicView.visible = false;
        windowView.childQuestionId = "";
        windowView.currentScore = questionItemsData.score;
        windowView.correctType = questionItemsData.isRight;
        windowView.errorReason = questionItemsData.errorType;

        //五大题型展示
        showQuestionHandlerView.knowledgesModels = knowledgesModels;
        showQuestionHandlerView.answerModel = answerModel;
        showQuestionHandlerView.questionItemsData = questionItems;
        showQuestionHandlerView.setCurrentBeShowedView(questionItemsData,type,false,1);
        showQuestionHandlerView.visible = true;
    }
}

