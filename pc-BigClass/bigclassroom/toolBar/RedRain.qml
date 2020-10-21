import QtQuick 2.0
import "./Configuration.js" as Cfg
/*
* 红包
*/

Item {
    id: redmainView
    width: 172 * heightRate
    height: 172 * heightRate

    property int number: getRandNumber(1,100);
    property int animateStartNumber: 0;
    property int animateEndNumber: 0;
    property int animateTimer: 3000;
    property bool isEnabled: false;
    property bool isRunning: false;

    signal sigIntegral(var packgeNo,var locationX,var locationY);//积分信号

    Image{
        id: redView
        width: parent.width
        height: 172 * heightRate
        source: "qrc:/redPackge/hbw.png"

        MouseArea{
            enabled: isEnabled
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                redView.visible = false;
                sigIntegral(number,Math.floor(redView.x),Math.floor(redView.y))
            }
        }
    }

    PropertyAnimation{
        id: animation
        target: redView
        property: "y"
        running: isRunning
        from : animateStartNumber
        to:animateEndNumber
        duration: animateTimer
        onStopped: {
            if(isRunning == false){
                return;
            }
            animation.start();
            number = getRandNumber(1,100);
            redmainView.visible = true;
        }
    }

    onIsRunningChanged: {
        if(isRunning){
            runningTime.restart();
        }
    }

    Timer{
        id: runningTime
        interval: animateTimer
        running: false
        repeat: true
        onTriggered: {
            redView.visible = true;
        }
    }

    function getRandNumber(min,max){
        var range = max - min;
        var rand = Math.random();
        var numbers = min +Math.round(rand * range);
        return numbers;
    }

}
