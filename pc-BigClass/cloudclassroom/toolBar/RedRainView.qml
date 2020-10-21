import QtQuick 2.0
import "./Configuration.js" as Cfg
import RedPacket 1.0
import QtMultimedia 5.0

/*
* 红包雨页面
*/

Rectangle {
    id: redRainView
    width: parent.width
    height: parent.height
    color: "#474A5B"
    opacity: 0.8

    property int countNum: 3;//倒计时几秒开始抢红包
    property int downTime: 0;//倒计时
    property int startTime: 10;//抢多久红包参数
    property int totalRed: 0;//总红包个数
    property bool isDisable: false;//是否禁用抢红包
    property var bufferPackge: [];//红包雨点击缓存

    signal sigIntegralTotal(var integral);//总积分信号


    MouseArea{
        anchors.fill: parent
        onClicked: {
            return;
        }
    }

    MediaPlayer{
        id: mediaPlayer
    }

    MouseArea{
        id: redClose
        width: 42 * heightRate
        height: 42 * heightRate
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 8 * heightRate
        cursorShape: Qt.PointingHandCursor

        Text {
            font.bold: true
            font.pixelSize: 26 * heightRate
            font.family: Cfg.DEFAULT_FONT
            text: qsTr("×")
            anchors.centerIn: parent
            color: "#ffffff"
        }

        onClicked: {
            redRainView.visible = false;
        }
    }


    onIsDisableChanged: {
        updateEnable(isDisable);
    }

    RedPacket {
        id:redPacket
        onSigRedPacketsInfo: {
            startTime = redTime;
            countNum = countDownTime;
            console.log("====onSigRedPacketsInfo=",redCount, redTime, countDownTime , canClick);
        }

        onSigBeginRedPackets:{//开始红包雨
            redClose.enabled = false;
            redClose.visible = false;
            if(currentUserRole == 2 || currentUserRole == 1){
                redRainView.visible = true;
            }
            startRedpackgeOperating();
        }

        onSigEndRedPackets:{//结束红包雨
            endRedPackgeOperating();
            redPackgeRankingView.visible = true;
            redPackgeRankingView.updateRankingData(redPacketsDataObj);
        }

        onSigRedPacketSize:{//红包积分大小
            for(var i = 0; i < bufferPackge.length;i++){
                if(packetId == bufferPackge[i].packgeId){
                    bufferPackge[i].redPackgeObj.number = packetSize.toString();
                    break;
                }
            }
        }

        onSigSyncHistoryCredit:{
            if(currentUserRole == 1){
                headView.stuIntegral = historyCredit;
            }
        }

    }

   //倒计时3秒开始抢红包
    Timer{
        id: runTime
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            if(countNum == 1){
                tospView.visible = false;
                runTime.stop();
                redRainRow.visible = true;
                updateRedRain(true);
                updateEnable(isDisable);
                downTimers.start();
                downTime = startTime;
                redpackgeDownView.visible = true;
                return;
            }
            countNum--;
        }
    }

    Timer{
        id: downTimers
        interval: 1000
        repeat: true
        running: false
        onTriggered: {
            if(downTime == 1){
                downTimers.stop();
                redRainView.visible = false;
                return;
            }
            downTime--;
        }
    }

    //红包倒计时
    Rectangle{
        id: redpackgeDownView
        visible: false
        width: 160 * heightRate
        height: 24 * widthRate
        color: "#fb4f4f"
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            color: "#ffffff"
            anchors.centerIn: parent
            text: qsTr("红包雨倒计时：") +downTime.toString() + "s"
        }
    }

    //倒计时提醒
    Image{
        id: tospView
        width: 329 * heightRate
        height: 367 * heightRate
        anchors.centerIn: parent
        source: "qrc:/redPackge/djsbj.png"

        Image{
            id: downImg
            visible: false
            width: 210 * heightRate
            height: 210 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 55 * heightRate
            source: "qrc:/redPackge/"+countNum.toString() +".png"
        }
    }

    Row{
        id: redRainRow
        visible: false
        width: parent.width - (parent.width - midWidth) * 0.5
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10 * heightRate
        RedRain{
            id: redRain1
            width: 172 * heightRate
            height: parent.height
            animateStartNumber: -100
            animateEndNumber: parent.height + 120 * widthRate
            animateTimer: 1800
            isRunning: false
            isEnabled: false
            onSigIntegral: {
                createComponent(packgeNo,redRain1.x +redRain1.width * 0.5,locationY);
            }
        }

        RedRain{
            id: redRain2
            width: 172 * heightRate
            height: parent.height
            animateStartNumber: 200
            animateEndNumber: parent.height + 120 * widthRate
            animateTimer: 1000
            isRunning: false
            isEnabled: false
            onSigIntegral: {
                //totalRed += number;
                 createComponent(packgeNo,redRain2.x +redRain2.width * 0.5,locationY);
            }
        }

        RedRain{
            id: redRain3
            width: 172 * heightRate
            height: parent.height
            animateStartNumber: -120
            animateEndNumber: parent.height + 120 * widthRate
            animateTimer: 2000
            isRunning: false
            isEnabled: false
            onSigIntegral: {
                 createComponent(packgeNo,redRain3.x +redRain3.width * 0.5,locationY);
            }
        }

        RedRain{
            id: redRain4
            width: 172 * heightRate
            height: parent.height
            animateStartNumber: 100
            animateEndNumber: parent.height + 120 * widthRate
            animateTimer: 2400
            isRunning: false
            isEnabled: false
            onSigIntegral: {
                createComponent(packgeNo,redRain4.x +redRain4.width * 0.5 ,locationY);
            }
        }

        RedRain{
            id: redRain5
            width: 172 * heightRate
            height: parent.height
            animateStartNumber: -120
            animateEndNumber: parent.height + 120 * widthRate
            animateTimer: 2200
            isRunning: false
            isEnabled: false
            onSigIntegral: {
                createComponent(packgeNo,redRain5.x +redRain5.width * 0.5 ,locationY);
            }
        }

        RedRain{
            id: redRain6
            width: 172 * heightRate
            height: parent.height
            animateStartNumber: -30
            animateEndNumber: parent.height + 120 * widthRate
            animateTimer: 2400
            isRunning: false
            isEnabled: false
            onSigIntegral: {
                createComponent(packgeNo,redRain6.x +redRain6.width * 0.5 ,locationY);
            }
        }

        RedRain{
            id: redRain7
            width: 172 * heightRate
            height: parent.height
            animateStartNumber: 230
            animateEndNumber: parent.height + 120 * widthRate
            animateTimer: 1400
            isRunning: false
            isEnabled: false
            onSigIntegral: {
                createComponent(packgeNo,redRain7.x +redRain7.width * 0.5 ,locationY);
            }
        }

        RedRain{
            id: redRain8
            width: 172 * heightRate
            height: parent.height
            animateStartNumber: -30
            animateEndNumber: parent.height
            animateTimer: 1800
            isRunning: false
            isEnabled: false
            onSigIntegral: {
                createComponent(packgeNo,redRain8.x +redRain8.width * 0.5 ,locationY);
            }
        }
    }

    //启动红包雨命令
    function startRedPackge(){
        redClose.enabled = true;
        redClose.visible = true;
        redPacket.startRedPackets();
    }

    //击中红包 packgeId: 红包的编号
    function checkRedPackge(redPackgeId){
        redPacket.hitRedPacket(redPackgeId);
    }

    //创建点击红包
    function createComponent(packgeId,locationX,locationY){
        var component = Qt.createComponent("YMRedpackgeComponent.qml")

        if(Component.Ready === component.status) {
            var object = component.createObject(redRainView)
            object.x = locationX;
            object.y = locationY;
            object.destroy(2000);
            bufferPackge.push(
                        {
                            "packgeId":packgeId,
                            "redPackgeObj":object
                        });
            checkRedPackge(packgeId);
        }
        mediaPlayer.source = "";
        mediaPlayer.source = "qrc:/mp3/gold.mp3";
        mediaPlayer.play();
    }

    //禁用红包
    function updateEnable(isEnable){
        redRain1.isEnabled = isEnable;
        redRain2.isEnabled = isEnable;
        redRain3.isEnabled = isEnable;
        redRain4.isEnabled = isEnable;
        redRain5.isEnabled = isEnable;
        redRain6.isEnabled = isEnable;
        redRain7.isEnabled = isEnable;
        redRain8.isEnabled = isEnable;
    }

    //红包雨是否运行
    function updateRedRain(isRunning){
        redRain1.isRunning = isRunning;
        redRain2.isRunning = isRunning;
        redRain3.isRunning = isRunning;
        redRain4.isRunning = isRunning;
        redRain5.isRunning = isRunning;
        redRain6.isRunning = isRunning;
        redRain7.isRunning = isRunning;
        redRain8.isRunning = isRunning;
    }

    //开启红包雨操作
    function startRedpackgeOperating(){
        console.log("===start::redPackge===")
        totalRed = 0;
        downImg.visible = true;
        redpackgeDownView.visible = false;
        runTime.restart();

        for(var k = 0; k < bufferPackge.length;k++){
            bufferPackge.splice(k,1);
        }
    }

    //结束红包操作
    function endRedPackgeOperating(){
        countNum = 3;
        redpackgeDownView.visible = false;
        redRainRow.visible = false;
        updateRedRain(false);
        tospView.visible = true;
        redRainView.visible = false;
        sigIntegralTotal(totalRed);
    }

}
