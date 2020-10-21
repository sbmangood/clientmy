import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.2
//import QtWebView 1.1
import HtmlSytelSetting 1.0
import "./Configuuration.js" as Cfg

/*
*单选题界面 1
*/

Item {
    id: singleMainView
    property int currentViewModel: 1;// 当前的显示模式 1 做题模式  2 对答案模式
    property int currentBeSelectAnswer: -1;//当前被选中的答案 在model里的索引位置

    property string knowledgesString: ""; //知识点的文字详情
    property string questionAnswer: "";
    property  int  heightRates: heightRate;

    property var questionItemsModel: [];
    property var answerModel: [];
    property var knowledgesModels: [];
    property string baseImages: "";//题目是否已做完显示数据
    property int topicStatus: 0;//题目是否做完 0未作，2待批改，4批改完成
    property bool clipStatus: false;
    property bool isComplexClip: false;//是否是综合题截图

    //批改信号//图片路径、题目状态(0:未作,2带批改,4已完成),题目类型
    signal sigCorrect(var imageUrl,var status,var imgWidth,var imgHeight);
    signal sigScrollImage(var contentY);
    signal sigLoadingSuccess();

    //重置数据 进行界面显示questionData:真实数据，topicMode：做题模式还是预览模式（1 做题模式  2 对答案模式）
    function updateMainView(questionData,topicMode){
        singleQuestionModel.clear();
        detailSelectItemModle.clear();
        currentViewModel = topicMode;
        console.log("======SingleChoice::return======",currentViewModel);
        baseImages = "";
        topicStatus = 0;
        clipStatus = false;
        if(questionData ==[] || questionData == undefined || questionItemsModel == []){
            //console.log("======SingleChoice::return======");
            return;
        }
        singleMainView.visible = true;
        showQuestionParsing.visible = false;
        var items = questionData;

        currentBeSelectAnswer = (items.studentAnswer == "" ? -1 :( currentViewModel == 1 ? -1 : parseInt(items.studentAnswer) - 1 ) );
        console.log("======SingleChoice::updateMainView1======",currentBeSelectAnswer);
        //console.log("======SingleChoice::updateMainView2======", items.content); //items.content 是富文本, 里面有标题, 也有图片的http路径
        singleQuestionModel.append({//模拟数据 ，题目类型传值结构未知
                                       "analyse":items.analyse,
                                       "answer":items.answer,
                                       "childQuestionInfo":items.childQuestionInfo,
                                       "content":items.content,//题目标题
                                       "difficulty":items.difficulty,//int
                                       "errorName":items.errorName,
                                       "errorType":items.errorType,//int
                                       "haschild":items.haschild,//bool
                                       "id":items.id,
                                       "isRight":items.isRight,//int
                                       // "knowledges":items.knowledges,//[{}]
                                       "lastUpdatedDate":items.lastUpdatedDate,
                                       "orderNumber":items.orderNumber,//int
                                       "qtype":items.qtype,//int
                                       "questionType":items.questionType,//int
                                       "remarkTime":items.remarkTime,//int
                                       "remarkUrl":items.remarkUrl,
                                       "reply":items.reply,
                                       "score":items.score,//int
                                       "status":items.status,//int
                                       "studentAnswer":items.studentAnswer,
                                       "studentScore":items.studentScore,//int
                                       "teacherImages":items.teacherImages,
                                       "useTime":items.useTime,//int
                                       "writeImages":items.writeImages,                                       
                                       "photos":items.photos,
                                       "baseImage": items.baseImage,
                                   })
        topicStatus = items.status;
        var imgwidth;
        var imgheight;
        if(items.baseImage != null){
            baseImages = items.baseImage.imageUrl == null ? "" : items.baseImage.imageUrl;
            imgwidth = items.baseImage.width;
            imgheight =  items.baseImage.height;
        }
        if(baseImages != ""){
            sigCorrect(baseImages,2,imgwidth,imgheight);
        }
        console.log("=======baseImages=====",baseImages,topicStatus)
        for(var z = 0; z < knowledgesModels.length; z++){
            knowledgesString += knowledgesModels[z].konwledgeName;
        }
        //console.log("********singleChoiceQuestion********",answerModel,JSON.stringify(answerModel))
        if(answerModel != null){
            var answer = answerModel;//items.answer;//
            for(var b = 0 ; b < answer.length ; b++ ){
                questionAnswer = answer[b];
            }
        }
    }

    ListView{
        id: singleQuestionListView
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
        //boundsBehavior: ListView.StopAtBounds
        model: singleQuestionModel
        delegate: singleQuestionDelegate
    }

    //答案解析面板
    Rectangle {
        height: parent.height
        width: parent.width * 0.3
        visible: showQuestionParsing.visible
        color: "transparent"
        x: parent.width - width //- 5 * widthRate
        y: 0

        Image {
            anchors.fill: parent
            source: "qrc:/cloudImage/pigaizuoyebeijing@3x.png"
        }

        Popup {
            id:showQuestionParsing
            height: parent.height //- 15 * heightRate
            width: parent.width - 20 * heightRate
            x:10 * heightRate
            y:0
            padding: 0
            visible: false

            MouseArea {
                anchors.fill: parent
            }

            Rectangle {
                anchors.fill: parent

                Rectangle {
                    width: parent.width
                    height: 20 * heightRate
                    //color: "red"

                    anchors.top: parent.top
                    anchors.topMargin: 20 * heightRate
                    Rectangle{
                        width: 35 * heightRate
                        height: 2 * heightRate
                        color: "#e3e6e9"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: title.left
                        anchors.rightMargin: 5 * heightRate
                    }

                    Text {
                        id:title
                        text: qsTr("答案解析")
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        wrapMode: Text.WordWrap
                    }

                    Rectangle {
                        width: 35 * heightRate
                        height: 2 * heightRate
                        color: "#e3e6e9"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: title.right
                        anchors.leftMargin: 5 * heightRate
                    }
                }

                ListView {
                    width: parent.width
                    height: parent.height - title.height - 50 * heightRate
                    clip: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    model: singleQuestionModel
                    delegate: answerAnalysisDelegate
                }
            }
        }

    }

    ListModel{
        id: singleQuestionModel
    }

    ListModel{
        id: detailSelectItemModle//具体题目选项model
    }


    Component{
        id: singleQuestionDelegate
        Rectangle {
            //Rectangle的大小, 比singleQuestionListView的高度, 大的时候, 会默认支持滚动
            width: singleQuestionListView.width
            height: singleMainView.height * 0.2 + questionItemsModel.length / 2 * selectionItemGridViews.cellHeight + 90 * heightRate + topicRow.height;

            onHeightChanged: {
                if(clipStatus){
                    if(isComplexClip == false){
                        singleQuestionListView.height = height + 100 * heightRates;
                        topicRow.topPadding = 100 * heightRates;
                    }else{
                        singleQuestionListView.height = height;
                    }
                    return;
                }
                singleQuestionListView.height = singleMainView.height;
            }
            color: "transparent"

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
                        text:  "单选题"
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        color: "#ffffff"
                        anchors.centerIn: parent
                    }
                }

                Text {
                    id: questionTitle
                    text: content
                    width: singleQuestionListView.width - 20 * heightRate - topicType.width
                    font.pixelSize: 18 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                }

//                property string contents: content
//                onContentsChanged: {
//                    htmlSetting.updateHtml(contents);
//                }

//                HtmlSytelSetting{
//                    id: htmlSetting
//                    onSigUpdateSuccess: {
//                        questionTitle.url = "file:///" + htmlUrl;
//                        console.log("====url====",htmlUrl);
//                    }
//                }

//                WebView{
//                    id: questionTitle
//                    width: singleQuestionListView.width - 20 * heightRate - topicType.width
//                    height: 200
//                    onLoadProgressChanged: {
//                        console.log("=====progress======",loadProgress)
//                        if(loadProgress == 100){
//                            questionTitle.runJavaScript("document.getbodyHeight",function(result) { console.log("====webView::height====",result)});
//                        }
//                    }
//                }
            }

            GridView {
                id:selectionItemGridViews
                width: singleQuestionListView.width - 60 * heightRate
                height: Math.ceil(questionItemsModel.length  /  2) * cellHeight //selectionItemModel.count / 2 * cellHeight//
                anchors.top: topicRow.bottom
                anchors.topMargin: 50 * heightRate
                model: questionItemsModel // selectionItemModel//
                delegate: gridViewDelegate
                clip: true
                cellWidth: selectionItemGridViews.width / 2
                cellHeight: cellWidth / 4
                anchors.left: parent.left
                anchors.leftMargin: 40 * heightRate
            }

            Rectangle {
                width: 200 * heightRate
                height: width / 4.5
                color: currentBeSelectAnswer != -1 ? "#FF6633" : "#C3C3C3"
                anchors.top: selectionItemGridViews.bottom
                anchors.topMargin: 10 * heightRate
                radius: 5 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: 26 *heightRate
                visible: false//currentViewModel == 1
                Text {
                    text: "做好了"
                    anchors.centerIn: parent
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    wrapMode: Text.WordWrap
                    //font.bold: true
                    color:  "white"
                }

                MouseArea {
                    enabled: false//currentBeSelectAnswer != -1
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        //模式显示为对答案模式
                        currentViewModel = 2;
                    }
                }
            }

            Row{
                width: 300 * heightRate
                height: width / 4.5
                anchors.top: selectionItemGridViews.bottom
                anchors.topMargin: 10 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: 26 * heightRate
                visible: false
                spacing: 10 * heightRate

                MouseArea{
                    enabled: false
                    width: 150 * heightRate
                    height: width / 3

                    Rectangle{
                        anchors.fill: parent
                        color: {
                            if(currentBeSelectAnswer == -1){
                                return "#000000000";
                            }else{
                                questionItemsModel[currentBeSelectAnswer].isright ? "#FF7B44" : "#FF7777"
                                //selectionItemModel.get(currentBeSelectAnswer).isright ? "#44EAC6" : "#FF7777"
                            }
                        }
                        radius: 4 * heightRate
                    }

                    Image {
                        width: parent.width
                        height: width / 3
                        anchors.centerIn: parent
                        source: {
                            if(currentBeSelectAnswer == -1){
                                return "";
                            }else{
                                questionItemsModel[currentBeSelectAnswer].isright ? "qrc:/cloudImage/pigai_right@2x.png" : "qrc:/cloudImage/pigai_wrong@2x.png";
                                //selectionItemModel.get(currentBeSelectAnswer).isright ? "qrc:/cloudImage/pigai_right@2x.png" : "qrc:/cloudImage/pigai_wrong@2x.png";
                            }
                        }
                    }
                }

                MouseArea {
                    hoverEnabled: true
                    enabled: false
                    width: 155 * heightRate
                    height: width / 3

                    Rectangle{
                        anchors.fill: parent
                        color: "white"
                        radius: 4 * heightRate
                    }

                    Image {
                        id:analyButtonImage
                        width: parent.width
                        height: width / 2.4
                        anchors.centerIn: parent
                        source: parent.containsMouse ? "qrc:/cloudImage/btn_daanjiexi_sed@2x.png" : "qrc:/cloudImage/btn_daanjiexi@2x.png";
                    }                    

                    onClicked:{
                        showQuestionParsing.open();
                    }

                }
            }
        }
    }

    Component {
        id:gridViewDelegate

        Rectangle {
            width: (singleQuestionListView.width - 60 * heightRate) / 2 // / 2 - 10 *heightRate
            height: width / 4
            color: "transparent";
            Rectangle {
                width: parent.width - 25 * heightRate
                height: parent.height - 20 * heightRate
                anchors.centerIn: parent
                radius: 10 * heightRate

                color: {
                    //color: "#FF7B44"//橙色
                    //color: "#FF7777"//红色
                    currentViewModel == 1 ?  "#C3C6C9" :  currentBeSelectAnswer == index ? "#FF7B44" : "#C3C6C9"
                    //currentViewModel == 1 ? currentBeSelectAnswer == index ? "#FF7B44" : "#C3C6C9" : questionItemsModel[index].isright ? "#FF7B44" : currentBeSelectAnswer == index ? "#FF7777" : "#C3C6C9"
                }
                //选项的名字
                Text {
                    id: orderNameItem
                    text:  questionItemsModel[index].orderName //questionItemsModel.get(index).orderName//
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    textFormat: Text.StyledText
                    font.bold: true
                    color: "white"
                }

                Rectangle {
                    height: parent.height - 4 * heightRate
                    width: parent.width - 42 * heightRate
                    anchors.right: parent.right
                    anchors.rightMargin: 2 *　heightRate
                    // anchors.top: parent.top
                    radius:  10 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"

                    Rectangle {
                        height: parent.height
                        width: 10 * heightRate
                        anchors.left: parent.left
                        anchors.leftMargin: -1
                        anchors.verticalCenter: parent.verticalCenter
                        color: parent.color
                    }

                    ListModel{
                        id: childModel
                    }

                    property int indexs:  index == 0 ? -1 : index;

                    onIndexsChanged: {
                        childModel.clear();
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
                        //console.log("==*****contents********==",questionItemsModel.get(index).contents)
                    }

                    //具体的选项内容
                    ListView {
                        id: detailSelectItemListView
                        width: parent.width
                        height: parent.height
                        clip: true
                        model: childModel //questionItemsModel[index]//selectionItemModel.get(index)//
                        delegate:Rectangle
                        {
                            id:trectang
                            width:parent.width - 10 * heightRate
                            height: parent.height;// + 20 * heightRate
                            color: "transparent"
                            clip:true
                            Text {
                                id: text1
                                width: parent.width - 20 * heightRate
                                font.pixelSize: 16 * Screen.width * 0.8 / 966.0 / 1.5337
                                font.family: Cfg.DEFAULT_FONT
                                anchors.left: parent.left
                                anchors.leftMargin: 15 * heightRate
                                font.bold: true
                                text: model.contents//contents
                                wrapMode: Text.WrapAnywhere
                                textFormat: Text.StyledText
                            }

//                            Component.onCompleted: {
//                                if(text1.height < parent.height)
//                                {
//                                    trectang.anchors.fill = parent
//                                    text1.anchors.verticalCenter = trectang.verticalCenter;
//                                }else
//                                {
//                                    text1.anchors.left = trectang.left
//                                    trectang.height = text1.height;
//                                }
//                            }
                        }
                    }
                }
            }

            MouseArea {
                enabled: false
                anchors.fill: parent
                onClicked: {
                    if(currentViewModel == 1) {
                        currentBeSelectAnswer = index;
                    }
                }
            }

            Component.onCompleted: {
                //console.log("=====singleChoiceQuestion========",index,questionItemsModel.length -1);
                if(clipStatus && questionItemsModel.length -1 == index){
                    sigLoadingSuccess();
                }
            }

        }

    }

    Component{
        id:answerAnalysisDelegate
        Rectangle {
            width: showQuestionParsing.width
            height:textColumn.height + 30 * heightRate //showQuestionParsing.height / 2

            Column {
                id:textColumn
                spacing: 10 * heightRate
                width: parent.width - 20 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: qsTr("正确答案")
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    color: "gray"
                }

                Text {
                    text: questionAnswer
                    width: parent.width
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    wrapMode: Text.WordWrap
                    textFormat: Text.StyledText
                }

                Rectangle  {
                    color: "#fff7c9"
                    width: 95 * heightRate
                    height: 25 * heightRate
                    radius: 2 * heightRate
                    Image {
                        id:wrongImage
                        source: "qrc:/cloudImage/icon_cuoyin@2x.png"
                        height: parent.height
                        width: parent.height
                        anchors.left: parent.left
                        anchors.top:parent.top
                        clip: true
                    }

                    Text {
                        text: qsTr("主要错因")
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        color: "gray"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.left: wrongImage.left
                        anchors.leftMargin: 25 * heightRate
                    }
                }

                Text {
                    text: errorType
                    width: parent.width
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    wrapMode: Text.WordWrap
                    textFormat: Text.StyledText
                }

                Rectangle {
                    color: "#fff7c9"
                    width: 85 * heightRate
                    height: 25 * heightRate
                    radius: 2 * heightRate
                    Image {
                        id:knowledgeImage
                        source: "qrc:/cloudImage/icon_zhishidian@2x.png"
                        height: parent.height
                        width: parent.height
                        anchors.left: parent.left
                        anchors.top:parent.top
                        clip: true
                    }
                    Text {
                        text: qsTr("知识点")
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        color: "gray"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.left: knowledgeImage.left
                        anchors.leftMargin: 28 * heightRate
                    }
                }

                Text {
                    text: knowledgesString
                    width: parent.width
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    wrapMode: Text.WordWrap
                    textFormat: Text.StyledText
                }

                Rectangle {
                    color: "#fff7c9"
                    width: 65 * heightRate
                    height: 25 * heightRate
                    radius: 2 * heightRate
                    Image {
                        id:parsingImage
                        source: "qrc:/cloudImage/icon_jiexi@2x.png"
                        height: parent.height
                        width: parent.height
                        anchors.left: parent.left
                        anchors.top:parent.top
                        clip: true
                    }
                    Text {
                        text: qsTr("解析")
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        color: "gray"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.left: parsingImage.left
                        anchors.leftMargin: 25 * heightRate
                    }
                }

                Text {
                    text: analyse
                    width: parent.width
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    wrapMode: Text.WordWrap
                    textFormat: Text.StyledText
                }
            }
        }
    }

    function singleChoiceClipImage(){
        console.log("======singleChoice::widht=========",singleQuestionListView.height)
        return singleQuestionListView;
    }

    function setClipStatus(status,complexStatus){
        clipStatus = status;
        isComplexClip = complexStatus;
    }
}
