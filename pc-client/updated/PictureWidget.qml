import QtQuick 2.7

/*
 * 截图
 */
Rectangle {
    id:bakcGround
    color: "#00000000"

    property double widthRates: bakcGround.width / 110.0
    property double heightRates: bakcGround.height / 105.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    signal sigUpLoadPicture();
    signal sigScreenShotPicture();

    Image {
        id: bakcGroundImage
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        source: "qrc:/images/tan_xiangpitwox.png"
    }


    //上传图片
    Rectangle{
        id:uploadPicture
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin:  15 * heightRates
        width: parent.width
        height: 30 * heightRates
        color: "#00000000"
        z:5
        Image {
            id: uploadPictureImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 30 * ratesRates
            height: 30 * ratesRates
            anchors.leftMargin: 30 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/newStyleImg/pc_shape_photo@2x.png"
        }
        Text {
            id: uploadPictureText
            anchors.left: uploadPictureImage.right
            anchors.top: uploadPictureImage.top
            anchors.leftMargin: 10 * widthRates
            height: uploadPictureImage.height
            width:parent.width -  uploadPictureImage.width
            font.pixelSize:13 *  heightRates
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#3c3c3e"
            text: qsTr("图片")
        }

        MouseArea{
            anchors.fill: parent
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
    }



    //截图
    Rectangle{
        id:screenshot
        anchors.left: parent.left
        anchors.top: uploadPicture.bottom
        anchors.topMargin:  15 * heightRates
        width: parent.width
        height: 30 * heightRates
        color: "#00000000"
        z:5
        Image {
            id: screenshotImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 30 * ratesRates
            height: 30 * ratesRates
            anchors.leftMargin: 30 * widthRates
            anchors.topMargin:  5 * heightRates
            source: "qrc:/newStyleImg/pc_photo_capture@2x.png"
        }
        Text {
            id: screenshotText
            anchors.left: screenshotImage.right
            anchors.top: screenshotImage.top
            anchors.leftMargin: 10 * widthRates
            height: screenshotImage.height
            width:parent.width -  screenshotImage.width
            font.pixelSize:13 *  heightRates
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#3c3c3e"
            text: qsTr("截图")
        }

        MouseArea{
            anchors.fill: parent
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



    MouseArea{
        anchors.fill: parent
        onClicked: {

        }
    }



}

