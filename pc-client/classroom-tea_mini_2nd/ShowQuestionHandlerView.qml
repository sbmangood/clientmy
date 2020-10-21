import QtQuick 2.7
import QtQuick.Controls 2.0
import YMHomeworkWrittingBoard 1.0
import "./Configuuration.js" as Cfg

/*
*处理题型显示的界面
*/

Rectangle {
    id: mainHandlerView
    color: "transparent"  //#ffffff
    border.width: 1
    border.color: "#f6f6f6"
    //存储所有题型

    property var questionItemsData: [];
    property var answerModel: [];
    property var knowledgesModels: [];
    property var resourceContent: [];
    property bool isScroll: true;
    property string baseImage: "";
    property bool isCompleStatus: false;//是否是综合题截图,false：不是， true：是
    property bool complexSuccess: false;
    //显示长图信号 status 0未做题 1为截图 2为批改 4完成 imgWidth:图片宽度 imgHeight:图片高度
    signal sigShowCorrectPage(var filePath,var status,var imgWidth,var imgHeight);

    /* 根据传入数据 来判断 数据属于那种提醒 从而来显示 对应题型的界面
        showData: 数据 ,
        type: 题目类型，
        browseStatus：截图模式,
        topicModel: 做题模式 1:做题、 2对答案
    */
    function setCurrentBeShowedView(showData,type,browseStatus,topicModel){
        hideView();
        console.log("====setCurrentBeShowedView====",type,browseStatus,isCompleStatus,JSON.stringify(showData));
        //副文本显示
        if(type == 0){
            if(showData.baseImage != null){
                baseImage = showData.baseImage.imageUrl;
                if(baseImage == ""){
                    targetText.text = showData.content;
                    textView.visible = true;
                    sigShowCorrectPage("",5,0,0);
                    return;
                }

                var imgHeight = showData.baseImage.height;
                var imgWidth = showData.baseImage.width;
                sigShowCorrectPage(baseImage,2,imgWidth,imgHeight);
                return;
            }
            sigShowCorrectPage("",5,0,0);
            targetText.text = showData.content;
            textView.visible = true;
            console.log("=====showData.content=====",showData.content);
            return;
        }

        //题型判断、数据传入 显示
        if(type == 1){//单选题            
            singleChoiceQuestionView.visible = true;
            singleChoiceQuestionView.setClipStatus(false,isCompleStatus);
            singleChoiceQuestionView.knowledgesModels = knowledgesModels;
            singleChoiceQuestionView.answerModel = answerModel;
            singleChoiceQuestionView.questionItemsModel = questionItemsData;
            singleChoiceQuestionView.updateMainView(showData,topicModel);

//            //截图模式
            if(browseStatus){
                singleChoiceQuestionView.setClipStatus(true,isCompleStatus);
            }
            return;
        }
        if(type == 2){//多选题
            multipleChoiceQuestionsView.updateClipStatus(false,isCompleStatus);
            multipleChoiceQuestionsView.knowledgesModels = knowledgesModels;
            multipleChoiceQuestionsView.answerModel = answerModel;
            multipleChoiceQuestionsView.questionItemsModel = questionItemsData;
            multipleChoiceQuestionsView.updateMainView(showData,topicModel);
            multipleChoiceQuestionsView.visible = true;
            //截图模式
            if(browseStatus){
                multipleChoiceQuestionsView.updateClipStatus(true,isCompleStatus);
            }
            return;
        }
        if(type == 3){//判断题
            judgmentQuestionView.updateClipStatus(false,isCompleStatus);
            judgmentQuestionView.knowledgesModels = knowledgesModels;
            judgmentQuestionView.answerModel = answerModel;
            judgmentQuestionView.questionItemsModel = questionItemsData;
            judgmentQuestionView.visible = true;
            judgmentQuestionView.updateMainView(showData,topicModel);

            //截图模式
            if(browseStatus){
                judgmentQuestionView.updateClipStatus(true,isCompleStatus);
            }
            return;
        }
        if(type == 4){//填空题
            fillBlankView.visible = true;
            fillBlankView.setClipStatus(browseStatus,isCompleStatus);
            fillBlankView.answerModel = answerModel;
            fillBlankView.knowledgesModels = knowledgesModels;
            fillBlankView.questionItemsModel = questionItemsData;
            fillBlankView.dataModel = showData;
            fillBlankView.isScroll = isScroll;
            console.log("===fillBlankView::browseStatus===",browseStatus,isCompleStatus);
            return;
        }

        if(type == 5){//简答题
            multipleChoiceView.visible = true;
            multipleChoiceView.setMultipleClipStatus(browseStatus,isCompleStatus);
            multipleChoiceView.answerModel = answerModel;
            multipleChoiceView.knowledgesModels = knowledgesModels;
            multipleChoiceView.questionItemsModel = questionItemsData;
            multipleChoiceView.dataModel = showData;
            multipleChoiceView.isScroll = isScroll;
            console.log("===multipleChoiceView::browseStatus===",browseStatus,isCompleStatus);
            return;
        }
    }

    //隐藏掉所有的页面
    function hideView(){
        complexSuccess = false;
        singleChoiceQuestionView.visible = false;
        multipleChoiceQuestionsView.visible = false;
        judgmentQuestionView.visible = false;
        fillBlankView.visible = false;
        multipleChoiceView.visible = false;
        textView.visible = false;
    }

    //截图处理
    YMHomeworkWrittingBoard{
        id: drawImageBoard
        onSigBeSavedGrapAnswer: {
            var currentStatus = isCompleStatus ?  6 : 1;
            if(complexSuccess){
                currentStatus = 1;
                isCompleStatus = false;
            }
            sigShowCorrectPage(imageUrl,currentStatus,imgWidth,imgHeight);
            console.log("=====YMHomeworkWrittingBoard::imageUrl====", imageUrl,imgWidth,imgHeight,currentStatus,isCompleStatus);
        }
    }

    function clipImage(object){
        drawImageBoard.grapItemImage(object);
        complexSuccess = true;
    }

    //学习目标显示副文本
    Flickable{
        id: textView
        clip: true
        visible: false
        width: parent.width
        height: parent.height
        contentHeight: targetText.height
        contentWidth: width

        Image{
            id: longImgs
            width: parent.width
            source: baseImage

            onStatusChanged: {
                longImgs.height = longImgs.sourceSize.height;
                textView.contentHeight = longImgs.sourceSize.height;
            }
        }

        Text {
            id: targetText
            visible: baseImage == "" ? true : false
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 14 * heightRate
            width: parent.width - 20 * widthRate
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
        }
    }

    //单选界面
    SingleChoiceQuestionView {
        id:singleChoiceQuestionView
        anchors.fill: parent
        visible: false;
        onSigCorrect:{
            console.log("======SingleChoiceQuestionView::imageUrl=======",imageUrl)
            sigShowCorrectPage(imageUrl,status,imgWidth,imgHeight);
        }
        onSigLoadingSuccess:{
            singleTime.restart();
            //drawImageBoard.grapItemImage(singleChoiceQuestionView.singleChoiceClipImage());
        }
    }
    //多选界面
    MultipleChoiceQuestionsView {
        id:multipleChoiceQuestionsView
        anchors.fill: parent
        visible: false
        onSigCorrect:{
            console.log("======MultipleChoiceQuestionsView::imageUrl=======",imageUrl)
            sigShowCorrectPage(imageUrl,status,imgWidth,imgHeight);
        }
        onSigLoadingSuccess: {
            multipleTime.restart();
            //drawImageBoard.grapItemImage(multipleChoiceQuestionsView.clipMultipleChoiceImage());
        }
    }
    //判断界面
    JudgmentQuestionView {
        id:judgmentQuestionView
        anchors.fill: parent
        visible: false;
        onSigCorrect:{
            console.log("======JudgmentQuestionView::imageUrl=======",imageUrl)
            sigShowCorrectPage(imageUrl,status,imgWidth,imgHeight);
        }
        onSigLoadingSuccess: {
            console.log("========JudgmentQuestionView::start::clip=========")
            judgmentTime.restart();
            //drawImageBoard.grapItemImage(judgmentQuestionView.clipJudgmentImage());
        }
    }

    //填空题
    CloudFillBlankView{
        id: fillBlankView
        anchors.fill: parent
        visible: false        
        onSigCorrect:{
            console.log("======CloudFillBlankView::imageUrl=======",imageUrl)
            sigShowCorrectPage(imageUrl,status,imgWidth,imgHeight);
        }
        onSigLoadingSuccess: {
            console.log("======CloudFillBlankView::clip======")
            fillblankTime.restart();
            //drawImageBoard.grapItemImage(fillBlankView.clipFillBalnkImage());
        }
    }

    //简答题
    CloudMultipleChoice{
        id: multipleChoiceView
        anchors.fill: parent
        visible: false
        onSigCorrect:{
            sigShowCorrectPage(imageUrl,status,imgWidth,imgHeight);
        }
        onSigLoadingSuccess: {
            answerTime.restart();
            //drawImageBoard.grapItemImage(multipleChoiceView.multipleChoiceClipImage());
        }
    }

    function displayerBlankPage(){
        multipleChoiceView.baseImages = "";
        fillBlankView.baseImages = "";
        judgmentQuestionView.baseImages = "";
        multipleChoiceQuestionsView.baseImages = "";
        singleChoiceQuestionView.baseImages = "";
        baseImage = "";

        multipleChoiceView.visible = false;
        fillBlankView.visible = false;
        judgmentQuestionView.visible = false;
        multipleChoiceQuestionsView.visible = false;
        singleChoiceQuestionView.visible = false;
        textView.visible = false;
    }

    //单选
       Timer{
           id: singleTime
           interval: 1000
           repeat: false
           running: false
           onTriggered: {
               drawImageBoard.grapItemImage(singleChoiceQuestionView.singleChoiceClipImage());
           }
       }

       //多选
       Timer{
           id: multipleTime
           interval: 1000
           repeat: false
           running: false
           onTriggered: {
               drawImageBoard.grapItemImage(multipleChoiceQuestionsView.clipMultipleChoiceImage());
           }
       }

       //判断
       Timer{
           id: judgmentTime
           interval: 1000
           repeat: false
           running: false
           onTriggered: {
               drawImageBoard.grapItemImage(judgmentQuestionView.clipJudgmentImage());
           }
       }

       //填空
       Timer{
           id: fillblankTime
           interval: 1000
           repeat: false
           running: false
           onTriggered: {
               drawImageBoard.grapItemImage(fillBlankView.clipFillBalnkImage());
           }
       }

       //简答
       Timer{
           id: answerTime
           interval: 1000
           repeat: false
           running: false
           onTriggered: {
               drawImageBoard.grapItemImage(multipleChoiceView.multipleChoiceClipImage());
           }
       }


}
