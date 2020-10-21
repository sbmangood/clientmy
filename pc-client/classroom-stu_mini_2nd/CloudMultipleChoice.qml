import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import "Configuration.js" as Cfg
//import QtWebView 1.1

/*
*简答题页面
*/

Rectangle {
    anchors.fill: parent
    color: "white"
    property string contentTopic: ""//题目内容
    property var dataModel: [];//代入数据模型
    property var questionItemsModel: [];
    property var answerModel: [];
    property var knowledgesModels: [];
    property bool isScroll: true;//是否显示滚动条
    property  var currentQuestionId: ;
    property var currentBufferedAnswer: "";
    property var hasBufferedQuestionAnswerList: [];//已经存储过的 答案列表 结构  question id  + 选项数组（json存储）


    property int currentViewModel: 1;// 当前的显示模式 1 做题模式  2 对答案模式

    signal saveStudentAnswer( var studentSelectAnswer, var questionId , var orderNumber );//提交学生答案

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
        //console.log("====onDataModelChanged====",JSON.stringify(dataModel))
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
        //anchors.rightMargin: 5 * heightRate
        anchors.top: topicListView.top
        width:14 * heightRate
        height:topicListView.height
        visible: false
        z: 230
        Rectangle{
            anchors.fill: parent
            color: "#eeeeee"
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 4 * heightRate
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
            anchors.horizontalCenter: parent.horizontalCenter
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
                    console.log(" onMouseYChanged: { onMouseYChanged: {");
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
            height: topicListView.height +  120 * heightRate + topicRow.height

            onHeightChanged: {
                scrollbar.visible = false;
                if(height > topicListView.height && isScroll){
                    scrollbar.visible = true;
                }else{
                    scrollbar.visible = false;
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
                //                WebView
                //                {
                //                  width: parent.width - topicType.width - 40 * widthRate
                //                  height: 100
                //                  url: "file:///C:/Users/Administrator/Desktop/test1.html"
                //                }

                Text {
                    text: content
                    width: parent.width - topicType.width - 40 * widthRate
                    wrapMode: Text.WordWrap
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 18 * heightRate
                    verticalAlignment: Text.AlignVCenter
                    textFormat: Text.RichText
                }


                /*
                WebView
                {
                    id:webView
                    width: parent.width - topicType.width - 40 * widthRate
                    height: text.height
                  //  url: "file:///C:/Users/Administrator/Desktop/test1.html"
                }

                Text {
                    id:text
                    text: content
                    width:0 //parent.width - topicType.width - 40 * widthRate
                    wrapMode: Text.WordWrap
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 18 * heightRate
                    verticalAlignment: Text.AlignVCenter
                    textFormat: Text.StyledText
                    visible: false
                    onTextChanged:
                    {
                        var tempText = Cfg.htmlStyle;
                        console.log(tempText,"sdddddddddddddddd")
                        tempText = tempText.replace("body_body",content)
                         console.log(tempText,"sdddddddddddddddd")
                        webView.loadHtml(tempText);
                    }

                }
*/
            }

            Rectangle{
                visible: !haschild
                width: parent.width - 20 * widthRate
                height: 300 * heightRate
                anchors.top: topicRow.bottom
                anchors.topMargin: 10 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 10 * heightRate
                color: "#ffffff"
                border.width: 2
                border.color: "#c3c6c9"

                TextArea{
                    id:tempTextArea
                    anchors.fill: parent
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 18 * heightRate
                    wrapMode: TextArea.Wrap
                    text:currentInputAnswer;
                    selectByMouse: true
                    placeholderText: "请输入答案"
                    onTextChanged:
                    {
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

            //子题目显示
            ListView{
                id: childTopicListView
                clip: true
                visible: haschild
                width: parent.width - 20
                height: parent.height//- knowledges.count * 18 * heightRate
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
                    height: 300 * heightRate
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
                                textFormat: Text.StyledText
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
                                readOnly: !questionItemsModel[index].isright// !isright //
                            }
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
