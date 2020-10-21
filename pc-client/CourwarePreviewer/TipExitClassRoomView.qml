import QtQuick 2.0

/*
*退出教室提醒页面
*/

Item {
    id: exitClassRoomView

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property string userName: "";//用户名称

    signal sigStayInclassroom();//留在教室信号
    signal sigExitClassroom();//退出信号

    Rectangle{
        id: backView
        width: 240 * widthRates;
        height: 180 * heightRates;
        radius:  6
        anchors.centerIn: parent
        color: "#ffffff"

        Row{
            width: parent.width * 0.8
            height: 35
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10 * heightRates

            MouseArea{
                width: parent.width  * 0.5
                height: parent.height
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRates
                    color: "#ffffff"
                    border.color: "#cccccc"
                    border.width: 1
                }

                Text {
                    text: qsTr("留在教室")
                    color:  "#cccccc"
                    font.pixelSize: 16 * heightRates
                    font.family: "Microsoft YaHei"
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigStayInclassroom();
                }
            }

            MouseArea{
                width: parent.width  * 0.5
                height: parent.height
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRates
                    color: "#ff5000"
                    border.color: "#cccccc"
                    border.width: 1
                }

                Text {
                    text: qsTr("退出")
                    color:  "#ffffff"
                    font.pixelSize: 16 * heightRates
                    font.family: "Microsoft YaHei"
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigExitClassroom();
                }
            }
        }
    }

    Column{
        width: backView.width * 0.8
        height: backView.height
        anchors.top: backView.top
        anchors.topMargin: 25 * heightRates
        anchors.horizontalCenter: backView.horizontalCenter
        spacing: 10 * heightRates

        Text {
            id: userNameText
            height: 45 * heightRates
            width: parent.width
            font.pixelSize: 20 * heightRates
            font.family: "Microsoft YaHei"
            text: qsTr("学生 ") + userName + " 退出教室"
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle{
            width: parent.width * 0.9
            height: 30 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                width: parent.width
                text: qsTr("您可以留在教室继续等学生回来上课,教室内将保留您所有操作。")
                font.family: "Microsoft YaHei"
                font.pixelSize: 12 * heightRates
                wrapMode: Text.WordWrap
                color: "#666666"
            }
        }
    }
    //显示界面
    function showWindow(){
        exitClassRoomView.visible = true;
    }

    //隐藏界面
    function hideWindow(){
        exitClassRoomView.visible = false;
    }
}

