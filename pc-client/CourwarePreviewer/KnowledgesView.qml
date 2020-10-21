import QtQuick 2.0
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
    width: 400 * heightRate
    background:Image{
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
                var analyse = childQuestionInfoModel[z].analyse == null ? "" : childQuestionInfoModel[z].analyse.toString()
                numberModel.append(
                            {
                                "number": z +1,
                                "questionId": dataModel.id,
                                "childQuestionId": childQuestionInfoModel[z].id,
                                "analyse": reply + analyse,
                                "isvisible": z == 0 ? true : false,
                            });
                if(z == 0){
                    analyseStr = reply + analyse;//题目解析
                    konwledgeName = "";
                    var childKnowledges = childQuestionInfoModel[z].knowledges;
                    if(childKnowledges != null && childKnowledges != ""){
                        for(var i = 0; i < childKnowledges.length;i++){
                            konwledgeName += childKnowledges[i].konwledgeName + "<p>";
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
        knowledgesView.contentY = 0;
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
                    konwledgeName += "<br>" + dataModel.knowledges[i].konwledgeName + "</br>";
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
        anchors.fill: parent

        //答案解析字样
        Rectangle{
            id: answerItem
            width: parent.width
            height:  20 * heightRate

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

            Rectangle{
                width: 35 * heightRate
                height: 2 * heightRate
                color: "#e3e6e9"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: title.right
                anchors.leftMargin: 5 * heightRate
            }
        }

        //题目编号
        GridView{
            id: numberGridView
            width: parent.width - 20 * heightRate
            height: Math.floor((numberModel.count / 5)) * 45 * heightRate < 45 ? 45 : Math.floor((numberModel.count / 5)) * 45 * heightRate
            anchors.top: answerItem.bottom
            anchors.topMargin: 10 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            cellHeight: 30 * heightRate
            cellWidth: width / 5
            visible: numberModel.count > 1 ? true : false

            model: numberModel
            delegate: MouseArea{
                hoverEnabled: true
                width: numberGridView.cellWidth
                height: numberGridView.cellHeight
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
                    color:  isvisible ? "#ffffff" : "#000000"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                function updateKnowData(index){
                    //console.log("==========childQuestionInfoModel[index].============",JSON.stringify(childQuestionInfoModel[index]))
                    var knowledgesArray = childQuestionInfoModel[index].knowledges;
                    var childQuestionIds = childQuestionInfoModel[index].id;
                    var questionId = analyseModel.get(0).id;
                    childQuestionId = childQuestionIds;
                    console.log("========analyseStr==========" ,numberModel.get(index).analyse);
                    showQuestionParsing.konwledgeName  = "";
                    sigOpenAnserParsing(questionId,childQuestionIds)
                    for(var i = 0; i <knowledgesArray .length; i++){
                        showQuestionParsing.konwledgeName  += knowledgesArray[i].konwledgeName;
                    }
                    showQuestionParsing.answerStr = answerModel.length > index ? answerModel[index].toString() : answerStr;
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
            id: knowledgesView
            width: parent.width -20 * heightRate
            height: parent.height - title.height - 50 * heightRate -numberGridView.height
            clip: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: numberGridView.bottom
            anchors.topMargin: 20 * heightRate
            model: analyseModel
            delegate: answerAnalysisDelegate
            boundsBehavior: ListView.StopAtBounds
        }

        Component{
            id:answerAnalysisDelegate
            Item {
                width: showQuestionParsing.width - 40 * heightRate
                height:textColumn.height + 30 * heightRate //showQuestionParsing.height / 2

                Column {
                    id:textColumn
                    spacing: 10 * heightRate
                    width: parent.width

                    property string answerData: answerStr;
                     onAnswerDataChanged: {
                         anserView.x = 0;
                         webEngine.x = 0;
                     }

                    Text {
                        text: qsTr("正确答案")
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        color: "#c9930c"
                        visible: answerStr == "" ? false : true
                    }

                    Rectangle{
                        width: parent.width
                        height: anserView.height

                        WebEngineView{
                            id:anserView
                            z: 56
                            enabled: true
                            width: parent.width - 20 * heightRate
                            height: 20 * widthRate

                            //右键的时候, 不弹出右键菜单
                            onContextMenuRequested: function(request) {
                                request.accepted = true;
                            }

                            onContentsSizeChanged: {
//                                anserView.width = anserView.contentsSize.width;
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
                                    newAnswer = answerStr == "T" ? "对" : answerStr == "F" ? "错" : answerStr
				    answerStr = newAnswer;
                                }
                                //console.log("===newAnswer===",newAnswer);
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
                            enabled: true
                            width: parent.width - 20 * heightRate//audioVideoHomeWorkListView.width / 1.4
                            height: 20 * widthRate

                            //右键的时候, 不弹出右键菜单
                            onContextMenuRequested: function(request) {
                                request.accepted = true;
                            }

                            onContentsSizeChanged: {
//                                webEngine.width = webEngine.contentsSize.width;
                                webEngine.height = webEngine.contentsSize.height;
                            }

                            Component.onCompleted: {
                                loadHtml(analyseStr);
                                // loadHtml("<html > <head> <style> p{font-family:\"Microsoft YaHei\"}    </style></head>" + content + "</html>");
                            }
                        }
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
                showQuestionParsing.konwledgeName +=  "<br>" + dataModel.knowledges[k].konwledgeName + "</br>";
            }
            return;
        }

        for(var i = 0; i < numberModel.count;i++){
            console.log("******updateCheckQuestion********",questionId,childQuestionId);
            if(numberModel.get(i).questionId == questionId && numberModel.get(i).childQuestionId == childQuestionId){
                numberModel.get(i).isvisible = true;
                var knowledgesArray = childQuestionInfoModel[i].knowledges;
                for(var z = 0; z <knowledgesArray .length; z++){
                    console.log("=====knowledgesArray[z].konwledgeName=====",knowledgesArray[z].konwledgeName)
                    showQuestionParsing.konwledgeName  += knowledgesArray[z].konwledgeName;
                }
                showQuestionParsing.answerStr = answerModel.length > i  ? answerModel[i].toString() : answerStr;
                var replys = dataModel.reply == null ? "" : dataModel.reply.toString();
                var analyses = dataModel.analyse == null ? "" : dataModel.analyse.toString()
                showQuestionParsing.analyseStr = replys + analyses;
                continue;
            }
            numberModel.get(i).isvisible = false;
        }
    }
}
