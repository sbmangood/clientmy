import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import "./Configuuration.js" as Cfg

/*
*填空题页面
*/

Item {
    id: fillblankView
    anchors.fill: parent

    property string contentTopic: ""//题目内容
    property var dataModel: [];//代入数据模型
    property var questionItemsModel: [];
    property var answerModel: [];
    property var knowledgesModels: [];
    property bool isScroll: false;

    property string baseImages: "";//题目是否已做完显示数据
    property var baseImageObj: [];
    property int topicStatus: 0;//题目是否做完 0未作，2待批改，4批改完成
    property bool clipStatus: false;
    property bool isComplexClip: false;//是否是综合题截图

    //批改信号
    signal sigCorrect(var imageUrl,var status,var imgWidth,var imgHeight);//图片路径、题目状态,题目类型
    signal sigLoadingSuccess();//加载完成进行截图

    //解析数据
    onDataModelChanged: {
        topicModel.clear();
        baseImages = "";
        topicStatus = 0;
        if(dataModel == [] || dataModel.length == 0){
            return;
        }

        var answer = dataModel.answer;       
        if(questionItemsModel  == "" || questionItemsModel == null){
            questionItemsModel = [];
        }

        if(questionItemsModel.length > 0){
            questionItemsModel.splice(0,questionItemsModel.length);
        }


        var studentAnswerStr;
        var studentAnswerArray = [];
        if(dataModel.studentAnswer != null){
            studentAnswerStr = dataModel.studentAnswer;
            studentAnswerArray = studentAnswerStr.split("|*|");
        }

        photosModel.clear();
        if(dataModel.allImages != null){
            for(var z = 0; z < dataModel.allImages.length; z++){
                console.log("======allImages=======",dataModel.allImages[z]);
                photosModel.append(
                            {
                                "imageStatus": 2,
                                "imageUrl": dataModel.allImages[z],
                            });
            }
        }

        console.log("========photosModel============",photosModel.count )

        for(var i = 0; i < answer.length; i++){
            questionItemsModel.push(
                        {
                            "contentText": "",
                            "answerText": studentAnswerArray.length > i ? studentAnswerArray[i] : "",
                        })
        }
        if(questionItemsModel.length == 0)
        {
            questionItemsModel.push(
                        {
                            "contentText": "",
                            "answerText": studentAnswerArray.length > 0 ? studentAnswerArray[0] : "",
                        })
        }
        console.log("====CloudFillBlankView===",questionItemsModel.length,JSON.stringify(questionItemsModel),answer.length,studentAnswerArray.length);
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
                    });
        topicStatus = dataModel.status;
        var imgwidth;
        var imgheight;
        if(dataModel.baseImage != null){
            baseImages = dataModel.baseImage.imageUrl == null ? "" : dataModel.baseImage.imageUrl;
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

    ListModel{//快照和书写图片数据模型
        id: photosModel
    }

    ListView{
        id: topicListView
        width: parent.width
        height: parent.height
        clip: true
        visible:  {
            if(baseImages == ""){
                sigCorrect("",5,0,0);
                return true;
            }else{
                return  false
            }
        }
        onVisibleChanged: {
            console.log("=====cloudFillBlankView::visible========",visible);
        }

        model: topicModel
        delegate: topicDelegate
    }

    //滚动条
    Item {
        id: scrollbar
        anchors.right: parent.right
        anchors.top: parent.top
        width:14 * heightRate
        height:parent.height
        visible: topicListView.height > fillblankView.height ? true : false
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
            height: {
                var mutilValue = topicListView.height / parent.height;
                if(mutilValue > 1){
                    return parent.height / mutilValue;
                }else{
                    return parent.height * mutilValue;
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
                    return  fillblankView.height * 0.4  + topicRow.height + questionItemsModel.length * 160 * heightRate;
                }else{
                    var numbers = questionItemsModel == null || questionItemsModel == "" ? 0 : questionItemsModel.length;
                    return  fillblankView.height * 0.4  + topicRow.height + photosModel .count * fillblankView.height + numbers * 160 * heightRate;
                }
            }

            onHeightChanged: {
                console.log("=====cloudFillBlankView::width====",height,topicListView.height,clipStatus);
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

                Text {
                    text: content
                    width: parent.width - topicType.width - 40 * widthRate
                    wrapMode: Text.WordWrap
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 18 * heightRate
                    verticalAlignment: Text.AlignVCenter
                    textFormat: Text.RichText
                }
            }

            //子题目显示
            ListView{
                id: childTopicListView
                clip: true
                visible: !haschild
                width: parent.width - 20
                height: {
                    return parent.height  - topicRow.height  - 50 * heightRate -  photosModel .count * fillblankView.height;// + numbers * 160 * heightRate
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
                        readOnly: true
                        width: parent.width - 60 * heightRate
                        height: parent.height - 20 * heightRate
                        anchors.left: parent.left
                        anchors.leftMargin: 40 * heightRate
                        font.family: Cfg.font_family
                        font.pixelSize: 16 * heightRate
                        selectByMouse: true
                        selectionColor: "blue"
                        selectedTextColor: "#ffffff"
                        wrapMode: TextArea.WordWrap
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
                                visible: questionItemsModel.length == 1 ? false : true
                            }
                        }
                        text: questionItemsModel[index].answerText == "gapBlank" ? "未做" : questionItemsModel[index].answerText
                    }
                }
            }

            //显示快照
            ListView{
                id: phpos
                clip: true
                visible: clipStatus && isComplexClip == false ? true : false
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

            Component.onCompleted: {                
                console.log("======fillBlankView::clip22222222222222======",photosModel.count,clipStatus);
                if(photosModel.count == 0 && clipStatus){
                    sigLoadingSuccess();
                }
            }
        }
    }

    ListModel{
        id: topicModel
    }

    Component.onCompleted: {
        console.log("======fillBlankView::clip3333333333======",photosModel.count,clipStatus);
        //如果没有快照则直接截图
        if(photosModel.count == 0 && clipStatus){
            sigLoadingSuccess();
            console.log("======clip111111111111======");
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
}
