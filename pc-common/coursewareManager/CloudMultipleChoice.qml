import QtQuick 2.7
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtWebEngine 1.4
import "./Configuuration.js" as Cfg

/*
*简答题页面 5
*/

Item {
    id: multipleChoiceView
    anchors.fill: parent
    
    property string role: ""// 角色：教师teacher,学生student,旁听auditor,根据该参数决定界面展示内容
    
    property string contentTopic: ""//题目内容
    property var dataModel: [];//代入数据模型
    property var questionItemsModel: [];
    property var answerModel: [];
    property var knowledgesModels: [];
    property bool isScroll: false;//是否显示滚动条

    property string baseImages: "";//题目是否已做完显示数据
    property int topicStatus: 0;//题目是否做完 0未作，2待批改，4批改完成
    property bool clipStatus: false;
    property bool isComplexClip: false;//是否是综合题截图
    property string questionAnswer: "";
    property var errorName: ;
    //批改信号
    signal sigCorrect(var imageUrl,var status,var imgWidth,var imgHeight);//图片路径、题目状态,题目类型
    signal sigLoadingSuccess();//加载成功信号
    
    
    
    property  var currentQuestionId: ;
    property var currentBufferedAnswer: "";
    property var hasBufferedQuestionAnswerList: [];//已经存储过的 答案列表 结构  question id  + 选项数组（json存储）


    property int currentViewModel: 1;// 当前的显示模式 1 做题模式  2 对答案模式

    signal saveStudentAnswer( var studentSelectAnswer, var questionId , var orderNumber );//提交学生答案

    property bool isEnable: true;

    ListModel{//快照和书写图片数据模型
        id: photosModel
    }
    
    onCurrentViewModelChanged:
    {
        if(currentViewModel == 2)
        {
            multipleChoiceView.enabled = false;
        }
    }

    function answerSubmit()
    {
        console.log(" function answerSubmit() 11111111111");
        //模式显示为对答案模式
        currentViewModel = 2;
        //提交答案到服务器
        saveStudentAnswer(topicModel.get(0).currentInputAnswer,topicModel.get(0).id,topicModel.get(0).orderNumber);
    }

    //解析数据
    onDataModelChanged: {
        topicModel.clear();
        if(dataModel == [] || dataModel.length == 0){
            return;
        }
        if(role == "teacher"){
            baseImages = "";
            topicStatus = 0;
            photosModel.clear();
            if(dataModel.allImages != null){
                for(var z = 0; z < dataModel.allImages.length; z++){
                    console.log("======cloudMultiple::allImages=======",dataModel.allImages[z]);
                    photosModel.append(
                                {
                                    "imageStatus": 2,
                                    "imageUrl": dataModel.allImages[z],
                                });
                }
            }
            topicModel.append(
                        {
                            "analyse": dataModel.analyse,//题目分析
                            "answer": dataModel.answer,//题目正确答案
                            "reply": dataModel.reply,//题目解答
                            "lastUpdatedDate": dataModel.lastUpdatedDate,
                            "photos": dataModel.photos,//拍照照片
                            "status": dataModel.status, //题目状态
                            "content": dataModel.content,//标题
                            "questionType": dataModel.questionType,//题目类型
                            "knowledges": dataModel.knowledges,//知识点对象集合
                            "studentAnswer": dataModel.studentAnswer == null ? "" : dataModel.studentAnswer,//学生正确答案
                                                                               "questionItems": dataModel.questionItems,//题目选项
                                                                               "orderNumber": dataModel.orderNumber,//题目序号
                                                                               "studentScore": dataModel.studentScore,//学生分数
                                                                               "useTime": dataModel.useTime,//答题用时
                                                                               "childQuestionInfo": dataModel.childQuestionInfo,//子题集合，数据结构和父类一样
                                                                               "teacherImages": dataModel.teacherImages,//老师批注
                                                                               "originImage": dataModel.originImage,//老师批注的原始图片
                                                                               "image": dataModel.image,//老师批注图片，为空字符串时也是没有批注
                                                                               "isRight": dataModel.isRight,//答案是否正确 0：错误，1：正确，2：半对半错
                                                                               "haschild": dataModel.haschild,//是否有子题
                                                                               "baseImage": dataModel.baseImage,//
                                                                               "writeImages":dataModel.writeImages,
                        });

            topicStatus = dataModel.status;
            var imgwidth;
            var imgheight;
            if(dataModel.baseImage != null){
                baseImages = (dataModel.baseImage.imageUrl == null  || dataModel.baseImage.imageUrl == "") ? "" : dataModel.baseImage.imageUrl;
                imgwidth = dataModel.baseImage.width;
                imgheight =  dataModel.baseImage.height;
            }
            if(baseImages != ""){
                sigCorrect(baseImages,2,imgwidth,imgheight);
            }
            var answer = answerModel;//items.answer;
            for(var b = 0 ; b < answer.length ; b++ ){
                questionAnswer = answer[b];
            }
            errorName= dataModel.errorName == null ? "" : dataModel.errorName;
        }
        else if(rloe == "student"){
            if(currentQuestionId == "" || currentQuestionId != dataModel.id)
            {
                currentBufferedAnswer = "";
            }
            currentQuestionId = dataModel.id;
            //查找是否存在该题目缓存的答案
            getCurrentBufferList();
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
                            "haschild": dataModel.haschild,//是否有子题
                            "currentInputAnswer":currentBufferedAnswer,
                        })
            currentOrderNumber = dataModel.orderNumber;
        }
    }

    ListView{
        id: multipleListView
        width: parent.width
        height: parent.height
        clip: true
        visible: {
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
        model: topicModel
        delegate: topicDelegate
        boundsBehavior: {
            if(role == "student"){
                return ListView.StopAtBounds;
            }
        }

        //滚动条
        Item {
            id: scrollbar
            anchors.right: multipleListView.right
            anchors.top: multipleListView.top
            width:14 * heightRate
            height: parent.height
            visible: (role == "teacher" && multipleListView.height > multipleChoiceView.height && multipleListView.visible) ? true : false
            z: 3
            Rectangle{
                anchors.fill: parent
                color: "#eeeeee"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            // 按钮
            Rectangle {
                id: button
                x: 2
                y: role == "teacher" ? 0 : topicListView.visibleArea.yPosition * scrollbar.height
                width: parent.width
                height: multipleListView.visibleArea.heightRatio * scrollbar.height * 0.5;
                color: "#ff5000"
                radius: 8 * heightRate
                anchors.horizontalCenter: {
                    if(role == "student"){
                        return parent.horizontalCenter;
                    }
                }
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
                        multipleListView.contentY = button.y / scrollbar.height * multipleListView.contentHeight
                    }
                }
            }
        }

        Component{
            id: topicDelegate
            Item{
                id: bodyItem
                width: multipleListView.width
                height: {
                    if(role == "teacher"){
                        if(isComplexClip){
                            return  multipleChoiceView.height * 0.5 + topicRow.height + answerView.height;
                        }else{
                            return  multipleChoiceView.height * 0.5 + topicRow.height + multipleChoiceView.height * photosModel.count + 100 * heightRate + answerView.height;
                        }
                    }
                    else if(role == "student"){
                        multipleChoiceView.height +  120 * heightRate + topicRow.height
                    }
                }
                onHeightChanged: {
                    if(role == "teacher"){
                        if(clipStatus){//如果是滚动并且截图才设置高度
                            if(isComplexClip){
                                multipleListView.height = height;
                            }else{
                                topicRow.topPadding = 100 * heightRate;
                                multipleListView.height = height + 100 * heightRate;
                            }
                            return;
                        }
                        multipleListView.height  = multipleChoiceView.height;
                    }
                    else if(role == "student"){
                        scrollbar.visible = false;
                        if(height > topicListView.height && isScroll){
                            scrollbar.visible = true;
                        }
                        else{
                            scrollbar.visible = false;
                        }
                    }
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
                            text:  "简答题"
                            font.family: Cfg.DEFAULT_FONT
                            font.pixelSize: 14 * heightRate
                            color: "#ffffff"
                            anchors.centerIn: parent

                        }
                    }

                    WebEngineView{
                        id: contentText
                        enabled: true
                        width: role == "teacher" ? (parent.width - 40 * heightRate - topicType.width) : (parent.width - 40 * widthRate - topicType.width)
                        height: 45 * heightRate
                        backgroundColor: "#00000000"

                        //右键的时候, 不弹出右键菜单
                        onContextMenuRequested: function(request) {
                            request.accepted = true;
                        }

                        onContentsSizeChanged: {
                            contentText.height = contentText.contentsSize.height;
                        }

                        Component.onCompleted: {
                            content = "<html>" + content + "</html> \n" + "<style> *{font-size:1.5vw!important;} </style>";
                            loadHtml(content);
                        }
                    }
                }

                Rectangle{
                    visible: !haschild
                    width: role == "teacher" ? (parent.width - 80 * heightRate) : (parent.width - 20 * widthRate)
                    height:  role == "teacher" ? 220 * heightRate : 300 * heightRate
                    anchors.top: topicRow.bottom
                    anchors.topMargin: role == "teacher" ? 20 * heightRate : 10 * heightRate
                    anchors.left: {
                        if(role == "teacher"){
                            return parent.left;
                        }
                    }
                    anchors.leftMargin: {
                        if(role == "teacher"){
                            return 50 * heightRate;
                        }
                    }
                    anchors.horizontalCenter: {
                        if(role == "student"){
                            return parent.horizontalCenter;
                        }
                    }
                    radius: 10 * heightRate
                    color: "#ffffff"
                    border.width: 2
                    border.color: role == "teacher" ? "#dddddd" : "#c3c6c9"

                    TextArea{
                        id:tempTextArea
                        anchors.fill: parent
                        readOnly: role == "teacher" ? true : false
                        text: role == "teacher" ? (studentAnswer == null || studentAnswer == "gapBlank" ? "" :  studentAnswer) : currentInputAnswer
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: role == "teacher" ? 14 * heightRate : 18 * heightRate
                        wrapMode: role == "teacher" ? TextArea.WordWrap : TextArea.Wrap
                        selectByMouse: role == "student" ? true : false
                        placeholderText: role == "student" ? "请输入答案" : ""
                        onTextChanged:
                        {
                            if(role == "student"){
                                if(tempTextArea.text.length > 500)
                                {
                                    tempTextArea.text = tempTextArea.getText(0,499);
                                }
                                currentInputAnswer = tempTextArea.text;
                                currentBufferedAnswer = tempTextArea.text;
                                resetHasBufferAnswerList(tempTextArea.text);
                            }
                        }
                    }
                }

                //子题目显示
                ListView{
                    id: childTopicListView
                    clip: true
                    visible: haschild
                    width: parent.width - 20
                    height: role == "teacher" ? (parent.height - answerView.height - topicRow.height - photosModel.count * multipleChoiceView.height) : parent.height
                    anchors.top: topicRow.bottom
                    anchors.topMargin: 10 * heightRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    delegate: childTopicDelegate
                    model: questionItemsModel
                }

                //显示快照
                ListView{
                    id: phpos
                    clip: true
                    visible: (role == "teacher") && clipStatus && isComplexClip == false ? true : false
                    width: parent.width - 20
                    height: multipleChoiceView.height * photosModel.count - topicType.height
                    anchors.top: childTopicListView.bottom
                    model: photosModel
                    anchors.horizontalCenter: parent.horizontalCenter
                    boundsBehavior: ListView.StopAtBounds
                    delegate: Item{
                        width: multipleChoiceView.width
                        height: multipleChoiceView.height
                        Image{
                            width: multipleChoiceView.width
                            height: multipleChoiceView.height
                            source: imageUrl
                            sourceSize.width: multipleChoiceView.width
                            sourceSize.height: multipleChoiceView.width

                            onStatusChanged: {
                                if(status == Image.Error){
                                    imageStatus = 1;
                                }
                                console.log("======cloudMultip::imageUrl=====",imageUrl);
                                if(status == Image.Ready){
                                    imageStatus = status;
                                }
                                var currentStatus = true;
                                for(var i = 0; i < photosModel.count; i++){
                                    if(photosModel.get(i).imageStatus != 1){
                                        currentStatus = false;
                                        break;
                                    }
                                }
                                if(currentStatus  && clipStatus){
                                    sigLoadingSuccess();
                                    console.log("=====clip3333333=======");
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
                            text:questionAnswer
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
                            text: errorName
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

                Component{
                    id: childTopicDelegate
                    Item{
                        width: childTopicListView.width
                        height: role == "teacher" ? 220 * heightRate : 300 * heightRate
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

                        //子标题布局
                        Row{
                            id: childTopicRow
                            width: parent.width
                            anchors.top: parent.top
                            anchors.topMargin: 40 * heightRate
                            spacing: 10 * heightRate

                            Rectangle{
                                id: titleItem
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
                                    text:  "简答题"
                                    font.family: Cfg.DEFAULT_FONT
                                    font.pixelSize: 14 * heightRate
                                    color: "#ffffff"
                                    anchors.centerIn: parent
                                }
                            }

                            ListModel{
                                id: childModel
                            }

                            property int indexs:  index == 0 ? -1 : index;

                            onIndexsChanged: {
                                if(indexs == -1){
                                    childModel.append(
                                                {
                                                    "contents": questionItemsModel[index].contents,
                                                    "isright": questionItemsModel[index].isright,
                                                    "orderName": questionItemsModel[index].orderName,
                                                    "orderno": questionItemsModel[index].orderno,
                                                    "qitemid": questionItemsModel[index].qitemid,
                                                    "questionid": questionItemsModel[index].questionid,
                                                    "score": questionItemsModel[index].score,
                                                })
                                    return;
                                }

                                childModel.append(
                                            {
                                                "contents": questionItemsModel[indexs].contents,
                                                "isright": questionItemsModel[indexs].isright,
                                                "orderName": questionItemsModel[indexs].orderName,
                                                "orderno": questionItemsModel[indexs].orderno,
                                                "qitemid": questionItemsModel[indexs].qitemid,
                                                "questionid": questionItemsModel[indexs].questionid,
                                                "score": questionItemsModel[indexs].score,
                                            })
                            }


                            //题目内容
                            ListView{
                                clip: true
                                width: parent.width - titleItem.width - 20 * widthRate
                                height: 60 * heightRate
                                model: childModel // questionItemsModels.get(index) //

                                delegate: Text {
                                    width: parent.width
                                    font.family: Cfg.DEFAULT_FONT
                                    font.pixelSize: 16 * Screen.width * 0.8 / 966.0 / 1.5337
                                    wrapMode: Text.WordWrap
                                    text: orderno + ". " + orderName
                                    textFormat: Text.RichText
                                }
                            }
                        }
                        //副文本内容
                        Item{
                            width: parent.width - 20
                            height: parent.height - childTopicRow.height - 50 * heightRate
                            anchors.top: childTopicRow.bottom
                            anchors.topMargin: 10 * heightRate
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle{
                                width: parent.width
                                height: parent.height - 10
                                radius: 10 * heightRate
                                color: "#ffffff"
                                border.width: 2
                                border.color: "#c3c6c9"

                                TextArea{
                                    anchors.fill: parent
                                    text: questionItemsModel[index].contents // contents //
                                    font.family: Cfg.DEFAULT_FONT
                                    font.pixelSize: 14 * heightRate
                                    wrapMode: TextArea.WordWrap
                                    readOnly: role == "teacher" ? true : (!questionItemsModel[index].isright)
                                }
                            }
                        }
                    }
                }

                Component.onCompleted: {
                    if(role == "teacher"){
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
                //如果没有快照则直接截图
                if(photosModel.count == 0 && clipStatus){
                    sigLoadingSuccess();
                }
            }
        }


        function multipleChoiceClipImage(){
            scrollbar.visible = false;
            return multipleListView;
        }

        function setMultipleClipStatus(status,complexStatus){
            console.log("===setMultipleClipStatus====",status,complexStatus);
            isComplexClip = complexStatus
            clipStatus = status;
        }
        //获取当前是否缓存过 显示题型的答案 如果有 就取出赋值
        function getCurrentBufferList()
        {
            var hasSave = 0;
            var tempAnswers = "" ;
            currentBufferedAnswer = "";
            for( var a = 0; a < hasBufferedQuestionAnswerList.length; a++)
            {
                if(currentQuestionId == hasBufferedQuestionAnswerList[a].questionId)
                {
                    currentBufferedAnswer = hasBufferedQuestionAnswerList[a].questionData;
                    hasSave = 1;
                    break;
                }
            }
            //不存在就 添加默认值
            if(hasSave == 0)
            {
                hasBufferedQuestionAnswerList.push({"questionData":tempAnswers,"questionId":currentQuestionId})
            }
        }
        //更新 当前缓存的题的答案数据
        function resetHasBufferAnswerList(currentAnswer)//
        {
            var tempAnswer = currentAnswer;
            for(var b = 0; b < hasBufferedQuestionAnswerList.length; b++)
            {
                if(currentQuestionId == hasBufferedQuestionAnswerList[b].questionId)
                {
                    hasBufferedQuestionAnswerList[b] =({"questionData":tempAnswer,"questionId":currentQuestionId})
                }
            }
        }
    }
