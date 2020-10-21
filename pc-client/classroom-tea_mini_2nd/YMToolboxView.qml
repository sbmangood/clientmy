import QtQuick 2.0
import "./Configuuration.js" as Cfg

//工具箱
Item {
    width: 150 * heightRate
    height: 75 * heightRate

    Image {
        source: "qrc:/miniClassImage/toolbar.png"
        width: parent.width
        height: 60 * heightRate
    }

    signal sigSelectedIndex(var index);

    Row{
        id: toolRow
        width: parent.width - 40 * heightRate
        height: 45 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 8 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10 * widthRate

        MouseArea{
            width: 25 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.verticalCenter: parent.verticalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_jsq_sed.png" : "qrc:/miniClassImage/xb_icon_jsq.png"
            }

            onClicked: {
                sigSelectedIndex(0);
            }

            onContainsMouseChanged: {
                if(containsMouse){
                    item1.visible = true;
                }else{
                    item1.visible = false;
                }
            }
        }

        MouseArea{
            width: 25 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.verticalCenter: parent.verticalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ?  "qrc:/miniClassImage/xb_icon_sjxr_sed.png" : "qrc:/miniClassImage/xb_icon_sjxr.png"
            }

            onClicked: {
                sigSelectedIndex(1);
            }

            onContainsMouseChanged: {
                if(containsMouse){
                    item2.visible = true;
                }else{
                    item2.visible = false;
                }
            }
        }

        MouseArea{
            width: 25 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.verticalCenter: parent.verticalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_qiangda_sed.png" : "qrc:/miniClassImage/xb_icon_qiangda.png"
            }

            onClicked: {
                sigSelectedIndex(2);
            }

            onContainsMouseChanged: {
                if(containsMouse){
                    item3.visible = true;
                }else{
                    item3.visible = false;
                }
            }
        }

    }

    //鼠标进入提醒字样
    Item{
        width: parent.width - 20 * heightRate
        height: 20 * heightRate
        anchors.top: toolRow.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle{
            id: item1
            width: 32 * widthRate
            height: 12 * widthRate
            anchors.left: parent.left
            anchors.leftMargin: 4 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            border.width: 1 * heightRate
            border.color: "#dddddd"
            color: "#f8f8f8"
            visible: false

            Text {
                text: qsTr("计时器")
                color: "#666666"
                visible: parent.visible
                anchors.centerIn: parent
                font.pixelSize: 12 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }
        }


        Rectangle{
            id: item2
            width: 38 * widthRate
            height: 12 * widthRate
            border.width: 1 * heightRate
            border.color: "#dddddd"
            color: "#f8f8f8"
            visible: false
            anchors.left: item1.right
            anchors.leftMargin: -16 * heightRate

            Text {
                text: qsTr("随机选人")
                color: "#666666"
                anchors.centerIn: parent
                font.pixelSize: 12 * heightRate
                font.family: Cfg.DEFAULT_FONT
                visible: parent.visible
            }
        }

        Rectangle{
            id: item3
            width: 32 * widthRate
            height: 14 * widthRate
            border.width: 1 * heightRate
            border.color: "#dddddd"
            color: "#f8f8f8"
            visible: false
            anchors.left: item2.right
            anchors.leftMargin: -12 * heightRate

            Text {
                text: qsTr("抢答器")
                color: "#666666"
                anchors.centerIn: parent
                font.pixelSize: 12 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }
        }

    }

}
