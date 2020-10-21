import QtQuick 2.7
import "Configuration.js" as Cfg

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
    property bool isScroll: true;
    property int currentBeShowedType: -1; //当前被显示的题的类型

    property var curreBeShowedModel: -1; //当前被显示的模式 1 做题模式  2 预览模式
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

    //根据传入数据 来判断 数据属于那种提醒 从而来显示 对应题型的界面
    function setCurrentBeShowedView(showData,type){

        currentBeShowedType = type;

        if(curreBeShowedModel == 1 && currentBeShowedType != -1)
        {
            resetAddAnswerViewShowModel(currentBeShowedType);
        }

        hideView();
        console.log("====setCurrentBeShowedView(showData,type)====",type)
        //题型判断
        //数据传入 显示

        //副文本显示
        if(type == 0){
            targetText.text = showData.content;
            console.log("=====showData.content=====",showData.content);
            textView.visible = true;
            return;
        }

        addAnswerView.currentBeShowedQId = showData.id;

        if(type == 1){//单选题
            singleChoiceQuestionView.knowledgesModels = knowledgesModels;
            singleChoiceQuestionView.answerModel = answerModel;
            singleChoiceQuestionView.questionItemsModel = questionItemsData;
            singleChoiceQuestionView.updateMainView(showData,curreBeShowedModel);
            singleChoiceQuestionView.visible = true;
            if(curreBeShowedModel == 2)
            {
                singleChoiceQuestionView.enabled = false;
            }else
            {
                singleChoiceQuestionView.enabled = true;
            }

            return;
        }
        if(type == 2){//多选题
            multipleChoiceQuestionsView.knowledgesModels = knowledgesModels;
            multipleChoiceQuestionsView.answerModel = answerModel;
            multipleChoiceQuestionsView.questionItemsModel = questionItemsData;
            multipleChoiceQuestionsView.updateMainView(showData,curreBeShowedModel);
            multipleChoiceQuestionsView.visible = true;
            if(curreBeShowedModel == 2)
            {
                multipleChoiceQuestionsView.enabled = false;
            }else
            {
                multipleChoiceQuestionsView.enabled = true;
            }

            return;
        }
        if(type == 3){//判断题
            judgmentQuestionView.knowledgesModels = knowledgesModels;
            judgmentQuestionView.answerModel = answerModel;
            judgmentQuestionView.questionItemsModel = questionItemsData;
            judgmentQuestionView.updateMainView(showData,curreBeShowedModel);
            judgmentQuestionView.visible = true;

            if(curreBeShowedModel == 2)
            {
                judgmentQuestionView.enabled = false;
            }else
            {
                judgmentQuestionView.enabled = true;
            }

            return;
        }

        if(type == 4){//填空题
            fillBlankView.answerModel = answerModel;
            fillBlankView.knowledgesModels = knowledgesModels;
            fillBlankView.questionItemsModel = questionItemsData;
            fillBlankView.dataModel = showData;
            fillBlankView.visible = true;
            fillBlankView.isScroll = isScroll;

            fillBlankView.currentViewModel = curreBeShowedModel;//更新当前显示模式 做题模式 或 显示模式
            fillBlankView.enabled = true;
            if(curreBeShowedModel == 2)
            {
                fillBlankView.isEnable = true;
            }else
            {
                 fillBlankView.isEnable = false;
            }

            return;
        }

        if(type == 5){//简答题
            multipleChoiceView.answerModel = answerModel;
            multipleChoiceView.knowledgesModels = knowledgesModels;
            multipleChoiceView.questionItemsModel = questionItemsData;
            multipleChoiceView.dataModel = showData;
            multipleChoiceView.visible = true;
            multipleChoiceView.isScroll = isScroll;

            multipleChoiceView.currentViewModel = curreBeShowedModel;//更新当前显示模式 做题模式 或 显示模式
            multipleChoiceView.enabled = true;
            if(curreBeShowedModel == 2)
            {
                multipleChoiceView.isEnable = true;
            }else
            {
                multipleChoiceView.isEnable = false;
            }

            return;
        }
        //        if(type == 6){
        //            compositeTopicView.dataModel = showData;
        //            compositeTopicView.visible = true;
        //        }



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
        singleChoiceQuestionView.visible = false;
        multipleChoiceQuestionsView.visible = false;
        judgmentQuestionView.visible = false;
        fillBlankView.visible = false;
        multipleChoiceView.visible = false;
        //compositeTopicView.visible = false;
        textView.visible = false;
    }

    //做题用时计时器
    Timer {
        id:useTimeTimer
        interval: 1000;
        running: false;
        repeat: true
        onTriggered:
        {
            ++useTimes;
            console.log("id:useTimeTimer 做题用时 ",useTimes);
        }
    }

    //学习目标显示副文本
    Rectangle{
        id: textView
        visible: false
        anchors.fill: parent

        Text {
            id: targetText
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

        onSaveStudentAnswer:
        {
            useTimeTimer.stop();//停止做题计时
            sigSaveStudentAnswer(useTimes,studentSelectAnswer,currentQuestionOwnerData,1,imageAnswer,questionId,orderNumber);
        }
    }

    //综合题
    //    CloudCompositeTopicView{
    //        id: compositeTopicView
    //        anchors.fill: parent
    //        visible: false
    //    }

    Component.onCompleted: {
        //setCurrentBeShowedView(Cfg.testJson);
    }
    function stopTimer()
    {
        useTimeTimer.stop();
    }
}
