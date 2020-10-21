import QtQuick 2.7


/*
 *老师退出教室 a学生用
 */
Rectangle {
    id:tipExitClassroom

    color: "white"
    property double widthRates: tipExitClassroom.width / 240.0
    property double heightRates: tipExitClassroom.height / 154.0
    property double ratesRates: tipExitClassroom.widthRates > tipExitClassroom.heightRates? tipExitClassroom.heightRates : tipExitClassroom.widthRates
    property string stuNameContent: "老师"


    radius: 10 * ratesRates
    clip: true

    //留在教室
    signal stayInclassroom();
    //退出教室
    signal leaveTheclassroom();

    Text {
        id: tagName
        width: 197 * tipExitClassroom.widthRates
        height: 18 * tipExitClassroom.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 18 * tipExitClassroom.ratesRates
        anchors.leftMargin: 22 * tipExitClassroom.widthRates
        anchors.topMargin: 20 * tipExitClassroom.heightRates
        color: "#222222"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: stuNameContent +qsTr("退出教室")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        id: contentName
        width: 200 * tipExitClassroom.widthRates
        height: 34 * tipExitClassroom.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 12 * tipExitClassroom.ratesRates
        anchors.leftMargin: 20 * tipExitClassroom.widthRates
        anchors.topMargin: 53 * tipExitClassroom.heightRates
        color: "#3c3c3e"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: qsTr("您可以留在教室回顾或预习一下本课程内容")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }



    //留在教室
    Rectangle{
        id:okBtn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 125 *  tipExitClassroom.widthRates
        anchors.topMargin:  107 * tipExitClassroom.heightRates
        width:  93  *  tipExitClassroom.widthRates
        height:  30 * tipExitClassroom.heightRates
        color: "#ff5000"
        radius: 5 * tipExitClassroom.heightRates
        Text {
            id: okBtnName
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14  * tipExitClassroom.ratesRates
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#ffffff"
            text: qsTr("留在教室")
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                stayInclassroom();

            }
        }
    }



    //取消按钮
    Rectangle{
        id:cancelBtn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20 *  tipExitClassroom.widthRates
        anchors.topMargin:  107 * tipExitClassroom.heightRates
        width:  93  *  tipExitClassroom.widthRates
        height:  30 * tipExitClassroom.heightRates
        color: "#96999c"
        radius: 5 * tipExitClassroom.heightRates
        Text {
            id: cancelBtnName
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14  * tipExitClassroom.ratesRates
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#ffffff"
            text: qsTr("退出")
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                leaveTheclassroom();
            }
        }
    }


}
