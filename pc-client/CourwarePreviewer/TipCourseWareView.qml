import QtQuick 2.0

/*
*删除课件页提醒
*/

Item {
    id: tipCourseWareView

    property double widthRates: fullWidths / 1340;
    property double heightRates: fullHeights / 900;
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    signal sigCancel();//取消信号
    signal sigOk();//确认信号

    Rectangle{
        id: backView
        width: 240 * widthRates;
        height: 180 * heightRates;
        radius:  6
        anchors.centerIn: parent
        color: "#ffffff"

        Row{
            width: parent.width * 0.8
            height: 35 * heightRates
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * heightRates
            anchors.left: parent.left
            anchors.leftMargin: (parent.width - width) * 0.4
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
                    font.pixelSize: 14 * heightRates
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
                    text: qsTr("确定")
                    color:  "#ffffff"
                    font.pixelSize: 14 * heightRates
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
        spacing: 10 * widthRates

        Text {
            height: 35 * heightRates
            width: parent.width
            font.pixelSize: 16 * heightRates
            font.family: "Microsoft YaHei"
            text: qsTr("您确定要删除当前页面吗?")
            horizontalAlignment: Text.AlignHCenter
        }
    }
    //显示界面
    function showWindow(){
        tipCourseWareView.visible = true;
    }

    //隐藏界面
    function hideWindow(){
        tipCourseWareView.visible = false;
    }
}


