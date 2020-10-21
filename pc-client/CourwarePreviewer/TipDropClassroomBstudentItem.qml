import QtQuick 2.7
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4


//课程暂时中断，请退出 学生 某某某某 退出教室 用于b学生
Rectangle {
    id:tipClassOverWidgetItem

    property double widthRates: tipClassOverWidgetItem.width /  240.0
    property double heightRates: tipClassOverWidgetItem.height / 137.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates
    radius: 10 * ratesRates
    color: "#ffffff"

    //退出教室
    signal sigExitRoom();

    //留在教室
    signal sigStayInclassroom();

    //退出教室的名字
    property string  exitName: "郭靖"

    //提示姓名信息
    Item{
        id: tagNameBackGround
        anchors.left: parent.left
        anchors.top: parent.top
        width: 192 * widthRates
        height: 40 * heightRates
        anchors.leftMargin: 20 * widthRates
        anchors.topMargin: 16 * heightRates

        Text {
            id: tagName
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            font.bold: true
            font.pixelSize: 12 * heightRates
            color: "#222222"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text:  exitName + qsTr(" 退出教室")
        }
    }

    //提示信息
    Rectangle{
        id: contentNameBackGround
        anchors.left: parent.left
        anchors.top: parent.top
        width: 200 * widthRates
        height: 17 * heightRates
        anchors.leftMargin: 20 * widthRates
        anchors.topMargin: 60 * heightRates
        color: "#00000000"

        Text {
            id: contentName
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            font.pixelSize: 8 * heightRates
            color: "#3c3c3e"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: qsTr("您可留在教室等学生回来继续上课,教室内将保留您所有的操作。")
        }
    }

    Row{
        width: parent.width * 0.8
        height: 30 * heightRates
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10 * heightRates
        anchors.left: parent.left
        anchors.leftMargin: 20 * widthRates
        spacing: 10 * heightRates

        //退出按钮
        MouseArea{
            id: exitButton
            width: parent.width * 0.5
            height: 30 * heightRates

            Rectangle{
                anchors.fill: parent
                radius: 5 //* ratesRates
                border.color: "#cccccc"
                border.width: 1
            }

            Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 12 * heightRates
                color: "#999999"
                anchors.fill: parent
                font.family: "Microsoft YaHei"
                text: qsTr("退出")
            }

            cursorShape :Qt.PointingHandCursor
            onClicked: {
                sigExitRoom();
            }
        }

        //留在教室按钮
        MouseArea{
            width: parent.width * 0.5
            height: 30 * heightRates
            cursorShape :Qt.PointingHandCursor

            Rectangle{
                color: "#ff5000"
                radius: 5
                anchors.fill: parent
            }

            Text {
                color: "#ffffff"
                anchors.fill: parent
                text: qsTr("留在教室")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 12 * tipClassOverWidgetItem.heightRates
                font.family: "Microsoft YaHei"
            }

            onClicked: {
                sigStayInclassroom();
                tipClassOverWidgetItem.visible = false;
            }
        }
    }
}

