import QtQuick 2.0
import "./Configuration.js" as Cfg

/*
*学生答题页面
*/
Rectangle {
    id: stuAnswerViews
    width: 414 * heightRate
    height: 308 * heightRate
    color: "#474A5B"

    property string currentDownTime: "00:20"
    property int countDownTime: 20;
    property bool isCheck: false;
    property bool isStartTopic: false;
    property string correctAnswer: "";//设置正确答案
    property string selecteAnswer: "";//选择正确答案

    signal sigSubmitAnswer(var correctAnswer,var selecteAnswer,var answerTime,var isCorrect);//提交答案是否正确
    signal sigTimerOut();

    onVisibleChanged: {
        if(visible){
            clearStatus();
            downTime.restart();
        }
    }

    //倒计时定时器
    Timer{
        id: downTime
        interval: 1000
        repeat: true
        running: false
        onTriggered: {
            countDownTime--;
            startCountDown(countDownTime);
            if(countDownTime == 0){
                sigTimerOut();
                downTime.stop();
                stuAnswerViews.visible = false;
            }
        }
    }

    Rectangle{
        id: headRec
        width: parent.width
        height: 42 * heightRate
        color: "#3D3F4E"

        Text {
            font.pixelSize: 20 * heightRate
            font.family: Cfg.DEFAULT_FONT
            color: "#ffffff"
            text: qsTr("倒计时 ") + currentDownTime
            anchors.centerIn: parent
        }

        Rectangle{
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
            color: "#4D90FF"
        }
    }

    ListView{
        id: answerListview
        width: parent.width - 70 * heightRate
        height: parent.height - headRec.height
        anchors.top: headRec.bottom
        anchors.topMargin: 22 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        model: answerModel
        delegate: answerComponent
        boundsBehavior: ListView.StopAtBounds
    }

    MouseArea{
        width: 252 * heightRate
        height: 42 * heightRate
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 26 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: isCheck

        Rectangle{
            anchors.fill: parent
            color: "#373A49"
            border.color: "#ffffff"
            border.width: 1
        }

        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            color:  isCheck ? "#ffffff" : "#646881"
            text: qsTr("提交答案")
            anchors.centerIn: parent
        }

        onClicked: {
            var isOk = selecteAnswer == correctAnswer ? true : false;
            sigSubmitAnswer(correctAnswer,selecteAnswer,countDownTime,isOk);
            stuAnswerViews.visible = false;
            isStartTopic = true;
            downTime.stop();
        }
    }

    ListModel{
        id: answerModel
    }

    Component{
        id: answerComponent
        Item{
            width: answerListview.width
            height: 340 * heightRate

            Column{
                width: answerListview.width
                height: parent.height
                spacing: 20 * heightRate

                //A-D
                Row{
                    width: parent.width
                    spacing: 28 * heightRate

                    YMAnswerButton{
                        number: "A"
                        isSelected: checkA
                        onSigSelected: {
                            updateSelecteStatus(mumber,isCheckAnswer);
                        }
                    }

                    YMAnswerButton{
                        number: "B"
                        isSelected: checkB
                        onSigSelected: {
                            updateSelecteStatus(mumber,isCheckAnswer);
                        }
                    }

                    YMAnswerButton{
                        number: numberC
                        isSelected: checkC
                        onSigAdd: {
                            addNumber();
                        }
                        onSigSub: {
                            subNumber();
                        }
                        onSigSelected: {
                            updateSelecteStatus(mumber,isCheckAnswer);
                        }
                    }

                    YMAnswerButton{
                        number: numberD
                        isSelected: checkD
                        onSigAdd: {
                            addNumber();
                        }
                        onSigSub: {
                            subNumber();
                        }
                        onSigSelected: {
                            updateSelecteStatus(mumber,isCheckAnswer);
                        }
                    }
                }

                //E-H
                Row{
                    width: parent.width
                    spacing: 28 * heightRate

                    YMAnswerButton{
                        number: numberE
                        isSelected: checkE
                        onSigAdd: {
                            addNumber();
                        }
                        onSigSub: {
                            subNumber();
                        }
                        onSigSelected: {
                            updateSelecteStatus(mumber,isCheckAnswer);
                        }
                    }

                    YMAnswerButton{
                        number: numberF
                        isSelected: checkF
                        onSigAdd: {
                            addNumber();
                        }
                        onSigSub: {
                            subNumber();
                        }
                        onSigSelected: {
                            updateSelecteStatus(mumber,isCheckAnswer);
                        }
                    }

                    YMAnswerButton{
                        number: numberG
                        isSelected: checkG
                        onSigAdd: {
                            addNumber();
                        }
                        onSigSub: {
                            subNumber();
                        }
                        onSigSelected: {
                            updateSelecteStatus(mumber,isCheckAnswer);
                        }
                    }

                    YMAnswerButton{
                        number: numberH
                        isSelected: checkH
                        onSigAdd: {
                            addNumber();
                        }
                        onSigSub: {
                            subNumber();
                        }
                        onSigSelected: {
                            updateSelecteStatus(mumber,isCheckAnswer);
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        answerModel.append(
                    {
                        "numberC": "",
                        "numberD": "",
                        "numberE": "",
                        "numberF": "",
                        "numberG": "",
                        "numberH": "",
                        "checkA": false,
                        "checkB": false,
                        "checkC": false,
                        "checkD": false,
                        "checkE": false,
                        "checkF": false,
                        "checkG": false,
                        "checkH": false
                    });
    }

    //修改选中按钮
    function updateSelecteStatus(No,isSelected){
        clearStatus();
        isCheck = isSelected;
        selecteAnswer = No;
        if(No == "A"){
            answerModel.get(0).checkA = isSelected;
        }
        if(No == "B"){
            answerModel.get(0).checkB = isSelected;
        }
        if(No == "C"){
            answerModel.get(0).checkC = isSelected;
        }
        if(No == "D"){
            answerModel.get(0).checkD = isSelected;
        }
        if(No == "E"){
            answerModel.get(0).checkE = isSelected;
        }
        if(No == "F"){
            answerModel.get(0).checkF = isSelected;
        }
        if(No == "G"){
            answerModel.get(0).checkG = isSelected;
        }
        if(No == "H"){
            answerModel.get(0).checkH = isSelected;
        }
    }

    //清除按钮所有状态
    function clearStatus(){
        isCheck = false;
        selecteAnswer = "";
        isStartTopic = false;
        answerModel.get(0).checkA = false;
        answerModel.get(0).checkB = false;
        answerModel.get(0).checkC = false;
        answerModel.get(0).checkD = false;
        answerModel.get(0).checkE = false;
        answerModel.get(0).checkF = false;
        answerModel.get(0).checkG = false;
        answerModel.get(0).checkH = false;
    }

    function updateButton(itemObj){
        for(var i = 0; i < itemObj.length;i++){
            answerModel.get(0).numberC = i == 2 ? itemObj[i] : answerModel.get(0).numberC;
            answerModel.get(0).numberD = i == 3 ? itemObj[i] : answerModel.get(0).numberD;
            answerModel.get(0).numberE = i == 4 ? itemObj[i] : answerModel.get(0).numberE;
            answerModel.get(0).numberF = i ==  5 ? itemObj[i] : answerModel.get(0).numberF;
            answerModel.get(0).numberG = i == 6 ? itemObj[i] : answerModel.get(0).numberG;
            answerModel.get(0).numberH = i == 7 ? itemObj[i] : answerModel.get(0).numberH;
        }
    }

    //倒计时设置时间
    function startCountDown(values){
        var minute = parseInt(values / 60);//分
        var second = values % 60;//秒

        var mTen = parseInt(minute / 10);//分钟取十位
        var mOne = minute % 10;//分钟取个位

        var sTen = parseInt(second / 10);//秒取十位
        var sOne = second % 10;//秒取个位

        currentDownTime = mTen.toString()+ mOne.toString() + ":" + sTen.toString() + sOne.toString();
    }
}
