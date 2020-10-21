import QtQuick 2.0
import "./Configuuration.js" as Cfg

/**
*@brief 问题反馈页面
*@date      2019-04-24
*/

Rectangle {
    id: feedbackItem
    width: 370 * heightRate
    height: 280 * heightRate
    color: "#3D3F54"
//    opacity: 0

    signal sigFeedbackInfo(var feedbackTest);



    //head bar
    MouseArea{
        id: headBar
        width: 370 * heightRate
        height: 36 * heightRate

        Rectangle{
            anchors.fill: parent
            color: "#37394C"
            radius: 4 * heightRate
        }

        property point clickPos: "0,0"

        onPressed: {
            clickPos  = Qt.point(mouse.x,mouse.y)
        }

        onPositionChanged: {
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
            var moveX = saveBoards.x + delta.x;
            var moveY = saveBoards.y + delta.y;
            var moveWidth = saveBoards.parent.width - saveBoards.width;
            var moveHeight = saveBoards.parent.height - saveBoards.height;

            if( moveX > 0 && moveX < moveWidth) {
                saveBoards.x = saveBoards.x + delta.x;
            }else{
                var loactionX = moveX < 0 ? 0 : (moveX > moveWidth ? moveWidth : moveX);
                saveBoards.x = loactionX;
            }

            if(moveY  > 0 && moveY < moveHeight){
                saveBoards.y = saveBoards.y + delta.y;
            }else{
                saveBoards.y = moveY < 0 ? 0 : (moveY > moveHeight ? moveHeight : moveY);
            }
        }

        Text {
            anchors.centerIn: parent
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            text: qsTr("常见问题&解决方案")
//            font.bold: true
            color: "#ffffff"
        }

        MouseArea{
            width: 42 * heightRate
            height: 42 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 4 * heightRate
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true


            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/classImage/btn_pop_close_focused.png" : "qrc:/classImage/btn_pop_close_normal.png"
            }

            onClicked: {
                feedbackItem.visible = false;
            }
        }

    }

//    Rectangle {
//        id: bg
//        width: 379 * heightRate
//        height: 244 * heightRate
//        anchors.left: parent.left
//        anchors.top: headBar.bottom
//        color: "#3D3F54"
//    }

    Text {
        width: 370 * heightRate
        height: 14 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 30 * heightRate
        anchors.top: headBar.bottom
        anchors.topMargin: 16 * heightRate

        text: "如遇以下问题，请先查阅解决方案"
        color: "#9397BD"
        anchors.verticalCenter: parent.verticalCenter
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 14 * heightRate
    }

    ListView{
        id: feedListview
        width: 370 * heightRate
        height: parent.height - headBar.height - 40 * heightRate
        anchors.left: parent.left

        anchors.top: headBar.bottom
        anchors.topMargin: 46 * heightRate

        model: feedmodel
        delegate: feedComponent
    }

    ListModel{
        id: feedmodel
    }

    Component{
        id: feedComponent
        Item{
            width: feedListview.width
            height: 29 * heightRate

            Rectangle{
                id:ietmBackground
                anchors.fill: parent
                color: checkMouseArea.containsMouse ? "#39C5A8" : "#3D3F54"
            }

            MouseArea{
                id: checkMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    sigFeedbackInfo(feedbackText);
                    feedbackItem.visible = false;
                }
            }

            Text {
                text: feedbackText
                color: "#FFFFFF"
                anchors.left: parent.left
                anchors.leftMargin: 30 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
            }
        }
    }

    Component.onCompleted: {
        feedmodel.append({ "id":1, "feedbackText": "老师听不见学生声音" });
        feedmodel.append({ "id":2, "feedbackText": "学生听不见老师声" });
        feedmodel.append({ "id":3, "feedbackText": "摄像头异常,看不见老师人像画面" });
        feedmodel.append({ "id":4, "feedbackText": "摄像头异常,看不见学生人像画面" });
        feedmodel.append({ "id":5, "feedbackText": "翻动不了课件" });
        feedmodel.append({ "id":6, "feedbackText": "严重卡顿或延迟" });
    }
}
