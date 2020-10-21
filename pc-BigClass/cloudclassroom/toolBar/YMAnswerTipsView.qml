import QtQuick 2.0
import "./Configuration.js" as Cfg

/*
*学生作答提醒页面
*/

Item {
    id: answerTipsView
    width: 600 * heightRate
    height: 600 * heightRate

    property string answerCorrect: "H";//正确答案

    onVisibleChanged: {
        if(visible){
            tipsTimer.restart();
        }
    }

    Timer{
        id: tipsTimer
        interval: 3000
        repeat: false
        running: false
        onTriggered: {
            hideView();
        }
    }

    Image{//时间到
        id: timeOut
        width: 554 * heightRate
        height: 118 * heightRate
        source: "qrc:/AnswerImg/sjdl.png"
        visible: false
        anchors.centerIn: parent
        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 36 * heightRate
            color: "#ffffff"
            text: answerCorrect
            anchors.left: parent.left
            anchors.leftMargin: 208 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 12 * heightRate
        }
    }

    Image{//答题错误
        id: answerError
        width: 562 * heightRate
        height: 152 * heightRate
        source: "qrc:/AnswerImg/cuowu.png"
        visible: false
        anchors.centerIn: parent
        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 36 * heightRate
            color: "#ffffff"
            text: answerCorrect
            anchors.left: parent.left
            anchors.leftMargin: 208 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 48 * heightRate
        }
    }

    Image{//老师提前结束答题
        id:teaOverAnswer
        width: 512 * heightRate
        height: 124 * heightRate
        source: "qrc:/AnswerImg/tqjs.png"
        visible: false
        anchors.centerIn: parent
        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 36 * heightRate
            color: "#ffffff"
            text: answerCorrect
            anchors.left: parent.left
            anchors.leftMargin: 208 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 20 * heightRate
        }
    }

    Image{//答题正确
        id: correctOk
        width: 518 * heightRate
        height: 112 * heightRate
        source: "qrc:/AnswerImg/zhengque.png"
        visible: false
        anchors.centerIn: parent
    }

    Image{//老师取消
        id: teaCancel
        width: 392 * heightRate
        height: 112 * heightRate
        source: "qrc:/AnswerImg/qxdt.png"
        visible: false
        anchors.centerIn: parent
    }

    //隐藏所有页面
    function hideView(){
        teaCancel.visible = false;
        correctOk.visible = false;
        teaOverAnswer.visible = false;
        answerError.visible = false;
        timeOut.visible = false;
        answerTipsView.visible = false;
    }

    //超时显示页面
    function showTimeOut(){
        hideView();
        answerTipsView.visible = true;
        timeOut.visible = true;
    }

    //答题错误显示
    function showAnswerError(){
        hideView();
        answerTipsView.visible = true;
        answerError.visible = true;
    }

    //老师结束答题
    function showTeaOverAnswer(){
        hideView();
        answerTipsView.visible = true;
        teaOverAnswer.visible = true;
    }

    //正确提醒
    function showCorrectOk(){
        hideView();
        answerTipsView.visible = true;
        correctOk.visible = true;
    }

    //老师取消提醒
    function showTeaCancel(){
        hideView();
        answerTipsView.visible = true;
        teaCancel.visible = true;
    }
}
