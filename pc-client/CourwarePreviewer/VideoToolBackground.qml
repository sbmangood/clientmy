import QtQuick 2.5
import QtGraphicalEffects 1.0
import CurriculumData 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import VideoRender 1.0
import ExternalCallChanncel 1.0
import NetworkAccessManagerInfor 1.0
import YMCloudClassManagerAdapter 1.0
import "./Configuuration.js" as Cfg

/*
  * 视频工具栏
  */

Rectangle {
    id:videoToolBackground

    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    signal allWriteTrail(var trailData);//获取到的 所有的课堂轨迹
    //边框阴影
    property int borderShapeLens: (rightWidthX - midWidth - midWidthX) > 10 ? 10 : (rightWidthX - midWidth - midWidthX)
    color: "#00000000"
    property string exitClassUserId: ""//学生退出教室Id
    property string bUserId: ""//B学生Id
    property string courseNameId: "";
    property string courseNamea: "";
    property string startEndTime: "";//起止结束时间
    property var programInfoBuffer: [];//节目清单缓存
    property  int serverClassTime: 0;
    property var currentTimeInLocal: 0;

    //课程类型
    property string  lessonType: "O"

    //总长度时间
    property int  totalLengthTime: 0;

    //当前时间的长度
    property int  currentLengthTime: 0

    //当前时间的字符串
    property string  currentLengthTimeStr:""

    //是否加载数据
    property bool  loadDataStatus: false
    property int  loadDataStatusInt: 0;
    property bool isPlanSelecte: true;//是否支持该讲义属性

    //按键操作
    property bool  audioVideoHandl: false//defulat false
    //关闭界面
    signal sigCloseWidget();
    //学生类型
    property  string  studentType: curriculumData.getCurrentUserType()

    //打开关闭本地摄像头、麦克风
    signal sigOperationVideoOrAudio(string userId , string videos , string audios);

    //音频，音视频切换
    signal sigOnOffVideoAudio(string videoType);

    //用户授权信号
    signal sigSetUserAuth(string userId,string authStatus);
    //选择课件显示
    signal sigSetLessonShow(string message);

    //播放视频源
    signal sigPlayerVideo(var videoSoucre,var videoName);

    //播放mp3信号
    signal sigPlayerAudio(var audioSoucre,var audioName);

    //创建房间信号
    signal sigCreateClassrooms();

    //最小化
    signal sigMinFrom();

    //结束课程返回时间
    signal sigGetCourse(bool isDisplay,var playerTime);

    //练习题菜单信号
    signal sigSubjectInfo(var dataArray);

    //获取讲义失败信号
    signal sigLoadLessonFails();

    //获取题目失败
    signal sigGetQuestionFailed();

    //题目信息信号 (题目信息 , 浏览状态：false做题模式、true:浏览模式)
    signal sigQuestionInfos(var questionInfo,var answerArray,var photosArray,var browseStatus);

    //学习目标信号
    signal sigLearningTargets(var targetData);

    //点击讲义发送命令
    signal sigHandoutInfos(var handoutData);

    //练习题是否显示有多题信号
    signal sigMultiTopic(var currentPage,var totalPage);

    //题目、讲义、栏目Id
    signal sigTopicIds(var questionId);
    //是否有子题信号
    signal sigIsTopicChild(var childStatus);

    //栏目下是否有子题
    signal sigIsMenuMultiTopics(var status);

    //错因列表
    signal sigErrorListed(var errorList);

    //讲义访问完成
    signal sigSynPlanSuccess();

    //批改成功信号
    signal sigCorreSuccessed();

    //选择讲义信号
    signal sigSelectePlan();

    //保存题目或者资源生成的底图接口,(注：questionId,resourceId 可以不用给参数)
    function saveBaseImage(planId,  itemId,  questionId,  resourceId,  baseImageUrl,  width,  height){
        cloudClassMgr.saveBaseImage(courseNameId,planId,itemId,questionId,resourceId,baseImageUrl,width,height);
    }

    //根据翻页传递的ID查询数据
    function getQuestionInfo(planId,columnId,questionId){
        cloudClassMgr.filterQuestionInfo(planId,columnId,questionId);
    }
    //是否第一次开始做题
    function getIsOneStartLesson(){
        return cloudClassMgr.getIsOneQuestion();
    }

    //根据讲义Id选中讲义项
    function selectePlanItem(planId){
        console.log("======selectePlanItem.id===========",planId);
        for(var i = 0; i < handoutModel.count; i++){
            if(handoutModel.get(i).id == planId){
                handoutCombox.currentIndex = i;
            }
        }
    }


    //学生提交练习题信息操作函数
    property var topicLessonId: [];
    property var topicQuestionId: [];
    property string topicPlanId: "";
    property var topicColumnId: [];

    function getAnalysisQuestionAnswer(lessonId,questionId, planId,columnId){
        topicLessonId = lessonId;
        topicQuestionId = questionId;
        topicPlanId = planId;
        topicColumnId = columnId;
        commitTimer.restart();
    }

    Timer{
        id: commitTimer
        interval: 5000
        repeat: false
        running: false
        onTriggered: {
            cloudClassMgr.findQuestionDetailById(topicLessonId,topicPlanId,topicColumnId,topicQuestionId)
        }
    }

    //获取错因列表
    function getErrorList(planId){
        cloudClassMgr.getErrorReasons(courseNameId,planId);
    }

    //老是提交批改
    function saveTeacherComment(prePlanId,itemId,commitParm){
        cloudClassMgr.saveTeacherComment(courseNameId,prePlanId,itemId,commitParm)
    }

    //继续留在教室
    function setStayInclassroom(){
        audioVideoHandl = false;
        for(var j = 0 ; j < listModel.count ;j++){
            var userId = listModel.get(j).userId;
            listModel.get(j).userAudio = "1"
            listModel.get(j).userVideo = "1";
            listModel.get(j).userAuth = "1";
            listModel.get(j).isVideo = "0";
            listModel.get(j).userOnline =curriculumData.justUserOnline(userId );
        }
        externalCallChanncel.setStayInclassroom();
        testTime.stop();
    }

    //获取结束课程是否弹窗显示状态
    function getEndCourseStatus(){
        if(!testTime.running){
            //console.log("===getEndCourseStatus====")
            sigGetCourse(false,"0");
            return
        }
        console.log("==getEndCourseStatus111==",testTime.running);
        var totalTimers = currentLengthTime + serverClassTime;
        console.log("=====totalTime::currentTime=====",currentLengthTime ,totalLengthTime);
        if(currentLengthTime >= totalLengthTime){
            //console.log("=======达标======")
            sigGetCourse(false, parseInt(totalTimers / 60));
        }else{
            //console.log("=======未达标======")
            sigGetCourse(true, parseInt(totalTimers / 60));
        }
    }

    //当前版本是否支持新讲义
    function updatePlanStatus(status){
        isPlanSelecte = status;
    }

    //翻页重新获取课件信息
    function requstLessonInfo(){
        networkMgr.getVideoNameInfor();
    }

    //选择音频课件索引
    function selectedLessonIndex(){
        audioCombobox.currentIndex = 0;
    }

    //获取当前视频还是音频模式
    function getIsVideo(){
        return curriculumData.getIsVideo();
    }

    //获得音频的图片路径
    function getImagePath(paths){
        var volumeh =  parseInt(paths) ;
        if(volumeh >= 7) {
            return "qrc:/images/videocall7sd.png";
        }
        if(volumeh == 6) {
            return "qrc:/images/videocall6sd.png";
        }
        if(volumeh == 5) {
            return "qrc:/images/videocall5sd.png";
        }
        if(volumeh == 4) {
            return "qrc:/images/videocall4sd.png";
        }
        if(volumeh == 3) {
            return "qrc:/images/videocall3sd.png";
        }
        if(volumeh == 2) {
            return "qrc:/images/videocall2sd.png";
        }
        if(volumeh <= 1) {
            return "qrc:/images/videocall1sd.png";
        }
    }

    //处理操作界面
    function handlPromptInterfaceHandl( inforces){
        //console.log("handlPromptInterfaceHandl:",inforces)
        if(inforces == "51") {
            //学生离开教室重置状态处理
            for(var j = 0 ; j < listModel.count ;j++){
                var userId = listModel.get(j).userId;
                if(userId == exitClassUserId){
                    listModel.get(j).userAudio = "1"
                    listModel.get(j).userVideo = "1";
                    listModel.get(j).userAuth = "1";
                    listModel.get(j).isVideo = "0";
                    listModel.setProperty(j,"userOnline",curriculumData.justUserOnline(userId ));
                }
            }
            return;
        }
        //B学生在线操作
        if(inforces == "b_Online"){
            for(var j = 0 ; j < listModel.count ;j++){
                var userId = listModel.get(j).userId;
                if(userId == bUserId){

                    var isVideo = curriculumData.getIsVideo();
                    var userAuth = curriculumData.getUserIdBrushPermissions(userId);
                    var userAudio = curriculumData.getUserPhone(userId);
                    var userVideo = curriculumData.getUserCamcera(userId);
                    //console.log("=====videoToolBakcg::b_Online=======",bUserId,isVideo,userVideo,userAudio);
                    listModel.get(j).userOnline = "1";
                    listModel.get(j).isVideo = isVideo;
                    listModel.get(j).userAuth = userAuth;
                    listModel.get(j).userAudio = userAudio;
                    listModel.get(j).userVideo = userVideo;
                    break;
                }
            }
            return;
        }

        //改变频道跟音频
        if(inforces == "61") {
            externalCallChanncel.changeChanncel();
            for(var j = 0 ; j < listModel.count ;j++){
                listModel.setProperty(j,"isVideo",curriculumData.getIsVideo());
                listModel.setProperty(j,"supplier",curriculumData.getUserChanncel());
            }
            return;
        }
        //改变权限
        if(inforces == "62") {
            for(var j = 0 ; j < listModel.count ;j++){
                listModel.setProperty(j,"userAuth",curriculumData.getUserIdBrushPermissions( listModel.get(j).userId ));
            }
            return;
        }

        //音视频状态
        if(inforces == "68") {
            for(var j = 0 ; j < listModel.count ;j++){
                listModel.setProperty(j,"userVideo",curriculumData.getUserCamcera( listModel.get(j).userId ));
                listModel.setProperty(j,"userAudio",curriculumData.getUserPhone( listModel.get(j).userId ));
            }
            return;
        }
    }

    //初始化上课状态
    function initChancel(){
        externalCallChanncel.initVideoChancel();
    }

    //获取线路
    function getWay(){
        return curriculumData.getUserChanncel();
    }


    //设置开始上课
    function setStartClassTimeData(times){
        console.log("setStartClassTimeData:: ==",times);

        serverClassTime =  parseInt(times);
        var data = new Date();
        currentTimeInLocal = data.getTime() / 1000 ;
        currentLengthTime = parseInt(times) / 60 ;
        //currentLengthTime = parseInt(times) / 60 ;
        testTime.restart();
        audioVideoHandl = true;
        //externalCallChanncel.initVideoChancel();
        for(var j = 0 ; j < listModel.count ;j++){
            var userId = listModel.get(j).userId;
            var isVideo = curriculumData.getIsVideo();
            var supplier = curriculumData.getUserChanncel();
            var userVideo = curriculumData.getUserCamcera(userId);
            var userAudio = curriculumData.getUserPhone(userId);
            var userOnline = curriculumData.justUserOnline(userId)
            var userAuth = curriculumData.getUserIdBrushPermissions(userId);

            //console.log("startclass:isVideo",userId,isVideo, supplier,userVideo,userAudio);

            listModel.setProperty(j,"isVideo",isVideo);
            listModel.setProperty(j,"supplier",supplier);
            listModel.setProperty(j,"userVideo",userVideo);
            listModel.setProperty(j,"userAudio",userAudio);
            listModel.setProperty(j,"userOnline",userOnline);
            listModel.setProperty(j,"userAuth",userAuth);
        }
    }

    //处理B学生状态
    function setBStatus(){
        for(var j = 0 ; j < listModel.count ;j++){
            var userId = listModel.get(j).userId;
            if(userId == bUserId){
                var userOnline = curriculumData.justUserOnline(userId);
                var isVideo = curriculumData.getIsVideo();
                var supplier = curriculumData.getUserChanncel();
                listModel.get(j).isVideo = isVideo;
                listModel.get(j).supplier = supplier;
                listModel.get(j).userVideo ="1";
                listModel.get(j).userAudio ="1";
                listModel.get(j).userOnline = userOnline; //0离线， 1在线
                //console.log("B_StudentStatus::info",userId, supplier,bUserId,userOnline);
                return;
            }
        }
    }

    Timer{
        id:testTime
        running: false
        interval: 10000
        repeat: true
        onTriggered: {
            var tempdate = new Date();
            currentLengthTime = (tempdate.getTime() / 1000 - currentTimeInLocal + serverClassTime ) / 60;
            //currentLengthTime++;
        }
    }

    onCurrentLengthTimeChanged: {
        currentLengthTimeStr = "";
        var timelh = parseInt( currentLengthTime / 60 ) ;
        if(timelh > 9) {
            currentLengthTimeStr = timelh.toString() + ":";
        }else {
            currentLengthTimeStr = "0"+timelh.toString() + ":";
        }
        var timelm = Math.round( currentLengthTime % 60);
        if(timelm > 9) {
            currentLengthTimeStr += timelm.toString() ;
        }else {
            currentLengthTimeStr += "0"+timelm.toString() ;
        }
    }

    //边框阴影
    Rectangle{
        id:borderShapes
        width: borderShapeLens
        height: parent.height
        anchors.left: parent.left
        anchors.top: parent.top
        color: "#00000000"
        Image {
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            source: "qrc:/images/rectangletwothree.png"
        }
    }
    //背景463062
    Rectangle{
        id:videoToolBackgroundColor
        width: parent.width - borderShapeLens
        height: parent.height
        anchors.left: borderShapes.right
        anchors.top: parent.top
        color: "#ffffff"
        z:2

        //图标
        Image {
            id: tagImage
            width: 14 * widthRates
            height: 17  * heightRates
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 10 * widthRates
            anchors.topMargin:  16  * heightRates
            source: "qrc:/images/icon_time.png"
        }

        Text {
            id: courseNameText
            //width: 56 * widthRates
            height: 20  * heightRates
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 38 * widthRates
            anchors.topMargin:  8  * heightRates
            font.pixelSize: 14 * heightRates
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: courseNamea
        }

        Text {
            width: 68 * widthRates
            height: 20  * heightRates
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 38 * widthRates
            anchors.topMargin:  30  * heightRates
            font.pixelSize: 14 * heightRates
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: courseNameId
        }

        //课程类型
        Image {
            width: 33 * widthRates
            height: 16  * heightRates
            anchors.left: courseNameText.right//parent.left
            anchors.top: parent.top
            anchors.leftMargin: 3 * widthRate//90 * widthRates
            anchors.topMargin:  10  * heightRates
            fillMode: Image.PreserveAspectFit
            source: lessonType == "O" ? "qrc:/images/icon_dingdan.png" : "qrc:/images/icon_shiting.png"
        }

        //关闭按钮
        MouseArea{
            id: closeButton
            width: 30 * heightRate
            height: 26 * heightRate
            hoverEnabled: true
            anchors.right: parent.right
            anchors.rightMargin: 5 * widthRate
            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/images/cr_btn_close_sed1.png" : "qrc:/images/cr_btn_close1.png"
            }
            onClicked: {
                videoToolBackground.focus = true;
                if(isStartLesson == false){
                    trailBoardBackground.setExitProject();
                    return;
                }
                sigCloseWidget();
            }
        }
        //最小化按钮
        MouseArea{
            width: 30 * heightRate
            height: 26 * heightRate
            hoverEnabled: true
            anchors.right: closeButton.left
            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/images/cr_btn_suoxiao_sed1.png" : "qrc:/images/cr_btn_suoxiao1.png"
            }
            onClicked: {
                sigMinFrom();
            }
        }

        //时间进度
        ProgressBar{
            id:timeProgressBar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin:54 * heightRates
            height: 5  * heightRates
            width: parent.width
            maximumValue: totalLengthTime
            minimumValue: 0
            value: currentLengthTime >= totalLengthTime ? totalLengthTime : currentLengthTime
            style:  ProgressBarStyle {
                background: Rectangle {
                    color: "#dddddd"
                    implicitWidth: timeProgressBar.width
                    implicitHeight: timeProgressBar.height

                }
                progress: Rectangle {
                    id:timeProgressBars
                    color: "#ff9000"
                }
            }
        }

        Rectangle{
            color: "#f6f6f6"
            width: parent.width
            height: 18 * heightRate
            anchors.top: timeProgressBar.bottom

            Text {
                height: parent.height
                anchors.left: parent.left
                anchors.leftMargin: 5 * heightRate
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 13  * heightRate
                color: "#ff5000"
                wrapMode:Text.WordWrap
                font.family: "Microsoft YaHei"
                text: currentLengthTimeStr
            }

            Text {
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                anchors.right: parent.right
                anchors.rightMargin: 5 * widthRate
                font.pixelSize: 13  * heightRate
                wrapMode:Text.WordWrap
                font.family: "Microsoft YaHei"
                text: startEndTime
                color: "#666666"
            }
        }

        //讲义列表
        YMHandoutComboxControl{
            id: handoutCombox
            width: 180 * widthRates
            height: handoutModel.count > 0 ? 30 * heightRates : 0
            anchors.left: parent.left
            anchors.leftMargin: (videoToolBackgroundColor.width  - 180 * widthRates ) / 2
            anchors.top: timeProgressBar.bottom
            anchors.topMargin: 20 * heightRates
            model: handoutModel
            visible: handoutModel.count > 0 ? true : false
            onCurrentIndexChanged: {
                var id = handoutModel.get(currentIndex).value;
                var planType = handoutModel.get(currentIndex).planType;
                var handountName = handoutModel.get(currentIndex).planName;

                console.log("=========plandInfo========",id,planType,handountName);

                if(id == -1){
                    return;
                }
                if(isPlanSelecte == false){
                    currentIndex = 0;
                    showMessageTips("您的学生软件版本太低,无法使用最新讲义,请让学生更新至最新版本3.0或直接使用老版讲义上课")
                    return;
                }

                if(planType == 1){//新讲义
                    isHomework = 1;
                    synchronizePlanId = id;
                    sigSelectePlan();
                    getErrorList(id);
                    cloudClassMgr.getIdByColumnInfo(courseNameId,id,planType,handountName);
                }
                if(planType == 2 || planType == 100){//100 erp的讲义
                    isHomework = 2;
                    cloudClassMgr.getCoursewareList(id);
                    //networkMgr.sendCoursewareNameInfor(handountName);
                    console.log("========isHomework=========",planType,isHomework)
                }

                if(planType == 3){//视频

                }
            }
        }

        //选择音频文件
        ComboboxControl{
            id: audioCombobox
            width: 180 * widthRates
            height: audioModel.count > 0 ? 30 * heightRates : 0
            anchors.left: parent.left
            anchors.leftMargin: (videoToolBackgroundColor.width  - 180 * widthRates ) / 2
            anchors.top: handoutCombox.bottom
            anchors.topMargin: 8 * heightRates
            dataModel: audioModel
            visible: audioModel.count > 0 ? true : false

            onSigId: {
                var videoUrl = fileUrl;//networkMgr.getVideoFileUrlName(lessonIdName)
                console.log("====videoUrl====",mediaType,videoUrl);
                if(mediaType == 2){
                    sigPlayerAudio(videoUrl,lessonIdName)
                }
                if(mediaType == 3){
                    var videoPath = videoUrl;//"file:///C:/Users/Administrator/Downloads/20171128124011.mp4";//
                    sigPlayerVideo(videoPath,lessonIdName);
                }
            }
        }

        ListView{
            id:videoListView
            anchors.top: audioCombobox.bottom
            anchors.left:parent.left
            width: videoToolBackgroundColor.width
            anchors.bottom: parent.bottom
            delegate: listViewDelegate
            model: listModel
            clip: true
            boundsBehavior: ListView.StopAtBounds
        }

        ListModel{
            id:listModel
        }

        Component{
            id:listViewDelegate
            Rectangle {
                id:itemDelegate
                color: "#00000000"
                width: videoToolBackgroundColor.width  //200 * widthRates
                height: 200 * heightRates
                Rectangle{
                    id:itemDelegateBackGround
                    width: 180 * widthRates
                    height: 190 * heightRates
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: (videoToolBackgroundColor.width  - 180 * widthRates ) / 2
                    anchors.topMargin: 5 * heightRates
                    color: "#ffffff"

                    //视频显示
                    VideoRender{
                        id:videoRender
                        anchors.fill: parent
                        imageId: userId
                        z: 5
                        visible: isVideo == "1" ?  true : false
                    }

                    //底部信息显示
                    Item{
                        id: audioItem
                        z: 6
                        width: parent.width
                        height: 32 * heightRates
                        anchors.bottom: parent.bottom
                        //打开关闭音频控制图片
                        Image{
                            id: audioImage
                            width: 38 * heightRate
                            height: 20 * heightRate
                            anchors.left: parent.left
                            anchors.leftMargin: 5 * widthRate
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 5 * widthRate
                            visible: isteacher == "1" ? true : false
                            source: audioVideoHandl ? (isVideo == "0" ? (userAudio == "1" ? "qrc:/images/audio_opened.png" : "qrc:/images/audio_voice_off.png") : "qrc:/images/audio_closed.png" ) : "qrc:/images/audio_closed.png"
                            MouseArea{
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: audioVideoHandl
                                onClicked: {
                                    videoPopup.close();
                                    if(isVideo =="0"){
                                        audioPopup.x = 20 * widthRates;
                                        audioPopup.y = audioModel.count > 0 ? (itemDelegate.height *( index +1)) + 145 * heightRates : (itemDelegate.height *( index +1)) + 105 * heightRates;
                                        audioPopup.userId = userId;
                                        audioPopup.isAudio = userAudio =="1" ? true : false;
                                        audioPopup.open();
                                        videoToolBackground.focus = true;
                                        return;
                                    }
                                    sigOnOffVideoAudio("0");
                                    externalCallChanncel.closeVideo("0");//A通道关闭摄像头
                                    sigOperationVideoOrAudio(userId,"0",userAudio);
                                    for(var i =0; i < listModel.count; i++){
                                        listModel.get(i).isVideo = "0";
                                    }
                                }
                            }
                        }

                        //打开关闭视频
                        Image{
                            id: videoImage
                            width: 38 * heightRate
                            height: 20 * heightRate
                            anchors.left: audioImage.right
                            anchors.leftMargin: 5 * widthRate
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 5 * widthRate
                            visible: isteacher == "1" ? true : false
                            source: audioVideoHandl ? (  isVideo == "1" ? ( userAudio =="0" && userVideo == "0" ? "qrc:/images/video_camera_off.png" : "qrc:/images/video_opened.png"):  "qrc:/images/video_closed.png" ) : "qrc:/images/video_closed.png"
                            MouseArea{
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: audioVideoHandl
                                onClicked: {
                                    audioPopup.close();
                                    if(isVideo == "1"){
                                        videoPopup.x = 45 * widthRates;
                                        videoPopup.y = audioModel.count > 0 ? (itemDelegate.height *( index +1)) + 145 * heightRates : (itemDelegate.height *( index +1)) + 105 * heightRates;
                                        videoPopup.userId = userId;
                                        videoPopup.isAudio = userAudio == "1" ? true : false;
                                        videoPopup.isVideo = userVideo == "1" ? true : false;
                                        videoPopup.video = userVideo;
                                        videoPopup.audio = userAudio;
                                        videoPopup.open();
                                        return;
                                    }
                                    sigOnOffVideoAudio("1");
                                    externalCallChanncel.closeVideo("1");//A通道打开摄像头
                                    userVideo = curriculumData.getIsVideo();
                                    sigOperationVideoOrAudio(userId,userVideo,userAudio);
                                    //console.log("=====open::came=====",userAudio,userVideo,isVideo);
                                    for(var i =0; i < listModel.count; i++){
                                        listModel.get(i).isVideo = "1";
                                    }
                                }
                            }
                        }
                        //授权操作按钮
                        Image{
                            id: authImage
                            width: 40 * heightRate
                            height: 26 * heightRate
                            anchors.right: parent.right
                            anchors.rightMargin: 5 * widthRate
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 5 * heightRate
                            fillMode: Image.PreserveAspectFit
                            visible:  isteacher != "1" ? (userOnline =="1" ? true : false) : false
                            source: userOnline == "1"? (userAuth == "0" ? "qrc:/images/shouquan_off.png" : "qrc:/images/shouquan_on.png") : "qrc:/images/shouquan_off.png"
                            MouseArea{
                                anchors.fill: parent
                                enabled: userOnline == "1" ? true : false
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if(userAuth == "0"){
                                        userAuth = "1";
                                        sigSetUserAuth(userId,userAuth);
                                    }else{
                                        userAuth = "0";
                                        sigSetUserAuth(userId,userAuth);
                                    }
                                }
                            }
                        }
                    }

                    //操作背景
                    Rectangle{
                        anchors.fill: parent
                        z: 5
                        color: "#ffffff"
                        visible: userOnline == "1" && audioVideoHandl ? (isVideo == "1" ? (userVideo == "1" ?  false: true) : true ) :  true
                        Image{
                            anchors.fill: parent
                            source: audioVideoHandl
                                    ? (userOnline == "1" ? "qrc:/images/auvodio_sd_bg_onlinetwox.png" : "qrc:/images/auvodio_sd_bg_offlinetwox.png")
                                    : (isteacher == "1" ? "qrc:/images/auvodio_sd_bg_onlinetwox.png"  : userOnline == "1" ? "qrc:/images/auvodio_sd_bg_onlinetwox.png" :"qrc:/images/auvodio_sd_bg_offlinetwox.png")
                        }
                    }

                    //学生头像及信息显示
                    Item{
                        z: 5
                        height:  45 * heightRates
                        width: parent.width
                        Row{
                            z: 6
                            anchors.fill: parent
                            anchors.left: parent.left
                            anchors.leftMargin: 5 * heightRates
                            anchors.verticalCenter: parent.verticalCenter
                            spacing:  6 * widthRates

                            Image{
                                z: 7
                                asynchronous: true
                                width: 32 * widthRates
                                height: 32 * widthRates
                                anchors.verticalCenter: parent.verticalCenter
                                source: headPicture == "" ? "qrc:/images/index_profile_defult@2x.png" : headPicture
                                onStatusChanged: {
                                    if(status == Image.Error){
                                        headPicture = "qrc:/images/index_profile_defult@2x.png"
                                    }
                                    //console.log("====status====",status,headPicture);
                                }
                            }

                            Column{
                                z: 8
                                width: parent.width
                                height: parent.height

                                Label{
                                    id: lableUserName
                                    text: userName == "" ? "" : userName
                                    height: parent.height * 0.5
                                    verticalAlignment: Label.AlignBottom
                                    font.pixelSize: 16 * heightRate
                                    font.family: "Microsoft YaHei"
                                }

                                Label{
                                    text: userOnline =="1" && audioVideoHandl ? (isVideo == "0" ? "正在音频对话..." : "正在视频对话...")  : (userId =="0"? "在线中..." : (userOnline =="1" ? "在线中..." :"离线中..."))
                                    height: userName == "" ? parent.height : parent.height * 0.5
                                    verticalAlignment: Label.AlignVCenter
                                    font.pixelSize: 11 * widthRates
                                    font.family: "Microsoft YaHei"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    //音频弹窗
    Popup{
        id: audioPopup
        z: 3
        visible: false
        width:  80 * widthRates
        height: 50 * heightRates
        background: Image{
            anchors.fill: parent
            source: "qrc:/images/btn_dakaitwosx.png"
        }

        property string userId: "";
        property string videoType: "" //0:关 1: 开
        property string audioType:  ""//
        property bool isAudio: true;

        MouseArea{
            id: audioMouseArea
            height: 30 * heightRates
            width: parent.width
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.top: parent.top
            Text{
                text:  audioPopup.isAudio ? "关闭麦克风" : "打开麦克风"
                anchors.fill: parent
                font.family: Cfg.font_family
                font.pixelSize: 12 * widthRates
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: parent.containsMouse ? "#ff5000" : "black"
            }
            onClicked: {
                if(audioPopup.isAudio){
                    audioPopup.audioType = "0";
                }else{
                    audioPopup.audioType = "1";
                }
                audioPopup.videoType = "0";
                for(var j = 0 ; j < listModel.count ;j++){
                    if(listModel.get(j).userId  == audioPopup.userId) {
                        videoToolBackground.sigOperationVideoOrAudio(audioPopup.userId ,  audioPopup.videoType ,  audioPopup.audioType);
                        if(audioPopup.isAudio){
                            externalCallChanncel.closeAudio("0");
                            listModel.get(j).userAudio = "0";
                        }else{
                            externalCallChanncel.closeAudio("1");
                            listModel.get(j).userAudio = "1";
                        }
                        listModel.get(j).isVideo = "0";
                        break;
                    }
                }
                audioPopup.close();
            }
        }
    }

    //音视频弹窗
    Popup{
        id: videoPopup
        z: 3
        visible: false
        width: 80 * widthRates
        height: 90 * heightRates
        background: Image{
            anchors.fill: parent
            source: "qrc:/images/btn_dakaitwosx.png"
        }

        property bool isAudio: false;
        property bool isVideo: false;
        property string userId: "";
        property string video: "1";
        property string audio: "0";

        MouseArea{
            id: audioButton
            height: 30 * heightRates
            width: parent.width
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.top: parent.top
            Text{
                text:  videoPopup.isAudio ? "关闭麦克风" : "打开麦克风"
                anchors.fill: parent
                font.family: Cfg.font_family
                font.pixelSize: 12 * widthRates
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: parent.containsMouse ? "#ff5000" : "black"
            }
            onClicked: {
                if(videoPopup.isAudio){
                    videoPopup.audio = "0";
                }else{
                    videoPopup.audio = "1";
                }
                for(var j = 0 ; j < listModel.count ;j++){
                    if(listModel.get(j).userId  == videoPopup.userId) {
                        videoToolBackground.sigOperationVideoOrAudio(videoPopup.userId , videoPopup.video ,  videoPopup.audio);
                        if(videoPopup.isAudio){
                            externalCallChanncel.closeAudio("0");
                            listModel.get(j).userAudio = "0";
                        }else{
                            externalCallChanncel.closeAudio("1");
                            listModel.get(j).userAudio = "1";
                        }
                        listModel.get(j).isVideo = "1";
                        break;
                    }
                }
                videoPopup.close();
            }
        }

        Rectangle{
            id: lineItem
            width: parent.width * 0.8
            height: 1
            color: "#cccccc"
            anchors.top: audioButton.bottom
            anchors.topMargin: 5 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MouseArea{
            height: 30 * heightRates
            width: parent.width
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.top: lineItem.bottom
            anchors.topMargin: 5 * heightRates
            Text{
                text: videoPopup.isVideo ? "关闭摄像头" : "打开摄像头"
                anchors.fill: parent
                font.family: Cfg.font_family
                font.pixelSize: 12 * widthRates
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: parent.containsMouse ? "#ff5000" : "black"
            }
            onClicked: {
                //video 0 是音频 1是音视频
                // 0 是关 1是开
                if(videoPopup.isVideo){
                    videoPopup.video = "0";
                }else{
                    videoPopup.video = "1";
                }

                for(var j = 0 ; j < listModel.count ;j++){
                    if(listModel.get(j).userId  == videoPopup.userId) {
                        videoToolBackground.sigOperationVideoOrAudio(videoPopup.userId , videoPopup.video ,  videoPopup.audio);
                        if(videoPopup.isVideo){
                            externalCallChanncel.closeVideo("0");
                            listModel.get(j).userVideo = "0";
                        }else{
                            externalCallChanncel.closeVideo("1");
                            listModel.get(j).userVideo = "1";
                        }
                        listModel.get(j).isVideo = "1";
                        break;
                    }
                }
                videoPopup.close();
            }
        }
    }

    CurriculumData{
        id:curriculumData
        onSigListAllUserId:{
            listModel.clear();
            for(var j = 0; j < list.length ; j++) {
                var dataObject = curriculumData.getUserInfo(list[j]);
                //console.log("==curriculumData==",JSON.stringify(dataObject));

                var userName = dataObject.userName;//用户名
                var userOnline = dataObject.userOnline;//用户在线状态
                var userAuth = dataObject.userAuth;//用户权限
                var isVideo = dataObject.isVideo;//是否为视频
                var userAudio = dataObject.userAudio//麦克风状态
                var userVideo = dataObject.userVideo;//视频状态
                var imagePath = dataObject.imagePath;//视频路径
                var isteacher = dataObject.isteacher;//老师状态
                var supplier = dataObject.supplier;//用户通道
                var headPicture = dataObject.headPicture; //用户头像
                //userVideo 0是关 1是开
                //userAudio 0是关 1是开
                //isVideo  0是关 1是开
                //userAuth 0未授权 1授权
                //userOnline 0离线 1在线
                //console.log("videoToolBackground::data:",userName,userAudio,userVideo,userOnline);
                listModel.append(
                            {   "userId":list[j]
                                , "userName": userName
                                , "userOnline":userOnline
                                , "userAuth":userAuth
                                , "isVideo": isVideo
                                , "userAudio": userAudio
                                , "userVideo": userVideo
                                , "imagePath": imagePath
                                , "isteacher":isteacher
                                , "supplier": supplier
                                , "headPicture": headPicture
                                , "volumes":"0" //设置音量
                            }
                            );
            }
        }
    }
    //操作视频
    ExternalCallChanncel{
        id:externalCallChanncel

        onSigCreateClassroom: {
            sigCreateClassrooms();
        }

        onCreateRoomFail:{
            popupWidget.setPopupWidget("createRoomFail");
        }
        //麦克风显示音量操作
        /*onSigAudioVolumeIndication:{
            var uids = uid.toString();
            var totalVolumes = totalVolume.toString();

            for(var j = 0 ; j < listModel.count ;j++){
                if(listModel.get(j).userId == uids) {
                    listModel.setProperty(j,"volumes",totalVolumes );
                }
            }
        }*/
    }

    MouseArea{
        anchors.fill: parent
        z:1
        onClicked: {
            videoToolBackground.focus = true;
        }
    }

    YMCloudClassManagerAdapter{
        id: cloudClassMgr

        onSigMiniHandoutInfo:
        {
            handoutModel.clear();
            coursewareListViewModel.clear();
            if(dataArray.length > 0){
                handoutModel.append(
                            {
                                "key": "请选择讲义",
                                "value": -1,
                            })
                for(var i = 0; i < dataArray.length; i++){
                    if(dataArray[i].images.length <= 0 && dataArray[i].type == 14 )
                    {
                        var types = "2";
                        if(dataArray[i].path.indexOf(".mp4") != -1 || dataArray[i].path.indexOf(".rmvb") != -1||dataArray[i].path.indexOf(".wmv") != -1||dataArray[i].path.indexOf(".avi") != -1)
                        {
                            types = "3"
                        }

                        audioModel.append({"key": dataArray[i].fileName,"values": types,"fileUrl":  dataArray[i].path});
                        continue;
                    }

                    console.log("=====dataArray======",dataArray[i].id,dataArray[i].planName,dataArray[i].createName);
                    handoutModel.append(
                                {
                                    "id": i,
                                    "key": dataArray[i].fileName,
                                    "value": i,
                                    "createName": dataArray[i].createName,
                                    "planDesc": dataArray[i].planDesc,
                                    "planName": dataArray[i].fileName,
                                    "planType": 2,
                                })
                    coursewareListViewModel.append(
                                {
                                    "id": i,
                                    "key": dataArray[i].fileName,
                                    "value": i,
                                    "createName": dataArray[i].fileName,
                                    "planDesc": dataArray[i].planDesc,
                                    "namess": dataArray[i].fileName,
                                    "planType": 2,
                                })
                }
                handoutCombox.currentIndex = 0;
                sigSynPlanSuccess();
            }
        }

        onSigHandoutInfo: {
            handoutModel.clear();
            coursewareListViewModel.clear();
            if(dataArray.length > 0){
                handoutModel.append(
                            {
                                "key": "请选择讲义",
                                "value": -1,
                            })
                for(var i = 0; i < dataArray.length; i++){
                    console.log("=====dataArray======",dataArray[i].id,dataArray[i].planName,dataArray[i].createName);
                    handoutModel.append(
                                {
                                    "id": dataArray[i].id,
                                    "key": dataArray[i].planName,
                                    "value": dataArray[i].id,
                                    "createName": dataArray[i].createName,
                                    "planDesc": dataArray[i].planDesc,
                                    "planName": dataArray[i].planName,
                                    "planType": dataArray[i].planType,
                                })
                    coursewareListViewModel.append(
                                {
                                    "id": dataArray[i].id,
                                    "key": dataArray[i].planName,
                                    "value": dataArray[i].id,
                                    "createName": dataArray[i].createName,
                                    "planDesc": dataArray[i].planDesc,
                                    "namess": dataArray[i].planName,
                                    "planType": dataArray[i].planType,
                                })
                }
                handoutCombox.currentIndex = 0;
                sigSynPlanSuccess();
            }
        }


        //老课件显示
        onSigCourseware: {
            sigSetLessonShow(dataStr);
        }

        //做题时获取题目失败
        onSigGetQuestionFail: {
            sigGetQuestionFailed();
        }

        //获取讲义失败
        onSigLoadLessonFail: {
            sigLoadLessonFails();
        }

        onSigHandoutMenuInfo: {
            sigSubjectInfo(dataArray);
        }

        onSigQuestionInfo: {
            //console.log("#######################",JSON.stringify(dataObjecte))
            sigQuestionInfos(dataObjecte,answerArray,photosArray,browseStatus);
        }
        //学习栏目显示副文本
        onSigLearningTarget: {
            sigLearningTargets(dataObjecte);
        }
        //发送选中讲义信息
        onSigSendHandoutInfo: {
            sigHandoutInfos(dataObjecte);
        }
        onSigShowPage: {
            sigMultiTopic(currentPage,totalPage);
        }
        //题目Id信号
        onSigTopicId: {
            sigTopicIds(questionId);
        }
        //是否有多题状态信号
        onSigIsChildTopic: {
            sigIsTopicChild(status)
        }
        //栏目是否有多题
        onSigIsMenuMultiTopic: {
            sigIsMenuMultiTopics(status);
        }
        //错因列表信号
        onSigErrorList: {
            sigErrorListed(errorList);
        }
        //批改成功信号
        onSigCorreSuccess: {
            sigCorreSuccessed();
        }
        //音视频获取
        onSigGetMeidiaInfo: {

        }
    }

    ListModel{
        id: handoutModel
    }

    NetworkAccessManagerInfor{
        id: networkMgr
        onSigSendCoursewareNameInfor: {
            console.log("=====onSigSendCoursewareNameInfor=====",contents)
            sigSetLessonShow(contents);
        }
        onSigAddWorkOrder: {
            console.log("===addWorkOrder====")
        }

        onSigVideoName: {
            //console.log("======infor========",JSON.stringify(infor))
            if(infor == "" || infor == []){
                return;
            }

            var dataObj = JSON.parse(infor);
            var dataArray = dataObj.data;
            if(dataArray == [] || dataArray.length == 0){
                return;
            }

            var key = "";
            var index1 = 0;
            var index2 = 0;
            var suffix = "";//后缀名
            var values = "0";

            programInfoBuffer.splice(0,programInfoBuffer.length);
            audioModel.clear();
            // audioModel.append({"key": "选择音频文件","values": "0","fileUrl": ""});
            if(dataArray.length > 0){
                programInfoBuffer = dataArray;
                for(var i = 0; i < dataArray.length; i++){
                    key = dataArray[i].docName;
                    var fileUrl = dataArray[i].fileUrl;
                    console.log("===key===",key,fileUrl);
                    index1 = key.lastIndexOf(".");
                    index2 = key.length;
                    suffix = key.substring(index1,index2).toLowerCase();//后缀名
                    values = "0";
                    if(suffix == ".mp3"){
                        values = "2";
                    }
                    if(suffix == ".mp4"){
                        values = "3";
                    }
                    audioModel.append({"key": key,"values": values,"fileUrl": fileUrl});
                }
            }

            audioCombobox.currentIndex = 0;
        }
    }

    Component.onCompleted: {
        if(loadDataStatus) {
            return;
        }
        loadDataStatus = true;
        curriculumData.getListAllUserId();
        totalLengthTime =curriculumData.courseTimeTotalLength;
        courseNameId = curriculumData.curriculumId;
        courseNamea = curriculumData.curriculumName;
        startEndTime = curriculumData.startToEndTime;
        networkMgr.getCoursewareNameInfor();
        networkMgr.getVideoNameInfor();
        var lessonTypes = curriculumData.getLessonType();
        lessonType =  lessonTypes == "" ? "O" : lessonTypes;

        //networkMgr.addWorkOrder("网络问题","一般","测试测试11111","http://static.1mifd.com/static-files/user_pics/171226/1233335/1712261523399247.jpg@,http://static.1mifd.com/static-files/user_pics/171226/1233335/1712261523399247.jpg");
        //console.log("====totalLengthTime===",totalLengthTime)

        cloudClassMgr.getLessonList();//("813552");//courseNameId

        allWriteTrail(cloudClassMgr.getLessonWriteTrail(courseNameId));
    }

    function updatePlanSelecte(){
        handoutCombox.currentIndex = 0;
    }

    function getFindItemById( itemId, lessonId, planId, questionId){
        cloudClassMgr.findItemById(lessonId,planId,itemId,questionId);
    }

    function getFileName(url){
        var lastindex = url.indexOf("?");
        var fileName = url.substring(lastindex - 18,lastindex);

        for(var i = 0; i < programInfoBuffer.length; i ++){
            var fileUrl = programInfoBuffer[i].fileUrl;
            var lastIndexs = fileUrl.indexOf("?");
            var fileNames = fileUrl.substring(lastIndexs - 18,lastIndexs);

            if(fileNames == fileName){
                return programInfoBuffer[i].fileName;
            }
        }

    }

    function resetCourwareView(currentIndex)
    {
        var id = handoutModel.get(currentIndex).value;
        var planType = handoutModel.get(currentIndex).planType;
        var handountName = handoutModel.get(currentIndex).planName
        console.log("resetCourwareView(currentIndex)" ,currentIndex,id,planType);

        if(id == -1){
            return;
        }

        //点击"查看课件"的菜单以后, 马上隐藏掉"查看课件"的菜单(即: 在显示课件的图片之前, 因为弱网环境下, 显示课件图片较慢, 不隐藏的话, "查看课件"的菜单, 还可以拖动, 郭意宽提出的优化)
        mainWindowTop.changeCurrentTitle(handoutCombox.textAt(currentIndex));

        if(planType == 1){//新讲义
            isHomework = 1;
            //lessonCombobox.visible = false;
            if(disibleOss == false){
                trailBoardBackground.updateCourseOssSignStatus(true);
            }
            cloudClassMgr.getIdByColumnInfo(courseNameId,id,planType,handountName);// //"813552" //courseNameId
        }

        if(planType == 2 || planType == 100){//旧课件、非结构化讲义
            isHomework = 2;
            if(disibleOss == false){
                trailBoardBackground.updateCourseOssSignStatus(false);
            }
            cloudClassMgr.getCoursewareList(id);
            //networkMgr.sendCoursewareNameInfor(handountName);
            //return;
            //lessonCombobox.visible = true;
            //  console.log("========isHomework=========",planType,isHomework)
        }

        isfirstShow = false;
        if(planType == 3){//视频

        }
    }

    function resetAudioVideoPlayer( mediaType,lessonIdName )
    {
        var videoUrl = "";//networkMgr.getVideoFileUrlName(lessonIdName)
        for(var i = 0; i < audioModel.count; i++)
        {
            if( audioModel.get(i).key == lessonIdName)
            {
                videoUrl = audioModel.get(i).fileUrl;
                break;
            }

        }


        //console.log("====videoUrl====",mediaType,videoUrl);
        if(mediaType == 2){
            sigPlayerAudio(videoUrl,lessonIdName)
        }
        if(mediaType == 3){
            var videoPath = videoUrl;//"file:///C:/Users/Administrator/Downloads/20171128124011.mp4";//
            sigPlayerVideo(videoPath,lessonIdName);
        }
    }


}

