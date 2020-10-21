import QtQuick 2.7
import QtQuick.Controls 2.0
import "./Configuuration.js" as Cfg

/*
*处理题型显示的界面
*/

Rectangle {
    id: mainHandlerView
    color: "transparent"  //#ffffff
    //存储所有题型

    property var questionItemsData: [];
    property var answerModel: [];
    property var knowledgesModels: [];
    property var resourceContent: [];
    property bool isScroll: true;
    property string baseImage: "";
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
        //console.log("====setCurrentBeShowedView====",type,browseStatus,topicModel,JSON.stringify(showData));
        //副文本显示
        if(type == 0){
            if(showData.baseImage != null){
                baseImage = showData.baseImage.imageUrl;
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
            singleChoiceQuestionView.knowledgesModels = knowledgesModels;
            singleChoiceQuestionView.answerModel = answerModel;
            singleChoiceQuestionView.questionItemsModel = questionItemsData;
            singleChoiceQuestionView.updateMainView(showData,topicModel);

            //截图模式
            if(browseStatus){                
                drawImageBoard.grapItemImage(singleChoiceQuestionView.singleChoiceClipImage());
            }
            return;
        }
        if(type == 2){//多选题
            multipleChoiceQuestionsView.knowledgesModels = knowledgesModels;
            multipleChoiceQuestionsView.answerModel = answerModel;
            multipleChoiceQuestionsView.questionItemsModel = questionItemsData;
            multipleChoiceQuestionsView.updateMainView(showData,topicModel);
            multipleChoiceQuestionsView.visible = true;
            multipleChoiceQuestionsView.updateClipStatus(false);
            //截图模式
            if(browseStatus){
                multipleChoiceQuestionsView.updateClipStatus(true);                
            }
            return;
        }
        if(type == 3){//判断题
            judgmentQuestionView.knowledgesModels = knowledgesModels;
            judgmentQuestionView.answerModel = answerModel;
            judgmentQuestionView.questionItemsModel = questionItemsData;
            judgmentQuestionView.visible = true;
            judgmentQuestionView.updateMainView(showData,topicModel);

            //截图模式
            if(browseStatus){
                judgmentQuestionView.updateClipStatus(true);
            }
            return;
        }
        if(type == 4){//填空题
            fillBlankView.setClipStatus(false);
            fillBlankView.answerModel = answerModel;
            fillBlankView.knowledgesModels = knowledgesModels;
            fillBlankView.questionItemsModel = questionItemsData;
            fillBlankView.dataModel = showData;
            fillBlankView.visible = true;
            fillBlankView.isScroll = isScroll;

            //截图模式
            if(browseStatus){
                fillBlankView.setClipStatus(true);
            }
            return;
        }

        if(type == 5){//简答题
            multipleChoiceView.setMultipleClipStatus(false);
            multipleChoiceView.answerModel = answerModel;
            multipleChoiceView.knowledgesModels = knowledgesModels;
            multipleChoiceView.questionItemsModel = questionItemsData;
            multipleChoiceView.dataModel = showData;
            multipleChoiceView.visible = true;
            multipleChoiceView.isScroll = isScroll;

            //长图模式
            if(browseStatus){
                multipleChoiceView.setMultipleClipStatus(true);
                //drawImageBoard.grapItemImage(multipleChoiceView.multipleChoiceClipImage());
            }
            return;
        }
    }

    //隐藏掉所有的页面
    function hideView(){
        singleChoiceQuestionView.visible = false;
        multipleChoiceQuestionsView.visible = false;
        judgmentQuestionView.visible = false;
        fillBlankView.visible = false;
        multipleChoiceView.visible = false;
        textView.visible = false;
    }



    function clipImage(object){
        drawImageBoard.grapItemImage(object);
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
        }
    }

    //单选界面
    SingleChoiceQuestionView {
        id:singleChoiceQuestionView
        anchors.fill: parent
        visible: false;
        onSigCorrect:{
            //console.log("======SingleChoiceQuestionView::imageUrl=======",imageUrl)
            sigShowCorrectPage(imageUrl,status,imgWidth,imgHeight);
        }
        onSigLoadingSuccess:{
            drawImageBoard.grapItemImage(singleChoiceQuestionView.singleChoiceClipImage());
        }
    }
    //多选界面
    MultipleChoiceQuestionsView {
        id:multipleChoiceQuestionsView
        anchors.fill: parent
        visible: false
        onSigCorrect:{
            //console.log("======MultipleChoiceQuestionsView::imageUrl=======",imageUrl)
            sigShowCorrectPage(imageUrl,status,imgWidth,imgHeight);
        }
        onSigLoadingSuccess: {
            drawImageBoard.grapItemImage(multipleChoiceQuestionsView.clipMultipleChoiceImage());
        }
    }
    //判断界面
    JudgmentQuestionView {
        id:judgmentQuestionView
        anchors.fill: parent
        visible: false;
        onSigCorrect:{
            //console.log("======JudgmentQuestionView::imageUrl=======",imageUrl)
            sigShowCorrectPage(imageUrl,status,imgWidth,imgHeight);
        }
        onSigLoadingSuccess: {
            //console.log("========JudgmentQuestionView::start::clip=========")
            drawImageBoard.grapItemImage(judgmentQuestionView.clipJudgmentImage());
        }
    }

    //填空题
    CloudFillBlankView{
        id: fillBlankView
        anchors.fill: parent
        visible: false        
        onSigCorrect:{
            //console.log("======CloudFillBlankView::imageUrl=======",imageUrl)
            sigShowCorrectPage(imageUrl,status,imgWidth,imgHeight);
        }
        onSigLoadingSuccess: {
            //console.log("======CloudFillBlankView::clip======")
            drawImageBoard.grapItemImage(fillBlankView.clipFillBalnkImage());
        }
    }

    //简答题
    CloudMultipleChoice{
        id: multipleChoiceView
        anchors.fill: parent
        visible: false
        onSigCorrect:{
            //console.log("======CloudMultipleChoice::imageUrl=======",imageUrl)
            sigShowCorrectPage(imageUrl,status,imgWidth,imgHeight);
        }
        onSigLoadingSuccess: {
            drawImageBoard.grapItemImage(multipleChoiceView.multipleChoiceClipImage());
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

    Component.onCompleted: {
        //setCurrentBeShowedView(Cfg.testJson);
    }
}
