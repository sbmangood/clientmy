import QtQuick 2.0
import QtQuick.Controls 1.4
import "./../Configuration.js" as Cfg
import YMLessonManagerAdapter 1.0

/***云盘首页***/

Item {
    id: lessonView
    anchors.fill: parent
    focus: true

    YMLessonManagerAdapter{
        id: lessonMgr
        onLoadingFinished:{
            loadingView.opacityAnimation = !loadingView.opacityAnimation;
        }
        onRequstTimeOuted:{
            enterClassRoom = true;
            networkItem.visible = true;
            classView.visible = false;
            loadingView.opacityAnimation = !loadingView.opacityAnimation;
        }

    }

    YMLoadingStatuesView{
        id:loadingView
        z: 100
        anchors.fill: parent
        visible: false
        onChangeVisible:
        {
            loadingView.visible=false;
        }
    }


    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Up:
            if(filckable.contentY > 0){
                filckable.contentY -= 20;
            }
            break;
        case Qt.Key_Down:
            if(button.y < scrollbar.height-button.height){
                filckable.contentY += 20;
            }
            break;
        default:
            return;
        }
        event.accepted = true
    }

    Flickable{
        id :filckable
        z: 1
        width: parent.width
        height: parent.height - headItem2.height - headItem.height - 5
        contentWidth: width
        contentHeight: cloudViewModel.count * 60 * heightRate
        anchors.top: headItem2.bottom

        ListView{
            id:lessonListView
            width: parent.width - 20
            height: cloudViewModel.count * 60 * heightRate
            delegate: contentComponent
            model: cloudViewModel
            anchors.horizontalCenter: parent.horizontalCenter
        }

    }

    //网络显示提醒
    Rectangle{
        id: networkItem
        z: 86
        visible: false
        anchors.fill: parent
        radius: 12 * widthRate
        anchors.top: headItem2.bottom
        Image{
            id: netIco
            width: 60 * widthRate
            height: 60 * widthRate
            source: "qrc:/images/icon_nowifi.png"
            anchors.top: parent.top
            anchors.topMargin: (parent.height - (30 * heightRate) * 2 - (10 * heightRate) - height) * 0.5
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text{
            id: netText
            height: 30 * heightRate
            text: "网络不给力,请检查您的网络～"
            anchors.top: netIco.bottom
            anchors.topMargin: 10 * heightRate
            font.family: Cfg.LESSON_FONT_FAMILY
            font.pixelSize: Cfg.LESSON_2FONTSIZE * heightRate
            verticalAlignment: Text.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Rectangle{
            width: 80 * widthRate
            height: 30 * heightRate
            border.color: "#808080"
            border.width: 1
            radius: 4
            anchors.top: netText.bottom
            anchors.topMargin: 10 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            Text{
                text: "刷新"
                font.family: Cfg.LESSON_FONT_FAMILY
                font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
                anchors.centerIn: parent
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    refreshPage();
                }
            }
        }
    }

    //滚动条
    Rectangle {
        id: scrollbar
        z: 66
        width: 10
        height: parent.height - headItem2.height - headItem.height
        anchors.top: headItem2.bottom
        anchors.right: parent.right
        Rectangle{
            width: 2
            height: lessonListView.height
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: filckable.visibleArea.yPosition * scrollbar.height
            width: 6
            height: filckable.visibleArea.heightRatio * scrollbar.height;
            color: "#cccccc"
            radius: 4 * widthRate

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
                    filckable.contentY = button.y / scrollbar.height * filckable.contentHeight
                }
            }
        }
    }

    ListModel{
        id: cloudViewModel
    }

    Component{
        id: contentComponent
    }

    Component.onCompleted: {
    }

}

