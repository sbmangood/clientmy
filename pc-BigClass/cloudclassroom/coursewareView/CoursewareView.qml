import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import YMCoursewareManager 1.0

Rectangle {
    id: coursewareview
    width: parent.width
    height: parent.height
    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates
    property bool  isMaxWidget: false
    property string tipName: "";
    property bool hasShowCutSCreen: false;
    property int loadImgWidth: 0;//加载图片宽度
    property int loadImgHeight: 0;//加载图片高度
    property bool isClipImage: false;//是否时截图课件
    property bool isUploadImage: false;//是否是传的图片
    property double currentOffsetY: 0;//当前滚动条的坐标
    property bool isLongImage: false;//是否是长图
    property double currentImageHeight: 0.0;

    property string userRole: "tea";// 当前身份

    property int isHomework: 2; //习题模式 1:练习模式 2：老课件模式 3：批改模式 4:浏览模式

    signal sigChangeCurrentPages(int pages);//当前页数
    signal sigChangeTotalPages(int pages);//总页数
    signal sigGetOffsetImage(var url, double currentCourseOffsetY);
    signal sigWhiteboardGetOffSetImage(double offsetX, double offsetY, double zoomRate);

    signal sigCoursewareOffsetY(double offsetY);
    signal sigSendH5PlayAnimation(var animationStepIndex);
    signal sigSendH5ThumbnailPage(var pageIndex);
    signal sigLoadsCoursewareSuccess(var currentUrl);// 课件加载成功信号
    signal sigIsCouserware();//删除的是否为课件
    signal sigCurrentCoursewareId(var coursewareId);// 当前课件Id

    signal sigVisualizeH5Courseware();// 设置H5课件可见

    signal sigWindowUpdates(var windowInfo);// 窗口信息更新

    signal sigH5GetScroll(var scrollValue);// H5页面滚动百分比
    signal sigH5GoPages(var currentPage, var totalPage);

    //背景图
    Rectangle{
        id:topicListView//bakcImages
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        clip: true

        // 课件显示
        CourseWareControlView {
            id: bmgImages
            anchors.fill: parent
            currentBeshowViewType: coursewareType
            onSigAnimationNotifications: {
                if(currentUserRole == 0){
                    sigSendH5PlayAnimation(animationStepIndex);
                }
            }
            onSigThumbnailPages: {
                //console.log("====缩略图Page===", pageIndex);
                if(currentUserRole == 0){
                    sigSendH5ThumbnailPage(pageIndex);
                }
            }
            onSigLoadCoursewareSuccess: {
                sigLoadsCoursewareSuccess(currentUrl);
            }

            onSigWebGetScrolls: {
                sigH5GetScroll(scrollValue);
            }
        }
    }

    YMCoursewareManager {
        id: ymCoursewareManager

        onSigOffsetY: {
            //console.log("======offsetY=",offsetY)
            currentOffsetY = offsetY;
            bmgImages.h5SetScroll(offsetY);
        }

        onSigCurrentCourseId: {
            //console.log("==========onSigCurrentCourseId::onSigCurrentCourseId=======",coursewareId);
            sigCurrentCoursewareId(coursewareId);
        }

        onSigWindowUpdate: {
            sigWindowUpdates(windowUpdateInfo);
        }

        onSigSendUrl: {
            var urlsa = urls.replace("https","http");
            isClipImage = false;
            isUploadImage = false;
            isLongImage = true;
            if(questionId == "" || questionId == "-1" || questionId == "-2"){
                isLongImage = false;
            }
            if(coursewareType == 3){
                console.log("===========444==============")
                sigVisualizeH5Courseware();// 学生端接收到课件url后需要设置H5课件
                bmgImages.setCoursewareSource("",coursewareType,urls,parent.width,parent.height,curriculumData.getCurrentToken());
                scrollbar.visible = false;
                whiteBoard.getOffSetImage(0,0,1.0);
                return;
            }
            if(width < 1 && height < 1 && urls != ""){//截图
                //console.log("==============1111===============");
                isClipImage = true;
                toobarWidget.disableButton = true;
                clipWidthRate = width;
                clipHeightRate = height;
                scrollbar.visible = false;
                isUploadImage = true;
                whiteBoard.getOffsetImage(urlsa,0);
                whiteBoard.getOffSetImage(0,0,1.0);
                return;
            }
            if(width == 1 && height == 1 && urls != ""){//传图
                //console.log("==============2222==============currentOffsetY=",currentOffsetY);
                isUploadImage = true;
                bmgImages.setCoursewareSource("",questionId,urlsa,height,width,curriculumData.getCurrentToken());
                sigGetOffsetImage(urlsa, currentOffsetY);
                sigWhiteboardGetOffSetImage(0,currentOffsetY,1.0);
                return;
            }
            if(urls.length > 0){
                //console.log("==============3333===============");
                loadImgHeight = height;
                loadImgWidth = width;
                bmgImages.setCoursewareSource("",questionId,urlsa,height,width,curriculumData.getCurrentToken());
                if(isLongImage && !isClipImage && !isUploadImage){
                    isHomework = 3;
                    sigGetOffsetImage(urlsa, currentOffsetY);
                    sigWhiteboardGetOffSetImage(0,currentOffsetY,1.0);
                }
            }
            else{
                //console.log("==============4444===============");
                bmgImages.setCoursewareVisible(1,false);
            }
        }

        onSigSynCoursewareInfo: {
            bmgImages.coursewareSyn(jsonObj);
        }

        onSigCurrentCourse: {

        }
        onSigCurrentQuestionId: {

        }

        /*
        // 音视频课件
        onSigVideoAudioUrl:{
            console.log("==onSigVideoAudioUrl==",flag,time,dockId);
            if(flag == 0 || flag == 1){
                var videoJsonObj = miniMgr.getCloudDiskFileInfo(dockId).data;
                var suffix = videoJsonObj.suffix.toLowerCase();
                var avType = "audio";

                if(suffix.indexOf("mp4") != -1 || suffix.indexOf("avi") != -1 || suffix.indexOf("wmv") != -1 || suffix.indexOf("rmvb") != -1){
                    avType = "video";
                }
                else if(suffix.indexOf("mp3") != -1 || suffix.indexOf("wma") != -1 || suffix.indexOf("wav") != -1){
                    avType = "audio";
                }
                console.log("=====argPrme=====",suffix,avType );
                trailBoardBackground.sigVideoAudioUrls(avType,videoJsonObj.name,time,videoJsonObj.path,dockId);
            }
            //console.log("avType ==",avType ,"startTime ==",startTime ,"controlType ==",controlType,"avUrl ==",avUrl)
            //trailBoardBackground.sigVideoAudioUrls(  avType, startTime , controlType , avUrl )
        }
        */

        onSigSynCoursewareStep: {
            playNumber = step;
            bmgImages.coursewareOperation(coursewareType,4,pageId,step);
        }

        onSigSynCoursewareType: {
            coursewareType = courseware;
            if(courseware == 3){
                if(h5Url=="")
                {
                    return;
                }
                console.log("========onSigSynCoursewareType======")
                bmgImages.setCoursewareSource("",coursewareType,h5Url,parent.width,parent.height,curriculumData.getCurrentToken());
            }
        }
        //当前页
        onSigCurrentPage: {
            var currentPages = currentPage + 1;
            sigChangeCurrentPages(currentPages);
        }
        //全部页数
        onSigTotalPage: {
            sigChangeTotalPages(totalPage);
        }
        //删除课件提醒
        onSigIsCourseWare: {
            if(isCourseware){
                sigIsCouserware();
            }else{
                if(userRole == "tea"){
                    bmgImages.coursewareOperation(coursewareType, 3, 0, 0);
                }
            }

        }
        // 动画播放同步
        onSigPlayAnimation: {
             if(userRole != "tea"){
                bmgImages.coursewareOperation(coursewareType, 5, pageId, step);
            }
        }

        onSigH5GoPage: {
            bmgImages.coursewareOperation(coursewareType, 4, pageIndex, 0);
            sigH5GoPages(pageIndex, totalPage);
        }

        onSigH5AddPage: {
            bmgImages.coursewareOperation(coursewareType, 2, 0, 0);
        }

        onSigH5DelPage: {
            bmgImages.coursewareOperation(coursewareType, 3, 0, 0);
        }

        onSigAnimationInfo: {
            console.log("=========onSigAnimationInfo", pageNo, step)
            if(userRole != "tea"){
                bmgImages.coursewareOperation(coursewareType, 5, pageNo, step);
            }
        }
    }

    function insertCourseWare(imgUrlList,fileId,h5Url,coursewareType,token)
    {
        if(coursewareType == 3){
            bmgImages.setCoursewareSource("",coursewareType,h5Url,parent.width,parent.height,token);
        }
    }

    function coursewareOperation(coursewareType, operationType, operationIndex,step){
        bmgImages.coursewareOperation(coursewareType,operationType,operationIndex,step);
    }

    function goNextAnimationSteps(){
        bmgImages.goNextAnimationStep();
    }

    function downLoadMp3(mp3Path){

    }

    //发送给学生音频，视频播放
    function setVideoStream(types,status,times,address,fileId){
        var lastIndex = address.lastIndexOf(".");
        var suffix = address.substring(lastIndex + 1,address.length);

    }

    function setCoursewareSource(role, coursewareType, url, width, height, token)
    {
        bmgImages.setCoursewareSource(role, coursewareType, url, width, height, token);
    }

    function setReShowOffsetImage(width,height)
    {

    }

    //清屏操作
    function clearScreen(){
        bmgImages.setCoursewareVisible(1,false);
        bmgImages.setCoursewareVisible(3,false);
    }
}
