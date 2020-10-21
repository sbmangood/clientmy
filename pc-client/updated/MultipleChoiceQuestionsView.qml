import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Window 2.2
import QtWebEngine 1.4
import "Configuration.js" as Cfg

/*
*多选题
*/

Rectangle {
    id:mainView
    //color:"transparent"

    property int currentViewModel: -1;// 当前的显示模式 1 做题模式  2 对答案模式 3 预览模式

    property int currentBeSelectAnswer: -1;//当前被选中的答案 在model里的索引位置
    property  var  currentQuestionId:"" ;

    property string knowledgesString: ""; //知识点的文字详情

    property string questionAnswer: "";

    property  bool  studentAnswerisright: true;
    property var bufferQuestionItemsModel: [];
    property var questionItemsModel: [];
    property var answerModel: [];
    property var knowledgesModels: [];

    property var hasBufferedQuestionAnswerList: [];//已经存储过的 答案列表 结构  question id  + 选项数组（json存储）
    property var beSelectAnswerList: []; //当前题目 缓存的答案数据

    //当前题目是否做对了
    signal isDoRight(var isRight);

    signal saveStudentAnswer( var studentSelectAnswer, var questionId ,var orderNumber);

    //显示答案解析
    function showAnswerDetail()
    {
        showQuestionParsing.open();
    }

    function answerSubmit()
    {
        //模式显示为对答案模式
        currentViewModel = 1;
        //判断学生是否错对
        chargerStudentAnswer();
        isDoRight(studentAnswerisright);

        //获取学生的选择项

        //提交答案到服务器 orderno(int型)
        saveStudentAnswer(getStudentSelectAnswer(),singleQuestionModel.get(0).id,singleQuestionModel.get(0).orderNumber);

    }

    //重置数据 进行界面显示
    function updateMainView(items,viewType)
    {
        currentViewModel = viewType;
        if(viewType == 2)
        {
            currentViewModel = 3;
        }

        if(items == [] || items == undefined || questionItemsModel == []){
            return;
        }
        mainView.visible = false;
        mainView.visible = true;
        console.log("======items========",JSON.stringify(items) );
        console.log("====updateMainView===",items.score,items.content,items.errorType,items.id)
        //model 重置
        if(currentQuestionId == "" || currentQuestionId != items.id)
        {
            currentBeSelectAnswer = -1;
        }
        currentQuestionId = items.id;
        singleQuestionModel.clear();
        singleQuestionModel.append({
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

        for(var i = 0; i < knowledgesModels.length; i++){
            knowledgesString += knowledgesModels[i].konwledgeName;
        }

        if(bufferQuestionItemsModel.length > 0){
            bufferQuestionItemsModel.splice(0,bufferQuestionItemsModel.length);
        }

        var questionItems = questionItemsModel;//items.questionItems//
        console.log("====items.questionIt11111ems=====",questionItems.length,currentQuestionId)

        getCurrentBufferList();
        //        if(beSelectAnswerList.length == 0)
        //        {
        //            for(var cc = 0; cc < questionItems.length; cc++)
        //            {
        //                beSelectAnswerList.push(false);
        //            }
        //        }
        //调整model
        for(var c = 0; c < questionItems.length; c++){
            bufferQuestionItemsModel.push(
                        {
                            "contents": questionItems[c].contents,
                            "isright": questionItems[c].isright,
                            "orderName": questionItems[c].orderName,
                            "orderno": questionItems[c].orderno,
                            "qitemid": questionItems[c].qitemid,
                            "questionid": questionItems[c].questionid,
                            "score": questionItems[c].score,
                            "isBeSelect": beSelectAnswerList[c] //是否被选中
                        });
        }

        var answer = answerModel;//items.answer;
        for(var b = 0 ; b < answer.length ; b++ ) {
            questionAnswer += answer[b];
            if(b + 1 < answer.length) {
                questionAnswer += "\n";
            }
        }

    }


    function chargerStudentAnswer() {
        studentAnswerisright = true;
        for ( var a = 0 ; a < bufferQuestionItemsModel.length ; a++ )
        {
            if( bufferQuestionItemsModel[a].isright )
            {
                if(bufferQuestionItemsModel[a].isBeSelect == false)
                {
                    studentAnswerisright = false;
                    break;
                }
            }else
            {
                if(bufferQuestionItemsModel[a].isBeSelect == true)
                {
                    studentAnswerisright = false;
                    break;
                }
            }
        }
    }

    function getStudentSelectAnswer()
    {
        var tempString = "";
        for ( var a = 0 ; a < bufferQuestionItemsModel.length; a++ )
        {
            if(bufferQuestionItemsModel[a].isBeSelect == true)
            {
                if(tempString == "")
                {
                    tempString = tempString + bufferQuestionItemsModel[a].orderno.toString();
                }else
                {
                    tempString = tempString + "," + bufferQuestionItemsModel[a].orderno.toString();
                }
            }
        }

        return tempString;
    }

    ListView{
        id: singleQuestionListView
        width: parent.width
        height: parent.height
        clip: true
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

            MouseArea
            {
                anchors.fill: parent
            }

            Rectangle
            {
                // color: "red"
                anchors.fill: parent

                Rectangle
                {
                    width: parent.width
                    height: 20 * heightRate
                    //color: "red"

                    anchors.top: parent.top
                    anchors.topMargin: 20 * heightRate
                    Rectangle
                    {
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
                    Rectangle
                    {
                        width: 35 * heightRate
                        height: 2 * heightRate
                        color: "#e3e6e9"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: title.right
                        anchors.leftMargin: 5 * heightRate
                    }
                }

                ListView
                {
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

    //    ListModel{
    //        id: selectionItemModel
    //    }

    ListModel{
        id:knowledgesModel //知识点 model
    }

    ListModel {
        id: detailSelectItemModle//具体题目选项model
    }

    Component{
        id: singleQuestionDelegate

        Item {
            width: singleQuestionListView.width
            height: singleQuestionListView.height * 0.6 + bufferQuestionItemsModel.length / 2 * selectionItemGridViews.cellHeight
            //height: singleQuestionListView.height * 0.6 + selectionItemModel.count / 2 * selectionItemGridViews.cellHeight

            Rectangle {
                id:questionTypeRectangle
                width: 50 * heightRate
                height: 24 * heightRate
                color: "#ff7777"
                radius:  4 * heightRate
                anchors.top: parent.top
                anchors.topMargin: 50 * heightRate

                Text {
                    text: "多选题"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    color: "#ffffff"
                    anchors.centerIn: parent
                }
            }

            WebEngineView{
                id: questionTitle
                enabled: false
                width: singleQuestionListView.width - 20 * heightRate - questionTypeRectangle.width
                height: 45 * heightRate
                anchors.left: questionTypeRectangle.right
                anchors.leftMargin: 15 * heightRate
                anchors.top: parent.top
                anchors.topMargin:  36 * heightRate
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

//            Text {
//                id: questionTitle
//                text: content
//                width: singleQuestionListView.width - 20 * heightRate - questionTypeRectangle.width
//                anchors.top: parent.top
//                anchors.topMargin: 50 * heightRate
//                anchors.left: questionTypeRectangle.right
//                anchors.leftMargin: 15 * heightRate
//                font.pixelSize: 16 * heightRate
//                font.family: Cfg.DEFAULT_FONT
//                wrapMode: Text.WordWrap
//                // font.bold: true
//                textFormat: Text.RichText
//            }

            GridView{
                id:selectionItemGridViews
                width: singleQuestionListView.width - 20 * heightRate
                height:Math.ceil( bufferQuestionItemsModel.length / 2 ) * cellHeight //selectionItemModel.count / 2 * cellHeight
                anchors.top: questionTitle.bottom
                anchors.topMargin: 50 * heightRate
                model: bufferQuestionItemsModel // selectionItemModel
                delegate: gridViewDelegate
                clip: true
                cellWidth: selectionItemGridViews.width / 2
                cellHeight: cellWidth / 4
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
                //visible: currentViewModel == 1
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
                        //判断学生是否错对
                        chargerStudentAnswer();
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
                //visible: currentViewModel == 2
                visible: false
                spacing: 10 * heightRate

                Rectangle {
                    width: 150 * heightRate
                    height: width / 3
                    color: studentAnswerisright ? "#44EAC6" : "#FF7777"
                    radius: 4 * heightRate
                    Image {
                        width: parent.width
                        height: width / 3
                        anchors.centerIn: parent
                        source: studentAnswerisright ? "qrc:/cloudImage/pigai_right@2x.png" : "qrc:/cloudImage/pigai_wrong@2x.png";
                    }

                    MouseArea {
                        anchors.fill: parent
                    }
                }

                MouseArea{
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
                        source:parent.containsMouse ? "qrc:/cloudImage/btn_daanjiexi_sed@2x.png" : "qrc:/cloudImage/btn_daanjiexi@2x.png";
                    }

                    onClicked: {
                        showQuestionParsing.open();
                    }

                }

            }
        }

    }

    Component{
        id:gridViewDelegate
        Item {
            width: singleQuestionListView.width / 2 // / 2 - 10 *heightRate
            height: width / 4

            property bool isBeselects: bufferQuestionItemsModel[index].isBeSelect;
            property int currentViewModels: currentViewModel

            onCurrentViewModelsChanged: {
                backgundItem.color = (currentViewModel == 1 || currentViewModel == 3) ? (isBeselects ? "#FF7B44" : "#C3C6C9") : (bufferQuestionItemsModel[index].isright ? "#44EAC6": (isBeselects ? "#FF7777" : "#C3C6C9")  )
            }

            onIsBeselectsChanged: {
                backgundItem.color = (currentViewModel == 1 || currentViewModel == 3)? (isBeselects ? "#FF7B44" : "#C3C6C9") : (bufferQuestionItemsModel[index].isright ? "#44EAC6": (isBeselects ? "#FF7777" : "#C3C6C9")  )
            }

            Rectangle {
                id: backgundItem
                width: parent.width - 25 * heightRate
                height: parent.height - 20 * heightRate
                anchors.centerIn: parent
                radius: 10 * heightRate //#FF7777  错误的颜色  #44EAC6 对的颜色
                //color: currentViewModel == 1 ? (isBeselects ? "#FF7B44" : "#C3C6C9") : (bufferQuestionItemsModel[index].isright ? "#44EAC6": (isBeselects ? "#FF7777" : "#C3C6C9")  )
                color: currentViewModel == 1 ? (isBeselects ? "#FF7B44" : "#C3C6C9") : (isBeselects ? "#FF7B44" : "#C3C6C9")
                clip:true

                //选项的名字
                Text {
                    id: orderNameItem
                    text: bufferQuestionItemsModel[index].orderName// orderName //
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    font.bold: true
                    color: "white"
                }

                Rectangle {
                    height: parent.height - 5 * heightRate
                    width: parent.width - 45 * heightRate
                    anchors.right: parent.right
                    anchors.rightMargin: 3 *　heightRate
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

                    property int indexs: index ==0 ? -1 : index;

                    onIndexsChanged: {
                        if(indexs == -1){
                            childModel.append(
                                        {
                                            "contents": bufferQuestionItemsModel[index].contents,
                                            "isright": bufferQuestionItemsModel[index].isright,
                                            "orderName": bufferQuestionItemsModel[index].orderName,
                                            "orderno": bufferQuestionItemsModel[index].orderno,
                                            "qitemid": bufferQuestionItemsModel[index].qitemid,
                                            "questionid": bufferQuestionItemsModel[index].questionid,
                                            "score": bufferQuestionItemsModel[index].score,
                                            "isBeSelect":bufferQuestionItemsModel[index].isBeSelect, //是否被选中
                                        });
                            return;
                        }

                        childModel.append(
                                    {
                                        "contents": bufferQuestionItemsModel[indexs].contents,
                                        "isright": bufferQuestionItemsModel[indexs].isright,
                                        "orderName": bufferQuestionItemsModel[indexs].orderName,
                                        "orderno": bufferQuestionItemsModel[indexs].orderno,
                                        "qitemid": bufferQuestionItemsModel[indexs].qitemid,
                                        "questionid": bufferQuestionItemsModel[indexs].questionid,
                                        "score": bufferQuestionItemsModel[indexs].score,
                                        "isBeSelect": bufferQuestionItemsModel[index].isBeSelect, //是否被选中
                                    });
                    }

                    //具体的选项内容
                    ListView {
                        id: detailSelectItemListView
                        width: parent.width
                        height: parent.height
                        //clip: true
                        model: childModel // selectionItemModel.get(index) //
//                        anchors.top:parent.top
//                        anchors.topMargin: 12 * heightRate

                        delegate:Rectangle
                        {
                            id:trectang
                            width:parent.width - 10 * heightRate
                            height: parent.height + 20 * heightRate
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
                                text: contents//contents
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
                anchors.fill: parent
                onClicked: {
                    if(currentViewModel == 1){
                        currentBeSelectAnswer = index;
                        //selectionItemModel.get(index).isBeSelect = !selectionItemModel.get(index).isBeSelect;
                        bufferQuestionItemsModel[index].isBeSelect = !bufferQuestionItemsModel[index].isBeSelect;
                        parent.isBeselects = bufferQuestionItemsModel[index].isBeSelect;
                        beSelectAnswerList[index] = bufferQuestionItemsModel[index].isBeSelect;
                        resetHasBufferAnswerList(bufferQuestionItemsModel[index].isBeSelect,index);
                    }
                }
            }

        }
    }

    Component{
        id:answerAnalysisDelegate

        Rectangle
        {
            width: showQuestionParsing.width
            height:textColumn.height + 30 * heightRate //showQuestionParsing.height / 2
            //color: "red"
            Column
            {
                //anchors.fill: parent
                id:textColumn
                spacing: 10 * heightRate
                width: parent.width - 20 * heightRate
                // height: parent .height
                anchors.horizontalCenter: parent.horizontalCenter
                Row
                {
                    spacing: 20 * heightRate
                    Text {
                        text: qsTr("得分")
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        color: "gray"
                    }
                    Text {
                        text:studentAnswerisright ? score + qsTr("分") : qsTr("0分")
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        color: "green"
                    }
                }

                Rectangle
                {
                    width: trueAnswer.width + 5 * widthRate
                    height: trueAnswer.height + 3 *  widthRate
                    visible: answerStr == "" ? false : true
                    color: "#F3FFDA"
                    Text {
                        id:trueAnswer
                        text: qsTr("正确答案")
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        color: "#77B300"
                        anchors.centerIn: parent

                    }
                }
                Text {
                    text: questionAnswer
                    width: parent.width
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    wrapMode: Text.WordWrap
                }
                Rectangle
                {
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
                }
                Rectangle
                {
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
                }

                Rectangle
                {
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
                }
            }
        }
    }

    Component.onCompleted:
    {
        //console.log("SingleChoiceQuestionView.qml~~~~~~~~~~~~~~~~~~");
        // showQuestionParsing.open();
    }

    //获取当前是否缓存过 显示题型的答案 如果有 就取出赋值
    function getCurrentBufferList()
    {
        var hasSave = 0;
        var temp = [];
        beSelectAnswerList = [];
        for( var a = 0; a<hasBufferedQuestionAnswerList.length; a++)
        {
            if(currentQuestionId == hasBufferedQuestionAnswerList[a].questionId)
            {
                beSelectAnswerList = hasBufferedQuestionAnswerList[a].questionData;

                hasSave = 1;
                break
            }
        }
        //不存在就 存进去默认全部都不选中
        if(hasSave == 0)
        {
            for(var cc = 0; cc < questionItemsModel.length; cc++)
            {
                beSelectAnswerList.push(false);
                temp.push(false);
            }
            hasBufferedQuestionAnswerList.push({"questionData":temp,"questionId":currentQuestionId})
        }
    }
    //更新 当前缓存的题的答案数据
    function resetHasBufferAnswerList(isSelect,indexs)//
    {
        var tempList = [];
        for(var b = 0; b < hasBufferedQuestionAnswerList.length; b++)
        {
            if(currentQuestionId == hasBufferedQuestionAnswerList[b].questionId)
            {
                tempList = hasBufferedQuestionAnswerList[b].questionData;
                tempList[indexs] = isSelect;
                hasBufferedQuestionAnswerList[b] =({"questionData":tempList,"questionId":currentQuestionId})
            }
        }
    }

}
