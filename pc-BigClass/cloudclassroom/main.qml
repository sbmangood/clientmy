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
import ScreenshotSaveImage 1.0
import QtQuick.Dialogs 1.2

Window {
    id: mainview
    visible: true
    width: Screen.width
    height: Screen.height
    flags: Qt.Window | Qt.FramelessWindowHint
    title: qsTr("ClassRoom")
    color: "#30313D"

    //屏幕比例
    property double widthRate: fullWidths / 1440.0;
    property double heightRate: fullHeights / 900.0;

    property int coursewareType: 1;//默认老课件
    property bool isMainWhiteBoard: false;//当前是否为主白板
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

    property string coursewareIdValue: "";// 上传到API后得到的课件Id
    property var coursewareList: [];
    property string whiteBoardId: "0";
    property string courseWhiteBoardId: "1";
    property string pointerWhiteBoardId: "00001";
    property string saveBoardName: "";
    property int curBoardPage: 1;
    property bool bSaveCurBoardPage;
    property string filePathName;
    property int current_Polygons: 0;
    property bool isAddGraph: false;//是否添加图形
    property var bufferGraph: [];//缓存创建的几何图形
    property string currentUserId: userId;

    // 记录H5课件窗口位置和大小
    property var coursewareX: 0;
    property var coursewareY: 0;
    property var coursewareW: 640 * widthRate;
    property var coursewareH: 416 * heightRate;
    property string currentH5CoursewareId: ""// 当前H5课件Id
    property string preSucceedH5Url: "";// 上一次加载成功的H5课件url
    property var hisWindowInfo: "";// 历史窗口信息
    property bool isNewSelected: false;// 是否重新选择，非历史课件

    // 上课之前打开的课件Id
    property string prevH5Id: "";
    property string prevVideoId: "";
    property string prevAudioId: "";

    property bool isSelected: false;//是否选中态

    EnterRoomStatusView {
        id: enterRoomStatusView
        anchors.fill: parent
        z: 101

        onSigExitRoom: {
            toolbar.exitChannel();
            toolbar.exitClassRoom();
            toolbar.uninit();
            toolbar.uploadLog();
            Qt.quit();
        }
    }

    Timer{
        id: loadTime
        interval: 20000
        running: true
        repeat: false
        onTriggered: {
            console.log("load time Trigger", errStatus);
            if(errStatus != "")
            {
                enterRoomStatusView.notifyStateCode(errStatus);
            }
        }
    }

    //菜单栏
    YMHeadControlView{
        z: 100
        id: headView
        width: parent.width
        height: 50 * heightRate
        anchors.top: parent.top
        setUserRole : currentUserRole
        onSigDeviceCheck: {
            deviceSettingView.visible = true;
        }

        onSigTipFeedBack: {
            tipFeedview.visible = true;
        }

        onSigDownLesson: {
            if(isStartLesson){
                tipsView.showExitroom();
            }else{
                isStartLesson = true;
                toolbar.beginClass();

                // 开始上课，清空上课前打开的课件
                if(coursewareMainView.visible){
                    coursewareMainView.visible = false;
                    toolbar.coursewareWindowUpdate(prevH5Id, "close", (coursewareMainView.width / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.height / coursewareMainView.parent.height).toFixed(6) * 1000000,
                                                   (coursewareMainView.x / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.y / coursewareMainView.parent.height).toFixed(6) * 1000000);
                }
                if(background_audio.visible){
                    mediaPlayer_audio.setPlayVideoStatus(2);
                    background_audio.visible = false;
                    toolbar.coursewareWindowUpdate(prevAudioId, "close", (mediaPlayer_audio.width / mediaPlayer_audio.parent.width).toFixed(6) * 1000000, (mediaPlayer_audio.height / mediaPlayer_audio.parent.height).toFixed(6) * 1000000,
                                                   (mediaPlayer_audio.x / mediaPlayer_audio.parent.width).toFixed(6) * 1000000, (mediaPlayer_audio.y / mediaPlayer_audio.parent.height).toFixed(6) * 1000000);
                }
                if(background_video.visible){
                    mediaPlayer_video.setPlayVideoStatus(2);
                    background_video.visible = false;
                    toolbar.coursewareWindowUpdate(prevVideoId, "close", (mediaPlayer_video.width / mediaPlayer_video.parent.width).toFixed(6) * 1000000, (mediaPlayer_video.height / mediaPlayer_video.parent.height).toFixed(6) * 1000000,
                                                   (mediaPlayer_video.x / mediaPlayer_video.parent.width).toFixed(6) * 1000000, (mediaPlayer_video.y / mediaPlayer_video.parent.height).toFixed(6) * 1000000);
                }

                hasTeacher = true;
                tipsView.showStartLesson();
                headView.setLessonState(1); //开始上课
            }
        }

        onSigExit: {
            if(currentUserRole == 2 || currentUserRole == 1 || !isStartLesson){
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

        onSigIM: {
            if(true == interaction.visible)
            {
                interaction.visible = false;
            }
            else
            {
                interaction.visible = true;
            }

        }

    }

    YMLoadingView{//加载课件
        id: loadingView
        z: 100
        width: 182 * heightRate
        height: 140 * heightRate
        anchors.centerIn: parent
        visible: false
        onSigRefresh:{

        }
    }

    //设备检测
    YMDevicetesting{
        id: deviceSettingView
        z: 101
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
            if(getCurrentUserRole() != "tea" && isStartLesson == false){
                toolbar.exitChannel();
            }

            if(headView.lessonStatus == 1){
                toolbar.initVideoChancel();
                audiovideoview.updateUserState("0", "1");
                hasTeacher = true;
            }
        }
    }

    // 视频区域
    Item {
        id :audioVideoRect
        z: 91
        width: mainview.width
        height: 110 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 58 * heightRate

        AudioVideoView {
            id: audiovideoview
            anchors.fill: parent
            currentUserId: userId
        }
    }

    // 课件和小白板
    Item {
        z: 92
        id: background
        height:  (parent.width / 16) * 9 > parent.height - headView.height - audioVideoRect.height -  bottomToolbars.height ? parent.height - headView.height - audioVideoRect.height -  bottomToolbars.height :(parent.width / 16) *9
        width: (height / 9) * 16
        anchors.top: audioVideoRect.bottom
        anchors.topMargin: 10 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter

        Item{
            id: polygonItemView
            z: 1
            clip: true
            x: coursewareMainView.locationX
            y: coursewareMainView.locationY
            width: coursewareMainView.locationWidth
            height: coursewareMainView.locationHeight
            visible: coursewareMainView.visible
        }

        CoursewareMainView {
            id: coursewareMainView
            width: 640 * widthRate
            height: 416 * heightRate
            //myheight: mainview.height - audioVideoRect.height - headView.height - bottomToolbars.height + 26 * heightRate
            //mywidth: (height / 9) * 16
            currentUserType: currentUserRole
            isEnableDrag: true
            isEnableScale: false
            visible: false
            x: 0
            y: 0
            property double locationX: 0;
            property double locationY: 0;
            property double locationWidth: coursewareMainView.width;
            property double locationHeight: coursewareMainView.height;

            onXChanged: {
                polygonItemView.x = coursewareMainView.x + locationX;
            }
            onYChanged: {
                polygonItemView.y = coursewareMainView.y + locationY;
            }

            onSigCoursewareWindowInfo: {
                locationWidth = recWidth;
                locationHeight = recHeight;
                locationX = recX;
                locationY = recY;
                polygonItemView.x = coursewareMainView.x + locationX;
                polygonItemView.y = coursewareMainView.y + locationY;
            }

            onSigCMVStuCurrentPage: {
                if(coursewareMainView.visible){
                    clearBoardGraphBuffer(courseWhiteBoardId);
                    console.log("====onSigCMVStuCurrentPage====");
                }
            }

            onSigSelecteWhiteBoard: {
                if(isAddGraph == false){
                    return;
                }
                isMainWhiteBoard = false;
                if(isAddGraph && isUploadImage){
                    return;
                }
                var component = Qt.createComponent("qrc:/YMGraphicsView.qml")
                if(Component.Ready === component.status) {
                    var rectangeObj = component.createObject(coursewareMainView);
                    rectangeObj.width = widths;
                    rectangeObj.height = heights;
                    var dockId = currentUserRole == 0 ? courseWhiteBoardId : coursewareMainView.h5coursewareId;
                    var pageId = coursewareMainView.currentPage;
                    var itemId = userId + Date.parse(new Date()).toString();
                    rectangeObj.y = topMaginValue;
                    rectangeObj.x = leftMaginValue;
                    rectangeObj.dockId = dockId;
                    rectangeObj.pageId = pageId;
                    rectangeObj.boardId = courseWhiteBoardId;
                    rectangeObj.itemId = itemId;
                    rectangeObj.setDrawPolygon(current_Polygons);
                    rectangeObj.visible = true;
                    rectangeObj.z = 91;
                    rectangeObj.sigGraphicsData.connect(sendGraphicMsg);
                    isAddGraph = false;
                }
            }

            onSigCMVUserAuth: {
                currentUserRole = userRole;
            }

            onSigCMVJumpPages: {
                clearGraphBuffer();
                toolbar.goCourseWarePage(1, pages, totalPage);
            }

            onSigCMVRemoverPages: {// 暂无删除页了
                clearGraphBuffer();
                //toolbar.goCourseWarePage(3, currentPage, totalPage);
            }

            onSigCMVAddPages: {// 暂无增加页了
                clearGraphBuffer();
                //toolbar.goCourseWarePage(2, currentPage, totalPage);
            }

            onSigCMVGetOffsetImage: {
                curOffsetY = currentCourseOffsetY;
                toolbar.getOffsetImage(url, curOffsetY);
            }
            onSigCMVSendH5PlayAnimation: {
                toolbar.sendH5PlayAnimation(animationStepIndex);
            }
            onSigCMVSendH5ThumbnailPage: {// 点击缩略图、点击页面中间引起页面翻动都走这个信号传出页面值
                console.log("=====onSigCMVSendH5ThumbnailPage::pageIndex======",pageIndex, totalPage)
                if(pageIndex >= totalPage - 1){// 此处防止H5端通知的页索引值大于等于总页数，造成越界崩溃，点击事件触发H5端通知页索引
                    pageIndex = totalPage - 1;
                }
                toolbar.goCourseWarePage(1, pageIndex, totalPage);
            }

            onSigH5GetScrolls: {
                //console.log("=====onSigH5GetScrolls::scrollValue=",scrollValue);
                toolbar.updataScrollMap(scrollValue);
            }

            onSigCMVLoadsCoursewareSuccess: {
                preSucceedH5Url = currentUrl;
                loadingView.hideView();
            }
            onSigCMVIsCouserware: {
                setTips("课件无法删除")
            }
            onSigCMVTipPages: {
                if(message == "lastPage"){

                }
                if(message == "onePage"){

                }
            }

            onSigCMVVisualizeH5Courseware: {
                if(!isNewSelected){
                    console.log("==========hisWindowInfo",JSON.stringify(hisWindowInfo), currentH5CoursewareId);
                    var type = hisWindowInfo["type"];
                    var recWidth = hisWindowInfo["recWidth"];
                    var recHeight = hisWindowInfo["recHeight"];
                    var recX = hisWindowInfo["recX"];
                    var recY = hisWindowInfo["recY"];
                    var boardId = hisWindowInfo["boardId"];
                    if(currentH5CoursewareId == boardId && (type == "close" || type == "min")){
                        coursewareMainView.visible = false;
                        return;
                    }
                }

                coursewareMainView.visible = true;
                background_video.z = 91;
                background_audio.z = 91;
                background.z = 92;
            }

            onSigCMVCurrentCoursewareId: {
                var userInfoObj = toolbar.getUserInfo();
                var classroomId = userInfoObj["classroomId"];
                var apiUrl = userInfoObj["apiUrl"];
                var appId = userInfoObj["appId"];
                classInfoManager.getCloudDiskList(classroomId, apiUrl, appId, false);
                var coursewareListInfo = classInfoManager.getCoursewareListInfo();
                console.log("=================coursewareListInfo=",JSON.stringify(coursewareListInfo));
                for(var i = 0; i < coursewareListInfo.length; i++){
                    if(coursewareListInfo[i].id == coursewareId){
                        var filename = coursewareListInfo[i].name;
                        console.log("==============filename=",filename,coursewareId);
                        coursewareMainView.coursewareName = filename;
                        break;
                    }
                }
            }

            onSigCMVChangeWindow: {
                currentH5CoursewareId = courseId;
                console.log("====onSigCMVChangeWindow====",type);
                if(type == "max"){
                    //console.log("=====max=======");
                    clearBoardGraphBuffer(courseId);
                    coursewareMainView.x = 0;
                    coursewareMainView.y = 0;
                    var heights = coursewareMainView.parent.height - 54 * heightRate;
                    var widths = coursewareMainView.parent.width;
                    polygonItemView.height = heights;
                    polygonItemView.width = widths > heights / 9 * 16 ? heights / 9  * 16 : widths;
                    polygonItemView.x = (widths - polygonItemView.width) / 2;
                    polygonItemView.y = 26 * heightRate;
                    coursewareMainView.height = coursewareMainView.parent.height;
                    coursewareMainView.width = coursewareMainView.parent.width;
                    toolbar.coursewareWindowUpdate(courseId, type, (coursewareMainView.width / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.height / coursewareMainView.parent.height).toFixed(6) * 1000000,
                                                   (coursewareMainView.x / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.y / coursewareMainView.parent.height).toFixed(6) * 1000000);
                    bottomToolbars.visible = false;// 课件全屏时隐藏底部bar
                    return;
                }
                else if(type == "recover"){
                    //console.log("=====recover=======");
                    clearBoardGraphBuffer(courseId);
                    var r_heights = coursewareH - 54 * heightRate;
                    var r_widths = coursewareW;
                    polygonItemView.width = r_widths > r_heights / 9 * 16 ? r_heights / 9  * 16 : r_widths;;
                    polygonItemView.height = r_heights;
                    polygonItemView.x = (r_widths - polygonItemView.width) / 2;
                    polygonItemView.y = 26 * heightRate;
                    //console.log("====recover=====",coursewareW,coursewareH,(r_widths - polygonItemView.width) / 2,26 * heightRate);
                    coursewareMainView.x = coursewareX;
                    coursewareMainView.y = coursewareY;
                    coursewareMainView.width = coursewareW;
                    coursewareMainView.height = coursewareH;
                }
                else if(type == "move"){
                    if(coursewareMainView.width < coursewareMainView.parent.width){
                        coursewareW = coursewareMainView.width;
                    }
                    if(coursewareMainView.height < coursewareMainView.parent.height){
                        coursewareH = coursewareMainView.height;
                    }
                    coursewareX = coursewareMainView.x;
                    coursewareY = coursewareMainView.y;
                    coursewareMainView.visible = true;
                }
                else if(type == "min"){
                    toolbar.coursewareWindowUpdate(courseId, type, (coursewareMainView.width / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.height / coursewareMainView.parent.height).toFixed(6) * 1000000,
                                                   (coursewareMainView.x / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.y / coursewareMainView.parent.height).toFixed(6) * 1000000);
                    coursewareMainView.visible = false;
                    min_background.visible = true;
                    bottomToolbars.visible = true;
                    return;
                }
                else if(type == "close"){
                    coursewareMainView.visible = false;
                }
                if(type == "recover"){
                    type = "move";
                    coursewareMainView.visible = true;
                }
                toolbar.coursewareWindowUpdate(courseId, type, (coursewareMainView.width / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.height / coursewareMainView.parent.height).toFixed(6) * 1000000 ,
                                               (coursewareMainView.x / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.y / coursewareMainView.parent.height).toFixed(6) * 1000000);
                bottomToolbars.visible = true;
            }

            onSigCMVWindowUpdates: {
                //console.log("==========onSigCMVWindowUpdates::windowUpdateInfos=======",JSON.stringify(windowUpdateInfos));
                if(!isNewSelected){
                    hisWindowInfo = windowUpdateInfos;
                }
                var type = windowUpdateInfos["type"];
                var recWidth = windowUpdateInfos["recWidth"];
                var recHeight = windowUpdateInfos["recHeight"];
                var recX = windowUpdateInfos["recX"];
                var recY = windowUpdateInfos["recY"];
                var boardId = windowUpdateInfos["boardId"];

                var heights = recHeight * coursewareMainView.parent.height / 1000000 - 54 * heightRate;
                var widths = recWidth * coursewareMainView.parent.width / 1000000;
                polygonItemView.height = heights;
                polygonItemView.width = widths > heights / 9 * 16 ? heights / 9  * 16 : widths;
                polygonItemView.x = (widths - polygonItemView.width) / 2;
                polygonItemView.y = 26 * heightRate;
                locationY = 26 * heightRate;
                locationX =  (widths - polygonItemView.width) / 2;
                var docType = getCoursewareTypeById(boardId);
                console.log("==========docType==",docType);
                //console.log("=======type=", type, recWidth, recHeight, recX, recY);
                //console.log("====onSigCMVWindowUpdates===", recWidth * coursewareMainView.parent.height / 1000000, recHeight * coursewareMainView.parent.height / 1000000, recX * coursewareMainView.parent.width / 1000000, recY * coursewareMainView.parent.height / 1000000)
                if(docType.indexOf("pdf") != -1 || docType.indexOf("ppt") != -1 || docType.indexOf("doc") != -1 || docType.indexOf("h5") != -1){
                    if(type == "close" || type == "min"){
                        coursewareMainView.visible = false;
                        if(type == "min" && getCurrentUserRole() == "tea")
                        {
                            min_background.visible = true;
                        }
                        if(type == "close"){
                            clearBoardGraphBuffer(boardId);
                        }
                    }
                    else {
                        coursewareMainView.visible = true;
                    }
                    coursewareMainView.x = 0;
                    coursewareMainView.y = 0;
                    coursewareMainView.x = recX * coursewareMainView.parent.width / 1000000;
                    coursewareMainView.y = recY * coursewareMainView.parent.height / 1000000;
                    coursewareMainView.width = recWidth * coursewareMainView.parent.width / 1000000;
                    coursewareMainView.height = recHeight * coursewareMainView.parent.height / 1000000;
                }
                else if(docType.indexOf("mp3") != -1  || docType.indexOf("wma") != -1 || docType.indexOf("wav") != -1){
                    background_video.visible = false;
                    mediaPlayer_video.setPlayVideoStatus(2);
                    if(type == "close"){
                        background_audio.visible = false;
                        mediaPlayer_audio.setPlayVideoStatus(2);
                    }
                    else {
                        background_audio.visible = true;
                    }
                    mediaPlayer_audio.width = recWidth * mediaPlayer_audio.parent.width / 1000000;
                    mediaPlayer_audio.height = recHeight * mediaPlayer_audio.parent.height / 1000000;
                    mediaPlayer_audio.x = recX * mediaPlayer_audio.parent.width / 1000000;
                    mediaPlayer_audio.y = recY * mediaPlayer_audio.parent.height / 1000000;
                }
                else if(docType.indexOf("mp4") != -1 || docType.indexOf("avi") != -1 || docType.indexOf("wmv") != -1 || docType.indexOf("rmvb") != -1){
                    background_audio.visible = false;
                    mediaPlayer_audio.setPlayVideoStatus(2);
                    if(type == "close"){
                        background_video.visible = false;
                        mediaPlayer_video.setPlayVideoStatus(2);
                    }
                    else {
                        background_video.visible = true;
                    }
                    mediaPlayer_video.width = recWidth * mediaPlayer_video.parent.width / 1000000;
                    mediaPlayer_video.height = recHeight * mediaPlayer_video.parent.height / 1000000;
                    mediaPlayer_video.x = recX * mediaPlayer_video.parent.width / 1000000;
                    mediaPlayer_video.y = recY * mediaPlayer_video.parent.height / 1000000;
                }
            }
        }

        // 课件最小化后左下角图标
        Item {
            id: min_background
            width: 78 * widthRate
            height: 78 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 30 * widthRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24 * heightRate
            visible: false
            Image {
                id: backImg
                source: "qrc:/cvimages/btn_pop_wjsx_pressed.png"
                anchors.fill: parent
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    toolbar.coursewareWindowUpdate(currentH5CoursewareId, "move", (coursewareMainView.width / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.height / coursewareMainView.parent.height).toFixed(6) * 1000000 ,
                                                   (coursewareMainView.x / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.y / coursewareMainView.parent.height).toFixed(6) * 1000000);
                    coursewareMainView.visible = true;
                    min_background.visible = false;
                }
                onEntered: {
                    backImg.source = "qrc:/cvimages/btn_pop_wjsx_focused.png";
                }
                onExited: {
                    backImg.source = "qrc:/cvimages/btn_pop_wjsx_pressed.png";
                }
            }
        }
    }

    // 主白板
    Rectangle {
        z: 90
        id: background1
        height:  (parent.width / 16) * 9 > parent.height - headView.height - audioVideoRect.height -  bottomToolbars.height ? parent.height - headView.height - audioVideoRect.height -  bottomToolbars.height :(parent.width / 16) *9
        width: (height / 9) * 16
        anchors.top: audioVideoRect.bottom
        anchors.topMargin: 10 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#282935"

        // 白板区域
        WhiteBoard0 {
            id:whiteBoard
            z: 92
            clip: true
            anchors.fill: parent
            smooth: true
            visible: true
            enabled: true
            onSigUserAuth: {
                currentUserRole = userRole;
            }
            onSigMouseReleases: {
                if(isAddGraph == false){
                    return;
                }
                isMainWhiteBoard = true;
                if(isAddGraph && isUploadImage){
                    return;
                }

                var component = Qt.createComponent("qrc:/YMGraphicsView.qml")
                if(Component.Ready === component.status) {
                    var rectangeObj = component.createObject(background1);
                    rectangeObj.width = background1.width;
                    rectangeObj.height = background1.height;
                    var pageId = bottomToolbars.currentPage;
                    var itemId = userId + Date.parse(new Date()).toString();
                    rectangeObj.dockId = "0";
                    rectangeObj.pageId = pageId;
                    rectangeObj.boardId = "0";
                    rectangeObj.itemId = itemId;
                    rectangeObj.setDrawPolygon(current_Polygons);
                    rectangeObj.visible = true;
                    rectangeObj.z = 92;
                    rectangeObj.sigGraphicsData.connect(sendGraphicMsg);
                    isAddGraph = false;
                }
            }
        }

    }

    // 数据类
    CurriculumData {
        id:curriculumData
        onSigListAllUserId: {
            // 声网SDK不回调自己加入频道状态，需从此处加入状态显示
            var dataObject = curriculumData.getUserInfo(list[0]);
            var userId = list[0];
            var userInfoObj = toolbar.getUserInfo();
            var nickName = userInfoObj["nickName"];
            var userRole = userInfoObj["userRole"];
            var isteacher = "0";
            if(userRole == 0){
                isteacher = "1";
            }
            else {
                isteacher = "0";
            }
            dataObject["isteacher"] = isteacher;
            if(userRole == 0){
                dataObject["userOnline"] = "0";// 点击开始上课之前,userOnline="0"
            }
            else{
                if(!hasTeacher){
                    dataObject["userOnline"] = "0";
                }
                else {
                    dataObject["userOnline"] = "1";
                }
            }
            dataObject["userName"] = nickName;
            console.log("===dataObject===",JSON.stringify(dataObject))
            audiovideoview.addSelfBaseInfo(userId, dataObject);
        }
    }

    //底部工具栏
    BottomToolbars {
        id: bottomToolbars
        z: 92
        visible: currentUserRole == 0 ? true : false
        width: mainview.width
        height: userRole == 0 ? 50 * widthRate : 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        //跳转页面
        onSigJumpPage: {
            //            toolbar.goCourseWarePage(1, pages, bottomToolbars.totalPage);
            //            if(getCurrentUserRole() == "tea" && isPrevOrNext){
            //                return;
            //            }
            //            console.log("=====onSigJumpPage====",pages)
            //            ymcourseware.coursewareOperation(3, 4, pages,0);
        }
        // 上一页
        onSigPrePage: {
            clearBoardGraphBuffer(whiteBoardId);
            toolbar.goWhiteBoardPage(1,bottomToolbars.currentPage-1,bottomToolbars.totalPage,whiteBoardId);
        }
        // 下一页
        onSigNext: {
            console.log("======onSigNextPage::aa====");
            clearBoardGraphBuffer(whiteBoardId);
            toolbar.goWhiteBoardPage(1,bottomToolbars.currentPage+1,bottomToolbars.totalPage,whiteBoardId);

        }
        //增加页
        onSigAddPage: {
            clearBoardGraphBuffer(whiteBoardId);
            toolbar.goWhiteBoardPage(2,bottomToolbars.currentPage,bottomToolbars.totalPage+1 ,whiteBoardId);
        }
        //删除页
        onSigRemoverPage: {
            if(bottomToolbars.totalPage <= 1)
            {
                return;
            }
            clearBoardGraphBuffer(whiteBoardId);
            toolbar.goWhiteBoardPage(3, bottomToolbars.currentPag-1,bottomToolbars.totalPage-1, whiteBoardId);
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
            Qt.quit();
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
        x: parent.width - width
        y: (parent.height - height) * 0.5

        ToolBar {
            id: toolbar

            onSigLoadClassComplete: {
                console.log("===onSigLoadClassComplete=====", errStatus);
                loadTime.stop();
                if(errStatus == "")
                {
                    enterRoomStatusView.visible = false;
                }
                else
                {
                    enterRoomStatusView.notifyStateCode(errStatus);
                }


            }

            onSigDeleteItem: {
                console.log("===onSigDeleteItem=====",boardId,itemId)
                if(itemId == ""){
                    clearGraphBuffer();
                }else{
                    deletePolyon(itemId);
                }
            }

            onSigUserAuth: {
                console.log("====onSigUserAuth====",userId,trail);
                var userIds = userId == currentUserId ? 0 : userId;
                audiovideoview.sysnUserAuthorize(userIds,up,trail,audio,video,isSynStatus);
                if(userRole === 1 && currentUserId == userId){
                    toolbarsView.visible = (trail == 0 ? false : true);
                    resetBoardStatus();
                }
            }

            onSigDrawGraph: {
                console.log("===onSigDrawGraph===",JSON.stringify(graphObjData),graphObjData.url);
                if(graphObjData === {} || graphObjData === []){
                    return;
                }

                var type = 0;
                if(graphObjData.type == "ellipse"){
                    type = 1;
                }
                if(graphObjData.type == "polygon"){
                    if(graphObjData.pts.length == 4){
                        type = 2;
                    }
                    if(graphObjData.pts.length == 6){
                        type = 3;
                    }
                    if(graphObjData.pts.length == 8){
                        type = 4;
                    }
                }
                if(graphObjData.url !== undefined){
                    type = 5;
                    isMainWhiteBoard = true;
                }
                console.log("=====typetype5=======",type,isMainWhiteBoard);
                isMainWhiteBoard = graphObjData.boardId == "0" ? true : false;
                analysisGraphicsData(graphObjData,type);
            }

            onSigCurrentCoursewareId: {
                courseWhiteBoardId = currentCoursewareId;
                coursewareMainView.setWhiteBoardId(courseWhiteBoardId);
                currentH5CoursewareId = currentCoursewareId;
                clearBoardGraphBuffer(currentCoursewareId);
                console.log("==========onSigCurrentCoursewareId===========",currentCoursewareId)
            }

            onSigWhiteBoardPages: {
                bottomToolbars.currentPage = curPage + 1;
                bottomToolbars.totalPage = totalPage;
                clearBoardGraphBuffer(id);
            }

            onSigKickOutClassroom: {
                kickOutView.visible = true;
            }

            onSigPlayAv: {
                if(getCurrentUserRole() == "tea"){
                    return;
                }
                console.log("===onSigPlayAv===",JSON.stringify(avData));
                if(currentUserRole == 0){
                    return;
                }
                var suffix = avData.suffix.toLowerCase();;
                var path = avData.path;
                var fileName = avData.docName;
                var startTime = avData.playTimeSec
                var flagState = avData.flagState;
                if(suffix == "mp3" || suffix == "wma" || suffix == "wav"){
                    mediaPlayer_video.setPlayVideoStatus(2);
                    background_video.visible = false;
                    if(flagState == 1 || flagState == 2){
                        mediaPlayer_audio.setPlayVideoStatus(flagState);
                        background_audio.visible =flagState == 1 ? true : false;
                        return;
                    }
                    background.z = 92;
                    mediaPlayer_video.z = 91;
                    mediaPlayer_audio.z = 93;
                    mediaPlayer_audio.ymVideoPlayerManagerPlayFielByFileUrl(path,fileName,startTime,"",path)
                    mediaPlayer_audio.visible = true;
                }
                else if(suffix == "mp4" || suffix == "avi" || suffix == "wmv" || suffix == "rmvb"){
                    mediaPlayer_audio.setPlayVideoStatus(2);
                    background_audio.visible = false;
                    if(flagState == 1 || flagState == 2){
                        mediaPlayer_video.setPlayVideoStatus(flagState);
                        background_video.visible =flagState == 1 ? true : false;
                        return;
                    }
                    background.z = 92;
                    mediaPlayer_audio.z = 91;
                    background_video.z = 93;
                    mediaPlayer_video.ymVideoPlayerManagerPlayFielByFileUrl(path,fileName,startTime,"",path)
                    background_video.visible = true;
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
                bottomToolbars.totalPage = 1;
                bottomToolbars.currentPage = 1;
                tipsView.showClearScreen();
                clearGraphBuffer();
            }
            onSigClearTrails:{
                console.log("====onSigClearTrails====",boardId)
                clearBoardGraphBuffer(boardId);
            }

            onSigExitClassroom:{
                toolbar.exitChannel();
                console.log("==onSigExitClassroom==");
            }

            onSigPromptInterface: {
                if(interfaces == "opencarm"){
                    toolbar.initVideoChancel();
                    audiovideoview.updateUserState("0", "1");
                }
            }
            onSigJoinroom: {//音视频进入
                console.log("===onSigJoinroom===",uid, status, getUserType(uid))
                var currentRole = getCurrentUserRole();
                var uType = getUserType(uid);
                var nickname = getUserName(uid);
                if(status == 1){
                    console.log("===========uType=", uType);
                    var  userAllAuth = audiovideoview.getCurrentUserAllAuth(uid);
                    var userIds = userRole == 1 ? 0 : uid;
                    var userAuths = audiovideoview.getUserAuth(userIds);
                    if(uType == "TEA"){
                        isStartLesson = true;
                        if(currentRole == "assistant" || currentRole == "stu"){
                            headView.setLessonState(1); //开始上课
                            var dataObject = {};
                            dataObject["userName"] = nickname;
                            dataObject["userOnline"] = "1";
                            dataObject["userAuth"] = userAllAuth === undefined ? "0" : userAllAuth.trail;
                            dataObject["isVideo"] = "1";
                            dataObject["userAudio"] = userAllAuth === undefined ? "1" : userAllAuth.audio;
                            dataObject["userVideo"] = userAllAuth === undefined ? "1" : userAllAuth.video;
                            dataObject["imagePath"] = "";
                            dataObject["isteacher"] = "1";
                            dataObject["supplier"] = "1";
                            dataObject["headPicture"] = "";
                            dataObject["userMute"] = "0";
                            dataObject["uid"] =  uid;
                            dataObject["userUp"] = userAllAuth === undefined ? "1" :userAllAuth.up;
                            dataObject["rewardNum"] = getRewardNum(uid);
                            console.log("=======onSigJoinClassroom::assistant::TEA=", userId, JSON.stringify(dataObject))
                            audiovideoview.addSelfBaseInfo(userId, dataObject);
                            hasTeacher = true;
                            audiovideoview.updateUserState("0", "1");
                        }
                    }
                    else{
                        var dataObjectstu = {};
                        dataObjectstu["userName"] = nickname;
                        dataObjectstu["userOnline"] = "1";
                        dataObjectstu["userAuth"] = userAllAuth === undefined ? "0" : userAllAuth.trail;
                        dataObjectstu["isVideo"] = "1";
                        dataObjectstu["userAudio"] = userAllAuth === undefined ? "1" : userAllAuth.audio;
                        dataObjectstu["userVideo"] = userAllAuth === undefined ? "1" : userAllAuth.video;
                        dataObjectstu["imagePath"] = "";
                        dataObjectstu["isteacher"] = "0";
                        dataObjectstu["supplier"] = "1";
                        dataObjectstu["headPicture"] = "";
                        dataObjectstu["userMute"] = "0";
                        dataObjectstu["uid"] =  uid;
                        dataObjectstu["userUp"] = userAllAuth === undefined ? "1" :userAllAuth.up;
                        dataObjectstu["rewardNum"] = getRewardNum(uid);
                        console.log("=======onSigJoinClassroom::STU=", userId, JSON.stringify(dataObjectstu))
                        audiovideoview.addSelfBaseInfo(userId, dataObjectstu);
                        //audiovideoview.updateUserState(userId, "1", nickname == "unknown" ? userId : nickname);
                    }
                    if(userRole === 1 ){
                        toolbarsView.visible = (userAuths == 0 ? false : true);
                        resetBoardStatus();
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
                        //                        tipsView.showTealevaImg();
                    }
                    else {
                        audiovideoview.updateUserState(userId, "0");
                    }
                }
            }
            onSigAudioVolumeIndication: {
                audiovideoview.updateVolume(totalVolume.toString(),uid);
                //console.log("=======onSigAudioVolumeIndication===",uid,totalVolume)
            }

            onSigJoinClassroom: {
                console.log("======onSigJoinClassroom=", userId, userType, teaNickName,JSON.stringify(extraInfoObj));
                infoModel.append({"videoId" : extraInfoObj.videoId, "userType" : userType, "userName" : extraInfoObj.userName})
                var currentRole = getCurrentUserRole();
                console.log("=====currentRole===", currentRole,extraInfoObj.userName)

                if(userType == "STU"){
                    interaction.addStuData(userId, extraInfoObj);
                    audiovideoview.updateUserState(userId, "1");
                }
                else if(userType == "TEA"){
                    if(currentRole == "assistant" || currentRole == "stu"){
                        //toolbar.initVideoChancel();
                        audiovideoview.updateUserState(userId, "1");
                    }
                }
            }

            onSigLeaveClassroom: {
                console.log("=====onSigLeaveClassroom======",userId);
                interaction.delStuData(userId);
                if(userType == "TEA" && currentUserRole  != 0){
                    tipsView.showTealevaImg();
                    isStartLesson = false;
                    toolbarsView.visible = false;
                    resetBoardStatus();
                }
                audiovideoview.updateUserState(userId, "0");
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
                    //audioviewviewstu.updateUserState("0", "1", nickName)
                    //audioviewviewstu.visible = true;
                    isUpStage = true;
                }
                else if(type == "forceDown" || type == "refused"){
                    toolbar.setUserRole(2);
                    //audioviewviewstu.updateUserState("0", "0", nickName)
                    //audioviewviewstu.visible = false;
                    isUpStage = false;
                    hasUp = false;
                }
            }

            onSigCurrentImageHeight: {
                currentImageHeight = imageHeight;
                //scrollbar.visible = false;
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
                }
            }

        }

        onSigSendFunctionKey: {
            resetBoardStatus();
            switch(keys)
            {
            case 0 :// 鼠标样式
                toolbar.selectShape(0, whiteBoardId);
                toolbar.selectShape(0, courseWhiteBoardId);
                whiteBoard.enabled = false;
                coursewareMainView.setEnableWhiteBoard(false);
                break;
            case 1: // 画笔
                toolbar.selectShape(1, whiteBoardId);
                toolbar.selectShape(1, courseWhiteBoardId);

                if(brushWidget.focus == true)
                {
                    brushWidget.focus = false;
                }
                else
                {
                    brushWidget.focus = true;
                }

                whiteBoard.enabled = true;
                coursewareMainView.setEnableWhiteBoard(true);
                break;
            case 4:  // 橡皮擦
                toolbar.selectShape(2, whiteBoardId);
                toolbar.selectShape(2, courseWhiteBoardId);
                coursewareMainView.setEnableWhiteBoard(true);

                if(eraserWidget.focus == true)
                {
                    eraserWidget.focus = false;
                }
                else
                {
                    eraserWidget.focus = true;
                }
                whiteBoard.enabled = true;
                break;
            case 5: // 教鞭
                toolbar.selectShape(4, pointerWhiteBoardId);
                pointerWhiteBoard.enabled = true;
                whiteBoard.enabled = true;
                coursewareMainView.setEnableWhiteBoard(true);
                break;
            case 6:   // 云盘(课件)
                var userInfoObj = toolbar.getUserInfo();
                var classroomId = userInfoObj["classroomId"];
                var apiUrl = userInfoObj["apiUrl"];
                var appId = userInfoObj["appId"];
                console.log("=====classroomId===",classroomId, apiUrl)
                classInfoManager.getCloudDiskList(classroomId, apiUrl, appId)
                if(diskMainView.focus == true)
                {
                    diskMainView.focus = false;
                    diskMainView.visible = false;
                }
                else
                {
                    diskMainView.focus = true;
                    diskMainView.visible = true;
                }
                whiteBoard.enabled = true;
                coursewareMainView.setEnableWhiteBoard(true);
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
            case 12://几何
                whiteBoard.enabled = false;
                coursewareMainView.setEnableWhiteBoard(false);
                if(graphicWidget.focus == true){
                    graphicWidget.focus = false;
                }
                else {
                    graphicWidget.focus = true;
                }
                break;
            case 14://保存板书
                saveBoardsView.visible = true;
                toolbarsView.enabled = false;
                bottomToolbars.enabled = false;
                break;
            case 13://选中
                updateGraphStatus(true);
                toolbar.selectShape(9, whiteBoardId);
                toolbar.selectShape(9, courseWhiteBoardId);
                isSelected = true;
                break;
            case 15://上传图片
                fileDialog.open();
                break;
            case 16:    //工具箱
                if(toolBoxView.focus == true)
                {
                    toolBoxView.focus = false;
                }
                else
                {
                    toolBoxView.focus = true;
                }
                break;
            default:
                break;
            }
        }
    }

    //问题反馈页面
    TipFeedbackView{
        id: tipFeedview
        z: 101
        visible: false
        anchors.centerIn : parent

        onSigFeedbackInfo: {
             toolbar.addFeedbackInfo(feedbackTest, "", className, teaNickName, roomId , userRole);
            console.log("==feedbackTest==",feedbackTest)

            tipFeedToast.visible = true;
            tipFeedToastTime.restart();

        }
    }

    Rectangle{
        id:tipFeedToast
        z: 100
        visible: false
        color: "#000000"
        width: 180 * heightRate
        height: 38 *heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: background1.top
//        anchors.topMargin: 40 * heightRate
        radius: 4 * heightRate

        Text {
            text: "问题已上报"
            color: "#FFFFFF"
            anchors.centerIn: parent
            font.family: "Microsoft YaHei"
            font.pixelSize: 18 * heightRate
        }
    }

    Timer {
        id: tipFeedToastTime
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            tipFeedToast.visible = false;
        }
    }

    //几何界面
    GraphicWidget{
        id:graphicWidget
        anchors.right: parent.right
        anchors.rightMargin: 60 * heightRate
        anchors.top:  parent.top
        anchors.topMargin: userRole == 0 ? (parent.height - toolbarsView.height) * 0.5 + 155 * heightRate : (parent.height - toolbarsView.height) * 0.5 + 46 * heightRate
        width: 252 * heightRate
        height: 52  * heightRate
        z: 94
        visible: false
        focus: false
        onFocusChanged: {
            if(focus) {
                graphicWidget.visible = true;
            }else {
                graphicWidget.visible = false;
                updateSeleted(0);
            }
        }
        onSigPolygon: {
            var shape;
            if(polygons == 1){//圆
                shape = 8;
            }
            if(polygons == 2){//线
                shape = 7;
            }
            if(polygons == 3){//三角形
                shape = 5;
            }
            if(polygons == 4){//矩形
                shape = 6;
            }
            toolbar.selectShape(shape, whiteBoardId);
            toolbar.selectShape(shape, courseWhiteBoardId);
            whiteBoard.enabled = true;
            coursewareMainView.setEnableWhiteBoard(true);
            current_Polygons = polygons;
            isAddGraph = true;
            //trailBoardBackground.setDrawPolygon(polygons);
        }
    }

    //选取文件
    FileDialog {
        id: fileDialog
        title: "选择图片"
        folder: shortcuts.home
        selectFolder: false
        selectMultiple: false
        modality: Qt.WindowModal
        nameFilters: [ "Image files (*.jpg *.png)" ,"All(*.*)"]
        onAccepted: {
            var selectfiles = fileDialog.fileUrl.toString();
            if(selectfiles.length > 0) {
                isUploadImage = true;
                setTips("正在上传图片,请稍候...")
                var fileUrl = selectfiles.replace("file:///","");
                var dockId = "0"
                var userInfoObj = toolbar.getUserInfo();
                var token = userInfoObj["appKey"];
                var enType = userInfoObj["envType"];
                var upFileMark = new Date().getTime().toString();
                uploadFileManager.upLoadFileToServer(upFileMark,fileUrl,dockId,userId,token,enType);
            }
        }
    }

    property var arrayX: [];
    property var arrayY: [];

    function sendGraphicMsg(graphicData,type){
        toolbar.sendDrawGraph(graphicData);
        toolbar.selectShape(0, whiteBoardId);
        toolbar.selectShape(0, courseWhiteBoardId);
    }

    function analysisGraphicsData(graphicData,type){
        var component;
        if(type == 5){
            component = Qt.createComponent("qrc:/YMUploadImageView.qml");
        }else{
            component = Qt.createComponent("RectangeView.qml");
        }
        if(Component.Ready === component.status){
            var x1 = 0,x2 = 0,x3 = 0,x4 = 0;
            var y1 = 0,y2 = 0,y3 = 0,y4 = 0;
            var rundRotation = 0,rundWidth = 0,rundHeight = 0,rundCenterX = 0,rundCenterY = 0;
            var maxX  = 0,minX = 0,maxY = 0,minY = 0;
            var locationX = 0,locationY = 0;
            var maxWidht = 0,maxHeight = 0;
            var factor = 1000000;
            if(type === 1){
                var rundData = graphicData;
                var widhts = rundData.rectWidth / factor * (isMainWhiteBoard ? background1.width : polygonItemView.width);
                var heights = rundData.rectHeight / factor * (isMainWhiteBoard ? background1.height : polygonItemView.height);
                locationX = rundData.rectX / factor * (isMainWhiteBoard ? background1.width : polygonItemView.width);
                locationY = rundData.rectY / factor * (isMainWhiteBoard ? background1.height : polygonItemView.height);
                rundRotation = rundData.angle;

                rundWidth = widhts;
                rundHeight = heights;
                rundCenterX = locationX + widhts / 2;
                rundCenterY = locationY + heights / 2;
                maxWidht = widhts;
                maxHeight = heights;
            }else if(type === 5){
                var imageObj = graphicData;
                var widht = imageObj.w / factor * (isMainWhiteBoard ? background1.width : polygonItemView.width);
                var height = imageObj.h / factor * (isMainWhiteBoard ? background1.height : polygonItemView.height);
                maxWidht = widht;
                maxHeight = height;
                locationX = imageObj.recX / factor * (isMainWhiteBoard ? background1.width : polygonItemView.width);
                locationY = imageObj.recY / factor * (isMainWhiteBoard ? background1.height : polygonItemView.height);
            }else{
                analysisPolygonData(graphicData);
                maxX = getMaxValue(arrayX);
                minX = getMinValue(arrayX)

                maxY = getMaxValue(arrayY);
                minY = getMinValue(arrayY)

                maxWidht = (maxX - minX) * (isMainWhiteBoard ? background1.width : polygonItemView.width);
                maxHeight = (maxY -minY) * (isMainWhiteBoard ? background1.height : polygonItemView.height);
                locationX = minX * (isMainWhiteBoard ? background1.width : polygonItemView.width);
                locationY = minY * (isMainWhiteBoard ? background1.height : polygonItemView.height);

                x1 = arrayX[0] * (isMainWhiteBoard ? background1.width : polygonItemView.width);
                y1 = arrayY[0] * (isMainWhiteBoard ? background1.height : polygonItemView.height);

                x2 = arrayX[1] * (isMainWhiteBoard ? background1.width : polygonItemView.width);
                y2 = arrayY[1] * (isMainWhiteBoard ? background1.height : polygonItemView.height);

                x3 = arrayX[2] * (isMainWhiteBoard ? background1.width : polygonItemView.width);
                y3 = arrayY[2] * (isMainWhiteBoard ? background1.height : polygonItemView.height);

                x4 = arrayX[3] * (isMainWhiteBoard ? background1.width : polygonItemView.width);
                y4 = arrayY[3] * (isMainWhiteBoard ? background1.height : polygonItemView.height);

                x1 = x1 - locationX;
                y1 = y1 - locationY ;

                x2 = x2 - locationX ;
                y2 = y2 - locationY;

                x3 = x3 - locationX;
                y3 = y3 - locationY ;

                x4 = x4 - locationX;
                y4 = y4 - locationY;
            }
            var graphDataObj = graphicData;
            var dockId = graphDataObj.dockId;
            var boardId = graphDataObj.boardId;
            var itemId = graphDataObj.itemId;
            var pageId = graphDataObj.pageId;

            if(isDrawPolyon(itemId)){
                //console.log("=====isDrawPolyon=====",locationX,locationY);
                updateDrawLocation(itemId,locationX,locationY,maxWidht,maxHeight,type);
                return;
            }

            var object;
            if(isMainWhiteBoard){
                object = component.createObject(background1);
            }else{
                object = component.createObject(polygonItemView);
            }

            object.z = isSelected ? 93 : (isMainWhiteBoard ? 1 : 11);
            object.x = type == 2 ? (maxWidht <= 1 ? locationX - 3 : locationX) : locationX;
            object.y = type == 2 ? (maxHeight <= 1 ? locationY - 3 : locationY) : locationY;
            console.log("====maxWidht::maxWidht=====",maxWidht,maxHeight);
            object.width = type == 2 ? (maxWidht <= 1  ? maxWidht + 4 : maxWidht): maxWidht;
            object.height = type == 2 ?( maxHeight <= 1 ? maxHeight + 4 : maxHeight) : maxHeight;
            if(type === 5){
                object.imageSource = graphicData.url;
                object.boardId = boardId;
                object.itemId = itemId;
                object.sigOperating.connect(operatingDraw);
                object.sigMoveLocation.connect(sendMoveGraphLocation);
                addGraph(dockId,pageId,boardId,itemId,object);
                return;
            }
            object.rectangeType = type;
            object.x1 = x1; object.y1 = y1;
            object.x2 = x2; object.y2 = y2;
            object.x3 = x3 ; object.y3 = y3;
            object.x4 = x4 ; object.y4 = y4;

            object.rundRotation = rundRotation;
            object.rundWidth = rundWidth;
            object.rundHeight = rundHeight;
            object.rundCenterX =rundCenterX;
            object.rundCenterY =rundCenterY;
            object.boardId = boardId;
            object.itemId = itemId;
            object.sigOperating.connect(operatingDraw);
            object.sigMoveLocation.connect(sendMoveGraphLocation);
            addGraph(dockId,pageId,boardId,itemId,object);
        }
    }

    function getMaxValue(array){
        return  Math.max.apply(null,array);
    }

    function getMinValue(array){
        return  Math.min.apply(null,array);
    }

    function analysisPolygonData(dataModel){
        arrayX.splice(0,arrayX.length);
        arrayY.splice(0,arrayY.length);
        var sortArray = [];
        var arrayTrail = dataModel.pts;
        var count = arrayTrail.length;
        var factor = 1000000.0;
        for(var i = 0; i < count; ++i){
            var factorVal = arrayTrail[i];
            var x,y;
            if((i % 2) == 0){
                x = factorVal  / factor;
            }
            if((i % 2) == 1){
                y = factorVal  / factor;
                sortArray.push(
                            {
                                "x": x,
                                "y": y,
                            })
            }
        }

        for(var z = 0; z < sortArray.length; z++){
            arrayX.push(sortArray[z].x);
            arrayY.push(sortArray[z].y);
        }
    }

    NumberAnimation {//隐藏动画
        id: shrinkAnimation
        target: toolbarsView
        property: "x"
        duration: 600
        from: mainview.width - toolbarsView.width
        to: mainview.width
        easing.type: Easing.InOutQuad
        onStopped: {
            expandBtn.visible = true;
        }
    }

    NumberAnimation {//展开动画
        id: expandAnimation
        target: toolbarsView
        property: "x"
        duration: 600
        from: mainview.width
        to: mainview.width - toolbarsView.width
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
        anchors.right: parent.right
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
            source: parent.containsMouse ? "qrc:/classImage/but_menu_expand_focused.png" : "qrc:/classImage/but_menu_expand_normal.png"
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
        z: 95
        id: interaction
        width: 240 * widthRate
        height: parent.height - audioVideoRect.height - headView.height - bottomToolbars.height
        anchors.top: audioVideoRect.bottom
        //        anchors.topMargin: 2 * heightRate
        anchors.left: parent.left
        setUserRole: currentUserRole
        visible: false

        onSigProcessHandsUp: {
            if(getCurrentUserRole() != "tea"){
                return;
            }
            var userName = getUserName(uid);
            console.log("=====main.qml=onSigProcessHandsUp",uid,operation,userName)
            toolbar.processHandsUp(uid, 0, operation);
            //var userId = toolbar.getUserId(uid);
            if(operation == 1){// 强制上台
                //audioviewviewstu.updateUserState(uid, "1",userName);
                //audioviewviewstu.visible = true;
            }
            else if(operation == 2){// 强制下台
                //audioviewviewstu.updateUserState(uid, "0",userName);
            }
            else if(operation == 3){// 同意上台
                //audioviewviewstu.updateUserState(uid, "1",userName);
            }
            else if(operation == 4){// 拒绝上台
                //audioviewviewstu.updateUserState(uid, "0",userName);
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

    property var rewardArray: [];

    //奖杯管理类
    Trophy {
        id:trophy
        onSigDrawTrophy: {
            rewardView.visible = true;
        }
        onSigSyncTeaTrophy: {
            audiovideoview.synRewardNum(jsonArray);
            rewardArray = jsonArray;
            console.log("===onSigSyncHistoryTrophy==",JSON.stringify(jsonArray));
        }

        onSigSyncHistoryTrophy:{
            headView.tophyNum = historyPrize;
            var userIds = userId == currentUserId ? 0 : userId;
            console.log("===onSigSyncHistoryTrophy==",historyPrize,userId);
            audiovideoview.updateRewardNum(userIds,historyPrize);
        }

    }

    //画笔操作
    BrushWidget{
        id:brushWidget
        anchors.right: parent.right
        anchors.rightMargin: 58 * heightRate
        anchors.top:  parent.top
        anchors.topMargin: (parent.height - toolbarsView.height) * 0.5 + 20 * heightRate
        width: 200 * heightRate
        height: 220  * heightRate
        visible: false
        focus: false
        z: 94
        onFocusChanged: {
            if(brushWidget.focus) {
                brushWidget.visible = true;
            }else {
                brushWidget.visible = false;
            }
        }
        onSendPenColor: {
            toolbar.setPaintColor(penColors, whiteBoardId);
            toolbar.setPaintColor(penColors, courseWhiteBoardId);
            //                toobarWidget.handlBrushImageColor(penColors);
            //setBrushImage();
        }
        onSendPenWidth: {
            toolbar.setPaintSize(penWidths, whiteBoardId);
            toolbar.setPaintSize(penWidths, courseWhiteBoardId);
            //setBrushImage();
        }

    }

    //橡皮
    EraserWidget{
        id:eraserWidget
        anchors.right: parent.right
        anchors.rightMargin: 58 * heightRate
        anchors.top:  parent.top
        anchors.topMargin: (parent.height - toolbarsView.height) * 0.5 + 120 * heightRate
        width: 200 * heightRate
        height: 212  * heightRate
        z: 94
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
            toolbar.selectShape(types, whiteBoardId);
            toolbar.selectShape(types, courseWhiteBoardId);
            toolbar.setErasersSize(eraserWidget.eraserSize, whiteBoardId);
            toolbar.setErasersSize(eraserWidget.eraserSize, courseWhiteBoardId);
        }

        onSigClearsCreeon: {
            if(types == 0){
                eraserWidget.focus = false;
                toolbar.clearTrails(whiteBoardId);
            }
            else if(types == 1){
                if(coursewareMainView.visible == false){
                    return;
                }
                eraserWidget.focus = false;
                toolbar.clearTrails(courseWhiteBoardId);
            }else{
                toolbar.undoTrail(whiteBoardId);
                toolbar.undoTrail(courseWhiteBoardId);
            }
        }
    }

    // 文件上传
    UploadFileManager {
        id: uploadFileManager
        // 上传成功信号
        onSigUploadSuccess: {
            console.log("========upload success, fileUrl=", fileUrl, fileSize,upFileMark);
            var userInfoObj = toolbar.getUserInfo();
            var roomId = userInfoObj["classroomId"];
            var userId = userInfoObj["userId"];
            var apiUrl = userInfoObj["apiUrl"];
            var appId = userInfoObj["appId"];
            if(isUploadImage){
                var dockId ="0"
                var pageId = coursewareMainView.currentPage;
                var itemId = userId + Date.parse(new Date()).toString();
                var json1 = {
                    "boardId": "0",
                    "itemId": itemId,
                    "url": fileUrl,
                    "w": 0.40 * 1000000,
                    "h": 0.40 * 1000000,
                    "pageId": pageId,
                    "recX": 0.1 * 1000000,
                    "recY": 0.1 * 1000000,
                    "dockId":dockId,
                }
                toolbar.sendUploadImage(json1);
                isUploadImage = false;
                return;
            }

            //setTips("文件上传成功");
            classInfoManager.upLoadCourseware(upFileMark, roomId, userId, fileUrl, fileSize, apiUrl, appId);
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
        width: 510 * widthRate
        height: 404 * heightRate
        anchors.right: parent.right
        anchors.rightMargin: 60 * heightRate
        anchors.bottom: toolbarsView.bottom
        anchors.bottomMargin: -15 * heightRate
        visible: false
        z: 95

        //当前被选择的 课件ImgList 和fileId  var ImgUrlList, var fileId
        onSigCurrentBeOpenedCoursewareUrl:{
            isNewSelected = true;
            var fileName = getCoursewareNameById(fileId);
            coursewareList = imgUrlList;
            if(!isStartLesson){
                prevH5Id = fileId;
            }
            if(preSucceedH5Url == h5Url){
                if(coursewareMainView.visible == false){
                    coursewareMainView.visible = true;
                    background.z = 92;
                    toolbar.insertCourseWare(imgUrlList, fileId, h5Url, 3 , fileName);
                    toolbar.coursewareWindowUpdate(fileId, "move", (coursewareMainView.width / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.height / coursewareMainView.parent.height).toFixed(6) * 1000000 ,
                                                   (coursewareMainView.x / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.y / coursewareMainView.parent.height).toFixed(6) * 1000000);
                }
                return;
            }

            if(coursewareMainView.visible){// 如果有课件正在打开则显示切换提示
                exchangeCoursewareView.setExchangeViewInfo("h5", fileId, fileName, h5Url, "");
            }
            else {// 如果没有课件则显示直接打开课件
                openCourseware("h5", fileId, h5Url, "", coursewareList, fileName);
            }
        }
        //当前被选择的音频的Url 及id   audioUrl  fileI
        onSigCurrentBePlayedAudioUrl:{
            console.log("==audioUrl==",audioUrl);
            if(!isStartLesson){
                prevAudioId = fileId;
            }
            if(background_audio.visible || background_video.visible){
                exchangeCoursewareView.setExchangeViewInfo("audio", fileId, fileName, "", audioUrl);
            }
            else {
                openCourseware("audio", fileId, "", audioUrl, coursewareList, fileName);
            }
        }
        //当前被选择的视频的Url 及id  videoUrl  fileId
        onSigCurrentBePlayedVideoUrl:{
            console.log("===videoUrl==",videoUrl)
            if(!isStartLesson){
                prevVideoId = fileId;
            }
            if(background_audio.visible || background_video.visible){
                exchangeCoursewareView.setExchangeViewInfo("video", fileId, fileName, "" ,videoUrl);
            }
            else {
                openCourseware("video", fileId, "", videoUrl, coursewareList, fileName);
            }
        }

        // 当前被选择的图片url id name
        onSigCurrentBeOpendImageUrl: {
            console.log("===imageUrl===",imageUrl, fileId, fileName);

            var userInfoObj = toolbar.getUserInfo();
            var roomId = userInfoObj["classroomId"];
            var userId = userInfoObj["userId"];
            var dockId ="0"
            var pageId = coursewareMainView.currentPage;
            var itemId = userId + Date.parse(new Date()).toString();
            var json1 = {
                "boardId": "0",
                "itemId": itemId,
                "url": imageUrl,
                "w": 0.40 * 1000000,
                "h": 0.40 * 1000000,
                "pageId": pageId,
                "recX": 0.1 * 1000000,
                "recY": 0.1 * 1000000,
                "dockId":dockId,
            }
            toolbar.sendUploadImage(json1);
        }
        // 确定选择文件上传
        onSigAccept: {
            console.log("====selectd file is", fileUrl);
            var userInfoObj = toolbar.getUserInfo();
            var lessonId = userInfoObj["classroomId"];
            var userId = userInfoObj["userId"];
            var token = userInfoObj["appKey"];
            var enType = userInfoObj["envType"];

            var index1 = fileUrl.lastIndexOf("/");
            var index2 = fileUrl.lastIndexOf(".");
            var suffix = fileUrl.substring(index2 + 1, fileUrl.length);
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

    // 课件切换提示
    ExchangeCoursewareView {
        id: exchangeCoursewareView
        anchors.centerIn: parent
        z: 999
        visible: false
        // 确认切换
        onSigChangelConfirm: {
            var coursewareInfo = exchangeCoursewareView.getExchangeViewInfo();
            var currentCourswareType = coursewareInfo["currentCourswareType"];
            var currentFileId = coursewareInfo["currentFileId"];
            var currentH5Url = coursewareInfo["currentH5Url"]  ;
            var currentAVUrl = coursewareInfo["currentAVUrl"];
            var currentFileName = coursewareInfo["currentFileName"];
            openCourseware(currentCourswareType, currentFileId, currentH5Url, currentAVUrl, coursewareList, currentFileName);
            exchangeCoursewareView.visible = false;
        }
        // 取消切换
        onSigChangeCancel: {
            exchangeCoursewareView.visible = false;
        }
    }

    // 打开课件
    function openCourseware(courswareType, fileId, h5Url, avUrl, imgUrlList, fileName){
        if(courswareType == "h5"){
            min_background.visible = false;
            loadingView.loadingCoursewa();
            coursewareType = 3;
            coursewareMainView.visible = true;
            if(coursewareType == 3){
                coursewareMainView.insertCourseWare(imgUrlList, fileId, h5Url, coursewareType,curriculumData.getCurrentToken());
            }
            toolbar.insertCourseWare(imgUrlList,fileId,h5Url,coursewareType, fileName);
            toolbar.coursewareWindowUpdate(fileId, "move", (coursewareMainView.width / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.height / coursewareMainView.parent.height).toFixed(6) * 1000000 ,
                                           (coursewareMainView.x / coursewareMainView.parent.width).toFixed(6) * 1000000, (coursewareMainView.y / coursewareMainView.parent.height).toFixed(6) * 1000000);
            background_video.z = 91;
            background_audio.z = 91;
            background.z = 92;
        }
        else if(courswareType =="audio"){
            loadingView.loadingCoursewa();
            var audioPath = toolbar.downLoadAVCourseware(avUrl);
            if(audioPath == ""){
                return;
            }
            console.log("===========mediaPlayer_video.ymVideoPlayerManagerPlayFielByFileUrl==========",avUrl)
            background_video.visible = false;
            mediaPlayer_video.setPlayVideoStatus(2);
            background_audio.visible = true;
            background_audio.z = 93;
            background_video.z = 91;
            background.z = 92;
            mediaPlayer_audio.ymVideoPlayerManagerPlayFielByFileUrl("file:///" + audioPath, fileName, 0, fileId, avUrl);
            mediaPlayer_audio.setPlayVideoStatus(2);
            loadingView.hideView();

            var lastIndex_audio = avUrl.lastIndexOf(".");
            var suffix_audio = avUrl.substring(lastIndex_audio + 1, avUrl.length);
            var docName_audio = getCoursewareNameById(fileId);
            toolbar.setAVCourseware("audio", "pause", 0, avUrl, fileId, docName_audio, suffix_audio);

            toolbar.coursewareWindowUpdate(fileId, "move", (mediaPlayer_audio.width / mediaPlayer_audio.parent.width).toFixed(6) * 1000000, (mediaPlayer_audio.height / mediaPlayer_audio.parent.height).toFixed(6) * 1000000 ,
                                           (mediaPlayer_audio.x / mediaPlayer_audio.parent.width).toFixed(6) * 1000000, (mediaPlayer_audio.y / mediaPlayer_audio.parent.height).toFixed(6) * 1000000);
        }
        else if(courswareType == "video"){
            loadingView.loadingCoursewa();
            var videoPath = toolbar.downLoadAVCourseware(avUrl);
            if(videoPath == ""){
                return;
            }
            console.log("===========mediaPlayer_video.ymVideoPlayerManagerPlayFielByFileUrl==========",avUrl)
            background_audio.visible = false;
            mediaPlayer_audio.setPlayVideoStatus(2);
            background_video.visible = true;
            background_video.z = 93;
            background_audio.z = 91;
            background.z = 92;
            mediaPlayer_video.ymVideoPlayerManagerPlayFielByFileUrl("file:///" + videoPath, fileName, 0, fileId, avUrl);
            mediaPlayer_video.setPlayVideoStatus(2);
            loadingView.hideView();

            var lastIndex_video = avUrl.lastIndexOf(".");
            var suffix_video = avUrl.substring(lastIndex_video + 1, avUrl.length);
            var docName_video = getCoursewareNameById(fileId);
            toolbar.setAVCourseware("video", "pause", 0, avUrl, fileId, docName_video, suffix_video);

            toolbar.coursewareWindowUpdate(fileId, "move", (mediaPlayer_video.width / mediaPlayer_video.parent.width).toFixed(6) * 1000000, (mediaPlayer_video.height / mediaPlayer_video.parent.height).toFixed(6) * 1000000 ,
                                           (mediaPlayer_video.x / mediaPlayer_video.parent.width).toFixed(6) * 1000000, (mediaPlayer_video.y / mediaPlayer_video.parent.height).toFixed(6) * 1000000);
        }
    }

    // 云盘课件删除提示框
    YMDelDialogView {
        id: delDialogItem
        z: 100
        width: 420 * widthRate
        height: 188 * heightRate
        anchors.right: diskMainView.left
        anchors.rightMargin: 44 * widthRate
        anchors.top: diskMainView.top
        visible: false
        // 确认信号
        onSigDelConfirm: {
            delDialogItem.visible = false;
            var fileIdList = diskMainView.getDeletingFileList();
            var userInfoObj = toolbar.getUserInfo();
            var lessonId = userInfoObj["classroomId"];
            var apiUrl = userInfoObj["apiUrl"];
            var appId = userInfoObj["appId"];
            for(var i = 0; i < fileIdList.length; i++){
                classInfoManager.deleteCourseware(fileIdList[i], lessonId, apiUrl, appId);
            }
        }
        // 取消信号
        onSigDelCancel: {
            delDialogItem.visible = false;
            diskMainView.clearDeletingFileList();
        }
    }

    // 视频播放器
    Item {
        z: 101
        id: background_video
        height:  (parent.width / 16) * 9 > parent.height - headView.height - audioVideoRect.height -  bottomToolbars.height ? parent.height - headView.height - audioVideoRect.height -  bottomToolbars.height :(parent.width / 16) *9
        width: (height / 9) * 16
        anchors.top: audioVideoRect.bottom
        anchors.topMargin: -30 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
        YMVideoPlayer {
            id: mediaPlayer_video
            width: 600 * widthRate
            height: 430 * heightRate
            y: (parent.height - height)/2
            x: (parent.width - width)/2
            userRole: currentUserRole
            visible: true
            isVideo: true
            onSigClose: {
                if(currentUserRole != 0){
                    return;
                }
                mediaPlayer_video.setPlayVideoStatus(2);// 关闭需停止播放
                var lastIndex = address.lastIndexOf(".");
                var suffix = address.substring(lastIndex + 1, address.length);
                var docName = getCoursewareNameById(fileId);
                toolbar.setAVCourseware("video", controlType, times, address, fileId, docName, suffix);
                background_video.visible = false;
            }
            onSigPlayerMedia:{
                if(currentUserRole != 0){
                    return;
                }
                if(controlType == "stop"){// 老师端播放结束无需命令发送给学生，fix BUG-5575【1对1】PM3老师端播放完成后，PC学生中途也会结束视频
                    return;
                }
                var lastIndex = address.lastIndexOf(".");
                var suffix = address.substring(lastIndex + 1, address.length);
                var docName = getCoursewareNameById(fileId);
                toolbar.setAVCourseware("video", controlType, times, address, fileId, docName, suffix);
            }
            onSigVPChangeWindow: {
                console.log("====type=", type, "recWidth=",recWidth, "recHeight=",recHeight, "recX=" ,recX, "recY=",recY);
                if(type == "max"){
                    toolbar.coursewareWindowUpdate(fileId, type, (mediaPlayer_video.width / mediaPlayer_video.parent.width).toFixed(6) * 1000000, (mediaPlayer_video.height / mediaPlayer_video.parent.height).toFixed(6) * 1000000,
                                                   (mediaPlayer_video.x / mediaPlayer_video.parent.width).toFixed(6) * 1000000, (mediaPlayer_video.y / mediaPlayer_video.parent.height).toFixed(6) * 1000000);
                    return;
                }
                else if(type == "close"){
                    if(currentUserRole != 0){
                        return;
                    }
                    background_video.visible = false;
                    mediaPlayer_video.setPlayVideoStatus(2);
                }
                toolbar.coursewareWindowUpdate(fileId, type, (recWidth / mediaPlayer_video.parent.width).toFixed(6) * 1000000, (recHeight / mediaPlayer_video.parent.height).toFixed(6) * 1000000 ,
                                               (recX / mediaPlayer_video.parent.width).toFixed(6) * 1000000, (recY / mediaPlayer_video.parent.height).toFixed(6) * 1000000);
            }
        }
    }

    // 音频播放器
    Item {
        z: 101
        id: background_audio
        height:  (parent.width / 16) * 9 > parent.height - headView.height - audioVideoRect.height -  bottomToolbars.height ? parent.height - headView.height - audioVideoRect.height -  bottomToolbars.height :(parent.width / 16) *9
        width: (height / 9) * 16
        anchors.top: audioVideoRect.bottom
        anchors.topMargin: -30 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
        YMVideoPlayer {
            id: mediaPlayer_audio
            width: 600 * widthRate
            height: 430 * heightRate
            y: (parent.height - height)/2
            x: (parent.width - width)/2
            userRole: currentUserRole
            visible: true
            isVideo: false
            onSigClose: {
                if(currentUserRole != 0){
                    return;
                }
                mediaPlayer_audio.setPlayVideoStatus(2);// 关闭需停止播放
                var lastIndex = address.lastIndexOf(".");
                var suffix = address.substring(lastIndex + 1, address.length);
                var docName = getCoursewareNameById(fileId);
                toolbar.setAVCourseware("audio", controlType, times, address, fileId, docName, suffix);
                background_audio.visible = false;
            }
            onSigPlayerMedia:{
                if(currentUserRole != 0){
                    return;
                }
                if(controlType == "stop"){// 老师端播放结束无需命令发送给学生，fix BUG-5575【1对1】PM3老师端播放完成后，PC学生中途也会结束视频
                    return;
                }
                var lastIndex = address.lastIndexOf(".");
                var suffix = address.substring(lastIndex + 1, address.length);
                var docName = getCoursewareNameById(fileId);
                toolbar.setAVCourseware("audio", controlType, times, address, fileId, docName, suffix);
            }
            onSigVPChangeWindow: {
                console.log("====type=", type, "recWidth=",recWidth, "recHeight=",recHeight, "recX=" ,recX, "recY=",recY);
                if(type == "max"){
                    toolbar.coursewareWindowUpdate(fileId, type, (mediaPlayer_audio.width / mediaPlayer_audio.parent.width).toFixed(6) * 1000000, (mediaPlayer_audio.height / mediaPlayer_audio.parent.height).toFixed(6) * 1000000,
                                                   (mediaPlayer_audio.x / mediaPlayer_audio.parent.width).toFixed(6) * 1000000, (mediaPlayer_audio.y / mediaPlayer_audio.parent.height).toFixed(6) * 1000000);
                    return;
                }
                else if(type == "close"){
                    if(currentUserRole != 0){
                        return;
                    }
                    background_audio.visible = false;
                    mediaPlayer_audio.setPlayVideoStatus(2);
                }
                toolbar.coursewareWindowUpdate(fileId, type, (recWidth / mediaPlayer_audio.parent.width).toFixed(6) * 1000000, (recHeight / mediaPlayer_audio.parent.height).toFixed(6) * 1000000 ,
                                               (recX / mediaPlayer_audio.parent.width).toFixed(6) * 1000000, (recY / mediaPlayer_audio.parent.height).toFixed(6) * 1000000);
            }
        }
    }

    // 教鞭 白板区域
    WhiteBoard0 {
        id: pointerWhiteBoard
        z: 100
        height:  Screen.height - (50 +110 + (userRole == 0 ? 50 : 0))* heightRate
        width: (height / 9) * 16
        anchors.top: audioVideoRect.bottom
        anchors.topMargin: 10 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter

        clip: true
        smooth: true
        visible: true
        enabled: userRole == 0 ? false : true
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

    ToolBoxView{
        id: toolBoxView
        z: 92
        visible: false
        anchors.right: parent.right
        anchors.rightMargin: 58 * heightRate
        anchors.bottom:  parent.bottom
        anchors.bottomMargin: (parent.height - toolbarsView.height) * 0.5 + 40 * heightRate

        onFocusChanged: {
            if(toolBoxView.focus) {
                toolBoxView.visible = true;
            }else {
                toolBoxView.visible = false;
            }
        }

        onSigSendBoxFunctionKey: {
            brushWidget.visible = false;
            eraserWidget.visible = false;
            diskMainView.visible = false;
            switch(keys)
            {
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
            default:
                break;
            }
        }

    }

    //退出教室与进入教室提醒
    YMLessonTipsView{
        id: tipsView
        z: 100
        visible: false
        onSigAutoExit: {
            toolbar.exitChannel();
            toolbar.uninit();
            toolbar.uploadLog();
            Qt.quit();
        }

        onSigFinishLesson: {
            toolbar.exitChannel();
            toolbar.endClass();
        }

        onSigHalt: {
            toolbar.exitChannel();
            toolbar.exitClassRoom();
        }

        onSigStartLesson: {
            isStartLesson = true;
            toolbar.beginClass();
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
            console.log("\n====ClassInfoManager::onSigCloudDiskInfo====", JSON.stringify(clouddiskInfo),"\n")
            diskMainView.resetCloudDiskViewData(clouddiskInfo)
        }

        onSigSaveResourceSuccess: {
            diskMainView.addUpFileMarkToBufferList(upFileMark);
            // 如果不是ppt/pptx、pdf、doc/docx格式则直接刷新云盘，无需轮询转换状态
            if(!(suffix.indexOf("ppt") != -1 || suffix.indexOf("pdf") != -1 || suffix.indexOf("doc") != -1)){
                refreshCloudDisk();
                return;
            }
            coursewareIdValue = coursewareId;
            findStatusTimer.start();
        }

        onSigSaveResourceFailed: {
            diskMainView.updateUpLoadingStatus(upFileMark, 2);
            setTips("上传资源失败");
        }

        onSigFindFileStatus: {// status 转换状态 0-转换中 1-成功 2-失败
            if(status == 0){
                refreshCloudDisk();// 查询到转换中也刷新一下云盘，云盘才能显示出"上传中"状态
            }
            else if(status == 1 || status == 2){
                //                if(status == 1){
                //                    setTips("上传资源成功");
                //                }
                //                else if(status == 2){
                //                    setTips("上传资源失败");
                //                }

                findStatusTimer.stop();
                refreshCloudDisk();// 查询到课件转码成功或失败结果后，则停止轮询，再刷新一下云盘列表，云盘显示出"上传成功"或"上传失败"状态
            }
        }

        onSigDeleteResult: {// 课件删除结果
            if(isSuccess){// 删除成功从云盘删除，避免API返回列表数据仍存在
                diskMainView.removeCourseware(coursewareId);
                diskMainView.clearDeletingFileList();
            }
            else {
                setTips("课件删除失败!");
            }
        }
    }
    // 轮询上传课件转码状态定时器
    Timer {
        id: findStatusTimer
        interval: 2000
        running: false
        repeat: true
        onTriggered: {
            var userInfoObj = toolbar.getUserInfo();
            var apiUrl = userInfoObj["apiUrl"];
            var appId = userInfoObj["appId"];
            classInfoManager.findFileStatus(coursewareIdValue, apiUrl, appId);
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

    Timer{
        id: saveBoardTime
        interval: 1000
        running: false
        repeat: false
        onTriggered: {
            console.log("saveBoard time Trigger");
            background1.grabToImage(function(result)
            {
                result.saveToFile(filePathName);

                var userInfoObj = toolbar.getUserInfo();
                var lessonId = userInfoObj["classroomId"];
                var userId = userInfoObj["userId"];
                var token = userInfoObj["appKey"];
                var enType = userInfoObj["envType"];

                var index1 = filePathName.lastIndexOf("/");
                var index2 = filePathName.lastIndexOf(".");
                var suffix = filePathName.substring(index2 + 1, filePathName.length);
                var tempFileName = filePathName.substring(index1 + 1, index2);
                var upFileMark = new Date().getTime().toString();
                diskMainView.addUpLoadingFile(tempFileName, suffix, 0, upFileMark);
                uploadFileManager.upLoadFileToServer(upFileMark, filePathName, lessonId, userId, token, enType);

                if(bSaveCurBoardPage == false)
                {
                    if(bottomToolbars.currentPage < bottomToolbars.totalPage)
                    {
                        screenshotSaveImage.saveBoard(bSaveCurBoardPage, saveBoardName, bottomToolbars.currentPage+1);
                    }
                    else
                    {
                        toolbar.goWhiteBoardPage(1, curBoardPage,bottomToolbars.totalPage,whiteBoardId, false);
                        toolbarsView.saveBoardsSuccessTip();
                    }
                }
                else
                {
                    toolbarsView.saveBoardsSuccessTip();
                }

            });


        }
    }

    //截图
    ScreenshotSaveImage{
        id:screenshotSaveImage
        onSigSendScreenshotName:{
            console.log("=======sigSendScreenshotName=========",bSaveCurPage, fileName, curPage);
            if(fileName.length > 0) {
                filePathName = fileName;
                bSaveCurBoardPage = bSaveCurPage;
                toolbar.goWhiteBoardPage(1, curPage,bottomToolbars.totalPage,whiteBoardId, false);

                saveBoardTime.restart();
            }
        }

    }

    SaveBoardsView{
        z:100
        id:saveBoardsView
        anchors.centerIn: parent
        visible: false

        onSigSaveBoardsOK: {

            toolbarsView.enabled = true;
            bottomToolbars.enabled = true;
            saveBoardName = fileName;
            curBoardPage = bottomToolbars.currentPage;
            if(bSaveCurPage == false)
            {
                bottomToolbars.currentPage = 1;
            }
            screenshotSaveImage.saveBoard(bSaveCurPage, fileName, bottomToolbars.currentPage);
        }

        onSigSaveBoardsCancel:{
            toolbarsView.enabled = true;
            bottomToolbars.enabled = true;
        }
    }


    Component.onCompleted: {
        curriculumData.getListAllUserId();
        networkMgr.setNetIp(socketIp);
        if(statusCode == 30001){
            tipsView.showDownLesson();
        }
        whiteBoard.setWhiteBoardId(whiteBoardId);
        coursewareMainView.setWhiteBoardId(courseWhiteBoardId);
        pointerWhiteBoard.setWhiteBoardId(pointerWhiteBoardId)
    }

    function getRewardNum(userId){
        for(var i  = 0; i < rewardArray.length; i ++){
            if(userId.toString() === rewardArray[i].uid){
                return rewardArray[i].count;
            }
        }
        return 0;
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
        var userName = videoId.toString();// 用户名默认为用户Id,服务端能传userName则显示真实的userName
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
        var appId = userInfoObj["appId"];
        console.log("=====refreshCloudDisk===", classroomId, apiUrl)
        classInfoManager.getCloudDiskList(classroomId, apiUrl, appId);
    }

    // 通过课件Id获取课件名称
    function getCoursewareNameById(coursewareId){
        if(coursewareId == "" || coursewareId == undefined){
            return "";
        }
        var filename = coursewareId;// 课件名称默认为Id，查询到课件名则为真实课件名称
        var userInfoObj = toolbar.getUserInfo();
        var classroomId = userInfoObj["classroomId"];
        var apiUrl = userInfoObj["apiUrl"];
        var appId = userInfoObj["appId"];
        classInfoManager.getCloudDiskList(classroomId, apiUrl, appId, false);
        var coursewareListInfo = classInfoManager.getCoursewareListInfo();
        for(var i = 0; i < coursewareListInfo.length; i++){
            if(coursewareListInfo[i].id == coursewareId){
                filename = coursewareListInfo[i].name;
                break;
            }
        }
        return filename;
    }

    // 通过课件Id获取课件类型
    function getCoursewareTypeById(coursewareId){
        var docType = "h5";// 课件名称默认为h5，查询到课件类型则为真实课件名称
        var userInfoObj = toolbar.getUserInfo();
        var classroomId = userInfoObj["classroomId"];
        var apiUrl = userInfoObj["apiUrl"];
        var appId = userInfoObj["appId"];
        classInfoManager.getCloudDiskList(classroomId, apiUrl, appId, false);
        var coursewareListInfo = classInfoManager.getCoursewareListInfo();
        for(var i = 0; i < coursewareListInfo.length; i++){
            if(coursewareListInfo[i].id == coursewareId){
                docType = coursewareListInfo[i].docType;
                break;
            }
        }
        return docType;
    }

    // 设置提示
    function setTips(tipsText){
        tipsTime.restart();
        ymtip.visible = true;
        tipText.text = tipsText
    }

    //添加更改几何图形并进行缓存
    function addGraph(dockId,pageId,boardId,itemId,rectangeObj){
        if(bufferGraph.indexOf(itemId) == -1){
            bufferGraph.push({
                                 "dockId": dockId,
                                 "pageId":  pageId,
                                 "boardId": boardId,
                                 "itemId": itemId,
                                 "graphObjecte": rectangeObj,
                             });
            console.log("===addGraph::11===",itemId)
        }
        console.log("===bufferGraph===",bufferGraph.indexOf(itemId),boardId ,itemId);
    }

    function isDrawPolyon(itemId){
        for(var i = 0; i < bufferGraph.length;i++){
            var itemIds = bufferGraph[i].itemId;
            if(itemId == itemIds){
                return true;
            }
        }
        return false;
    }

    function updateDrawLocation(itemId,x,y,w,h,type){
        for(var i = 0; i < bufferGraph.length;i++){
            var itemIds = bufferGraph[i].itemId;
            if(itemId == itemIds){
                bufferGraph[i].graphObjecte.visible = true;
                bufferGraph[i].graphObjecte.x = x;
                bufferGraph[i].graphObjecte.y = y;
                if(type == 5){
                    bufferGraph[i].graphObjecte.width = w;
                    bufferGraph[i].graphObjecte.height = h;
                }

                break;
            }
        }
    }

    //清除当前页所有几何图形
    function clearGraphBuffer(){
        for(var z = 0; z < bufferGraph.length;z++){
            bufferGraph[z].graphObjecte.visible = false;
            //bufferGraph[z].graphObjecte.destroy();
        }
        //bufferGraph.splice(0,bufferGraph.length);
    }

    //清除当前白板所有几何图形
    function clearBoardGraphBuffer(boardId){
        for(var z = 0; z < bufferGraph.length;z++){
            if(boardId == bufferGraph[z].boardId){
                bufferGraph[z].graphObjecte.visible = false;
                //bufferGraph[z].graphObjecte.destroy();
            }
        }
        //bufferGraph.splice(0,bufferGraph.length);
    }

    //修改当前页当前课件的几何图形是否可以选中操作
    function updateGraphStatus(status){
        for(var i = 0 ; i < bufferGraph.length;i++){
            var drawZ = status ? 93 : bufferGraph[i].boardId == "0" ? 1 : 11;
            bufferGraph[i].graphObjecte.isclicked = status;
            bufferGraph[i].graphObjecte.z = drawZ;
            bufferGraph[i].graphObjecte.isSelected = false;
        }
    }

    //发送移动位置
    function sendMoveGraphLocation(itemId,graphType,locationArray){
        var sendGraphData;
        for(var i = 0 ; i < bufferGraph.length;i++){
            if(bufferGraph[i].itemId == itemId){
                if(graphType == 1){
                    sendGraphData = {
                        "angle": locationArray[0].angle,
                        "boardId": bufferGraph[i].boardId,
                        "color":"3ED7B7",
                        "dockId": bufferGraph[i].dockId,
                        "itemId": bufferGraph[i].itemId ,
                        "pageId": bufferGraph[i].pageId ,
                        "rectHeight": locationArray[0].rundHeight,
                        "rectWidth": locationArray[0].rectWidth,
                        "rectX": locationArray[0].rectX,
                        "rectY": locationArray[0].rectY,
                        "type":"ellipse",
                        "width": 0.000977 * 1000000
                    };
                }else if(graphType == 5){
                    sendGraphData ={
                        "itemId": itemId,
                        "boardId": "0",
                        "pageId": bufferGraph[i].pageId,
                        "dockId": bufferGraph[i].dockId,
                        "url": locationArray.url,
                        "w": locationArray.w,
                        "h": locationArray.h,
                        "recX": locationArray.recX,
                        "recY": locationArray.recY,
                    }
                }
                else{
                    sendGraphData = {
                        "boardId": bufferGraph[i].boardId,
                        "color":"3ED7B7",
                        "dockId": bufferGraph[i].dockId,
                        "itemId": bufferGraph[i].itemId,
                        "pageId": bufferGraph[i].pageId,
                        "pts": locationArray,
                        "type":"polygon",
                        "width": 0.000977 * 1000000
                    };
                }
                break;
            }
        }
        if(graphType == 5){
            toolbar.sendUploadImage(sendGraphData);
        }else{
            toolbar.sendDrawGraph(sendGraphData);
        }
    }

    //操作几何图形是删除还是选中状态
    function operatingDraw(opearType,boardId,itemId){
        for(var i = 0 ; i < bufferGraph.length;i++){
            var itemIds = bufferGraph[i].itemId;
            if(bufferGraph[i].itemId == itemId && opearType == 1){
                continue;
            }
            if(bufferGraph[i].itemId == itemIds && opearType == 2){
                toolbar.deleteItem(boardId,itemId);
                break;
            }
            bufferGraph[i].graphObjecte.isSelected = false;
        }
    }

    function isCurrentPagePolyon(boardId,pageId){
        var isPolyon = true;
        for(var i = 0 ; i < bufferGraph.length;i++){
            if(pageId == bufferGraph[i].pageId && boardId == bufferGraph[i].boardId){
                isPolyon = false;
            }
        }
        if(isPolyon){
            clearGraphBuffer();
        }
    }

    function deletePolyon(itemId){
        for(var i = 0 ; i < bufferGraph.length;i++){
            var itemIds = bufferGraph[i].itemId;
            if(itemId == itemIds){
                bufferGraph[i].graphObjecte.visible = false;
                //bufferGraph[i].graphObjecte.destroy();
                //bufferGraph.splice(i,1);
                console.log("======deletePolyon======")
                break;
            }
        }
    }

    function resetBoardStatus(){
        isSelected = false;
        brushWidget.visible = false;
        eraserWidget.visible = false;
        diskMainView.visible = false;
        toolBoxView.visible = false;
        graphicWidget.visible = false;
        pointerWhiteBoard.enabled = false;
        tipFeedview.visible = false;
        isAddGraph = false;
        updateGraphStatus(false);

        toolbar.selectShape(0, whiteBoardId);
        toolbar.selectShape(0, courseWhiteBoardId);
    }
}
