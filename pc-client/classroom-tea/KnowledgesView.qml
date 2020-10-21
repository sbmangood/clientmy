import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtWebEngine 1.4
import "./Configuuration.js" as Cfg

/*
*答案解析界面
*/

Popup{
    id:showQuestionParsing
    height: parent.height
    width: height /( 647 / 440 )
    closePolicy:  mainView.teacherType == "L" ? Popup.NoAutoClose : Popup.CloseOnPressOutside
    //最好加入下面的2行属性, 不然, Popup在使用的时候, 会有奇怪的问题
    modal: mainView.teacherType == "L" ? false :  true
    //focus: true

    background: Image{
        anchors.fill: parent
        source: "qrc:/cloudImage/pigaizuoyebeijing@3x.png"
    }

    property var dataModel: [];
    property string konwledgeName: "";
    property var answerModel: [];
    property var childQuestionInfoModel: [];
    property string answerStr: "";//知识点
    property string analyseStr: "";//解析显示数据

    signal sigOpenAnserParsing(var questionId,var childQuestionId);

    onChildQuestionInfoModelChanged: {
        numberModel.clear();
        console.log("==============222===============",JSON.stringify(answerModel))
        if(childQuestionInfoModel != null && childQuestionInfoModel  !="" && childQuestionInfoModel != []){
            for(var z = 0; z < childQuestionInfoModel.length;z++){
                console.log("*********childQuestionInfoModel[z].id***********",childQuestionInfoModel[z].id);
                var reply = childQuestionInfoModel[z].reply == null ? "" : childQuestionInfoModel[z].reply.toString();
                var analyse = childQuestionInfoModel[z].analyse == null ? "" : childQuestionInfoModel[z].analyse.toString();
                if(z == 0){
                    mainView.childQuestionId = childQuestionInfoModel[z].id;
                    analyseStr = reply + analyse;//题目解析
                }
                numberModel.append(
                            {
                                "number": z +1,
                                "questionId": dataModel.id,
                                "childQuestionId": childQuestionInfoModel[z].id,
                                "analyse": reply + analyse,
                                "isvisible": z == 0 ? true : false,
                            });
                if(z == 0){
                    konwledgeName = "";
                    var childKnowledges = childQuestionInfoModel[z].knowledges;
                    if(childKnowledges != null && childKnowledges != ""){
                        for(var i = 0; i < childKnowledges.length;i++){
                            konwledgeName += "<br>" +childKnowledges[i].konwledgeName + "</br>";
                        }
                    }
                }
            }
        }
        else{
            var replys = dataModel.reply == null ? "" : dataModel.reply.toString();
            var analyses = dataModel.analyse == null ? "" : dataModel.analyse.toString()
            numberModel.append(
                        {
                            "number": 1,
                            "questionId": dataModel.id,
                            "childQuestionId": dataModel.id,
                            "analyse": replys + analyses,
                            "isvisible": true,
                        })
            analyseStr = replys + analyses;//题目解析
        }
    }

    onDataModelChanged: {
        analyseModel.clear();
        if(dataModel.length == 0 || dataModel == []) {
            return;
        }
        nowledgesView.contentY = 0;
        answerStr = "";
        analyseStr = "";
        console.log("======analyse=======",dataModel.analyse);
        analyseModel.append(
                    {
                        "id": dataModel.id,//题目id
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
                        "childQuestionInfo": dataModel.childQuestionInfo,//子题集合，数据结构和父类一样
                        "teacherImages": dataModel.teacherImages,//老师批注
                        "originImage": dataModel.originImage,//老师批注的原始图片
                        "image": dataModel.image,//老师批注图片，为空字符串时也是没有批注
                        "isRight": dataModel.isRight,//答案是否正确 0：错误，1：正确，2：半对半错
                        "score":dataModel.score,//题目得分
                        "errorType": dataModel.errorType,//错因
                    })

        console.log("======dataModel.knowledge::length==========",dataModel.knowledges.length)

        if(dataModel.questionType  < 6){
            var reply = dataModel.reply == null ? "" : dataModel.reply.toString();
            var analyse = dataModel.analyse == null ? "" : dataModel.analyse.toString()
            analyseStr = reply + analyse;//题目解答
            konwledgeName = "";
            if(dataModel.knowledges != null && dataModel.knowledges != ""){
                for(var i = 0; i < dataModel.knowledges.length;i++){
                    konwledgeName += "<br>" + dataModel.knowledges[i].konwledgeName + "</br>" ;
                }
            }
        }

        var replys = dataModel.reply == null ? "" : dataModel.reply.toString();
        var analyses = dataModel.analyse == null ? "" : dataModel.analyse.toString()
        numberModel.append(
                    {
                        "number": 1,
                        "questionId": dataModel.id,
                        "childQuestionId": dataModel.id,
                        "analyse": replys + analyses,
                        "isvisible": true,
                    })
        analyseStr = replys + analyses;//题目解析
    }

    MouseArea{
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
    }

    ListModel{
        id: numberModel
    }

    ListModel{
        id: analyseModel
    }


    Rectangle {
        width: parent.width - 10 * widthRates
        height: parent.height
        anchors.centerIn: parent
        Text {
            id:title
            text: qsTr("答案解析")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 18 * heightRate
            font.family: Cfg.DEFAULT_FONT
            wrapMode: Text.WordWrap
            anchors.top: parent.top
            anchors.topMargin: 5 * heightRate
        }

        Rectangle{
            id: answerItem
            width: parent.width - 15 * widthRates
            height:  45 * heightRate
            color: "#F9F9F9"
            anchors.top: parent.top
            anchors.topMargin: 55 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 12 * widthRates
            visible: isStartLesson

            Text {
                id:to_student_read
                text: qsTr("立即同步给学生")
                font.pixelSize: 15 * heightRate
                font.family: Cfg.DEFAULT_FONT
                wrapMode: Text.WordWrap
                visible: isStartLesson
                anchors.left: parent.left
                anchors.leftMargin: 6 * widthRates
                anchors.verticalCenter: parent.verticalCenter
            }

            //开关
            Rectangle{
                id:rect_on_off
                anchors.right: parent.right
                anchors.rightMargin: 10 * heightRate
                anchors.top: parent.top
                anchors.topMargin: -6 * heightRate
                width: 40 * heightRate
                height: 40 * heightRate
                visible: isStartLesson
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"

                Image {
                    id:image_on_off
                    source: bAnswer_Parse_OnOff ? "qrc:/newStyleImg/pcsd_btn_swift_on@2x.png" : "qrc:/newStyleImg/pcsd_btn_swift_off@2x.png"
                    width: 80 * heightRate * 0.54
                    height: 48 * heightRate * 0.54
                    anchors.centerIn: parent
                    visible: true

                    MouseArea{
                        anchors.fill: parent
                        visible: isStartLesson
                        cursorShape: Qt.PointingHandCursor
                        enabled: teacherType == "T" ? true : false //持麦者, 才可以点击
                        onClicked: {
                            //console.log("=========098============", bAnswer_Parse_OnOff, isStartLesson)
                            if(!bAnswer_Parse_OnOff){
                                bAnswer_Parse_OnOff = true;
                                trailBoardBackground.openAnswerParsing(mainView.planId, currentQuestionId, columnId, childQuestionId);
                            }else{
                                bAnswer_Parse_OnOff = false;
                                trailBoardBackground.closeAnswerParsing(planId, columnId, currentQuestionId);
                            }
                        }
                    }
                }
            }
        }

        //题目编号
        GridView{
            id: numberGridView
            width: parent.width - 14 * heightRate
            height: Math.floor((numberModel.count / 5)) * 45 * heightRate < 45 ? 45 : Math.floor((numberModel.count / 5)) * 45 * heightRate
            anchors.top: answerItem.bottom
            anchors.topMargin: 16 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 12 * widthRates
            cellHeight: 30 * heightRate
            cellWidth: width / 6
            visible: dataModel.questionType == 6 ? true : false

            model: numberModel
            delegate: MouseArea{
                hoverEnabled: true
                width: numberGridView.cellWidth - 5 * widthRates
                height: width / (58 / 20)
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    width: parent.width -5
                    height: parent.height - 5
                    anchors.centerIn: parent
                    color: isvisible ? "#ff5000" :"#f6f6f6"
                }

                Text {
                    text: (index + 1).toString()
                    anchors.fill: parent
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    color:  isvisible ? "#ffffff" : "#666666"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                function updateKnowData(index){
                    //console.log("==========childQuestionInfoModel[index].============",JSON.stringify(childQuestionInfoModel[index]))
                    var knowledgesArray = childQuestionInfoModel[index].knowledges;
                    var childQuestionIds = childQuestionInfoModel[index].id;
                    var questionId = analyseModel.get(0).id;
                    childQuestionId = childQuestionIds;

                    //console.log("========analyseStr==========" ,numberModel.get(index).analyse);

                    showQuestionParsing.konwledgeName  = "";
                    if(bAnswer_Parse_OnOff){
                        trailBoardBackground.openAnswerParsing(mainView.planId, questionId, mainView.columnId, childQuestionIds);
                    }
                    //sigOpenAnserParsing(questionId,childQuestionIds)
                    for(var i = 0; i <knowledgesArray .length; i++){
                        showQuestionParsing.konwledgeName  +="<br>" + knowledgesArray[i].konwledgeName +"</br>";
                    }
                    showQuestionParsing.answerStr = answerModel.length > index ? answerModel[index].toString() : answerStr;
                    answerStr = (answerStr == "T" ? "对" : answerStr == "F" ? "错" : answerStr)
                    showQuestionParsing.analyseStr = numberModel.get(index).analyse;
                }

                onClicked: {
                    isvisible = true;
                    for(var i = 0; i < numberModel.count; i++){
                        if(i == index){
                            continue;
                        }
                        numberModel.get(i).isvisible = false;
                    }
                    updateKnowData(index);
                }

            }
        }

        ListView {
            id: nowledgesView
            width: parent.width - 14 * heightRate
            height: parent.height - title.height - 50 * heightRate -numberGridView.height
            clip: true
            anchors.left: parent.left
            anchors.leftMargin: 12 * widthRates
            anchors.top: numberGridView.bottom
            anchors.topMargin: numberGridView.visible ? 25 * heightRate : -40 * heightRate
            model: analyseModel
            delegate: answerAnalysisDelegate
            boundsBehavior: ListView.StopAtBounds
        }

        Component{
            id:answerAnalysisDelegate
            Item {
                width: showQuestionParsing.width - 40 * heightRate
                height: textColumn.height + 30 * heightRate //showQuestionParsing.height / 2

                Column {
                    id:textColumn
                    spacing: 10 * heightRate
                    width: parent.width

                    property string answerData: answerStr;
                    property string analyseStrData: analyseStr;

                    onAnalyseStrDataChanged: {
                        webEngine.x = 0;
                        webEngine.loadHtml(analyseStr);
                    }

                    onAnswerDataChanged: {
                        anserView.x = 0;
                        anserView.loadHtml(answerData);
                    }

                    Rectangle
                    {
                        width: trueAnswer.width + 5 * widthRates
                        height: trueAnswer.height + 3 *  widthRates
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

                    Rectangle{
                        width: parent.width
                        height: anserView.height

                        WebEngineView{
                            id:anserView
                            z: 76
                            enabled: true
                            width: parent.width - 20 * heightRate
                            height: 20 * widthRates

                            //右键的时候, 不弹出右键菜单
                            onContextMenuRequested: function(request) {
                                request.accepted = true;
                            }

                            onContentsSizeChanged: {
                                anserView.height = anserView.contentsSize.height;
                            }

                            Component.onCompleted: {
                                var newAnswer;
                                if(answerStr == ""){
                                    if(answerModel.length > 0){
                                        var answer = answerModel[index] == undefined ? "" : answerModel[index].toString();
                                        newAnswer =  answer == "T" ? "对" : answer == "F" ? "错" : answer
                                        answerStr = newAnswer;
                                    }
                                }else{
                                    newAnswer = answerStr == "T" ? "对" : answerStr == "F" ? "错" : answerStr;
                                    answerStr = newAnswer;
                                }
                                console.log("===newAnswer===",newAnswer);
                                loadHtml(newAnswer);
                                // loadHtml("<html > <head> <style> p{font-family:\"Microsoft YaHei\"}    </style></head>" + content + "</html>");
                            }
                        }
                    }

                    Rectangle{
                        color: "#fff7c9"
                        width: 85 * heightRate
                        height: 25 * heightRate
                        radius: 2 * heightRate
                        visible: showQuestionParsing.konwledgeName == "" ? false : true

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
                            color: "#c9930c"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.left: knowledgeImage.left
                            anchors.leftMargin: 28 * heightRate
                        }
                    }

                    Text {
                        text: showQuestionParsing.konwledgeName
                        width: parent.width - 10 * heightRate
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
                        visible: analyseStr == "" ? false : true

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
                            color: "#c9930c"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.left: parsingImage.left
                            anchors.leftMargin: 25 * heightRate
                        }
                    }


                    Rectangle{
                        width: parent.width
                        height: webEngine.height

                        WebEngineView{
                            id:webEngine
                            z: 76
                            enabled: true
                            width: parent.width - 20 * heightRate//audioVideoHomeWorkListView.width / 1.4
                            height: 20 * widthRates

                            //右键的时候, 不弹出右键菜单
                            onContextMenuRequested: function(request) {
                                request.accepted = true;
                            }

                            onContentsSizeChanged: {
                                webEngine.height = webEngine.contentsSize.height;
                            }

                            Component.onCompleted: {
                                loadHtml(analyseStr);
                                // loadHtml("<html > <head> <style> p{font-family:\"Microsoft YaHei\"}    </style></head>" + content + "</html>");
                            }
                        }

                        //                        MouseArea{
                        //                            z: 66
                        //                            anchors.fill: parent
                        //                            drag.target: webEngine
                        //                            drag.axis: Drag.XAxis
                        //                            drag.maximumX: 0
                        //                            cursorShape: Qt.PointingHandCursor
                        //                            onMouseXChanged: {
                        //                                var contentX = webEngine.x + mouseX;
                        //                                if(contentX >= 0 )
                        //                                {
                        //                                    contentX = webEngine.x;
                        //                                }
                        //                                if(webEngine.width <= parent.width)
                        //                                {
                        //                                    webEngine.x = 0;
                        //                                    return;
                        //                                }
                        //                                if(-contentX >= webEngine.width * 0.8)
                        //                                {
                        //                                    webEngine.x = -(webEngine.width * 0.8);
                        //                                    return;
                        //                                }
                        //                                webEngine.x = contentX;
                        //                            }
                        //                        }
                    }
                }

            }
        }
    }

    function updateCheckQuestion(questionId,childQuestionId){
        console.log("******updateCheckQuestion::Data********",questionId,childQuestionId,numberModel.count);
        showQuestionParsing.konwledgeName = "";
        showQuestionParsing.analyseStr = "";

        if(dataModel.questionType  < 6){
            var reply = dataModel.reply == null ? "" : dataModel.reply.toString();
            var analyse = dataModel.analyse == null ? "" : dataModel.analyse.toString()
            showQuestionParsing.analyseStr = reply + analyse;//题目解答
            for(var k = 0; k < dataModel.knowledges.length;k++){
                showQuestionParsing.konwledgeName += "<br>" +dataModel.knowledges[k].konwledgeName + "</br>";
            }
            return;
        }

        for(var i = 0; i < numberModel.count;i++){
            console.log("******updateCheckQuestion********",questionId,childQuestionId);
            if(numberModel.get(i).questionId == questionId && numberModel.get(i).childQuestionId == childQuestionId){
                numberModel.get(i).isvisible = true;
                mainView.childQuestionId = questionId;//给主页面当前子ID赋值
                var knowledgesArray = childQuestionInfoModel[i].knowledges;
                for(var z = 0; z <knowledgesArray .length; z++){
                    console.log("=====knowledgesArray[z].konwledgeName=====",knowledgesArray[z].konwledgeName)
                    showQuestionParsing.konwledgeName  += "<br>" +knowledgesArray[z].konwledgeName + "<\br>";
                }

                showQuestionParsing.answerStr = answerModel.length > i  ? answerModel[i].toString() : answerStr;
                answerStr = (answerStr == "T" ? "对" : answerStr == "F" ? "错" : answerStr)
                var replys = numberModel.get(i).reply == null ? "" : numberModel.get(i).reply.toString();
                var analyses = numberModel.get(i).analyse == null ? "" : numberModel.get(i).analyse.toString();
                showQuestionParsing.analyseStr = replys + analyses;
                continue;
            }
            numberModel.get(i).isvisible = false;
        }
    }
}
