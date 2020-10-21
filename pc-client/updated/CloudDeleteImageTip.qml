import QtQuick 2.7


/*
 *删除做题图片
 */

Rectangle {
    id:deleteImageTip

    color: "white"
    property double widthRates: deleteImageTip.width / 240.0
    property double heightRates: deleteImageTip.height / 137.0
    property double ratesRates: deleteImageTip.widthRates > deleteImageTip.heightRates? deleteImageTip.heightRates : deleteImageTip.widthRates

    radius: 10 * ratesRates
    clip: true
    //同意
    signal sigDeleteImage();
    //取消
    signal sigNotDeleteImage();

    Text {
        id: tagName
        width: 109 * deleteImageTip.widthRates
        height: 18 * deleteImageTip.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 18 * deleteImageTip.ratesRates
        anchors.leftMargin: 66 * deleteImageTip.widthRates
        anchors.topMargin: 20 * deleteImageTip.heightRates
        color: "#222222"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: qsTr("图片删除")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }



    Text {
        id: contentName
        width: 200 * deleteImageTip.widthRates
        height: 17 * deleteImageTip.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 12 * deleteImageTip.ratesRates
        anchors.leftMargin: 20 * deleteImageTip.widthRates
        anchors.topMargin: 53 * deleteImageTip.heightRates
        color: "#3c3c3e";
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: qsTr("确定删除该图片吗？")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }


    //确定按钮
    Rectangle{
        id:okBtn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 125 *  deleteImageTip.widthRates
        anchors.topMargin:  90 * deleteImageTip.heightRates
        width:  93  *  deleteImageTip.widthRates
        height:  30 * deleteImageTip.heightRates
        color: "#ff5000"
        radius: 5 * deleteImageTip.heightRates
        Text {
            id: okBtnName
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14  * deleteImageTip.ratesRates
            color: "#ffffff"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: qsTr("确定")
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                sigDeleteImage();

            }
        }
    }



    //取消按钮
    Rectangle{
        id:cancelBtn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20 *  deleteImageTip.widthRates
        anchors.topMargin:  90 * deleteImageTip.heightRates
        width:  93  *  deleteImageTip.widthRates
        height:  30 * deleteImageTip.heightRates
        color: "#ffffff"
        border.color: "#96999c"
        border.width: 1
        radius: 5 * deleteImageTip.heightRates
        Text {
            id: cancelBtnName
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14  * deleteImageTip.ratesRates
            color: "#96999c"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: qsTr("取消")
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                sigNotDeleteImage();
            }
        }
    }



}

