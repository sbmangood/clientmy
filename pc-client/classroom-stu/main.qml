import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
//import TrailBoard 1.0
import CurriculumData 1.0
import ExternalCallChanncel 1.0
import YMHomeworkManagerAdapter 1.0
import "Configuration.js" as Cfg

import PanDuWriteBoard 1.0

Window {
    id: mainView
    visible: true
    width: Screen.width
    height: Screen.height + 1
    flags: Qt.Window | Qt.FramelessWindowHint //| Qt.WindowStaysOnTopHint

    title: "学生端教室"

    property double leftMidWidths: leftMidWidth / 66.0

    property double widthRate: Screen.width * 0.8 / 966.0;
    property double heightRate:widthRate/1.5337;

    property  var currentOrderNumber: ;

    property bool toolBarIsCanClick: showQuestionHandlerView.visible || compositeTopicView.visible ;//左侧工具栏是否可以操作（for: 如果是显示题型时 不可操作）

    property bool columRoomMenueBufferVisible: false;
    property bool pageBufferVisible: false;

    property  var lessonCommentConfigInfo:[];

    property  var currentCourwareType: 1;

    //是否可以使用新比例的画板
    property bool couldUseNewBoard: true;

    //===========================
    //lessonType 0,1    试听课
    //lessonType 10     订单课
    //subjectId  0      演示课
    //课程类型
    property var  lessonType: -1
    property var  subjectId: -1
    //判断是否是标准试听课, //0不是标准试听课，1是
    property var  applicationType: 0;

    //===========================
    onClosing:
    {
        trailBoardBackground.disconnectSockets();
        externalCallChanncel.closeAlllWidget()
    }

    //    Image {
    //        id: testiamge
    //        z:100000000
    //    }


    //全屏类型
    property bool fullScreenType: false

    //学生类型
    property string studentType: videoToolBackground.getCurrentUserType()

    //边框阴影
    property int borderShapeLen: (rightWidthX - midWidth - midWidthX) > 10 ? 10 : (rightWidthX - midWidth - midWidthX)

    //设置全屏
    function setFullScrreen(types){
        //console.log("=============setFullScrreen0", types, trailBoardBackground.width, trailBoardBackground.height, trailBoardBackground.anchors.leftMargin, trailBoardBackground.anchors.topMargin);

        if(types){
            trailBoardBackground.width = fullWidth
            //trailBoardBackground.height = fullHeight
            trailBoardBackground.anchors.leftMargin = fullWidthX
            var tempHeight = titelImg.visible ? titelImg.height : fullHeightY;
            trailBoardBackground.anchors.topMargin = tempHeight;
            if(!couldUseNewBoard)
            {
                trailBoardBackground.anchors.topMargin = (mainView.height - trailBoardBackground.height) / 2
            }

        }else{
            trailBoardBackground.width = midWidth
            //trailBoardBackground.height = midHeight
            trailBoardBackground.anchors.leftMargin = midWidthX - 15 * fullWidths / 1440.0
            var tempHeights = titelImg.visible ? midHeightYs : midHeightY;
            trailBoardBackground.anchors.topMargin = tempHeights;
            if(!couldUseNewBoard)
            {
                trailBoardBackground.anchors.topMargin = (mainView.height - trailBoardBackground.height) / 2
            }
        }
        trailBoardBackground.jumpToPage(bottomToolbars.currentPage - 1);
    }

    Component.onCompleted: {
        var currentNetStatus = trailBoardBackground.getNetworkStatus();
        videoToolBackground.networkStatus = currentNetStatus;
        videoToolBackground.updateNetworkStatus(3);
        cloudRoomMenu.getLessonCommentConfigInfo();

    }
    //手写板
    PanDuWriteBoard
    {
        id:panDuWriteBoard

        onConnectWriteBoardStatus:
        {
            console.log("onConnectWriteBoardStatus",codes);
            //断开链接 拔掉了
            if(codes == 3)
            {
                cloudTipView.setBreakWriteBoard();
            }
        }

        onWriteBoardClick:
        {
            //手写板单击, 下一页, 翻页
            console.log("onConnectWriteBoardStatus click");
            bottomToolbars.setNextPage();
        }

        onWriteBoardDoubleClick:
        {
            //手写板双击, 上一页, 翻页
            console.log("onConnectWriteBoardStatus double click");
            bottomToolbars.setPrePage();
        }
    }

    //全屏时显示logo
    Image{
        z: 1
        width: 70 * fullHeights / 900
        height: width * 1.2
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 8 * fullHeights / 900
        anchors.topMargin: 15 * fullHeights / 900
        source: "qrc:/images/maxlogo.png"
        visible: fullScreenType ? true : false
    }

    //背景颜色
    Rectangle{
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        color:  "#f7f7f7"//"#eeeeee"

        //*******************************************
        CloudModifyPageView
        {
            id:cloudModifyPageView
            width: 100 * heightRate
            height: 105 * heightRate
            z:1000
            anchors.left: fullScreenBtn.right
            anchors.leftMargin: 300 * heightRate
            anchors.verticalCenter: bottomToolbars.verticalCenter
            onSigAnswer:
            {
                knowledgesView.open();
                trailBoardBackground.sendOpenAnswerParse(cloudRoomMenu.planId,cloudRoomMenu.columnId,knowledgesView.currentQuestionId,knowledgesView.currentChildQuestionId,true)
            }
            onSigModify:
            {
                //modifyHomework.open();
                trailBoardBackground.sendOpenCorrect(cloudRoomMenu.planId,cloudRoomMenu.columnId,knowledgesView.currentQuestionId,knowledgesView.currentChildQuestionId,true)
            }
        }

        CloudTipView
        {
            id:cloudTipView
            anchors.centerIn: cloudTipView.parent
            z:1000
            visible: false

        }

        YMHomeworkManagerAdapter
        {
            id:yMHomeworkManagerAdapter
        }

        //题型显示界面
        ShowQuestionHandlerView{
            id:showQuestionHandlerView
            width: trailBoardBackground.width
            height: trailBoardBackground.height
            z:5
            x:trailBoardBackground.x
            y:trailBoardBackground.y
            //visible: false
            onVisibleChanged:
            {
                if(visible)
                {
                    console.log("on showquestionHandlerView visiblechange")
                    trailBoardBackground.visible = false;
                    //bottomToolbars.visible = false;
                }
            }
            onIsDoRights:
            {
                addAnswerView.resetBottomOperationView(isRight);
            }
            //提交学生答案到服务器
            onSigSaveStudentAnswer:
            {
                cloudRoomMenu.savaStudentAnswerToserver(useTime,studentSelectAnswer,ownerData,isFinished,imageAnswers,childQId)
            }

            //做题模式下 改变添加答案界面的显示
            onResetAddAnswerViewShowModel:
            {
                if(qtype <= 3)
                {
                    addAnswerView.currentBeShowedModel = 1;
                }

                if(qtype >= 4)
                {
                    addAnswerView.currentBeShowedModel = 2;
                }
            }
            //            Component.onCompleted:
            //            {
            //                getQuestionItems(Cfg.jiandati);
            //                showQuestionHandlerView.curreBeShowedModel = 1;
            //                addAnswerView.visible = true;
            //            }
        }

        //显示已做题型图
        CloudPictureScrollView{
            id: pictureScrollView
            visible: false
            width: midWidth
            height: midHeight - 50  * fullHeights / 900
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: midWidthX
            anchors.topMargin: midHeightY
            imageUrl: ""
        }

        //综合题 显示界面
        CloudCompositeTopicView{
            id: compositeTopicView
            visible: false
            anchors.fill: showQuestionHandlerView
            z:5
            //是否有多个子题目
            onSigIsMultipleTopic: {
                console.log("=======SigIsMultipleTopic======")
                addAnswerView.visible = true;
                addAnswerView.showNextProButton();
            }
            //是否显示做题按钮
            onSigShowFinishedButton:
            {
                //显示做题按钮
                addAnswerView.showFnishedWorkButton();
            }
            onSigJumpTopic: {
                if(jump == "pre")
                {
                    cloudRoomMenu.preTopic();
                    exercisePage.prePage();
                }
                if(jump == "next")
                {
                    cloudRoomMenu.nextTopic();
                    exercisePage.nextPage();
                }

            }

        }

        //答案添加面板
        AddAnswerView
        {
            id:addAnswerView
            width: midWidth
            height: midHeight + 40 * fullHeights / 900
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: midWidthX
            anchors.bottomMargin: 10 * fullHeights / 900
            color: "transparent"
            visible: false;
            z:100
            onAddWrittingAnswer:
            {
                //            trailBoardBackground.visible = true;
                //            showQuestionHandlerView.visible = false;
                //            trailBoardBackground.isHandl = true;
                //            toobarWidget.teacherEmpowerment = true;
                //            //addAnswerView.visible = false;
                //            brushWidget.setPenColor();
                //            brushWidget.setPenWidth();
            }
            //做好了信号
            onSigFinishedWork:
            {
                console.log("  onSigFinishedWork:       22222222")
                if(compositeTopicView.visible == true)
                {
                    compositeTopicView.answerSubmit(imageUrlString);
                }else
                {
                    showQuestionHandlerView.imageAnswer = imageUrlString;
                    showQuestionHandlerView.answerSubmit();
                }
            }
            onSigShowAnswerDetail:
            {
                if(addAnswerView.currentBeShowedModel == 1)
                {
                    showQuestionHandlerView.showAnswerDetail();
                }
                else
                {
                    knowledgesView.open();
                }
            }

            onSigPage: {
                if(status == "pre"){//上一题
                    if(compositeTopicView.visible){
                        compositeTopicView.updateTopicBody(status);
                    }
                    return;
                }
                if(status == "next"){//下一题
                    if(compositeTopicView.visible){
                        compositeTopicView.updateTopicBody(status);
                    }
                    return;
                }
            }
            onSigShowAddAnswerPhoto:
            {
                showAddAnserIamge.source = imageFileUrl;
                showAddAnserIamge.parent.visible = true;
            }
            onSigDeleteImageTip:
            {
                deleteImageTips.parent.visible = true;
            }
        }

        Rectangle
        {
            anchors.fill: parent
            z:1000
            visible: false
            Image {
                id: showAddAnserIamge
                anchors.centerIn: parent
                width: parent.width
                height: parent.width * showAddAnserIamge.sourceSize.height / showAddAnserIamge.sourceSize.width
            }
            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    console.log(" id: showAddAnserIamge")
                    parent.visible = !parent.visible;
                }
            }

        }
        //图片删除二次确认
        Rectangle
        {
            anchors.fill: parent
            z:1001
            visible: false
            color: Qt.rgba(0.5,0.5,0.5,0.6)
            MouseArea
            {
                anchors.fill: parent
                onClicked: {
                    return;
                }
            }

            CloudDeleteImageTip
            {
                id:deleteImageTips
                width: 240.0 *  parent.width / 1440
                height:  137.0 *  parent.height / 900
                anchors.centerIn: parent
                onSigDeleteImage:
                {
                    addAnswerView.deleteImage();
                    deleteImageTips.parent.visible = false;
                }
                onSigNotDeleteImage:
                {
                    deleteImageTips.parent.visible = false;
                }
            }

        }

        //上一题下一题
        CloudExercisePageView{
            id: exercisePage
            z: 2
            visible:false
            width: midWidth
            height: 120 * heightRate
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: midWidthX - 5
            isVisiblePage :true

            //上一题、下一题信号
            onSigPage: {
                console.log(" //上一题、下一题信号 onSigPage",status,compositeTopicView.visible);
                if(status == "pre"){//上一题
                    if(compositeTopicView.visible){
                        compositeTopicView.updateTopicBody(status);
                    }else{
                        cloudRoomMenu.preTopic();
                        exercisePage.prePage();
                    }
                    return;
                }
                if(status == "next"){//下一题
                    if(compositeTopicView.visible){
                        compositeTopicView.updateTopicBody(status);
                    }else{
                        cloudRoomMenu.nextTopic();
                        exercisePage.nextPage();
                    }
                    return;
                }
            }
            //跳转某一题
            onSigJumpPage: {
                cloudRoomMenu.jumpPage(pages);
            }
        }

        //批改页面
        CloudModifyHomeworkView{
            id: modifyHomework
            height: trailBoardBackground.height
            //y:showQuestionHandlerView.y
            //x:showQuestionHandlerView.x + showQuestionHandlerView.width - knowledgesView.width -knowledgesView.width
            y:trailBoardBackground.y
            x:trailBoardBackground.x + trailBoardBackground.width - modifyHomework.width
            visible: false
            onVisibleChanged:
            {
                if(visible == false)
                {
                    trailBoardBackground.sendOpenCorrect(cloudRoomMenu.planId,cloudRoomMenu.columnId,knowledgesView.currentQuestionId,knowledgesView.currentChildQuestionId,false)
                }
            }

            onClosed: {
                // trailBoardBackground.closeCorrect(mainView.planId,mainView.columnId,mainView.currentQuestionId);
            }
        }

        //答案解析
        KnowledgesView{
            id: knowledgesView
            height: trailBoardBackground.height
            y:trailBoardBackground.y
            x:trailBoardBackground.x + trailBoardBackground.width - knowledgesView.width
            visible: false

            onVisibleChanged:
            {
                //学生自己关闭了"答案解析"窗口, 则发送关闭的命令, 给老师
                //如果是老师发命令要求学生关闭"答案解析"窗口的, 则不用发命令了
                if(visible == false && !knowledgesView.bCloseCommandIsFromTeacher)
                {
                    trailBoardBackground.sendOpenAnswerParse(cloudRoomMenu.planId,cloudRoomMenu.columnId,knowledgesView.currentQuestionId,knowledgesView.currentChildQuestionId,false)
                }
            }
        }

        //课程讲义主菜单
        CloudRoomMeun{
            id:cloudRoomMenu
            visible: false
            width: 200 * widthRate
            height: 63 * heightRate
            anchors.top: parent.top
            x:trailBoardBackground.x + trailBoardBackground.width / 2 - width / 2
            z:105

            onSigShowItemNamesInMainView:
            {
                midTipTexts.text = itemName;
            }

            onVisibleChanged:
            {

                if(cloudRoomMenu.visible == true)
                {
                    cloudRoomMenu.visible = cloudRoomMenu.getModelCount() > 1 ? true : false;
                }

                if(fullScreenType)
                {
                    cloudRoomMenu.visible = false;
                    bottomToolbars.visible = false;
                }
            }

            //显示更新学习目标View 知识梳理View 都是富文本显示
            onSigLearningTargets:
            {
                console.log("显示更新学习目标View",dataObjecte,index);
                compositeTopicView.visible = false;
                showQuestionHandlerView.curreBeShowedModel = 2;
                showQuestionHandlerView.visible = true;
                showQuestionHandlerView.setCurrentBeShowedView(dataObjecte,0);
            }
            onApplyPage: {
                //trailBoardBackground.setApplyPage()
                cloudTipView.setNoPowerTip();
            }

            //显示更新知识梳理View
            onSigKnowledgeCombs:
            {
                trailBoardBackground.visible = false;
                console.log("显示更新知识梳理View",dataObjecte,index);
                var resourceContents = targetData.resourceContents;
                for(var i =0; i <resourceContents.length; i++){
                    targetText.text = resourceContents[i].content;
                    console.log("======onSigLearningTargets========",resourceContents[i].content);
                    break;
                }
                addAnswerView.visible = false;
            }
            //显示更新典型例题View 课堂联系View 题目显示
            onSigTypicalExamples:
            {
                console.log("显示更新典型例题View",dataObjecte,index);
                compositeTopicView.visible = false;
                compositeTopicView.currentShowView = 2;
                showQuestionHandlerView.curreBeShowedModel = 2;
                getQuestionItems(dataObjecte);
                addAnswerView.visible = false;//隐藏做题面板
            }
            //显示更新课堂联系View
            onSigClassroomPractices:
            {
                trailBoardBackground.visible = false;
                //console.log("显示更新课堂联系View",JSON.stringify(dataObjecte),index);
                console.log("显示更新课堂联系View",index);
                compositeTopicView.visible = false;
                compositeTopicView.currentShowView = 2;
                showQuestionHandlerView.curreBeShowedModel = 2;
                getQuestionItems(dataObjecte);
                addAnswerView.visible = false;
                console.log("显示更新课堂联系 2 View",index);
            }


            //显示老师所发的练习题进行练习
            onSigTeacherSendQuestionDatas:
            {
                trailBoardBackground.visible = false;

                var type = questionData.questionType

                compositeTopicView.visible = false;
                console.log(questionData,findDatas.planId,findDatas.columnId,findDatas.questionId);
                console.log("onSigTeacherSendQuestionDatas:",findDatas,questionData,type);

                //隐藏预览模式的翻页界面
                exercisePage.visible = false;
                bottomToolbars.visible = false;
                //做题模式

                if(type < 6)
                {
                    showQuestionHandlerView.currentQuestionOwnerData = findDatas;
                    showQuestionHandlerView.curreBeShowedModel = 1;
                }
                else
                {
                    compositeTopicView.ownerDatas = findDatas;
                    compositeTopicView.currentShowQuestionType = type;
                    compositeTopicView.currentShowView = 1;
                }

                //分配数据
                getQuestionItems(questionData);

                //显示答题操作栏
                addAnswerView.visible = true;
                addAnswerView.showFnishedWorkButton();

            }
            onSigUploadStudentAnswerBackDatas:
            {
                console.log("onSigUploadStudentAnswerBackDatas:",isSuccess, findData,isFinished);
                if(isFinished == 1)//所有的题都传结束了
                {
                    trailBoardBackground.sendAnsweerToTeacher(findData);
                }


            }

            //讲义题目显示上一题下一题
            onSigShowPages: {
                console.log("讲义题目显示上一题下一题",currentPages,totalPages);
                exercisePage.currentPage = currentPages;
                exercisePage.totalPage = totalPages;
                exercisePage.isVisiblePage = true;
                //exercisePage.visible = true;****
            }

            //显示答案解析面板
            onSigShowAnswerAnalyseViews:
            {
                knowledgesView.dataModel = questionDatas;
                //knowledgesView.answerModel = questionDatas.answer
                knowledgesView.childQuestionInfoModel = questionDatas.childQuestionInfo;
                knowledgesView.open();
            }

            //显示批改界面
            onSigShowCorrectViews:
            {
                modifyHomework.dataModel = questionDatas;
                if(modifyHomework.isVisbles)
                {
                    modifyHomework.open();
                }
            }

            onSigExplainMode:
            {
                console.log("====onSigExplainMode====",itemId, planId, questionId,itemType)
                //发送命令 页数
                trailBoardBackground.selectedMenuCommand(1,planId,itemId);

            }

        }


        Image {
            id: titelImg
            //source: "qrc:/images/pc_fixtitle_bg@2x.png"
            width: trailBoardBackground.width
            height:width / ( 1150 / 46 )
            anchors.bottom: trailBoardBackground.top
            anchors.left: parent.left
            anchors.leftMargin: fullScreenType ? fullWidthX : (midWidthX - 15 * fullWidths / 1440.0)
            visible: cloudRoomMenu.visible && couldUseNewBoard
            onWidthChanged:
            {
                console.log(" id: titelImg",width,height)
            }

            Rectangle
            {
                width: parent.width
                height:width / ( 1150 / 46 )
                color: "#FFFFFF"
                anchors.bottom: parent.bottom
                Rectangle
                {
                    width: parent.width
                    height: 1
                    color: "#EAEAEA"
                    anchors.bottom: parent.bottom
                }
            }

            Text {
                anchors.right: midTipTexts.left
                anchors.rightMargin: 20 * heightRate
                text: qsTr("——")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 21 * heightRate
                color: "#CECECE"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: midTipTexts
                anchors.centerIn: parent
                text: qsTr("知识梳理")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 20 * heightRate
                color: "#737373"
            }

            Text {
                anchors.left: midTipTexts.right
                anchors.leftMargin: 20 * heightRate
                text: qsTr("——")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 21 * heightRate
                color: "#CECECE"
                anchors.verticalCenter: parent.verticalCenter
            }

            onVisibleChanged:
            {

                if(trailBoardBackground.width == midWidth)
                {
                    trailBoardBackground.anchors.leftMargin = midWidthX - 15 * fullWidths / 1440.0
                    trailBoardBackground.anchors.topMargin = titelImg.visible ? midHeightYs : midHeightY;
                    if(!couldUseNewBoard)
                    {
                        trailBoardBackground.anchors.topMargin = (mainView.height - trailBoardBackground.height) / 2
                    }
                }else
                {

                }

            }
        }

        //画布
        TrailBoardBackground{
            id:trailBoardBackground
            width: midWidth
             height: couldUseNewBoard ? midWidth * 9 / 16 : midWidth * 10 / 16 //midHeight
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: midWidthX - 15 * heightRates
            anchors.topMargin: titelImg.visible ? midHeightYs : midHeightY

            Component.onCompleted:
            {
                setFullScrreen(false);
            }

            onSigGetUnsatisfactoryOptionsT:
            {
                popupWidget.upTipEvaluateWidgetItem(optionData);
            }

            //获取课件列表失败
            onSigGetLessonListFails:
            {
                popupWidget.setPopupWidget("getLessonListFail");
            }
            onSigInterNetworks: {
                videoToolBackground.networkStatus = networkStatus;
            }

            //发送离开教室的姓名跟类型
            onSendExitRoomName: {

                popupWidget.setExitRoomName( types , cname)
            }
            //控制视频流
            onSigVideoAudioUrls: {
                if(avType == "video") {
                    audioPlayer.stopVideo();
                    if(controlType == "stop") {
                        mediaPlayer.stopVideo();
                        mediaPlayer.visible = false;
                        return;
                    }

                    if(controlType == "play") {
                        mediaPlayer.pauseVideo();
                        mediaPlayer.playTipContentTimes = parseInt(startTime) * 1000;
                        mediaPlayer.setAudioUrl(avUrl);
                    }else{
                        mediaPlayer.playStatues = false;

                    }
                    mediaPlayer.visible = true;

                }
                if(avType == "audio") {
                    mediaPlayer.stopVideo();
                    mediaPlayer.visible = false;
                    if(controlType == "stop") {
                        audioPlayer.stopVideo();
                        return;
                    }
                    if(controlType == "play") {
                        audioPlayer.pauseVideo();
                        audioPlayer.playTipContentTimes = parseInt(startTime) * 1000;
                        audioPlayer.setAudioUrl(avUrl);
                    }else{
                        audioPlayer.playStatues = false;
                    }
                    return;
                }
            }

            //当前页
            onSigChangeCurrentPages: {
                bottomToolbars.currentPage = pages;
                cloudModifyPageView.visible = false;
                //                trailBoardBackground.visible = true;
                //                bottomToolbars.visible = true;
                //                fullScreenBtn.visible = true;
            }
            //总页数
            onSigChangeTotalPages: {
                bottomToolbars.totalPage = pages;
            }
            //开始上课
            onSigStartClassTimeData: {
                brushWidget.setPenColor();
                brushWidget.setPenWidth();
                videoToolBackground.setStartClassTimeData(times);
                popupWidget.setPopupWidget("startclass");
                if(videoToolBackground.isUserPagePermissions() ){
                    bottomToolbars.whetherAllowedClick = true;
                    cloudRoomMenu.whetherAllowedClick = true;
                    addAnswerView.whetherAllowedClick = true;
                }else {
                    bottomToolbars.whetherAllowedClick = false;
                    cloudRoomMenu.whetherAllowedClick = false;
                    addAnswerView.whetherAllowedClick = false;
                }
                //  console.log("bottomToolbars.whetherAllowedClick times ===",bottomToolbars.whetherAllowedClick,"times ==",times);

                //测试
                // mediaPlayer.setVideoContents("http://118.31.65.79/abc.mp4","无敌风火轮")
                //  audioPlayer.setAudioUrl("http://118.31.65.79/abcd.mp3")
            }
            onSigPromptInterfaceHandl: {

                //console.log("inforces === on main qml ",inforces)
                if(inforces == "68") {
                    videoToolBackground.handlPromptInterfaceHandl(inforces);
                    return;
                }

                //处理老师结束课程 为a学生
                if(inforces == "65") {
                    popupWidget.setPopupWidget(inforces);
                    return;
                }

                if(inforces == "0" || inforces == "1" ) {
                    popupWidget.setPopupWidget(inforces);
                    return;
                }
                if(inforces == "2") {
                    popupWidget.setPopupWidget(inforces);
                    return;
                }
                //申请离开教室的返回
                if(inforces == "63" || inforces == "64" ){
                    popupWidget.setPopupWidget(inforces);
                    return;
                }

                if(inforces == "80") {
                    popupWidget.setPopupWidget(inforces);
                    return;
                }

                //申请进入教室的返回 b
                if(inforces == "66" || inforces == "67" ){
                    if(inforces == "66") {//同意进入
                        videoToolBackground.setStartClassTimeData(videoToolBackground.getStartClassTimelen());
                        // bottomToolbars.whetherAllowedClick = false;
                    }

                    popupWidget.setPopupWidget(inforces);
                    return;
                }

                videoToolBackground.handlPromptInterfaceHandl(inforces);
                //改变权限
                if(inforces == "62") {
                    if(videoToolBackground.getUserBrushPermissions() == "1"){
                        toobarWidget.teacherEmpowerment = true;
                    }
                    else
                    {
                        toobarWidget.teacherEmpowerment = false;
                    }

                    return;
                }
                //翻页
                if(inforces == "70" || inforces == "71" || inforces == "72") {
                    if(videoToolBackground.isUserPagePermissions() ){
                        bottomToolbars.whetherAllowedClick = true;
                        cloudRoomMenu.whetherAllowedClick = true;
                        addAnswerView.whetherAllowedClick = true;
                    }else {
                        bottomToolbars.whetherAllowedClick = false;
                        cloudRoomMenu.whetherAllowedClick = false;
                        addAnswerView.whetherAllowedClick = false;
                    }
                    return;
                }

                //上过课
                if(inforces == "22") {
                    //console.log("inforces ===",inforces);
                    //toobarWidget.teacherEmpowerment = false;
                    bottomToolbars.whetherAllowedClick = true;
                    cloudRoomMenu.whetherAllowedClick = true;
                    addAnswerView.whetherAllowedClick = true;
                    return;
                }
                //同意结束课程
                if(inforces == "56"){
                    popupWidget.setPopupWidget(inforces);
                }

                //自动切换ip
                if(inforces == "showAutoChangeIpview" || inforces == "autoChangeIpSuccess" || inforces == "autoChangeIpFail" ){
                    popupWidget.setPopupWidget(inforces);
                    return;
                }
            }

            onSigSendCoursewareErrorToServer:
            {
                //发送课件错误类型
                trailBoardBackground.setSigSendIpLostDelays(errorString);
            }

            //新课件的信号
            //显示新课件
            onSigShowNewCoursewares:
            {
                console.log("新课件的信号",JSON.stringify( coursewareData));
                //隐藏老的界面
                trailBoardBackground.visible = false;
                //bottomToolbars.visible = false;
                fullScreenBtn.visible = false;
                //加载新的加载新的界面 （顶部导航显示  中间对应模块显示）
                //显示顶部导航
                cloudRoomMenu.visible = true;
                cloudRoomMenu.visible = cloudRoomMenu.getModelCount() > 1 ? true : false;
                //顶部导航栏重设
                cloudRoomMenu.planId = coursewareData.planId;
                cloudRoomMenu.planName = coursewareData.planName;
                cloudRoomMenu.dataModels = coursewareData.columns;
                console.log("onSigShowNewCoursewares: cloudRoomMenu.",cloudRoomMenu.planId,cloudRoomMenu.visible,coursewareData.columns)
                addAnswerView.hideTcheckAndAswDetail();//隐藏 老师批改和 答案解析
                addAnswerView.visible = false;
            }

            //显示新课件对应item
            onSigShowNewCoursewareItems:
            {
                trailBoardBackground.visible = false;
                //bottomToolbars.visible = false;
                fullScreenBtn.visible = false;
                //更新顶部导航的选中项  发出信号显示对应的项
                cloudRoomMenu.visible = true;
                cloudRoomMenu.updateSelectedIndexByteacher(coursewareItemData);
                addAnswerView.hideTcheckAndAswDetail();//隐藏 老师批改和 答案解析
                addAnswerView.visible = false;
                bottomToolbars.visible = true;
            }

            //开始做题
            onSigStarAnswerQuestions:
            {
                trailBoardBackground.visible = false;
                //bottomToolbars.visible = false;
                fullScreenBtn.visible = false;
                console.log("开始做题开始做题");
                cloudTipView.setStartAnswerQuestion();
                //获取题目数据
                cloudRoomMenu.getTeacherSendQuestionData(questionData,1);
            }

            //停止做题
            onSigStopAnswerQuestions:
            {
                trailBoardBackground.visible = false;
                //bottomToolbars.visible = false;
                fullScreenBtn.visible = false;
                addAnswerView.stopAnswerByOrder();
            }

            //打开答案解析
            onSigOpenAnswerParsings:
            {
                console.log("onSigOpenAnswerParsings",JSON.stringify(questionData),questionData.childQuestionId)
                knowledgesView.currentChildQuestionId = questionData.childQuestionId;
                cloudRoomMenu.getTeacherSendQuestionData(questionData,2);
            }

            //关闭答案解析
            onSigCloseAnswerParsings:
            {
                knowledgesView.bCloseCommandIsFromTeacher = true; //标记: 关闭"课程解析"的命令, 是来自老师的, 与自己关闭的区分开来
                knowledgesView.close();
                knowledgesView.bCloseCommandIsFromTeacher = false;
            }

            //打开批改View
            onSigOpenCorrects:
            {
                cloudRoomMenu.getTeacherSendQuestionData(questionData,3);
                modifyHomework.isVisbles = isVisible;
                if(isVisible)
                {
                    modifyHomework.open();
                }
            }
            onSigCorrects:
            {
                //modifyHomework.open();
                //答案批改
                console.log("答案批改信号",JSON.stringify(questionData));
                modifyHomework.resetModifyView(questionData)

            }

            //关闭批改View
            onSigCloseCorrects:
            {
                modifyHomework.close();
            }

            onSigAutoPictures:
            {
                console.log("onSigAutoPictures:自动转图 ",questionData);

                //开始做题弹窗
                cloudTipView.setStartDetailQuestion();

                //进入批改模式
                //hideNewCursorView();
                //显示批改按钮
                addAnswerView.showTcheckAndAswDetail();

                //修改缓存数据
                cloudRoomMenu.resetAllCourseware();

            }
        }

        //提示框
        Rectangle{
            id:toopBracund
            color: "#3C3C3E"
            opacity: 0.6
            width: 400 * trailBoardBackground.widthRates
            height: 40 * trailBoardBackground.heightRates
            z:20
            anchors.left: trailBoardBackground.left
            anchors.bottom: trailBoardBackground.bottom
            anchors.leftMargin:  trailBoardBackground.width / 2 - 100 * trailBoardBackground.widthRates
            anchors.bottomMargin: 100 * trailBoardBackground.heightRates
            visible: false
            radius: 5 * trailBoardBackground.heightRates
            onVisibleChanged: {
                toopBracundTimer.stop();
                if(visible){
                    toopBracundTimer.start();
                }
            }

            Timer {
                id:toopBracundTimer
                interval: 2000;
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
                anchors.leftMargin: 20 * trailBoardBackground.heightRates
                anchors.topMargin:   20 * trailBoardBackground.heightRates  - 10 * trailBoardBackground.ratesRates
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


        //底部工具栏
        BottomToolbars{
            id:bottomToolbars
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 600  * fullWidths / 1440// + 20  * fullHeights / 900
            // anchors.bottomMargin:  5  * fullHeights / 900
            width: 260 * fullWidths / 1440  //+ 40  * fullHeights / 900
            height: 50 * fullHeights / 900
            z:10
            hasTeacherEmpowerment:toobarWidget.teacherEmpowerment ;
            visible: fullScreenType ? false : true

            onSigNoTeacherEmpowerment:
            {
                toobarWidget.noSelectPower();
            }

            onSigJumpPage: {
                trailBoardBackground.jumpToPage(pages);
            }
            onApplyPage: {
                trailBoardBackground.setApplyPage()
            }
            onAtLastPage:
            {
                trailBoardBackground.setLastPageRemind();
            }
            onAtFirstPage:
            {
                trailBoardBackground.setFirstPageRemind();
            }


        }

        //右边视频工具栏
        VideoToolBackground{
            id:videoToolBackground
            width: rightWidth + borderShapeLen
            height: rightHeight
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: rightWidthX - borderShapeLen
            anchors.topMargin: rightWidthY
            visible: fullScreenType ? false : true
            onSigCloseWidget: {
                if(studentType == "A") {
                    if(videoToolBackground.justTeacherOnline() ) {
                        popupWidget.setPopupWidget("close");

                    }else {
                        trailBoardBackground.disconnectSockets();
                        externalCallChanncel.closeAlllWidget()
                    }
                }else {
                    popupWidget.setPopupWidget("bclose");

                }

            }

            onSigRequestVideoSpans:
            {
                trailBoardBackground.setRequestVideoSpans();
            }

            //控制本地摄像头
            onSigOperationVideoOrAudio: {
                trailBoardBackground.setOperationVideoOrAudio(userId ,  videos ,  audios , pingValue);
            }

            onSigCreatRoomFails:
            {
                trailBoardBackground.createRoomFail();
            }

            onSigCreatRoomSuccess:
            {
                trailBoardBackground.createRoomSuccess();
            }

        }

        YMTipNetworkView{
            id: networkView
            z: 99999
            width:rightWidth + 20 * heightRate
            height:  160 * heightRate
            x: parent.width - rightWidth - 10 * heightRate
            y: 50 * heightRate
        }
        //全屏按键
        MouseArea{
            id:fullScreenBtn
            width: 40 * fullHeights / 900
            height: 40 * fullHeights / 900
            anchors.left: bottomToolbars.right
            anchors.verticalCenter: bottomToolbars.verticalCenter
            hoverEnabled: true

            Image {
                id: fullScreenBtnImage
                anchors.left: parent.left
                anchors.top: parent.top
                width: parent.width
                height: parent.height
                source: fullScreenType ? ("qrc:/newStyleImg/pc_btn_smallscreen@2x.png") : ("qrc:/newStyleImg/pc_btn_fullscreen@2x.png")
            }

            onClicked: {
                fullScreenBtn.focus = true;
                fullScreenType = !fullScreenType;
                console.log("ssssssssssssss",knowledgesView.visible);
                setFullScrreen(fullScreenType);
                console.log("ssssssssssssss",knowledgesView.visible);
            }

        }

        //工具栏
        ToobarWidget{
            id:toobarWidget
            width: leftMidWidth //+ 12.0 * leftMidWidth / 66
            height: leftMidHeight + 45.0  * leftMidWidth  / 66
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin:  - 3.0 * leftMidWidth  / 66
            anchors.topMargin:  - 5.0  * leftMidWidth  / 66
            visible:  fullScreenType ? false : true
            MouseArea{
                anchors.fill: parent
                z:100
                enabled: toolBarIsCanClick
                onClicked: {
                    return;
                }
            }
            onNoSelectPower:
            {
                popupWidget.setPopupWidget("noselectpower");
            }

            onSigSendFunctionKey: {
                //画笔
                if(keys == 1) {
                    if(brushWidget.focus == false) {
                        brushWidget.focus = true;
                        brushWidget.setPenColor();
                        brushWidget.setPenWidth();

                    }else {
                        brushWidget.focus = false;

                    }

                    return;
                }
                //橡皮擦
                if(keys == 2) {
                    if(eraserWidget.focus == false) {
                        eraserWidget.focus = true;

                    }else {
                        eraserWidget.focus = false;

                    }

                    return;
                }

                //表情
                if(keys == 3){
                    if ( interfaceWidget.focus == false ){
                        interfaceWidget.focus = true;
                    }else{
                        interfaceWidget.focus = false;

                    }
                    return;
                }

                //截图
                if(keys == 4) {
                    if( pictureWidget.focus == false) {
                        pictureWidget.focus = true;
                    } else {
                        pictureWidget.focus = false;

                    }
                    return;
                }

                //几何图形
                if(keys == 5) {
                    if(graphicWidget.focus == false) {
                        graphicWidget.focus = true;
                    }else {
                        graphicWidget.focus = false;

                    }
                    return;
                }
                //网络优化
                if(keys == 6) {
                    //                    if(detectionNetwork.focus == false) {
                    //                        detectionNetwork.focus = true;
                    //                    }else {
                    //                        detectionNetwork.focus = false;

                    //                    }
                    return;
                }


            }

        }

        //画笔操作
        BrushWidget{
            id:brushWidget
            anchors.left: toobarWidget.right
            anchors.leftMargin: -8 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin: 77 * fullHeight / 900//80 * fullHeights / 900
            width: 255 * widthRate * 0.8
            height: 198  * widthRate * 0.8
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
                toobarWidget.handlBrushImageColor(penColors);
                //setBrushImage();
            }
            onSendPenWidth: {
                trailBoardBackground.changeBrushSizes(penWidths);
                //setBrushImage();

            }

        }

        //橡皮
        EraserWidget{
            id:eraserWidget
            anchors.left: toobarWidget.right
            anchors.leftMargin: -6 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin:  58 * 2 * leftMidWidths + 28 * leftMidWidths
            width: 268 * heightRate / 2.2
            height: 264  * heightRate / 2.2
            z:10
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
                toobarWidget.handlEraserImageColor(types);

            }

        }

        //表情
        InterfaceWidget{
            id:interfaceWidget
            anchors.left: toobarWidget.right
            anchors.leftMargin: -8 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin: 58 * 3 * leftMidWidths - 100 * leftMidWidths
            width: 308 * widthRate * 0.9
            height: 274  * widthRate * 0.9
            z:100
            visible: false
            focus: false
            onFocusChanged: {
                if(interfaceWidget.focus) {
                    interfaceWidget.visible = true;
                }else {
                    interfaceWidget.visible = false;

                }
            }
            onSigSendHttpsUrl: {
                trailBoardBackground.focus = true;
                trailBoardBackground.setInterfaceUrl(urls);

            }

        }

        //截图
        PictureWidget{
            id:pictureWidget
            anchors.left: toobarWidget.right
            anchors.leftMargin: -6 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin:  58 * 4 * leftMidWidths + 20 * leftMidWidths
            width: 268 * heightRate / 2.5
            height: 264  * heightRate / 2.5
            z:10
            visible: false
            focus: false
            onFocusChanged: {
                if(focus) {
                    pictureWidget.visible = true;
                }else {
                    pictureWidget.visible = false;

                }
            }
            onSigUpLoadPicture: {
                trailBoardBackground.focus = true;
                trailBoardBackground.setUpLoadPicture();

            }
            onSigScreenShotPicture: {
                trailBoardBackground.focus = true;
                trailBoardBackground.setScreenShotPicture();
                //   screenshotSaveImage.grabImage(idTrailItem);
            }

        }

        //几何界面
        GraphicWidget{
            id:graphicWidget
            anchors.left: toobarWidget.right
            anchors.leftMargin: -10 * fullWidths / 1440
            anchors.top:  parent.top
            anchors.topMargin:  58 * 5 * leftMidWidths + 18 *   leftMidWidths
            width: 258 * widthRate * 0.65
            height: 60 * widthRate * 0.65
            z:10
            visible: false
            focus: false
            onFocusChanged: {
                if(focus) {
                    graphicWidget.visible = true;
                }else {
                    graphicWidget.visible = false;

                }
            }
            onSigPolygon: {
                trailBoardBackground.focus = true;
                trailBoardBackground.setDrawPolygon(polygons);
            }
        }

        //设备检测
        DetectionNetwork{
            id:detectionNetwork
            anchors.left: trailBoardBackground.left
            anchors.top:   trailBoardBackground.top
            anchors.topMargin:  trailBoardBackground.height / 2  - 125  * fullHeights / 900
            anchors.leftMargin:  trailBoardBackground.width / 2 - 120 * fullWidths / 1440
            width: 240 * fullWidths / 1440
            height: 250  * fullHeights / 900
            z:100
            visible: false
            focus: false
            onFocusChanged: {
                if(detectionNetwork.focus) {
                    detectionNetwork.visible = true;
                }else {
                    detectionNetwork.visible = false;
                }
            }
            onSigCurrentNetStatus: {
                videoToolBackground.updateNetworkStatus(netStatus,netValue);
            }

            //发送当前网络状态
            onSigSendCurrentNetworks: {
                toobarWidget.networkIcon =  parseInt(status);

            }
            //切换网络
            onSigChangeOldIpToNews:{
                trailBoardBackground.setChangeOldIpToNews();

            }
            //发送延迟的信息
            onSigSendIpLostDelays:{
                trailBoardBackground.setSigSendIpLostDelays(strList);
            }

        }

        //音频播放
        AudioPlayer{
            id:audioPlayer
            visible: false
        }

        //视频播放器
        MediaPlayer{
            id:mediaPlayer
            width: 450 * fullWidths / 1440
            height: 330 * fullHeights / 900
            y:fullHeightY + ( fullHeight - mediaPlayer.height) / 2
            x:fullWidthX  + ( fullWidth - mediaPlayer.width) / 2
            z:17
            xPressedPosition:fullWidthX  + ( fullWidth - mediaPlayer.width) / 2
            yPressedPosition:fullHeightY + ( fullHeight - mediaPlayer.height) / 2
            visible: false
        }

        //学生的提示性弹窗
        PopupWidget{
            id:popupWidget
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            z:1800
            visible: true
            onSigCloseAllWidget: {
                trailBoardBackground.disconnectSockets();
                externalCallChanncel.closeAlllWidget()
            }
            onSelectWidgetType: {
                trailBoardBackground.setSelectWidgetType(types);
            }
            onSigEvaluateContent: {
                trailBoardBackground.sendEvaluateContent( content ,  attitude ,  homework ,  contentText);
            }
            onSigSaveStuEvaluations:
            {
                trailBoardBackground.saveStuEvaluationContents( stuSatisfiedFlag ,optionId , otherReason);
            }


            //留在教室
            onSigStayInclassroom: {
                trailBoardBackground.setStayInclassroom();
                videoToolBackground.setStayInclassroom();


            }
            onSigExitRoomName: {
                videoToolBackground.closeVideo();
                //videoToolBackground.handlPromptInterfaceHandl("68");
            }
            //结束课程请求
            onSigEndLesson: {
                trailBoardBackground.setEndLesson();
            }
            onClassOverView:
            {
                console.log("adsssssssssssssssss");
                videoToolBackground.closeVideo();
                videoToolBackground. classOverViewReset();
            }
        }

        ExternalCallChanncel{
            id:externalCallChanncel
        }

    }
    //题型显示
    function getQuestionItems(questionItemsData){
        var knowledgesModels = questionItemsData.knowledges //Cfg.zongheti.knowledges;
        var answerModel = questionItemsData.answer //Cfg.zongheti.answer;
        var questionItems = questionItemsData.questionItems //Cfg.zongheti.questionItems;
        var type = questionItemsData.questionType //Cfg.zongheti.questionType;
        //console.log("getQuestionItems(questionItemsData)",questionItemsData,answerModel,questionItems,type)

        //同步答案解析 批改界面数据
        modifyHomework.resetModifyView(questionItemsData);
        knowledgesView.dataModel = questionItemsData;
        //knowledgesView.answerModel = questionItemsData.answer
        knowledgesView.childQuestionInfoModel = questionItemsData.childQuestionInfo;

        if(type == 6){
            //综合题
            console.log("======综合题6=======")
            showQuestionHandlerView.visible = false;
            compositeTopicView.visible = true;
            compositeTopicView.dataModel = questionItemsData;

            return;
        }
        compositeTopicView.visible = false;

        //五大题型展示
        showQuestionHandlerView.knowledgesModels = knowledgesModels;
        showQuestionHandlerView.answerModel = answerModel;
        showQuestionHandlerView.questionItemsData = questionItems;
        showQuestionHandlerView.setCurrentBeShowedView(questionItemsData,type);
        showQuestionHandlerView.visible = true;

    }

    //显示老课件的时候用
    function hideNewCursorView()
    {
        console.log("显示老课件~~~~~~~~~~~~~~~~~~~~~")
        addAnswerView.visible = false;
        exercisePage.visible = false;
        // knowledgesView.visible = false;
        cloudRoomMenu.visible = false;
        showQuestionHandlerView.visible = false;
        compositeTopicView.visible = false;

        trailBoardBackground.visible = true;
        bottomToolbars.visible = true;
        fullScreenBtn.visible = true;
    }

    function openNewCoursewarePreview()
    {
        //答题面板隐藏
        //
    }

    //设置这几项: bottomToolbars, toobarWidget, cloudMenu 控件的enable状态
    //点击圆形, 或者几何图形的时候,
    //出现取消× 按钮, 和√按钮, 没有点击这两个按钮,
    //这个时候, 这些bottomToolbars, toobarWidget, cloudMenu 控件, 都不能操作
    function doEnableDisableControls(status)
    {
        bottomToolbars.enabled = status;
        toobarWidget.enabled = status;
        cloudRoomMenu.enabled = status;
        fullScreenBtn.enabled = status;
    }
}

