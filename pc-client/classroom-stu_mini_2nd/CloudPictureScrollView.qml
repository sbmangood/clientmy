import QtQuick 2.0
import QtQuick.Controls 2.0
import "Configuration.js" as Cfg

/*
*图片浏览页面
*/

Item {
    property string imageUrl: "";

    Flickable{
        id: imgScroll
        width: parent.width
        height: parent.height
        contentHeight: img.height
        contentWidth: width
        clip: true

        Image{
            id: img
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectCrop
            source: imageUrl

            onStatusChanged: {
                console.log("===== img.sourceSize=====", img.sourceSize)
                img.height = img.sourceSize.height
            }

        }
    }

    //滚动条
    Item {
        id: scrollbar
        anchors.right: imgScroll.right
        anchors.top: parent.top
        width:12 * heightRate
        height:imgScroll.height
        z: 2
        Rectangle{
            anchors.fill: parent
            color: "#eeeeee"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: imgScroll.visibleArea.yPosition * scrollbar.height
            width: parent.width
            height: imgScroll.visibleArea.heightRatio * scrollbar.height;
            color: "#ff5000"
            radius: 8 * heightRate

            // 鼠标区域
            MouseArea {
                id: mouseArea
                anchors.fill: button
                drag.target: button
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: scrollbar.height - button.height
                cursorShape: Qt.PointingHandCursor
                // 拖动
                onMouseYChanged: {
                    imgScroll.contentY = button.y / scrollbar.height * imgScroll.contentHeight
                }
            }
        }
    }
}
