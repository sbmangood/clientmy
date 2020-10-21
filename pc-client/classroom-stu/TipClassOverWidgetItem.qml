﻿import QtQuick 2.7

//正在离开教室，稍后可以回来继续上课哦！
Rectangle {
    id:tipClassOverWidgetItem

    property double widthRates: tipClassOverWidgetItem.width /  300.0
    property double heightRates: tipClassOverWidgetItem.height / 225.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates
    radius: 10 * ratesRates
    color: "#00000000"
    //背景图片
    Image {
        id:backGroundImage
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        z:1
        source: "qrc:/images/classovertwo.png"
    }

    //提示信息
    Rectangle{
         id: tagNameBackGround
         anchors.left: parent.left
         anchors.top: parent.top
         width: 270 * tipClassOverWidgetItem.widthRates
         height: 38 * tipClassOverWidgetItem.heightRates
         anchors.leftMargin: 15 * tipClassOverWidgetItem.widthRates
         anchors.topMargin: 172 * tipClassOverWidgetItem.heightRates
         color: "#00000000"
         z:2
         Text {
             id: tagName
             horizontalAlignment: Text.AlignHCenter
             verticalAlignment: Text.AlignVCenter
             anchors.left: parent.left
             anchors.top: parent.top
             width: parent.width
             height:parent.height
             font.pixelSize: 15 * tipClassOverWidgetItem.heightRates
             color: "#222222"
             wrapMode:Text.WordWrap
             font.family: "Microsoft YaHei"
             z:2
             text: qsTr("正在离开教室，稍后可以回来继续上课哦！");
         }
    }




}

