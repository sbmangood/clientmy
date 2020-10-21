import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtWebEngine 1.4
import "Configuration.js" as Cfg

/*
*填空题页面
*/

Rectangle {
    id:fillblankView
    anchors.fill: parent
    property string contentTopic: ""//题目内容
    property var dataModel: [];//代入数据模型
    property var questionItemsModel: [];
    property var answerModel: [];
    property var knowledgesModels: [];
    property bool isScroll: true;

    property var hasBufferedQuestionAnswerList: [];//已经存储过的 答案列表 结构  question id  + 选项数组（json存储）
    property var currentBufferAnswer:[] ;//当前缓存答案值
    property  int  currentItemNumber: 1;//当前输入框的数量

    property var currentBufferId : ;//当前缓存题目的id

    property int currentViewModel: 1;// 当前的显示模式 1 做题模式  2 对答案模式

    signal saveStudentAnswer( var studentSelectAnswer, var questionId ,var orderNumber);//提交学生答案

    property bool isEnable: true;
    MouseArea
    {
        anchors.fill: parent
        enabled: isEnable
        visible: isEnable
        z:1000
        onClicked: {
            return;
        }
    }


    onCurrentViewModelChanged:
    {
        if(currentViewModel == 2)
        {
            fillBlankView.enabled = false;
        }
    }

    function answerSubmit()
    {
        console.log(" function answerSubmit() 11111111111");
        //模式显示为对答案模式
        currentViewModel = 2;

        //获取填空的内容
        var tempAnswer = "";
        for(var a = 0; a<questionItemsModel.length ; a++  )
        {
            var tas = questionItemsModel[a].contentText == "" ? "gapBlank" : questionItemsModel[a].contentText;
            if(tempAnswer == "")
            {
                tempAnswer = tempAnswer + tas == "" ? "gapBlank" : tas
            }else
            {
                tempAnswer = tas == "" ? tempAnswer  + "|*|" + "gapBlank" : tempAnswer  + "|*|" + tas
            }

            // console.log("answerSubmit(1111)",tempAnswer);
        }
        //console.log("answerSubmit(1111) to submit server ",tempAnswer);
        //提交答案到服务器 orderno(int型)
        saveStudentAnswer(tempAnswer,topicModel.get(0).id ,topicModel.get(0).orderNumber);
    }


    //解析数据
    onDataModelChanged: {
        topicModel.clear();

        console.log("afsddddddddddanswerModel",JSON.stringify(dataModel));
        if(dataModel == [] || dataModel.length == 0){
            return;
        }


        var answer ;
        if(dataModel.tempRemaker == null || dataModel.tempRemaker == undefined)
        {
            answer = dataModel.answer.length;
        }else
        {
            answer = dataModel.answer;
        }
        currentItemNumber = answer;

        //        if(currentBufferId == "" || currentBufferId != dataModel.id) {
        //            currentBufferAnswer.splice(0,currentBufferAnswer.length);
        //            for(var ii = 0; ii < answer.count; ii++)
        //            {
        //                currentBufferAnswer.push("");
        //            }
        //        }
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

        console.log("====onDataModelChanged111111111111====",answer,  dataModel.answer.length,questionItemsModel.length)
    }

    ListView{
        id: topicListView
        width: parent.width
        height: parent.height
        clip: true
        model: topicModel
        delegate: topicDelegate
        boundsBehavior: ListView.StopAtBounds
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

        Item{
            id: bodyItem
            width: topicListView.width
            height: topicListView.height * 0.5 + questionItemsModel.length * 100 * heightRate + topicRow.height//* 0.5 + knowledges.count * 300 * heightRate

            onHeightChanged: {
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
                        text:  "填空题";
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
                height: parent.height  - topicRow.height - 50 * heightRate
                anchors.top: topicRow.bottom
                anchors.topMargin: 10 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                delegate: childTopicDelegate
                model: questionItemsModel // knowledges //
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
                        id:textareas
                        width: parent.width - 60 * heightRate
                        height: parent.height - 20 * heightRate
                        anchors.left: parent.left
                        anchors.leftMargin: 40 * heightRate
                        font.family: Cfg.font_family
                        font.pixelSize: 16 * heightRate
                        placeholderText: "请输入答案"
                        selectByMouse: true
                        selectionColor: "blue"
                        selectedTextColor: "#ffffff"
                        text: questionItemsModel[index].contentText
                        wrapMode: TextArea.Wrap
                        background: Rectangle{
                            anchors.fill: parent
                            color: "#ffffff"
                            radius: 8 * widthRate
                            border.width: 1
                            border.color: "#cccccc"
                            Rectangle{
                                visible: questionItemsModel.length < 1
                                color: "#ffffff"
                                width: 10 * widthRate
                                height: parent.height - 4
                                anchors.top: parent.top
                                anchors.topMargin: 2
                            }
                        }

                        onTextChanged: {
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
    }

    ListModel{
        id: topicModel
    }

    Component.onCompleted: {

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
