import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtWebEngine 1.4
import "./Configuuration.js" as Cfg

/*
*综合题页面
*/

Rectangle {
    id: compositeTopicItem
    anchors.fill: parent
    color: "transparent"
    property string contentTopic: ""//题目内容
    property var dataModel: [];//代入数据模型
    property var bufferData: [];//缓存显示的数据

    signal sigIsMultipleTopic(var childStatus);//是否有多题信号
    signal sigPageChange(string pageStatus);//分页发生变化
    signal sigJumpTopic(var jump,var pages);//大题下一题 or 上一题
    signal sigScrollImage(var contentY);

    property string baseImages: "";//题目是否已做完显示数据
    property var baseImageObj: [];//图片展示对象
    property int topicStatus: 0;//题目是否做完 0未作，2待批改，4批改完成
    property var answerModel: [];

    //批改信号
    signal sigCorrect(var filePath,var status,var imgWidth,var imgHeight);

    //当前题目Id信号
    //signal sigTopicId(var questionId);

    //批改信号
    signal sigCorrectInfos(var questionId,var childQuestionId,var score,var correctType,var errorReason);

    //解析数据
    onDataModelChanged: {
        topicModel.clear();
        baseImages = "";
        if(baseImageObj.length > 0){
            baseImageObj.splice(0,baseImageObj.length);
        }

        if(dataModel == [] || dataModel.length == 0){
            return;
        }
        topicModel.append(
                    {
                        "analyse": dataModel.analyse,//题目分析
                        "answer": (dataModel.answer == null ? [] : dataModel.answer),//题目正确答案
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
                        "baseImage": dataModel.baseImage,//
                        "writeImages":dataModel.writeImages,
                    });

        topicStatus = dataModel.status;
        var imgWidth;
        var imgHeight;
        if(dataModel.baseImage != null){
            baseImages = dataModel.baseImage.imageUrl == null ? "" : dataModel.baseImage.imageUrl;
            baseImageObj = dataModel.baseImage;
            imgWidth = dataModel.baseImage.width;
            imgHeight = dataModel.baseImage.height;
        }
        if(baseImages != ""){
            sigCorrect(baseImages,2,imgWidth,imgHeight);
        }
        button.y = 0;
        console.log("====cloudComposite::baseImages====",baseImages,JSON.stringify(baseImageObj));
    }

    ListView{
        id: topicListView
        width: parent.width
        height: fullScreenType == false ? parent.height : fullHeight
        clip: true
        visible:  {
            if(baseImages == ""){
                sigCorrect("",5,0,0);
                return true;
            }else{
                return  false
            }
        }
        model: topicModel
        delegate: topicDelegate
    }

    //ListView滚动条
    Item {
        id: scrollbar
        anchors.right: topicListView.right
        anchors.top: topicListView.top
        width:14 * heightRate
        height:topicListView.height
        visible: false//topicListView.height > compositeTopicItem.height ? true : false

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
            y: 0//topicListView.visibleArea.yPosition * scrollbar.height
            width: parent.width
            height: topicListView.visibleArea.heightRatio * scrollbar.height
            color: "#cccccc"
            radius: 8 * heightRate

            // 鼠标区域
            MouseArea {
                anchors.fill: button
                drag.target: button
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: scrollbar.height - button.height
                cursorShape: Qt.PointingHandCursor
                // 拖动
                onMouseYChanged: {
                    topicListView.contentY = button.y / button.height * topicListView.contentHeight
                }
            }
        }
    }

    Component{
        id: topicDelegate
        Rectangle{
            id: bodyItem
            clip: true
            width: topicListView.width
            height:  fullScreenType == false ? topicListView.height : fullHeight * 0.89
            onHeightChanged: {
                scrollbar.visible = false;
                if(height > compositeTopicItem.height){
                    scrollbar.visible = true;
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
                    width: parent.width - 40 * heightRate - topicType.width
                    height: 45 * heightRate
                    backgroundColor: "#00000000"

                    //右键的时候, 不弹出右键菜单
                    onContextMenuRequested: function(request) {
                        request.accepted = true;
                    }

                    onContentsSizeChanged: {
                        questionTitle.height = questionTitle.contentsSize.height;
                        bodyItem.height = compositeTopicItem.height  + contentsSize.height;
                        console.log("====Compostite::height===",contentsSize.height,compositeTopicItem.height);
                    }

                    Component.onCompleted: {
                        loadHtml(content);
                    }
                }
            }

            //子题目显示
            ListView{
                id: childTopicListView
                clip: true
                width: parent.width - 20
                height: fullScreenType ? parent.height : fullHeight //- topicRow.height - 60 * heightRate//  + topicRow.height - knowledges.count * 460 * heightRate
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
                    height: childTopicListView.height * 1.5 *  heightRate
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image{
                        z: 2
                        anchors.top: parent.top
                        anchors.topMargin: 2 * heightRate
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

                    property var childQuestionInfos: childQuestionInfo
                    property var questionItemsModel : [];
                    property int currentIndexs: 1;

                    //五大题型操作界面
                    ShowQuestionHandlerView{
                        id: questionHandlerView
                        width: parent.width -10 * heightRate
                        height: parent.height - 24 * heightRate
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2 * heightRate
                        visible: false
                    }

                    onChildQuestionInfosChanged: {
                        analysisData(index);
                    }

                    function analysisData(index){
                        if(bufferData.length > 0){
                            bufferData.splice(0,bufferData.length);
                        }
                        //console.log("**********questionTypes***********",index,questionType,haschild,childQuestionInfo);

                        var questionTypes = -1;
                        if(childQuestionInfo == null){
                            bufferData = {};
                            return;
                        }else{
                            //console.log("---------------questionTypes-----------",childQuestionInfo.count);
                            questionTypes = childQuestionInfo.get(index).questionType;

                            var  answerBuffer = answerModel[index];
                            //console.log("=======answerBuffer========",answerModel[index]);
                            bufferData = {
                                "id": childQuestionInfo.get(index).id,
                                "analyse": childQuestionInfo.get(index).analyse,//题目分析
                                "answer": answerBuffer,//childQuestionInfo.get(index).answer,//题目正确答案
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

                            if(questionItemsModel.length > 0){
                                questionItemsModel .splice(0,questionItemsModel.length);
                            }

                            var questionItems = childQuestionInfo.get(index).questionItems;
                            if(questionItems != null){
                                for(var  i = 0; i < questionItems.count; i++){
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


                            //传递当前答案解析信息
                            sigCorrectInfos( id,
                                            childQuestionInfo.get(index).id,
                                            childQuestionInfo.get(index).score,
                                            childQuestionInfo.get(index).isRight,
                                            childQuestionInfo.get(index).errorType);
                        }
                        //设置五大题型的数据及显示
                        questionHandlerView.visible = false;
                        console.log("=====questionTypes======",questionTypes,JSON.stringify(bufferData))
                        questionHandlerView.questionItemsData = questionItemsModel;
                        questionHandlerView.answerModel =  answerBuffer;//answer;
                        questionHandlerView.knowledgesModels = knowledges;
                        questionHandlerView.setCurrentBeShowedView(bufferData,questionTypes,false,1);
                        questionHandlerView.visible = true;
                        questionHandlerView.isScroll = false;
                    }

                    Component.onCompleted: {
                        compositeTopicItem.sigPageChange.connect(updateData);
                    }

                    //分页改变则数据改变函数
                    function updateData(pageStatus){
                        if(pageStatus == "pre"){
                            var currentIndex = currentIndexs  - 1;
                            console.log("***************child***************",currentIndex,childQuestionInfo)
                            //大题上一题信号

                            if(childQuestionInfo == undefined){
                                //console.log("***************childQuestionInfo::undefined***************");
                                return;
                            }
                            if(currentIndex == -1){
                                sigJumpTopic("pre",currentIndex);
                                return;
                            }
                            if(currentIndex >= 0){
                                if(childQuestionInfo == null){
                                    sigJumpTopic("pre",currentIndex);
                                }else{
                                    if(currentIndex <= childQuestionInfo.count){
                                        analysisData(currentIndex);
                                        currentIndexs = currentIndex;
                                    }
                                }
                            }
                            return;
                        }

                        if(pageStatus == "next"){
                            var nextIndex = currentIndexs  + 1;
                            //console.log("=======child=======",nextIndex,childQuestionInfo)
                            //大题下一题信号
                            if(childQuestionInfo == null  || childQuestionInfo == undefined){
                                return;
                            }
                            if(nextIndex > childQuestionInfo.count){
                                currentIndexs = childQuestionInfo.count;
                                sigJumpTopic("next",currentIndex);
                                return;
                            }

                            if(nextIndex <= childQuestionInfo.count){
                                analysisData(nextIndex -1);
                                currentIndexs = nextIndex;
                            }
                            return;
                        }
                    }

                }
            }
        }
    }

    ListModel{
        id: topicModel
    }

    //上一题、下一题函数
    function updateTopicBody(topicNumber){
        sigPageChange(topicNumber);
        console.log("===updateTopicBody::data===",topicNumber);
    }

}
