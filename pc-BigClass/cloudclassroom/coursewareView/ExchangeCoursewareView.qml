import QtQuick 2.0
import QtQuick.Controls 1.4
import "./Configuration.js" as Cfg

Item {
    id: exchangeView
    width: 420 * widthRate
    height: 188 * heightRate

    signal sigChangelConfirm();
    signal sigChangeCancel();

    property string currentCourswareType: ""
    property string currentFileId: ""
    property string currentH5Url: ""
    property string currentAVUrl: ""
    property string currentFileName: ""

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
            anchors.fill: parent
            source: "qrc:/cloudDiskImages/btn_pop_close_focused.png"
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
                sigChangeCancel();
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
        text: qsTr("提示:")
        color: "#FFFFFF"
        font.pixelSize: 22 * heightRate
        font.family: Cfg.DEFAULT_FONT
    }

    // 提示内容
    Text {
        width: 320 * widthRate
        height: 42 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 50 * widthRate
        anchors.top: parent.top
        anchors.topMargin: 66 * heightRate
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("当前已有相同类型课件正在使用中，\n确认是否替换？")
        color: "#FFFFFF"
        font.pixelSize: 18 * heightRate
        font.family: Cfg.DEFAULT_FONT
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
                    sigChangeCancel();
                }
            }
        }
        // 确定按钮
        Rectangle {
            width: parent.width / 2
            height: parent.height
            color: "#39C5A8"
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
                    sigChangelConfirm();
                }
            }
        }
    }

    function setExchangeViewInfo(courswareType, fileId, fileName, h5Url, avUrl){
        currentCourswareType = courswareType;
        currentFileId = fileId;
        currentH5Url = h5Url;
        currentAVUrl = avUrl;
        currentFileName = fileName;
        exchangeView.visible = true;
    }

    function getExchangeViewInfo(){
        var info = {};
        info["currentCourswareType"] = currentCourswareType;
        info["currentFileId"] = currentFileId;
        info["currentH5Url"] = currentH5Url;
        info["currentAVUrl"] = currentAVUrl;
        info["currentFileName"] = currentFileName;
        return info;
    }
}
