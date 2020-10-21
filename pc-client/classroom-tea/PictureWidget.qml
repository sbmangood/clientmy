﻿import QtQuick 2.7

/*
 * 截图
 */
Item {
    id:bakcGround

    property double widthRates: bakcGround.width / 110.0
    property double heightRates: bakcGround.height / 160.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    signal sigUpLoadPicture();
    signal sigScreenShotPicture();

    property bool disableClipButton: true;//截图按钮是否禁用
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
        source: "qrc:/newStyleImg/popwindow_photo@2x.png"
    }


    //上传图片
    MouseArea{
        id:uploadPicture
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 8 * heightRates
        width: parent.width
        height: 50 * heightRates
        z:5
        Image {
            id: uploadPictureImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 58 * ratesRates
            height: 58 * ratesRates
            anchors.leftMargin: 18 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/newStyleImg/pc_shape_photo@2x.png"
        }
        Text {
            id: uploadPictureText
            anchors.left: uploadPictureImage.right
            anchors.top: uploadPictureImage.top
            anchors.leftMargin: 8 * widthRates
            height: uploadPictureImage.height
            width:parent.width -  uploadPictureImage.width
            font.pixelSize: 16 * widthRates
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#3c3c3e"
            text: qsTr("图片")
        }

        onPressed: {
            uploadPictureImage.source = "qrc:/newStyleImg/pc_shape_photo@2x.png";
            uploadPictureText.color = "#ff5000";

        }
        onReleased: {
            uploadPictureImage.source = "qrc:/newStyleImg/pc_shape_photo@2x.png";
            uploadPictureText.color = "#3c3c3e";
            sigUpLoadPicture();
        }

    }


    //截图
    MouseArea{
        id:screenshot
        anchors.left: parent.left
        anchors.top: uploadPicture.bottom
        anchors.topMargin:  19 * heightRates
        width: parent.width
        height: 50 * heightRates
        enabled: disableClipButton
        z:5
        Image {
            id: screenshotImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 58 * ratesRates
            height: 58 * ratesRates
            anchors.leftMargin: 18 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/newStyleImg/pc_photo_capture@2x.png"
        }
        Text {
            id: screenshotText
            anchors.left: screenshotImage.right
            anchors.top: screenshotImage.top
            anchors.leftMargin: 8 * widthRates
            height: screenshotImage.height
            width:parent.width -  screenshotImage.width
            font.pixelSize: 16 * widthRates
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#3c3c3e"
            text: qsTr("截图")
        }

        onPressed: {
            screenshotImage.source = "qrc:/newStyleImg/pc_photo_capture@2x.png";
            screenshotText.color = "#ff5000";

        }

        onReleased: {
            screenshotImage.source = "qrc:/newStyleImg/pc_photo_capture@2x.png";
            screenshotText.color = "#3c3c3e";
            sigScreenShotPicture();

            mainView.doEnableDisableControls(false); //disable 部分控件
        }

    }

}
