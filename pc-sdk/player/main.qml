import QtQuick 2.5
import QtQuick.Window 2.2
import PlayManager 1.0
import TrailRender 1.0
import QtQuick.Controls 2.0
import QtMultimedia 5.5
import QtGraphicalEffects 1.0
import FileDownload 1.0
//import YMCloudClassManagerAdapter 1.0

Window {
    id: windowView
    width: Screen.width
    height:  Screen.height
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
    property int currentDocType: 0;
    property string currentToken: "";
    property string appId;
    property string liveroomId;
    property string apiUrl;

    Video{
        id: audioMedia
        autoLoad: true
        autoPlay: true
    }

    ListModel{
        id: planModel
    }

    Rectangle{
        id: bgItem
        anchors.fill: parent
        color: "#4A4C5F"
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
        height: 62 * heightRate
        anchors.top: parent.top
        color: "#4A4C5F"

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
                playManager.uploadLogFile(); //上传本地日志, 到服务器
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
            trailRender.getOffsetImage(currentImagePath,currentOffsetY);
            trailRender.getOffSetImage(0,currentOffsetY,1.0);
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

    Timer{
        id: trophyTimer
        interval: 3000
        repeat: false
        onTriggered: {
            trophyView.visible = false;
        }
    }

    //画布区域
    Rectangle{
        id: mainView
        z: 2
        clip: true
        width: midWidth//parent.width
        height: midHeight//parent.height - headView.height - playerControl.height
        anchors.centerIn: parent

        CourseWareControlView{
            id: backImage
            z: 5
            clip: true
            width: parent.width
            height: parent.height
            currentBeshowViewType: currentDocType
        }

/*
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
*/

        Connections{
            target: getOffSetImage
            onReShowOffsetImage: {
                //console.log("onReShowOffsetImage",width,height);
                if(currentDocType == 3){
                    return;
                }

                if(width == 0 && height == 0){
                    return
                }

                loadImgWidth = width;
                loadImgHeight = height;
                isClipImage = false;
                isLoadingImage = true;
                var imgSource = "image://offsetImage/" + Math.random();
                //backImage.visible = true;
                backImage.setCoursewareSource("",currentDocType,imgSource,width,height,currentToken);
                showQuestionHandlerView.visible = false;
                compositeTopicView.visible = false;
                //console.log("===onReShowOffsetImage===",currentDocType,width,height,backImage.source);
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

        //教鞭
        Item{
            id:cursorPoint
            width: 44 * heightRate
            height: 44 * heightRate
            x:0
            y:0
            visible: false
            z: 6
            Image{
                anchors.fill: parent
                source: "qrc:/images/xbk_shubiao_brush.png"
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

        YMTipsMediaPlayView{
            id: mediaPlayView
            anchors.centerIn: parent
            visible: false
            onSigOk: {
                playManager.setMediaStatus(true)
                playManager.play();
                audioMedia.play();
            }
            onSigCancel: {
                playManager.setMediaStatus(false)
                playManager.play();
                audioMedia.play();
            }
        }

        TrailRender{
            id: trailRender
            z: 5
            clip: true
            visible: true
            focus: true
            anchors.fill: parent

            //滚动图片
            onSigZoomInOut:{
                currentOffsetY = offsetY;
                //playManager.setCurrentImgHeight(currentImgHeight);
                trailRender.getOffSetImage(0.0,offsetY,1.0);
                console.log("======currentOffsetY========",currentOffsetY,currentImgHeight);
            }

            onSigChangeBgimg: {
                isClipImage = false;
                isUploadImage = false;
                isLoadingImage = true;
//                showQuestionHandlerView.visible = false;
//                compositeTopicView.visible = false;

                if(currentDocType == 3){
                    backImage.setCoursewareSource("",currentDocType,url,parent.width,parent.height,currentToken);
                    trailRender.getOffSetImage(0,0,1.0);
                    return;
                }
                var d_currentHeight = currentImgHeight > parent.height ? parent.height : currentImgHeight;
                trailRender.setCurrentImgHeight(d_currentHeight);//parent.height);
                //console.log("====onChangeBgimg::old======",url,width,height,isClipImage,isLoadingImage,questionId,isUploadImage,currentImgHeight);
                if(width < 1 && height < 1 && url  != ""){
                    isClipImage = true;
                    clipImgWidth = width;
                    clipImgHeight = height;
                    loadingImg.stop();
                }

                if(width == 1 && height == 1 && url != ""){
                    isUploadImage = true;
                }

                if(newPlay && isUploadImage){
                    console.log("====loadingImage===",url,currentOffsetY);
                    trailRender.getOffsetImage(url,currentOffsetY);
                    trailRender.getOffSetImage(0,currentOffsetY,1.0);
                    return;
                }
                if(isLoadingImage){
                    trailRender.getOffSetImage(0,currentOffsetY,1.0);
                }

                loadImgWidth =width
                loadImgHeight = height;
                //backImage.source = url;
                //backImage.visible = true;
                console.log("====onChangeBgimg::new======",url,width,height,isClipImage,isLoadingImage,questionId,isUploadImage);
            }

            onSigCursorPointer: {
                cursorPoint.x = pointx;
                cursorPoint.y = pointy;
                cursorPoint.visible = true;
                cursorPointTime.restart();
            }

        }

        //画板区域
        PlayManager{
            id: playManager
            z: 5
            clip: true
            visible: true
            focus: true
            anchors.fill: parent

            onSigPlayMediaTips: {
                mediaPlayView.visible = true
                audioMedia.pause();
            }

            onSigPageOpera: {
                if(type == "add"){
                    backImage.coursewareOperation(currentDocType,2,0,0);
                }
                if(type == "delete"){
                    backImage.coursewareOperation(currentDocType,3,0,0);
                }
            }

            onSigPlayAnimation: {
                backImage.coursewareOperation(currentDocType,5,pageId,step);
            }

            onSigSynCoursewarePage: {
                backImage.coursewareOperation(currentDocType,4,page,0);
            }

            onSigSynCoursewareType: {
                currentDocType = coursewareType;
                currentToken = token;
                //console.log("===onSigSynCoursewareType===",coursewareType,h5Url,token)
                if(coursewareType == 3){
                    if(h5Url == ""){
                        return;
                    }
                    backImage.updateH5EngineView(false);
                }
                backImage.setCoursewareSource("",coursewareType,h5Url,parent.width,parent.height,token);
            }

            onSigSynCoursewareInfo: {
                backImage.coursewareSyn(jsonObj);
            }

            //计时器倒计时
            onSigTimer: {
                console.log("===onSigTimer===",JSON.stringify(timerDataJson));
                timerView.resetViewData(timerDataJson);
            }

            //随机选人信号
            onSigRoll: {
                console.log("===rollDataJson===",JSON.stringify(rollDataJson))
                if(rollDataJson.type == 3)
                {
                    randomSelectionView.visible = false;
                    return
                }
                randomSelectionView.randomByGiveData(rollDataJson.name);
            }
            //抢答器信号
            onSigResponder: {
                responderView.resetResponderView(responderData);
            }

            //奖励
            onSigReward: {
                showTrophy();
            }


            //图片的高度
            onSigCurrentImageHeight: {
                currentImgHeight = height;
                console.log("=======onSigCurrentImageHeight==========",height,currentOffsetY);
                trailRender.getOffSetImage(0.0,currentOffsetY,1.0);
            }

            //讲义显示信号
            onSigPlanInfo: {
                if(planType == "2" || planType == 100){
                    planType = -1;
                }else{
                    planType = 1;
                }
//                cloudMgr.getIdByColumnInfo(0,planId,0,"");
            }
            //栏目选中信号
            onSigColumnInfo: {
                cloudMenu.updateSelected(planId,columnId);
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
                playManager.getOffsetImage(imageUrl,0);
                backImage.width = parent.width;
                backImage.source = imageUrl;
                console.log("=======onSigCommitImage========",imageUrl)
            }

            onSigSetCurrentTime:{
                playerControl.sliderValue = time;
                playerControl.startTimeText =  dateFromart(time);

                //播放结束以后, 将按钮置为播放状态
                if(time == 0){
                    playerControl.playerStatus = false;
                }

                if(time > totalTime){
                    playManager.stop();
                    cloudMenu.visible = false;
                }
            }

            onSigSetTotalTime:{
                totalTime = seconds;
                playerControl.mediaTotalTimer = seconds;
                playerControl.endTimeText = dateFromart(seconds);
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
                        videoPlayer.closeVideo();
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

        //奖杯动画
        Item{
            id: trophyView
            z: 18
            width: 118 * widthRate
            height: 118 * widthRate
            focus: false
            visible: false
            anchors.centerIn: parent

            AnimatedImage{
                id: animateTrophyImg
                anchors.fill: parent
                source: "qrc:/images/xb_timg.gif"
            }
        }

        //随机选人
        YMRandomSelectionView{
            id:randomSelectionView
            anchors.centerIn: parent
            z:17
            visible: false
            currentUserCanOperation:false
        }

        //抢答器
        YMResponderViewForStu{
            id:responderView
            anchors.centerIn: parent
            z:17
            visible: false
        }

        //计时器
        YMTimerView{
            id:timerView
            anchors.centerIn: parent
            z:17
            visible: false
            userCanOperation: false
        }
    }

    //音频播放器
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
        height: 50 * heightRate
        anchors.bottom: parent.bottom
        onPlayerMedia: {
            audioMedia.play();
            playManager.play();
        }
        onPauseMedia: {
            audioMedia.pause();
            playManager.pause();
        }
        onSeekMedia: {
            playManager.seekTime(position);
        }
    }

    //下载进度条
    YMDownLoadView{
        id: downloadView
        anchors.fill: parent
        z: 3
        visible: false
        onSigResetDownload: {
            downloadTime.start();
        }
    }

    FileDownload{
        id: fileDownloadManager

        onSetDownValue: {
            downloadView.currentValue = 0;
            downloadView.minValue = min;
            downloadView.maxValue = max;
            downloadView.visible = true;
            console.log("onSetDownValue-- ", min, max);
        }

        onDownloadChanged: {
            console.log("onDownloadChanged-- ", currentValue);
            downloadView.currentValue = currentValue;
        }

        onDownloadFinished: {
            console.log("onDownloadFinished-- ", lessonId, date, filePath, trailName);
            menuView.displayerText = lessonId;
            currentLessonId = lessonId;
            playManager.setData(lessonId,date,filePath,trailName,2);
            downloadView.visible = false;
        }

        onSigDownLoadFailed: {
            downloadView.resetDownload();
        }

    }

    Component.onCompleted: {
        appId = boardList[0];//"7169a6c5ab5b4eeba2ca37b831fb9239"
        liveroomId = boardList[1];//"358688023015067648"
        apiUrl =  boardList[2];//"http://sit01-liveroom.yimifudao.com/v1.0.0/openapi"
        console.log("Component.onCompleted==", apiUrl, liveroomId, appId);
        downloadTime.start();
    }

    Timer{
        id: downloadTime
        interval: 1500
        repeat: false
        running: false
        onTriggered: {
            fileDownloadManager.getPlayback(apiUrl, liveroomId, appId);
        }
    }

    function showTrophy(){
        trophyView.visible = true;
        trophyTimer.restart();
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
        knowledgesView.answerModel = answerModel;
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

