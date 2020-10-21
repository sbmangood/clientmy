import QtQuick 2.5
import QtGraphicalEffects 1.0
import CurriculumData 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import VideoRender 1.0
import "./Configuration.js" as Cfg

Rectangle {
    id: audiovideoview
    color: "#00000000"

    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates
    property bool isBeautyOn: true;
    property int borderShapeLens: (rightWidthX - midWidth - midWidthX) > 10 ? 10 : (rightWidthX - midWidth - midWidthX)
    property string exitClassUserId: ""//学生退出教室Id
    property string bUserId: ""//学生Id
    property string courseNameId: "";
    property string courseNamea: "";
    property int serverClassTime: 0;
    property var currentUserId: 0;//当前选择操作学生的Id
    property var currentMute: 0;//当前是否禁音
    property string currentUp: "-1";//上下台
    property string currentUserAuth: "-1";//当前权限
    property string currentUserAudio: "-1";//当前音频状态
    property string currentUserVideo: "-1";//当前视频状态
    property bool  audioVideoHandl: false //按键操作
    signal sigOperationVideoOrAudio(string userId , string videos , string audios);  //打开关闭本地摄像头、麦克风
    signal sigOnOffVideoAudio(string videoType);//音频，音视频切换
    signal sigSetUserAuth(string userId,string authStatus);//用户授权信号
    signal sigPlayerVideo(var videoSoucre,var videoName);//播放视频源
    signal sigPlayerAudio(var audioSoucre,var audioName);//播放mp3信号

    signal sigSetUserAuths(var userId, string up, int trail, int audio, int video);

    signal sigUpdateAllMute(int muteStatus);// 全体禁言信号

    MouseArea {
        anchors.fill: parent
        z:1
        onClicked: {
            audiovideoview.focus = true;
        }
    }
    //背景
    Item {
        id:audiovideoviewColor
        width: parent.width - borderShapeLens
        height: parent.height
        z:2

        ListView {
            id:videoListView
            height: 130 * widthRates
            width: {
                if(listModel.count > 6){
                    return parent.width - 80 * heightRate;
                }
                else{
                    return listModel.count *  258 * heightRate
                }
            }
            delegate: listViewDelegate
            model: listModel
            clip: true
            orientation:ListView.Horizontal
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            boundsBehavior: ListView.StopAtBounds
        }

        ListModel {
            id:listModel
        }

        Component {
            id:listViewDelegate
            Item {
                width: 258 * heightRate
                height: 120 * widthRates

                Rectangle {
                    id:itemDelegateBackGround
                    width: 230 * heightRate
                    height: parent.height
                    anchors.left: parent.left
                    anchors.leftMargin: ((videoListView.width  - listModel.count * width - 28 * heightRate * listModel.count ) * 0.5) + 28 * heightRate * 0.5
                    radius: 6 * heightRate
                    color: "#ffffff"

                    //视频显示
                    VideoRender {
                        id: videoRender
                        width:  parent.width
                        height: 133 * widthRates
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        imageId: uid
                        z: 5
                        visible: false
                        Component.onCompleted:{
                            videoRender.enableBeauty(false);// 小组课默认关闭美颜
                        }
                    }
                    //学生信息与麦克风状态
                    MouseArea {
                        z: 6
                        width: parent.width
                        height: 30 * heightRate
                        hoverEnabled: true
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        cursorShape: Qt.PointingHandCursor
                        enabled: userOnline == "1" ? true : false

                        Image{
                            anchors.fill: parent
                            source: "qrc:/avimages/6pxbackgrundImg.png"
                        }

                        onClicked: {
                            currentUserId = userId;
                            currentMute = userMute;//禁音
                            currentUp = userUp;//上下台权限
                            currentUserAuth = userAuth;//当前权限
                            currentUserAudio = userAudio;//当前音频状态
                            currentUserVideo = userVideo;//当前视频状态

                            if(isteacher == 0){
                                studentPopup.open();
                                var locationX = ((audiovideoview.width - videoListView.width) * 0.5) + index  * itemDelegateBackGround.width + index * 28 * heightRate + 13 * heightRate;
                                studentPopup.x = locationX;
                                studentPopup.y = videoListView.y + 120 * widthRates;
                            }
                            else{
                                teaPopup.open();
                                teaPopup.x = ((audiovideoview.width - videoListView.width) * 0.5) + index  * itemDelegateBackGround.width + index * 28 * heightRate + 13 * heightRate;
                                teaPopup.y = videoListView.y + 120 * widthRates;
                            }
                        }

                        Image {
                            id: micPhoneImg
                            width: 27 * heightRate
                            height: 20 * heightRate
                            anchors.left: parent.left
                            anchors.leftMargin: 6 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                            source:  {
                                if(userAudio == "1"){
                                    if(volumes == "0"){
                                        return "qrc:/avimages/xb_yuyin1-1.png";
                                    }
                                    if(volumes == "1"){
                                        return "qrc:/avimages/xb_yuyin1-1.png"
                                    }
                                    if(volumes == "2"){
                                        return "qrc:/avimages/xb_yuyin1-2.png";
                                    }
                                    if(volumes == "3"){
                                        return "qrc:/avimages/xb_yuyin1-3.png";
                                    }
                                    if(volumes == "4"){
                                        return "qrc:/avimages/xb_yuyin1-4.png";
                                    }
                                    if(volumes == "5"){
                                        return "qrc:/avimages/xb_yuyin1-5.png";
                                    }
                                    if(volumes == "6"){
                                        return "qrc:/avimages/xb_yuyin1-5.png";
                                    }
                                }else{
                                    return "qrc:/avimages/xb_hmc_off.png"
                                }
                            }
                        }

                        Text {
                            text: userName
                            height: parent.height
                            anchors.left: micPhoneImg.right
                            anchors.leftMargin: 5 * heightRate
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 16 * heightRate
                            font.family: Cfg.DEFAULT_FONT
                        }

                        //老师图标
                        Image {
                            width: 26 * heightRate
                            height: 26 * heightRate
                            visible: isteacher == 1 ? true : false
                            source: "qrc:/avimages/xb_icon_laoshi.png"
                            anchors.right: parent.right
                            anchors.rightMargin: 10 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        /*
                        //学生奖杯
                        Image {
                            id: jiangliImg
                            width: 32 * heightRate
                            height: 24 * heightRate
                            visible: isteacher == 0 ? true : false
                            source: "qrc:/avimages/xb_hmc_jiangli.png"
                            anchors.right: jiangliText.left
                            anchors.rightMargin: 8 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            id: jiangliText
                            visible: isteacher == 0 ? true : false
                            text: prizeNumber
                            color: "#ffcc33"
                            font.pixelSize: 15 * heightRate
                            font.family: Cfg.DEFAULT_FONT
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right:  parent.right
                            anchors.rightMargin: 5 * heightRate
                        }
                        */

                    }
                    //操作背景
                    Image {
                        id: backImg
                        z: 5
                        width: parent.width
                        height: parent.height - 30 * heightRate
                        visible:  false
                        source: userOnline == "1" ?  (userUp == "0" ? "qrc:/avimages/xb_xianshi2.png" : (userVideo == "0"  ? "qrc:/avimages/xb_xianshi2.png"  :"qrc:/avimages/xb_xianshi1.png")) :  "qrc:/avimages/xb_xianshi1.png"
                    }

                    Rectangle {
                        id: maskView
                        anchors.fill: parent
                        radius: 6 * heightRate
                        visible: false
                    }

                    //背景椭圆遮罩层
                    OpacityMask{
                        anchors.fill: parent
                        visible: userOnline == "1" ? (userVideo == "0" ?  true : false) : true
                        source: backImg
                        maskSource: maskView
                    }
                    //视频展示遮罩层
                    OpacityMask {
                        anchors.fill: parent
                        visible: (userUp == "1" && userVideo == "1") ? (userOnline == "1"  ? true :  false ): false
                        source: videoRender
                        maskSource: maskView
                        cached: true
                    }
                }
            }
        }
    }

    //学生弹窗
    Popup {
        id: studentPopup
        z: 3
        visible: false
        width:  180 * heightRate - 32 * heightRate
        height: 42 * heightRate
        background:
            Rectangle {
            anchors.fill: parent
            border.width: 1
            border.color: "#dddddd"
            radius: 4 * heightRate
            color: "#ffffff"
        }
        Row {
            width: parent.width
            height: 24 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10 * heightRate
            //上下台
            MouseArea{
                width: 32 * heightRate
                height: 25 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: currentUp == "0" ? "qrc:/avimages/xbk_hmc_xiatai.png" : "qrc:/avimages/xbk_hmc_shangtai.png"
                }

                onClicked: {
                    var isCurrentUp  = "0";
                    if(currentUp == "0"){
                        isCurrentUp = "1";
                    }
                    updateUserAuthorize(currentUserId,isCurrentUp,currentUserAuth,currentUserAudio,currentUserVideo);
                }
            }

            //授权
            MouseArea {
                width: 32 * heightRate
                height: 24 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: currentUserAuth == "0" ? "qrc:/avimages/xb_hmc_weishouquan.png" : "qrc:/avimages/xb_hmc_shouquan.png"
                }

                onClicked: {
                    var isCurrentAuth  = "0";
                    if(currentUserAuth == "0"){
                        isCurrentAuth = "1";
                    }
                    updateUserAuthorize(currentUserId,currentUp,isCurrentAuth,currentUserAudio,currentUserVideo);
                }
            }

            //禁音
            MouseArea {
                width: 32 * heightRate
                height: 24 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: currentUserAudio == "0" ? "qrc:/avimages/xb_hmc_forbid.png" : "qrc:/avimages/xb_hmc_on.png"
                }

                onClicked: {
                    var isCurrentAudio  = "0";
                    if(currentUserAudio == "0"){
                        isCurrentAudio = "1";
                        //qosApiMgr.clickMute(currentUserId,curriculumData.getCurrentIp());
                    }
                    updateUserAuthorize(currentUserId,currentUp,currentUserAuth,isCurrentAudio,currentUserVideo);
                }
            }

            /*
            // 奖杯
            MouseArea{
                width: 32 * heightRate
                height: 24 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: "qrc:/avimages/xb_hmc_jiangli.png"
                }

                onClicked: {
                    studentPopup.close();
                    updateRewardNum(currentUserId);
                    //trailBoardBackground.sendTrophy(currentUserId);
                }
            }
            */
        }
    }

    //老师弹窗
    Popup {
        id: teaPopup
        z: 3
        visible: false
        width:  80 * heightRate
        height: 42 * heightRate
        background: Rectangle{
            anchors.fill: parent
            border.width: 1
            border.color: "#dddddd"
            radius: 4 * heightRate
            color: "#ffffff"
        }

        Row {
            width: parent.width
            height: 24 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10 * heightRate
            MouseArea {
                width: 20 * heightRate
                height: 20 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    anchors.fill: parent
                    source: "qrc:/avimages/xb_icon_shuxin_changtai.png"
                }
                onClicked: {

                }
            }
            //全体禁音
            MouseArea{
                width: 24 * heightRate
                height: 24 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Image{
                    anchors.fill: parent
                    source: currentMute == 0 ?  "qrc:/avimages/xb_icon_lbqg.png" : "qrc:/avimages/xb_icon_lbqk.png"
                }

                onClicked: {
                    var isMuteStatus = 0;
                    if(currentMute == 0){
                        isMuteStatus = 1;
                        //qosApiMgr.clickAullmute(curriculumData.getCurrentIp());
                    }
                    updateMute(isMuteStatus);
                }

            }

        }
    }


    Timer{
        id: joinclassTime
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            joinClassTipsImg.visible = false;
        }
    }

    CurriculumData {
        id:curriculumData
        /*
        onSigListAllUserId:{
            listModel.clear();
            for(var j = 0; j < list.length ; j++) {
                var dataObject = curriculumData.getUserInfo(list[j]);
                console.log("==curriculumData==",list[j],JSON.stringify(dataObject));

                var userId = list[j];
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
                var userMute = 1;//dataObject.mute;//
                var uid = dataObject.uid;
                var userUp = dataObject.userUp;
                var rewardNum = dataObject.rewardNum;
                console.log("==audiovideoview::data==",userName,userOnline,userAudio,userVideo,userUp,userAuth);
                listModel.append(
                            {
                                "uid": uid,
                                "makeIndex": j + 1,
                                "userId": userId,
                                "userMute": userMute,
                                "userUp": userUp,
                                "userName": userName,
                                "userOnline":userOnline,
                                "userAuth":userAuth,
                                "isVideo": isVideo,
                                "userAudio": userAudio,
                                "userVideo": userVideo,
                                "imagePath": imagePath,
                                "isteacher":isteacher,
                                "supplier": supplier,
                                "headPicture": headPicture,
                                "volumes":"0", //设置音量
                                "prizeNumber": rewardNum,
                            }
                            );
                break;
            }
        }
        */
    }

    // 添加自己的用户信息
    function addSelfBaseInfo(userId, dataObject){
        var j = 0;
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
        var userMute = 1;//dataObject.mute;//
        var uid = dataObject.uid;
        var userUp = dataObject.userUp;
        var rewardNum = dataObject.rewardNum;
        listModel.append(
                    {
                        "uid": uid,
                        "makeIndex": j + 1,
                        "userId": userId,
                        "userMute": userMute,
                        "userUp": userUp,
                        "userName": userName,
                        "userOnline":userOnline,
                        "userAuth":userAuth,
                        "isVideo": isVideo,
                        "userAudio": userAudio,
                        "userVideo": userVideo,
                        "imagePath": imagePath,
                        "isteacher":isteacher,
                        "supplier": supplier,
                        "headPicture": headPicture,
                        "volumes":"0", //设置音量
                        "prizeNumber": rewardNum,
                    }
                    );
    }

    // 增加其他用户信息
    function addUserInfo(userId){
        var isAdd = true;
        for(var i = 0; i < listModel.count; i++){
            if(listModel.get(i).userId == userId){
                isAdd = false;
                break;
            }
        }
        var isAttend = curriculumData.isAttend(userId);
        if(isAdd && isAttend){
            var dataObject = curriculumData.getUserInfo(userId);
            console.log("==addUserInfo==",userId,JSON.stringify(dataObject));
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
            var userMute = 1;//dataObject.mute;//
            var uid = dataObject.uid;
            var userUp = dataObject.userUp;
            var rewardNum = dataObject.rewardNum;
            console.log("=====addUserInfo====",userId,userOnline,isVideo,userUp,userAuth,userAudio,userVideo);
            listModel.append(
                        {
                            "uid": uid,
                            "makeIndex": listModel.count + 1,
                            "userId": userId,
                            "userMute": userMute,
                            "userUp": userUp,
                            "userName": userName,
                            "userOnline":userOnline,
                            "userAuth":userAuth,
                            "isVideo": isVideo,
                            "userAudio": userAudio,
                            "userVideo": userVideo,
                            "imagePath": imagePath,
                            "isteacher":isteacher,
                            "supplier": supplier,
                            "headPicture": headPicture,
                            "volumes":"0", //设置音量
                            "prizeNumber":rewardNum,
                        });
        }
    }


    /*
    // 操作视频
    ExternalCallChanncel {
        id: externalCallChanncel

        //麦克风显示音量操作
        onSigAudioVolumeIndication:{
            var uids = uid.toString();
            var totalVolumes = totalVolume.toString();
            for(var j = 0 ; j < listModel.count ;j++){
                if(listModel.get(j).userId == uids) {
                    listModel.get(j).volumes = totalVolumes;
                }
            }
        }


        // 学生进入教室消息提醒
        onSigJoinroom:{

            console.log("=====onSigJoinroom=======",uid,userId);
            addUserInfo(userId);
            updateIsVideo(uid,status);
            //学生退出加入教室更新花名册状态
            var rosterInfoData = curriculumData.getRosterInfo();
            rosterView.addRosterData(rosterInfoData);
            if(status == 1){
                joinclassTime.restart();
                joinClassTipsImg.visible = true;
                var userName = curriculumData.getUserName(userId);
            }
        }

    }
    */

    function updateIsVideo(uid,status){
        for(var j = 0 ; j < listModel.count ;j++){
            //console.log("======updateIsVideo======",listModel.get(j).userId)
            if(listModel.get(j).uid == uid) {
                listModel.get(j).userOnline = status.toString()
                listModel.get(j).isVideo = status.toString();
                break;
            }
        }
    }

    function updateRewardNum(userId){
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                var prizeNumber = listModel.get(i).prizeNumber;
                listModel.get(i).prizeNumber = (parseInt(prizeNumber) + 1).toString();
                break;
            }
        }
    }

    // 小班课授权函数 用户Id, 上台,
    function updateUserAuthorize(userId,up,trail,audio,video){
        currentUp = up;
        currentUserAuth = trail.toString();
        currentUserAudio = audio.toString();
        currentUserVideo = video.toString();
        //console.log("====userUP::videoaaaaa====",userId,up,video,trail);
        //如果是上台，根据历史记录开关音视频
        //第一次默认是上台并且音视频默认打开
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                listModel.get(i).userUp = up;
                listModel.get(i).userAuth = trail;
                listModel.get(i).isVideo = (up == "1" && video == "1") ? "1" : "0";
                listModel.get(i).userAudio = (up == "0" ? "0" : audio);
                listModel.get(i).userVideo = up;
                //console.log("====userUP::videobbbb====",userId,up,video,listModel.get(i).isVideo,listModel.get(i).userOnline);
                break;
            }
        }
        //视频参数是根据上下台进行展示视频还是关闭视频
        sigSetUserAuths(userId,parseInt(up),parseInt(trail),parseInt(audio),parseInt(up));
    }

    //同步小班课授权函数 用户Id, 上台,
    function sysnUserAuthorize(userId,up,trail,audio,video){
        currentUp = up;
        currentUserAuth = trail.toString();
        currentUserAudio = audio.toString();
        currentUserVideo = video.toString();
        //console.log("==sysnUserAuthorize::data==",userId,trail,listModel.count);
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                //console.log("==sysnUserAuthorize==",userId,trail);
                listModel.get(i).userUp = up.toString();
                listModel.get(i).userAuth = trail.toString();
                listModel.get(i).isVideo =  (up == "1" && video == "1") ? "1" : "0";
                listModel.get(i).userAudio = (up == 0 ? "0" : audio.toString()); //audio;//
                listModel.get(i).userVideo = (up == 0 ? "0" : video.toString());//video;//
                break;
            }
        }
    }

    //全体静音 muteStatus 0静音，1 恢复
    function updateMute(muteStatus){
        currentMute = muteStatus;
        currentUserAudio = muteStatus;
        //console.log("=====updateMute=======",muteStatus);
        for(var i  = 0; i < listModel.count; i ++){
            listModel.get(i).userMute = muteStatus;
            listModel.get(i).userAudio = muteStatus.toString();
            //console.log("====userAudiouserAudio=====",muteStatus)
        }
        sigUpdateAllMute(parseInt(muteStatus));
    }

    function updateOnlineStatus(uid,onlineStatus){
        for(var j = 0 ; j < listModel.count ;j++){
            console.log("======updateOnlineStatus======",uid,onlineStatus)
            if(listModel.get(j).uid == uid) {
                listModel.get(j).userOnline = onlineStatus;
            }
        }
    }

    //继续留在教室
    function setStayInclassroom() {
        audioVideoHandl = false;
        for(var j = 0 ; j < listModel.count ;j++) {
            var userId = listModel.get(j).userId;
            listModel.get(j).userAudio = "1"
            listModel.get(j).userVideo = "1";
            listModel.get(j).userAuth = "1";
            listModel.get(j).isVideo = "0";
            listModel.get(j).userOnline =curriculumData.justUserOnline(userId);
        }
        externalCallChanncel.setStayInclassroom();
    }

    //处理操作界面
    function handlPromptInterfaceHandl(inforces){
        if(inforces == "51") {
            //学生离开教室重置状态处理
            for(var j = 0 ; j < listModel.count ;j++){
                var userId = listModel.get(j).userId;
                if(userId == exitClassUserId){
                    listModel.get(j).userAudio = "1"
                    listModel.get(j).userVideo = "1";
                    listModel.get(j).userAuth = "1";
                    listModel.get(j).isVideo = "0";
                    listModel.setProperty(j,"userOnline",curriculumData.justUserOnline(userId));
                }
            }
            return;
        }
        //学生在线操作
        if(inforces == "b_Online"){
            for(var j = 0 ; j < listModel.count ;j++){
                var userId = listModel.get(j).userId;
                if(userId == bUserId){
                    var isVideo = curriculumData.getIsVideo();
                    var userAuth = curriculumData.getUserIdBrushPermissions(userId);
                    var userAudio = curriculumData.getUserPhone(userId);
                    var userVideo = curriculumData.getUserCamcera(userId);
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
        //console.log("setStartClassTimeData:: ==",times);
        audioVideoHandl = true;
        for(var j = 0 ; j < listModel.count ;j++){
            var userId = listModel.get(j).userId;
            var isVideo = curriculumData.getIsVideo();
            var supplier = curriculumData.getUserChanncel();
            var userVideo = curriculumData.getUserCamcera(userId);
            var userAudio = curriculumData.getUserPhone(userId);
            var userOnline = curriculumData.justUserOnline(userId)
            var userAuth = curriculumData.getUserIdBrushPermissions(userId);

            //console.log("startclass:isVideo",userId,isVideo, supplier,userVideo,userAudio,userOnline);

            listModel.setProperty(j,"isVideo",isVideo);
            listModel.setProperty(j,"supplier",supplier);
            listModel.setProperty(j,"userVideo",userVideo);
            listModel.setProperty(j,"userAudio",userAudio);
            listModel.setProperty(j,"userOnline",userOnline);
            listModel.setProperty(j,"userAuth",userAuth);
        }
    }

}

