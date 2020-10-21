import QtQuick 2.6
import QtQuick.Window 2.2
import ToolBar 1.0
import YMLessonManager 1.0
import CurriculumData 1.0
import Trophy 1.0
import YMNetworkManagerAdapert 1.0
import ClassInfoManager 1.0
import Answer 1.0
import UploadFileManager 1.0

Window {
    id: mainview
    visible: true
    width: Screen.width
    height: Screen.height
    flags: Qt.Window | Qt.FramelessWindowHint
    title: qsTr("ClassRoom")
    color: "#4E5065"

    //屏幕比例
    property double widthRate: fullWidths / 1440.0;
    property double heightRate: fullHeights / 900.0;

    property int coursewareType: 1;//默认老课件
    property int h5CoursewarePageTotal: 0;//H5课件总页数
    property int playNumber: 0;
    property double currentImageHeight: 0.0;
    property double curOffsetY: 0.0;//当前滚动条的坐标,不能与CoursewareView.qml中的变量同名，故更名为curOffsetY

    property int loadImgWidth: 0;//加载图片宽度
    property int loadImgHeight: 0;//加载图片高度
    property bool isClipImage: false;//是否时截图课件
    property bool isUploadImage: false;//是否是传的图片
    property bool isLongImage: false;//是否是长图
    property bool isStartLesson: false;//
    property int currentUserRole: 0;//当前用户角色 0=老师，1=学生，2=助教

    property bool hasUp: false;// 是否举手了
    property bool isUpStage: false;// 是否已经上台
    property bool hasTeacher: false;// 老师是否在频道内

    //菜单栏
    YMHeadControlView{
        id: headView
        width: parent.width
        height: 70 * heightRate
        anchors.top: parent.top
        setUserRole : currentUserRole
        onSigDeviceCheck: {
            deviceSettingView.visible = true;
        }

        onSigDownLesson: {
            if(isStartLesson){
                tipsView.showExitroom();
            }else{
                isStartLesson = true;
                toolbar.beginClass();
                toolbar.initVideoChancel();
                hasTeacher = true;
                tipsView.showStartLesson();
                headView.setLessonState(1); //开始上课
            }
        }

        onSigExit: {
            if(currentUserRole == 2 || currentUserRole == 1){
                toolbar.exitChannel();
                toolbar.exitClassRoom();
                toolbar.uploadLog();
                toolbar.uninit();
                return;
            }
            tipsView.showExitroom();
        }

        onSigMin: {
            mainview.visibility = Window.Minimized;
        }

    }

    YMLoadingView{//加载课件
        id: loadingView
        z: 91
        anchors.fill: parent
        visible: false
        onSigRefresh:{

        }
    }

    //设备检测
    YMDevicetesting{
        id: deviceSettingView
        z: 100
        width: 490 * widthRate
        height: 356 * heightRate
        x: (parent.width - width) * 0.5
        y: (parent.height - height) * 0.5
        visible: false

        onSigFirstStartTest: {
            if(getCurrentUserRole() == "tea" && hasTeacher){
                toolbar.exitChannel();
                hasTeacher = false;
            }
        }
        // 设备检测后重新进频道防止视频画面卡住
        onSigFinishedTest: {
            if(getCurrentUserRole() != "tea"){
                toolbar.exitChannel();
            }

            if(headView.lessonStatus == 1){
                toolbar.initVideoChancel();
                hasTeacher = true;
            }
        }
    }

    // 视频区域
    AudioVideoView {
        id: audiovideoview
        z: 1
        width: 240 * widthRate
        height: 200 * heightRate
        anchors.top: headView.bottom
        anchors.topMargin: 4 * heightRate
        anchors.right: parent.right
        userAVRole: getCurrentUserRole()
        //操作背景
        Image {
            id: backImg
            z: 5
            width: parent.width
            height: parent.height
            visible: !hasTeacher
            source:  "qrc:/bigclassImage/lsmr.png"
        }

        onSigResolutionValue: {
            console.log("======分辨率=", resValue, resValue == 1 ? "360P" : resValue == 2 ? "480P" : "720P");
            toolbar.setVideoResolution(resValue);
        }
    }

    Item {
        z: 90
        id: background
        width: midWidth
        height: midHeight
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - midWidth - audiovideoview.width) * 0.5
        anchors.top: parent.top
        anchors.topMargin: (parent.height - midHeight - headView.height -bottomToolbars.height) * 0.5 + headView.height

        // 白板区域
        WhiteBoard0 {
            id:whiteBoard
            z: 11
            clip: true
            anchors.fill: parent
            smooth: true
            visible: true
            enabled: currentUserRole != 0 ? false : true
            onSigUserAuth: {
                currentUserRole = userRole;
            }
        }

        // 课件区域
        CoursewareView {
            id: ymcourseware
            z: 10
            anchors.fill: parent
            visible: true
            userRole: currentUserRole == 0 ? "tea" : (currentUserRole == 1 ? "stu" : "assistant")
            enabled: currentUserRole == 0 ? true : false

            onSigChangeCurrentPages: {
                bottomToolbars.currentPage = pages;
            }
            onSigChangeTotalPages: {
                bottomToolbars.totalPage = pages;
            }
            onSigGetOffsetImage: {
                curOffsetY = currentCourseOffsetY;
                toolbar.getOffsetImage(url, curOffsetY);
            }
            onSigSendH5PlayAnimation: {
                toolbar.sendH5PlayAnimation(animationStepIndex);
            }
            onSigSendH5ThumbnailPage: {
                toolbar.goCourseWarePage(1, pageIndex, bottomToolbars.totalPage);
            }
            onSigLoadsCoursewareSuccess: {
                loadingView.hideView();
            }
            onSigIsCouserware: {
                setTips("课件无法删除")
            }

            Connections {
                target: getOffSetImage
                onReShowOffsetImage:
                {
                    if(coursewareType== 3){
                        return;
                    }

                    var imgSource = "image://offsetImage/" + Math.random();
                    ymcourseware.setCoursewareSource("",coursewareType,imgSource,width,height,curriculumData.getCurrentToken());
                    loadImgHeight = height;
                    loadImgWidth = width;
                    isUploadImage = false;
                    isClipImage = false;
                    isLongImage = true;

                    console.log("===bmgImages.source===",coursewareType,imgSource,width,height,currentImageHeight);
                    scrollbar.visible = false;
                    if(currentImageHeight > background.height){
                        scrollbar.visible = true;
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
            height: background.height
            visible: false
            z: 16

            // 按钮
            Rectangle {
                id: button
                width: parent.width
                height: {
                    var mutilValue = currentImageHeight / background.height
                    if(mutilValue > 1){
                        return parent.height / mutilValue;
                    }
                    else{
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
                        //currentOffsetY = 0;
                        var contentY =  (button.y / scrollbar.height * currentImageHeight / background.height);
                        toolbar.updataScrollMap(contentY);
                        whiteBoard.getOffSetImage(0.0,contentY,1.0);
                    }
                }
            }
        }
    }

    AudioVideoViewStu {
        id: audioviewviewstu
        z: 100
        x: parent.width - width * 2
        y: (parent.height - midHeight - headView.height -bottomToolbars.height) * 0.5 + headView.height
        visible: false
        useRole: currentUserRole == 0 ? "tea" : (currentUserRole == 1 ? "stu" : "assistant")
        // 设置用户授权
        onSigSetUserAuths: {
            if(getCurrentUserRole() != "tea"){
                return;
            }
            toolbar.setUserAuth(userId, up, trail, audio, video);
        }

        // 强制下台
        onSigForceDown: {
            if(getCurrentUserRole() != "tea"){
                return;
            }
            interaction.updateUpStatus(uid,1);
            interaction.updateDisableStatus(uid,true);
            audioviewviewstu.updateUserState(uid, "0","");
            toolbar.processHandsUp(uid, 0, 2);
        }
    }

    // 数据类
    CurriculumData {
        id:curriculumData
        onSigListAllUserId: {
            if(getCurrentUserRole() == "tea"){
                var dataObject = curriculumData.getUserInfo(list[0]);
                var userId = list[0];
                console.log("===dataObject===",JSON.stringify(dataObject))
                audiovideoview.userName = teaNickName;
                audiovideoview.addSelfBaseInfo(userId, dataObject);
            }
        }
    }

    //底部工具栏
    BottomToolbars {
        id: bottomToolbars
        z: 92
        visible: currentUserRole == 0 ? true : false
        width: parent.width - audiovideoview.width
        height: 65  * widthRate
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        //跳转页面
        onSigJumpPage: {
            //console.log("=====onSigJumpPage====",pages)
            toolbar.goCourseWarePage(1, pages, bottomToolbars.totalPage);
            ymcourseware.coursewareOperation(3, 4, pages,0);
        }
        // 上一页
        onSigPrePage: {
            //console.log("======onSigPrePage====");
            ymcourseware.coursewareOperation(3, 0, 0,0);
        }
        // 下一页
        onSigNext: {
            //console.log("======onSigNextPage====");
            ymcourseware.coursewareOperation(3,1,1,0);;
        }
        //增加页
        onSigAddPage: {
            toolbar.goCourseWarePage(2,bottomToolbars.currentPage,bottomToolbars.totalPage + 1);
            ymcourseware.coursewareOperation(coursewareType,2,bottomToolbars.currentPage,0);
        }
        //删除页
        onSigRemoverPage: {
            toolbar.goCourseWarePage(3,bottomToolbars.currentPage - 1,bottomToolbars.totalPage - 1);
        }
        //翻页首末页提醒
        onSigTipPage:  {
            if(message == "lastPage"){

            }
            if(message == "onePage"){

            }
        }
    }

    // 举手按钮
    Rectangle {
        id: btnHandsup
        width: 100 * heightRate
        height: 40 * heightRate
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: audiovideoview.width + 10 * heightRate
        anchors.bottomMargin: 12 * heightRate
        color: "#4E5065"
        enabled: getCurrentUserRole() == "stu" && !isUpStage
        visible: getCurrentUserRole() == "stu" && !isUpStage
        z: 200
        Image {
            id: handsImg
            visible: !isUpStage
            source: hasUp ? "qrc:/bigclassImage/jushou5.png" : "qrc:/bigclassImage/jushou2.png"
            anchors.fill: parent
            anchors.centerIn: parent
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
                var userInfoObj = toolbar.getUserInfo();
                var groupId = userInfoObj["groupId"];
                var userId = userInfoObj["userId"];
                if(hasUp){
                    if(isUpStage){
                        setTips("你已经上台，无法取消!");
                        hasUp = false;
                        return;
                    }
                    toolbar.cancelHandsUp(userId, groupId);
                    hasUp = false;
                }
                else{
                    toolbar.raiseHandForUp(userId, groupId);
                    hasUp = true;
                }
            }
        }
    }

    // kickView
    YMKickOutView{
        id: kickOutView
        z: 100
        visible: false
        anchors.fill: parent
        onSigKickOut: {
            toolbar.exitChannel();
            toolbar.exitClassRoom();
            toolbar.uploadLog();
            toolbar.uninit();
        }
    }

    YMClassDisconnectView{
        id: classDisconnectView
        z: 100
        visible: false
        anchors.fill: parent
        onSigClassDisconnect: {
            toolbar.exitChannel();
            toolbar.exitClassRoom();
            toolbar.uploadLog();
            toolbar.uninit();
        }
    }

    Timer{
        id: networkTime
        interval: 35000
        running: false
        repeat: false
        onTriggered: {
            console.log("network time Trigger");
            classDisconnectView.visible = true;
        }
    }

    //工具栏
    RightToolbarsView {
        id: toolbarsView
        z: 91
        visible: currentUserRole == 0 ? true : false
        x: 0
        y: (parent.height - height) * 0.5
        ToolBar {
            id: toolbar
            onSigKickOutClassroom: {
                kickOutView.visible = true;
            }

            onSigPlayAv: {
                console.log("===onSigPlayAv===",JSON.stringify(avData));
                if(currentUserRole == 0){
                    return;
                }
                var suffix = avData.suffix;
                var path = avData.path;
                var fileName = "";
                var startTime = avData.playTimeSec
                var flagState = avData.flagState;
                if(suffix == "mp3" || suffix == "wma" || suffix == "wav"){
                    if(flagState == 1 || flagState == 2){
                        audioPlayer.setPlayAudioStatus(flagState);
                        audioPlayer.visible = flagState == 1 ? true : false;
                        return;
                    }
                    if(mediaPlayer.visible){
                        mediaPlayer.visible = false;
                        mediaPlayer.setPlayVideoStatus(3);
                    }
                    audioPlayer.ymAudioPlayerManagerPlayFileByUrl(path,fileName,startTime,path,"");
                    audioPlayer.visible = true;
                }
                if(suffix == "mp4" || suffix == "avi" || suffix == "wmv" || suffix == "rmvb"){
                    if(audioPlayer.visible){
                        audioPlayer.setPlayAudioStatus(3);
                        audioPlayer.visible = false;
                    }
                    if(flagState == 1 || flagState == 2){
                        mediaPlayer.setPlayVideoStatus(flagState);
                        mediaPlayer.visible =flagState == 1 ? true : false;
                        return;
                    }
                    mediaPlayer.ymVideoPlayerManagerPlayFielByFileUrl(path,fileName,startTime,"",path)
                    mediaPlayer.visible = true;
                }
            }

            onSpeakerVolume: {
                deviceSettingView.currentVolumeIndex =volume / 255 * 28;
            }
            onRenderVideoImage: {
                deviceSettingView.updateCareme(fileName);
            }

            onSigBeginClassroom:{
                console.log("==onSigBeginClassroom==");
                isStartLesson = true;
                if(currentUserRole == 0){
                    tipsView.showContinueLessonView();
                    return;
                }
                tipsView.showTeaStartLesson();

            }

            onSigNoBeginClass: {
                console.log("====onSigNoBeginClass===")
                if(currentUserRole != 0){//不是老师则提醒未开课
                    tipsView.showNoStartLesson();
                }
                headView.setLessonState(0); //未开始
            }

            onSigExitRoom:{
                console.log("===onSigExitRoom====");
                toolbar.exitChannel();
                toolbar.uninit();
                console.log("===onSigExitRoom end====");
                toolbar.uploadLog();
                Qt.quit();
                console.log("===onSigExitRoom quit====");
            }
            onSigEndClassroom:{
                console.log("==onSigEndClassroom==");
                tipsView.showDownLesson();
                headView.setLessonState(3); //结束
            }

            onSigClearScreen:{
                console.log("==onSigClearScreen==");
                bottomToolbars.totalPage = 1;
                bottomToolbars.currentPage = 1;
                ymcourseware.clearScreen();
                tipsView.showClearScreen();
            }

            onSigExitClassroom:{
                console.log("==onSigExitClassroom==");
            }

            onSigPromptInterface: {
                if(interfaces == "opencarm" && currentUserRole == 0){
                    //toolbar.initVideoChancel();
                }
            }
            onSigJoinroom: {//音视频进入
                console.log("===onSigJoinroom===",uid, status, getUserType(uid))
                var currentRole = getCurrentUserRole();
                var uType = getUserType(uid);
                var nickname = getUserName(uid);
                if(status == 1){
                    console.log("===========uType=", uType);
                    if(uType == "TEA"){
                        isStartLesson = true;
                        if(currentRole == "assistant" || currentRole == "stu"){
                            headView.setLessonState(1); //开始上课
                            var dataObject = {};
                            dataObject["userName"] = "tea";
                            dataObject["userOnline"] = "1";
                            dataObject["userAuth"] = "1";
                            dataObject["isVideo"] = "1";
                            dataObject["userAudio"] = "1";
                            dataObject["userVideo"] = "1";
                            dataObject["imagePath"] = "";
                            dataObject["isteacher"] = "1";
                            dataObject["supplier"] = "1";
                            dataObject["headPicture"] = "";
                            dataObject["userMute"] = "0";
                            dataObject["uid"] =  uid;
                            dataObject["userUp"] = "1";
                            dataObject["rewardNum"] = "0";
                            console.log("=======onSigJoinClassroom::assistant::TEA=", userId, JSON.stringify(dataObject))
                            audiovideoview.addSelfBaseInfo(userId, dataObject);
                            hasTeacher = true;
                        }
                    }
                    else{
                        audioviewviewstu.updateUserState(userId, "1", nickname == "unknown" ? userId : nickname);
                        audioviewviewstu.visible = true;
                    }
                }
                else if(status == 0){
                    if(uType == "TEA"){
                        if(currentRole == "assistant" || currentRole == "stu"){
                            headView.setLessonState(2); //离开
                            audiovideoview.updateUserState(userId, "0")
                            hasTeacher = false;
                        }
                        isStartLesson = false;
                        tipsView.showTealevaImg();
                    }
                    else {
                        audioviewviewstu.updateUserState(userId, "0", nickname == "unknown" ? userId : nickname)
                        audioviewviewstu.visible = false;
                    }
                }
            }

            onSigAudioVolumeIndication: {
                audiovideoview.updateVolume(totalVolume.toString());
                //console.log("=======onSigAudioVolumeIndication===",uid,totalVolume)
            }

            onSigJoinClassroom: {
                console.log("======onSigJoinClassroom=", userId, userType, teaNickName,JSON.stringify(extraInfoObj));
                infoModel.append({"videoId" : extraInfoObj.videoId, "userType" : userType, "userName" : extraInfoObj.userName})
                var currentRole = getCurrentUserRole();
                console.log("=====currentRole===", currentRole,extraInfoObj.userName)

                if(userType == "STU"){
                    interaction.addStuData(userId, extraInfoObj);
                    //audioviewviewstu.updateUserState(userId, "1","")
                }
                else if(userType == "TEA"){
                    if(currentRole == "assistant" || currentRole == "stu"){
                        toolbar.initVideoChancel();
                    }
                    audiovideoview.userName = currentUserRole == 0 ? teaNickName : extraInfoObj.userName;
                }
            }

            onSigLeaveClassroom: {
                console.log("=====onSigLeaveClassroom======");
                interaction.delStuData(userId);
                audioviewviewstu.updateUserState(userId, "0","")
                if(userType == "TEA" && currentUserRole  != 0){
                    tipsView.showTealevaImg();
                    isStartLesson = false;
                }

            }

            onUpdateStuList: {//申请取消申请上麦
                console.log("===========onUpdateStuList=",userId,reqOrCancel,groupId)
                if(reqOrCancel == 0){
                    interaction.stuCancelData(userId)
                }
                else if(reqOrCancel == 1){
                    console.log("===学生申请上台===")
                    interaction.stuAppliedData(userId);
                }
            }

            onSigHandsUpResponse: {
                if(getCurrentUserRole() != "stu"){
                    return;
                }
                console.log("=====type=",type)
                var userInfoObj = toolbar.getUserInfo();
                var nickName = userInfoObj["nickName"];
                var userId = userInfoObj["userId"];
                if(type == "forceUp" || type == "agree"){
                    toolbar.setUserRole(1);
                    audioviewviewstu.updateUserState("0", "1", nickName)
                    audioviewviewstu.visible = true;
                    isUpStage = true;
                }
                else if(type == "forceDown" || type == "refused"){
                    toolbar.setUserRole(2);
                    audioviewviewstu.updateUserState("0", "0", nickName)
                    audioviewviewstu.visible = false;
                    isUpStage = false;
                    hasUp = false;
                }
            }

            onSigCurrentImageHeight: {
                currentImageHeight = imageHeight;
                scrollbar.visible = false;
                if(currentImageHeight > background.height){
                    scrollbar.visible = true;
                }
                if(currentImageHeight == 0){
                    return;
                }
                button.y = (scrollbar.height * curOffsetY * background.height / currentImageHeight);
                whiteBoard.getOffSetImage(0,curOffsetY,1.0);
            }

            onSigDowloadAVFail: {
                setTips("课件加载失败!");
            }

            onSigDowloadAVSuccess: {
                loadingView.hideView();
                setTips("课件加载成功")
            }

            //计时器倒计时
            onSigResetTimerView: {
                timerView.resetViewData(timerData);
            }

            onSigAutoConnectionNetwork: {
                console.log("sig auto connection network");
                networkTime.restart();
            }

            onSigAutoChangeIpResult: {
                console.log("sig auto change ip result");
                if("autoChangeIpSuccess" == autoChangeIpStatus)
                {
                    networkTime.stop();
                    classDisconnectView.visible = false;
                }
            }

        }

        onSigSendFunctionKey: {
            brushWidget.visible = false;
            eraserWidget.visible = false;
            diskMainView.visible = false;
            switch(keys)
            {
            case 0 :// 鼠标样式
                toolbar.selectShape(0);
                whiteBoard.enabled = false;
                break;
            case 1: // 画笔
                toolbar.selectShape(1);
                brushWidget.focus = true;
                whiteBoard.enabled = true;
                break;
            case 4:  // 橡皮擦
                toolbar.selectShape(2);
                eraserWidget.focus = true;
                whiteBoard.enabled = true;
                break;
            case 5: // 教鞭
                toolbar.selectShape(4);
                whiteBoard.enabled = true;
                break;
            case 6:   // 云盘(课件)
                var userInfoObj = toolbar.getUserInfo();
                var classroomId = userInfoObj["classroomId"];
                var apiUrl = userInfoObj["apiUrl"];
                console.log("=====classroomId===",classroomId, apiUrl)
                classInfoManager.getCloudDiskList(classroomId, apiUrl)
                diskMainView.visible = true;
                whiteBoard.enabled = true;
                break;
            case 7: //答题器
                if(answerView.isStartTopic){
                    beingAnswerView.visible = true;
                }else{
                    answerView.isStartTopic = false;
                    answerView.isCheck = false;
                    answerView.answerText = "";
                    answerView.answerItem = ["A","B","C"];
                    answerView.resetStatus();
                    answerView.visible = true;
                }
                break;
            case 8: //计时器
                timerView.visible = true;
                break;
            case 9: //红包雨
                redView.visible = true;
                redPackgeRankingView.visible = false;
                redView.startRedPackge();
                break;
            case 10://奖杯
                rewardView.visible = true;
                trophy.sendTrophy("","");
                break;
            case 11://隐藏
                shrinkAnimation.start();
                break;
            default:
                break;
            }
        }
    }

    NumberAnimation {//隐藏动画
        id: shrinkAnimation
        target: toolbarsView
        property: "x"
        duration: 600
        to: -60 * heightRate
        from: 0
        easing.type: Easing.InOutQuad
        onStopped: {
            expandBtn.visible = true;
        }
    }

    NumberAnimation {//展开动画
        id:expandAnimation
        target: toolbarsView
        property: "x"
        duration: 600
        to: 0
        from: -60 * heightRate
        easing.type: Easing.InOutQuad
        onStopped: {
            expandBtn.visible = false;
        }
    }

    MouseArea{//展开按钮
        id: expandBtn
        z: 91
        width: 52 * heightRate
        height: 52 * heightRate
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        visible: false
        x: 0
        y: parent.height * 0.5 + toolbarsView.height * 0.5 - height - 6 * heightRate

        Rectangle{
            anchors.fill: parent
            color: "#363744"
            radius: 6 * heightRate
        }
        Rectangle{
            width: 20 * heightRate
            height: parent.height
            color: "#363744"
        }

        Image{
            width: 42 * heightRate
            height: 42 * heightRate
            anchors.centerIn: parent
            source: parent.containsMouse ? "qrc:/bigclassImage/expand_sed.png" : "qrc:/bigclassImage/expand.png"
        }

        onClicked: {
            expandAnimation.start();
        }
    }

    ListModel {
        id: infoModel
    }

    //聊天与学员
    InteractiveToolsView {
        id: interaction
        width: 240 * widthRate
        height: parent.height - audiovideoview.height - headView.height
        anchors.top: audiovideoview.bottom
        anchors.topMargin: 2 * heightRate
        anchors.right: parent.right
        setUserRole: currentUserRole
        onSigProcessHandsUp: {
            if(getCurrentUserRole() != "tea"){
                return;
            }
            var userName = getUserName(uid);
            console.log("=====main.qml=onSigProcessHandsUp",uid,operation,userName)
            toolbar.processHandsUp(uid, 0, operation);
            //var userId = toolbar.getUserId(uid);
            if(operation == 1){// 强制上台
                audioviewviewstu.updateUserState(uid, "1",userName);
                audioviewviewstu.visible = true;
            }
            else if(operation == 2){// 强制下台
                audioviewviewstu.updateUserState(uid, "0",userName);
            }
            else if(operation == 3){// 同意上台
                audioviewviewstu.updateUserState(uid, "1",userName);
            }
            else if(operation == 4){// 拒绝上台
                audioviewviewstu.updateUserState(uid, "0",userName);
            }
        }

        onSigSetTips: {
            setTips(tips);
        }

        onSigSetChattingRoomUrl: {
            var userInfoObj = toolbar.getUserInfo();
            var chatRoomUrl = userInfoObj["chatRoomUrl"];
            console.log("========chatRoomUrl",chatRoomUrl)
            interaction.setChattingRoomUrl(chatRoomUrl,"01fdee403750988316b38b42960f198e");
        }

        onSigChattingRoomLoadFinished: {
            var userInfoObj = toolbar.getUserInfo();
            var nickName = userInfoObj["nickName"];
            var userIds = userInfoObj["userId"];
            var userRole = userInfoObj["userRole"];
            var groupId = userInfoObj["groupId"]
            var classroomId = userInfoObj["classroomId"];

            var role = "tea";
            var myClass = "all";
            if(userRole == 0){
                role = "tea";
                myClass = "all";
            }
            else if(userRole == 1){
                role = "stu";
                myClass = groupId;
            }
            else if(userRole == 2){
                role = "assistant";
                myClass = groupId;
            }
            var chatroomId = userInfoObj["chatRoomId"];
            console.log("===onSigChattingRoomLoadFinished,", "nickName=",nickName, ",userIds=", userIds, ",userRole=", userRole, ",groupId=", groupId, ",classroomId=", classroomId, ",chatroomId=",chatroomId)
            interaction.initchattingroom(nickName == "" ? "tea" : nickName,
                                                          "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJh6NN0AEmiajjbI9B9vH1gjiaSz5ZhyK53cTamycfYOe8LTg8piacj2WSjBsEnSicjDS0bDJ9rNfpdsw/132",
                                                          userIds,
                                                          role,
                                                          myClass,
                                                          chatroomId);
        }
    }
    //奖杯
    YMRewardView{
        id: rewardView
        anchors.fill: parent
        visible: false
        z: 93
    }

    //奖杯管理类
    Trophy {
        id:trophy
        onSigDrawTrophy: {
            rewardView.visible = true;
        }

        onSigSyncHistoryTrophy:{
            console.log("===onSigSyncHistoryTrophy===",historyPrize);
            headView.tophyNum = historyPrize;
        }

    }

    //画笔操作
    BrushWidget{
        id:brushWidget
        anchors.left: parent.left
        anchors.leftMargin: 54 * heightRate
        anchors.top:  parent.top
        anchors.topMargin: (parent.height - toolbarsView.height) * 0.5 - 20 * heightRate
        width: 200 * heightRate
        height: 220  * heightRate
        visible: false
        focus: false
        z: 91
        onFocusChanged: {
            if(brushWidget.focus) {
                brushWidget.visible = true;
            }else {
                brushWidget.visible = false;
            }
        }
        onSendPenColor: {
            toolbar.setPaintColor(penColors);
            //                toobarWidget.handlBrushImageColor(penColors);
            //setBrushImage();
        }
        onSendPenWidth: {
            toolbar.setPaintSize(penWidths);
            //setBrushImage();
        }

    }

    //橡皮
    EraserWidget{
        id:eraserWidget
        anchors.left: parent.left
        anchors.leftMargin: 54 * heightRate
        anchors.top:  parent.top
        anchors.topMargin: (parent.height - toolbarsView.height) * 0.5 + 30 * heightRate
        width: 200 * heightRate
        height: 212  * heightRate
        z: 91
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
            toolbar.selectShape(types);
            toolbar.setErasersSize(eraserWidget.eraserSize);
        }

        onSigClearsCreeon: {
            if(types == 1){
                eraserWidget.focus = false;
                toolbar.clearTrails();
            }else{
                toolbar.undoTrail();
            }
        }
    }

    // 文件上传
    UploadFileManager {
        id: uploadFileManager
        // 上传成功信号
        onSigUploadSuccess: {
            console.log("========upload success, fileUrl=", fileUrl, fileSize);
            //setTips("文件上传成功");
            var userInfoObj = toolbar.getUserInfo();
            var roomId = userInfoObj["classroomId"];
            var userId = userInfoObj["userId"];
            var apiUrl = userInfoObj["apiUrl"];
            classInfoManager.upLoadCourseware(roomId, userId, fileUrl, fileSize, apiUrl);
        }
        // 上传失败信号
        onSigUploadFailed: {
            console.log("========upload failed");
            setTips("文件上传失败");
        }
    }

    // 云盘
    YMCloudDiskMainView {
        id: diskMainView
        anchors.left: parent.left
        anchors.leftMargin: 50 * heightRate
        anchors.top: parent.top
        anchors.topMargin: (parent.height - height) * 0.5
        visible: false
        z: 92
        //当前被选择的 课件ImgList 和fileId  var ImgUrlList, var fileId
        onSigCurrentBeOpenedCoursewareUrl:{
            loadingView.loadingCoursewa();
            if(coursewareType == 3){
                ymcourseware.insertCourseWare(imgUrlList, fileId, h5Url, coursewareType,curriculumData.getCurrentToken());
            }
            toolbar.insertCourseWare(imgUrlList,fileId,h5Url,coursewareType);
        }
        //当前被选择的音频的Url 及id   audioUrl  fileI
        onSigCurrentBePlayedAudioUrl:{
            console.log("==audioUrl==",audioUrl)
            loadingView.loadingCoursewa();
            if(mediaPlayer.visible){
                mediaPlayer.visible = false;
            }
            var audioPath = toolbar.downLoadAVCourseware(audioUrl);
            if(audioPath == ""){
                return;
            }
            console.log("====onSigCurrentBePlayedAudioUrl====",audioPath)
            audioPlayer.ymAudioPlayerManagerPlayFileByUrl("file:///" + audioPath,fileName,0,audioUrl,fileId);
            audioPlayer.visible = true;
            loadingView.hideView();
        }
        //当前被选择的视频的Url 及id  videoUrl  fileId
        onSigCurrentBePlayedVideoUrl:
        {
            console.log("===videoUrl==",videoUrl)
            loadingView.loadingCoursewa();
            if(audioPlayer.visible){
                audioPlayer.visible = false;
            }
            var videoPath = toolbar.downLoadAVCourseware(videoUrl);
            if(videoPath == ""){
                return;
            }
            console.log("===========mediaPlayer.ymVideoPlayerManagerPlayFielByFileUrl==========",videoPath)
            mediaPlayer.ymVideoPlayerManagerPlayFielByFileUrl("file:///" + videoPath ,fileName,0,fileId,videoUrl);
            mediaPlayer.visible = true;
            loadingView.hideView();
        }
        // 确定选择文件上传
        onSigAccept: {
            console.log("====selectd file is", fileUrl);
            var userInfoObj = toolbar.getUserInfo();
            var lessonId = userInfoObj["classroomId"];
            var userId = userInfoObj["userId"];
            var token = userInfoObj["appKey"];
            var enType = userInfoObj["envType"];
            uploadFileManager.upLoadFileToServer(fileUrl, lessonId, userId, token, enType);
        }
        // 取消选择文件上传
        onSigReject: {
            console.log("====canceled select file");
        }
    }

    //音频播放器
    YMAudioPlayer {
        id:audioPlayer
        visible: false
        z: 93
        width: 550 * widthRate
        height:  60 * heightRate
        x: (parent.width - width - audiovideoview.width) * 0.5
        y: parent.height - height - 120 * heightRate
        userRole: currentUserRole
        onSigClose: {
            console.log("=====onSigClose======",currentUserRole)
            if(currentUserRole != 0){
                return;
            }
            var lastIndex = address.lastIndexOf(".");
            var suffix = address.substring(lastIndex + 1, address.length);
            toolbar.setAVCourseware(vaType, controlType, times, address, fileId, suffix);
            audioPlayer.visible = false;
        }
        onSigPlayerMedia:  {
            if(currentUserRole != 0){
                return;
            }

            var lastIndex = address.lastIndexOf(".");
            var suffix = address.substring(lastIndex + 1, address.length);
            toolbar.setAVCourseware(vaType, controlType, times, address, fileId, suffix);
        }
    }

    //视频播放器
    YMVideoPlayer {
        id:mediaPlayer
        width: 600 * widthRate
        height: 430 * heightRate
        y: (parent.height - height)/2
        x: (parent.width - width)/2
        z: 93
        visible: false
        userRole: currentUserRole
        onSigClose: {
            if(currentUserRole != 0){
                return;
            }
            var lastIndex = address.lastIndexOf(".");
            var suffix = address.substring(lastIndex + 1, address.length);
            toolbar.setAVCourseware(vaType, controlType, times, address, fileId, suffix);
            mediaPlayer.visible = false;
        }
        onSigPlayerMedia:{
            if(currentUserRole != 0){
                return;
            }
            var lastIndex = address.lastIndexOf(".");
            var suffix = address.substring(lastIndex + 1, address.length);
            toolbar.setAVCourseware(vaType, controlType, times, address, fileId, suffix);
        }
    }

    //计时器
    YMTimerView{
        id: timerView
        x: (parent.width - width) * 0.5
        y: (parent.height - height) * 0.5
        visible: false
        z: 92
        userRole:currentUserRole
        //开始计时器
        onSigStartAddTimer:{
            //            qosApiMgr.clickTimer(curriculumData.getCurrentIp());
            toolbar.sendTimer(1,1,currentTime);
        }
        //停止计时器
        onSigStopAddTimer:
        {
            toolbar.sendTimer(1,2,currentTime);
        }
        //重置计时器
        onSigResetAddTimer:
        {
            toolbar.sendTimer(1,3,0);
        }

        //开始倒计时
        onSigStartCountDownTimer:
        {
            toolbar.sendTimer(2,1,currentTime);
            //            qosApiMgr.clickCountdown(curriculumData.getCurrentIp());
        }

        //停止倒计时
        onSigStopCountDownTimer:
        {
            toolbar.sendTimer(2,2,currentTime);
        }

        //重置倒计时
        onSigResetCountDownTimer:
        {
            toolbar.sendTimer(2,3,0);
        }

        onSigCloseTimerView:
        {
            toolbar.sendTimer(currentViewType,4,currentTime);
        }
    }

    //学生答题器
    YMStuAnswerView{
        id: stuAnswerView
        z: 91
        visible: false
        anchors.centerIn: parent
        onSigSubmitAnswer: {
            if(isCorrect){
                answerTipsView.showCorrectOk();
            }else{
                answerTipsView.showAnswerError();
            }
            answer.submitAnswer(correctAnswer,selecteAnswer,answerTime,isCorrect);
        }

        onSigTimerOut: {
            answerTipsView.showTimeOut();
        }
    }

    //学生答题提醒页面
    YMAnswerTipsView{
        id: answerTipsView
        z: 91
        visible: false
        anchors.centerIn: parent
    }

    //答题器管理类
    Answer{
        id:answer
        onSigAnswerStatistics: {
            console.log("onSigAnswerStatistics--", itemAnswer, submitNum, accuracy,JSON.stringify(itemData));
            if(currentUserRole == 0){
                beingAnswerView.visible = false;
                answerStatistics.itemAnswer = itemAnswer;
                answerStatistics.submitNum = submitNum;
                answerStatistics.accuracy = accuracy;
                answerStatistics.visible = true;
                answerStatistics.updateItemData(itemData);
            }
        }

        onSigDrawAnswer: {
            console.log("onSigDrawAnswer--", itemId, JSON.stringify(item), itemAnswer, countDownTime);
            if(currentUserRole == 1){
                answerTipsView.answerCorrect = itemAnswer;
                stuAnswerView.correctAnswer = itemAnswer;
                stuAnswerView.countDownTime = countDownTime;
                stuAnswerView.updateButton(item);
                stuAnswerView.visible = true;
                return;
            }

            beingAnswerView.addTimeCount = countDownTime;
            beingAnswerView.answerSrt = itemAnswer;
            beingAnswerView.visible = true;
            answerView.isStartTopic = true;
            beingAnswerView.startTime();
        }

        onSigAnswerCancel:{
            console.log("=====onSigAnswerForceFin======");
            beingAnswerView.visible = false;
            if(currentUserRole == 1 && stuAnswerView.isStartTopic == false){
                stuAnswerView.visible = false;
                answerTipsView.showTeaCancel();
            }
        }

        onSigAnswerForceFin:{
            console.log("=====onSigAnswerForceFin======");
            beingAnswerView.visible = false;
            if(currentUserRole == 1 && stuAnswerView.isStartTopic == false){
                stuAnswerView.visible = false;
                answerTipsView.showTeaOverAnswer();
            }
        }

    }

    //答题器选题页面
    YMAnswerView{
        id: answerView
        x: (parent.width - width) * 0.5
        y: (parent.height - height) * 0.5
        visible: false
        z: 92
        onSigStartTopic: {
            console.log("===onSigStartTopic===",answerText,JSON.stringify(answerArray),downTime);
            answer.sendAnswer("", answerArray, answerText, downTime);
            beingAnswerView.visible = true;
        }
    }

    //答题中
    YMBeingAnswerView{
        id: beingAnswerView
        x: (parent.width - width) * 0.5
        y: (parent.height - height) * 0.5
        visible: false
        z: 92
        onSigEndAnswer:{
            if(currentUserRole == 0){
                answer.forceFinAnswer(0);
                answer.queryStatistics();
                answerView.isStartTopic = false;
                answerStatistics.visible = true;
            }
            answerView.isStartTopic = false;
        }

        onSigResetAnswer:{
            answer.cancelAnswer(0);
            answerView.isStartTopic = false;
            answerView.visible = true;
        }

    }

    //答题统计
    YMAnswerStatistics{
        id: answerStatistics
        x: (parent.width - width) * 0.5
        y: (parent.height - height) * 0.5
        visible: false
        z: 92
    }

    //红包雨
    RedRainView{
        id: redView
        z: 91
        visible: false
        anchors.fill: parent
        isDisable: currentUserRole == 1 ? true : false
    }

    //积分排行
    YMRedPackgeRankingView{
        id: redPackgeRankingView
        anchors.fill: parent
        visible: false
        z: 92
    }

    //退出教室与进入教室提醒
    YMLessonTipsView{
        id: tipsView
        z: 92
        visible: false
        onSigAutoExit: {
            toolbar.exitChannel();
            toolbar.uninit();
            toolbar.uploadLog();
            Qt.quit();
        }

        onSigFinishLesson: {
            toolbar.endClass();
        }

        onSigHalt: {
            toolbar.exitClassRoom();
        }

        onSigStartLesson: {
            isStartLesson = true;
            toolbar.beginClass();
            toolbar.initVideoChancel();
            hasTeacher = true;
            headView.setLessonState(1); //开始上课
        }
    }

    YMLessonManager {
        id: miniMgr
        onSigCoursewareTotalPage: {
            h5CoursewarePageTotal = pageTotal;
        }
    }

    YMNetworkManagerAdapert{
        id: networkMgr
        onSigNetworkInfo: {
            headView.netwrokStatus = netType;
            deviceSettingView.interNetGrade = parseInt(netType);
        }
        onSigRouting: {
            console.log("===onSigRouting===")
            deviceSettingView.routingGrade = parseInt(delay);
            deviceSettingView.setVisibleNetwork();
        }

        onSigNetworkType: {
            console.log("===netType===",netType);
            deviceSettingView.interNetStatus = netType;
        }
    }

    ClassInfoManager {
        id: classInfoManager
        onSigCloudDiskInfo: {
            console.log("====ClassInfoManager::onSigCloudDiskInfo====", JSON.stringify(clouddiskInfo))
            diskMainView.resetCloudDiskViewData(clouddiskInfo)
        }

        onSigSaveResourceSuccess: {
            setTips("上传资源成功");
            refreshCloudDisk();
        }

        onSigSaveResourceFailed: {
            setTips("上传资源失败");
        }
    }

    // 提示
    Rectangle {
        id: ymtip
        z: 999
        visible:  false
        width: 400 * heightRate
        height: 50 * heightRate
        color: "#4E5065"
        radius: 6 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 160 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - audiovideoview.width - width) * 0.5
        Text {
            id: tipText
            z: 2
            anchors.centerIn: parent
            color: "#ffffff"
            font.family: "Microsoft YaHei"
            font.pixelSize: 22 * heightRate
        }
        Timer {
            id: tipsTime
            interval: 3000
            running: false
            repeat: false
            onTriggered: {
                ymtip.visible = false;
            }
        }
    }

    Component.onCompleted: {
        curriculumData.getListAllUserId();
        networkMgr.setNetIp(socketIp);
        if(statusCode == 30001){
            tipsView.showDownLesson();
        }
    }

    // 获取当前用户角色
    function getCurrentUserRole(){
        var userRole = toolbar.getUserInfo()["userRole"];
        var role = "tea";
        if(userRole == 0){
            role = "tea";
        }
        else if(userRole == 1){
            role = "stu";
        }
        else if(userRole == 2){
            role = "assistant";
        }
        console.log("====getCurrentUserRole===",role)
        return role;
    }

    // 通过videoId的用户类型
    function getUserType(videoId){
        var userTypes = "unknown";
        console.log("====getUserType", JSON.stringify(infoModel))
        for (var i = 0; i < infoModel.count; i++){
            if(infoModel.get(i).videoId == videoId){
                userTypes = infoModel.get(i).userType;
            }
        }
        return userTypes;
    }

    // 通过videoId获取用户名
    function getUserName(videoId){
        var userName = "unknown";
        console.log("====getUserName", JSON.stringify(infoModel))
        for (var i = 0; i < infoModel.count; i++){
            if(infoModel.get(i).videoId == videoId){
                userName = infoModel.get(i).userName;
            }
        }
        return userName;
    }

    // 刷新云盘
    function refreshCloudDisk(){
        var userInfoObj = toolbar.getUserInfo();
        var classroomId = userInfoObj["classroomId"];
        var apiUrl = userInfoObj["apiUrl"];
        console.log("=====refreshCloudDisk===", classroomId, apiUrl)
        classInfoManager.getCloudDiskList(classroomId, apiUrl)
    }

    // 设置提示
    function setTips(tipsText){
        tipsTime.restart();
        ymtip.visible = true;
        tipText.text = tipsText
    }
}
