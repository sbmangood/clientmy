import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtWebEngine 1.4
import "./Configuuration.js" as Cfg

/*
*填空题页面
*/

Item {
    id: fillblankView
    anchors.fill: parent
    
    property string role: ""// 角色：教师teacher,学生student,旁听auditor,根据该参数决定界面展示内容
    
    property string contentTopic: ""//题目内容
    property var dataModel: [];//代入数据模型
    property var questionItemsModel: [];
    property var answerModel: [];
    property var knowledgesModels: [];
    property bool isScroll: role == "teacher" ? false : true;

    property var hasBufferedQuestionAnswerList: [];//已经存储过的 答案列表 结构  question id  + 选项数组（json存储）
    property var currentBufferAnswer:[] ;//当前缓存答案值
    property int currentItemNumber: 1;//当前输入框的数量

    property var currentBufferId : ;//当前缓存题目的id

    property int currentViewModel: 1;// 当前的显示模式 1 做题模式  2 对答案模式

    signal saveStudentAnswer( var studentSelectAnswer, var questionId ,var orderNumber);//提交学生答案
    
    property bool isEnable: true;
    
    property string baseImages: "";//题目是否已做完显示数据
    property bool isEnable: role == "student" ? true : false;
    property var baseImageObj: [];
    property int topicStatus: 0;//题目是否做完 0未作，2待批改，4批改完成
    property bool clipStatus: false;
    property bool isComplexClip: false;//是否是综合题截图

    //批改信号
    signal sigCorrect(var imageUrl,var status,var imgWidth,var imgHeight);//图片路径、题目状态,题目类型
    signal sigLoadingSuccess();//加载完成进行截图

    onCurrentViewModelChanged:
    {
        if(currentViewModel == 2)
        {
            fillBlankView.enabled = false;
        }
    }

    function answerSubmit()
    {
        //模式显示为对答案模式
        currentViewModel = 2;
        //获取填空的内容
        var tempAnswer = "";
        for(var a = 0; a<questionItemsModel.length; a++)
        {
            var tas = questionItemsModel[a].contentText == "" ? "gapBlank" : questionItemsModel[a].contentText;
            if(tempAnswer == "")
            {
                tempAnswer = tempAnswer + tas == "" ? "gapBlank" : tas
            }
            else
            {
                tempAnswer = tas == "" ? tempAnswer  + "|*|" + "gapBlank" : tempAnswer  + "|*|" + tas
            }
        }
        //提交答案到服务器 orderno(int型)
        saveStudentAnswer(tempAnswer,topicModel.get(0).id ,topicModel.get(0).orderNumber);
    }
    
    //解析数据
    onDataModelChanged: {
        topicModel.clear();
        if(dataModel == [] || dataModel.length == 0){
            return;
        }

        baseImages = "";
        topicStatus = 0;
        
        var answer;
        if(role == "teacher"){
            answer = dataModel.answer;
            if(questionItemsModel === "" || questionItemsModel == null){
                questionItemsModel = [];
            }

            if(questionItemsModel.length > 0){
                questionItemsModel.splice(0,questionItemsModel.length);
            }

            var studentAnswerStr;
            var studentAnswerArray = [];
            if(dataModel.studentAnswer !== null){
                studentAnswerStr = dataModel.studentAnswer;
                studentAnswerArray = studentAnswerStr.split("|*|");
            }

            photosModel.clear();
            if(dataModel.allImages !== null){
                for(var z = 0; z < dataModel.allImages.length; z++){
                    photosModel.append(
                                {
                                    "imageStatus": 2,
                                    "imageUrl": dataModel.allImages[z],
                                });
                }
            }

            for(var i = 0; i < answer.length; i++){
                questionItemsModel.push(
                            {
                                "contentText": "",
                                "rightAnswer":answer[i],
                                "errorName": (dataModel.errorName === null  || dataModel.errorName === undefined )? "" : dataModel.errorName,
                                                                                                                    "answerText": studentAnswerArray.length > i ? studentAnswerArray[i] : "",
                            })
            }
            if(questionItemsModel.length == 0)
            {
                questionItemsModel.push(
                            {
                                "contentText": "",
                                "rightAnswer":answer[i],
                                "errorName": (dataModel.errorName === null || dataModel.errorName  === undefined) ? "" : dataModel.errorName,
                                                                                                                    "answerText": studentAnswerArray.length > 0 ? studentAnswerArray[0] : "",
                            })
            }
            console.log("====CloudFillBlankView===",questionItemsModel.length,JSON.stringify(questionItemsModel),answer.length,studentAnswerArray.length,dataModel.answer.length);
            topicModel.append(
                        {
                            "analyse": dataModel.analyse,//题目分析
                            "answer": answer,//题目正确答案
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
                            "haschild": dataModel.haschild,//是否有子节点
                            "childQuestionInfo": dataModel.childQuestionInfo,//子题集合，数据结构和父类一样
                            "teacherImages": dataModel.teacherImages,//老师批注
                            "originImage": dataModel.originImage,//老师批注的原始图片
                            "image": dataModel.image,//老师批注图片，为空字符串时也是没有批注
                            "isRight": dataModel.isRight,//答案是否正确 0：错误，1：正确，2：半对半错
                            "baseImage": dataModel.baseImage,//是否有答题图片
                            "writeImages": dataModel.writeImages,//手写图片
                            "errorType": dataModel.errorType,//错因
                            "errorName": dataModel.errorName,
                        });
            topicStatus = dataModel.status;
            var imgwidth;
            var imgheight;
            if(dataModel.baseImage !== null){
                baseImages = dataModel.baseImage.imageUrl === null ? "" : dataModel.baseImage.imageUrl;
                baseImageObj = dataModel.baseImage;
                imgwidth = dataModel.baseImage.width;
                imgheight =  dataModel.baseImage.height;
                console.log("=====imgheight======",imgheight);
            }
            if(baseImages != ""){
                sigCorrect(baseImages,2,imgwidth,imgheight);
            }
            topicListView.contentY = 0;
            console.log("====onDataModelChanged====",topicStatus,baseImages,JSON.stringify(dataModel))
        }
        else if(role == "student"){
            if(dataModel.tempRemaker == null || dataModel.tempRemaker == undefined)
            {
                answer = dataModel.answer.length;
            }else
            {
                answer = dataModel.answer;
            }
            currentItemNumber = answer;

            questionItemsModel = [];
            currentBufferId = dataModel.id;

            //获取缓存答案
            getCurrentBufferList();
            if(answer == 0)
            {
                answer = 1;
            }
            for(var i = 0; i < answer; i++){
                questionItemsModel.push(
                            {
                                "contentText": currentBufferAnswer[i],
                            })
            }

            topicModel.append(
                        {
                            "analyse": dataModel.analyse,//题目分析
                            "id":dataModel.id,
                            "answer": dataModel.answer,//题目正确答案
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
                            "childQuestionInfo": dataModel.childQuestionInfo,//子题集合，数据结构和父类一样
                            "teacherImages": dataModel.teacherImages,//老师批注
                            "originImage": dataModel.originImage,//老师批注的原始图片
                            "image": dataModel.image,//老师批注图片，为空字符串时也是没有批注
                            "isRight": dataModel.isRight,//答案是否正确 0：错误，1：正确，2：半对半错
                        })
            currentOrderNumber = dataModel.orderNumber;
        }
    }
    
    

    ListModel{//快照和书写图片数据模型
        id: photosModel
    }

    ListView{
        id: topicListView
        width: parent.width
        height: parent.height
        clip: true
        visible:  {
            if(role == "teacher"){
                if(baseImages == ""){
                    sigCorrect("",5,0,0);
                    return true;
                }else{
                    return false;
                }
            }
            else if(role == "student"){
                return true;
            }
        }
        onVisibleChanged: {
            console.log("=====cloudFillBlankView::visible========",visible);
        }

        model: topicModel
        delegate: topicDelegate
        boundsBehavior: {
            if(role == "student"){
                return ListView.StopAtBounds;
            }
        }
    }

    //滚动条
    Item {
        id: scrollbar
        anchors.right: parent.right
        anchors.top: parent.top
        width:14 * heightRate
        height:parent.height
        visible: {
            if(role == "student"){
                return false;
            }
            else if(role == "teacher"){
                return topicListView.height > fillblankView.height ? true : false;
            }
        }
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
            y: role == "student" ? topicListView.visibleArea.yPosition * scrollbar.height : 0
            width: parent.width
            height: {
                if(role == "student"){
                    return topicListView.visibleArea.heightRatio * scrollbar.height;
                }
                else{
                    var mutilValue = topicListView.height / parent.height;
                    if(mutilValue > 1){
                        return parent.height / mutilValue;
                    }else{
                        return parent.height * mutilValue;
                    }
                }
            }
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
                    topicListView.contentY = button.y / scrollbar.height * topicListView.height
                }
            }
        }
    }

    Component{
        id: topicDelegate
        Item{
            id: bodyItem
            width: topicListView.width
            height: {
                if(isComplexClip){
                    return  fillblankView.height * 0.4  + topicRow.height + questionItemsModel.length * 160 * heightRate + answerView.height;
                }else{
                    var numbers = questionItemsModel == null || questionItemsModel == "" ? 0 : questionItemsModel.length;
                    return  fillblankView.height * 0.4  + topicRow.height + photosModel .count * fillblankView.height + numbers * 160 * heightRate + answerView.height;
                }
            }

            onHeightChanged: {
                console.log("=====cloudFillBlankView::width====",height,topicListView.height,clipStatus);
                if(role == "teacher"){
                    if(clipStatus){
                        scrollbar.visible = false;
                        if(isComplexClip){
                            topicListView.height = height;
                        }else{
                            topicRow.topPadding = 100 * heightRate;
                            topicListView.height = height +100 * heightRate;
                        }
                        return;
                    }
                }
                topicListView.height = fillblankView.height;
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
                        text:  qsTr("填空题");
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        color: "#ffffff"
                        anchors.centerIn: parent
                    }
                }


                WebEngineView{
                    id: questionTitle
                    enabled: true
                    width: role == "student"? (parent.width - 40 * widthRate - topicType.width):(parent.width - 40 * heightRate - topicType.width)
                    height: 45 * heightRate
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
                visible: {
                    if(role == "teacher"){
                        return !haschild;
                    }
                    else if(role == "student"){
                        return true;
                    }
                }
                width: parent.width - 20
                height: {
                    if(role == "teacher"){
                        return parent.height - answerView.height - topicRow.height  - 50 * heightRate -  photosModel .count * fillblankView.height;// + numbers * 160 * heightRate
                    }
                    else if(role == "student"){
                        return parent.height  - topicRow.height - 50 * heightRate;
                    }
                }
                anchors.top: topicRow.bottom
                anchors.topMargin: 10 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                delegate: childTopicDelegate
                model: questionItemsModel
            }

            Component{
                id: childTopicDelegate
                Item{
                    width: childTopicListView.width
                    height: 160 * heightRate
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle{
                        width: parent.width - 20 * heightRate
                        height: parent.height - 20 * heightRate
                        color: "#f9f9f9"
                        radius: 8 * widthRate
                        border.width: 1
                        border.color: "#cccccc"
                        visible: questionItemsModel.length > 1
                    }

                    Item{
                        width: 40 * heightRate
                        height: parent.height
                        visible: questionItemsModel.length > 1
                        Text {
                            font.family: Cfg.font_family
                            font.pixelSize: 16 * heightRate
                            text: (index + 1).toString()
                            anchors.centerIn: parent
                        }
                    }

                    TextArea{
                        id:writeArea
                        readOnly: role == "teacher" ? true : false
                        width: parent.width - 60 * heightRate
                        height: parent.height - 20 * heightRate
                        anchors.left: parent.left
                        anchors.leftMargin: 40 * heightRate
                        font.family: Cfg.font_family
                        font.pixelSize: 16 * heightRate
                        placeholderText: role == "student" ? "请输入答案" : ""
                        selectByMouse: true
                        selectionColor: "blue"
                        selectedTextColor: "#ffffff"
                        text: role == "student" ? questionItemsModel[index].contentText : ""
                        wrapMode: role == "teacher" ? TextArea.WordWrap : TextArea.Wrap
                        background: Rectangle{
                            anchors.fill: parent
                            color: "#ffffff"
                            radius: 8 * widthRate
                            border.width: 1
                            border.color: "#cccccc"
                            Rectangle{
                                color: "#ffffff"
                                width: 10 * widthRate
                                height: parent.height - 4
                                anchors.top: parent.top
                                anchors.topMargin: 2
                                visible: questionItemsModel.length < 1
                            }
                            Rectangle{
                                width: 10 * heightRate
                                height: parent.height - 4
                                anchors.top: parent.top
                                anchors.topMargin: 2
                                color: "#ffffff"
                                visible: {
                                    if(role == "teacher"){
                                        return questionItemsModel.length == 1 ? false : true;
                                    }
                                    else if(role == "student"){
                                        return false;
                                    }
                                }
                            }
                        }
                        text: {
                            if(role == "teacher"){
                                return questionItemsModel[index].answerText == "gapBlank" ? "未做" : questionItemsModel[index].answerText;
                            }
                            else{
                                return "";
                            }
                        }
                        onTextChanged: {
                            if(role == "student"){
                                if(textareas.text.length > 500)
                                {
                                    textareas.text = textareas.getText(0,499);
                                }

                                questionItemsModel[index].contentText = textareas.text;
                                currentBufferAnswer[index] = textareas.text;

                                resetHasBufferAnswerList(textareas.text,index);
                            }
                        }
                    }
                }
            }

            //显示快照
            ListView{
                id: phpos
                clip: true
                visible: (role == "teacher") && clipStatus && isComplexClip == false ? true : false
                width: parent.width - 20
                height: fillblankView.height * photosModel.count - topicType.height
                anchors.top: childTopicListView.bottom
                model: photosModel
                anchors.horizontalCenter: parent.horizontalCenter
                boundsBehavior: ListView.StopAtBounds
                delegate: Item{
                    width: fillblankView.width
                    height: fillblankView.height
                    Image{
                        width: fillblankView.width
                        height: fillblankView.height
                        source: imageUrl
                        sourceSize.width: fillblankView.width
                        sourceSize.height: fillblankView.height

                        onStatusChanged: {
                            console.log("================",status,index,imageUrl);
                            if(status == Image.Error){
                                imageStatus = 1;
                            }

                            if(status == Image.Ready){
                                imageStatus = status;
                            }
                            var currentStatus = true;
                            for(var i = 0; i < photosModel.count;i++){
                                if(photosModel.get(i).imageStatus != 1){
                                    currentStatus = false;
                                    break;
                                }
                            }
                            if(currentStatus  && clipStatus){
                                console.log("=========clipStatus==========",clipStatus)
                                sigLoadingSuccess();
                            }
                        }
                    }
                }
            }

            Rectangle{
                id:answerView
                width: parent.width - 15 * widthRates
                anchors.top: phpos.bottom
                height: textColumn.height
                anchors.horizontalCenter: parent.horizontalCenter
                visible: (role == "teacher") && (currentIsHomeWorkClipImg || isStuHomeWorkView)
                Column {
                    id:textColumn
                    spacing: 10 * heightRate
                    width: parent.width

                    Text {
                        text: qsTr("正确答案")
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        color: "#c9930c"
                    }
                    Text {
                        width: parent.width
                        text:{
                            if(questionItemsModel.length > 0)
                            {
                                return questionItemsModel[0].rightAnswer
                            }else
                            {
                                return ""
                            }
                        }

                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        wrapMode: Text.WordWrap

                    }

                    Text {
                        text: qsTr("错因")
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        color: "#c9930c"
                        visible: (isRight == 0 || isRight == 2 ) && status !=0
                    }

                    Text {
                        width: parent.width
                        visible: (isRight == 0 || isRight == 2 ) && status !=0
                        text: errorName == undefined ? "" : errorName
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        text: qsTr("解析")
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        color: "#c9930c"
                    }

                    Text {
                        width: parent.width
                        text: analyse
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        wrapMode: Text.WordWrap
                    }

                }

            }

            Component.onCompleted: {
                if(role == "teacher"){
                console.log("======fillBlankView::clip22222222222222======",photosModel.count,clipStatus);
                if(photosModel.count == 0 && clipStatus){
                    sigLoadingSuccess();
                }
            }
            }
        }
    }

    ListModel{
        id: topicModel
    }

    Component.onCompleted: {
        if(role == "teacher"){
            console.log("======fillBlankView::clip3333333333======",photosModel.count,clipStatus);
            //如果没有快照则直接截图
            if(photosModel.count == 0 && clipStatus){
                sigLoadingSuccess();
                console.log("======clip111111111111======");
            }
        }
    }

    function clipFillBalnkImage(){
        console.log("======clipFillBalnkImage======",topicListView.height)
        return topicListView;
    }

    function setClipStatus(status,complexStatus){
        clipStatus = status;
        isComplexClip = complexStatus;
        scrollbar.visible = false;
        console.log('======setClipStatus========',isComplexClip,clipStatus)
    }
    //获取当前是否缓存过 显示题型的答案 如果有 就取出赋值
    function getCurrentBufferList()
    {
        var hasSave = 0;
        var temp = [];
        currentBufferAnswer = [];
        for( var a = 0; a<hasBufferedQuestionAnswerList.length; a++)
        {
            if(currentBufferId == hasBufferedQuestionAnswerList[a].questionId)
            {
                currentBufferAnswer = hasBufferedQuestionAnswerList[a].questionData;
                hasSave = 1;
                break
            }
        }
        //不存在就 存进去默认全部都不选中
        if(hasSave == 0)
        {
            for(var cc = 0; cc < currentItemNumber; cc++)
            {
                currentBufferAnswer.push("");
                temp.push("");
            }
            hasBufferedQuestionAnswerList.push({"questionData":temp,"questionId":currentBufferId})
        }
    }
    //更新 当前缓存的题的答案数据
    function resetHasBufferAnswerList(currentAnswer,indexs)//
    {
        var tempList = [];
        for(var b = 0; b < hasBufferedQuestionAnswerList.length; b++)
        {
            if(currentBufferId == hasBufferedQuestionAnswerList[b].questionId)
            {
                tempList = hasBufferedQuestionAnswerList[b].questionData;
                tempList[indexs] = currentAnswer;
                hasBufferedQuestionAnswerList[b] =({"questionData":tempList,"questionId":currentBufferId})
            }
        }
    }
}
