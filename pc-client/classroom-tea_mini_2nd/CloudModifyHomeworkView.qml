import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuuration.js" as Cfg

/*
*批改页面 questionType < = 3 自动批改
*/

Popup {
    width: 400 * heightRate
    height: parent.height
    background: Image{
        anchors.fill: parent
        source: "qrc:/cloudImage/pigaizuoyebeijing@3x.png"
    }

    MouseArea{
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
    }

    property var dataModel: [];
    property bool selecteStatus: false;//初始化数据时不发送错因

    signal sigCommitTopic(var commitParm);//提交批改接口信号
    signal sigCommitTopicComand(var questionId,//对应的题ID
                                var childQuestionId, //小题ID
                                var correctType,//批改类型 0 正确 1 错误 2 半对半错
                                var score,//得分
                                var errorReason,//错因
                                var errorTypeId);//提交批改命令

    onDataModelChanged: {
        workModel.clear();
        if(dataModel.length == 0 || dataModel == []){
            return;
        }
        selecteStatus = false;
        //console.log("========Modify::dataModel==88========",JSON.stringify(dataModel) )
        if(dataModel.childQuestionInfo == null || dataModel.childQuestionInfo == undefined){
            var scoreModels = setScoreData(dataModel.score);
            workModel.append(
                        {
                            "id": dataModel.id,//对应题的Id
                            "score": dataModel.score,//选择得分
                            "scoreModels": scoreModels,//分数数据模型
                            "realScore": dataModel.score,//题目原有得分
                            "oldScore": dataModel.studentScore,//真实得分
                            "childQuestionId": dataModel.id,//小题Id
                            "orderNumber": dataModel.orderNumber,
                            "remarkUrl": dataModel.remarkUrl,
                            "remarkTime": dataModel.remarkTime,
                            "errorType": dataModel.errorType,
                            "errorTypeId": 0,
                            "questionType": dataModel.questionType,
                            "errorName": dataModel.errorName == null ? "" : dataModel.errorName,
                            "questionStatus": dataModel.isRight,//答案是否正确 0：错误，1：正确，2：半对半错
                            "isCompare": -1,//答案是否正确 0：错误，1：正确，2：半对半错
                            "correStatus": dataModel.status,
                            "isRight":dataModel.isRight,
                            "selected": false,
                            "checked": false,//是否进行过点击
                        });
            console.log("=======updateScore======",dataModel.id,dataModel.score,dataModel.orderNumber);
            return;
        }

        var childQuestionInfo = dataModel.childQuestionInfo;
        console.log("**************Modify::dataModel************",childQuestionInfo.length);
        for(var i = 0; i < childQuestionInfo.length; i++){
            var scoreModels = setScoreData(childQuestionInfo[i].score);
            workModel.append(
                        {
                            "id": dataModel.id,//对应题的Id
                            "score": childQuestionInfo[i].score,//真实得分
                            "scoreModels": scoreModels,
                            "realScore": childQuestionInfo[i].score,//题目原有得分
                            "oldScore": childQuestionInfo[i].studentScore,//真实得分
                            "childQuestionId": childQuestionInfo[i].id,//小题Id
                            "orderNumber": childQuestionInfo[i].orderNumber,//题目序号
                            "remarkUrl": childQuestionInfo[i].remarkUrl,
                            "remarkTime": childQuestionInfo[i].remarkTime,
                            "errorType": childQuestionInfo[i].errorType,
                            "errorTypeId": 0,
                            "questionType": childQuestionInfo[i].questionType,
                            "errorName": childQuestionInfo[i].errorName == null ? "" : childQuestionInfo[i].errorName,
                            "questionStatus": childQuestionInfo[i].isRight,//答案是否正确 0：错误，1：正确，2：半对半错
                            "isCompare": -1,//答案是否正确 0：错误，1：正确，2：半对半错
                            "correStatus": childQuestionInfo[i].status,
                            "isRight":childQuestionInfo[i].isRight,
                            "selected": false,
                            "checked": false,//是否进行过点击
                        });
        }
        if(childQuestionInfo.length == 0){
            var scoreModels = setScoreData(dataModel.score);
            workModel.append(
                        {
                            "id": dataModel.id,//对应题的Id
                            "score": dataModel.score,//真实得分
                            "scoreModels": scoreModels,
                            "realScore": dataModel.score,//题目原有得分
                            "oldScore": dataModel.studentScore,//真实得分
                            "childQuestionId": dataModel.id,//小题Id
                            "orderNumber": dataModel.orderNumber,//题目序号
                            "remarkUrl": dataModel.remarkUrl,
                            "remarkTime": dataModel.remarkTime,
                            "errorType": dataModel.errorType,
                            "errorTypeId": 0,
                            "questionType": dataModel.questionType,
                            "errorName": dataModel.errorName == null ? "" : dataModel.errorName,
                            "questionStatus": dataModel.isRight,//答案是否正确 0：错误，1：正确，2：半对半错
                            "isCompare": -1,//答案是否正确 0：错误，1：正确，2：半对半错
                            "correStatus": dataModel.status,
                            "isRight":dataModel.isRight,
                            "selected": false,//初始控件选中状态
                            "checked": false,//是否进行过点击
                        });
        }
    }

    function setScoreData(number){
        var scoreModels = [];
        scoreModels.push({"key": 0,"values": "请选分数" });
        for(var k = 1 ; k <= number; k++){
            scoreModels.push(
                        {
                            "key": k - 0.5,
                            "values": Number(k - 0.5) + "分",
                        });
            if(k != number){
                scoreModels.push(
                            {
                                "key": k,
                                "values": k.toString() + "分",
                            });
            }
        }
        return scoreModels;
    }

    ListView{
        id: homeworkListView
        clip: true
        width: parent.width
        height: 80 * heightRate * workModel.count
        delegate: homeWorkDelegate
        model: workModel
        boundsBehavior: ListView.StopAtBounds
    }

    //滚动条
    Item {
        id: scrollbar
        visible: false
        anchors.right: homeworkListView.right
        anchors.top: homeworkListView.top
        width: 8 * heightRate
        height:homeworkListView.height

        z: 23
        Rectangle{
            anchors.fill: parent
            color: "#eeeeee"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: homeworkListView.visibleArea.yPosition * scrollbar.height
            width: parent.width
            height: homeworkListView.visibleArea.heightRatio * scrollbar.height;
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
                    homeworkListView.contentY = button.y / scrollbar.height * homeworkListView.contentHeight
                }
            }
        }
    }

    //批改题型数据模型
    ListModel{
        id: workModel
    }

    //错因数据模型
    ListModel{
        id: wrongModel
    }

    Component{
        id: homeWorkDelegate
        Item{
            width: homeworkListView.width
            height: 80 * heightRate

            onHeightChanged: {
                if(workModel.count * 80 * heightRate > homeworkListView.height){
                    scrollbar.visible = true;
                }else{
                    scrollbar.visible = false;
                }
            }

            Row{
                width: parent.width
                height: parent.height
                spacing: 15 * heightRate
                z: 1

                Text {
                    text: (index + 1).toString()//orderNumber
                    width: 20 * heightRate
                    height: parent.height
                    font.pixelSize: 18 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                }

                //对题按钮
                MouseArea{
                    id: yesBut
                    hoverEnabled: true
                    width: 60 * heightRate
                    height: 60 * heightRate
                    cursorShape: Qt.PointingHandCursor
                    anchors.verticalCenter: parent.verticalCenter
                    enabled: questionType <= 3 ? false : true
                    visible: {
                        console.log("===undefined===",questionType,isRight,correStatus)
                        if(questionType <= 3){
                            return isRight != 0 ? true : false ;
                        }else{
                            if(model.correStatus == 2){
                                return true;
                            }

                            if(model.correStatus == 4){
                                if(isRight == 0){
                                    return false;
                                }
                                if(isRight == 1){
                                    return true;
                                }
                                if(isRight == 2){
                                    return false;
                                }
                            }
                            return true;
                        }
                    }

                    Image{
                        id: yesImg
                        anchors.fill: parent
                        source: {
                            if(questionType <= 3){
                                return "qrc:/cloudImage/pigai_dui_sed@2x.png"
                            }

                            if(isRight == 1 && isCompare == -1){
                                return "qrc:/cloudImage/pigai_dui_sed@2x.png"
                            }
                            return "qrc:/cloudImage/icon_dui@2x.png"
                        }
                    }

                    onClicked: {
                        questionStatus = 1;
                        if(isCompare == -1){
                            isCompare = 1;
                            checked = true;
                            yesImg.source = "qrc:/cloudImage/pigai_dui_sed@2x.png"
                            noBut.visible = false;
                            halfBut.visible = false;
                            commitTopicInfo(index);
                        }else{
                            isCompare = -1;
                            visible = true;
                            yesImg.source = "qrc:/cloudImage/icon_dui@2x.png"
                            noBut.visible = true;
                            halfBut.visible = true;
                        }
                    }
                }

                //错题按钮
                MouseArea{
                    id: noBut
                    hoverEnabled: true
                    width: 60 * heightRate
                    height: 60 * heightRate
                    cursorShape: Qt.PointingHandCursor
                    anchors.verticalCenter: parent.verticalCenter
                    enabled: questionType <= 3 ? false : true
                    visible: {
                        if(questionType <= 3){
                            return isRight != 0 ? false : true;
                        }else{
                            if(model.correStatus == 2){
                                return true;
                            }

                            if(model.correStatus == 4){
                                if(isRight == 0){
                                    return true;
                                }
                                if(isRight == 1){
                                    return false;
                                }
                                if(isRight == 2){
                                    return false;
                                }
                            }
                            return true;
                        }
                    }

                    Image{
                        id: noImg
                        anchors.fill: parent
                        source: {
                            if(isRight == 2){
                                return "qrc:/cloudImage/icon_cuo@2x.png";
                            }

                            if(isRight == 0){
                                if(questionType <= 3){
                                    return "qrc:/cloudImage/pigai_cuo_sed@2x.png";
                                }

                                if(correStatus == 2 || correStatus ==0){
                                    return "qrc:/cloudImage/icon_cuo@2x.png";
                                }
                                return "qrc:/cloudImage/pigai_cuo_sed@2x.png";
                            }
                            return "qrc:/cloudImage/icon_cuo@2x.png";

                        }
                    }

                    onClicked: {
                        if(isCompare == -1){
                            isCompare = 0;
                            yesBut.visible = false;
                            halfBut.visible = false;
                            noImg.source = "qrc:/cloudImage/pigai_cuo_sed@2x.png";
                            errorCombox.visible = true;
                            scoreCombox.visible =false;
                        }else{
                            isCompare = -1;
                            yesBut.visible = true;
                            halfBut.visible = true;
                            noImg.source = "qrc:/cloudImage/icon_cuo@2x.png";
                            scoreCombox.visible =false;
                            errorCombox.visible = false;
                        }
                        questionStatus = 0;
                    }
                }

                //半对题按钮
                MouseArea{
                    id: halfBut
                    hoverEnabled: true
                    width: 60 * heightRate
                    height: 60 * heightRate
                    cursorShape: Qt.PointingHandCursor
                    anchors.verticalCenter: parent.verticalCenter
                    visible: {
                        if(questionType <= 3){
                            return false
                        }
                        else{
                            if(model.correStatus == 2){
                                return true;
                            }

                            if(model.correStatus == 4){
                                if(isRight == 0){
                                    return false;
                                }
                                if(isRight == 1){
                                    return false;
                                }
                                if(isRight == 2){
                                    return true;
                                }
                            }
                            return true;
                        }
                    }
                    Image{
                        id: halfImg
                        anchors.fill: parent
                        source:{
                            if(model.correStatus == 2){
                                return "qrc:/cloudImage/icon_bandui@2x.png";
                            }
                            isRight == 2 ? "qrc:/cloudImage/pigai_bandui_sed@2x.png"  : "qrc:/cloudImage/icon_bandui@2x.png"
                        }
                    }

                    onClicked: {

                        if(isCompare == -1){
                            isCompare = 2;
                            noBut.visible = false;
                            yesBut.visible = false;
                            halfImg.source = "qrc:/cloudImage/pigai_bandui_sed@2x.png"
                            scoreCombox.visible =true;
                            errorCombox.visible = true;
                        }else{
                            isCompare = -1;
                            noBut.visible = true;
                            yesBut.visible = true;
                            halfImg.source = "qrc:/cloudImage/icon_bandui@2x.png"
                            scoreCombox.visible =false;
                            errorCombox.visible = false;
                        }
                        questionStatus = 2;
                    }
                }

                //得分控件
                YMComboBoxControl{
                    id: scoreCombox
                    z: 2

                    visible: {
                        //console.log("====index::value=====",index,correStatus )
                        if(correStatus == 2){
                            return false;
                        }
                        if(isCompare == 2 || isRight == 2){
                            return true;
                        }else{
                            return false;
                        }
                    }

                    width: 60 * widthRate
                    height: 30 * heightRate
                    model: scoreModels//scoreModel
                    textRole: "values"
                    anchors.verticalCenter: parent.verticalCenter
                    onCurrentIndexChanged: {                       
                        score = scoreModels.get(currentIndex).key;
                        console.log("=====**score**=======",score);
                    }
                }

                //错因控件
                YMComboBoxControl{
                    id: errorCombox
                    z: 3
                    visible: {
                        if(questionType <= 3){
                            return  isRight != 0 ? false : true ;
                        }
                        else{
                            console.log("********questionStatus*******",questionStatus,isRight);
                            if(isRight == 2 && correStatus == 4){
                                return true;
                            }

                            if(questionStatus == 1){
                                return false;
                            }
                            if(questionStatus == 0 && correStatus == 4){
                                return true;
                            }else{
                                return false;
                            }
                        }
                    }
                    width: 120 * heightRate
                    height: 30 * heightRate
                    model: wrongModel
                    textRole:  "values"
                    anchors.verticalCenter: parent.verticalCenter
                    onCurrentIndexChanged: {
                        console.log("====wrongModel=====",wrongModel.count,scoreModels.count);
                        if(errorCombox.currentIndex == 0){
                            return;
                        }

                        if(selected == false){
                            return;
                        }

                        errorTypeId = wrongModel.get(errorCombox.currentIndex).key;
                        errorType = wrongModel.get(errorCombox.currentIndex).key;
                        errorName = wrongModel.get(errorCombox.currentIndex).values;
                        commitTopicInfo(index);
                    }
                }

                property var errorNames: errorName;
                property double scores: oldScore;

                onErrorNamesChanged: {
                    for(var k = 0; k < wrongModel.count; k++){
                        var currentErrorName = wrongModel.get(k).values;
                        if(currentErrorName == errorNames){
                            errorCombox.currentIndex= k;
                            break;
                        }
                    }
                }

                onScoresChanged: {
                    for(var i = 0; i < scoreModels.count;i++){
                        if(scoreModels.get(i).key == scores){
                            scoreCombox.currentIndex = i;
                            break;
                        }
                    }
                }
            }

            Rectangle{
                width: parent.width - 20
                height: 1
                color: "#e0e0e0"
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Component.onCompleted: {
                selected = true;
            }
        }

    }

    //提交题目数据处理
    function commitTopicInfo(index){
        for(var i = 0; i < workModel.count; i ++){
            if(i == index){
                var questionId = workModel.get(i).id;
                var childQuestionIds = workModel.get(i).childQuestionId;
                var remarkUrl = workModel.get(i).remarkUrl;
                var remarkTime = workModel.get(i).remarkTime;
                var errorType = workModel.get(i).errorType;
                var errorTypeId = workModel.get(i).errorTypeId;
                var errorName =  workModel.get(i).errorName;
                var score = workModel.get(i).score;
                var questionStatus = workModel.get(i).questionStatus;

                console.log("=====commitTopicInfo::childQuestionIds========",questionId,"childQuestionId:" +childQuestionIds,score);

                var sendData = {
                    "questionId": questionId,
                    "childQuestionId": childQuestionIds,
                    "remarkUrl": remarkUrl,
                    "remarkTime": remarkTime,
                    "errorType": errorType,
                    "errorTypeId": errorTypeId,
                    "errorName": errorName,
                    "score": score,
                    "questionStatus": questionStatus,//答案是否正确 0：错误，1：正确，2：半对半错
                }
                sigCommitTopicComand(questionId,childQuestionIds,questionStatus,score,errorName,errorTypeId);
                console.log("=====commitTopicInfo========",score,JSON.stringify(sendData));
                sigCommitTopic(sendData);
                break;
            }
        }
    }

    //错因处理
    function updateErrorList(dataObject){
        wrongModel.clear();
        wrongModel.append({"key": 0,"values": "请您选择错因"});
        if(dataObject == {}  || dataObject == undefined){
            return;
        }

        for(var z = 0; z < dataObject.length; z++){
            wrongModel.append(
                        {
                            "key": dataObject[z].id,
                            "values": dataObject[z].name,
                        });
        }
    }

    //是否有错因
    function isErrorList(){
        return wrongModel.count;
    }
}

