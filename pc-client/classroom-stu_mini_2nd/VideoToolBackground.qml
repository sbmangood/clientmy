import QtQuick 2.7
import QtGraphicalEffects 1.0
import CurriculumData 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import VideoRender 1.0
import ExternalCallChanncel 1.0
import QtQuick.Controls 2.0
import "./Configuration.js" as Cfg

/*
  * 视频工具栏
  */
Rectangle {
    id:videoToolBackground

    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates


    //边框阴影
    property int borderShapeLens: (rightWidthX - midWidth - midWidthX) > 10 ? 10 : (rightWidthX - midWidth - midWidthX)
    color: "#00000000"

    //课程类型
    property string  curriculumType: "A"
    property int networkStatus: 3;//无线还是有线网状态
    property int networkValue: 3; //3 优 2良 1 差 0 无网络
    property int pingValue: 3;//当前ping值
    property int lossrate: 0;//丢包率
    property int cpuValue: 20;//CPU使用率

    property var currentUserId: 0;//当前选择操作学生的Id
    property var currentMute: 0;//当前是否禁音
    property var currentUp: 0;//上下台
    property var currentUserAuth: 0;//当前权限
    property var currentUserAudio: 0;//当前音频状态
    property var currentUserVideo: 0;//当前视频状态
    property var currentUserNameId: curriculumData.getCurrentUserId();//当前教室内用户ID
    property string tipsText: "";
    property bool isTeaLogin: false;

    //总长度时间
    property int  totalLengthTime:0
    //当前时间的长度
    property int  currentLengthTime: 0
    property  int serverClassTime: 0;
    property var currentTimeInLocal: ;

    //当前时间的字符串
    property string  currentLengthTimeStr:""

    //是否加载数据
    property bool  loadDataStatus: false

    property int  loadDataStatusInt: 0

    //按键操作
    property bool  audioVideoHandl: false
    //关闭界面
    signal sigCloseWidget();
    //学生类型
    property  string  studentType: curriculumData.getCurrentUserType()

    property string timeProgressBarsTexts: "" ;
    //关闭本地摄像头
    signal sigOperationVideoOrAudio(string userId , string videos , string audios);

    //老师是否在线
    property bool teacherIsOnline: false;

    //切换通道失败信号
    signal sigCreatRoomFails();


    //设置留在教室
    function setStayInclassroom(){
        audioVideoHandl = false;
    }
    //关闭视频
    function closeVideo(){
        externalCallChanncel.setStayInclassroom();
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
    function classOverViewReset()
    {
        for(var j = 0 ; j < listModel.count ;j++){
            listModel.setProperty(j,"userOnline","0");
        }
    }
    //处理操作界面
    function handlPromptInterfaceHandl( inforces){

        //在线离线状态
        if(inforces == "51") {
            // console.log("inforces ==  51515151511 ",inforces);
            for(var j = 0 ; j < listModel.count ;j++){
                listModel.setProperty(j,"userOnline",curriculumData.justUserOnline( listModel.get(j).userId ));
            }
            teacherIsOnline = curriculumData.justTeacherOnline();
            return;
        }
        //改变频道跟音频
        if(inforces == "61") {
            // console.log("inforces ==",inforces);

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

    //设置开始上课
    function setStartClassTimeData(times){
        externalCallChanncel.initVideoChancel();
        for(var j = 0 ; j < listModel.count ;j++){
            listModel.setProperty(j,"isVideo",curriculumData.getIsVideo());
            listModel.setProperty(j,"supplier",curriculumData.getUserChanncel());
            listModel.setProperty(j,"userVideo",curriculumData.getUserCamcera( listModel.get(j).userId ));
            listModel.setProperty(j,"userAudio",curriculumData.getUserPhone( listModel.get(j).userId ));
        }
        audioVideoHandl = true;
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
    //背景
    Item{
        id:videoToolBackgroundColor
        width: parent.width - borderShapeLens
        height: parent.height
        anchors.left: borderShapes.right
        anchors.top: parent.top
        z:2
        //关闭按钮
        MouseArea{
            id: closeButton
            width: 112 * heightRate
            height: 30 * heightRate
            hoverEnabled: true
            anchors.right: parent.right
            anchors.rightMargin: 10 * widthRate

            Rectangle{
                anchors.fill: parent
                radius: 4 * heightRate
                color:  parent.containsMouse ? (parent.pressed ? "#FF8E57" : "#FFD6C2") : "#ffffff"
            }

            Text {
                text: qsTr("退出教室 →")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 18 * heightRate
                anchors.centerIn: parent
            }

            onPressed: {
                videoToolBackground.focus = true;
                //colseBtnImage.source = "qrc:/images/bnt_quittwo.png"
            }
            onReleased: {
                //colseBtnImage.source = "qrc:/images/bnt_quit_sedtwo.png"
                sigCloseWidget();
            }
        }

        Text {
            id: courseNamea
            height: 20  * heightRates
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 18 * widthRates
            anchors.topMargin:  3  * heightRate
            font.pixelSize: 18 * heightRate
            wrapMode:Text.WordWrap
            font.family: Cfg.DEFAULT_FONT

        }

        //网络状态与设备状态
        YMNetworkControlView{
            id: networkControlView
            anchors.top: parent.top
            anchors.topMargin: 3 * heightRate
            anchors.right: closeButton.left//minButton.left
            anchors.rightMargin: 40 * heightRate
        }

        ListView{
            id:videoListView
            z: 1
            height: 130 * widthRates
            width: {
                if(listModel.count >= 6){
                    return parent.width - 80 * heightRate;
                }
                else{
                    return listModel.count *  258 * heightRate
                }
            }
            orientation:ListView.Horizontal
            anchors.horizontalCenter: parent.horizontalCenter
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
            Item {
                id:itemDelegate
                width: 258 * heightRate
                height: 130 * widthRates
                Rectangle{
                    id:itemDelegateBackGround
                    width: 230 * heightRate
                    height: 120 * widthRates//parent.height
                    anchors.left: parent.left
                    radius: 6 * heightRate
                    anchors.leftMargin: ((videoListView.width  - listModel.count * width - 28 * heightRate * listModel.count ) * 0.5) + 28 * heightRate * 0.5
                    color: "#ffffff"

                    property var currentUserAudio: userAudio;
                    property var currentUserAuth: userAuth;

                    onCurrentUserAudioChanged: {
                        if(isSynCompletes == false){
                            return
                        }

                        var locationX = ((videoToolBackground.width - videoListView.width) * 0.5) + index  * itemDelegateBackGround.width + index * 28 * heightRate;
                        bannedImg.x = locationX;
                        bannedImg.y = videoListView.y + 114 * widthRates;

                        if(userAudio == "0" && userUp == "1"  && userId == "0"){
                            tipsText = "亲，您被禁止发言了 请保持课堂安静哦～";
                            bannedImg.visible = true;
                            bannedTime.restart();
                        }
                        else if(userAudio == "1" && userUp == "1"  && userId == "0"){
                            tipsText = "亲,您可以自由发言了!";
                            bannedImg.visible = true;
                            bannedTime.restart();
                        }
                    }

                    onCurrentUserAuthChanged: {
                        if(isSynCompletes == false){
                            return
                        }
                        var locationX = ((videoToolBackground.width - videoListView.width) * 0.5) + index  * itemDelegateBackGround.width + index * 28 * heightRate;
                        bannedImg.x = locationX;
                        bannedImg.y = videoListView.y + 114 * widthRates;

                        if(userAuth == "1" && userId == "0"){
                            tipsText = "亲,您可以使用工具了!";
                            bannedImg.visible = true;
                            bannedTime.restart();
                        }else  if(userAuth == "0" && userId == "0"){
                            tipsText = "亲,您被禁止使用工具了～";
                            bannedImg.visible = true;
                            bannedTime.restart();
                        }
                    }

                    //视频显示
                    VideoRender{
                        id:videoRender
                        width: parent.width
                        height: 133 * widthRates
                        imageId: uid
                        z: 6
                        visible: false//(userUp == "1" && userVideo == "1") ? (userOnline == "1" ?  true : false): false//isVideo == "1" ?  true : false
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

                        Image{
                            anchors.fill: parent
                            source: "qrc:/miniClassImage/6pxbackgrundImg.png"
                        }

                        onClicked: {
                            console.log("=====onclicked::uid====",uid)
//                                currentUserId = userId;
//                                currentMute = userMute;//禁音
//                                currentUserAuth = userAuth;//当前权限
//                                currentUserAudio = userAudio;//当前音频状态
//                                currentUserVideo = userVideo;//当前视频状态
//                                console.log("====header::Click=====",currentUserId,userAuth,userAudio,userVideo)
//                                if(isteacher == 0){
//                                    studentPopup.open();
//                                    var locationX = ((videoToolBackground.width - videoListView.width) * 0.5) + index  * itemDelegateBackGround.width + index * 28 * heightRate + 13 * heightRate;
//                                    console.log("=====locationX=====",locationX,index,videoToolBackground.width,videoListView.width,videoToolBackground.width - videoListView.width);
//                                    studentPopup.x = locationX;
//                                    studentPopup.y = videoListView.y + 130 * widthRates;
//                                }
                        }

                        Image{
                            id: micPhoneImg
                            width: 27 * heightRate
                            height: 20 * heightRate
                            anchors.left: parent.left
                            anchors.leftMargin: 6 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                            source: {
                                if(userAudio == "1"){
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
                                    if(isteacher == 1){
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
                            width: 20 * heightRate
                            height: 20 * heightRate
                            visible: isteacher == 0 ? true : false
                            source: "qrc:/miniClassImage/xb_hmc_jiangli.png"
                            anchors.right: parent.right
                            anchors.rightMargin: 32 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            visible: isteacher == 0 ? true : false
                            text: trophyNumber
                            color: "#ffcc33"
                            font.pixelSize: 15 * heightRate
                            font.family: Cfg.DEFAULT_FONT
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left:  jiangliImg.right
                            anchors.leftMargin: 3 * heightRate
                        }

                    }

                    //操作背景
                    Image{
                        id: backImg
                        z: 5
                        width: parent.width
                        height: parent.height
                        visible:  false//userOnline == "1" ? (userVideo == "0" ?  true : false) : true
                        source: userOnline == "1" ?  (userUp == "0" ? "qrc:/miniClassImage/xb_xianshi2.png" : (userVideo == "0" ? "qrc:/miniClassImage/xb_xianshi2.png" : "qrc:/miniClassImage/xb_xianshi1.png")) : ((isteacher && isTeaLogin) ? "qrc:/miniClassImage/xb_xianshi1.png" : "qrc:/miniClassImage/xbk_camer_bg_thoff.png")
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
                        visible: (userVideo == "1") ? (userOnline == "1"  ? true :  false ): false
                        source: videoRender
                        maskSource: maskView
                    }
                }

            }
        }
    }

    Timer{
        id: bannedTime
        interval: 3000
        repeat: false
        running: false
        onTriggered: {
            bannedImg.visible = false;
        }
    }

    //禁言图标
    Image{
        id: bannedImg
        visible: false
        width:300 * heightRate
        height: 100 * heightRate
        source: "qrc:/miniClassImage/xb_jinyan1.png"

        Text {
            id: tipsOne
            width: 180 * heightRate
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 12 * widthRate
            text: tipsText
            color: "#ffffff"
            anchors.left: parent.left
            anchors.leftMargin: 35 * heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: (parent.height - height) * 0.5 - 5 * heightRate
            wrapMode: Text.AlignLeft
        }
    }

    //学生弹窗
    Popup{
        id: studentPopup
        z: 3
        visible: false
        width:  115 * heightRate
        height: 43 * heightRate
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

            //下台
            MouseArea{
                width: 24 * heightRate
                height: 24 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: currentUp == 0 ? "qrc:/miniClassImage/xbk_hmc_shangtai.png" : "qrc:/miniClassImage/xbk_hmc_xiatai.png"
                }

                onClicked: {
                    var isCurrentUp  = 0;
                    if(currentUp == 0){
                        isCurrentUp = 1;
                    }
                    updateUserAuthorize(currentUserId,isCurrentUp,currentUserAuth,currentUserAudio,currentUserVideo);
                }
            }

            //授权
            MouseArea{
                width: 24 * heightRate
                height: 24 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: currentUserAuth == 0 ? "qrc:/miniClassImage/xb_hmc_shouquan.png" : "qrc:/miniClassImage/xb_hmc_weishouquan.png"
                }

                onClicked: {
                    var isCurrentAuth  = 0;
                    if(currentUserAuth == 0){
                        isCurrentAuth = 1;
                    }
                    updateUserAuthorize(currentUserId,currentUp,isCurrentAuth,currentUserAudio,currentUserVideo);
                }
            }

            //禁音
            MouseArea{
                width: 24 * heightRate
                height: 24 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: currentUserAudio == 0 ? "qrc:/miniClassImage/xb_hmc_on.png" : "qrc:/miniClassImage/xb_hmc_forbid.png"
                }

                onClicked: {
                    var isCurrentAudio  = 0;
                    if(currentUserAudio == 0){
                        isCurrentAudio = 1;
                    }
                    updateUserAuthorize(currentUserId,currentUp,currentUserAuth,isCurrentAudio,currentUserVideo);
                }
            }
        }
    }

    //小班课授权函数 用户Id, 上台,
    function updateUserAuthorize(userId,up,trail,audio,video){
        console.log("====updateUserAuthorize===",userId,up,trail,audio,video);
        currentUp = up;
        currentUserAuth = trail;
        currentUserAudio = audio;
        currentUserVideo = video;
        var currentIndexOf = 0;

        //修改其它学生状态
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                listModel.get(i).userMute = up;
                listModel.get(i).userAuth = trail.toString();
                listModel.get(i).userAudio = audio.toString();
                listModel.get(i).userVideo = video.toString();
                listModel.get(i).userOnline = up.toString();
                currentIndexOf = i;
                break;
            }
        }

        var sUserId = curriculumData.getCurrentUserId();
        if(userId == sUserId){
            for(var i  = 0; i < listModel.count; i ++){
                if(listModel.get(i).userId == "0"){
                    currentIndexOf = i;
                    listModel.get(i).userUp = up.toString();
                    listModel.get(i).userAuth = trail.toString();
                    listModel.get(i).userAudio = up == 0 ? "0" : audio.toString();
                    listModel.get(i).userVideo = video.toString();
                    break;
                }
            }

            if(trail == 0){
                toolbarsView.disableButton = false;
            }else{
                toolbarsView.disableButton = true;
            }

            if(up == 0){
                externalCallChanncel.closeAudio("0");
                updateStudentStatus(userId,"0","1","1");
            }else{
                console.log("====audio====",audio,currentIndexOf,listModel.count)
                if(listModel.count == 0)
                {
                    return;
                }

                if(userId == sUserId){
                    userId = "0";
                    externalCallChanncel.closeAudio(audio);
                }

                var isVideo = listModel.get(currentIndexOf).isVideo;
                if(isVideo == "0"){
                    externalCallChanncel.closeVideo("1");
                    listModel.get(currentIndexOf).isVideo = "1";
                }
                var userVideos = curriculumData.getUserCamcera(userId);
                if(userVideos != isVideo){
                    externalCallChanncel.closeVideo(isVideo)
                }
                updateStudentStatus(userId,audio.toString(),video.toString(),"1");
            }
        }

        rosterView.updateUserAuth(userId,up,trail,audio,video);
        console.log("====listModel.get(i).userId =======",sUserId ,userId)
    }

    //修改学生音视频信息
    function updateStudentStatus(userId,audio,video,isVideo){
        console.log("====updateStudentStatus===",userId,audio,video,isVideo)
        var sUserId = curriculumData.getCurrentUserId();
        if(userId == sUserId){
            userId = "0";
        }

        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                listModel.get(i).isVideo = isVideo;
                listModel.get(i).userAudio = audio;
                listModel.get(i).userVideo = video;
                break;
            }
        }
    }


    //全体静音 muteStatus 0静音，1 恢复
    function updateMute(userId,muteStatus){
        currentMute = muteStatus;
        currentUserAudio = muteStatus;

        var sUserId = curriculumData.getCurrentUserId();
        if(sUserId == userId){
            externalCallChanncel.closeAudio(muteStatus);
        }
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userUp == "1"){
                listModel.get(i).userMute = muteStatus;
                listModel.get(i).userAudio = muteStatus.toString();
            }
        }
        rosterView.updateMircphonStatus(muteStatus);
    }

    function updateTrophy(userId){
        var sUserId = curriculumData.getCurrentUserId();
        console.log("==updateTrophy===",userId,sUserId)
        if(userId == sUserId){
            userId = "0";            
            trailBoardBackground.showTrophy();
        }
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                var trophyNumber = listModel.get(i).trophyNumber;
                listModel.get(i).trophyNumber = (parseInt(trophyNumber) + 1).toString();
                console.log("====userAudiouserAudio=====",listModel.get(i).trophyNumber)
                break;
            }
        }
    }

    CurriculumData{
        id:curriculumData
        onSigListAllUserId:{
            listModel.clear();
            for(var j = 0; j < list.length ; j++) { // 6; j++){//
                var userId = list[j];
                var userName = curriculumData.getUserName( list[j] );
                var userOnline = curriculumData.justUserOnline(list[j] );
                var userAuth = curriculumData.getUserIdBrushPermissions( list[j] );
                var isVideo = curriculumData.getIsVideo();
                var userAudio = curriculumData.getUserPhone( list[j] );
                var userVideo = curriculumData.getUserCamcera( list[j] );
                var imagePath = curriculumData.getUserUrl( list[j] );
                var isteacher = curriculumData.isTeacher(list[j]);
                var supplier = curriculumData.getUserChanncel();
                var volumes = "0";
                var headPicture = curriculumData.getUserPicture(userId);
                var userMute = 0;
                var trophyNumber = curriculumData.getRewardNum(userId);
                var uid = curriculumData.getUserUid(userId);
                var userUp = curriculumData.getUserUpStatus(userId);
                console.log("====onSigListAllUserId====",userId,userOnline,isVideo,userAudio,userVideo,userAuth,headPicture)
                listModel.append(
                            {
                                "userId": userId,
                                "uid": uid,
                                "userUp": userUp,
                                "userMute": userMute,
                                "userName": userName,
                                "userOnline": userOnline,
                                "userAuth": userAuth,
                                "isVideo": isVideo,
                                "userAudio": userAudio,
                                "userVideo": userVideo,
                                "imagePath": imagePath,
                                "isteacher": isteacher,
                                "supplier": supplier,
                                "volumes": volumes,
                                "headPicture": headPicture,
                                "trophyNumber": trophyNumber,
                            });
                if(userId == "0"){
                    userId = curriculumData.getCurrentUserId();
                    updateUserAuthorize(userId,userUp,userAuth,userAudio,userVideo);
                    break;
                }
            }
        }
    }
    //操作视频
    ExternalCallChanncel{
        id:externalCallChanncel

        onSigAudioVolumeIndication:{
            var uids = uid.toString();
            var totalVolumes = totalVolume.toString();
            for(var j = 0 ; j < listModel.count ;j++){
                if(listModel.get(j).userId == uids) {
                    listModel.setProperty(j,"volumes",totalVolumes );
                }
            }
        }

        onCreateRoomFail: {
            //popupWidget.setPopupWidget("createRoomFail");
            sigCreatRoomFails();
        }
        onSigJoinroom: {
            console.log("=====onSigJoinroom======",uid,userId,status)
            var isteacher = curriculumData.isTeacher(userId);
            if(isteacher == "1"){
                isTeaLogin = true;
                updateUserOnlineAuth(isteacher,status);
            }
            addUserInfo(userId)
            updateIsVideo(uid,status);
            rosterView.updateOnline(userId,status);
        }
    }

    function updateUserOnlineAuth(isteacher,status){
        if(isteacher == "1" && status == "0"){//如果是老师退出则学生不能操作
            trailBoardBackground.isHandl = false;
            toolbarsView.disableButton = false;
        }
        if(isteacher == "1" && status == "1"){//如果是老师进入则判定学生是否有操作权限
            var userAuth = curriculumData.getUserIdBrushPermissions(curriculumData.getCurrentUserId());
            if(userAuth == "1"){
                trailBoardBackground.isHandl = true;
                toolbarsView.disableButton = true;
            }
        }
    }

    function updateIsVideo(uid,status){
        for(var j = 0 ; j < listModel.count ;j++){
            console.log("======updateIsVideo======",listModel.get(j).userId,status)
            if(listModel.get(j).uid == uid) {
                listModel.get(j).userOnline = status.toString();
                listModel.get(j).isVideo = status.toString();
                break;
            }
        }
    }

    function addUserInfo(userId){
        var isAdd = true;
        for(var i = 0; i < listModel.count; i++){
            if(listModel.get(i).userId == userId){
                isAdd = false;
                break;
            }
        }
        if(isAdd){
            var userName = curriculumData.getUserName(userId);
            var userOnline = curriculumData.justUserOnline(userId);
            var userAuth = curriculumData.getUserIdBrushPermissions(userId);
            var isVideo = curriculumData.getIsVideo();
            var userAudio = curriculumData.getUserPhone(userId);
            var userVideo = curriculumData.getUserCamcera(userId);
            var imagePath = curriculumData.getUserUrl(userId);
            var isteacher = curriculumData.isTeacher(userId);
            var supplier = curriculumData.getUserChanncel();
            var volumes = "0";
            var headPicture = curriculumData.getUserPicture(userId);
            var userMute = 0;
            var trophyNumber = curriculumData.getRewardNum(userId);
            var uid = curriculumData.getUserUid(userId);
            var userUp = curriculumData.getUserUpStatus(userId);
            console.log("=====addUserInfo====",isteacher,trophyNumber,userId,userOnline,isVideo,userUp,userAuth,userAudio,userVideo,headPicture);
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
                            "trophyNumber":trophyNumber,
                        });
        }
    }


    MouseArea{
        anchors.fill: parent
        z:1
        onClicked: {
            videoToolBackground.focus = true;
        }
    }

    Component.onCompleted: {
        if(loadDataStatus) {
            return;
        }
        loadDataStatus = true;
        curriculumData.getListAllUserId();
        totalLengthTime = curriculumData.courseTimeTotalLength;
        //courseNameId.text = curriculumData.curriculumId;
        courseNamea.text = curriculumData.curriculumName;
        timeProgressBarsTexts = curriculumData.startToEndTime;
        curriculumType = curriculumData.lessonType;
    }

    //修改网络图标
    function updateNetworkInfo(netType,delay,lossRate,cpuRate){
        qosApiMgr.networkQuality(lossRate,delay,curriculumData.getCurrentIp());
        networkControlView.updateNetValue(netType,delay,lossRate,cpuRate);
    }

    //开始上课重置所以学生状态
    function resetStatus(){
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == "0"){
                toolbarsView.disableButton = false;
                if(listModel.get(i).userAudio == "0"){
                    externalCallChanncel.closeAudio("1");
                }
                if(listModel.get(i).userVideo == "0"){
                    externalCallChanncel.closeVideo("1");
                }
            }
            listModel.get(i).trophyNumber = "0";
            listModel.get(i).isVideo = "1";
            listModel.get(i).userAudio = "1";
            listModel.get(i).userVideo = "1";
        }
    }
}

