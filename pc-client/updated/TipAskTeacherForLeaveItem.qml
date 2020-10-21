import QtQuick 2.7

//正在向老师请假离开
Rectangle {
    id:tipAskTeacherForLeaveItem
signal hideItem();
    property double widthRates: tipAskTeacherForLeaveItem.width /  300.0
    property double heightRates: tipAskTeacherForLeaveItem.height / 225.0
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
        source: "qrc:/images/window_sh_linshituichu@1x.png"
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
             font.family: "Microsoft YaHei"
             font.pixelSize: 15 * tipAskTeacherForLeaveItem.heightRates
             color: "#222222"
             wrapMode:Text.WordWrap
             z:2
             text: qsTr("正在向老师请假离开...")
         }
    }

    Rectangle{
        width: 25 * widthRates
        height: 25 * widthRates
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 5 * heightRates
        anchors.topMargin: 5 * heightRates
       color: "transparent"
        z:5
        Image {
            anchors.fill: parent
            source: "qrc:/images/cr_btn_closetwo.png"
        }
        MouseArea
        {
            anchors.fill: parent
            onClicked: {
                hideItem();
            }
        }
    }


}

