import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "./Configuration.js" as Cfg

//录播列表
Item {
    id: playListView
    anchors.fill: parent

    signal sigSetVisible();//设置隐藏面板信号
    signal sigPlayUrl(var url);//录播链接信号

    function resetModelData(jsonData){
        recordModel.clear();

        for(var i = 0; i < jsonData.length; i++){
            var tObj = jsonData[i];
            recordModel.append({
                                   indexssName: "录播:"+ (i + 1).toString(),
                                   title:tObj.fileName,
                                   jumpUrl:tObj.path
                               })
        }
    }

    Rectangle{
        anchors.fill: parent
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
        radius: 12
    }

    //按键盘上下进行滚动页面
    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Up:
            if(talkCloudGridView.contentY > 0){
                talkCloudGridView.contentY -= 20;
            }
            break;
        case Qt.Key_Down:
            if(button.y < scrollbar.height - button.height){
                talkCloudGridView.contentY += 20;
            }
            break;
        default:
            return;
        }
        event.accepted = true
    }

    //滚动条
    Item {
        id: scrollbar
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 12 * heightRate
        width:10 * widthRate
        height: parent.height - 20 * heightRate
        z: 23
        Rectangle{
            width: 2
            height: parent.height
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: talkCloudGridView.visibleArea.yPosition * scrollbar.height
            width: 6 * widthRate
            height: talkCloudGridView.visibleArea.heightRatio * scrollbar.height;
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
                    talkCloudGridView.contentY = button.y / scrollbar.height * talkCloudGridView.contentHeight
                }
            }
        }
    }

    MouseArea{
        anchors.fill: parent
        onClicked:{
            return;
        }
    }

    Rectangle{
        width: 25 * widthRate
        height: 25 * widthRate
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 15 * widthRate
        anchors.leftMargin: 15 * widthRate
        Image {
            anchors.fill: parent
            source: "qrc:/talkcloudImage/xbk_btn_back@2x.png"
        }

        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:{
                playListView.visible = false;
                sigSetVisible();
            }
        }
    }


    Rectangle{
        width: parent.width * 0.9
        height: parent.height * 0.87
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.09//25
        anchors.horizontalCenter:parent.horizontalCenter

        GridView{
            id: talkCloudGridView
            anchors.fill: parent
            anchors.centerIn: parent
            clip: true
            cellWidth: talkCloudGridView.width / 4
            cellHeight: talkCloudGridView.height / 3
            model: recordModel
            delegate: talkcomponent
        }
    }

    ListModel{
        id: recordModel
    }

    Component{
        id: talkcomponent
        Item{
            width: talkCloudGridView.cellWidth - 25 * widthRate
            height: talkCloudGridView.cellHeight - 15 * widthRate
            //背景颜色
            Rectangle{
                color: tmouse.containsMouse ? "#FFF3ED" : "#f9f9f9"
                anchors.fill: parent
                border.width: tmouse.containsMouse ? 1 : "0"
                border.color: tmouse.containsMouse ? "#FFC3A6" : "#f9f9f9"
                radius: 2 * widthRate
                //点击按钮
                MouseArea{
                    id:tmouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        console.log("==jumpUrl==",jumpUrl);
                        //sigPlayUrl(jumpUrl);
                        Qt.openUrlExternally(jumpUrl);
                    }
                }

                //课程图文
                Image{
                    id: videoImg
                    width: parent.width / 4.736
                    height: width * 1.241
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 24 * widthRate
                    source: "qrc:/talkcloudImage/xbk_icon_video.png"
                }

                Text {
                    anchors.top:videoImg.bottom
                    anchors.topMargin: 5 * widthRate
                    text: indexssName
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 12 * widthRate
                    color: "#000000"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    anchors.top:videoImg.bottom
                    anchors.topMargin: 28 * widthRate
                    text: title
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 12 * widthRate
                    color: "#000000"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

}
