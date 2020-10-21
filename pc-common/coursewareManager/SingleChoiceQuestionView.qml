import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.2
import QtWebEngine 1.4
import HtmlSytelSetting 1.0
import "./Configuuration.js" as Cfg

/*
*单选题界面 1
*/
Item {
    id: singleMainView
    property int currentViewModel: 1;// 当前的显示模式 1 做题模式  2 对答案模式
    property int currentBeSelectAnswer: -1;//当前被选中的答案 在model里的索引位置
    property var hasBufferedQuestionAnswerList: [];//已经存储过的 答案列表 结构  question id  + 选项数组（json存储）
    property var currentQuestionId: "" ;
    property string knowledgesString: ""; //知识点的文字详情
    property string questionAnswer: "";
    property var errorName: ;
    property int heightRates: heightRate;
    
    property double heightRates: 1.0;//高度比例系数
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
    
    signal isDoRight(var isRight);

    signal saveStudentAnswer( var studentSelectAnswer, var questionId ,var orderNumber);

    //重置数据 进行界面显示questionData:真实数据，topicMode：做题模式还是预览模式（1 做题模式  2 对答案模式）
    onCurrentViewModelChanged:
    {
        if(currentViewModel == 1)
        {
            lookView.visible = false;
            lookView.enabled = false;
        }
    }

    //答案提交
    function answerSubmit()
    {
        if(currentBeSelectAnswer == -1)
        {
            currentViewModel = 2;
            isDoRight(false);
            saveStudentAnswer("",singleQuestionModel.get(0).id,singleQuestionModel.get(0).orderNumber);
            return;
        }
        currentViewModel = 2;
        if(questionItemsModel[currentBeSelectAnswer].isright)
        {
            isDoRight(true);
        }else
        {
            isDoRight(false);
        }
        //提交答案到服务器 orderno(int型)
        saveStudentAnswer(questionItemsModel[currentBeSelectAnswer].orderno.toString(),singleQuestionModel.get(0).id,singleQuestionModel.get(0).orderNumber);
    }

    //显示答案解析
    function showAnswerDetail()
    {
        showQuestionParsing.open();
    }
    
    function updateMainView(questionData,topicMode){
        if(questionData ==[] || questionData == undefined || questionItemsModel == []){
            return;
        }

        var items;
        var answer;
        if(role == "teacher"){
            singleQuestionModel.clear();
            detailSelectItemModle.clear();
            currentViewModel = topicMode;
            baseImages = "";
            topicStatus = 0;
            clipStatus = false;
            singleMainView.visible = true;
            showQuestionParsing.visible = false;
            items = questionData;

            currentBeSelectAnswer = (items.studentAnswer == "" ? -1 :( currentViewModel == 1 ? -1 : parseInt(items.studentAnswer) - 1 ) );
            console.log("======SingleChoice::updateMainView1======",currentBeSelectAnswer);

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
                answer = answerModel;//items.answer;//
                for(var b = 0 ; b < answer.length ; b++ ){
                    questionAnswer = answer[b];
                }
            }
            errorName= items.errorName == null ? "" : items.errorName;
        }
        else if(role == "student"){
            currentViewModel = viewType;
            if(viewType == 2)
            {
                currentViewModel = 3;
            }

            singleMainView.visible = true;
            showQuestionParsing.visible = false;
            items = questionData;
            console.log("======SingleChoice::updateMainView======",viewType)
            //model 重置
            if(currentQuestionId == "" || currentQuestionId != items.id)
            {
                currentBeSelectAnswer = -1;
            }
            currentQuestionId = items.id;
            //获取是否存在缓存答案
            getCurrentBufferList();
            singleQuestionModel.clear();
            singleQuestionModel.append({//模拟数据 ，题目类型传值结构未知
                                           "analyse":items.analyse,
                                           "answer":items.answer,
                                           "childQuestionInfo":items.childQuestionInfo,
                                           "content":items.content,//题目标题
                                           "difficulty":items.difficulty,//int
                                           "errorName":items.errorName,
                                           "errorType":items.errorType,//int
                                           "haschild":items.haschild,//bool
                                           "id":items.id,//题目id
                                           "isRight":items.isRight,//int
                                           // "knowledges":items.knowledges,//[{}]
                                           "lastUpdatedDate":items.lastUpdatedDate,
                                           "orderNumber":items.orderNumber,//int
                                           "photos":items.photos,
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
                                       })
            currentOrderNumber = items.orderNumber;
            for(var z = 0; z < knowledgesModels.length; z++){
                knowledgesString += knowledgesModels[z].konwledgeName;
            }
            answer = answerModel;
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
                return false;
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
            height: parent.height //- 15 * heightRates
            width: parent.width - 20 * heightRates
            x:10 * heightRates
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
                    height: 20 * heightRates
                    //color: "red"

                    anchors.top: parent.top
                    anchors.topMargin: 20 * heightRates
                    Rectangle{
                        width: 35 * heightRates
                        height: 2 * heightRates
                        color: "#e3e6e9"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: title.left
                        anchors.rightMargin: 5 * heightRates
                    }

                    Text {
                        id:title
                        text: qsTr("答案解析")
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 16 * heightRates
                        font.family: Cfg.DEFAULT_FONT
                        wrapMode: Text.WordWrap
                    }

                    Rectangle {
                        width: 35 * heightRates
                        height: 2 * heightRates
                        color: "#e3e6e9"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: title.right
                        anchors.leftMargin: 5 * heightRates
                    }
                }

                ListView {
                    width: parent.width
                    height: parent.height - title.height - 50 * heightRates
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
            height: answerView.height + singleMainView.height * 0.2 + questionItemsModel.length / 2 * selectionItemGridViews.cellHeight + 90 * heightRates + topicRow.height;

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
                anchors.topMargin: 36 * heightRates
                spacing: 10 * heightRates

                Rectangle{
                    id: topicType
                    width: 50 * heightRates
                    height: 24 * heightRates
                    color: "#ff7777"
                    radius:  4 * heightRates

                    Rectangle{
                        width: 4
                        height: parent.height
                        color: "#ff7777"
                    }

                    Text {
                        text:  "单选题"
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRates
                        color: "#ffffff"
                        anchors.centerIn: parent
                    }
                }

                WebEngineView{
                    id: questionTitle
                    enabled: true
                    width: singleQuestionListView.width - 20 * heightRates - topicType.width
                    height: 45 * heightRates
                    backgroundColor: "#00000000"

                    onContentsSizeChanged: {
                        questionTitle.height = questionTitle.contentsSize.height;
                    }

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

            GridView {
                id:selectionItemGridViews
                width: role == "teacher" ? (singleQuestionListView.width - 60 * heightRates) : (singleQuestionListView.width - 20 * heightRates)
                height: Math.ceil(questionItemsModel.length  /  2) * cellHeight //selectionItemModel.count / 2 * cellHeight//
                anchors.top: topicRow.bottom
                anchors.topMargin: 50 * heightRates
                model: questionItemsModel // selectionItemModel//
                delegate: gridViewDelegate
                clip: true
                cellWidth: selectionItemGridViews.width / 2
                cellHeight: cellWidth / 4
                anchors.left: {
                    if(role == "teacher"){
                        return parent.left;
                    }
                }
                anchors.leftMargin: {
                    if(role == "teacher"){
                        return 40 * heightRates;
                    }
                }
            }

            Rectangle{
                id:answerView
                width: parent.width - 15 * widthRates
                anchors.top: selectionItemGridViews.bottom
                height: textColumn.height
                anchors.horizontalCenter: parent.horizontalCenter
                visible: (role == "teacher") && (currentIsHomeWorkClipImg || isStuHomeWorkView)
                Column {
                    id:textColumn
                    spacing: 10 * heightRates
                    width: parent.width

                    Text {
                        text: qsTr("正确答案")
                        font.pixelSize: 16 * heightRates
                        font.family: Cfg.DEFAULT_FONT
                        color: "#c9930c"
                    }
                    Text {
                        width: parent.width
                        text:questionAnswer
                        font.pixelSize: 16 * heightRates
                        font.family: Cfg.DEFAULT_FONT
                        wrapMode: Text.WordWrap

                    }

                    Text {
                        text: qsTr("错因")
                        font.pixelSize: 16 * heightRates
                        font.family: Cfg.DEFAULT_FONT
                        color: "#c9930c"
                        visible: (isRight == 0 || isRight == 2 ) && status !=0
                    }

                    Text {
                        width: parent.width
                        visible: (isRight == 0 || isRight == 2 ) && status !=0
                        text: errorName
                        font.pixelSize: 16 * heightRates
                        font.family: Cfg.DEFAULT_FONT
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        text: qsTr("解析")
                        font.pixelSize: 16 * heightRates
                        font.family: Cfg.DEFAULT_FONT
                        color: "#c9930c"
                    }

                    Text {
                        width: parent.width
                        text: analyse
                        font.pixelSize: 16 * heightRates
                        font.family: Cfg.DEFAULT_FONT
                        wrapMode: Text.WordWrap
                    }

                }

            }

            Rectangle {
                width: 200 * heightRates
                height: width / 4.5
                color: currentBeSelectAnswer != -1 ? "#FF6633" : "#C3C3C3"
                anchors.top: selectionItemGridViews.bottom
                anchors.topMargin: 10 * heightRates
                radius: 5 * heightRates
                anchors.right: parent.right
                anchors.rightMargin: 26 *heightRates
                visible: false//currentViewModel == 1
                Text {
                    text: "做好了"
                    anchors.centerIn: parent
                    font.pixelSize: 16 * heightRates
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
                width: 300 * heightRates
                height: width / 4.5
                anchors.top: selectionItemGridViews.bottom
                anchors.topMargin: 10 * heightRates
                anchors.right: parent.right
                anchors.rightMargin: 26 * heightRates
                visible: false
                spacing: 10 * heightRates

                MouseArea{
                    enabled: false
                    width: 150 * heightRates
                    height: width / 3

                    Rectangle{
                        anchors.fill: parent
                        color: {
                            if(currentBeSelectAnswer == -1){
                                return "#000000000";
                            }else{
                                if(role == "teacher"){
                                    if(isRight == undefined)
                                    {
                                        return "#000000000";
                                    }

                                    return isRight ? "#FF7B44" : "#FF7777";
                                }
                                else if(role == "student"){
                                    return questionItemsModel[currentBeSelectAnswer].isright ? "#44EAC6" : "#FF7777";
                                }
                                //selectionItemModel.get(currentBeSelectAnswer).isright ? "#44EAC6" : "#FF7777"
                            }
                        }
                        radius: 4 * heightRates
                    }

                    Image {
                        width: parent.width
                        height: width / 3
                        anchors.centerIn: parent
                        source: {
                            if(currentBeSelectAnswer == -1){
                                return "";
                            }else{
                                if(role == "teacher"){
                                    isRight ? "qrc:/cloudImage/pigai_right@2x.png" : "qrc:/cloudImage/pigai_wrong@2x.png";
                                    //selectionItemModel.get(currentBeSelectAnswer).isright ? "qrc:/cloudImage/pigai_right@2x.png" : "qrc:/cloudImage/pigai_wrong@2x.png";
                                }
                                else if(role == "student"){
                                    questionItemsModel[currentBeSelectAnswer].isright ? "qrc:/cloudImage/pigai_right@2x.png" : "qrc:/cloudImage/pigai_wrong@2x.png";
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    hoverEnabled: true
                    enabled: role == "teacher" ? false : true
                    width: 155 * heightRates
                    height: width / 3

                    Rectangle{
                        anchors.fill: parent
                        color: "white"
                        radius: 4 * heightRates
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
            width: role == "teacher" ? (singleQuestionListView.width - 60 * heightRates) / 2 : singleQuestionListView.width / 2
            height: width / 4
            color: "transparent";
            clip:{
                if(role == "student"){
                    return true;
                }
            }
            Rectangle {
                width: parent.width - 25 * heightRates
                height: parent.height - 20 * heightRates
                anchors.centerIn: parent
                radius: 10 * heightRates

                color: {
                    if(role == "teacher"){
                        return currentViewModel == 1 ?  "#C3C6C9" :  currentBeSelectAnswer == index ? "#FF7B44" : "#C3C6C9";
                        //currentViewModel == 1 ? currentBeSelectAnswer == index ? "#FF7B44" : "#C3C6C9" : questionItemsModel[index].isright ? "#FF7B44" : currentBeSelectAnswer == index ? "#FF7777" : "#C3C6C9"
                    }
                    else if(role == "student"){
                        return (currentViewModel == 3 || currentViewModel == 1) ? ( currentBeSelectAnswer == index ? "#FF7B44" : "#C3C6C9" ) : ( currentBeSelectAnswer == index ? "#FF7B44" : "#C3C6C9");
                    }
                }
                //选项的名字
                Text {
                    id: orderNameItem
                    text:  questionItemsModel[index].orderName //questionItemsModel.get(index).orderName//
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * heightRates
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 16 * heightRates
                    font.family: Cfg.DEFAULT_FONT
                    textFormat: Text.RichText
                    font.bold: true
                    color: "white"
                }

                Rectangle {
                    height: parent.height - 4 * heightRates
                    width: parent.width - 42 * heightRates
                    anchors.right: parent.right
                    anchors.rightMargin: 2 *　heightRates
                    // anchors.top: parent.top
                    radius:  10 * heightRates
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"

                    Rectangle {
                        height: parent.height
                        width: 10 * heightRates
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
                        //clip: true
                        model: childModel //questionItemsModel[index]//selectionItemModel.get(index)//
                        delegate:Rectangle
                        {
                            id:trectang
                            width:parent.width - 10 * heightRates
                            height: parent.height;// + 20 * heightRates
                            color: "transparent"
                            clip:true

                            Text {
                                id: text1
                                width: parent.width - 20 * heightRates
                                font.pixelSize: 16 * Screen.width * 0.8 / 966.0 / 1.5337
                                font.family: Cfg.DEFAULT_FONT
                                anchors.top: parent.top
                                anchors.topMargin: 8* heightRates
                                anchors.left: parent.left
                                anchors.leftMargin: 15 * heightRates
                                font.bold: true
                                text: model.contents//contents
                                wrapMode: Text.WrapAnywhere
                                textFormat: Text.RichText
                            }

                            Component.onCompleted: {
                                if(text1.height < parent.height)
                                {
                                    trectang.anchors.fill = parent
                                    text1.anchors.verticalCenter = trectang.verticalCenter;
                                }else
                                {
                                    text1.anchors.left = trectang.left
                                    trectang.height = text1.height;
                                }
                            }
                        }
                    }
                }
            }

            MouseArea {
                enabled: role == "teacher" ? false : true
                anchors.fill: parent
                onClicked: {
                    if(currentViewModel == 1) {
                        currentBeSelectAnswer = index;
                        if(role == "student"){
                            resetHasBufferAnswerList(index);
                        }
                    }
                }
            }

            Component.onCompleted: {
                //console.log("=====singleChoiceQuestion========",index,questionItemsModel.length -1);
                if(role == "teacher"){
                    if(clipStatus && questionItemsModel.length -1 == index){
                        sigLoadingSuccess();
                    }
                }
            }

        }

    }

    Component{
        id:answerAnalysisDelegate
        Rectangle {
            width: showQuestionParsing.width
            height:textColumn.height + 30 * heightRates //showQuestionParsing.height / 2

            Column {
                id:textColumn
                spacing: 10 * heightRates
                width: parent.width - 20 * heightRates
                anchors.horizontalCenter: parent.horizontalCenter
                Row {
                    spacing: 20 * heightRates
		    visible: role == "student" ? true: false
                    Text {
                        text: qsTr("得分")
                        font.pixelSize: 16 * heightRates
                        font.family: Cfg.DEFAULT_FONT
                        color: "gray"
                    }

                    Text {
                        text: {
                            if(currentBeSelectAnswer == -1){
                                return "0分";
                            }else{
                                questionItemsModel[currentBeSelectAnswer].isright ? score + qsTr("分") : qsTr("0分");
                                //selectionItemModel.get(currentBeSelectAnswer).isright ? score + qsTr("分") : qsTr("0分");
                            }
                        }
                        font.pixelSize: 16 * heightRates
                        font.family: Cfg.DEFAULT_FONT
                        color: "green"
                    }
                }

                Text {
                    text: qsTr("正确答案")
                    font.pixelSize: 16 * heightRates
                    font.family: Cfg.DEFAULT_FONT
                    color: "gray"
                }

                Text {
                    text: questionAnswer
                    width: parent.width
                    font.pixelSize: 16 * heightRates
                    font.family: Cfg.DEFAULT_FONT
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                }

                Rectangle  {
                    color: "#fff7c9"
                    width: 95 * heightRates
                    height: 25 * heightRates
                    radius: 2 * heightRates
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
                        font.pixelSize: 16 * heightRates
                        font.family: Cfg.DEFAULT_FONT
                        color: "gray"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.left: wrongImage.left
                        anchors.leftMargin: 25 * heightRates
                    }
                }

                Text {
                    text: errorType
                    width: parent.width
                    font.pixelSize: 16 * heightRates
                    font.family: Cfg.DEFAULT_FONT
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                }

                Rectangle {
                    color: "#fff7c9"
                    width: 85 * heightRates
                    height: 25 * heightRates
                    radius: 2 * heightRates
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
                        font.pixelSize: 16 * heightRates
                        font.family: Cfg.DEFAULT_FONT
                        color: "gray"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.left: knowledgeImage.left
                        anchors.leftMargin: 28 * heightRates
                    }
                }

                Text {
                    text: knowledgesString
                    width: parent.width
                    font.pixelSize: 16 * heightRates
                    font.family: Cfg.DEFAULT_FONT
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                }

                Rectangle {
                    color: "#fff7c9"
                    width: 65 * heightRates
                    height: 25 * heightRates
                    radius: 2 * heightRates
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
                        font.pixelSize: 16 * heightRates
                        font.family: Cfg.DEFAULT_FONT
                        color: "gray"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.left: parsingImage.left
                        anchors.leftMargin: 25 * heightRates
                    }
                }

                Text {
                    text: analyse
                    width: parent.width
                    font.pixelSize: 16 * heightRates
                    font.family: Cfg.DEFAULT_FONT
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
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
    
    //获取当前是否缓存过 显示题型的答案 如果有就取出赋值
    function getCurrentBufferList()
    {
        var hasSave = 0;
        var temp = -1 ;
        currentBeSelectAnswer = -1;
        for( var a = 0; a<hasBufferedQuestionAnswerList.length; a++)
        {
            if(currentQuestionId == hasBufferedQuestionAnswerList[a].questionId)
            {
                currentBeSelectAnswer = hasBufferedQuestionAnswerList[a].questionData;
                hasSave = 1;
                break;
            }
        }
        //不存在就 添加默认值
        if(hasSave == 0)
        {
            hasBufferedQuestionAnswerList.push({"questionData":temp,"questionId":currentQuestionId})
        }
    }
    //更新 当前缓存的题的答案数据
    function resetHasBufferAnswerList(beSelectIndexs)//
    {
        var tempindex = beSelectIndexs;
        for(var b = 0; b < hasBufferedQuestionAnswerList.length; b++)
        {
            if(currentQuestionId == hasBufferedQuestionAnswerList[b].questionId)
            {
                hasBufferedQuestionAnswerList[b] =({"questionData":tempindex,"questionId":currentQuestionId})
            }
        }
    }
}
