import QtQuick 2.0

/*
*清除画布提醒页面
*/

Item {
    id: roleView

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property string userName: "";//用户名称

    signal sigRefuse();//拒绝信号
    signal sigOk();//同意信号

    Rectangle{
        id: backView
        width: 240 * widthRates;
        height: 160 * heightRates;
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
                    sigRefuse();
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
        anchors.topMargin: 25 * heightRates
        anchors.horizontalCenter: backView.horizontalCenter
        spacing: 10 * widthRates

        Text {
            id: userNameText
            height: 35 * heightRates
            width: parent.width
            font.pixelSize: 20 * heightRates
            font.family: "Microsoft YaHei"
            text: qsTr("清屏")
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            width: parent.width
            height: 35 * heightRates
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("执行该操作将会清除当前所有内容! ")
            font.family: "Microsoft YaHei"
            font.pixelSize: 12 * heightRates
            color: "#666666"
        }
    }
    //显示界面
    function showWindow(){
        roleView.visible = true;
    }

    //隐藏界面
    function hideWindow(){
        roleView.visible = false;
    }
}

