import QtQuick 2.0

/*
*进入教室失败提醒页面
*/

Item {
    id: enterClassRoomView

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    signal sigCancel();//取消信号
    signal sigOk();//确认退出信号

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
                    text: qsTr("取消")
                    color:  "#cccccc"
                    font.pixelSize: 16 * heightRates
                    font.family: "Microsoft YaHei"
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigCancel();
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
                    text: qsTr("确认")
                    color:  "#ffffff"
                    font.pixelSize: 16 * heightRates
                    font.family: "Microsoft YaHei"
                    anchors.centerIn: parent
                }
                onClicked: {
                    sigOk();
                }
            }
        }
    }

    Column{
        width: backView.width * 0.8
        height: backView.height
        anchors.top: backView.top
        anchors.topMargin: 45 * heightRates
        anchors.horizontalCenter: backView.horizontalCenter

        Text {
            id: userNameText
            height: 45 * heightRates
            width: parent.width
            font.pixelSize: 20 * heightRates
            font.family: "Microsoft YaHei"
            text: qsTr("进入教室失败")
            horizontalAlignment: Text.AlignHCenter
        }
    }
    //显示界面
    function showWindow(){
        enterClassRoomView.visible = true;
    }

    //隐藏界面
    function hideWindow(){
        enterClassRoomView.visible = false;
    }
}

