import QtQuick 2.5
import TrailBoard 1.0
import LoadInforMation 1.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import WhiteBoard 1.0

Rectangle {
    id:trailBoardBackground
    color: "#ffffff"

    property double ratesRates: widthRates > heightRates? heightRates : widthRates
    property string tipName: "";
    property bool hasShowCutSCreen: false;
    property int loadImgWidth: 0;//加载图片宽度
    property int loadImgHeight: 0;//加载图片高度
    property bool isClipImage: false;//是否时截图课件
    property bool isUploadImage: false;//是否是传的图片
    property double currentOffsetY: 0;//当前滚动条的坐标
    property bool isLongImage: false;//是否是长图
    property double currentImageHeight: 0.0;
    property string bgImgUrl: "";

    //判断是否允许操作
    property bool isHandl: true

    //设置清屏操作
    function setClearCreeon(type,pageNo,totalNum){
        whiteBoard.clearScreen(type,pageNo,totalNum);
    }

    //设置开始上课
    function setStartClassRoom(){
        trailBoard.startClassBegin();
    }

    //掉线重连提醒
    function setContinueLesson(){
        trailBoard.startClassBegin();
        showMessageTips("学生进入教室,开始上课!");
    }

    //申请结束课程
    function agreeEndLesson(types){
        trailBoard.agreeEndLesson(types);
    }

    //退出程序
    function setExitProject(){
        trailBoard.temporaryExitWidget();
    }

    //小班课
    function gotoPage(type,pageNo,pageNumber){
        trailBoard.miniClassGoPage(type,pageNo,pageNumber)
    }

    //主动断开连接
    function  disconnectSockets(){
        trailBoard.disconnectSocket(false);
    }

    //发送给学生音频，视频播放
    function setVideoStream(types,status,times,address,fileId){
        var lastIndex = address.lastIndexOf(".");
        var suffix = address.substring(lastIndex + 1,address.length);
        trailBoard.setVideoStream(types,status,times,address,fileId,suffix);
    }

    //设置画笔颜色
    function setPenColors(penColors) {
        whiteBoard.setPenColor(penColors);
    }
    //改变画笔尺寸
    function changeBrushSizes(penWidths) {
        whiteBoard.changeBrushSize(penWidths);
    }
    //设置鼠标样式
    function setCursorShapeType(types) {
        whiteBoard.setCursorShapeTypes(types);
    }

    // 禁止白板
    function disableTrailboard(){
        whiteBoard.enabled = false;
    }

    // 激活白板
    function enableTrailboard(){
        whiteBoard.enabled = true;
    }

    //设置橡皮大小
    function setEraserSize(eraserSize){
        console.log("111111111111", eraserSize);
        whiteBoard.setEraserSize(eraserSize);
    }
    //评价主动退出教室命令
    function teaFinishClassroom(){
        trailBoard.finishClassRoom();
    }

    //跳转页面
    function jumpToPage(pages){
        trailBoard.goPage(pages );
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

    //设置用户权限
    function setUserAuth(userId,up,trail,audio,video){
        trailBoard.setUserAuth(userId,up,trail,audio,video);
        if(trail == 1){
            qosApiMgr.clickAuthorization(userId,curriculumData.getCurrentIp());
        }
    }

    //显示删除课件提醒
    function setLessonShow(message){
        trailBoard.setCourseware(message);
    }

    //获取课件当前页
    function getCoursePage(docId){
        return trailBoard.getCursorPage(docId);
    }

    //长图滚动函数
    function scrollImage(scrollY){
        trailBoard.updataScrollMap(scrollY);
    }

    //控制界面信号
    signal sigPromptInterfaceHandl(string inforces);

    //发送离开教室的姓名跟类型
    signal sendExitRoomName(string types ,string cname,string userId);

    //视频控制流
    signal sigVideoAudioUrls(var avType,var videoName,var startTime ,var avUrl,var dockId );

    //获取用户名信号
    signal sigUserName(string userName,string userId);

    signal sigAnalysisQuestionAnswers(var lessonId,var questionId,var planId,var columnId);//学生提交练习命令
    signal sigUploadWorkImage(var url,var imgWidth,var imgHeight); //作业上传图片成功信号
    signal sigDisplayerBlankPage();//显示空白页信号
    signal sigStudentAppVersioned(var status);//学生使用的版本
    signal sigGetCoursewareFaills();//老课件获取失败提醒并重新获取信号
    signal sigInterNetworks(var networkStatus);//当前是无线还是有线切换

    signal sigGetbackAisles();//切换为原通道信号

    function setListenLessonTips(){
        showMessageTips(qsTr("学生 ") + tipName + qsTr(" 未注意听讲!"));
    }

    function coursewareOperation(coursewareType, operationType, operationIndex,step){
        bmgImages.coursewareOperation(coursewareType,operationType,operationIndex,step);
    }

    //背景图
    Rectangle{
        id:topicListView//bakcImages
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        clip: true

        property bool isLoading: false;

        Timer{
            id: loadingTimer
            interval: 10000
            repeat: false
            onTriggered: {
                imageSourceChageRectangle.visible= false;
            }
        }
        CourseWareControlView{
            id: bmgImages
            anchors.fill: parent
            z: 11
            currentBeshowViewType: coursewareType
            onSigAnimationNotifications: {
                trailBoard.sendH5PlayAnimation(animationStepIndex);
                console.log("===onSigAnimationNotifications====",animationStepIndex);
            }
        }

        Connections{
            target: getOffSetImage
            onReShowOffsetImage:
            {
                if(coursewareType == 3){
                    return;
                }
                if(isClipImage == false && isUploadImage == false && bgImgUrl == ""){
                    return;
                }

                var imgSource = "image://offsetImage/" + Math.random();
                bmgImages.setCoursewareSource("",coursewareType,imgSource,width,height,curriculumData.getCurrentToken());
                loadImgHeight = height;
                loadImgWidth = width;
                isUploadImage = false;
                isClipImage = false;
                isLongImage = true;

                console.log("===bmgImages.source===",coursewareType,bmgImages.source,width,height,currentImageHeight);
                scrollbar.visible = false;
                if(currentImageHeight > trailBoardBackground.height){
                    scrollbar.visible = true;
                }
            }
        }


        WhiteBoard0{
            id: whiteBoard
            z: 14
            clip: true
            width: parent.width
            height: parent.height
            smooth: true
            visible: networkImage.visible ? false : true
        }

        // 画布
        TrailBoard{
            id:trailBoard
            //z: 12
            //clip: true
            //width: parent.width
            //height: parent.height
            //smooth: true
            //visible: networkImage.visible ? false : true

            onSigSynCoursewareInfo: {
                bmgImages.coursewareSyn(jsonObj);
            }

            onSigClearScreen: {
                coursewareType = 0;
                whiteBoard.clearScreen();
                bmgImages.setCoursewareVisible(1,false);
                bmgImages.setCoursewareVisible(3,false);
                videoToolBackground.resetStatus();
                rosterView.resetStatus();
                showMessageTips("开始上课,课前操作将被清除!")
            }

            onSigIsOnline:
            {
               //重设随机选人数据
                if(randomSelectionView.visible)
                {
                    var rosterInfoData = curriculumData.getRosterInfo();
                    randomSelectionView.resetRandomModel(rosterInfoData);
                }
            }

            onSigStartResponder:
            {
                var rosterInfoData = curriculumData.getRosterInfo();
                randomSelectionView.resetRandomModel(rosterInfoData);
                responderView.setSuccessUser(randomSelectionView.getUserNameById(responderData.userId));
            }

            onSigUserAuth: {
                console.log("===onSigUserAuth===",userId,up,trail,audio,video);
                videoToolBackground.sysnUserAuthorize(userId,up,trail,audio,video);
                rosterView.updateLocalUserAuth(userId,up,trail,audio,video);
            }

            onSigJoinClassroom: {//动态进入教室
                console.log("=====onSigJoinClassroom======",userId)
                videoToolBackground.addUserInfo(userId)
                //重设随机选人数据
                 if(randomSelectionView.visible)
                 {
                     var rosterInfoData = curriculumData.getRosterInfo();
                     randomSelectionView.resetRandomModel(rosterInfoData);
                 }
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
                whiteBoard.getOffSetImage(0.0,currentOffsetY,1.0);
            }

            //学生使用的当前版本
            onSigStudentAppversion: {
                sigStudentAppVersioned(status);
            }

            onSigOffsetY: {
                currentOffsetY = offsetY;
                //console.log("***********setYYYYYYY***************",offsetY);
                if(currentImageHeight == 0){
                    return;
                }

                button.y =  (scrollbar.height * offsetY * trailBoardBackground.height / currentImageHeight);

                scrollbar.visible = false;
                if(currentImageHeight > trailBoardBackground.height){
                    scrollbar.visible = true;
                }
                //console.log("=======sigOffsetY=======",offsetY,button.y,currentImageHeight);
            }

            onSigAutoConnectionNetwork:{
                //console.log("======autoConnetionNetwork===");
                sigPromptInterfaceHandl("autoConnectionNetwork");
            }

            onSigNetworkOnline: {
                console.log("======onSigNetworkOnline=======",online)
                networkImage.visible = isLessonAssess ? false : !online;
            }
            //自动切换IP
            onAutoChangeIpResult: {
                //console.log("sigPromptInterfaceHandl(autoChangeIpStatus)",autoChangeIpStatus)
                sigPromptInterfaceHandl(autoChangeIpStatus);
            }

            //视频控制流
            onSigVideoAudioUrl:{
                console.log("==onSigVideoAudioUrl==",flag,time,dockId);
                if(flag == 0 || flag == 1){
                    var videoJsonObj = miniMgr.getCloudDiskFileInfo(dockId).data;
                    var suffix = videoJsonObj.suffix.toLowerCase();
                    var avType = "audio";

                    if(suffix.indexOf("mp4") != -1 || suffix.indexOf("avi") != -1 || suffix.indexOf("wmv") != -1 || suffix.indexOf("rmvb") != -1){
                        avType = "video";
                        mediaPlayer.ymVideoPlayerManagerPlayFielByFileUrl(videoJsonObj.path,videoJsonObj.name,time,dockId,videoJsonObj.path);
                    }
                    else if(suffix.indexOf("mp3") != -1 || suffix.indexOf("wma") != -1 || suffix.indexOf("wav") != -1){
                        avType = "audio";
                        audioPlayer.ymAudioPlayerManagerPlayFileByUrl(videoJsonObj.path,videoJsonObj.name,time,videoJsonObj.path,dockId);
                    }
                }
            }

            onSigSynCoursewareStep: {
                console.log("====step====",step,coursewareType);
                bmgImages.coursewareOperation(coursewareType,4,pageId,step);
            }

            onSigSynCoursewareType: {
                coursewareType = docType;
                if(docType == 3){
                    if(h5Url=="")
                    {
                        return;
                    }
                    bmgImages.setCoursewareSource("",coursewareType,h5Url,parent.width,parent.height,curriculumData.getCurrentToken());
                }
                console.log("======onSigSynCoursewareType=====",docType,h5Url);
            }

            onSigSendUrl:{
                var urlsa = urls.replace("https","http");
                isClipImage = false;
                isUploadImage = false;
                bgImgUrl = urlsa;
                //console.log("=======false========",width,height,urlsa,isHomework,isClipImage,isLongImg,questionId,coursewareType);
                isLongImage = true;

                if(questionId == "" || questionId == "-1" || questionId == "-2"){
                    //console.log("========no::longImg=====",isLongImage);
                    isLongImage = false;
                }
                if(coursewareType == 3){
                    bmgImages.setCoursewareSource("",coursewareType,urls,parent.width,parent.height,curriculumData.getCurrentToken());
                    scrollbar.visible = false;
                    whiteBoard.getOffSetImage(0,0,1.0);
                    return;
                }

                if(width < 1 && height < 1 && urls != ""){//截图
                    isClipImage = true;
                    scrollbar.visible = false;
                }
                if(width == 1 && height == 1 && urls != ""){//传图
                    //原逻辑传图老课件都是走这里(原来传图老课件都是一屏铺满显示) 现在逻辑把传图和老课件都按等比例缩放
                    console.log("======= test old img 1 ========",currentOffsetY);
                    isUploadImage = true;
                    bmgImages.setCoursewareSource("",questionId,urlsa,height,width,curriculumData.getCurrentToken());
                    trailBoard.getOffsetImage(urlsa,currentOffsetY);
                    whiteBoard.getOffSetImage(0,currentOffsetY,1.0);
                    return;
                }
                if(urls.length > 0){
                    loadImgHeight = height;
                    loadImgWidth = width;
                    bmgImages.setCoursewareSource("",questionId,urlsa,height,width,curriculumData.getCurrentToken());
                    if(isLongImage && !isClipImage && !isUploadImage){
                        isHomework = 3;
                        trailBoard.getOffsetImage(urlsa,currentOffsetY);
                        whiteBoard.getOffSetImage(0,currentOffsetY,1.0);
                    }
                }else{
                     scrollbar.visible = false;
                    bmgImages.setCoursewareVisible(1,false);
                    bmgImages.setCoursewareVisible(3,false);
                    whiteBoard.setCurrentImgUrl("")
                    whiteBoard.getOffSetImage(0,0,1.0);
//                    if(isHomework == 2){
//                        bmgImages.source = "";
//                    }
//                    bmgImages.visible = (isHomework == 3 ? true : isLongImg);
                }
            }

            //提示打开跟关闭摄像头
            onSigUserIdCameraMicrophone: {
                toopBracund.visible = false;
                toopBracundTimer.stop();
                var cname = curriculumData.getUserName(usrid);

                if(status == 16) {
                    showMessageTips(qsTr("学生 ") + cname + qsTr(" 关闭本地摄像头"));
                }
                if(status == 15){
                    showMessageTips(qsTr("学生 ") + cname + qsTr(" 关闭本地麦克风"));
                }
            }


            //当前页
            onSigChangeCurrentPage: {
                var currentPages = currentPage + 1;
                bottomToolbars.currentPage = currentPages;
            }
            //全部页数
            onSigChangeTotalPage: {
                bottomToolbars.totalPage = totalPage;
            }
            //开始上课
            onSigStartClassTimeData:{
                toopBracund.visible = false;
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

            onSigPromptInterface:{
                //处理老师结束课程 为a学生
                console.log("==onSigPromptInterface==",interfaces);
                if(interfaces == "opencarm"){
                    videoToolBackground.setStartClassTimeData();
                }

                if(interfaces == "2"){
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }

                if(interfaces == "65" ) {
                    sigPromptInterfaceHandl(interfaces);
                    return;
                }
                //切换线路
                if(interfaces == "changedWay"){
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
                    return;
                }

                //音视频的状态
                if(interfaces == "68") {
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
                if(isCourseware){
                    showMessageTips("课件不能删除!");
                }else{
                    trailBoardBackground.coursewareOperation(coursewareType,3,1,0);
                }
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
        visible: false
        z: 16

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

                onReleased: {
                    currentOffsetY = 0;
                    var contentY =  (button.y / scrollbar.height * currentImageHeight / trailBoardBackground.height);
                    scrollImage(contentY);
                    whiteBoard.getOffSetImage(0.0,contentY,1.0);
                    console.log("=====lsdkfjlsajflksdjflksd===========",contentY,currentImageHeight,trailBoardBackground.height);
                }
            }
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

    function updateAllMute(muteStatus){
        trailBoard.allMute(muteStatus);
    }

    function sendTrophy(userId){
        trophyView.visible = true;
        trophyTimer.restart();
        trailBoard.sendReward(userId,curriculumData.getUserName(userId));
        qosApiMgr.clickReward(userId,curriculumData.getCurrentIp());
    }

    Timer{
        id: trophyTimer
        interval: 3000
        repeat: false
        onTriggered: {
            trophyView.visible = false;
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

    LoadInforMation{
        id: loadInforMation
        onSigLoadingMp3: {
            showMessageTips("正在加载音视频课件，请稍候...");
        }

        onSigDowloadFail: {
            showMessageTips("音视频课件加载失败，请重新选择");
        }
    }

    function downLoadMedia(mp3Path){
        return loadInforMation.downLoadMedia(mp3Path);
    }

    function insertCourseWare(imgUrlList,fileId,h5Url,coursewareType)
    {
        if(coursewareType == 3){
            bmgImages.setCoursewareSource("",coursewareType,h5Url,parent.width,parent.height,curriculumData.getCurrentToken());
            scrollbar.visible = false;
        }
        trailBoard.insertCourseWare(imgUrlList,fileId,h5Url,coursewareType);
    }

    function sendRandomSelectMsg(userId,type,userName)
    {
        trailBoard.sendRandomSelectMsg(userId,type,userName);
    }

    function sendResponderMsg(runTimes,types)
    {
        trailBoard.sendResponderMsg(runTimes,types);
    }

    function sendTimerMsg(timerType, flag, timesec)
    {
        trailBoard.sendTimerMsg(timerType, flag, timesec);
    }

}

