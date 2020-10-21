import QtQuick 2.5
import WhiteBoard 1.0


WhiteBoard{

    signal sigUserAuth(var userId,var up,var trail,var userRole);//设置用户权限信号

    onSigFocusTrailboard:{
        whiteBoard.focus = true;
    }

    //修改操作权限
    onSigAuthChange: {
        //QString userId,int up,int trail,int userRole
        //userRole: 0=老师，1=学生，2=助教
        console.log("===onSigAuthChange===",userId,up,trail,userRole);
        sigUserAuth(userId,up,trail,userRole);
    }
/*
    //图片的高度
    onSigCurrentImageHeight: {
        currentImageHeight = height;
        console.log("**********currentImageHeight*************",currentImageHeight)
        scrollbar.visible = false;
        if(currentImageHeight > trailBoardBackground.height){
            scrollbar.visible = true;
        }
        whiteBoard.setCurrentImageHeight(height);
        whiteBoard.getOffSetImage(0.0,currentOffsetY,1.0);
    }

    onSigOffsetY: {
        currentOffsetY = offsetY;
        console.log("***********setYYYYYYY***************",currentImageHeight,offsetY);
        if(currentImageHeight == 0){
            return;
        }

        var currentY =  -(scrollbar.height * offsetY * trailBoardBackground.height / currentImageHeight);
        button.y  = currentY;

        scrollbar.visible = false;
        if(currentImageHeight > trailBoardBackground.height){
            scrollbar.visible = true;
        }
        //console.log("=======sigOffsetY=======",offsetY,button.y,currentImageHeight)
    }
*/
    //老师操作教鞭
    onSigCursorPointer:{
//        console.log("===sigCursorPointer===",pointx,pointy,statues);
        cursorPoint.x = pointx
        cursorPoint.y = pointy
        cursorPoint.visible = true;
    }

    //教鞭
    onSigPointerPosition:{
        cursorPoint.x = xPoint * whiteBoard.width;
        cursorPoint.y = yPoint * whiteBoard.height;
        cursorPoint.visible = true;
        cursorPointTime.restart();
    }

    onSigMouseRelease: {
        cursorPointTime.restart();
    }

    onSigSendUrl:{
        var urlsa = urls.replace("https","http");
        isClipImage = false;
        isUploadImage = false;

        console.log("=======falseonSigSendUrl========",currentOffsetY,width,height,urlsa,isHomework,isClipImage,isLongImg,questionId);
        isLongImage = true;
        if(isHomework == 2) //老课件
        {
            scrollbar.visible = false;
        }

        if(questionId == "" || questionId == "-1" || questionId == "-2"){
            //console.log("========no::longImg=====",isLongImage);
            isLongImage = false;
        }

        if(width < 1 && height < 1 && urls != ""){//截图
            isClipImage = true;
            toobarWidget.disableButton = teacherType == "T" ? true : false;
            clipWidthRate = width;
            clipHeightRate = height;
            scrollbar.visible = false;

            //可以使用新比例画板的话 按照16:9新比例模式来进行填充显示
            if(couldUseNewBoard)
            {
                isUploadImage = true;
                toobarWidget.disableButton = true;
                whiteBoard.getOffsetImage(urlsa,0);
                whiteBoard.getOffSetImage(0,0,1.0);
                return;
            }
        }
        if(width == 1 && height == 1 && urls != ""){//传图
            //原逻辑传图老课件都是走这里(原来传图老课件都是一屏铺满显示) 现在逻辑把传图和老课件都按等比例缩放
            console.log("======= test old img 1 ========",currentOffsetY);
            isUploadImage = true;
            toobarWidget.disableButton = teacherType == "T" ? true : false;

            if(couldUseNewBoard)
            {
                whiteBoard.getOffsetImage(urlsa,currentOffsetY);
                whiteBoard.getOffSetImage(0,currentOffsetY,1.0);
            }else
            {
                setBmgUrl(urlsa,width,height);
                setBmgVisible(true);
            }

            return;
        }

        //                console.log("=======false::new========",width,height,urlsa,isHomework,isClipImage,isLongImg,isLongImage,questionId,isUploadImage);
        console.log("=====currentOffsetY======",currentOffsetY);

        if(urls.length > 0){
            loadImgHeight = height;
            loadImgWidth = width;
            if(isLongImage && !isClipImage && !isUploadImage){
                isHomework = 3;
                whiteBoard.getOffsetImage(urlsa,currentOffsetY);
                whiteBoard.getOffSetImage(0,currentOffsetY,1.0);
                //                        console.log("=======getOffsetImage========",currentOffsetY);
            }else
            {
                setBmgUrl(urlsa,width,height);
                setBmgVisible(true);
            }

            screenshotSaveImage.deleteTempImage();
        }else{
            if(isHomework == 2){
                removeBmgUrl();
            }

            if(questionId == "" && isHomework == 3){
                scrollbar.visible = false;
                setBmgVisible(false);
            }

            if(width == 1 && height == 1 && urlsa == ""){
                //console.log("width == 1 && height =wwwwww= 1",isHomework,isLongImage);
                //setBmgVisible(false);
                if(isHomework == 1)
                {
                    sigHideCourseView(false);
                }
                return
            }

            var visibles = (isHomework == 3 ? true : isLongImg);
            setBmgVisible(visibles);
            sigHideCourseView(visibles);
        }
    }

    onSigSendHttpUrl:{
        animePlayBroundImage.source = "";
        animePlayBroundImage.paused = true;

        if(urls.length > 0) {
            animePlayBroundImage.source = trailBoard.justImageIsExisting(urls);
            animePlayBround.focus = true;
            animePlayBroundImage.paused = false;
        }else {
            trailBoard.focus = true;
        }
    }

    //教鞭
    Rectangle{
        id:cursorPoint
        width: 15
        height: 15
        radius: cursorPoint.height / 2
        color: "#4FF6D3"
        x:0
        y:0
        visible: false
        z: 99
    }

    //教鞭定时器
    Timer{
        id:cursorPointTime
        interval: 1000
        repeat: false
        running: false
        onTriggered: {
            cursorPoint.visible = false;
        }
    }

}




