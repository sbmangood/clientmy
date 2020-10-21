﻿import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtWebEngine 1.4
import "Configuration.js" as Cfg
import QtWebEngine 1.4

/*
*答案解析界面
*/

Popup{
    id:showQuestionParsing
    height: parent.height
    width: height /( 647 / 440 )
    background:Image{
        anchors.fill: parent
        source: "qrc:/cloudImage/pigaizuoyebeijing@3x.png"
    }

    property var dataModel: [];
    property string konwledgeName: "";
    property var answerModel: [];
    property var childQuestionInfoModel: [];
    property string answerStr: "";
    property string analyseStr: "";//解析显示数据
    signal sigOpenAnserParsing(var questionId,var childQuestionId);
    property var currentQuestionId ;
    property string currentChildQuestionId: "";

    //标记: 关闭"课程解析"的命令, 是来自老师的, 与自己关闭的区分开来
    property bool bCloseCommandIsFromTeacher: false;

    closePolicy:toobarWidget.teacherEmpowerment ? Popup.CloseOnPressOutside : Popup.NoAutoClose

    onChildQuestionInfoModelChanged: {
        numberModel.clear();
        var tempIndex = 0;
        //console.log("==============222333===============",JSON.stringify(answerModel))
        if(childQuestionInfoModel != null && childQuestionInfoModel  !="" && childQuestionInfoModel != []){
            for(var z = 0; z < childQuestionInfoModel.length;z++){
                console.log("*********childQuestionInfoModel[z].id***********",childQuestionInfoModel[z].id);
                var tempAnswer = childQuestionInfoModel[z];
                if(z == 0)
                {
                    answerModel = [];
                }

                if(currentChildQuestionId == childQuestionInfoModel[z].id )
                {
                    tempIndex = z;

                }

                answerModel.push(tempAnswer.answer);
                var reply = childQuestionInfoModel[z].reply == null ? "" : childQuestionInfoModel[z].reply.toString();
                var analyse = childQuestionInfoModel[z].analyse == null ? "" : childQuestionInfoModel[z].analyse.toString();
                numberModel.append(
                            {
                                "number": z +1,
                                "questionId": dataModel.id,
                                "childQuestionId": childQuestionInfoModel[z].id,
                                "isvisible": z == 0 ? true : false,
                                                      "analyse":reply + analyse,
                            });
            }

            if(currentChildQuestionId == "")
            {
                tempIndex = 0;
            }

            currentChildQuestionId = childQuestionInfoModel[tempIndex].id;
            //更新 number 选中的Ui
            for(var i = 0; i < numberModel.count; i++){
                if(i == tempIndex){
                    numberModel.get(i).isvisible = true;
                    continue;
                }
                numberModel.get(i).isvisible = false;
            }
            updateKnowData(tempIndex);


        }else{
            numberModel.clear();
            var replys = dataModel.reply == null ? "" : dataModel.reply.toString();
            var analyses = dataModel.analyse == null ? "" : dataModel.analyse.toString();

            numberModel.append(
                        {
                            "number": 1,
                            "questionId": dataModel.id,
                            "childQuestionId": dataModel.id,
                            "isvisible": true,
                            "analyse":replys + analyses,
                        })
            analyseStr = "";
            analyseStr = replys + analyses ;//题目解析
        }
    }

    onDataModelChanged: {
        numberModel.clear();
        analyseModel.clear();
        if(dataModel.length == 0 || dataModel == []) {
            return;
        }
        nowledgesView.contentY = 0;
        konwledgeName = "";
        answerStr = "";
        analyseStr = "";
        currentQuestionId = dataModel.id;

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

        if(dataModel.questionType  < 6){
            analyseStr = dataModel.reply.toString() + dataModel.analyse.toString() ;//题目解答
        }

        if(dataModel.childQuestionInfo == [] || dataModel.childQuestionInfo == null || dataModel.childQuestionInfo.length == 0)
        {
            answerModel = [];
            answerModel.push(dataModel.answer);
            //  console.log("======dataModel.knowledge::length==========",dataModel.knowledges.length,dataModel.answer)

        }
        console.log("=========knowledges=========");

        if(dataModel.knowledges != null && dataModel.knowledges != ""){
            konwledgeName = "";
            for(var i = 0; i < dataModel.knowledges.length;i++){
                konwledgeName += dataModel.knowledges[i].konwledgeName + "<p></p>";
            }

        }

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
        width: parent.width - 10 * widthRate
        height: parent.height
        anchors.centerIn: parent

        //答案解析字样
        Rectangle{
            id: answerItem
            width: parent.width
            height:  20 * heightRate

            anchors.top: parent.top
            anchors.topMargin: 10 * heightRate

            Rectangle {
                width: 35 * heightRate
                height: 2 * heightRate
                color: "#e3e6e9"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: title.left
                anchors.rightMargin: 5 * heightRate
                visible: false
            }

            Text {
                id:title
                text: qsTr("答案解析")
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 18 * heightRate
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
                visible: false
            }
        }

        //题目编号
        GridView{
            id: numberGridView
            width: parent.width - 14 * heightRate
            height: Math.floor((numberModel.count / 5)) * 45 * heightRate < 45 ? 45 : Math.floor((numberModel.count / 5)) * 45 * heightRate
            anchors.top: answerItem.bottom
            anchors.topMargin: 22 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 12 * widthRate
            cellHeight: 30 * heightRate
            cellWidth: width / 6
            visible: dataModel.questionType == 6 ? true : false

            model: numberModel
            delegate: MouseArea{
                hoverEnabled: true
                width: numberGridView.cellWidth - 5 * widthRate
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



                onClicked: {

                    if(toobarWidget.teacherEmpowerment)
                    {
                        isvisible = true;
                        for(var i = 0; i < numberModel.count; i++){
                            if(i == index){
                                currentChildQuestionId = numberModel.get(i).childQuestionId
                                trailBoardBackground.sendOpenAnswerParse(cloudRoomMenu.planId,cloudRoomMenu.columnId,currentQuestionId,currentChildQuestionId,true)

                                continue;
                            }
                            numberModel.get(i).isvisible = false;
                        }
                        updateKnowData(index);
                    }else
                    {
                        popupWidget.setPopupWidget("noselectpower");
                    }
                }

            }
        }

        ListView {
            id: nowledgesView
            width: parent.width - 14 * heightRate
            height: parent.height - title.height - 50 * heightRate -numberGridView.height
            clip: true
            anchors.left: parent.left
            anchors.leftMargin: 12 * widthRate
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
                        visible: konwledgeName == "" ? false : true
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
                        visible: konwledgeName == "" ? false : true
                        text: showQuestionParsing.konwledgeName
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
                        id: moveItem
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
                showQuestionParsing.konwledgeName += dataModel.knowledges[k].konwledgeName + "<p></p>";
            }
            return;
        }

        for(var i = 0; i < numberModel.count;i++){
            console.log("******updateCheckQuestion******",questionId,childQuestionId);
            showQuestionParsing.konwledgeName = "";
            if(numberModel.get(i).questionId == questionId && numberModel.get(i).childQuestionId == childQuestionId){
                numberModel.get(i).isvisible = true;
                var knowledgesArray = childQuestionInfoModel[i].knowledges;
                for(var z = 0; z <knowledgesArray .length; z++){
                    console.log("=====knowledgesArray[z].konwledgeName=====",knowledgesArray[z].konwledgeName)
                    showQuestionParsing.konwledgeName  += knowledgesArray[z].konwledgeName + "<p></p>";
                }
                showQuestionParsing.answerStr = answerModel.length > i  ? answerModel[i].toString() : answerStr;
                answerStr = (answerStr == "T" ? "对" : answerStr == "F" ? "错" : answerStr)
                showQuestionParsing.analyseStr = numberModel.get(i).analyse;
                continue;
            }
            numberModel.get(i).isvisible = false;
        }
    }


    function updateKnowData(index){
        console.log("==========childQuestionInfoModel[index].============",index)
        var knowledgesArray = childQuestionInfoModel[index].knowledges;
        var childQuestionIds = childQuestionInfoModel[index].id;
        var questionId = analyseModel.get(0).id;
        //console.log("******questionId::childQuestionId**********",questionId,childQuestionIds);
        console.log("========knowledges==========",JSON.stringify(knowledgesArray))
        //console.log("========answerModel==========" ,JSON.stringify(answerModel));
        showQuestionParsing.konwledgeName  = "";
        sigOpenAnserParsing(questionId,childQuestionIds)
        for(var i = 0; i <knowledgesArray.length; i++){
            showQuestionParsing.konwledgeName  += knowledgesArray[i].konwledgeName + "<p></p>";
        }
        showQuestionParsing.analyseStr = numberModel.get(index).analyse;
        showQuestionParsing.answerStr = answerModel.length > index ? answerModel[index].toString() : answerStr;
        answerStr = (answerStr == "T" ? "对" : answerStr == "F" ? "错" : answerStr)
    }
}
