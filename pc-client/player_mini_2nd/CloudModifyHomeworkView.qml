import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuuration.js" as Cfg
import QtQuick.Controls.Styles 1.4

/*
 *批改页面  不能直接覆盖！
 */

Popup {

    property bool isVisbles: false;
    property var hasDoneQuestionList: [];//缓存已批改题型
    width: 400 * heightRate
    height: parent.height
    background: Image{
        anchors.fill: parent
        source: "qrc:/cloudImage/pigaizuoyebeijing@3x.png"
    }
    closePolicy: Popup.NoAutoClose
    MouseArea{
        anchors.fill: parent
        z:10
        onClicked: {
            return;
        }
    }

    property var dataModel: [];
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
        var errorData = {};
        updateErrorList(errorData);
        console.log("dataModel.score",dataModel.score)

        var childQuestionInfo = dataModel.childQuestionInfo;
        if(dataModel.childQuestionInfo == undefined){childQuestionInfo = [];}
        //console.log("========Modify::dataModel==========",dataModel,dataModel.childQuestionInfo)
        if(childQuestionInfo.length == 0 ||dataModel.childQuestionInfo == [] || dataModel.childQuestionInfo == undefined){
            workModel.append(
                        {
                            "id": dataModel.id,//对应题的Id
                            "score": dataModel.studentScore,//得分
                            "childQuestionId": "",//小题Id
                            "orderNumber": dataModel.orderNumber,
                            "remarkUrl": dataModel.remarkUrl,
                            "remarkTime": dataModel.remarkTime,
                            "errorType": dataModel.errorType,
                            "errorTypeId": 0,
                            "correStatus": dataModel.status,
                            "questionType": dataModel.questionType,
                            "errorName": dataModel.errorName == null ? "" : dataModel.errorName,
                                                                       "questionStatus": -1,//答案是否正确 0：错误，1：正确，2：半对半错
                                                                       "isCompare": dataModel.isRight,//答案是否正确 0：错误，1：正确，2：半对半错
                                                                       "isOk": false,//是否确认
                                                                       "isRight":dataModel.isRight
                        });
            updateScore(dataModel.score);
            console.log("=======errorName======",dataModel.errorName);
            return;
        }


        console.log("**************Modify::dataModel************",childQuestionInfo.length);
        for(var i = 0; i < childQuestionInfo.length; i++){
            workModel.append(
                        {
                            "id": dataModel.id,//对应题的Id
                            "score": childQuestionInfo[i].studentScore,//得分
                            "childQuestionId": childQuestionInfo[i].id,//小题Id
                            "orderNumber": childQuestionInfo[i].orderNumber,//题目序号
                            "remarkUrl": childQuestionInfo[i].remarkUrl,
                            "remarkTime": childQuestionInfo[i].remarkTime,
                            "errorType": childQuestionInfo[i].errorType,
                            "errorTypeId": 0,
                            "correStatus": childQuestionInfo[i].status,
                            "questionType": childQuestionInfo[i].questionType,
                            "errorName": childQuestionInfo[i].errorName == null ? "" : childQuestionInfo[i].errorName,
                                                                                  "questionStatus": -1,//答案是否正确 0：错误，1：正确，2：半对半错
                                                                                  "isCompare": childQuestionInfo[i].isRight,//答案是否正确 0：错误，1：正确，2：半对半错
                                                                                  "isOk": false,//是否确认
                                                                                  "isRight":childQuestionInfo[i].isRight
                        });
            console.log("**************question type************",childQuestionInfo[i].isRight, childQuestionInfo[i].questionType);

        }
        if(childQuestionInfo.length == 0){
            workModel.append(
                        {
                            "id": dataModel.id,//对应题的Id
                            "score": dataModel.studentScore,//得分
                            "childQuestionId": dataModel.id,//小题Id
                            "orderNumber": dataModel.orderNumber,//题目序号
                            "remarkUrl": dataModel.remarkUrl,
                            "remarkTime": dataModel.remarkTime,
                            "errorType": dataModel.errorType,
                            "errorTypeId": 0,
                            "correStatus": dataModel.status,
                            "questionType": dataModel.questionType,
                            "errorName": dataModel.errorName == null ? "" : dataModel.errorName,
                                                                       "questionStatus": -1,//答案是否正确 0：错误，1：正确，2：半对半错
                                                                       "isCompare": dataModel.isRight,//答案是否正确 0：错误，1：正确，2：半对半错
                                                                       "isOk": false,//是否确认
                                                                       "isRight":dataModel.isRight
                        });
        }



    }

    ListView{
        id: homeworkListView
        clip: true
        anchors.fill: parent
        delegate: homeWorkDelegate
        model: workModel
    }

    //滚动条
    Item {
        id: scrollbar
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

    //得分数据模型
    ListModel{
        id: scoreModel
    }

    //错因数据模型
    ListModel{
        id: wrongModel
    }

    Component{
        id: homeWorkDelegate
        Rectangle{
            width: homeworkListView.width
            height: 80 * heightRate

            onHeightChanged: {
                if(workModel.count * 80 * heightRate > homeworkListView.height){
                    scrollbar.visible = true;
                }else{
                    scrollbar.visible = false;
                }
            }

            property double scores: model.score;

            onScoresChanged: {
                var scoresPram  = scores == 0 ? 5  : scores;
                updateScore(scoresPram);
            }

            Row{
                width: parent.width
                height: parent.height
                spacing: 10 * heightRate
                z: 1

                Text {
                    text: (index + 1).toString()//orderNumbe
                    width: 20 * heightRate
                    height: parent.height
                    font.pixelSize: 18 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                }

                //对题按钮
                MouseArea{
                    id:rightButton
                    hoverEnabled: true
                    width: 60 * heightRate
                    height: 60 * heightRate
                    cursorShape: Qt.PointingHandCursor
                    anchors.verticalCenter: parent.verticalCenter
                    visible: questionType <= 3 ? ( isRight != 0 ? true : false ) : correStatus == 4 ? ( isCompare == -1 ? false : isCompare == 1 ? true : false) : true
                    enabled: !isOk

                    Image{
                        anchors.fill: parent
                        source: isCompare == 1 ? "qrc:/cloudImage/pigai_dui_sed@2x.png" : "qrc:/cloudImage/icon_dui@2x.png"
                    }

                    onClicked: {
                        if(isCompare == -1){
                            isCompare = 1;
                        }else{
                            isCompare = -1;
                        }
                        questionStatus = 1;
                        commitTopicInfo(index);
                    }
                }

                //错题按钮
                MouseArea{
                    hoverEnabled: true
                    width: 60 * heightRate
                    height: 60 * heightRate
                    cursorShape: Qt.PointingHandCursor
                    anchors.verticalCenter: parent.verticalCenter
                    visible: questionType <= 3 ? ( isRight != 0 ? false : true ) : correStatus == 4 ? (isCompare == -1 ? false : isCompare == 0 ? true : false) : true

                    Image{
                        anchors.fill: parent
                        source:{
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
                            //isCompare == 0 ? "qrc:/cloudImage/pigai_cuo_sed@2x.png" : "qrc:/cloudImage/icon_cuo@2x.png"
                    }

                    onClicked: {
                        if(isCompare == -1){
                            isCompare = 0;
                        }else{
                            isCompare = -1;
                        }
                        questionStatus = 0;
                    }
                }

                //半对题按钮
                MouseArea{
                    hoverEnabled: true
                    width: 60 * heightRate
                    height: 60 * heightRate
                    cursorShape: Qt.PointingHandCursor
                    anchors.verticalCenter: parent.verticalCenter
                    visible:questionType <= 3 ? false : correStatus == 4 ? ( isCompare == -1 ? false : isCompare == 2 ? true : false ) : true

                    Image{
                        anchors.fill: parent
                        source:  isCompare == 2 ? "qrc:/cloudImage/pigai_bandui_sed@2x.png" :  "qrc:/cloudImage/icon_bandui@2x.png"
                    }
                    onClicked: {
                        if(isCompare == -1){
                            isCompare = 2;
                        }else{
                            isCompare = -1;
                        }
                        questionStatus = 2;
                        commitTopicInfo(index);
                    }
                }

                //得分控件
                Rectangle{////YMComboBoxControl2
                    id: scoreCombox
                    z: 3
                    visible: isCompare == 2 ? true : false
                    width: 120 * heightRate
                    height: 30 * heightRate
                    // model: scoreModel
                    //textRole: "values"
                    anchors.verticalCenter: parent.verticalCenter
                    // currentText: errorName;
                    Text {
                        anchors.centerIn: parent
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        wrapMode: Text.WordWrap
                        text: Number(score) + "分"//覆盖时注意
                    }

                }

                //错因控件
                Rectangle{ //YMComboBoxControl2
                    id: errorCombox
                    z: 3
                    visible: errorName == "" ? false : rightButton.visible ? false : true //: ( isCompare == 2 || isCompare == 0 ? true : false ) //(isOk == false ?  true  : false) : false
                    width: errorText .width >  120 * heightRate ? errorText .width + 5 * heightRate : 120 * heightRate
                    height: 30 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 2 * heightRate
                    //border.width: 1
                    //border.color: "#c3c6c9"
                    Text {
                        id:errorText
                        anchors.centerIn: parent
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        wrapMode: Text.WordWrap
                        text: errorName
                    }
                    //currentText: score;

                }
            }

            Rectangle{
                width: parent.width - 20
                height: 1
                color: "#e0e0e0"
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }
    }

    //提交题目数据处理
    function commitTopicInfo(index){
        for(var i = 0; i < workModel.count; i ++){
            if(i == index){
                var questionId = workModel.get(i).id;
                var childQuestionId = workModel.get(i).childQuestionId;
                var remarkUrl = workModel.get(i).remarkUrl;
                var remarkTime = workModel.get(i).remarkTime;
                var errorType = workModel.get(i).questionStatus;
                var errorTypeId = workModel.get(i).errorTypeId;
                var errorName =  workModel.get(i).errorName;
                var score = workModel.get(i).score;
                var questionStatus = workModel.get(i).questionStatus;

                var sendData = {
                    "questionId": questionId,
                    "childQuestionId": childQuestionId,
                    "remarkUrl": remarkUrl,
                    "remarkTime": remarkTime,
                    "errorType": errorType,
                    "errorTypeId": errorTypeId,
                    "errorName": errorName,
                    "score": score,
                    "questionStatus": questionStatus,//答案是否正确 0：错误，1：正确，2：半对半错
                }
                // sigCommitTopicComand(questionId,childQuestionId,questionStatus,score,errorName,errorTypeId);
                console.log("=====commitTopicInfo========",JSON.stringify(sendData));
                // sigCommitTopic(sendData);
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
            //console.log("======dataObject::id=====",dataObject[z].id,dataObject[z].name)
            wrongModel.append(
                        {
                            "key": dataObject[z].id,
                            "values": dataObject[z].name,
                        });
        }
    }
    //分数处理
    function updateScore(number){
        scoreModel.clear();
        scoreModel.append({"key": 0,"values": "请选得分"});
        if(number == null || number == 0){
            return;
        }


        for(var k = 1 ; k <= number; k++){
            //console.log("======dataObject::id=====",k);
            scoreModel.append(
                        {
                            "key": k,
                            "values": k.toString() + "分",
                        });
        }
    }

    //批改面板更新老师批改
    function resetModifyView(questionData)
    {
        console.log("批改面板更新老师批改界面",questionData.score)

        var questionId = questionData.questionId;
        var childQuestionId = questionData.childQuestionId ;
        //var remarkUrl = workModel.get(i).remarkUrl;
        //var remarkTime = workModel.get(i).remarkTime;
        //var errorType = workModel.get(i).questionStatus;
        //var errorTypeId = workModel.get(i).errorTypeId;
        //var errorName =  workModel.get(i).errorName;
        var score = parseFloat(questionData.score);
        if(questionId != dataModel.id )
        {
            dataModel = questionData;
            return;
        }
        var questionStatus = parseInt(questionData.correctType);
        console.log("questionStatus = parseInt(",questionStatus)

        for(var  i = 0 ; i<workModel.count; i++)
        {
            console.log("判断id是否相同  1 ",score,questionId,dataModel.id,questionStatus,childQuestionId)
            if(questionId == dataModel.id )
            {
                if( workModel.get(i).childQuestionId == "" || childQuestionId == null )
                {
                    workModel.get(i).isCompare = questionStatus;
                    workModel.get(i).score = score;
                    workModel.get(i).errorName = questionData.errorReason;
                    workModel.get(i).correStatus = 4;
                    console.log(workModel.get(i).isCompare,"workModel.1111get(i)",workModel.get(i).errorName)
                    break;
                } else
                {
                    //判断子节点id是否相同
                    if(childQuestionId == workModel.get(i).childQuestionId)
                    {
                        workModel.get(i).isCompare = questionStatus;
                        workModel.get(i).score = score;
                        workModel.get(i).errorName = questionData.errorReason;
                        workModel.get(i).correStatus = 4;
                        console.log(workModel.get(i).isCompare,"workModel.get(i)2222",workModel.get(i).errorName)
                        break;
                    }
                }
            }

        }
    }

    function resetErrorName(childQId)
    {
        var hasSave = 0;
        for(var a = 0; a < hasDoneQuestionList.length ; a++)
        {
            var tempList = hasDoneQuestionList[a].questionData;

            console.log("/此题是否已经存在",tempList,tempList[0],tempList[1])
            //此题是否已经存在
            if( tempList[0] == childQId )
            {
                tempList[1] = studentSelectAnswer;
                tempList[2] = useTime;
                tempList[3] = imageUrlList;//图片的信息
                tempList[4] = orderNumber;
                hasSave = 1;
                hasDoneQuestionList[a] = ({"questionData":tempList});
                break;
            }
        }
        if(hasSave == 0)
        {
            var tempBufferList = [];
            tempBufferList.push(childQId);
            tempBufferList.push(studentSelectAnswer);
            tempBufferList.push(useTime);
            tempBufferList.push(imageUrlList);
            tempBufferList.push(orderNumber);
            hasDoneQuestionList.push({"questionData":tempBufferList});
        }
    }

}

