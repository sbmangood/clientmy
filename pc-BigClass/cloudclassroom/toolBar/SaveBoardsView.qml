import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtWebEngine 1.4
import "./Configuration.js" as Cfg


Rectangle {
    id:saveBoards
    width: 420 * heightRate
    height: 274 * heightRate
    color: "#515369"
    radius: 4 * heightRate

    property bool bCurPage: true;
    property string strFileName: "";

    signal sigSaveBoardsOK(var bSaveCurPage, var fileName);
    signal sigSaveBoardsCancel();


    MouseArea{
        anchors.fill: parent
        onClicked: {
        }
    }

    //head bar
    MouseArea{
        id: headBar
        width: parent.width
        height: 36 * heightRate

        Rectangle{
            anchors.fill: parent
            color: "#515369"
            radius: 8 * heightRate
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
            anchors.left: parent.left
            anchors.leftMargin: 20 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 20 * heightRate
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 22 * heightRate
            text: qsTr("保存板书")
            font.bold: true
            color: "#ffffff"
        }

        MouseArea{
            width: 42 * heightRate
            height: 42 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8 * heightRate
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true


            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/classImage/btn_pop_close_focused.png" : "qrc:/classImage/btn_pop_close_normal.png"
            }

            onClicked: {
                saveBoards.visible = false;
//                fileName.text = "";
                strFileName = "";
                bCurPage = true;
                sigSaveBoardsCancel();
            }
        }

    }

    //saveSelect
    Item {
        id: saveSelect
        width: parent.width
        height: 24 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 17 * heightRate
        anchors.top: headBar.bottom
        anchors.topMargin: 28 * heightRate

        MouseArea {
            id: curPage
            width: 24 * heightRate
            height: 24 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            Image{
                anchors.fill: parent
                source: bCurPage ? "qrc:/classImage/btn_pop_radio_pressed.png" : "qrc:/classImage/btn_pop_radio_normal.png"
            }

            onClicked: {
                    bCurPage = true;
            }
        }
        Text {
            id: curPageText
            anchors.left: curPage.right
            anchors.leftMargin: 9 * heightRate
            width: 94 * heightRate
            height: 22 * heightRate

            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            text: qsTr("保存当前页")
            color: "#ffffff"
        }

        MouseArea {
            id: totalPage
            width: 24 * heightRate
            height: 24 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.left: curPageText.right
            anchors.leftMargin: 60 * heightRate
            anchors.bottom: parent.bottom
            visible: false

            Image{
                anchors.fill: parent
                source: bCurPage ? "qrc:/classImage/btn_pop_radio_normal.png" : "qrc:/classImage/btn_pop_radio_pressed.png"
            }

            onClicked: {
                    bCurPage = false;
            }
        }
        Text {
            anchors.left: totalPage.right
            anchors.leftMargin: 9 * heightRate
            width: 94 * heightRate
            height: 22 * heightRate
            visible: false

            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            text: qsTr("保存全部")
            color: "#ffffff"
        }

    }


    //fileInfo
    Item {
        id: fileInfo
        width: parent.width
        height: 38 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 20 * heightRate
        anchors.top: saveSelect.bottom
        anchors.topMargin: 18 * heightRate

        Text {
            id: fileText
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 72 * heightRate
            height: 22 * heightRate

            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            text: qsTr("文件名")
            color: "#ffffff"
        }

        TextField{
            id: fileName
             width: 264 * heightRate
             height: 38 * heightRate
             anchors.left: fileText.right
             anchors.top: parent.top
             selectByMouse: true
             //selectionColor: "#515369"

             text : "板书_" + Qt.formatDateTime(new Date(), "yyyyMMdd_hhmmss")
             //color: "#515369"
             font.pixelSize: 16 * heightRate
             font.family: Cfg.DEFAULT_FONT
             maximumLength: 18
             validator: RegExpValidator{regExp: /^[\u4e00-\u9fa5_a-zA-Z0-9]+$/ }
             anchors.verticalCenter: parent.verticalCenter
             onTextChanged: {
                strFileName = text;
             }

             style: TextFieldStyle{
                 background: Rectangle{
                     color: "#ffffff"
                     border.color:"#cccccc"
                     border.width: 1 * widthRate
                 }
                 textColor: "#515369"
                 placeholderTextColor: "#999999"
                 padding.left: 10 * widthRate
             }
             menu:null



         }
         Text {
             width: 44 * heightRate
             height: 22 * heightRate
             anchors.left: fileName.right
             anchors.verticalCenter: parent.verticalCenter
             text: qsTr(".png")
             font.family: Cfg.DEFAULT_FONT
             font.pixelSize: 18 * heightRate
//             font.bold: true
             color: "#ffffff"

         }

         Text {
             width: 44 * heightRate
             height: 20 * heightRate
             anchors.left: fileName.left
             anchors.top: parent.bottom
             anchors.topMargin: 10 * heightRate

             text: qsTr("仅支持输入中英文、数字与“_“，不得超过18个字")
             font.family: Cfg.DEFAULT_FONT
             font.pixelSize: 12 * heightRate
//             font.bold: true
             color: "#44CBB6"

         }
    }

    Item {
        id: location
        width: 110 * heightRate
        height: 22 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 20 * heightRate
        anchors.top: fileInfo.bottom
        anchors.topMargin: 37 * heightRate

        Text {
            width: 54 * heightRate
            height: 22 * heightRate
            anchors.left: location.left

            text: qsTr("位置：")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            font.bold: true
            color: "#ffffff"

        }

        Text {
            width: 44 * heightRate
            height: 22 * heightRate
            anchors.right: location.right
            anchors.bottom: parent.bottom

            text: qsTr("云盘")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
//            font.bold: true
            color: "#ffffff"

        }
    }

    Item {
        width: parent.width
        height: 50 * heightRate
        anchors.bottom: parent.bottom

        MouseArea {
            id: cancel
            width: parent.width * 0.5
            height: 50 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.left: parent.left

            Rectangle {
                anchors.fill: parent
                color: parent.containsMouse ? "#39C5A8" : "#484B5E"
                radius: 2 * heightRate

                Rectangle
                {
                    width: parent.width
                    height: 2 * heightRate
                    color: cancel.containsMouse ? "#39C5A8" : "#484B5E"
                }
                Rectangle
                {
                    width: 2 * heightRate
                    height: parent.height
                    anchors.right: parent.right
                    color: cancel.containsMouse ? "#39C5A8" : "#484B5E"
                }

            }

            Text {
                anchors.centerIn: parent
                text: qsTr("取消")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 18 * heightRate
//                font.bold: true
                color: "#ffffff"
            }
            onClicked: {
                strFileName = "";
                bCurPage = true;
                saveBoards.visible = false;
                sigSaveBoardsCancel();
//                fileName.text = "";
            }
        }

        MouseArea {
            id: ok
            width: parent.width * 0.5
            height: 50 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.right: parent.right

            Rectangle {
                anchors.fill: parent
                color: ok.containsMouse ? "#39C5A8" : "#424458"
                radius: 2 * heightRate

                Rectangle
                {
                    width: parent.width
                    height: 2 * heightRate
                    color: ok.containsMouse ? "#39C5A8" : "#424458"
                }
                Rectangle
                {
                    width: 2 * heightRate
                    height: parent.height
                    color: parent.containsMouse ? "#39C5A8" : "#424458"
                }
            }

            Text {
                anchors.centerIn: parent
                text: qsTr("确定")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 18 * heightRate
//                font.bold: true
                color: "#ffffff"
            }

            onClicked: {
                strFileName = fileName.text;
                sigSaveBoardsOK(bCurPage, strFileName);
                strFileName = "";
                bCurPage = true;
                saveBoards.visible = false;
//                fileName.text = "";
            }
        }

    }




}
