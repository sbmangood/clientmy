﻿import QtQuick 2.7

/*
 * 橡皮擦
 */
Rectangle {
    id:bakcGround
    color: "#00000000"

    property double widthRates: bakcGround.width / 122.0
    property double heightRates: bakcGround.height / 160.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    //清屏信号
    signal sigClearsCreeon();

    //橡皮擦
    signal sigSendEraserInfor(int types);

    Image {
        id: bakcGroundImage
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        source: "qrc:/newStyleImg/popwindow_photo@2x.png"
    }


    //大橡皮擦
    Rectangle{
        id:bigRubber
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 8 * heightRates
        width: parent.width
        height: 50 * heightRates
        color: "#00000000"
        z:5
        Image {
            id: bigRubberImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 55 * ratesRates
            height: 55 * ratesRates
            anchors.leftMargin: 18 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/newStyleImg/pc_tool_eraser_big@2x.png"
        }
        Text {
            id: bigRubberText
            anchors.left: bigRubberImage.right
            anchors.top: bigRubberImage.top
            anchors.leftMargin: 6 * widthRates
            height: bigRubberImage.height
            width:parent.width - bigRubberImage.width
            font.pixelSize:16 * widthRates
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#3c3c3e"
            text: qsTr("大橡皮")
        }

        MouseArea{
            anchors.fill: parent
            onPressed: {
                bigRubberImage.source = "qrc:/newStyleImg/pc_tool_eraser_big@2x.png"
                bigRubberText.color = "#ff5000";

            }
            onReleased: {
                bigRubberImage.source = "qrc:/newStyleImg/pc_tool_eraser_big@2x.png";
                bigRubberText.color = "#3c3c3e";
                sigSendEraserInfor(2);
            }
        }
    }




    //小橡皮擦
    Rectangle{
        id:smallRubber
        anchors.left: parent.left
        anchors.top: bigRubber.bottom
        anchors.topMargin:  19 * heightRates
        width: parent.width
        height: 50 * heightRates
        color: "#00000000"
        z:5
        Image {
            id: smallRubberImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 55 * ratesRates
            height: 55 * ratesRates
            anchors.leftMargin: 18 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/newStyleImg/pc_tool_clear@2x.png"
        }
        Text {
            id: smallRubberText
            anchors.left: smallRubberImage.right
            anchors.top: smallRubberImage.top
            anchors.leftMargin: 5 * widthRates
            height: smallRubberImage.height
            width:parent.width - smallRubberImage.width
            font.pixelSize:16 * widthRates
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#3c3c3e"
            text: qsTr("小橡皮")
        }

        MouseArea{
            anchors.fill: parent
            onPressed: {
                smallRubberImage.source = "qrc:/newStyleImg/pc_tool_clear@2x.png";
                smallRubberText.color = "#ff5000";

            }
            onReleased: {
                smallRubberImage.source = "qrc:/newStyleImg/pc_tool_clear@2x.png";
                smallRubberText.color = "#3c3c3e";
                sigSendEraserInfor(1);

            }
        }
    }


    MouseArea{
        anchors.fill: parent
        onClicked: {

        }
    }


}

