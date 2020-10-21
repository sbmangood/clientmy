import QtQuick 2.5
import QtGraphicalEffects 1.0
import CurriculumData 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import VideoRender 1.0
import ExternalCallChanncel 1.0
import "./Configuuration.js" as Cfg

/*
  * 视频工具栏
  */

Rectangle {
    id:videoToolBackground

    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property bool isBeautyOn: true;

    //边框阴影
    property int borderShapeLens: (rightWidthX - midWidth - midWidthX) > 10 ? 10 : (rightWidthX - midWidth - midWidthX)
    color: "#00000000"
    property string courseNameId: "";
    property string courseNamea: "";
    property string startEndTime: "";//起止结束时间
    property int networkStatus: 3;
    property var currentUserId: 0;//当前选择操作学生的Id
    property var currentMute: 0;//当前是否禁音
    property string currentUp: "-1";//上下台
    property string currentUserAuth: "-1";//当前权限
    property string currentUserAudio: "-1";//当前音频状态
    property string currentUserVideo: "-1";//当前视频状态
    property string currentUserOnline: "-1";//当前用户在线状态

    //关闭界面
    signal sigCloseWidget();

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

    //设置开始上课
    function setStartClassTimeData(){
        externalCallChanncel.initVideoChancel();
        for(var j = 0 ; j < listModel.count ;j++){
            var userId = listModel.get(j).userId;
            var isVideo = curriculumData.getIsVideo();
            var supplier = curriculumData.getUserChanncel();
            var userVideo = curriculumData.getUserCamcera(userId);
            var userAudio = curriculumData.getUserPhone(userId);
            var userOnline = curriculumData.justUserOnline(userId)
            var userAuth = curriculumData.getUserIdBrushPermissions(userId);

            listModel.setProperty(j,"isVideo",isVideo);
            listModel.setProperty(j,"supplier",supplier);
            listModel.setProperty(j,"userVideo",userVideo);
            listModel.setProperty(j,"userAudio",userAudio);
            listModel.setProperty(j,"userOnline",userOnline);
            listModel.setProperty(j,"userAuth",userAuth);
        }
    }

    //背景463062
    Item{
        id:videoToolBackgroundColor
        width: parent.width - borderShapeLens
        height: parent.height
        z:2

        Text {
            id: courseNameText
            //width: 56 * widthRates
            height: 20  * heightRates
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 18 * widthRates
            anchors.topMargin:  3  * heightRate
            font.pixelSize: 18 * heightRate
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: courseNamea
        }

        MouseArea{
            width: 20 * heightRate
            height: 8  * heightRate
            anchors.left: courseNameText.right
            anchors.leftMargin: 10 * heightRate
            anchors.top: parent.top
            anchors.topMargin:  14  * heightRate
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: "qrc:/miniClassImage/shrinkImg.png"
            }

            onClicked: {
                tipminiClassView.lessonId = courseNameId;
                tipminiClassView.lessonName = courseNamea;
                tipminiClassView.lessonTea = listModel.get(0).userName;
                tipminiClassView.lessonTime = startEndTime;
                tipminiClassView.x = courseNameText.width;
                tipminiClassView.y = 24;
                tipminiClassView.open();
            }
        }

        //关闭按钮
        MouseArea{
            id: closeButton
            width: 15 * widthRate
            height: 15 * widthRate
            hoverEnabled: true
            anchors.top: parent.top
            anchors.topMargin: 4 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 9 * widthRate
            cursorShape: Qt.PointingHandCursor

            Rectangle{
                anchors.fill: parent
                color:   "#e0e0e0"//parent.containsMouse ? (parent.pressed ? "#676767" : "#eeeeee") :
            }

            Text {
                text: qsTr("×")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 18 * heightRate
                anchors.centerIn: parent
                color:  "#676767"
            }

            onClicked: {
                videoToolBackground.focus = true;
                if(isStartLesson == false){
                    loadingAnimate.visible = true;
                    loadingText.text = "正在退出教室,请稍候...."
                    trailBoardBackground.setExitProject();
                    return;
                }
                sigCloseWidget();
            }
        }
        //最小化按钮
        MouseArea{
            id: minButton
            width: 15 * widthRate
            height: 15 * widthRate
            hoverEnabled: true
            anchors.top: parent.top
            anchors.topMargin: 4 * heightRate
            anchors.right: closeButton.left
            anchors.rightMargin: 2 * heightRate
            cursorShape: Qt.PointingHandCursor

            Rectangle{
                anchors.fill: parent
                color:   "#e0e0e0" //parent.containsMouse ? (parent.pressed ? "#676767" : "#eeeeee") :
            }

            Text {
                text: qsTr("－")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 18 * heightRate
                anchors.centerIn: parent
                color: "#676767"
            }

            onClicked: {
                sigMinFrom();
            }
        }

        //网络状态与设备状态
        YMNetworkControlView{
            id: networkControlView
            anchors.top: parent.top
            anchors.topMargin: 3 * heightRate
            anchors.right: minButton.left
            anchors.rightMargin: 40 * heightRate
        }

        ListView{
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

        ListModel{
            id:listModel
        }

        Component{
            id:listViewDelegate
            Item{
                width: 258 * heightRate
                height: 120 * widthRates

                Rectangle{
                    id:itemDelegateBackGround
                    width: 230 * heightRate
                    height: parent.height
                    anchors.left: parent.left
                    anchors.leftMargin: ((videoListView.width  - listModel.count * width - 28 * heightRate * listModel.count ) * 0.5) + 28 * heightRate * 0.5
                    radius: 6 * heightRate
                    color: "#ffffff"

                    //视频显示
                    VideoRender{
                        id:videoRender
                        width:  parent.width
                        height: 133 * widthRates
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        imageId: uid
                        z: 5
                        visible: false//(userUp == "1" && userVideo == "1") ? (userOnline == "1"  ? true :  false ): false

                        Component.onCompleted:{
                            isBeautyOn = videoRender.getBeautyIsOn();
                            console.log("Component.onCompleted:",isBeautyOn,uid,imageId,videoRender.width,videoRender.height)
                        }
                    }

                    //学生信息与麦克风状态
                    MouseArea{
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
                            source: "qrc:/miniClassImage/6pxbackgrundImg.png"
                        }

                        onClicked: {
                            currentUserId = userId;
                            currentMute = userMute;//禁音
                            currentUp = userUp;//上下台权限
                            currentUserAuth = userAuth;//当前权限
                            currentUserAudio = userAudio;//当前音频状态
                            currentUserVideo = userVideo;//当前视频状态
                            currentUserOnline = userOnline;
                            console.log("====header::Click=====",currentUserId,userUp,userAuth,userAudio,userVideo,userOnline)
                            if(isteacher == 0){
                                studentPopup.open();
                                var locationX = ((videoToolBackground.width - videoListView.width) * 0.5) + index  * itemDelegateBackGround.width + index * 28 * heightRate + 13 * heightRate;
                                console.log("=====locationX=====",locationX,index,videoToolBackground.width,videoListView.width,videoToolBackground.width - videoListView.width);
                                studentPopup.x = locationX;
                                studentPopup.y = videoListView.y + 120 * widthRates;
                            }else{
                                teaPopup.open();
                                teaPopup.x = ((videoToolBackground.width - videoListView.width) * 0.5) + index  * itemDelegateBackGround.width + index * 28 * heightRate + 13 * heightRate;
                                teaPopup.y = videoListView.y + 120 * widthRates;
                            }
                        }

                        Image{
                            id: micPhoneImg
                            width: 27 * heightRate
                            height: 20 * heightRate
                            anchors.left: parent.left
                            anchors.leftMargin: 6 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                            source:  {
                                if(userUp == "1"&& userAudio == "1"){
                                    if(volumes == "0"){
                                        return "qrc:/miniClassImage/xb_yuyin1-1.png";
                                    }
                                    if(volumes == "1"){
                                        return "qrc:/miniClassImage/xb_yuyin1-1.png"
                                    }
                                    if(volumes == "2"){
                                        return "qrc:/miniClassImage/xb_yuyin1-2.png";
                                    }
                                    if(volumes == "3"){
                                        return "qrc:/miniClassImage/xb_yuyin1-3.png";
                                    }
                                    if(volumes == "4"){
                                        return "qrc:/miniClassImage/xb_yuyin1-4.png";
                                    }
                                    if(volumes == "5"){
                                        return "qrc:/miniClassImage/xb_yuyin1-5.png";
                                    }
                                    if(volumes == "6"){
                                        return "qrc:/miniClassImage/xb_yuyin1-5.png";
                                    }
                                }else{
                                    if(isteacher == 1)
                                    {
                                        return "qrc:/miniClassImage/xb_hmc_on.png";
                                    }
                                    return "qrc:/miniClassImage/xb_hmc_off.png"
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
                        Image{
                            width: 26 * heightRate
                            height: 26 * heightRate
                            visible: isteacher == 1 ? true : false
                            source: "qrc:/miniClassImage/xb_icon_laoshi.png"
                            anchors.right: parent.right
                            anchors.rightMargin: 10 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        //学生奖杯
                        Image{
                            id: jiangliImg
                            width: 32 * heightRate
                            height: 24 * heightRate
                            visible: isteacher == 0 ? true : false
                            source: "qrc:/miniClassImage/xb_hmc_jiangli.png"
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

                    }
                    //操作背景
                    Image{
                        id: backImg
                        z: 5
                        width: parent.width
                        height: parent.height - 30 * heightRate
                        visible:  false//userOnline == "1" ? (userVideo == "0" ?  true : false) : true
                        source: userOnline == "1" ?  (userUp == "0" ? "qrc:/miniClassImage/xb_xianshi2.png" : (userVideo == "0"  ? "qrc:/miniClassImage/xb_xianshi2.png"  :"qrc:/miniClassImage/xb_xianshi1.png")) :  "qrc:/miniClassImage/xb_xianshi1.png"
                    }

                    Rectangle{
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
                    OpacityMask{
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
    Popup{
        id: studentPopup
        z: 3
        visible: false
        width:  180 * heightRate
        height: 42 * heightRate
        background: Rectangle{
            anchors.fill: parent
            border.width: 1
            border.color: "#dddddd"
            radius: 4 * heightRate
            color: "#ffffff"
        }

        Row{
            width: parent.width
            height: 24 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10 * heightRate

            /*
            //刷新
            MouseArea{
                width: 24 * heightRate
                height: 24 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: "qrc:/miniClassImage/xb_icon_shuxin_changtai.png"
                }

                onClicked: {

                }
            }
            */

            //上下台
            MouseArea{
                width: 32 * heightRate
                height: 25 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: currentUp == "0" ? "qrc:/miniClassImage/xbk_hmc_xiatai.png" : "qrc:/miniClassImage/xbk_hmc_shangtai.png"
                }

                onClicked: {
                    var isCurrentUp  = "0";
                    if(currentUp == "0"){
                        isCurrentUp = "1";
                    }
                    qosApiMgr.clickGoingdown(currentUserId,isCurrentUp,curriculumData.getCurrentIp());
                    updateUserAuthorize(currentUserId,isCurrentUp,currentUserAuth,currentUserAudio,currentUserVideo);
                }
            }

            //授权
            MouseArea{
                width: 32 * heightRate
                height: 24 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: currentUserAuth == "0" ? "qrc:/miniClassImage/xb_hmc_weishouquan.png" : "qrc:/miniClassImage/xb_hmc_shouquan.png"
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
            MouseArea{
                width: 32 * heightRate
                height: 24 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent                    
                    source: currentUserOnline == "1" ? ((currentUp == "1" && currentUserAudio == "1") ? "qrc:/miniClassImage/xb_hmc_on.png" : "qrc:/miniClassImage/xb_hmc_off.png" ) : "qrc:/miniClassImage/xb_hmc_forbid.png"
                }

                onClicked: {
                    var isCurrentAudio  = "0";
                    if(currentUserAudio == "0"){
                        isCurrentAudio = "1";
                        qosApiMgr.clickMute(currentUserId,curriculumData.getCurrentIp());
                    }
                    updateUserAuthorize(currentUserId,currentUp,currentUserAuth,isCurrentAudio,currentUserVideo);
                }
            }

            MouseArea{//奖杯
                width: 32 * heightRate
                height: 24 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: "qrc:/miniClassImage/xb_hmc_jiangli.png"
                }

                onClicked: {
                    studentPopup.close();
                    updateRewardNum(currentUserId);
                    trailBoardBackground.sendTrophy(currentUserId);
                }
            }
        }
    }

    //老师弹窗
    Popup{
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

        Row{
            width: parent.width
            height: 24 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10 * heightRate

            MouseArea{
                width: 20 * heightRate
                height: 20 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.verticalCenter: parent.verticalCenter
                Image{
                    anchors.fill: parent
                    source: "qrc:/miniClassImage/xb_icon_shuxin_changtai.png"
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
                    source: currentMute == 0 ?  "qrc:/miniClassImage/xb_icon_lbqg.png" : "qrc:/miniClassImage/xb_icon_lbqk.png"
                }

                onClicked: {
                    var isMuteStatus = 0;
                    if(currentMute == 0){
                        isMuteStatus = 1;
                        qosApiMgr.clickAullmute(curriculumData.getCurrentIp());
                    }
                    updateMute(isMuteStatus);
                }

            }

        }
    }

    //修改奖杯数量
    function updateRewardNum(userId){
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                var prizeNumber = listModel.get(i).prizeNumber;
                listModel.get(i).prizeNumber = (parseInt(prizeNumber) + 1).toString();
                break;
            }
        }
    }

    //开始上课重置所有学生状态
    function resetStatus(){
        for(var i  = 0; i < listModel.count; i ++){
            listModel.get(i).prizeNumber = "0";
            listModel.get(i).userUp = "1";
            listModel.get(i).userAuth = "0";
            listModel.get(i).isVideo = "1";
            listModel.get(i).userAudio = "1"; //audio;//
            listModel.get(i).userVideo = "1";//video;//
        }
    }

    //小班课授权函数 用户Id, 上台,
    function updateUserAuthorize(userId,up,trail,audio,video){
        currentUp = up;
        currentUserAuth = trail.toString();
        currentUserAudio = audio.toString();
        currentUserVideo = video.toString();
        console.log("====userUP::videoaaaaa====",userId,up,video,trail);
        //如果是上台，根据历史记录开关音视频
        //第一次默认是上台并且音视频默认打开
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                listModel.get(i).userUp = up;
                listModel.get(i).userAuth = trail;
                listModel.get(i).isVideo = (up == "1" && video == "1") ? "1" : "0";
                listModel.get(i).userAudio = (up == "0" ? "0" : audio); //audio;//
                listModel.get(i).userVideo = up;//video;//
                console.log("====userUP::videobbbb====",userId,up,video,listModel.get(i).isVideo,listModel.get(i).userOnline);
                break;
            }
        }
        //视频参数是根据上下台进行展示视频还是关闭视频
        var updateAudio =up == "0" ? "0" : audio;
        rosterView.updateLocalUserAuth(userId,parseInt(up),parseInt(trail),parseInt(updateAudio),parseInt(up));
        trailBoardBackground.setUserAuth(userId,parseInt(up),parseInt(trail),parseInt(audio),parseInt(up));
    }

    //同步小班课授权函数 用户Id, 上台,
    function sysnUserAuthorize(userId,up,trail,audio,video){
        currentUp = up;
        currentUserAuth = trail.toString();
        currentUserAudio = audio.toString();
        currentUserVideo = video.toString();
        console.log("==sysnUserAuthorize::data==",userId,trail,listModel.count);
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                console.log("==sysnUserAuthorize==",userId,trail);
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
        console.log("=====updateMute=======",muteStatus);
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userUp == "1"){
                listModel.get(i).userMute = muteStatus;
                listModel.get(i).userAudio = muteStatus.toString();
            }
        }
        trailBoardBackground.updateAllMute(parseInt(muteStatus));
        rosterView.updateMircphonStatus(muteStatus);
    }

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
            //console.log("==addUserInfo==",userId,JSON.stringify(dataObject));
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

    function updateOnlineStatus(uid,onlineStatus){
        for(var j = 0 ; j < listModel.count ;j++){
            if(listModel.get(j).uid == uid) {
                listModel.get(j).userOnline = onlineStatus;
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

    CurriculumData{
        id:curriculumData
        onSigListAllUserId:{
            listModel.clear();
            for(var j = 0; j < list.length ; j++) { // 7; j++){//
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
                //userVideo 0是关 1是开
                //userAudio 0是关 1是开
                //isVideo  0是关 1是开
                //userAuth 0未授权 1授权
                //userOnline 0离线 1在线
                //userUp 0下台 1上台
                console.log("==videoToolBackground::data==",userName,userOnline,userAudio,userVideo,userUp,userAuth);
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
                            });
                break;
            }
        }
    }
    //操作视频
    ExternalCallChanncel{
        id:externalCallChanncel

        onCreateRoomFail:{
            popupWidget.setPopupWidget("createRoomFail");
        }
        //麦克风显示音量操作
        onSigAudioVolumeIndication:{
            var uids = uid.toString();
            var totalVolumes = totalVolume.toString();
            //console.log("=====onSigAudioVolumeIndication=====",totalVolumes)
            for(var j = 0 ; j < listModel.count ;j++){
                if(listModel.get(j).userId == uids) {
                    listModel.get(j).volumes =totalVolumes;
                }
            }
        }

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
               joinClassText.text = userName + "，进入教室了";
           }
       }
    }

    function updateIsVideo(uid,status){
        for(var j = 0 ; j < listModel.count ;j++){
            console.log("======updateIsVideo======",listModel.get(j).userId)
            if(listModel.get(j).uid == uid) {
                listModel.get(j).userOnline = status.toString()
                listModel.get(j).isVideo = status.toString();
                break;
            }
        }
    }

    MouseArea{
        anchors.fill: parent
        z:1
        onClicked: {
            videoToolBackground.focus = true;
        }
    }

    ListModel{
        id: handoutModel
    }

    Component.onCompleted: {
        curriculumData.getListAllUserId();
        courseNameId = curriculumData.curriculumId;
        courseNamea = curriculumData.curriculumName;
        startEndTime = curriculumData.startToEndTime;
    }

    //修改网络图标
    function updateNetworkInfo(netType,delay,lossRate,cpuRate){
        qosApiMgr.networkQuality(lossRate,delay,curriculumData.getCurrentIp());
        networkControlView.updateNetValue(netType,delay,lossRate,cpuRate);
    }

}

