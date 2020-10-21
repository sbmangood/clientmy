import QtQuick 2.0

Item {
    id: rootItem

    property bool isBigScreen: true;
    Image {
        id: image
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        fillMode: Image.Pad
        source: {
            if(isBigScreen)
                return "qrc:/cloudDiskImages/bg_wjzclx.png";
             else
                 return "qrc:/cloudDiskImages/bg_fileInfo.png";
            }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: {
            rootItem.visible = true;
        }
        onExited: {
            rootItem.visible = false;
        }
    }
}
