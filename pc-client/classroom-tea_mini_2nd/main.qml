import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import CurriculumData 1.0
import ExternalCallChanncel 1.0
import "./Configuuration.js" as Cfg
import PanDuWriteBoard 1.0
import YMMiniLessonManager 1.0
import YMQosApiMannager 1.0
import YMNetworkManagerAdapert 1.0

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
    property int planTypes: -1;//讲义类型
    property int isHomework: 2;//
    property int coursewareType: 1;//默认老课件
    property var lessonCommentConfigInfo: [];//课程评价配置信息
    property int h5CoursewarePageTotal: 0;//H5课件总页数
    //开始上课同步数据
    property bool isSynLesson: false;//同步完成
    property bool isBlanckPage: true;//当前是否是空白页
    property bool pointerIsClick: false;//教鞭是否被选中
    //视频播放缓存
    property var videoPlayerBuffer: [];
    property var audioPlayerBuffer: [];
    //屏幕比例
    property double widthRate: Screen.width * 0.8 / 966.0;
    property double heightRate:widthRate / 1.5337;

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;


    //边框阴影
    property int borderShapeLen : (rightWidthX - midWidth - midWidthX) > 10 ? 10 : (rightWidthX - midWidth - midWidthX)


    Component.onCompleted: {
        networkMgrAdapter.setNetIp(curriculumData.getCurrentIp());
        showLessonView.updateStartLessonTime();
    }

    //关闭窗体
    onClosing: {
        trailBoardBackground.disconnectSockets();
        externalCallChanncel.closeAlllWidget();
    }

    //手写板
    PanDuWriteBoard{
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

    //加载长图等待动画
    MouseArea{
        id: loadingAnimate
        anchors.fill: parent
        visible: false
        z: 6666
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle{
            color: "#c0c0c0"
            opacity: 0.6
            anchors.fill: parent
        }

        AnimatedImage {
            id: animateImg
            width: 42 * heightRate
            height: 42 * heightRate
            source: "qrc:/images/loading.gif"
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.5 - width * 3
            anchors.verticalCenter: parent.verticalCenter
        }

        Text{
            id: loadingText
            anchors.left: animateImg.right
            anchors.leftMargin: 10 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 16 * heightRate
            font.family: Cfg.font_family
            color: "gray"
        }

        onVisibleChanged: {
            if(visible){
                bottomToolbars.disabledButton = false;
            }else{
                bottomToolbars.disabledButton = true;
            }
        }

        onClicked: {
            console.log("====check::noChange====");
        }
    }

    //课程详细信息页面
    TipMiniclassInfoView{
        id: tipminiClassView
        visible: false
        z: 666
    }

    //背景颜色
    Item{
        anchors.fill: parent

        Image{
            anchors.fill: parent
            fillMode: Image.Tile
            source: "qrc:/miniClassImage/backgrundImg.png"
        }

        //随机选人
        YMRandomSelectionView{
            id:randomSelectionView
            anchors.centerIn: parent
            z:17
            visible: false
            currentUserCanOperation:true
            //"type":1, // 1 开始动画，2 选择结果，3 关闭窗口
            onStartRandom:
            {
                qosApiMgr.clickSelection(curriculumData.getCurrentIp());
                trailBoardBackground.sendRandomSelectMsg(userId,1,curriculumData.getUserName(userId));
            }

            onCloseRandomView:
            {
                trailBoardBackground.sendRandomSelectMsg("",3,"");
            }

        }
        //抢答器
        YMResponderView{
            id:responderView
            anchors.centerIn: parent
            z:17
            visible: false
            //type // 1 发起抢答，2 学生抢答，3 抢答失败，4关闭抢答,byte
            onSigStartResponder:
            {
                qosApiMgr.clickResponder(curriculumData.getCurrentIp());
                trailBoardBackground.sendResponderMsg(runTimes,1);
            }

            onSigCloseResponderView:
            {
                trailBoardBackground.sendResponderMsg(0,4);
            }
        }
        //计时倒计时
        YMTimerView{
            id:timerView
            x:(parent.width - width) *0.5
            y:(parent.height - height)*0.5
            z:92
            visible: false
            //开始计时器
            onSigStartAddTimer:{
                qosApiMgr.clickTimer(curriculumData.getCurrentIp());
                trailBoardBackground.sendTimerMsg(1,1,currentTime);
            }
            //停止计时器
            onSigStopAddTimer:
            {
                trailBoardBackground.sendTimerMsg(1,2,currentTime);
            }
            //重置计时器
            onSigResetAddTimer:
            {
                trailBoardBackground.sendTimerMsg(1,3,0);
            }

            //开始倒计时
            onSigStartCountDownTimer:
            {
                trailBoardBackground.sendTimerMsg(2,1,currentTime);
                qosApiMgr.clickCountdown(curriculumData.getCurrentIp());
            }

            //停止倒计时
            onSigStopCountDownTimer:
            {
                trailBoardBackground.sendTimerMsg(2,2,currentTime);
            }

            //重置倒计时
            onSigResetCountDownTimer:
            {
                trailBoardBackground.sendTimerMsg(2,3,0);
            }

            onSigCloseTimerView:
            {
                trailBoardBackground.sendTimerMsg(currentViewType,4,currentTime);
            }

        }

        //打开课件开始上课
        YMTipOpenCoursewareView{
            id: openCoursewareView
            anchors.fill: parent
            visible: false
            z: 222
            onSigRefuse: {
                openCoursewareView.visible = false;
            }

            onSigOk: {
                isStartLesson = true;
                showLessonView.visible = false;
                trailBoardBackground.setStartClassRoom();
                openCoursewareView.visible = false;
                diskMainView.selecteCourseware(suffix,fileId);
            }
        }

        //云盘
        YMCloudDiskMainView{
            id: diskMainView
            anchors.right: parent.right
            anchors.rightMargin: 42 * heightRate
            anchors.top: parent.top
            anchors.topMargin: (parent.height - toolbarsView.height) * 0.5 - 16 * heightRate
            visible: false
            z:16
            onVisibleChanged:
            {
                if(!visible)
                {
                    toolbarsView.setSelectPointer();
                }
            }

            //当前被选择的 课件ImgList 和fileId  var ImgUrlList, var fileId
            onSigCurrentBeOpenedCoursewareUrl:
            {
                trailBoardBackground.insertCourseWare(imgUrlList,fileId,h5Url,coursewareType);
            }
            //当前被选择的音频的Url 及id   audioUrl  fileI
            onSigCurrentBePlayedAudioUrl:
            {
                console.log("==audioUrl==",audioUrl)
                mediaPlayer.visible = false;
                var audioPath = trailBoardBackground.downLoadMedia(audioUrl);
                if(audioPath == ""){
                    return;
                }
                audioPlayer.ymAudioPlayerManagerPlayFileByUrl("file:///" + audioPath,fileName,0,audioUrl,fileId);//"file:///" + audioPath

            }
            //当前被选择的视频的Url 及id  videoUrl  fileId
            onSigCurrentBePlayedVideoUrl:
            {
                console.log("===videoUrl==",videoUrl)
                audioPlayer.visible = false;
                var videoPath = trailBoardBackground.downLoadMedia(videoUrl);
                if(videoPath == ""){
                    return;
                }
                mediaPlayer.ymVideoPlayerManagerPlayFielByFileUrl("file:///" + videoPath ,fileName,0,fileId,videoUrl);//videoUrl
            }
        }

        //消息提示框
        Rectangle{
            id:toopBracund
            color: "#3C3C3E"
            opacity: 0.6
            width: 480 * heightRate
            height: 40 * heightRate
            z:  20
            anchors.left: trailBoardBackground.left
            anchors.bottom: trailBoardBackground.bottom
            anchors.leftMargin:  (trailBoardBackground.width - width) * 0.5  //2 - 150 * trailBoardBackground.widthRates
            anchors.bottomMargin: 100 * heightRate
            visible: false
            radius: 5 * heightRate
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
                anchors.leftMargin: 20 * heightRate
                anchors.topMargin:   20 * heightRate  - 10 * trailBoardBackground.ratesRates
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

        //画布
        TrailBoardBackground{
            id:trailBoardBackground
            width: midWidth
            height:  midHeight
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            visible: isHomework == 3 || isHomework == 2  ? true : false

            //切换为原来的通道
            onSigGetbackAisles:
            {
                externalCallChanncel.changeChanncel();
            }

            onSigInterNetworks: {
                videoToolBackground.networkStatus = networkStatus;
            }

            onSigGetCoursewareFaills: {
                showMessageTips("讲义暂未生成,请您稍后再选择该讲义!");
                videoToolBackground.getCoursewareInfo();
            }

            //显示空白页
            onSigDisplayerBlankPage:{
                isDisplayerAnswerCorrec = false;//设置不显示批改答案解析
                showQuestionHandlerView.displayerBlankPage();
                compositeTopicView.baseImages = "";
                compositeTopicView.visible = false;
                isBlanckPage = true;
                if(mainView.planTypes == -1 || mainView.planTypes == 2 || mainView.planTypes == 100){
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

            onSigUserName: {
                videoToolBackground.bUserId = userId;
                popupWidget.setUserName(userName)
                //console.log("onSigUserName>>",userId,userName)
            }

            onSigPromptInterfaceHandl: {
                console.log("=====onSigPromptInterfaceHandl======",inforces)
                if(inforces == "autoConnectionNetwork"){
                    popupWidget.setPopupWidget(inforces);
                    return;
                }

                //自动切换ip
                if(inforces == "showAutoChangeIpview" || inforces == "autoChangeIpSuccess" || inforces == "autoChangeIpFail" ){
                    popupWidget.setPopupWidget(inforces);
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

                //申请进入教室
                if(inforces == "4" || inforces =="5"){
                    //4继续上课
                    //3、5开始上课
                    showLessonView.isStartLesson = (inforces == 4 ? true : false);
                    showLessonView.visible = inforces == "4" ? false : true;
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

                //上过课
                if(inforces == "22") {
                    isSynLesson = true;
                    bottomToolbars.whetherAllowedClick = true;
                    return;
                }
                //断开不再重连
                if(inforces == "88"){
                    popupWidget.setPopupWidget(inforces)
                    return;
                }
            }
        }

        //底部工具栏
        BottomToolbars{
            id:bottomToolbars
            width: midWidth//240 * widthRate
            height: 35  * widthRate
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: (parent.width + (leftMidWidth + 12.0 * leftMidWidth / 66) - (rightWidth + borderShapeLen) -width) * 0.5
            anchors.bottomMargin:  5  * heightRate

            //跳转页面
            onSigJumpPage: {
                console.log("=====onSigJumpPage====",pages)
                trailBoardBackground.gotoPage(1,pages,bottomToolbars.totalPage)
                trailBoardBackground.coursewareOperation(coursewareType,4,pages,0);
            }
            onSigPrePage: {
                trailBoardBackground.coursewareOperation(coursewareType,0,1,0);
                console.log("=====onSigPrePage=====");
            }

            onSigNext: {
                trailBoardBackground.coursewareOperation(coursewareType,1,1,0);
                console.log("=====onSigNext=====");
            }

            //添加分页
            onSigAddPage: {
                trailBoardBackground.gotoPage(2,bottomToolbars.currentPage,bottomToolbars.totalPage + 1)
                trailBoardBackground.coursewareOperation(coursewareType,2,bottomToolbars.currentPage,0);
            }
            //删除分页
            onSigRemoverPage: {
                trailBoardBackground.gotoPage(3,bottomToolbars.currentPage - 1,bottomToolbars.totalPage - 1)
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

        //上边视频工具栏
        VideoToolBackground{
            id:videoToolBackground
            width: mainView.width
            height: parent.height - trailBoardBackground.height - 10 * heightRate//180 * heightRate//rightWidth + borderShapeLen
            anchors.bottom: trailBoardBackground.top
            anchors.bottomMargin: 5 * heightRate
            onSigCloseWidget: {
                if(curriculumData.justTeacherOnline() ) {
                    popupWidget.setPopupWidget("close");
                }else {
                    trailBoardBackground.disconnectSockets();
                    externalCallChanncel.closeAlllWidget()
                }
            }

            //用户授权
            onSigSetUserAuth: {
                trailBoardBackground.setUserAuth(userId,authStatus);
            }
            //选择课件显示当前课件
            onSigSetLessonShow: {
                trailBoardBackground.setLessonShow(message);
            }

            //播放MP3
            onSigPlayerAudio: {
                mediaPlayer.visible = false;
                var audioPath = trailBoardBackground.downLoadMedia(audioSoucre);
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
        }

        //上课提醒小窗口
        YMStartLessonView{
            id: showLessonView
            anchors.right: parent.right
            anchors.rightMargin: 9 * heightRate
            anchors.bottom: toolbarsView.top
            anchors.bottomMargin: 20 * heightRate
            onSigStartLesson: {
                showLessonView.visible = false;
                qosApiMgr.clickClass(curriculumData.getCurrentIp());
                if(status){
                    popupWidget.setPopupWidget("4");
                }else{
                    popupWidget.setPopupWidget("5");
                }
            }
        }

        //伸展图标
        MouseArea{
            id: expandView
            width: 58 * heightRate
            height: 64 * heightRate
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: (parent.height - toolbarsView.height) * 0.5 +  toolbarsView.height - height
            hoverEnabled: true
            visible: false

            Image {
                anchors.fill: parent
                source: "qrc:/miniClassImage/extendback.png"
            }

            Image{
                width: 17 * heightRate
                height: 20 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: (parent.width - width) * 0.5 + 6 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_zhankai_sed.png" : "qrc:/miniClassImage/xb_icon_zhankai.png"
            }

            onClicked: {
                expandAnimation.start();
            }

            Text {
                text: qsTr("展开")
                color: "#666666"
                font.pixelSize: 12 * heightRate
                font.family: Cfg.DEFAULT_FONT
                visible: parent.containsMouse ? true : false
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: (parent.width - width) * 0.5 + 8 * heightRate
            }
        }

        //隐藏动画
        NumberAnimation {
            id: foldAnimation
            target: toolbarsView
            property: "x"
            from: mainView.width - toolbarsView.width
            to: mainView.width + toolbarsView.width
            duration: 500
            onStopped: {
                expandView.visible = true;
            }
        }

        //渐出动画
        NumberAnimation {
            id: expandAnimation
            target: toolbarsView
            property: "x"
            from: mainView.width + toolbarsView.width
            to: mainView.width - toolbarsView.width
            duration: 500
            onStopped: {
                expandView.visible = false;
            }
        }

        //进入教室提醒
        Image{
            id: joinClassTipsImg
            visible:  false
            width: 610 * heightRate
            height: 149 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 50 * heightRate
            anchors.top: parent.top
            anchors.topMargin: topMargins + 560 * heightRate
            source: "qrc:/miniClassImage/JoinClassTips.png"

            Text {
                id: joinClassText
                anchors.verticalCenter: parent.verticalCenter
                color: "#ffffff"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 28 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: 206 * heightRate
            }
        }

        //小班课工具栏
        YMMiniClassToolbarsView{
            id: toolbarsView
            x: parent.width - width
            y: (parent.height - height) * 0.5

            onSigSendFunctionKey: {
                brushWidget.focus = false;
                eraserWidget.focus = false;
                toolboxView.visible = false;
                diskMainView.visible = false;
                tipFeedview.visible = false;
                if(pointerIsClick){
                    pointerIsClick = false;
                    qosApiMgr.clickPointer(curriculumData.getCurrentIp(),false);
                }

                switch(keys)
                {
                case 0 ://鼠标样式
                    trailBoardBackground.setCursorShapeType(0);
                    trailBoardBackground.disableTrailboard();
                    break;
                case 1: //画笔
                    trailBoardBackground.enableTrailboard();
                    trailBoardBackground.setPenColors(brushWidget.penColor);
                    trailBoardBackground.changeBrushSizes(brushWidget.brushWidth);
                    brushWidget.focus = true;
                    brushWidget.setPenColor();
                    break;
                case 4:  //橡皮擦
                    trailBoardBackground.enableTrailboard();
                    trailBoardBackground.setEraserSize(eraserWidget.eraserSize);
                    trailBoardBackground.setCursorShapeType(2);
                    eraserWidget.focus = true;
                    break;
                case 5: //教鞭
                    trailBoardBackground.enableTrailboard();
                    pointerIsClick = true;
                    trailBoardBackground.setCursorShapeType(4);
                    qosApiMgr.clickPointer(curriculumData.getCurrentIp(),true);
                    break;
                case 6:   //云盘
                    diskMainView.visible = true;
                    break;
                case 7:
                    toolboxView.visible = true;
                    break;
                case 8: //花名册
                    rosterView.visible = true;
                    var rosterInfoData = curriculumData.getRosterInfo();
                    rosterView.addRosterData(rosterInfoData);
                    break;
                case 9: //伸缩
                    foldAnimation.running = true;
                    break;
                case 10: //问题反馈
                    tipFeedview.visible = true;
                    break;
                default:
                    break;
                }
            }
        }

        //花名册
        TipRosterView{
            id: rosterView
            anchors.centerIn: parent
            visible: false
        }

        //问题反馈页面
        TipFeedbackView{
            id: tipFeedview
            anchors.right: parent.right
            anchors.rightMargin: 54 * heightRate
            anchors.top:  parent.top
            anchors.topMargin:  (parent.height - toolbarsView.height) * 0.5 + 150 * heightRate
            visible: false
            onSigFeedbackInfo: {
                curriculumData.addFeedbackInfo(feedbackTest);
                console.log("==feedbackTest==",feedbackTest)
            }
        }

        //工具箱
        YMToolboxView{
            id: toolboxView
            anchors.right: parent.right
            anchors.rightMargin: 54 * heightRate
            anchors.top:  parent.top
            anchors.topMargin: topMargins + 560 * heightRate
            visible: false
            onSigSelectedIndex: {
                toolboxView.visible = false;
                switch(index)
                {
                case 0://计时器
                    if(responderView.visible){
                        trailBoardBackground.sendResponderMsg(0,4);
                    }
                    if(randomSelectionView.visible){
                        trailBoardBackground.sendRandomSelectMsg("",3,"");
                    }
                    responderView.visible = false;
                    randomSelectionView.visible = false;
                    timerView.visible = true;
                    break;
                case 1://随机选人
                    if(responderView.visible){
                        trailBoardBackground.sendResponderMsg(0,4);
                    }
                    if(timerView.visible){
                        trailBoardBackground.sendTimerMsg(1,4,timerView.addTimeCount);
                    }
                    responderView.visible = false;
                    timerView.visible = false;
                    //填充数据
                    var rosterInfoData = curriculumData.getRosterInfo();
                    randomSelectionView.resetRandomModel(rosterInfoData);
                    randomSelectionView.visible = true;
                    break;
                case 2://抢答器
                    if(randomSelectionView.visible){
                        trailBoardBackground.sendRandomSelectMsg("",3,"");
                    }
                    if(timerView.visible){
                        trailBoardBackground.sendTimerMsg(1,4,timerView.addTimeCount);
                    }
                    timerView.visible = false;
                    randomSelectionView.visible = false;
                    responderView.visible = true;
                    break;
                default:
                    break;
                }
            }
        }

        //画笔操作
        BrushWidget{
            id:brushWidget
            anchors.right: parent.right
            anchors.rightMargin: 50 * heightRate
            anchors.top:  parent.top
            anchors.topMargin: (parent.height - toolbarsView.height) * 0.5 + 10 * heightRate
            width: 200 * heightRate
            height: 220  * heightRate
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
            }
            onSendPenWidth: {
                trailBoardBackground.changeBrushSizes(penWidths);
            }

        }

        //橡皮
        EraserWidget{
            id:eraserWidget
            anchors.right: parent.right
            anchors.rightMargin: 50 * heightRate
            anchors.top:  parent.top
            anchors.topMargin: (parent.height - toolbarsView.height) * 0.5 + 60 * heightRate
            width: 200 * heightRate
            height: 212  * heightRate
            z: 10
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
                //                toobarWidget.handlEraserImageColor(types);
                trailBoardBackground.setEraserSize(eraserWidget.eraserSize);
            }

            onSigClearsCreeon: {
                if(types == 1){
                    popupWidget.setPopupWidget("12");
                }else{
                    trailBoardBackground.setClearCreeon(2,bottomToolbars.currentPage,bottomToolbars.totalPage);
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
                trailBoardBackground.setVideoStream(vaType,controlType,times,address,fileId);
            }
            onSigPlayerMedia:  {
                trailBoardBackground.setVideoStream(vaType,controlType,times,address,fileId);
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
                trailBoardBackground.setVideoStream(vaType,controlType,times,address,fileId);
            }
            onSigPlayerMedia:  {
                trailBoardBackground.setVideoStream(vaType,controlType,times,address,fileId);
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

            onSigCloseAllWidget: {
                trailBoardBackground.disconnectSockets();
                externalCallChanncel.closeAlllWidget()
            }

            //开始上课弹窗
            onStartLesson: {
                //先初始化线路
                //再发送进入教室命令
                isStartLesson = true;
                trailBoardBackground.setStartClassRoom();
            }

            //清屏、撤销操作
            onSigClearScreen: {
                trailBoardBackground.setClearCreeon(1,bottomToolbars.currentPage,bottomToolbars.totalPage);
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

            //结束课程退出获取时间信号
            onSigGetLessonTime: {
                console.log("======sigGetLessonTime=======")
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
            //结束课程
            onSigFinishClass: {
                isLessonAssess = true;
                trailBoardBackground.teaFinishClassroom();
            }
        }
    }

    CurriculumData{
        id:curriculumData
    }

    ExternalCallChanncel{
        id:externalCallChanncel
    }

    YMMiniLessonManager{
        id: miniMgr
        onSigCoursewareTotalPage: {
            h5CoursewarePageTotal = pageTotal;
        }
    }

    YMQosApiMannager{
        id: qosApiMgr
    }

    YMNetworkManagerAdapert{
        id: networkMgrAdapter
        onSigNetworkInfo: {
            console.log("==networkInfo==",netType,delay,lossRate,cpuRate)
            videoToolBackground.updateNetworkInfo(netType,delay,lossRate,cpuRate);
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

}

