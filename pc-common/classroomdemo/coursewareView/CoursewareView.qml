import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import YMCoursewareManager 1.0

Rectangle {
    id: coursewareview
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

    property int isHomework: 2; //习题模式 1:练习模式 2：老课件模式 3：批改模式 4:浏览模式

    signal sigChangeCurrentPages(int pages);//当前页数
    signal sigChangeTotalPages(int pages);//总页数
    signal sigGetOffsetImage(var url, double currentCourseOffsetY);
    signal sigWhiteboardGetOffSetImage(double offsetX, double offsetY, double zoomRate);

    signal sigCoursewareOffsetY(double offsetY);

    signal sigSendH5PlayAnimation(var animationStepIndex);

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
                sigSendH5PlayAnimation(animationStepIndex);
            }
        }
    }

    YMCoursewareManager {
        id: ymCoursewareManager

        onSigOffsetY: {
            //console.log("======offsetY=",offsetY)
            currentOffsetY = offsetY;
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
                console.log("=====课件不能删除!===");
            }
            else{
                bmgImages.coursewareOperation(coursewareType,3,1,0);
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

    function downLoadMp3(mp3Path){
        //return loadInforMation.downLoadMp3(mp3Path);
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
        /*
        if(coursewareType== 3){
            return;
        }
        var imgSource = "image://offsetImage/" + Math.random();
        bmgImages.setCoursewareSource("",coursewareType,imgSource,width,height,curriculumData.getCurrentToken());
        loadImgHeight = height;
        loadImgWidth = width;
        isUploadImage = false;
        isClipImage = false;
        isLongImage = true;

        console.log("===bmgImages.source===",coursewareType,bmgImages.source,width,height,currentImageHeight);
        scrollbar.visible = false;
        if(currentImageHeight > coursewareview.height){
            scrollbar.visible = true;
        }
        */
    }
}

