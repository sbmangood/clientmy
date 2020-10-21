import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "./Configuuration.js" as Cfg

/*
*综合题浏览模式截图
*/

Item {
    id: compositeTopicItem
    anchors.fill: parent

    property string contentTopic: ""//题目内容
    property var dataModel: [];//代入数据模型
    property var bufferData: [];//缓存显示的数据
    property var questionItemModel: [];//题目内容缓存数据
    property var childQuestionInfoModel: [];//子节点数据
    property var photosData: [];//快照数组

    signal sigIsMultipleTopic(var childStatus);//是否有多题信号
    signal sigPageChange(string pageStatus);//分页发生变化
    signal sigJumpTopic(var jump);//大题下一题 or 上一题

    property string baseImages: "";//题目是否已做完显示数据
    property var baseImageObj: [];//图片展示对象
    property int topicStatus: 0;//题目是否做完 0未作，2待批改，4批改完成
    property bool clipStatus: false; //是否截图 false:不截图; true截图
    property bool isClipImage: false;//该题是否已经截图过

    property var clipStatusBuffer: [];//截图状态缓存
    property int clipImageHeight: 0;//题目截图的高度
    property var childQuestionInfos: [];//子节点数据

    //批改信号
    signal sigCorrect(var filePath,var status);

    //加载完成截图
    signal sigLoadingSuccess();

    //批改信号
    signal sigCorrectInfos(var questionId,var childQuestionId,var score,var correctType,var errorReason);

    //解析数据
    onDataModelChanged: {
        topicModel.clear();
        clipImageModel.clear();
        clipImageHeight = 0;
        if(dataModel == [] || dataModel.length == 0){
            return;
        }
        isClipImage = false;
        topicModel.append(
                    {
                        "analyse": dataModel.analyse,//题目分析
                        "answer": dataModel.answer,//题目正确答案
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
                    });
        topicStatus = dataModel.status;
        if(dataModel.baseImage != null){
            baseImages = dataModel.baseImage.imageUrl == null ? "" : dataModel.baseImage.imageUrl;
            baseImageObj = dataModel.baseImage;
        }
        console.log("====cloudComposite::baseImages====",baseImages);
    }

    ListModel{ //题目截图数据模型
        id: clipImageModel
    }

    //解析快照数据
    onPhotosDataChanged: {
        photosModel.clear();
        //console.log("======onPhotosDataChanged=======",photosData.length,JSON.stringify(photosData));
        for(var k = 0; k < photosData.length; k++){
            var itemArray = photosData[k];
            for(var z = 0; z < itemArray.length; z++){
                photosModel.append(
                            {
                                "imageStatus": 2,
                                "imageUrl": itemArray[z],
                            });
            }
        }
        console.log("======photosModel.count=======",photosModel.count);
    }

    ShowQuestionHandlerView{
        id: complexQuestionView
        anchors.fill: parent
        isCompleStatus: true
        onSigShowCorrectPage: {
            if(filePath == ""){
                //console.log("===CloudComplexQuestionView::null===");
                return;
            }
            console.log("=====1111========",filePath);
            setListViewHeght(imgHeight);
            clipImageModel.append(
                        {
                            "imageHeight": imgHeight,
                            "imageSource": "file:///" +filePath,
                        });

            clipTime.restart();
            console.log("===CloudComplexQuestionView===",filePath,1,imgWidth,imgHeight,clipImageModel.count);
        }
    }

    Timer{
        id: clipTime
        interval: 1000
        repeat: false
        running: false
        onTriggered: {
            for(var z = 0; z < clipStatusBuffer.length; z++){
                console.log("===for===",z,clipStatusBuffer[z].status)
                if(clipStatusBuffer[z].status == true){
                    continue;
                }

                if(z == clipStatusBuffer.length - 1){
                    clipStatusBuffer[z].status = true;
                    break;
                }

                clipStatusBuffer[z].status = true;
                childQuestionInfos = childQuestionInfoModel[z];
                return;
            }

            var currentStatus = true;
            for(var i = 0; i < photosModel.count;i++){
                if(photosModel.get(i).imageStatus != 1){
                    currentStatus = false;
                    break;
                }
            }

            var clipTipceStatus = true;
            for(var k = 0; k < clipStatusBuffer.length; k++){
                console.log("=====clipStatusBuffer::status======",k,clipStatusBuffer[k].status,clipStatusBuffer.length);
                if(clipStatusBuffer[k].status == false){
                    clipTipceStatus = false;
                    break;
                }
            }

            if(currentStatus  && clipStatus && clipTipceStatus && isClipImage == false){
                //complexQuestionView.clipImage(clipBrowsViewImage());
                console.log("====loadingSuccess=====");
                isClipImage = true;
                sigLoadingSuccess();
            }
        }
    }

    onChildQuestionInfoModelChanged: {
        if(clipStatusBuffer.length > 0){
            clipStatusBuffer.splice(0,clipStatusBuffer.length);
        }
        if(childQuestionInfoModel.length == 0){
            return;
        }

        for(var z = 0; z < childQuestionInfoModel.length + 1; z++){
            if(z  == childQuestionInfoModel.length){
                clipStatusBuffer.push({"index": z, "status":  true});
                continue;
            }
            clipStatusBuffer.push({"index": z, "status":  false});
            if(clipStatus == false){
                childQuestionInfos = childQuestionInfoModel[z];
                continue;
            }

            if(z == 0){
                childQuestionInfos = childQuestionInfoModel[z];
            }
        }
        console.log("#######clipStatusBuffer#########",childQuestionInfoModel.length,clipStatusBuffer.length,JSON.stringify(clipStatusBuffer));
    }

    onChildQuestionInfosChanged: {
        console.log("=====childQuestionInfos===AAAA====")
        if(childQuestionInfos.length == 0 || childQuestionInfos == null || childQuestionInfos == []){
            console.log("========childQuestionInfos::null==========")
            return;
        }
        clipStatusBuffer[0].status = true;
        analysisData();
    }

    function analysisData(){
        if(bufferData.length > 0){
            bufferData.splice(0,bufferData.length);
        }
        var questionTypes;
        if(childQuestionInfos == null){
            bufferData = {};
        }else{
            questionTypes = childQuestionInfos.questionType;

            //传递当前答案解析信息
            sigCorrectInfos(childQuestionInfos.id,
                            childQuestionInfos.id,
                            childQuestionInfos.score,
                            childQuestionInfos.isRight,
                            childQuestionInfos.errorType);

            bufferData = {
                "id": childQuestionInfos.id,
                "analyse": childQuestionInfos.analyse,//题目分析
                "answer": childQuestionInfos.answer,//题目正确答案
                "reply": childQuestionInfos.reply,//题目解答
                "lastUpdatedDate": childQuestionInfos.lastUpdatedDate,
                "photos": childQuestionInfos.photos,//拍照照片
                "writeImages": childQuestionInfos.writeImages,//手写图片
                "status": childQuestionInfos.status, //题目状态
                "content": childQuestionInfos.content,//标题
                "questionType": childQuestionInfos.questionType,//题目类型
                "knowledges": childQuestionInfos.knowledges,//知识点对象集合
                "studentAnswer": childQuestionInfos.studentAnswer,//学生正确答案
                "questionItems": childQuestionInfos.questionItems,//题目选项
                "orderNumber": childQuestionInfos.orderNumber,//题目序号
                "studentScore": childQuestionInfos.studentScore,//学生分数
                "useTime": childQuestionInfos.useTime,//答题用时
                "haschild": childQuestionInfos.haschild,//是否有子题
                "childQuestionInfo": childQuestionInfos.childQuestionInfo,//子题集合，数据结构和父类一样
                "teacherImages": childQuestionInfos.teacherImages,//老师批注
                "originImage": childQuestionInfos.originImage,//老师批注的原始图片
                "image": childQuestionInfos.image,//老师批注图片，为空字符串时也是没有批注
                "isRight": childQuestionInfos.isRight,//答案是否正确 0：错误，1：正确，2：半对半错
                "score":childQuestionInfos.score,//题目得分
                "errorType": childQuestionInfos.errorType,//错因
            };
            if(questionItemModel.length > 0){
                questionItemModel.splice(0,questionItemModel.length);
            }
            if(childQuestionInfos.questionItems != null){
                var questionArray = childQuestionInfos.questionItems;
                if(questionArray.length > 0){
                    console.log("==BrowsView::length===",questionArray.length, questionArray[0].orderName);
                    for(var k = 0; k < questionArray.length; k++){
                        questionItemModel.push(
                                    {
                                        "contents": questionArray[k].contents,
                                        "isright": questionArray[k].isright,
                                        "orderName": questionArray[k].orderName,
                                        "orderno": questionArray[k].orderno,
                                        "qitemid": questionArray[k].qitemid,
                                        "questionid": questionArray[k].questionid,
                                        "score": questionArray[k].score,
                                    });
                    }
                }
            }
            console.log("====BrowsView::questionItemModel====",clipStatus,JSON.stringify(bufferData));
            complexQuestionView.isCompleStatus = true;
            complexQuestionView.questionItemsData = questionItemModel; //childQuestionInfos.questionItems;
            complexQuestionView.answerModel = childQuestionInfos.answer;//
            complexQuestionView.knowledgesModels = childQuestionInfos.knowledges;
            complexQuestionView.setCurrentBeShowedView(bufferData,questionTypes,clipStatus,2);
            complexQuestionView.visible = true;
            complexQuestionView.isScroll = false;
        }
    }

    function setListViewHeght(currentHeight){
        clipImageHeight += currentHeight;
    }

    ListView{
        id: topicListView
        width: parent.width
        height: parent.height
        clip: true
        model: topicModel
        delegate: topicDelegate
    }

    ListModel{
        id: photosModel
    }

    Component{
        id: topicDelegate
        Rectangle{
            id: bodyItem
            width: topicListView.width
            height: {
                if(clipStatus){
                    topicRow.topPadding = 100 * heightRate;
                    return  clipImageHeight  + 80 * heightRate + topicRow.height + photosModel.count * compositeTopicItem.height;
                }else{
                    return clipImageHeight - topicRow.height + photosModel.count * compositeTopicItem.height
                }
            }
                    //compositeTopicItem.height * childQuestionInfo.count - topicRow.height + photosModel.count * compositeTopicItem.height
            onHeightChanged: {
                if(height > compositeTopicItem.height && !clipStatus){
                    return;
                }
                topicListView.height =  height + 100 * heightRate;
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
                        text:  qsTr("综合题")
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
                }
            }

            ListView{
                id: childTopicListView
                clip: true
                width: parent.width - 20
                height: clipImageHeight
                anchors.top: topicRow.bottom
                anchors.topMargin: 10 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                delegate: childTopicDelegate
                model: clipImageModel//topicModel//
            }

            Component{
                id: childTopicDelegate
                Item{
                    width: childTopicListView.width
                    height: imageHeight

                    Image{
                        anchors.fill: parent
                        source: imageSource
                    }
                }
            }

            //显示快照
            ListView{
                id: phpos
                clip: true
                z: 6
                width: parent.width - 20
                height: compositeTopicItem.height * photosModel.count
                anchors.top: childTopicListView.bottom
                model: photosModel
                anchors.horizontalCenter: parent.horizontalCenter
                boundsBehavior: ListView.StopAtBounds
                delegate: Item{
                    width: compositeTopicItem.width
                    height: compositeTopicItem.height

                    Image{
                        width: compositeTopicItem.width
                        height: compositeTopicItem.height
                        source: imageUrl

                        onStatusChanged: {
                            console.log("=======cloudTopicBrows=========",status,index,imageUrl)
                            if(status == Image.Ready){
                                imageStatus = status;
                            }

                            if(status == Image.Error){
                                imageStatus = 1;
                            }

                            var currentStatus = true;
                            for(var i = 0; i < photosModel.count;i++){
                                if(photosModel.get(i).imageStatus != 1){
                                    currentStatus = false;
                                    break;
                                }
                            }

                            var clipTipceStatus = true;
                            for(var k = 0; k < clipStatusBuffer.length; k++){
                                console.log("=====clipStatusBuffer::status======",k,clipStatusBuffer[k].status,clipStatusBuffer.length);
                                if(clipStatusBuffer[k].status == false){
                                    clipTipceStatus = false;
                                    break;
                                }
                            }

                            if(currentStatus  && clipStatus && clipTipceStatus && isClipImage == false){
                                console.log("====loadingSuccess=====");
                                isClipImage = true;
                                sigLoadingSuccess();
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

    function clipBrowsViewImage(){
        console.log("======clipBrowsViewImage========",topicListView.height);
        return topicListView;
    }

    function setStatus(status){
        clipStatus = status;
    }

}

