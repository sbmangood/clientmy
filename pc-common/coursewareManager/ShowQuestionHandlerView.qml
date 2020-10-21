import QtQuick 2.7
import QtQuick.Controls 2.0
import "./Configuuration.js" as Cfg

/*
*处理题型显示的界面
*/

Rectangle {
    id: mainHandlerView
    color: "transparent"  //#ffffff
    border.width: 1
    border.color: "#f6f6f6"

    property string role: ""// 角色：教师teacher,学生student,旁听auditor,根据该参数决定界面展示内容

    //存储所有题型
    property var questionItemsData: [];
    property var answerModel: [];
    property var knowledgesModels: [];
    property var resourceContent: [];
    property bool isScroll: true;
    property string baseImage: "";
    property bool isCompleStatus: false;//是否是综合题截图,false：不是， true：是
    property bool complexSuccess: false;
    property bool isStuHomeWorkView: false;//是否是学生课后作业查看模式 （区分是否显示答案解析）

    //显示长图信号 status 0未做题 1为截图 2为批改 4完成 imgWidth:图片宽度 imgHeight:图片高度
    signal sigShowCorrectPage(var filePath,var status,var imgWidth,var imgHeight);

    //课后作业截图
    signal sigCurrentClipImagePath(var imageUrl, var imgWidth, var imgHeight);
    property int currentBeShowedType: -1; //当前被显示的题的类型

    property int curreBeShowedModel: -1; //当前被显示的模式 1 做题模式  2 预览模式
    property int useTimes: 0; //当前做题用时
    //jsonobject 形式存储
    property var currentQuestionOwnerData: ;// 当前题目的 归属信息  planid 讲义ID columnId 栏目Id  以及题目id
    property var imageAnswer: ;

    signal isDoRights(var isRight );
    //重设添加答案页面的显示模式
    signal resetAddAnswerViewShowModel(var qtype);

    //提交学生答案到服务器  isFinished 1 完成 0 未完成 useTime 用时  studentSelectAnswer 学生选择的答案  ownerData 题目归属信息 childQId 当前显示题目的id
    signal sigSaveStudentAnswer( var useTime, var studentSelectAnswer,var ownerData ,var isFinished,var imageAnswers,var childQId ,var orderNumber);

    //如果前是做题模式 发信号显示答题面板
    onCurreBeShowedModelChanged:
    {
        if(curreBeShowedModel == 1 && currentBeShowedType != -1)
        {
            resetAddAnswerViewShowModel(currentBeShowedType);
            //做题模式话 启动定时器计时
            console.log("useTimes = 0;//重置做题时间",currentBeShowedType);
            useTimes = 0;//重置做题时间
            useTimeTimer.stop();
            useTimeTimer.start();
        }
    }

    onCurrentBeShowedTypeChanged:
    {
        //更新显示答题面板
        if(curreBeShowedModel == 1 && currentBeShowedType != -1)
        {
            resetAddAnswerViewShowModel(currentBeShowedType);
        }
    }

    /* 根据传入数据 来判断 数据属于那种提醒 从而来显示 对应题型的界面
        showData: 数据 ,
        type: 题目类型，
        browseStatus：截图模式,
        topicModel: 做题模式 1:做题、 2对答案
    */
    function setCurrentBeShowedView(showData,type,browseStatus,topicModel){
        if(role == "student"){
            currentBeShowedType = type;
            if(curreBeShowedModel == 1 && currentBeShowedType != -1)
            {
                resetAddAnswerViewShowModel(currentBeShowedType);
            }
        }
        hideView();
        console.log("====setCurrentBeShowedView====",type,browseStatus,isCompleStatus,JSON.stringify(showData));
        //副文本显示
        if(type === 0){
            if(role == "teacher"){
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
            }
            targetText.text = showData.content;
            textView.visible = true;
            console.log("=====showData.content=====",showData.content);
            return;
        }

        //题型判断、数据传入 显示
        if(type == 1){//单选题
            if(role == "teacher"){
                singleChoiceQuestionView.setClipStatus(false,isCompleStatus);
            }
            singleChoiceQuestionView.knowledgesModels = knowledgesModels;
            singleChoiceQuestionView.answerModel = answerModel;
            singleChoiceQuestionView.questionItemsModel = questionItemsData;
            if(role == "teacher"){
                singleChoiceQuestionView.updateMainView(showData,topicModel);
            }
            else if(role == "student"){
                singleChoiceQuestionView.updateMainView(showData,curreBeShowedModel);
            }
            
            singleChoiceQuestionView.visible = true;
            if(role == "teacher"){
                //截图模式
                if(browseStatus){
                    singleChoiceQuestionView.setClipStatus(true,isCompleStatus);
                }
            }

            if(role == "student"){
                if(curreBeShowedModel == 2)
                {
                    singleChoiceQuestionView.enabled = false;
                }else
                {
                    singleChoiceQuestionView.enabled = true;
                }
            }
            return;
        }
        if(type == 2){//多选题
            if(role == "teacher"){
                multipleChoiceQuestionsView.updateClipStatus(false,isCompleStatus);
            }
            multipleChoiceQuestionsView.knowledgesModels = knowledgesModels;
            multipleChoiceQuestionsView.answerModel = answerModel;
            multipleChoiceQuestionsView.questionItemsModel = questionItemsData;
            if(role == "teacher"){
                singleChoiceQuestionView.updateMainView(showData,topicModel);
            }
            else if(role == "student"){
                singleChoiceQuestionView.updateMainView(showData,curreBeShowedModel);
            }
            multipleChoiceQuestionsView.visible = true;
            if(role == "teacher"){
                //截图模式
                if(browseStatus){
                    singleChoiceQuestionView.setClipStatus(true,isCompleStatus);
                }
            }

            if(role == "student"){
                if(curreBeShowedModel == 2)
                {
                    singleChoiceQuestionView.enabled = false;
                }else
                {
                    singleChoiceQuestionView.enabled = true;
                }
            }
            return;
        }
        if(type == 3){//判断题
            if(role == "teacher"){
                judgmentQuestionView.updateClipStatus(false,isCompleStatus);
            }
            judgmentQuestionView.knowledgesModels = knowledgesModels;
            judgmentQuestionView.answerModel = answerModel;
            judgmentQuestionView.questionItemsModel = questionItemsData;
            judgmentQuestionView.visible = true;
            if(role == "teacher"){
                singleChoiceQuestionView.updateMainView(showData,topicModel);
            }
            else if(role == "student"){
                singleChoiceQuestionView.updateMainView(showData,curreBeShowedModel);
            }

            if(role == "teacher"){
                //截图模式
                if(browseStatus){
                    singleChoiceQuestionView.setClipStatus(true,isCompleStatus);
                }
            }

            if(role == "student"){
                if(curreBeShowedModel == 2)
                {
                    singleChoiceQuestionView.enabled = false;
                }
                else{
                    singleChoiceQuestionView.enabled = true;
                }
            }
            return;

        }
        if(type == 4){//填空题
            if(role == "teacher"){
                fillBlankView.setClipStatus(browseStatus,isCompleStatus);
            }
            fillBlankView.answerModel = answerModel;
            fillBlankView.knowledgesModels = knowledgesModels;
            fillBlankView.questionItemsModel = questionItemsData;
            fillBlankView.dataModel = showData;
            fillBlankView.visible = true;
            fillBlankView.isScroll = isScroll;
            if(role == "student"){
                fillBlankView.currentViewModel = curreBeShowedModel;//更新当前显示模式 做题模式 或 显示模式
                fillBlankView.enabled = true;
                if(curreBeShowedModel == 2)
                {
                    fillBlankView.isEnable = true;
                }else
                {
                    fillBlankView.isEnable = false;
                }
            }
            return;
        }

        if(type == 5){//简答题
            if(role == "teacher"){
                multipleChoiceView.setMultipleClipStatus(browseStatus,isCompleStatus);
            }
            multipleChoiceView.answerModel = answerModel;
            multipleChoiceView.knowledgesModels = knowledgesModels;
            multipleChoiceView.questionItemsModel = questionItemsData;
            multipleChoiceView.dataModel = showData;
            multipleChoiceView.visible = true;
            multipleChoiceView.isScroll = isScroll;
            if(role == "student"){
                multipleChoiceView.currentViewModel = curreBeShowedModel;//更新当前显示模式 做题模式 或 显示模式
                multipleChoiceView.enabled = true;
                if(curreBeShowedModel == 2)
                {
                    multipleChoiceView.isEnable = true;
                }else
                {
                    multipleChoiceView.isEnable = false;
                }
            }
            return;
        }
    }

    //答案提交
    function answerSubmit()
    {
        console.log("showQuestionhandler answerSubmit() "<<currentBeShowedType);
        if( currentBeShowedType == 1 ){//单选题
            singleChoiceQuestionView.answerSubmit();
            return;
        }
        if(currentBeShowedType == 2){//多选题
            multipleChoiceQuestionsView.answerSubmit();
            return;
        }

        if(currentBeShowedType == 3){//判断题
            judgmentQuestionView.answerSubmit();
            return;
        }

        if(currentBeShowedType == 4){//填空题
            fillBlankView.answerSubmit();
            return;
        }
        if(currentBeShowedType == 5){//简答题
            multipleChoiceView.answerSubmit();
            return;
        }
    }
    //显示答案解析
    function showAnswerDetail()
    {
        if( currentBeShowedType == 1 ){//单选题
            singleChoiceQuestionView.showAnswerDetail();
            return;
        }
        if(currentBeShowedType == 2){//多选题
            multipleChoiceQuestionsView.showAnswerDetail();
            return;
        }
        if(currentBeShowedType == 3){//判断题
            judgmentQuestionView.showAnswerDetail();
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
            console.log("===onSigBeSavedGrapAnswer===",imageUrl,imgWidth,imgHeight,homeworkClipImgType);
            if(homeworkClipImgType == 0)
            {
                sigCurrentClipImagePath(imageUrl, imgWidth, imgHeight);
                return;
            }
            var currentStatus = isCompleStatus ?  6 : 1;

            if(complexSuccess){
                currentStatus = 1;
                isCompleStatus = false;

                if(homeworkClipImgType == 1)
                {
                    sigCurrentClipImagePath(imageUrl, imgWidth, imgHeight);
                    return;
                }
            }

            sigShowCorrectPage(imageUrl,currentStatus,imgWidth,imgHeight);

            console.log("=====YMHomeworkWrittingBoard::imageUrl====", imageUrl,imgWidth,imgHeight,currentStatus,isCompleStatus);
        }
    }

    function clipImage(object){
        complexSuccess = true;
        drawImageBoard.grapItemImage(object);
    }
    
    //做题用时计时器
    Timer {
        id:useTimeTimer
        interval: 1000;
        running: false;
        repeat: true
        //visible: role == "student" ? true : false
        onTriggered:
        {
            ++useTimes;
            console.log("id:useTimeTimer 做题用时 ",useTimes);
        }
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
            onSourceChanged:{
                console.log("onSourceChangedonSourceChanged",source)
            }
            onStatusChanged: {
                longImgs.height = longImgs.sourceSize.height;
                textView.contentHeight = longImgs.sourceSize.height;
            }
        }

        Text {
            id: targetText
            visible: {
                if(role == "teacher"){
                    if(baseImage == ""){
                        return true;
                    }
                    else{
                        return false;
                    }
                }
                else{
                    return true;
                }
            }
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
        heightRates:heightRate
        onSigCorrect:{
            console.log("======SingleChoiceQuestionView::imageUrl=======",imageUrl)
            sigShowCorrectPage(imageUrl,status,imgWidth,imgHeight);
        }
        onSigLoadingSuccess:{
            console.log("====onSigLoadingSuccess======",auditionLessonCoursewareView.currentSelectIndex);
            if(auditionLessonCoursewareView.currentSelectIndex != 3){
                sigShowCorrectPage("",1,0,0);
            }else{
                singleTime.restart();
            }
            //singleTime.restart();
            //drawImageBoard.grapItemImage(singleChoiceQuestionView.singleChoiceClipImage());
        }
        onIsDoRight:
        {
            isDoRights(isRight);
        }

        onSaveStudentAnswer:
        {
            useTimeTimer.stop();
            console.log("onSaveStudentAnswer: currentQuestionOwnerData ",currentQuestionOwnerData);
            sigSaveStudentAnswer(useTimes,studentSelectAnswer,currentQuestionOwnerData,1,imageAnswer,questionId,orderNumber);
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
            if(auditionLessonCoursewareView.currentSelectIndex != 3){
                sigShowCorrectPage("",1,0,0);
            }else{
                multipleTime.restart();
            }
            //drawImageBoard.grapItemImage(multipleChoiceQuestionsView.clipMultipleChoiceImage());
        }
        onIsDoRight:
        {
            isDoRights(isRight)
        }
        onSaveStudentAnswer:
        {
            useTimeTimer.stop();//停止做题计时器
            sigSaveStudentAnswer(useTimes,studentSelectAnswer,currentQuestionOwnerData,1,imageAnswer,questionId,orderNumber);
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
            if(auditionLessonCoursewareView.currentSelectIndex != 3){
                sigShowCorrectPage("",1,0,0);
            }else{
                judgmentTime.restart();
            }
            //drawImageBoard.grapItemImage(judgmentQuestionView.clipJudgmentImage());
        }
        onIsDoRight:
        {
            isDoRights(isRight)
        }
        onSaveStudentAnswer:
        {
            useTimeTimer.stop();//停止做题计时
            sigSaveStudentAnswer(useTimes,studentSelectAnswer,currentQuestionOwnerData,1,imageAnswer,questionId,orderNumber);
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
            console.log("======CloudFillBlankView::clip======");
            if(auditionLessonCoursewareView.currentSelectIndex != 3){
                sigShowCorrectPage("",1,0,0);
            }else{
                fillblankTime.restart();
            }
            //drawImageBoard.grapItemImage(fillBlankView.clipFillBalnkImage());
        }
        onSaveStudentAnswer:
        {
            useTimeTimer.stop();//停止做题计时
            sigSaveStudentAnswer(useTimes,studentSelectAnswer,currentQuestionOwnerData,1,imageAnswer,questionId,orderNumber);
        }
    }

    //简答题
    CloudMultipleChoice{
        id: multipleChoiceView
        anchors.fill: parent
        visible: false
        onSigCorrect:{
            console.log("======CloudMultipleChoice::imageUrl=======",imageUrl)
            sigShowCorrectPage(imageUrl,status,imgWidth,imgHeight);
        }
        onSigLoadingSuccess: {
            console.log("======CloudMultipleChoice::clip=====");
            if(auditionLessonCoursewareView.currentSelectIndex != 3){
                sigShowCorrectPage("",1,0,0);
            }else{
                answerTime.restart();
            }
            //drawImageBoard.grapItemImage(multipleChoiceView.multipleChoiceClipImage());
        }
        onSaveStudentAnswer:
        {
            useTimeTimer.stop();//停止做题计时
            sigSaveStudentAnswer(useTimes,studentSelectAnswer,currentQuestionOwnerData,1,imageAnswer,questionId,orderNumber);
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

    function stopTimer()
    {
        useTimeTimer.stop();
    }
}
