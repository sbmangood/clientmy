import QtQuick 2.0
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
    width: parent.width
    height: parent.height

    property string contentTopic: ""//题目内容
    property var dataModel: [];//代入数据模型
    property var questionItemsModel: [];
    property var answerModel: [];
    property var knowledgesModels: [];
    property bool isScroll: false;//是否显示滚动条

    property string baseImages: "";//题目是否已做完显示数据
    property int topicStatus: 0;//题目是否做完 0未作，2待批改，4批改完成
    property bool clipStatus: false;

    //批改信号
    signal sigCorrect(var imageUrl,var status,var imgWidth,var imgHeight);//图片路径、题目状态,题目类型
    signal sigLoadingSuccess();//加载成功信号

    ListModel{//快照和书写图片数据模型
        id: photosModel
    }

    //解析数据
    onDataModelChanged: {
        topicModel.clear();
        baseImages = "";
        topicStatus = 0;
        clipStatus = false;

        //console.log("=======cloudMultiple***============",JSON.stringify(dataModel));
        if(dataModel == [] || dataModel.length == 0){
            return;
        }
        photosModel.clear();
        if(dataModel.writeImages != null){
            for(var z = 0; z < dataModel.writeImages.length; z++){
                photosModel.append(
                            {
                                "imageStatus": 2,
                                "imageUrl": dataModel.writeImages[z],
                            });
            }
        }

        if(dataModel.photos != null){
            for(var k = 0; k < dataModel.photos.length; k++){
                photosModel.append(
                            {
                                "imageStatus": 2,
                                "imageUrl": dataModel.photos[k],
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
            //console.log("=======Multiple::baseImages=======",baseImages);
        }
        //console.log("====onDataModelChanged====",baseImages,topicStatus,JSON.stringify(dataModel))
    }

    ListView{
        id: multipleListView
        width: parent.width
        height: parent.height
        clip: true
        visible: {
            if(baseImages == ""){
                sigCorrect("",5,0,0);
                return true;
            }else{
                return  false
            }
        }
        model: topicModel
        delegate: topicDelegate
        //boundsBehavior: ListView.StopAtBounds
    }

    //滚动条
    Item {
        id: scrollbar
        anchors.right: multipleListView.right
        anchors.top: multipleListView.top
        width:14 * heightRate
        height: parent.height
        visible: multipleListView.height > multipleChoiceView.height ? (multipleListView.visible ? true : false) : false
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
            y: 0//topicListView.visibleArea.yPosition * scrollbar.height
            width: parent.width
            height: multipleListView.visibleArea.heightRatio * scrollbar.height * 0.5;
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
            height: multipleChoiceView.height * 0.5  + topicRow.height + multipleChoiceView.height * photosModel.count

            onHeightChanged: {
                //console.log("=====cloudMultip::width====",height,multipleListView.height,clipStatus);
                if(clipStatus){//如果是滚动并且截图才设置高度
                    multipleListView.height = height;
                    return;
                }
                multipleListView.height  = multipleChoiceView.height;
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
                    id: questionTitle
                    enabled: false
                    width: parent.width - 40 * heightRate - topicType.width
                    height: 45 * heightRate
                    backgroundColor: "#00000000"

                    onContentsSizeChanged: {
                        questionTitle.height = questionTitle.contentsSize.height;
                    }

                    Component.onCompleted: {
                        loadHtml(content);
                    }
                }
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
                    anchors.fill: parent
                    readOnly: true
                    text: studentAnswer == null || studentAnswer == "gapBlank" ? "" :  studentAnswer
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    wrapMode: TextArea.WordWrap
                }
            }

            //子题目显示
            ListView{
                id: childTopicListView
                clip: true
                visible: haschild
                width: parent.width - 20
                height: parent.height - topicRow.height - photosModel.count * multipleChoiceView.height//- knowledges.count * 18 * heightRate
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
                visible: clipStatus
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
                        onStatusChanged: {
                            if(status == Image.Error){
                                imageStatus = 1;
                            }
                            //console.log("======cloudMultip::imageUrl=====",imageUrl);
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
                                text: orderno.toString() + ". " + orderName
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
                                readOnly: true
                            }
                        }
                    }
                }
            }

            Component.onCompleted: {
                if(photosModel.count == 0 && clipStatus && topicModel.count - 1 == index){
                    console.log("=====clip11111111111=======");
                    sigLoadingSuccess();
                }
            }
        }
    }

    ListModel{
        id: topicModel
    }

    Component.onCompleted: {
        //如果没有快照则直接截图
        if(photosModel.count == 0 && clipStatus){
            sigLoadingSuccess();
        }
    }


    function multipleChoiceClipImage(){
        scrollbar.visible = false;
        return multipleListView;
    }

    function setMultipleClipStatus(status){
        clipStatus = status;
    }
}
