import QtQuick 2.7

//暂时不能离开，请认真听讲
Rectangle {
    id:tipCannotLeaveWidgetItem

    property double widthRates: tipCannotLeaveWidgetItem.width /  300.0
    property double heightRates: tipCannotLeaveWidgetItem.height / 225.0
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
        source: "qrc:/images/nononotwo.png"
    }

    //提示信息
    Rectangle{
         id: tagNameBackGround
         anchors.left: parent.left
         anchors.top: parent.top
         width: 270 * tipCannotLeaveWidgetItem.widthRates
         height: 38 * tipCannotLeaveWidgetItem.heightRates
         anchors.leftMargin: 15 * tipCannotLeaveWidgetItem.widthRates
         anchors.topMargin: 172 * tipCannotLeaveWidgetItem.heightRates
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
             font.pixelSize: 15 * tipCannotLeaveWidgetItem.heightRates
             color: "#222222"
             wrapMode:Text.WordWrap
             font.family: "Microsoft YaHei"
             z:2
             text: qsTr("暂时不能离开，请认真听讲")
         }
    }




}

