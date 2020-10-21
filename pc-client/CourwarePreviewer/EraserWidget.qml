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

    Image {
        id: bakcGroundImage
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        source: "qrc:/images/tan_xiangpitwox.png"
    }

    //清屏
    MouseArea{
        id:cleartPanle
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin:  15 * heightRates
        width: parent.width
        height: 30 * heightRates
        z:5
        Image{
            id: cleartImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 20 * ratesRates
            height: 20 * ratesRates
            anchors.leftMargin: 30 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/images/cr_btn_empty.png"
        }

        Text{
            id: cleartText
            anchors.left: cleartImage.right
            anchors.top: cleartImage.top
            anchors.leftMargin: 2 * widthRates
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
            cleartImage.source = "qrc:/images/cr_btn_empty_click.png";
            cleartText.color = "#ff5000";

        }
        onReleased: {
            cleartImage.source = "qrc:/images/cr_btn_empty.png";
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
            width: 20 * ratesRates
            height: 20 * ratesRates
            anchors.leftMargin: 30 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/images/cr_btn_clearbig.png"
        }
        Text {
            id: bigRubberText
            anchors.left: bigRubberImage.right
            anchors.top: bigRubberImage.top
            anchors.leftMargin: 2 * widthRates
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
            bigRubberImage.source = "qrc:/images/cr_btn_clearbig_click.png";
            bigRubberText.color = "#ff5000";

        }
        onReleased: {
            bigRubberImage.source = "qrc:/images/cr_btn_clearbig.png";
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
            width: 20 * ratesRates
            height: 20 * ratesRates
            anchors.leftMargin: 30 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/images/cr_btn_clearsmall.png"
        }
        Text {
            id: smallRubberText
            anchors.left: smallRubberImage.right
            anchors.top: smallRubberImage.top
            anchors.leftMargin: 2 * widthRates
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
            smallRubberImage.source = "qrc:/images/cr_btn_clearsmall_click.png";
            smallRubberText.color = "#ff5000";

        }
        onReleased: {
            smallRubberImage.source = "qrc:/images/cr_btn_clearsmall.png";
            smallRubberText.color = "#3c3c3e";
            sigSendEraserInfor(1);

        }

    }

}

