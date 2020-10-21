import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Window 2.2
import QtWebEngine 1.4
import "./Configuuration.js" as Cfg

/*
*判断题界面
*/

Item {
    id: judgmentMainView
    //color:"transparent"

    property int currentViewModel: 1;// 教师：当前的显示模式 1 做题模式  2 对答案模式；学生：// 当前的显示模式 1 做题模式  2 对答案模式 3 预览模式  shouhandlerview 的2为预览模式
    property int currentBeSelectAnswer: -1;//当前被选中的答案 在model里的索引位置
    property var hasBufferedQuestionAnswerList: [];//已经存储过的 答案列表 结构  question id  + 选项数组（json存储）
    property  var  currentQuestionId:"" ;
    property string knowledgesString: ""; //知识点的文字详情

    property string questionAnswer: "";
    property var errorName: ;
    property var questionItemsModel: [];
    property var answerModel: [];
    property var knowledgesModels: [];
    property string baseImages: "";//题目是否已做完显示数据
    property var photosModel: [];
    property bool clipImageStatus: false;//截图
    property bool isComplexClip: false;

    //批改信号
    signal sigCorrect(var imageUrl,var status,var imgWidth,var imgHeight);//图片路径、题目状态,题目类型
    signal sigLoadingSuccess();//加载完成开始截图
    //当前题目是否做对了
    signal isDoRight(var isRight);

    signal saveStudentAnswer( var studentSelectAnswer, var questionId , var orderNumber );
    //显示答案解析
    function showAnswerDetail()
    {
        showQuestionParsing.open();
    }

    function answerSubmit()
    {
        //console.log(" function answerSubmit() 11111111111 JudgmentQuestionView.qml currentBeSelectAnswer", currentBeSelectAnswer);

        //========================================
        //默认值为空, 不可以是: var orderNumber = questionItemsModel[currentBeSelectAnswer].orderno.toString();
        //如果是这样的话, 判断题, 学生没有操作的话, 这一行qml执行失败, 因为找不到: orderno 属性
        var orderNumber = "";
        //console.log(" function answerSubmit() 22222222222 JudgmentQuestionView.qml currentBeSelectAnswer", currentBeSelectAnswer);

        //========================================
        if(currentBeSelectAnswer == -1 )
        {
            orderNumber = "";
            isDoRight(false);
        }else
        {
            orderNumber = questionItemsModel[currentBeSelectAnswer].orderno.toString();

            //判断学生是否错对, 只有在学生做题了以后, 才能使用以下打印, 不然, 在使用: isright的时候, qml执行出错
            console.log("JudgmentQuestionView.qmlquestionItemsModel[currentBeSelectAnswer].isright", questionItemsModel[currentBeSelectAnswer].isright);

            if(questionItemsModel[currentBeSelectAnswer].isright )
            {
                isDoRight(true);
            }else
            {
                isDoRight(false);
            }
        }

        //模式显示为对答案模式
        currentViewModel = 2;

        //提交答案到服务器 orderno(int型)
        saveStudentAnswer(orderNumber,singleQuestionModel.get(0).id,singleQuestionModel.get(0).orderNumber);
    }


    //重置数据 进行界面显示
    function updateMainView(questionData,topiceModel) {
        if(role == "student"){
            currentViewModel = topiceModel;//根据传入的数据更改显示模式
            if(topiceModel == 2)
            {
                currentViewModel = 3;
            }
        }

        judgmentMainView.visible = true;
        showQuestionParsing.visible = false;
        var items = questionData;
        var answer = answerModel;

        if(role == "teacher"){
            baseImages = "";
            currentViewModel = topiceModel;
            //model 重置
            detailSelectItemModle.clear();
            singleQuestionModel.clear();
            if(items.studentAnswer != "" && currentViewModel == 2){
                var orderno = parseInt(items.studentAnswer);
                for(var z = 0; z < questionItemsModel.length;z++){
                    if(questionItemsModel[z].orderno == orderno){
                        currentBeSelectAnswer = z;
                        break;
                    }
                }
            }
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
                                           "baseImage": items.baseImage,
                                       });

            if(photosModel.length > 0){
                photosModel.splice(0,photosModel.length);
            }

            if(items.writeImages != null){
                for(var z = 0; z < items.writeImages.length; z++){
                    photosModel.push(
                                {
                                    "imagePath":  items.writeImages[z],
                                });
                }
            }

            if(items.photos != null){
                for(var k = 0; k < items.photos.length; k++){
                    photosModel.push(
                                {
                                    "imagePath":  items.photos[k],
                                });
                }
            }

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
            for(var z = 0; z < knowledgesModels.length; z++){
                knowledgesString += knowledgesModels[z].konwledgeName;
            }

            for(var b = 0 ; b < answer.length ; b++ ){
                questionAnswer = answer[b];
            }
            errorName= items.errorName == null ? "" : items.errorName;
        }
        else if(role == "student"){
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
                                           "id":items.id,
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
        visible: {
            if(role == "teacher"){
                if(baseImages == ""){
                    sigCorrect("",5,0,0);
                    return true;
                }
                else{
                    return false;
                }
            }
            else if(role == "student"){
                return true;
            }
        }
        model: singleQuestionModel
        delegate: singleQuestionDelegate
    }

    //答案解析面板
    Rectangle{
        height: parent.height
        width: parent.width * 0.3
        visible: showQuestionParsing.visible
        color: "transparent"
        x: parent.width - width //- 5 * widthRate
        y:0

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

            MouseArea{
                anchors.fill: parent
            }

            Rectangle{
                // color: "red"
                anchors.fill: parent

                Rectangle {
                    width: parent.width
                    height: 20 * heightRate
                    //color: "red"

                    anchors.top: parent.top
                    anchors.topMargin: 20 * heightRate
                    Rectangle {
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
            width: singleQuestionListView.width
            height: {
                if(role == "teacher") {
                    return judgmentMainView.height * 0.5 +  questionItemsModel.length / 2 * selectionItemGridViews.cellHeight + 190 * heightRate + answerView.height;
                }
                else if(role == "student"){
                    return singleQuestionListView.height * 0.6 + questionItemsModel.length / 2 * selectionItemGridViews.cellHeight;
                }
            }
            onHeightChanged: {
                if(role == "teacher"){
                    if(clipImageStatus){
                        if(isComplexClip){
                            singleQuestionListView.height = height;
                        }
                        else{
                            singleQuestionListView.height = height + 140 * heightRate;
                            topicRow.topPadding = 100 * heightRate
                        }
                        return;
                    }
                    singleQuestionListView.height = judgmentMainView.height;
                }
            }
            color: "transparent"

            Row{
                id: topicRow
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: 36 * heightRate
                spacing: role == "teacher" ? 10 * heightRate : 15 * heightRate

                Rectangle{
                    id: topicType
                    width: 50 * heightRate
                    height: 24 * heightRate
                    color: "#ff7777"
                    radius:  4 * heightRate

                    Rectangle{
                        width: 4 * widthRate
                        height: parent.height
                        color: "#ff7777"
                    }

                    Text {
                        text:  "判断题"
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        color: "#ffffff"
                        anchors.centerIn: parent

                    }
                }

                WebEngineView{
                    id: contentText
                    enabled: true
                    width: parent.width - topicType.width - 40 * widthRate
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

            GridView {
                id:selectionItemGridViews
                width: {
                    if(role == teacher){
                        return singleQuestionListView.width - 60 * heightRate;
                    }
                    else if(role == "student"){
                        return singleQuestionListView.width - 20 * heightRate;
                    }
                }
                height: Math.ceil(questionItemsModel.length / 2) * cellHeight
                anchors.top: topicRow.bottom
                anchors.topMargin: 50 * heightRate
                model: questionItemsModel // selectionItemModel //
                delegate: gridViewDelegate
                clip: true
                cellWidth: selectionItemGridViews.width / 2
                cellHeight: cellWidth / 8
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
                visible: false
                Text {
                    text: "做好了"
                    anchors.centerIn: parent
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    wrapMode: Text.WordWrap
                    color:  "white"
                }

                MouseArea {
                    enabled: currentBeSelectAnswer != -1
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        //模式显示为对答案模式
                        currentViewModel = 2;
                    }
                }
            }

            Row {
                width: 300 * heightRate
                height: width / 4.5
                anchors.top: selectionItemGridViews.bottom
                anchors.topMargin: 10 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: 26 * heightRate
                visible: false
                spacing: 10 * heightRate

                Rectangle {
                    width: 150 * heightRate
                    height: width / 3
                    radius: 4 * heightRate

                    color: {
                        if(currentBeSelectAnswer == -1){
                            return "#00000000"
                        }
                        questionItemsModel[currentBeSelectAnswer].isright ? "#44EAC6" : "#FF7777"
                        //selectionItemModel.get(currentBeSelectAnswer).isright ? "#44EAC6" : "#FF7777"
                    }

                    Image {
                        width: parent.width
                        height: width / 3
                        anchors.centerIn: parent
                        source: {
                            if(currentBeSelectAnswer == -1){
                                return "";
                            }
                            questionItemsModel[currentBeSelectAnswer].isright ? "qrc:/cloudImage/pigai_right@2x.png" : "qrc:/cloudImage/pigai_wrong@2x.png";
                            //selectionItemModel.get(currentBeSelectAnswer).isright ? "qrc:/cloudImage/pigai_right@2x.png" : "qrc:/cloudImage/pigai_wrong@2x.png";
                        }
                    }
                    MouseArea
                    {
                        anchors.fill: parent

                    }

                }

                MouseArea {
                    width: 155 * heightRate
                    height: width / 3
                    hoverEnabled: true

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
                        source: parent.containsMouse ? "qrc:/cloudImage/btn_daanjiexi_sed@2x.png"  : "qrc:/cloudImage/btn_daanjiexi@2x.png";
                    }

                    onClicked:{
                        showQuestionParsing.open();
                    }

                }

            }

            Rectangle {
                id:answerView
                width: parent.width - 15 * widthRates
                anchors.top: selectionItemGridViews.bottom
                anchors.topMargin: 10 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: 26 * heightRate
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
                        text:errorName
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

        }

    }

    Component {
        id:gridViewDelegate

        Rectangle {
            width: {
                if(role == "teacher"){
                    return (singleQuestionListView.width - 60 * heightRate) / 2;
                }
                else if(role == "student"){
                    return singleQuestionListView.width / 2;
                }
            }
            height: width / 8
            color: "transparent"

            Rectangle {
                width: parent.width - 25 * heightRate
                height: parent.height - 20 * heightRate
                anchors.centerIn: parent
                radius: 10 * heightRate
                color: {
                    if(role == "teacher"){
                        if(currentViewModel == 1){
                            return "#C3C6C9";
                        }
                        else{
                            if(currentBeSelectAnswer == index){
                                return "#FF7B44";
                            }
                            else{
                                return "#C3C6C9";
                            }
                        }
                    }
                    else if(role == "student"){
                        return (currentViewModel == 3 || currentViewModel == 1) ? currentBeSelectAnswer == index ? "#FF7B44" : "#C3C6C9" : currentBeSelectAnswer == index ? "#FF7B44" : "#C3C6C9";
                    }
                }
                Image {
                    anchors.left: parent.left
                    anchors.leftMargin: (parent.width / 12 - width) / 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width / 17
                    height: width //
                    source: index == 0 ? "qrc:/cloudImage/panduan_icon_dui@2x.png" : "qrc:/cloudImage/panduan_icon_cuo@2x.png"
                }

                Rectangle {
                    height: parent.height - 4 * heightRate
                    width: parent.width - parent.width / 12
                    anchors.right: parent.right
                    anchors.rightMargin: 2 *　heightRate
                    // anchors.top: parent.top
                    radius:  10 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"

                    Rectangle{
                        height: parent.height
                        width: 10 * heightRate
                        anchors.left: parent.left
                        anchors.leftMargin: -1
                        anchors.verticalCenter: parent.verticalCenter
                        color: parent.color
                    }

                    Text {
                        id: text1
                        //width: 650 * Screen.width * 0.8 / 966.0 / 1.5337
                        wrapMode: Text.WordWrap
                        textFormat: Text.RichText
                        font.pixelSize: 16 * Screen.width * 0.8 / 966.0 / 1.5337
                        font.family: Cfg.DEFAULT_FONT
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20 * heightRate
                        font.bold: true
                        text:  questionItemsModel[index].contents// contents //
                    }
                }

            }

            MouseArea{
                enabled: role == "student" ? false : true
                anchors.fill: parent
                onClicked:{
                    if(currentViewModel == 1)
                    {
                        console.log(index);
                        currentBeSelectAnswer = index;
                        if(role == "student"){
                            resetHasBufferAnswerList(index);
                        }
                    }
                }
            }

            Component.onCompleted: {
                if(role == "teacher"){
                    if(clipImageStatus && index == questionItemsModel.length -1){
                        sigLoadingSuccess();
                    }
                }
            }
        }
    }

    Component {
        id:answerAnalysisDelegate

        Rectangle {
            width: showQuestionParsing.width
            height:textColumn.height + 30 * heightRate //showQuestionParsing.height / 2

            Column {
                id:textColumn
                spacing: 10 * heightRate
                width: parent.width - 20 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter

                Row {
                    spacing: 20 * heightRate
                    visible: role == "student" ? true : false
                    Text {
                        text: qsTr("得分")
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        color: "gray"
                    }
                    Text {
                        text: {
                            if(currentBeSelectAnswer == -1){
                                return "0分"
                            }
                            questionItemsModel[currentBeSelectAnswer].isright ? score + qsTr("分") : qsTr("0分")
                            //selectionItemModel.get(currentBeSelectAnswer).isright ? score + qsTr("分") : qsTr("0分")
                        }
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        color: "green"
                    }
                }

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
                    textFormat: Text.RichText
                }

                Rectangle{
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
                    textFormat: Text.RichText
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
                    textFormat: Text.RichText
                }

                Rectangle{
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
                    textFormat: Text.RichText
                }
            }
        }
    }
    Component.onCompleted:{
        //        showQuestionParsing.close();
        //        showQuestionParsing.visible = false;
    }

    function updateClipStatus(status,complexClip){
        clipImageStatus = status;
        isComplexClip = complexClip;
    }

    function clipJudgmentImage(){
        return singleQuestionListView;
    }
    
    //获取当前是否缓存过 显示题型的答案 如果有 就取出赋值
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
