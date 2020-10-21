import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "./Configuuration.js" as Cfg

/*
*综合题浏览模式截图可用
*/

Item {
    id: compositeTopicItem
    anchors.fill: parent

    property string contentTopic: ""//题目内容
    property var dataModel: [];//代入数据模型
    property var bufferData: [];//缓存显示的数据
    property var childQuestionInfoModel: [];//子节点数据
    property var photosData: [];//快照数组

    signal sigIsMultipleTopic(var childStatus);//是否有多题信号
    signal sigPageChange(string pageStatus);//分页发生变化
    signal sigJumpTopic(var jump);//大题下一题 or 上一题

    property string baseImages: "";//题目是否已做完显示数据
    property var baseImageObj: [];//图片展示对象
    property int topicStatus: 0;//题目是否做完 0未作，2待批改，4批改完成
    property bool clipStatus: false;

    //批改信号
    signal sigCorrect(var filePath,var status);

    //加载完成截图
    signal sigLoadingSuccess();

    //批改信号
    signal sigCorrectInfos(var questionId,var childQuestionId,var score,var correctType,var errorReason);

    //解析数据
    onDataModelChanged: {
        topicModel.clear();
        if(dataModel == [] || dataModel.length == 0){
            return;
        }
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
        console.log("====cloudComposite::baseImages2222===",baseImages);
    }

    //解析快照数据
    onPhotosDataChanged: {
        //console.log("======onPhotosDataChanged=======",photosData.length,JSON.stringify(photosData));
        for(var k = 0; k < photosData.length; k++){
            var itemArray = photosData[k];
            for(var z = 0; z < itemArray.length; z++){
                //console.log("*********itemArray[z]***********",itemArray[z])
                photosModel.append(
                            {
                                "imageStatus": 2,
                                "imageUrl": itemArray[z],
                            });
            }
        }
        console.log("======photosModel.count=======",photosModel.count);
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


    //滚动条
    Item {
        id: scrollbar
        anchors.right: topicListView.right
        anchors.top: topicListView.top
        width: 10 * heightRate
        height: parent.height
        visible: false
        z: 2
        Rectangle{
            anchors.fill: parent
            color: "#eeeeee"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: 0
            width: parent.width
            height: topicListView.height / parent.height * 20 * heightRate//topicListView.visibleArea.heightRatio * scrollbar.height / compositeTopicItem.height * 0.5
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
            height: compositeTopicItem.height * childQuestionInfo.count - topicRow.height + photosModel.count * compositeTopicItem.height

            onHeightChanged: {
                scrollbar.visible = false;
                if(height > compositeTopicItem.height && !clipStatus){
                    scrollbar.visible = true;
                }
                topicListView.height =  height;
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

            //子题目显示
            ListView{
                id: childTopicListView
                clip: true
                width: parent.width - 20
                height: compositeTopicItem.height * childQuestionInfo.count - topicRow.height// (parent.height - topicRow.height - 60 * heightRate)//  + topicRow.height - knowledges.count * 460 * heightRate
                anchors.top: topicRow.bottom
                anchors.topMargin: 10 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                delegate: childTopicDelegate
                model: childQuestionInfo//topicModel//
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
                        anchors.fill: parent
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
                            if(currentStatus  && clipStatus){
                                sigLoadingSuccess();
                            }
                        }
                    }
                }
            }

            Component{
                id: childTopicDelegate
                Item{
                    id: childItem
                    width: childTopicListView.width - 20
                    height: compositeTopicItem.height// + childQuestionInfos.photos.length * childItem.height + childQuestionInfos.writeImages.length * childItem.height
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

                    property var childQuestionInfos: childQuestionInfoModel[index]//childQuestionInfo.get(index);

                    onChildQuestionInfosChanged: {
                        if(childQuestionInfos == null){
                            console.log("========childQuestionInfos::null==========")
                            return;
                        }
                        analysisData(index);
                        if(clipStatus && index == childQuestionInfoModel.length - 1 && photosModel.count == 0){
                            sigLoadingSuccess();
                            console.log("=======cloudTopicBrowsView=========");
                        }
                    }

                    function analysisData(index){
                        if(bufferData.length > 0){
                            bufferData.splice(0,bufferData.length);
                        }
                        var questionTypes;
                        if(childQuestionInfos == null){
                            bufferData = {};
                        }else{
                            questionTypes = childQuestionInfos.questionType;                           

                            //传递当前答案解析信息
                            sigCorrectInfos( id,
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
                        }
                        //设置五大题型的数据及显示
                        console.log("=====questionTypes======",questionTypes);

                        var component = Qt.createComponent("ShowQuestionHandlerView.qml");
                        if (component.status == Component.Ready) {
                            var button = component.createObject(childItem);
                            button.width = childItem.width;
                            button.height = childItem.height;
                            button.questionItemsData = childQuestionInfos.questionItems;
                            button.answerModel = childQuestionInfos.answer;//
                            button.knowledgesModels = childQuestionInfos.knowledges;
                            button.setCurrentBeShowedView(bufferData,questionTypes,false,2);
                            button.visible = true;//index == currentIndex ? true : false;
                            button.isScroll = false;
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
        scrollbar.visible = false;
    }

}

