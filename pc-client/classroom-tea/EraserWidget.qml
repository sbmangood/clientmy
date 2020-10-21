import QtQuick 2.7

/*
 * 橡皮擦
 */
Item {
    id:bakcGround

    property double widthRates: bakcGround.width / 122.0
    property double heightRates: bakcGround.height / 160.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    //清屏信号
    signal sigClearsCreeon();

    //橡皮擦
    signal sigSendEraserInfor(int types);
    MouseArea
    {
        anchors.fill: parent
        onClicked:
        {
            return;
        }
    }
    Image {
        id: bakcGroundImage
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        source: "qrc:/newStyleImg/popwindow_clear@2x.png"
    }

    //清屏
    MouseArea{
        id:cleartPanle
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin:  10 * heightRates
        width: parent.width
        height: 30 * heightRates
        z:5
        Image{
            id: cleartImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 40 * ratesRates
            height: 40 * ratesRates
            anchors.leftMargin: 16 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/newStyleImg/pc_tool_eraser_small@2x.png"
        }

        Text{
            id: cleartText
            anchors.left: cleartImage.right
            anchors.top: cleartImage.top
            anchors.leftMargin: 6 * widthRates
            height: cleartImage.height
            width:parent.width -  cleartImage.width
            font.pixelSize:14 *  heightRates
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#3c3c3e"
            text: qsTr("清屏")
        }
        onPressed: {
            cleartImage.source = "qrc:/newStyleImg/pc_tool_eraser_small@2x.png";
            cleartText.color = "#ff5000";

        }
        onReleased: {
            cleartImage.source = "qrc:/newStyleImg/pc_tool_eraser_small@2x.png";
            cleartText.color = "#3c3c3e";
            sigClearsCreeon();
        }

    }

    //大橡皮擦
    MouseArea{
        id:bigRubber
        anchors.left: parent.left
        anchors.top: cleartPanle.bottom
        anchors.topMargin:  15 * heightRates
        width: parent.width
        height: 30 * heightRates

        z:5
        Image {
            id: bigRubberImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 40 * ratesRates
            height: 40 * ratesRates
            anchors.leftMargin: 16 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/newStyleImg/pc_tool_eraser_big@2x.png"
        }
        Text {
            id: bigRubberText
            anchors.left: bigRubberImage.right
            anchors.top: bigRubberImage.top
            anchors.leftMargin: 6 * widthRates
            height: bigRubberImage.height
            width:parent.width -  bigRubberImage.width
            font.pixelSize:14 *  heightRates
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#3c3c3e"
            text: qsTr("大橡皮")
        }

        onPressed: {
            bigRubberImage.source = "qrc:/newStyleImg/pc_tool_eraser_big@2x.png";
            bigRubberText.color = "#ff5000";

        }
        onReleased: {
            bigRubberImage.source = "qrc:/newStyleImg/pc_tool_eraser_big@2x.png";
            bigRubberText.color = "#3c3c3e";
            sigSendEraserInfor(2);
        }

    }

    //小橡皮擦
    MouseArea{
        id:smallRubber
        anchors.left: parent.left
        anchors.top: bigRubber.bottom
        anchors.topMargin:  15 * heightRates
        width: parent.width
        height: 30 * heightRates

        z:5
        Image {
            id: smallRubberImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 40 * ratesRates
            height: 40 * ratesRates
            anchors.leftMargin: 16 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/newStyleImg/pc_tool_clear@2x.png"
        }
        Text {
            id: smallRubberText
            anchors.left: smallRubberImage.right
            anchors.top: smallRubberImage.top
            anchors.leftMargin: 6 * widthRates
            height: smallRubberImage.height
            width:parent.width -  smallRubberImage.width
            font.pixelSize:14 *  heightRates
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#3c3c3e"
            text: qsTr("小橡皮")
        }

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

