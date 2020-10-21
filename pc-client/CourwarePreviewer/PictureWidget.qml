import QtQuick 2.7

/*
 * 截图
 */
Item {
    id:bakcGround

    property double widthRates: bakcGround.width / 110.0
    property double heightRates: bakcGround.height / 105.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    signal sigUpLoadPicture();
    signal sigScreenShotPicture();

    property bool disableClipButton: true;//截图按钮是否禁用

    Image {
        id: bakcGroundImage
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        source: "qrc:/images/tan_xiangpitwox.png"
    }


    //上传图片
    MouseArea{
        id:uploadPicture
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin:  15 * heightRates
        width: parent.width
        height: 30 * heightRates
        z:5
        Image {
            id: uploadPictureImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 20 * ratesRates
            height: 20 * ratesRates
            anchors.leftMargin: 30 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/images/btn_window_pic.png"
        }
        Text {
            id: uploadPictureText
            anchors.left: uploadPictureImage.right
            anchors.top: uploadPictureImage.top
            anchors.leftMargin: 2 * widthRates
            height: uploadPictureImage.height
            width:parent.width -  uploadPictureImage.width
            font.pixelSize:14 *  heightRates
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#3c3c3e"
            text: qsTr("图片")
        }

        onPressed: {
            uploadPictureImage.source = "qrc:/images/btn_window_pic_click.png";
            uploadPictureText.color = "#ff5000";

        }
        onReleased: {
            uploadPictureImage.source = "qrc:/images/btn_window_pic.png";
            uploadPictureText.color = "#3c3c3e";
            sigUpLoadPicture();
        }

    }


    //截图
    MouseArea{
        id:screenshot
        anchors.left: parent.left
        anchors.top: uploadPicture.bottom
        anchors.topMargin:  15 * heightRates
        width: parent.width
        height: 30 * heightRates
        enabled: disableClipButton
        z:5
        Image {
            id: screenshotImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 20 * ratesRates
            height: 20 * ratesRates
            anchors.leftMargin: 30 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/images/btn_capture.png"
        }
        Text {
            id: screenshotText
            anchors.left: screenshotImage.right
            anchors.top: screenshotImage.top
            anchors.leftMargin: 2 * widthRates
            height: screenshotImage.height
            width:parent.width -  screenshotImage.width
            font.pixelSize:14 *  heightRates
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#3c3c3e"
            text: qsTr("截图")
        }

        onPressed: {
            screenshotImage.source = "qrc:/images/btn_capture_click.png";
            screenshotText.color = "#ff5000";

        }
        onReleased: {
            screenshotImage.source = "qrc:/images/btn_capture.png";
            screenshotText.color = "#3c3c3e";
            sigScreenShotPicture();
        }

    }

}

