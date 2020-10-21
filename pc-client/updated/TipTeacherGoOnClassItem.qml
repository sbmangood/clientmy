import QtQuick 2.7



//老师回来啦，现在继续上课
Rectangle {
    id:tipTeacherGoOnClassItem

    property double widthRates: tipTeacherGoOnClassItem.width /  300.0
    property double heightRates: tipTeacherGoOnClassItem.height / 225.0
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
        source: "qrc:/images/teachercomebacktwo.png"
    }

    //提示信息
    Rectangle{
         id: tagNameBackGround
         anchors.left: parent.left
         anchors.top: parent.top
         width: 270 * tipAskTeacherForLeaveItem.widthRates
         height: 38 * tipAskTeacherForLeaveItem.heightRates
         anchors.leftMargin: 15 * tipAskTeacherForLeaveItem.widthRates
         anchors.topMargin: 172 * tipAskTeacherForLeaveItem.heightRates
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
             font.pixelSize: 15 * tipAskTeacherForLeaveItem.heightRates
             color: "#222222"
             wrapMode:Text.WordWrap
             font.family: "Microsoft YaHei"
             z:2
             text: qsTr("老师回来啦，现在继续上课")
         }
    }




}

