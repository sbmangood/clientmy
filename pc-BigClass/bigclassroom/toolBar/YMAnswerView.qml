import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import "./Configuration.js" as Cfg

/*
* 答题器页面
*/

Rectangle {
    id: answerView
    width: 440 * heightRate
    height: 420 * heightRate
    color: "#474A5B"
    radius: 8 * heightRate

    property bool isStartTopic: false;//是否开始答题状态
    property bool isCheck: false;//是否选择正确答案
    property string answerText: "";
    property var answerItem: ["A","B","C"];

    signal sigStartTopic(var answerText,var answerArray,var downTime);//开始答题信号

    MouseArea{
        anchors.fill: parent
        onClicked: {
        }
    }

    //head bar
    MouseArea{
        width: parent.width
        height: 48 * heightRate

        Rectangle{
            anchors.fill: parent
            color: "#474a5b"
            radius: 8 * heightRate
        }

        property point clickPos: "0,0"

        onPressed: {
            clickPos  = Qt.point(mouse.x,mouse.y)
        }

        onPositionChanged: {
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
            var moveX = answerView.x + delta.x;
            var moveY = answerView.y + delta.y;
            var moveWidth = answerView.parent.width - answerView.width;
            var moveHeight = answerView.parent.height - answerView.height;

            if( moveX > 0 && moveX < moveWidth) {
                answerView.x = answerView.x + delta.x;
            }else{
                var loactionX = moveX < 0 ? 0 : (moveX > moveWidth ? moveWidth : moveX);
                answerView.x = loactionX;
            }

            if(moveY  > 0 && moveY < moveHeight){
                answerView.y = answerView.y + delta.y;
            }else{
                answerView.y = moveY < 0 ? 0 : (moveY > moveHeight ? moveHeight : moveY);
            }
        }

        Text {
            anchors.centerIn: parent
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 22 * heightRate
            text: qsTr("答题器")
            color: "#ffffff"
        }

        MouseArea{
            width: 42 * heightRate
            height: 42 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8 * heightRate
            cursorShape: Qt.PointingHandCursor

            Text {
                font.bold: true
                font.pixelSize: 26 * heightRate
                font.family: Cfg.DEFAULT_FONT
                text: isStartTopic == false ? qsTr("×") : "一"
                anchors.centerIn: parent
                color: "#ffffff"
            }

            onClicked: {
                answerView.visible = false;
            }
        }

        Rectangle{
            width: parent.width
            height: 1
            color: "#4D90FF"
            anchors.bottom: parent.bottom
        }
    }

    //按钮栏
    Item{
        width: parent.width - 80 * heightRate
        height: parent.height - 40 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 60 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            id: tipsTxt
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            color: "#ffffff"
            text: "点击字母设置正确答案"
        }

        ListView{
            id: answerListview
            width: parent.width
            height: 320 * heightRate
            anchors.top: tipsTxt.bottom
            anchors.topMargin: 20 * heightRate
            model: answerModel
            delegate: answerComponent
            boundsBehavior: ListView.StopAtBounds
        }

        ListModel{
            id: answerModel
        }

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

                //+ -
                Row{
                    width: parent.width
                    spacing: 28 * heightRate

                    YMAnswerButton{
                        number: add
                        onSigAdd: {
                            addNumber();
                        }
                        onSigSub: {
                            subNumber();
                        }
                    }

                    YMAnswerButton{
                        number: sub
                        onSigAdd: {
                            addNumber();
                        }
                        onSigSub: {
                            subNumber();
                        }
                    }
                }

                Row{
                    id: settingRow
                    width: parent.width
                    height: 68 * heightRate
                    spacing: 20 * heightRate
                    Text {
                        text: qsTr("设置时间：")
                        color: "#ffffff"
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 16 * heightRate
                        anchors.verticalCenter: parent.verticalCenter
                    }

                   TextField{
                       id: timerField
                        width: 180 * heightRate
                        height: 40 * heightRate
                        selectByMouse: true
                        selectionColor: "blue"
                        text : "20"
                        color: "#8A8B9B"
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        maximumLength: 3
                        validator: RegExpValidator{regExp: /^[0-9]+$/ }
                        anchors.verticalCenter: parent.verticalCenter
                        onTextChanged: {
                            if(parseInt(text) > 300){
                                return text = "300";
                            }
                            if(parseInt(text) == 0){
                                return text = "20";
                            }
                        }
                        background: Rectangle{
                            color: "#363847"
                            radius: 4 * heightRate
                        }

                    }

                    Text {
                        text: qsTr("S")
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 16 * heightRate
                        font.bold: true
                        width:  32 * heightRate
                        color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                    }      
                }

                MouseArea{
                    width: 176* heightRate
                    height: 42 * heightRate
                    cursorShape: Qt.PointingHandCursor
                    anchors.horizontalCenter: parent.horizontalCenter
                    enabled: (parseInt(timerField.text) == 0 || timerField.text == ""  || isCheck == false) ? false : true

                    Rectangle{
                        anchors.fill: parent
                        border.color: parent.enabled ? "#ffffff" : "#727797"
                        border.width: 1
                        radius: 4 * heightRate
                        color: parent.pressed ? "#ffffff" : "#474A5B"
                    }

                    Text {
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 16
                        anchors.centerIn: parent
                        color: parent.enabled ? "#ffffff" : "#727797"
                        text: qsTr("开始答题")
                    }

                    onClicked: {
                        var downTime = parseInt(timerField.text);
                        sigStartTopic(answerText,answerItem,downTime);
                        timerField.text = "20";
                        answerView.visible = false;
                    }
                }
            }

        }

    }

    Component.onCompleted: {
        answerModel.append(
                    {
                        "numberC": "C",
                        "numberD": "+",
                        "numberE": "一",
                        "numberF": "",
                        "numberG": "",
                        "numberH": "",
                        "add": "",
                        "sub": "",
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

    //加一个字母
    function addNumber(){
        clearStatus();
        if(answerModel.get(0).numberC == "+"){
            answerModel.get(0).numberC = "C";
            answerModel.get(0).numberD = "+";
            answerModel.get(0).numberE = "一";
            answerView.height = 450 * heightRate;
            answerItem = ["A","B","C"];
        }
        else if(answerModel.get(0).numberD == "+"){
            answerModel.get(0).numberD = "D";
            answerModel.get(0).numberE = "+";
            answerModel.get(0).numberF = "一";
            answerItem = ["A","B","C","D"];
        }
        else if(answerModel.get(0).numberE == "+"){
            answerModel.get(0).numberE = "E";
            answerModel.get(0).numberF = "+";
            answerModel.get(0).numberG = "一";
            answerItem = ["A","B","C","D","E"];
        }
        else if(answerModel.get(0).numberF == "+"){
            answerModel.get(0).numberF = "F";
            answerModel.get(0).numberG = "+";
            answerModel.get(0).numberH = "一";
            answerItem = ["A","B","C","D","E","F"];
        }
        else if(answerModel.get(0).numberG == "+"){
            answerModel.get(0).numberG = "G";
            answerModel.get(0).numberH = "+"
            answerModel.get(0).add = "一";
            answerView.height = 500 * heightRate;
            answerItem = ["A","B","C","D","E","F","G"];
        }
        else if(answerModel.get(0).numberH == "+"){
            answerModel.get(0).numberH = "H";
            answerModel.get(0).add = "+";
            answerModel.get(0).sub = "一";
            answerItem = ["A","B","C","D","E","F","G","H"];
        }
    }

    //减去一个字母
    function subNumber(){
        clearStatus();
        if(answerModel.get(0).sub == "一"){
            answerModel.get(0).sub = "";
            answerModel.get(0).numberH = "+"
            answerModel.get(0).add = "一";
            answerItem = ["A","B","C","D","E","F","G"];
        }
        else if(answerModel.get(0).add == "一"){
            answerModel.get(0).add = "";
            answerModel.get(0).numberG = "+";
            answerModel.get(0).numberH = "一"
            answerView.height = 450 * heightRate;
            answerItem = ["A","B","C","D","E","F"];
        }
        else if(answerModel.get(0).numberH == "一"){
            answerModel.get(0).numberH = "";
            answerModel.get(0).numberF = "+";
            answerModel.get(0).numberG = "一";
            answerItem = ["A","B","C","D","E"];
        }
        else if(answerModel.get(0).numberG == "一"){
            answerModel.get(0).numberG = "";
            answerModel.get(0).numberE = "+";
            answerModel.get(0).numberF = "一"
            answerItem = ["A","B","C","D"];
        }
        else if(answerModel.get(0).numberF == "一"){
            answerModel.get(0).numberF = "";
            answerModel.get(0).numberD = "+";
            answerModel.get(0).numberE = "一"
            answerView.height = 420 * heightRate;
            answerItem = ["A","B","C"];
        }
        else if(answerModel.get(0).numberE == "一"){
            answerModel.get(0).numberE = "";
            answerModel.get(0).numberC = "+";
            answerModel.get(0).numberD = "一"
            answerView.height = 380 * heightRate;
            answerItem = ["A","B"];
        }
    }

    //修改选中按钮
    function updateSelecteStatus(No,isSelected){
        clearStatus();
        isCheck = isSelected;
        answerText = No;
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
        answerModel.get(0).checkA = false;
        answerModel.get(0).checkB = false;
        answerModel.get(0).checkC = false;
        answerModel.get(0).checkD = false;
        answerModel.get(0).checkE = false;
        answerModel.get(0).checkF = false;
        answerModel.get(0).checkG = false;
        answerModel.get(0).checkH = false;
    }

    //还原
    function resetStatus(){

        answerModel.clear();
        answerModel.append(
                    {
                        "numberC": "C",
                        "numberD": "+",
                        "numberE": "一",
                        "numberF": "",
                        "numberG": "",
                        "numberH": "",
                        "add": "",
                        "sub": "",
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

}
