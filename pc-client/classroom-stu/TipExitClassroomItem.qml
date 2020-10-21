import QtQuick 2.7


/*
 *用于b学生主动退出教室
 */

Rectangle {
    id:tipExitClassroomItem

    color: "white"
    property double widthRates: tipExitClassroomItem.width / 240.0
    property double heightRates: tipExitClassroomItem.height / 137.0
    property double ratesRates: tipExitClassroomItem.widthRates > tipExitClassroomItem.heightRates? tipExitClassroomItem.heightRates : tipExitClassroomItem.widthRates

    radius: 10 * ratesRates
    clip: true
    //同意
    signal agreeTheCmd();
    //取消
    signal refuseTheCmd();

    Text {
        id: tagName
        width: 109 * tipExitClassroomItem.widthRates
        height: 18 * tipExitClassroomItem.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 18 * tipExitClassroomItem.ratesRates
        anchors.leftMargin: 66 * tipExitClassroomItem.widthRates
        anchors.topMargin: 20 * tipExitClassroomItem.heightRates
        color: "#222222"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: qsTr("退出教室")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }



    Text {
        id: contentName
        width: 200 * tipExitClassroomItem.widthRates
        height: 17 * tipExitClassroomItem.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 12 * tipExitClassroomItem.ratesRates
        anchors.leftMargin: 20 * tipExitClassroomItem.widthRates
        anchors.topMargin: 53 * tipExitClassroomItem.heightRates
        color: "#3c3c3e";
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: qsTr("课程尚未结束，确定退出？")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }


    //确定按钮
    Rectangle{
        id:okBtn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 125 *  tipExitClassroomItem.widthRates
        anchors.topMargin:  90 * tipExitClassroomItem.heightRates
        width:  93  *  tipExitClassroomItem.widthRates
        height:  30 * tipExitClassroomItem.heightRates
        color: "#ff5000"
        radius: 5 * tipExitClassroomItem.heightRates
        Text {
            id: okBtnName
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14  * tipExitClassroomItem.ratesRates
            color: "#ffffff"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: qsTr("确定")
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                agreeTheCmd();

            }
        }
    }



    //取消按钮
    Rectangle{
        id:cancelBtn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20 *  tipExitClassroomItem.widthRates
        anchors.topMargin:  90 * tipExitClassroomItem.heightRates
        width:  93  *  tipExitClassroomItem.widthRates
        height:  30 * tipExitClassroomItem.heightRates
        color: "#ffffff"
        border.color: "#96999c"
        border.width: 1
        radius: 5 * tipExitClassroomItem.heightRates
        Text {
            id: cancelBtnName
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14  * tipExitClassroomItem.ratesRates
            color: "#96999c"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: qsTr("取消")
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                refuseTheCmd();

            }
        }
    }



}

