import QtQuick 2.0
import "./Configuuration.js" as Cfg

/*
*开始上课提醒小窗口
*/

Rectangle {
    width: 136 * heightRate
    height: 114 * heightRate
    radius: 10 * heightRate

    Rectangle{
        id: opacityView
        anchors.fill: parent
        radius: 10 * heightRate
        border.color: "#ff5000"
        border.width: 2 * heightRate
    }

    property string currentTimer: "00:00";
    property int totalTime: 0;
    property bool isStartLesson: false;//是否上过课

    signal sigStartLesson(var status);//是否开始上课还是立即上课信号


    Text {
        id: text1
        text: qsTr("距离上课还有")
        font.pixelSize: 16 * heightRate
        font.family: Cfg.DEFAULT_FONT
        anchors.top: parent.top
        anchors.topMargin: 18 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        text: currentTimer
        color: "#ff5000"
        font.pixelSize: 24 * heightRate
        font.family: Cfg.DEFAULT_FONT
        anchors.top: text1.bottom
        anchors.topMargin: 4 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
    }

    MouseArea{
        width: parent.width - 2
        height: 34 * heightRate
        hoverEnabled: true
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        anchors.horizontalCenter: parent.horizontalCenter
        cursorShape: Qt.PointingHandCursor

        Rectangle{
            width: parent.width
            height: 10 * heightRate
            color: "#ff5000"
        }

        Rectangle{
            anchors.fill: parent
            color: "#ff5000"
            radius: 10 * heightRate
        }

        Text {
            font.pixelSize: 16 * heightRate
            font.family: Cfg.DEFAULT_FONT
            text: isStartLesson ? "立即上课" : "开始上课"
            anchors.centerIn: parent
            color: "#ffffff"
        }

        onClicked: {
            sigStartLesson(isStartLesson);
        }
    }

    //隐藏动画
    NumberAnimation {
         id: foldAnimation
         target: opacityView
         property: "opacity"
         from: 0
         to: 1
         duration: 500
         running: isStartLesson
         loops: Animation.Infinite
     }

    Timer{
        id: secondTime
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            totalTime--;
            updateTimestamp(totalTime);
        }
    }

    function updateStartLessonTime(){
        var startTime = curriculumData.getCurrentStartTime();
        var date = new Date();
        var currentTime  = date.getTime();
        console.log("==updateStartLessonTime==",startTime);
        if(currentTime > startTime){
            currentTimer = "00:00";
            foldAnimation.start();
        }else{
            var spanTime = (startTime  - currentTime) / 1000;
            totalTime = spanTime - 1;
            updateTimestamp(spanTime);
            secondTime.start();
        }
    }

    function updateTimestamp(totalSecond){
        var minutes = totalSecond  / 60;
        var seconds = totalSecond  % 60;
        currentTimer = addZero(parseInt(minutes)) + ":" + addZero(parseInt(seconds));
    }

    function addZero(values){
        if(values < 10){
            return  "0" + values;
        }else{
            return values.toString();
        }
    }
}
