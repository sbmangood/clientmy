import QtQuick 2.6
import QtQuick.Dialogs 1.2

Item {

    signal sigAccepted(var fileUrl); // 确定选择文件信号
    signal sigRejected();            // 取消选择文件信号

    // 浏览文件按钮
    Item {
        id: openBtn
        anchors.fill: parent
        // 上边框线
        Rectangle {
            width: parent.width
            height: 1
            color: "#4D90FF"
            anchors.top: parent.top
        }
        // 下边框线
        Rectangle {
            width: parent.width
            height: 1
            color: "#4D90FF"
            anchors.bottom: parent.bottom
        }
        // 左边框线
        Rectangle {
            width: 1
            height: parent.height
            color: "#4D90FF"
            anchors.left: parent.left
        }
        // 右边框线
        Rectangle {
            width: 1
            height: parent.height
            color: "#4D90FF"
            anchors.right: parent.right
        }
        Text {
            id: openBtnTxt
            text: qsTr("上传...")
            anchors.centerIn: parent
            color: "#ffffff"
            font.family: "Microsoft YaHei"
            font.pixelSize: 13 * heightRate
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
                fds.open();
            }
            onEntered: {
                openBtnTxt.color = "#4D90FF";
            }
            onExited: {
                openBtnTxt.color = "#ffffff";
            }
        }
    }
    // 选择文件会话框
    FileDialog {
        id: fds
        title: "选择文件"
        folder: shortcuts.desktop
        selectExisting: true
        selectFolder: false
        selectMultiple: false
        nameFilters: ["ALL Files(*)"]
        onAccepted: {
            var selectfile = fds.fileUrl.toString();
            var filesurl = selectfile.replace("file:///","");
            sigAccepted(filesurl);
        }
        onRejected: {
            sigRejected();
        }
    }
}
