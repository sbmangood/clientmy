import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtWebEngine 1.4
import "Configuration.js" as Cfg

/*
*综合题页面
*/

Rectangle {
    id: compositeTopicItem
    anchors.fill: parent

    property string contentTopic: ""//题目内容
    property var dataModel: [];//代入数据模型
    property var bufferData: [];//缓存显示的数据


    signal sigIsMultipleTopic();//是否有多题信号
    signal sigPageChange(string pageStatus);//分页发生变化
    signal sigJumpTopic(var jump);//大题下一题 or 上一题
    signal sigTopicId(var questionId);//当前题目Id信号
    property int currentShowView: -1; //1 做题模式 2 预览模式

    property int currentShowQuestionType: -1;

    property int currentIndex: 0;//当前的综合题字体索引
    property  int  allQuestionNumber: 0;//当前所有的综合体的字体总数

    property bool isFirstShowQuestionView : true;

    property var hasDoneQuestionList: [];

    //显示做好了按钮信号  有的已经做过的题就不显示了
    signal sigShowFinishedButton();

    //批改信号
    signal sigCorrectInfos(var questionId,var childQuestionId,var score,var correctType,var errorReason);


    property var saveImageAnswers: ;
    property var ownerDatas: ;

    onCurrentShowViewChanged:
    {
        compositeTopicItem.enabled = true;
        if(currentShowView == 2)
        {
            compositeTopicItem.enabled = false;
        }
    }

    //解析数据
    onDataModelChanged: {
        topicModel.clear();
        console.log("=====onDataModelChanged=====111= 1 ",JSON.stringify(dataModel));

        console.log("=====onDataModelChanged======",topicModel.count);
        if(dataModel == [] || dataModel.length == 0){
            return;
        }
        isFirstShowQuestionView = true;
        console.log("=====onDataModelChanged======",JSON.stringify(dataModel));
        topicModel.append(
                    {
                        "analyse": dataModel.analyse,//题目分析
                        "answer": dataModel.answer == "" ? [] : dataModel.answer ,//题目正确答案
                                                           "id": dataModel.id,//题目Id
                                                           "reply": dataModel.reply,//题目解答
                                                           "lastUpdatedDate": dataModel.lastUpdatedDate,
                                                           "photos": dataModel.photos,//拍照照片
                                                           "status": dataModel.status, //题目状态
                                                           "content": dataModel.content,//标题
                                                           "questionType": dataModel.questionType,//题目类型
                                                           "knowledges": dataModel.knowledges,//知识点对象集合
                                                           "studentAnswer": dataModel.studentAnswer,//学生正确答案
                                                           "questionItems": dataModel.questionItems,//题目选项
                                                           "orderNumber": dataModel.orderNumber,//题目序号
                                                           "studentScore": dataModel.studentScore,//学生分数
                                                           "useTime": dataModel.useTime,//答题用时
                                                           "haschild": dataModel.haschild,//是否有子题
                                                           "childQuestionInfo": dataModel.childQuestionInfo,//.childQuestionInfo,//子题集合，数据结构和父类一样
                                                           "teacherImages": dataModel.teacherImages,//老师批注
                                                           "originImage": dataModel.originImage,//老师批注的原始图片
                                                           "image": dataModel.image,//老师批注图片，为空字符串时也是没有批注
                                                           "isRight": dataModel.isRight,//答案是否正确 0：错误，1：正确，2：半对半错
                                                           "score":dataModel.score,//题目得分
                                                           "errorType": dataModel.errorType,//错因
                    })
        if( dataModel.childQuestionInfo == null)
        {
            allQuestionNumber = 0;
        }
        allQuestionNumber = dataModel.childQuestionInfo.length;
        currentIndex = 0;
        console.log("====onDataModelChanged==== allQuestionNumber ",dataModel.id,dataModel.childQuestionInfo,allQuestionNumber,currentIndex);
    }

    ListView{
        id: topicListView
        width: parent.width
        height: parent.height
        clip: true
        model: topicModel
        delegate: topicDelegate

    }

    //滚动条
    Item {
        id: scrollbar
        anchors.right: topicListView.right
        anchors.top: topicListView.top
        width:14 * heightRate
        height:topicListView.height
        visible: false
        z: 23
        Rectangle{
            anchors.fill: parent
            color: "#eeeeee"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: topicListView.visibleArea.yPosition * scrollbar.height
            width: parent.width
            height: topicListView.visibleArea.heightRatio * scrollbar.height;
            color: "#ff5000"
            radius: 8 * heightRate

            // 鼠标区域
            MouseArea {
                id: mouseArea
                anchors.fill: button
                drag.target: button
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: scrollbar.height - button.height
                cursorShape: Qt.PointingHandCursor
                // 拖动
                onMouseYChanged: {
                    topicListView.contentY = button.y / scrollbar.height * topicListView.contentHeight
                }
            }
        }
    }

    Component{
        id: topicDelegate

        Rectangle{
            id: bodyItem
            width: topicListView.width
            height: topicListView.height * 0.5 + questionTitle.height
//            height: {
//                //计算综合题目里面题目最多、高度最高、的一组题目类型
//                var topiceType = 0;
//                var maxCount = 0;
//                if(childQuestionInfo == null){
//                    return;
//                }

//                for(var i = 0; i < childQuestionInfo.count; i++){
//                    //                    if(childQuestionInfo.get(i).questionItems == null){
//                    //                        break;
//                    //                    }

//                    //                    if(childQuestionInfo.get(i).questionItems.count >= maxCount){
//                    //                        maxCount = childQuestionInfo.get(i).questionItems.count;
//                    //                    }
//                    //                    if(childQuestionInfo.get(i).questionType > topiceType){
//                    //                        topiceType = childQuestionInfo.get(i).questionType;
//                    //                    }
//                }

//                //console.log("====height=====",topiceType,maxCount);
//                if(topiceType >= 1 && topiceType < 5){
//                    var currentType1 = topicListView.height * 0.5  + maxCount * 150 * heightRate ;
//                    return currentType1 < topicListView.height ? topicListView.height : currentType1;
//                }

//                if(topiceType == 5){
//                    //console.log("=====maxCount=====",maxCount);
//                    var currentType5 = topicListView.height + maxCount * 150 * heightRate//topicListView.height * 0.5 + knowledges.count * 300 * heightRate
//                    return currentType5 < topicListView.height ? topicListView.height : currentType5;
//                }
//                return topicListView.height;
//            }

            onHeightChanged: {
                if(height > topicListView.height){
                    scrollbar.visible = true;
                }else{
                    scrollbar.visible = false;
                }
                //console.log("======cloudComposite::questionItems::count=========",questionItems.count, childQuestionInfo.get(index).questionItems.count)
            }

            property var questionTypes: model.questionType

            //主标题
            Row{
                id: topicRow
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: 36 * heightRate
                spacing: 10 * heightRate

                Rectangle{
                    id: topicType
                    width: 50 * heightRate
                    height: 24 * heightRate
                    color: "#ff7777"
                    radius:  4 * heightRate

                    Rectangle{
                        width: 4
                        height: parent.height
                        color: "#ff7777"
                    }

                    Text {
                        text:  "综合题"
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        color: "#ffffff"
                        anchors.centerIn: parent
                    }
                }

                WebEngineView{
                    id: questionTitle
                    enabled: true
                    width: parent.width - 40 * widthRate - topicType.width
                    height: 45 * heightRate
                    anchors.left: questionTypeRectangle.right
                    anchors.leftMargin: 15 * heightRate
                    backgroundColor: "#00000000"

                    //右键的时候, 不弹出右键菜单
                    onContextMenuRequested: function(request) {
                        request.accepted = true;
                    }

                    onContentsSizeChanged: {
                        questionTitle.height = questionTitle.contentsSize.height;
                    }

                    Component.onCompleted: {
                        content = "<html>" + content + "</html> \n" + "<style> *{font-size:1.5vw!important;} </style>";
                        loadHtml(content);
                    }
                }
            }

            //子题目显示
            ListView{
                id: childTopicListView
                clip: true
                width: parent.width - 20
                height: parent.height - topicRow.height - 60 * heightRate//  + topicRow.height - knowledges.count * 460 * heightRate
                anchors.top: topicRow.bottom
                anchors.topMargin: 10 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                delegate: childTopicDelegate
                model: topicModel
            }

            Component{
                id: childTopicDelegate
                Rectangle{
                    id: childItem
                    width: childTopicListView.width- 20
                    height: childTopicListView.height // * heightRate
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image{
                        z: 2
                        anchors.top: parent.top
                        anchors.topMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "qrc:/cloudImage/icon_exercise@2x.png"
                    }

                    Rectangle{
                        width: parent.width
                        height: parent.height - 20
                        color: "#f9f9f9"
                        radius: 8 * widthRate
                        border.width: 1
                        border.color: "#cccccc"
                        anchors.bottom: parent.bottom
                    }

                    property var childQuestionInfos: childQuestionInfo;
                    property var questionItemsModel : [];


                    //五大题型操作界面
                    ShowQuestionHandlerView
                    {
                        id: questionHandlerView
                        width: parent.width -10 * heightRate
                        height: parent.height - 24 * heightRate
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2 * heightRate
                        visible: false
                        imageAnswer: saveImageAnswers
                        currentBeShowedType: currentShowQuestionType
                        curreBeShowedModel: currentShowView;
                        property bool isAllFinished : false;

                        onImageAnswerChanged:
                        {
                            if(imageAnswer == undefined)
                            {
                                console.log("onImageAnswerChanged: 综合题 return ",imageAnswer,saveImageAnswers);
                                return;
                            }
                            isAllFinished = true;
                            console.log("onImageAnswerChanged: 综合题",imageAnswer,saveImageAnswers);
                            //记录当前显示面板的答案
                            questionHandlerView.answerSubmit();
                            //currentShowView = 2;//改变为预览模式
                            questionHandlerView.stopTimer();
                            console.log("onImageAnswerChanged: questionHandlerView.stopTimer()");
                            isAllFinished = false;
                            hasDoneQuestionList.splice(0,hasDoneQuestionList.length);
                        }

                        onSigSaveStudentAnswer:
                        {

                            console.log("danan 提交aaaa",imageAnswers)
                            //获取当前答案面板的图片信息
                            if(currentBeShowedType >= 4)
                            {
                                var imageUrlList = addAnswerView.getCurrentImageUrlList(childQId);
                                console.log("获取当前答案面板的图片信息",imageUrlList)
                            }

                            var hasSave = 0;
                            for(var a = 0; a < hasDoneQuestionList.length ; a++)
                            {
                                var tempList = hasDoneQuestionList[a].questionData;

                                console.log("/此题是否已经存在",tempList,tempList[0],tempList[1])
                                //此题是否已经存在
                                if( tempList[0] == childQId )
                                {
                                    tempList[1] = studentSelectAnswer;
                                    tempList[2] = useTime;
                                    tempList[3] = imageUrlList;//图片的信息
                                    tempList[4] = orderNumber;
                                    hasSave = 1;
                                    hasDoneQuestionList[a] = ({"questionData":tempList});
                                    break;
                                }
                            }
                            if(hasSave == 0)
                            {
                                var tempBufferList = [];
                                tempBufferList.push(childQId);
                                tempBufferList.push(studentSelectAnswer);
                                tempBufferList.push(useTime);
                                tempBufferList.push(imageUrlList);
                                tempBufferList.push(orderNumber);
                                hasDoneQuestionList.push({"questionData":tempBufferList});
                            }
                            var tempList1 = hasDoneQuestionList[0];

                            //                            for(var b= 0; b< hasDoneQuestionList.length ; b++)
                            //                            {
                            //                                var tempLists = hasDoneQuestionList[b].questionData;
                            //                                console.log("已保存的答案数据",tempLists)
                            //                            }

                            if(isAllFinished )
                            {
                                //提交所有的答案
                                for(var b= 0; b< hasDoneQuestionList.length ; b++)
                                {
                                    var tempLists = hasDoneQuestionList[b].questionData;
                                    var isFinished = 0;
                                    if(b == hasDoneQuestionList.length -1 )
                                    {
                                        isFinished = 1;
                                    }
                                    console.log("综合题 提交所有的答案 ",b,tempLists,hasDoneQuestionList.length)
                                    //传图
                                    var iamgeAnswer = addAnswerView.upLoadPhotoByid(tempLists[0],tempLists[4]);
                                    cloudRoomMenu.savaStudentAnswerToserver(tempLists[2],tempLists[1],ownerDatas,isFinished,iamgeAnswer,tempLists[0]) ;
                                }
                            }
                            isAllFinished = false;

                            //studentSelectAnswer  ownerDatas  childQId
                            console.log("综合题答案提交 onSigSaveStudentAnswer",useTime,studentSelectAnswer,ownerDatas,isFinished,saveImageAnswers,childQId)
                        }


                        //做题模式下 改变添加答案界面的显示
                        onResetAddAnswerViewShowModel:
                        {
                            console.log("onResetAddAnswerViewShowModel: 综合题",qtype,addAnswerView.visible)
                            addAnswerView.visible = true;
                            addAnswerView.currentBeShowedModel = -1;
                            if(qtype <= 3)
                            {
                                addAnswerView.currentBeShowedModel = 1;
                            }

                            if(qtype >= 4)
                            {
                                addAnswerView.currentBeShowedModel = 2;
                            }
                        }


                    }

                    onChildQuestionInfosChanged: {
                        console.log("  onChildQuestionInfosChanged: {",currentShowView)
                        analysisData(index);
                    }

                    function analysisData(index){
                        if(bufferData.length > 0){
                            bufferData.splice(0,bufferData.length);
                        }
                        console.log("**********questionTypes*********** haschild",childQuestionInfo.get(index).answer.count,childQuestionInfo.get(index).questionType);
                        if(childQuestionInfo == null){
                            return
                        }

                        if( childQuestionInfo.count > 1 && currentShowView == 1){
                            sigIsMultipleTopic();
                        }


                        //判断是否显示 做题按钮
                        if(currentShowView == 1 )
                        {
                            console.log("shifou 显示做题按钮")
                            var temp = 0;
                            for(var e =0 ;e<hasDoneQuestionList.length; e++)
                            {
                                if(childQuestionInfo.get(index).id == hasDoneQuestionList[e])
                                {
                                    temp = 1;
                                    break;
                                }
                            }
                            if(temp == 0)
                            {
                                sigShowFinishedButton();
                            }
                        }

                        bufferData = {
                            "tempRemaker":"fromClodCompositView",//来源标示
                            "id": childQuestionInfo.get(index).id,
                            "analyse": childQuestionInfo.get(index).analyse,//题目分析
                            "answer":childQuestionInfo.get(index).questionType == 4 ? childQuestionInfo.get(index).answer.count : childQuestionInfo.get(index).answer,//题目正确答案
                                                                                      "reply": childQuestionInfo.get(index).reply,//题目解答
                                                                                      "lastUpdatedDate": childQuestionInfo.get(index).lastUpdatedDate,
                                                                                      "photos": childQuestionInfo.get(index).photos,//拍照照片
                                                                                      "status": childQuestionInfo.get(index).status, //题目状态
                                                                                      "content": childQuestionInfo.get(index).content,//标题
                                                                                      "questionType": childQuestionInfo.get(index).questionType,//题目类型
                                                                                      "knowledges": childQuestionInfo.get(index).knowledges,//知识点对象集合
                                                                                      "studentAnswer": childQuestionInfo.get(index).studentAnswer,//学生正确答案
                                                                                      "questionItems": childQuestionInfo.get(index).questionItems,//题目选项
                                                                                      "orderNumber": childQuestionInfo.get(index).orderNumber,//题目序号
                                                                                      "studentScore": childQuestionInfo.get(index).studentScore,//学生分数
                                                                                      "useTime": childQuestionInfo.get(index).useTime,//答题用时
                                                                                      "haschild": childQuestionInfo.get(index).haschild,//是否有子题
                                                                                      "childQuestionInfo": childQuestionInfo.get(index).childQuestionInfo,//子题集合，数据结构和父类一样
                                                                                      "teacherImages": childQuestionInfo.get(index).teacherImages,//老师批注
                                                                                      "originImage": childQuestionInfo.get(index).originImage,//老师批注的原始图片
                                                                                      "image": childQuestionInfo.get(index).image,//老师批注图片，为空字符串时也是没有批注
                                                                                      "isRight": childQuestionInfo.get(index).isRight,//答案是否正确 0：错误，1：正确，2：半对半错
                                                                                      "score":childQuestionInfo.get(index).score,//题目得分
                                                                                      "errorType": childQuestionInfo.get(index).errorType,//错因
                        };

                        var questionTypes = childQuestionInfo.get(index).questionType;
                        if(questionItemsModel.length > 0){
                            questionItemsModel .splice(0,questionItemsModel.length);
                        }

                        var questionItems = childQuestionInfo.get(index).questionItems;
                        if(questionItems != null){
                            for(var  i = 0; i < questionItems.count; i++){
                                if( questionTypes == 3)
                                {
                                    questionItemsModel.push(
                                                {
                                                    "contents": questionItems.get(i).contents,
                                                    "isright": false,
                                                    "orderName": "",
                                                    "orderno": questionItems.get(i).orderno,
                                                    "qitemid": "",
                                                    "questionid": "",
                                                    "score": "",
                                                });
                                }else{
                                    questionItemsModel.push(
                                                {
                                                    "contents": questionItems.get(i).contents,
                                                    "isright": questionItems.get(i).isright,
                                                    "orderName": questionItems.get(i).orderName,
                                                    "orderno": questionItems.get(i).orderno,
                                                    "qitemid": questionItems.get(i).qitemid,
                                                    "questionid": questionItems.get(i).questionid,
                                                    "score": questionItems.get(i).score,
                                                });
                                }


                            }
                        }

                        //传递当前答案解析信息
                        sigCorrectInfos( id,
                                        childQuestionInfo.get(index).id,
                                        childQuestionInfo.get(index).score,
                                        childQuestionInfo.get(index).isRight,
                                        childQuestionInfo.get(index).errorType);

                        //设置五大题型的数据及显示
                        console.log("=====questionTypes2222222222222222222======",JSON.stringify(questionItemsModel),childQuestionInfo.count)

                        addAnswerView.currentBeShowedQId = bufferData.id;

                        questionHandlerView.questionItemsData = questionItemsModel;
                        questionHandlerView.answerModel = (answer == null || answer == undefined) ? [] : answer;
                        questionHandlerView.knowledgesModels = knowledges;
                        questionHandlerView.setCurrentBeShowedView(bufferData,questionTypes);
                        questionHandlerView.visible = true;
                        questionHandlerView.isScroll = false;
                        sigTopicId(childQuestionInfo.get(index).id);

                    }

                    Component.onCompleted: {
                        console.log("Component.onCompleted: { 2222222222222");
                        compositeTopicItem.sigPageChange.connect(updateData);
                    }

                    //分页改变则数据改变函数
                    function updateData(pageStatus){
                        // console.log("***************child***************111",pages)
                        if(pageStatus == "pre"){
                            console.log("***************child***************",currentIndex,childQuestionInfo,currentShowView)
                            //大题上一题信号
                            if(currentIndex == 0){

                                if(currentShowView != 1)
                                {
                                    console.log("***********  sigJumpTopic( 综合题子题的第一题 跳出综合题");
                                    sigJumpTopic("pre");
                                }
                                return;
                            }
                            if(currentIndex > 0){
                                console.log("***********  sigJumpTopic( currentIndex >= 0",currentShowView);
                                if(childQuestionInfo == null || allQuestionNumber == 0 ){
                                    console.log("***********  sigJumpTopic( currentIndex >= 0 null",currentShowView);
                                    if(currentShowView != 1)
                                    {
                                        console.log("***********  sigJumpTopic( 综合题子题的第一题 跳出综合题",currentShowView);
                                        sigJumpTopic("pre");
                                    }
                                }else{
                                    if(currentIndex <= allQuestionNumber){
                                        if(currentShowView == 1)
                                        {
                                            //记录当前显示面板的答案
                                            questionHandlerView.answerSubmit();
                                        }

                                        console.log("***********  sigJumpTopic( currentIndex >= 0 11",currentShowView);
                                        currentIndex--;
                                        analysisData(currentIndex);
                                    }
                                }
                            }
                            return;
                        }

                        if(pageStatus == "next"){
                            //没有子题直接下一题 信号
                            if(childQuestionInfo == null || allQuestionNumber == 0 ){
                                //console.log("***********  sigJumpTopic( currentIndex >= 0 null",questionHandlerView.currentBeShowedType);
                                //                                if(currentShowView != 1)
                                //                                {
                                //                                    console.log("***********  sigJumpTopic( 综合题子题的最后一题 跳出综合题",compositeTopicItem.currentShowView,compositeTopicItem.allQuestionNumber);
                                //                                    sigJumpTopic("next");
                                //                                }

                                return;
                            }

                            //大题下一题信号
                            if(currentIndex == allQuestionNumber - 1){
                                //currentIndexs = childQuestionInfo.count;

                                if(currentShowView != 1)
                                {
                                    console.log("***********  sigJumpTopic( 综合题子题的最后一题 跳出综合题");
                                    sigJumpTopic("next");
                                }
                                return;
                            }

                            if(currentIndex < allQuestionNumber - 1){
                                if(currentShowView == 1)
                                {
                                    //记录当前显示面板的答案
                                    questionHandlerView.answerSubmit();
                                    //保存图片

                                }
                                currentIndex++;
                                analysisData(currentIndex);

                            }
                            return;
                        }
                    }

                    function answerSubmits()
                    {
                        questionHandlerView.answerSubmit();
                    }
                }
            }


        }
    }

    ListModel{
        id: topicModel
    }
    ListModel{
        id: topicModels
    }
    Component.onCompleted: {

    }
    //上一题、下一题函数
    function updateTopicBody(topicNumber){
        sigPageChange(topicNumber);
        console.log("===updateTopicBody::data===",topicNumber);
    }

    //判断练习未完成的时候 答案提交二次提醒 暂时不用
    function chargeSubmitAnswer(imageUrlString)
    {
        //是否有题型未做
        if(hasDoneQuestionList < allQuestionNumber )
        {

        }else
        {
            answerSubmit(imageUrlString);
        }
    }

    function answerSubmit(imageUrlString)
    {


        console.log("function answerSubmit(imageUrlString)",imageUrlString);
        //获取答案图片 handlerView 接收到 答案图片以后会自动 提交答案
        saveImageAnswers = imageUrlString;

    }
}
