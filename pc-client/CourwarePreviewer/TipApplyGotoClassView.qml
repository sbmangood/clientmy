import QtQuick 2.0

/*
*B学生申请进入教室页面
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
            height: 30 * heightRates
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
                    text: qsTr("拒绝")
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
                    text: qsTr("同意")
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
        spacing: 15 * widthRates

        Text {
            id: userNameText
            height: 35 * heightRates
            width: parent.width
            font.pixelSize: 20 * heightRates
            font.family: "Microsoft YaHei"
            text: qsTr("申请权限")
            horizontalAlignment: Text.AlignHCenter
        }
        Row{
            width: parent.width * 0.8
            height: 35 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("学生 ")
                font.family: "Microsoft YaHei"
                font.pixelSize: 12 * heightRates
                color: "#666666"
            }
            Text {
                horizontalAlignment: Text.AlignHCenter
                text: userName
                font.family: "Microsoft YaHei"
                font.pixelSize: 12 * heightRates
            }
            Text {
                horizontalAlignment: Text.AlignHCenter
                text: qsTr(" 正在申请进入教室!")
                font.family: "Microsoft YaHei"
                font.pixelSize: 12 * heightRates
                color: "#666666"
            }
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

