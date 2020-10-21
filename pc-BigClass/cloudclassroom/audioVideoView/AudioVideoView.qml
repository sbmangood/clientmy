import QtQuick 2.5
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import VideoRender 1.0
import "./Configuration.js" as Cfg

Rectangle {
    id: audiovideoview
    width: parent.width
    height: parent.height
    color: "#30313D"

    property double widthRate: fullWidths / 1440.0
    property double heightRate: fullHeights / 900.0
    property bool isBeautyOn: true;

    property var currentUserId: 0;//当前选择操作学生的Id
    property var currentMute: 0;//当前是否禁音
    property string currentUp: "-1";//上下台
    property string currentUserAuth: "-1";//当前权限
    property string currentUserAudio: "-1";//当前音频状态
    property string currentUserVideo: "-1";//当前视频状态

    signal sigOperationVideoOrAudio(string userId , string videos , string audios);  //打开关闭本地摄像头、麦克风
    signal sigOnOffVideoAudio(string videoType);//音频，音视频切换
    signal sigSetUserAuth(string userId,string authStatus);//用户授权信号
    signal sigPlayerVideo(var videoSoucre,var videoName);//播放视频源
    signal sigPlayerAudio(var audioSoucre,var audioName);//播放mp3信号

    signal sigSetUserAuths(var userId, string up, int trail, int audio, int video);
    signal sigUpdateAllMute(int muteStatus);// 全体禁言信号

    //背景
    ListView {
        id: videoListView
        anchors.fill: parent
        delegate: listViewDelegate
        model: listModel
        clip: true
        orientation: ListView.Horizontal
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
            width: 200 * widthRate
            height: videoListView.height
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                id: itembgk
                width: 196 * widthRate
                height: 110 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: ((videoListView.width  - listModel.count * width - 28 * heightRate * listModel.count ) * 0.5) + 28 * heightRate * 0.5
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    console.log("===onclick::userId===",userId,uid,userRole,userAuth,isteacher,userUp,userVideo,userOnline)
                    //updateSelected(userId);
                }

                Image{
                    z: 6
                    width: 22 * heightRate
                    height: 22 * heightRate
                    source: "qrc:/bigclassImage/ico_view_warrant.png"
                    anchors.right: parent.right
                    visible: userRole == 1 && userAuth == "1" ? true : false
                }

                // 视频显示
                VideoRender {
                    id: videoRender
                    width:  196 * widthRate
                    height: 110 * heightRate
                    imageId: uid
                    z: 5
                    visible: (userUp == "1" && userVideo == "1") ? (userOnline == "1"  ? true :  false ): false
                    Component.onCompleted: {
                        videoRender.enableBeauty(false);
                    }

                    // 学生信息与麦克风状态
                    Item {
                        id: infoItem
                        z: 100
                        width: parent.width
                        height: 18 * heightRate
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom

                        Rectangle {
                            anchors.fill: parent
                            opacity: 0.5
                            color: "#333333"
                        }

                        // 奖杯
                        Item {
                            width: 42 * widthRate
                            height: 16 * heightRate
                            anchors.left: parent.left
                            Image {
                                id: jiangliImg
                                width: parent.height
                                height: parent.height
                                visible: isteacher == 0 ? true : false
                                source: "qrc:/avimages/jiangbei.png"
                                anchors.rightMargin: 8 * heightRate
                            }
                            Text {
                                width: 23 * widthRate
                                height: 14 * heightRate
                                anchors.left: jiangliImg.right
                                anchors.leftMargin: 4 * heightRate
                                id: jiangliText
                                visible: isteacher == 0 ? true : false
                                text: prizeNumber
                                color: "#ffcc33"
                                font.pixelSize: 15 * heightRate
                                font.family: Cfg.DEFAULT_FONT
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // 用户名
                        Text {
                            color: "#ffffff"
                            text: userName
                            width: 44 * widthRate
                            height: parent.height
                            anchors.left: parent.left
                            anchors.leftMargin: 133 * widthRate
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 14 * heightRate
                            font.family: Cfg.DEFAULT_FONT
                            elide:Text.ElideRight
                        }

                        // 麦克风开关
                        Item {
                            id: micBtn
                            width: 14 * widthRate
                            height: 14 * heightRate
                            anchors.right: parent.right
                            anchors.rightMargin: 5 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: micImg
                                anchors.fill: parent
                                source: userAudio == "1" ? "qrc:/avimages/mike_focused.png" : "qrc:/avimages/mike_unfocused.png"
                            }
                        }

                        MouseArea {
                            hoverEnabled: true
                            anchors.bottom: parent.bottom
                            cursorShape: Qt.PointingHandCursor
                            enabled: userOnline == "1" ? true : false
                            onClicked: {
                                currentUserId = userId;
                                currentMute = userMute;//禁音
                                currentUp = userUp;//上下台权限
                                currentUserAuth = userAuth;//当前权限
                                currentUserAudio = userAudio;//当前音频状态
                                currentUserVideo = userVideo;//当前视频状态

                                if(isteacher == 0){
                                    studentPopup.open();
                                    var locationX = ((audiovideoview.width - videoListView.width) * 0.5) + index  * itembgk.width + index * 28 * heightRate + 13 * heightRate;
                                    studentPopup.x = locationX;
                                    studentPopup.y = videoListView.y + 120 * widthRate;
                                }
                                else {
                                    teaPopup.open();
                                    teaPopup.x = ((audiovideoview.width - videoListView.width) * 0.5) + index  * itembgk.width + index * 28 * heightRate + 13 * heightRate;
                                    teaPopup.y = videoListView.y + 120 * widthRate;
                                }
                            }
                        }
                    }

                    // 音量
                    Image {
                        id: micPhoneImg
                        z: 100
                        width: 13 * heightRate
                        height: 20 * heightRate
                        anchors.right: parent.right
                        anchors.rightMargin: 6 * heightRate
                        anchors.bottom: infoItem.top
                        anchors.bottomMargin: 2 * heightRate
                        source:  {
                            if(userAudio == 1){
                                if(volumes == "0"){
                                    return "qrc:/bigclassImage/yin0@2x.png";
                                }
                                if(volumes == "1"){
                                    return "qrc:/bigclassImage/yin1@2x.png"
                                }
                                if(volumes == "2"){
                                    return "qrc:/bigclassImage/yin2@2x.png";
                                }
                                if(volumes == "3"){
                                    return "qrc:/bigclassImage/yin3@2x.png";
                                }
                                if(volumes == "4"){
                                    return "qrc:/bigclassImage/yin4@2x.png";
                                }
                                if(volumes == "5"){
                                    return "qrc:/bigclassImage/yin5@2x.png";
                                }
                                if(volumes == "6"){
                                    return "qrc:/bigclassImage/yin5@2x.png";
                                }
                                return "qrc:/bigclassImage/yin5@2x.png";
                            }else{
                                return "qrc:/bigclassImage/yin0@2x.png";
                            }

                        }
                    }

                }

                // 视频遮罩
                Image {
                    id: backImg
                    z: 5
                    anchors.fill: parent
                    visible:  userOnline == "1" ? (userVideo == "0" ?  true : false) : true
                    source: userOnline == "1" ?  (userUp == "0" ? "qrc:/avimages/xb_xianshi2.png" : (userVideo == "0"  ? "qrc:/avimages/xb_xianshi2.png" :
                                                                                                                         (isteacher == "1" ? "qrc:/avimages/img_view_teacher.png" :"qrc:/avimages/img_view_student.png"))) :
                                                (isteacher == "1" ? "qrc:/avimages/img_view_teacher.png" :"qrc:/avimages/img_view_student.png")
                }

                YMAuthView{
                    id: authView
                    z: 6
                    focus: itembgk.containsMouse
                    visible: userRole == 0 ? (itembgk.containsMouse ? true : false) : ((userAuth == "1" && userId == 0) ? (itembgk.containsMouse ? true : false) : false)
                    width: parent.width
                    height: 52 * heightRate
                    userIds: userId
                    mirophon: userAudio
                    camera: userVideo
                    auth: userAuth
                    userRoles: userRole
                    userType: isteacher
                    onSigOperating: {
                        //updateSelected(userId);
                        var sendUserId = (userId == 0 ? currentUserId : userId);
                        switch(operaType){
                        case 1:
                            userAudio = operaStatus.toString();
                            toolbar.setUserAuth(sendUserId,authView.camera,authView.auth,operaStatus,authView.camera);
                            break;
                        case 2:
                            userVideo = operaStatus.toString();
                            toolbar.setUserAuth(sendUserId,operaStatus,authView.auth,authView.mirophon,authView.camera);
                            break;
                        case 3:
                            userAuth = operaStatus.toString();
                            toolbar.setUserAuth(sendUserId,authView.camera,operaStatus,authView.mirophon,authView.camera);
                            break;
                        case 4:
                            prizeNumber++;
                            trophy.sendTrophy(sendUserId,"");
                            break;
                        default :
                            break;
                        }
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
                    updateUserAuthorize(currentUserId,currentUp,currentUserAuth,isCurrentAudio,currentUserVideo);
                }
            }


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

    ListModel{
        id: userAuthBufferModel
    }

    // 添加用户信息
    function addSelfBaseInfo(userId, dataObject){
        console.log("===addSelfBaseInfo===",userId,JSON.stringify(dataObject));
        var userName = dataObject.userName;//用户名
        var isteacher = dataObject.isteacher;//老师状态
        var uid = dataObject.uid;
        if(isUserExist(userId,uid,userName,isteacher)){
            updateOnlineStatus(userId,"1");
            return;
        }
        var userOnline = dataObject.userOnline;//用户在线状态
        var userAuth = dataObject.userAuth;//用户权限
        var isVideo = dataObject.isVideo;//是否为视频
        var userAudio = dataObject.userAudio//麦克风状态
        var userVideo = dataObject.userVideo;//视频状态
        var imagePath = dataObject.imagePath;//视频路径
        var supplier = dataObject.supplier;//用户通道
        var headPicture = dataObject.headPicture; //用户头像
        var userMute = dataObject.userMute;
        var userUp = dataObject.userUp;
        var rewardNum = dataObject.rewardNum;
        // 如果用户已经在视频列表则先删除再加入，便于后面的重新排序
        for(var i = 0; i < listModel.count; i++){
            if(listModel.get(i).userId == userId){
                listModel.remove(i);
            }
        }
        // 排序：老师在首位，学生在后
        var video_index = 0;
        if(isteacher == "1"){
            video_index = 0;
        }
        else {
            video_index = listModel.count;
        }

        listModel.insert(video_index,
                    {
                        "uid": parseInt(uid),
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
                        "prizeNumber": parseInt(rewardNum),
                        "selected" : false,
                    });
    }

    function updateSelected(userId){
        for(var j = 0 ; j < listModel.count ;j++){
            if(listModel.get(j).userId === userId){
                var isCheck = listModel.get(j).selected;
                listModel.get(j).selected = !isCheck;
                continue;
            }
            listModel.get(j).selected = false;
        }
    }

    function updateVolume(volumes,uid){
        if(listModel.count == 0){
            return;
        }
        for(var i = 0; i < listModel.count;i++){
            if(listModel.get(i).uid == uid){
                listModel.get(i).volumes = volumes;
                break;
            }
        }
    }

    function getUserAuth(userId){
        for(var j = 0 ; j < listModel.count ;j++){
            if(listModel.get(j).userId === userId.toString()){
                return listModel.get(j).userAuth;
            }
        }
        return 0;
    }

    // 更新用户状态
    function updateUserState(userId, up){
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                if(up == "0"){
                    listModel.get(i).userOnline = "0";
                    listModel.get(i).userVideo = "0";
                    listModel.get(i).userAudio = "0";
                }
                else if(up == "1"){
                    listModel.get(i).userOnline = "1";
                    listModel.get(i).userVideo = "1";
                    listModel.get(i).userAudio = "1";
                }
            }
        }
    }

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

    function updateRewardNum(userId,number){
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                listModel.get(i).prizeNumber = number;
                break;
            }
        }
    }

    function synRewardNum(jsonArray){
        console.log("====jsonArray[i]=====",jsonArray.length,listModel.count)
        for(var k = 0; k < listModel.count;k++){
            for(var i  = 0; i < jsonArray.length; i ++){
                console.log("====jsonArray[i].uid=====",jsonArray[i].uid,listModel.get(k).userId)
                if(listModel.get(k).userId === jsonArray[i].uid){
                    listModel.get(i).prizeNumber = jsonArray[i].count;
                    break;
                }
            }
        }
    }

    function getRewardNum(userId){
        console.log("===getRewardNum======",userId,listModel.count);
        for(var k = 0; k < listModel.count;k++){
            if(listModel.get(k).uid ===userId){
                console.log("====getRewardNum=====",listModel.get(k).prizeNumber)
                return listModel.get(k).prizeNumber;
            }
        }
    }

    function isUserAuth(userId){
        for(var i = 0 ; i < userAuthBufferModel.count;i++){
            if(userAuthBufferModel.get(i).userId === userId){
                return i;
            }
        }
        return -1;
    }

    // 授权函数
    function updateUserAuthorize(userId,up,trail,audio,video){
        currentUp = up;
        currentUserAuth = trail.toString();
        currentUserAudio = audio.toString();
        currentUserVideo = video.toString();

        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                listModel.get(i).userUp = up;
                listModel.get(i).userAuth = trail;
                listModel.get(i).isVideo = (up == "1" && video == "1") ? "1" : "0";
                listModel.get(i).userAudio = (up == "0" ? "0" : audio);
                listModel.get(i).userVideo = up;
                break;
            }
        }
        sigSetUserAuths(userId,parseInt(up),parseInt(trail),parseInt(audio),parseInt(up));
    }

    function getCurrentUserAllAuth(userId){
        var userAuth;
        for(var i = 0 ; i < userAuthBufferModel.count;i++){
            if(userId.toString() === userAuthBufferModel.get(i).userId){
                //console.log("===getCurrentUserAllAuth===",userId,userAuthBufferModel.count);
                userAuth = {
                    "userId": userAuthBufferModel.get(i).userId,
                    "up": userAuthBufferModel.get(i).up,
                    "trail":userAuthBufferModel.get(i).trail,
                    "audio": userAuthBufferModel.get(i).audio,
                    "video":userAuthBufferModel.get(i).video,
                };
                return userAuth;
            }
        }
        return userAuth;
    }

    //同步授权函数
    function sysnUserAuthorize(userId,up,trail,audio,video,synStatus){
        currentUp = up;
        currentUserAuth = trail.toString();
        currentUserAudio = audio.toString();
        currentUserVideo = video.toString();

        var indexs = isUserAuth(userId);
        if(indexs == -1){
            userAuthBufferModel.append(
                        {
                            "userId": userId.toString(),
                            "up": up.toString(),
                            "trail":trail.toString(),
                            "audio": audio.toString(),
                            "video":video.toString(),
                        });
        }else{
            userAuthBufferModel.setProperty(indexs,"userId",userId.toString());
            userAuthBufferModel.setProperty(indexs,"up",up.toString());
            userAuthBufferModel.setProperty(indexs,"trail",trail.toString());
            userAuthBufferModel.setProperty(indexs,"audio",audio.toString());
            userAuthBufferModel.setProperty(indexs,"video",video.toString());
        }

        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                listModel.get(i).userUp = up.toString();
                listModel.get(i).userAuth = trail.toString();
                listModel.get(i).isVideo =  (up == "1" && video == "1") ? "1" : "0";
                listModel.get(i).userAudio = (up == 0 ? "0" : audio.toString()); //audio;//
                listModel.get(i).userVideo = (up == 0 ? "0" : video.toString());//video;
                listModel.get(i).userOnline = "1";
                break;
            }
        }
        if(synStatus && userId === 0){
            toolbar.closeAudio(audio);
            toolbar.closeVideo(video);
        }
    }

    //用户是否存在
    function isUserExist(userId,uid,nickName,isteacher){
        for(var i = 0; i < listModel.count;i++){
            if(listModel.get(i).userId == userId){
                listModel.get(i).userName = nickName;
                return true;
            }
        }
        return false;
    }


    //全体静音 muteStatus 0静音，1 恢复
    function updateMute(muteStatus){
        currentMute = muteStatus;
        currentUserAudio = muteStatus;
        for(var i  = 0; i < listModel.count; i ++){
            listModel.get(i).userMute = muteStatus;
            listModel.get(i).userAudio = muteStatus.toString();
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
}

