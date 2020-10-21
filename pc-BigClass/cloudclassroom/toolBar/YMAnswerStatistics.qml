import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import "./Configuration.js" as Cfg

/*
* 答题统计
*/

Rectangle {
    id: answerStatistics
    width: 442 * heightRate
    height: 324 * heightRate
    color: "#474A5B"
    radius: 8 * heightRate

    property string itemAnswer: "";
    property int submitNum: 0;
    property int accuracy: 0;

    MouseArea{
        anchors.fill: parent
        onClicked: {

        }
    }

    //head bar
    MouseArea{
        id:headBar
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
            var moveX = answerStatistics.x + delta.x;
            var moveY = answerStatistics.y + delta.y;
            var moveWidth = answerStatistics.parent.width - answerStatistics.width;
            var moveHeight = answerStatistics.parent.height - answerStatistics.height;

            if( moveX > 0 && moveX < moveWidth) {
                answerStatistics.x = answerStatistics.x + delta.x;
            }else{
                var loactionX = moveX < 0 ? 0 : (moveX > moveWidth ? moveWidth : moveX);
                answerStatistics.x = loactionX;
            }

            if(moveY  > 0 && moveY < moveHeight){
                answerStatistics.y = answerStatistics.y + delta.y;
            }else{
                answerStatistics.y = moveY < 0 ? 0 : (moveY > moveHeight ? moveHeight : moveY);
            }
        }

        Text {
            anchors.centerIn: parent
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            text: qsTr("结果统计")
            color: "#ffffff"
        }

        Rectangle{
            width: parent.width
            height: 1
            color: "#4D90FF"
            anchors.bottom: parent.bottom
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
                text: qsTr("×")
                anchors.centerIn: parent
                color: "#ffffff"
            }

            onClicked: {
                answerStatistics.visible = false;
            }
        }
    }

    Row{
        id: answerResult
        anchors.top: headBar.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8 * heightRate
        width: parent.width * 0.9
        height: 42 * heightRate

        Item{
            width: parent.width * 0.3
            height: parent.height

            Text {
                anchors.centerIn: parent
                font.pixelSize: 16 * heightRate
                text: qsTr("正确答案: " + itemAnswer)
                font.family: Cfg.DEFAULT_FONT
                color: "#ffffff"
            }
            Rectangle{
                width: 1 * heightRate
                height: 18 * heightRate
                color: "#5e627d"
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item{
            width: parent.width * 0.4
            height: parent.height

            Text {
                anchors.centerIn: parent
                font.pixelSize: 16 * heightRate
                text: qsTr("已提交人数: " + submitNum.toString())
                color: "#ffffff"
                font.family: Cfg.DEFAULT_FONT
            }

            Rectangle{
                width: 1 * heightRate
                height: 18 * heightRate
                color: "#5e627d"
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item{
            width: parent.width * 0.3
            height: parent.height

            Text {
                anchors.centerIn: parent
                font.pixelSize: 16 * heightRate
                text: qsTr("正确率: " + accuracy.toString() + "%")
                color: "#ffffff"
                font.family: Cfg.DEFAULT_FONT
            }
        }
    }

    Row{
        width: parent.width - 80 * heightRate
        height: parent.height - headBar.height - answerResult.height - 20 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 18 * heightRate

        YMStatisticsControl{
            id: statisticsA
            height: parent.height
            colorValue: itemStr == itemAnswer ? "#35D0B0" : "red"
        }

        YMStatisticsControl{
            id: statisticsB
            height: parent.height
            colorValue: itemStr == itemAnswer ? "#35D0B0" : "red"
        }

        YMStatisticsControl{
            id: statisticsC
            height: parent.height
            colorValue: itemStr == itemAnswer ? "#35D0B0" : "red"
        }

        YMStatisticsControl{
            id: statisticsD
            height: parent.height
            colorValue: itemStr == itemAnswer ? "#35D0B0" : "red"
        }

        YMStatisticsControl{
            id: statisticsE
            height: parent.height
            colorValue: itemStr == itemAnswer ? "#35D0B0" : "red"
        }

        YMStatisticsControl{
            id: statisticsF
            height: parent.height
            colorValue: itemStr == itemAnswer ? "#35D0B0" : "red"
        }

        YMStatisticsControl{
            id: statisticsG
            height: parent.height
            colorValue: itemStr == itemAnswer ? "#35D0B0" : "red"
        }

        YMStatisticsControl{
            id: statisticsH
            height: parent.height
            colorValue: itemStr == itemAnswer ? "#35D0B0" : "red"
        }
    }

    Rectangle{
        width: 2
        height: 160 * heightRate
        color: "#5e627d"
        anchors.left: parent.left
        anchors.leftMargin: 24 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 36 * heightRate
    }

    Text {
        text: qsTr("人数")
        color: "#797EA3"
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 14 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 10 * heightRate
        anchors.top: answerResult.bottom
        anchors.topMargin: 10 * heightRate
    }


    Rectangle{
        width: parent.width - 20
        height: 2 * heightRate
        color: "#5e627d"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 36 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        text: qsTr("选项")
        color: "#797EA3"
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 14 * heightRate
        anchors.right: parent.right
        anchors.rightMargin: 10 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 44 * heightRate
    }

    function updateItemData(arrayData){
        resetItem();
        if(arrayData.length < 0){
            return;
        }

        for(var i = 0; i < arrayData.length; i++){
            var itemName = arrayData[i].itemName;
            var itemValue = arrayData[i].value;
            if(itemName == "A"){
                statisticsA.itemStr = itemName;
                statisticsA.itemNum = itemValue;
                continue;
            }
            if(itemName == "B"){
                statisticsB.itemStr = itemName;
                statisticsB.itemNum = itemValue;
                continue;
            }
            if(itemName == "C"){
                statisticsC.itemStr = itemName;
                statisticsC.itemNum = itemValue;
                continue;
            }
            if(itemName == "D"){
                statisticsD.itemStr = itemName;
                statisticsD.itemNum = itemValue;
                continue;
            }
            if(itemName == "E"){
                statisticsE.itemStr = itemName;
                statisticsE.itemNum = itemValue;
                continue;
            }
            if(itemName == "F"){
                statisticsF.itemStr = itemName;
                statisticsF.itemNum = itemValue;
                continue;
            }
            if(itemName == "G"){
                statisticsG.itemStr = itemName;
                statisticsG.itemNum = itemValue;
                continue;
            }
            if(itemName == "H"){
                statisticsH.itemStr = itemName;
                statisticsH.itemNum = itemValue;
                continue;
            }

            /*
            switch(i){
            case 0:
                statisticsA.itemStr = arrayData[i].itemName;
                statisticsA.itemNum = arrayData[i].value;
                break;
            case 1:
                statisticsB.itemStr = arrayData[i].itemName;
                statisticsB.itemNum = arrayData[i].value;
                break;
            case 2:
                statisticsC.itemStr = arrayData[i].itemName;
                statisticsC.itemNum = arrayData[i].value;
                break;
            case 3:
                statisticsD.itemStr = arrayData[i].itemName;
                statisticsD.itemNum = arrayData[i].value;
                break;
            case 4:
                statisticsE.itemStr = arrayData[i].itemName;
                statisticsE.itemNum = arrayData[i].value;
                break;
            case 5:
                statisticsF.itemStr = arrayData[i].itemName;
                statisticsF.itemNum = arrayData[i].value;
                break;
            case 6:
                statisticsG.itemStr = arrayData[i].itemName;
                statisticsG.itemNum = arrayData[i].value;
                break;
            case 7:
                statisticsH.itemStr = arrayData[i].itemName;
                statisticsH.itemNum = arrayData[i].value;
                break;
            }*/
        }
    }

    function resetItem(){
        statisticsA.itemStr = "";
        statisticsB.itemStr = "";
        statisticsC.itemStr = "";
        statisticsD.itemStr = "";
        statisticsE.itemStr = "";
        statisticsF.itemStr = "";
        statisticsG.itemStr = "";
        statisticsH.itemStr = "";
    }
}
