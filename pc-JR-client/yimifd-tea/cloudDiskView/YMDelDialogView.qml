import QtQuick 2.0
import QtQuick.Controls 1.4
import "./Configuration.js" as Cfg

Item {
    width: 400 * widthRate
    height: 188 * heightRate

    signal sigDelConfirm();
    signal sigDelCancel();

    // 背景
    Image {
        anchors.fill: parent
        source: "qrc:/cloudDiskImages/deldialog.png"
    }

    // 右上角X
    Item {
        width: 36 * widthRate
        height: 36 * heightRate
        anchors.top: parent.top
        anchors.right: parent.right
        Image {
            id: closeImg
            anchors.fill: parent
            source: "qrc:/cloudDiskImages/btn_pop_close_released.png"
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
                sigDelCancel();
            }
            onEntered: {
                closeImg.source = "qrc:/cloudDiskImages/btn_pop_close_focused.png";
            }
            onExited: {
                closeImg.source = "qrc:/cloudDiskImages/btn_pop_close_released.png";
            }
        }
    }

    // 提示Title
    Text {
        width: 94 * widthRate
        height: 22 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 20 * widthRate
        anchors.top: parent.top
        anchors.topMargin: 20 * heightRate
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        text: qsTr("提示")
        color: "#FFFFFF"
        font.pixelSize: 22 * heightRate
        font.family: Cfg.DEFAULT_FONT
        font.bold: true
    }

    // 提示内容
    Text {
        width: 320 * widthRate
        height: 22 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 50 * widthRate
        anchors.top: parent.top
        anchors.topMargin: 66 * heightRate
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("确定要删除选中的课件吗？")
        color: "#FFFFFF"
        font.pixelSize: 18 * heightRate
        font.family: Cfg.DEFAULT_FONT
        font.wordSpacing: 12 * heightRate
    }

    // 底部bar
    Row {
        width: parent.width
        height: 50 * heightRate
        anchors.bottom: parent.bottom
        // 取消按钮
        Rectangle {
            width: parent.width / 2
            height: parent.height
            color: "#484B5E"
            radius: 4 * heightRate

            Rectangle
            {
                width: parent.width
                height: 4 * heightRate
                color: "#484B5E"
            }

            Rectangle
            {
                width:4 * heightRate
                height: parent.height
                color: "#484B5E"
                anchors.right: parent.right
            }
            Text {
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("取消")
                color: "#FFFFFF"
                font.pixelSize: 18 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    sigDelCancel();
                }
            }
        }
        // 确定按钮
        Rectangle {
            width: parent.width / 2
            height: parent.height
            color: "#39C5A8"            
            radius: 4 * heightRate
            Rectangle
            {
                width: parent.width
                height: 4 * heightRate
                color: "#39C5A8"
            }

            Rectangle
            {
                width:4 * heightRate
                height: parent.height
                color: "#39C5A8"
            }

            Text {
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("确定")
                color: "#FFFFFF"
                font.pixelSize: 18 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    sigDelConfirm();
                }
            }
        }
    }
}
