import QtQuick 2.6
import QtQuick.Dialogs 1.2

Item {

    signal sigAccepted(var fileUrl); // 确定选择文件信号
    signal sigRejected();            // 取消选择文件信号

    // 浏览文件按钮
    Rectangle {
        id: openBtn
        anchors.fill: parent
        color: "#39C5A8"
        radius: 2 * heightRate
        Text {
            id: openBtnTxt
            text: qsTr("上传")
            anchors.centerIn: parent
            color: "#ffffff"
            font.family: "Microsoft YaHei"
            font.pixelSize: 16 * heightRate
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
        nameFilters: ["Supported Files(*.ppt *.pptx *.jpg *.png *.doc *.docx *.mp3 *.mp4 *.avi *.pdf)"]
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
