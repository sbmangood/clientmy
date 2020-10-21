import QtQuick 2.3
import QtQuick.Window 2.0
import YMAccountManagerAdapter 1.1
import YMHomeWorkManagerAdapter 1.0
import "Configuration.js" as Cfg
import QtQml 2.2
import QtGraphicalEffects 1.0
import PingThreadManagerAdapter 1.0
import LessonEvalution 1.0
import UploadFileManager 1.0
import YMLessonManagerAdapter 1.0
Window {
    id: windowView
    visible: false
    width: Screen.width * 0.8;
    height: Screen.width * 0.65;
    title: topTitle;
    color: "transparent"
    //缩放参数
    property double widthRate: Screen.width * 0.8 / 966.0;
    property double heightRate: widthRate / 1.5337;
    //屏幕比例
    property double widthRates: Screen.width / 1440.0;
    property double heightRates: Screen.height / 900.0;

    property bool enterClassRoom: true;//进入教室标记，只能进一次
    property bool exitRequest: false;//退出重新登录刷新数据
    property string topTitle: qsTr("教师端V1.0.7");
    property string userId: "";
    property string currentClassroomId: "";
    property string userName: "";
    property string password: "";
    property string realName: "";
    property string nameText: "";
    property var clickPos: [];//移动窗体坐标
    property bool windowClick: false;
    property bool loadingStatus: true;//登录时不显示加载状态属性

    property int interNetStatus: 0;    //网络状态：有线，无线
    property int interNetValue: 5; //网络ping值
    property int interNetGrade: 3;//网络好，差，无状态
    property int routingPing: 5;//路由ping值
    property int routingGrade: 3;//路由网络状态，好、差、无
    property int wifiDevice: 1;//wifi设备台数
    property int wifiGrade: 3;//wifi设备数优先级

    property int debugNetType: -1;
    property string debugStage: "";
    property var lessonCommentConfigInfo:[];
    property int lessonEvalutionStatus: 0;//0：隐藏， 1：显示
    property string curEvalutionLessonId: "";
    property string curEvalutionStudentName: "";
    property var currentLessonInfo: ;//当前课程信息

    flags: Qt.Window | Qt.FramelessWindowHint

    signal refreshPage();//刷新页面信号
    signal checkInterNetSuccess();//网络检测完成
    signal sigListenTips(var status);//CC/CR进入旁听提醒信号

    property string strStage: "api";//运行环境
    property string appKey: "a995732df99bc794";
    property string token:""

    YMHomeWorkManagerAdapter{
        id: homeWorkMgr
        onSigStageInfo: {
            debugNetType = netType;
            debugStage = stageInfo;
        }

        onSigMessageBoxInfo:
        {
            console.log("=======main.qml========");
            windowView.showMessageBox(strMsg);
        }
    }

    //内部测试使用的"网络环境设置"对话框
    YMInterNetSetting{
        id: interNetSetting
        z: 2222
        width: 280 * heightRate
        height: 400 * heightRate
        anchors.centerIn: parent
        visible: false
    }

    //连续左击5次版本号, 提示的密码框
    YMStageInputPasswordView{
        id: stagePwdView
        z: 666
        visible: false
        width: 280 * heightRate
        height: 160 * heightRate
        anchors.centerIn: parent
    }

    PingThreadManagerAdapter{
        id: pingMgr

        onSigCurrentInternetStatus: {
            interNetStatus = internetStatus;
            systemMenu.currentInternetStatus = internetStatus;
        }

        onSigCurrentNetworkStatus: {
            interNetValue = netValue;
            interNetGrade = netStatus;
            systemMenu.interNetValue = netStatus;
            systemMenu.pingValue = netValue == undefined ? 0 : netValue;
            systemMenu.netStatus = netStatus;
            systemMenu.updateNetworkImage();
        }

        //wifi连接的设备个数
        onSigWifiDeviceCount: {
            wifiDevice = count;
        }

        //当前路由的ping值与网络等级
        onSigCurrentRoutingValue: {
            routingPing = routingValue;
            routingGrade = netStatus;
            checkInterNetSuccess();
            console.log("=======routingValue========",routingValue,netStatus);
        }
    }

    YMAccountManagerAdapter{
        id: accountMgr
        onLoginSucceed: {
            token = message//获得token
            userName = loginView.userName.trim();
            password = loginView.password.trim();
            var savepwd = loginView.savePassword == true ? 1 : 0;
            var autologin = loginView.autoLogin == true ? 1 : 0;
            accountMgr.saveUserInfo(userName,password,savepwd,autologin);
            enterClassRoom = true;
            loadingStatus = false;
            navigation.setActiveView(0,0);
            loginView.tips = "";
            exitRequest = true;
            showMainWindow();

            lessonEvalution.getLessonEvalutionConfig("", "", "TEA", "");

        }
        onSigTokenFail:
        {
            navigation.clearModel = false;
            tipsControl.visible = false;
            exitRequest = false;
            loginView.loginConfram = true;
            loginView.clearPassword();
            showLoginWindow();
            loginView.tips = "登录已过期，请重新登录";
        }

        onLoginFailed: {
            loginView.tips = message;
            loginView.loginConfram = true;
            //loginView.password = "";
        }

        onTeacherInfoChanged:{
            realName = teacherInfo.realName;
            navigation.teacherName = teacherInfo.realName;
            navigation.headPicture = teacherInfo.headPicture;
            topTitle = "教师端V" + teacherInfo.appVersion
            userId = teacherInfo.userId;
            //console.log("=====userId====",userId);
            //console.log("=headPicture=",systemMenu.headPicture)

            nameText = teacherInfo.realName;
            if("" == nameText)
            {
                nameText = teacherInfo.mobileNo
            }
        }
        onSetDownValue:{
            softWareView.updateProgressBarValue(min,max)
            softWareView.visible = true;
        }

    }

    YMLessonManagerAdapter{
        id: lessonMgr
    }

    LessonEvalution{
        id: lessonEvalution

        onSigLessonEvalutionConfig: {
            lessonCommentConfigInfo = dataArray;
        }
    }

    Item{
        id:teaLessonEvaluationView
        anchors.fill: parent
        visible: lessonEvalutionStatus == 1 ? true :false
        z: 103
        Rectangle{
            color: "#000000"
            opacity: 0.7
            anchors.fill: parent
            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    return;
                }
            }
        }
        TeaLessonEvaluationView{
            visible: lessonEvalutionStatus == 1 ? true :false
            anchors.centerIn: parent
            aStudentName: curEvalutionStudentName
            //关闭窗体
            onConfirmClose: {
                lessonEvalutionStatus = 0;
            }
            //提交评价并退出
            onContinueExit: {
                lessonEvalutionStatus = 0;

                lessonEvalution.submitTeaLessonEvalution("", "", contentText1, contentText2, contentText3, contentText4, contentText5, userId, curEvalutionLessonId, "");

                navigation.getActiveView();
                refreshPage();

            }
        }

    }


    //控制整体背景色
    Rectangle{
        id: bgItem
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        //radius:  12 * widthRate
        color: "#F8F8F8"
    }


    YMTipNetworkView{
        id: tipInterView
        width: 200 * widthRate
        height: 160 * heightRate
    }



    YMSoftWareView{
        id: softWareView
        anchors.fill: parent
        visible: false
        onUpdateChanged: {
            if(updateStatus){
                accountMgr.updateFirmware = updateStatus;
            }else{
                showLoginWindow();
                loginView.userName = userInfo[0];
                loginView.password = userInfo[2] == 1 ? userInfo[1] : ""
                loginView.savePassword = userInfo[2] == 1 ? true : false
                loginView.autoLogin = userInfo[3] == 1 ? true : false
            }
        }

        onClosed: {
           accountMgr.doUplaodLogFile();
            windowView.close();
            Qt.quit();
        }
    }

    YMLoginView {
        id: loginView
        visible: false
        anchors.fill: parent
        window: windowView
        onClosed: {
            accountMgr.doUplaodLogFile();
            Qt.quit();
        }
        onLoginMined: {
            windowView.visibility = Window.Minimized;
        }
    }

    YMProgressbarControl{
        id: progressbar
        visible: false
        anchors.fill: parent
    }

    YMMassgeTipsControl{
        id: massgeTips
        visible: false
    }

    YMJoinClassroomTipsView{
        id: joinClasstipsView
        z: 6
        anchors.fill: parent
        visible: false
        onSigConfirm: {
            sigListenTips(status);
        }
    }
    YMCCHasInRoomTipView
    {
        id: ccHasInRoomView
        z: 6
        anchors.fill: parent
        visible: false
    }
    Item{
        id: mainView
        anchors.fill: parent

        MouseArea{
            width: parent.width
            height: Cfg.TB_HEIGHT
            Rectangle{
                anchors.fill: parent
                color: "white"

                Image {
                    width: 92
                    height: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/logo@2x.png"

                }
            }

            YMSystemMenuBar{
                id: systemMenu
                anchors.right: parent.right
                anchors.rightMargin: 10 * widthRates
                anchors.verticalCenter: parent.verticalCenter
                window: windowView
                onClosed: {
                    tipsControl.exitSystem = true;
                    tipsControl.visible = true;
                }
                onRefreshData: {
                    navigation.getActiveView();
                    refreshPage();
                }
            }

            onDoubleClicked: {
                windowClick = true;
                if(windowView.visibility == Window.Maximized){
                    windowView.visibility = Window.Windowed;
                }else if (windowView.visibility === Window.Windowed){
                    windowView.visibility = Window.Maximized;
                }
            }

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

        YMNavigationView{
            id:navigation
            anchors.fill: parent
            onShowCloseOrderView:
            {
                closeWorkOrderView.visible = true;
                closeWorkOrderView.showCloseWorkOrderView(id);
            }
        }
    }

    YMExitControl{
        id: exitButton
        visible: false
        onExitConfirm: {
            tipsControl.visible = true;
        }
        onShowDeviceTestWidget:
        {
            deviceSettingView.visible = true;
        }
        onShowWorkOrderView:
        {
            navigation.showWorkOrderView();
        }
    }

    YMLessonDescribe{
        id: lessonDescribe
        visible: false
        anchors.fill: parent
    }

    YMLessonInfo{
        id: lessonControl
        visible: false
        onLessonRefreshData: {
            enterClassRoom = true;
            navigation.getActiveView();
        }
    }

    YMLiveLessonView{
        id: liveLessonView
        visible: false
    }

    YMExitTipsControl{
        id: tipsControl
        tips: "确认退出吗？"
        visible: false
        anchors.fill: parent
        onCancelConfirm: {
            tipsControl.visible = false;
        }

        onAppExited: {
            accountMgr.doUplaodLogFile();
            Qt.quit();
        }

        onConfirmed: {
            navigation.clearModel = false;
            tipsControl.visible = false;
            exitRequest = false;
            loginView.loginConfram = true;
            loginView.clearPassword();
            showLoginWindow();

        }
    }


    YMMessageBox{
        id: messagebox
        visible: false
        anchors.fill: parent

        onConfirmed: {
            console.log("YMMessageBox onConfirmed");
            messagebox.visible = false;
        }
    }

    YMClassIntoView{
        id: classView
        anchors.fill: parent
        visible: false
    }

    YMDevicetesting{
        id: deviceSettingView
        z: 33
        anchors.fill: parent
        visible: false
    }

    YMCloseWorkOrderView
    {
        id:closeWorkOrderView
        visible: false
        onCloseWorkerOrderSuccess:
        {
            navigation.reSetWorkOrderView();
        }
    }
    YMCreatWorkOrderView
    {
        id:creatWorkOrderView
        visible: false
        onCreatWorkOrderFinished:
        {
            navigation.reSetWorkOrderView();
        }
    }
    YMReCommitWorkOrderView
    {
        id: reCommitWorkOrderView
        visible: false
        onReNewWorkOrdrDetailView:
        {
            navigation.resetWorkOrderDetail(isCommitSuccess);
        }
    }

    YMShowWorkOrderImageView
    {
        id:showWorkOrderImageView
        visible: false
    }

    // 云盘
    YMCloudDiskMainView {
        id: diskMainView
        width: 510 * widthRate
        height: Screen.width < 1920 ?  495 * heightRate : 420 * heightRate
        anchors.centerIn: parent
        isBigScreen: Screen.width < 1920 ?  false : true
        visible: false
        z: 95

        //当前被选择的 课件ImgList 和fileId  var ImgUrlList, var fileId
        onSigCurrentBeOpenedCoursewareUrl:{

        }
        //当前被选择的音频的Url 及id   audioUrl  fileI
        onSigCurrentBePlayedAudioUrl:{
            console.log("==audioUrl==",audioUrl);

        }
        //当前被选择的视频的Url 及id  videoUrl  fileId
        onSigCurrentBePlayedVideoUrl:{

        }

        // 当前被选择的图片url id name
        onSigCurrentBeOpendImageUrl: {

        }
        // 确定选择文件上传
        onSigAccept: {
            var lessonId = currentClassroomId;
            var userId = windowView.userId;
            var token = appKey;
            var enType = strStage;
            if(strStage == ""){
               enType = "";
            } else{
               enType+="-";
            }
            console.log("====selectd file is", fileUrl,lessonId,windowView.userId,appKey,strStage);
            var fileSize= lessonMgr.getFileSize(fileUrl);
            var index1 = fileUrl.lastIndexOf("/");
            var index2 = fileUrl.lastIndexOf(".");
            var suffix = fileUrl.substring(index2 + 1, fileUrl.length);
            var suffix_lower = suffix.toLowerCase();
            if(suffix_lower.indexOf("mp3") != -1 ){
                if(fileSize > (6*1024*1024)){
                    setTips("MP3大小不得超过5M～");
                    return;
                }
              }
            if( suffix_lower.indexOf("mp4") != -1){
                if(fileSize>(51*1024*1024)){
                    setTips("MP4大小不得超过50M～");
                    return;
                }
            }

            var fileName = fileUrl.substring(index1 + 1, index2);
            var upFileMark = new Date().getTime().toString();

            diskMainView.addUpLoadingFile(fileName, suffix, 0, upFileMark);

            uploadFileManager.upLoadFileToServer(upFileMark, fileUrl, lessonId, userId, token, enType);
        }
        // 取消选择文件上传
        onSigReject: {
            console.log("====canceled select file");
        }

        // 删除文件
        onSigDelFile: {
            delDialogItem.visible = true;
        }
    }

    //文件支持类型
    YMFileInfo{
       id:fileInfo
       width: Screen.width < 1920 ? 241 * widthRate : 282 * widthRate
       height: Screen.width < 1920 ? 400 * heightRate :362 * heightRate
       isBigScreen: Screen.width < 1920 ? false : true
       anchors.left:  diskMainView.left
       anchors.leftMargin: Screen.width < 1920 ? 270 * widthRate :265 * widthRate
       anchors.top:  diskMainView.top
       anchors.topMargin: Screen.width < 1920 ? 40 *heightRate: 30 * heightRate
       z:999
       visible: false

    }
    // 文件上传
    UploadFileManager {
        id: uploadFileManager
        // 上传成功信号
        onSigUploadSuccess: {
            console.log("========upload success, fileUrl=", fileUrl, fileSize,upFileMark);
            var roomId = currentClassroomId;
            var userId = windowView.userId;
            var apiUrl = "";
            var appId = "";

            //setTips("文件上传成功");
            diskMainView.upLoadCourseware(upFileMark, roomId, userId, fileUrl, fileSize, apiUrl, appId);
        }
        // 上传失败信号
        onSigUploadFailed: {
            isH5UploadImage = false;
            if(isUploadImage){
                imgTipsView.showUploadView(1);
            }else{
                setTips("文件上传失败");
            }
        }

        onSigUploadProgress: {
            for(var i = 0; i < fileModel.count;i++){
                if(fileModel.get(i).fileUrl == fileUrl){
                    imgTipsView.setProgress(parseInt(transferedPercent));
                    if(transferedPercent == 100){
                        fileModel.remove(i);
                    }
                    break;
                }
            }
            //console.log("========onSigUploadProgress======",fileUrl,transferedPercent)
        }
    }

    ListModel{
        id: fileModel
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
        anchors.centerIn: parent
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
    // 设置提示
    function setTips(tipsText){
        tipsTime.restart();
        ymtip.visible = true;
        tipText.text = tipsText
    }


    // 云盘课件删除提示框
    YMDelDialogView {
        id: delDialogItem
        z: 100
        width: 420 * widthRate
        height: 188 * heightRate
        anchors.centerIn: parent
        visible: false
        // 确认信号
        onSigDelConfirm: {
            delDialogItem.visible = false;
            var fileIdList = diskMainView.getDeletingFileList();
            var lessonId = currentClassroomId;
            var apiUrl = "";
            var appId = "";
            for(var i = 0; i < fileIdList.length; i++){
                diskMainView.deleteCourseware(fileIdList[i], lessonId, apiUrl, appId);
            }
        }
        // 取消信号
        onSigDelCancel: {
            delDialogItem.visible = false;
            diskMainView.clearDeletingFileList();
        }
    }

    Component.onCompleted: {
        windowView.visible = true
        var isUpdate = versionInfo;
        topTitle = "教师端V" + versionSoftWare;
        strStage = accountMgr.getCurrentStage();
        if(strStage == "api")
        {
            strStage = "";
        }
        softWareView.title = topTitle
        softWareView.isUpdate = versionValue == 0 ? false : true;
        //console.log("softWareView.isUpdate",softWareView.isUpdate,versionValue)
        addNavigation();
        if(isUpdate){
            showUpdateSoftWare();
            return;
        }else{
            showLoginWindow();

            //如果userInfo是空的话, 从 userInfo[0] 取值, qml会抱错
            if(userInfo[0] == undefined || userInfo == null)
            {
                return;
            }
            loginView.userName = userInfo[0];
            loginView.password = userInfo[2] == 1 ? userInfo[1] : ""
            loginView.savePassword = userInfo[2] == 1 ? true : false
            loginView.autoLogin = userInfo[3] == 1 ? true : false
        }
    }

    function showMessageBox(strMsg){
        messagebox.tips = strMsg;
        classView.visible = false;  //隐藏"正在进入教室中..."的窗口
        messagebox.visible = true;  //显示: 服务器返回错误信息的窗口
    }

    function showUpdateSoftWare(){
        softWareView.visible = true;
        windowView.width = 430 * widthRate;
        windowView.height = 440 * heightRate;
        windowView.setX((Screen.width - windowView.width) * 0.5);
        windowView.setY((Screen.height - windowView.height) * 0.5);
        mainView.visible = false;
    }

    function showLoginWindow(){
        softWareView.visible = false;
        loginView.visible = true;
        if(loginView.autoLogin && loginView.savePassword ){
          loginView.startTimer();
        }
        loginView.startLoginAnimation();
        windowView.width = Screen.width /1366 * 847;
        windowView.height = Screen.width / 1366 * 464;
        windowView.setX((Screen.width - windowView.width)* 0.5);
        windowView.setY((Screen.height - windowView.height) * 0.5);
        mainView.visible = false;

    }

    function showMainWindow(){
        loginView.visible = false;
        softWareView.visible = false;
        windowView.width = 1000 * widthRate * 0.9;
        windowView.height = 1000 * widthRate / 1.515 * 0.9;
        windowView.setX((Screen.width - windowView.width) * 0.5);
        windowView.setY((Screen.height - windowView.height) * 0.5);
        mainView.visible = true;
    }

    function addNavigation(){
        navigation.clearModel = true;
        navigation.addView("课程表",
                           ":/../JRMainView/YMMiniMainView.qml",
                           "qrc:/images/btn_kechengbiao@2x.png",
                           "qrc:/images/btn_kechengbiao_sed@2x.png");
        navigation.addView("课程列表",
                           "qrc:/ymlesson/lessonListTable/YMLessonListTable.qml",
                           "qrc:/images/btn_allcourse@3x.png",
                           "qrc:/images/btn_allcourse_sed@3x.png");
        navigation.addView("溢米教研",
                           "qrc:/ymresearch/YMResearchView.qml",
                           "qrc:/images/th_btn_yimijiaoyan@2x.png",
                           "qrc:/images/th_btn_yimijiaoyan_sed@2x.png")
        navigation.addView("小组课",
                           ":/../YMMiniHomePage/YMMiniMainView.qml",
                           "qrc:/images/btn_allcourse@3x.png",
                           "qrc:/images/btn_allcourse_sed@3x.png");

    }

    YMLessonReportView
    {
        id:lessonReport
        visible: false
        onReportFinished:{
            console.log("on...sigReportFinished")
            lessonReport.visible = false
            navigation.getActiveView();
            refreshPage();
        }
    }
    function showReportView(lessonInfo,viewType)//显示试听课报告选择页
    {
        console.log("show..report..view")
        lessonReport.visible = true
        lessonReport.updateUserInfo(lessonInfo,viewType)
    }
}

