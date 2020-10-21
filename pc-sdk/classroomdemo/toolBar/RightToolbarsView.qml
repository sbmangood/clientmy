import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuration.js" as Cfg

Item {
    id: toolbarsMainView
    width: 65 * heightRate
    height: 240 * heightRate

    property int updateIndex: -1;

    signal sigSendFunctionKey(var keys);//点击的按钮

    Image {
        anchors.fill: parent
        source: "qrc:/images/gongjulan.png"
    }

    Column {
        width: parent.width - 12 * heightRate
        height: parent.height - 260 * heightRate
        anchors.top: parent.top
        anchors.topMargin:  22 * heightRate
        anchors.right: parent.right
        spacing: 0

        //指针
        MouseArea {
            width: 16 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/images/xb_icon_select_sed.png"  :  (updateIndex == 2 ? "qrc:/images/xb_icon_select_sed.png" :"qrc:/images/xb_icon_select.png")
            }

            onClicked: {
                updateIndex = 2;
                 sigSendFunctionKey(0);
            }
            onContainsMouseChanged: {
                if(containsMouse){
                    hoverTxt1.text = "点击";
                }
                else{
                    hoverTxt1.text = " ";
                }
            }
        }

        Text {
            id: hoverTxt1
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }

        //画笔
        MouseArea {
            width: 25 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                id: brushImg
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/images/xb_icon_brush_sed.png" : (updateIndex == 3 ? "qrc:/images/xb_icon_brush_sed.png" : "qrc:/images/xb_icon_brush.png")
            }

            onClicked: {
                updateIndex = 3;
                sigSendFunctionKey(1);
            }
            onContainsMouseChanged: {
                if(containsMouse){
                    hoverTxt2.text = "画笔";
                }else{
                    hoverTxt2.text = " ";
                }
            }
        }

        Text {
            id: hoverTxt2
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }

        //橡皮
        MouseArea {
            width: 28 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/images/xb_icon_erase_sed.png" : (updateIndex == 4 ? "qrc:/images/xb_icon_erase_sed.png" :"qrc:/images/xb_icon_erase.png")
            }

            onClicked: {
                updateIndex = 4;                
                sigSendFunctionKey(4);
            }
            onContainsMouseChanged: {
                if(containsMouse){
                    hoverTxt3.text = "橡皮";
                }else{
                    hoverTxt3.text = " ";
                }
            }
        }

        Text {
            id: hoverTxt3
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }

        //教鞭
        MouseArea {
            width: 26 * heightRate
            height: 26 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/images/xb_icon_magicwand_sed.png" : (updateIndex == 5 ? "qrc:/images/xb_icon_magicwand_sed.png" :"qrc:/images/xb_icon_magicwand.png")
            }

            onClicked: {
                updateIndex = 5;
                sigSendFunctionKey(5)
            }
            onContainsMouseChanged: {
                if(containsMouse){
                    hoverTxt4.text = "教鞭";
                }
                else{
                    hoverTxt4.text = " ";
                }
            }
        }

        Text {
            id: hoverTxt4
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }
        //云盘
        MouseArea {
            width: 26 * heightRate
            height: 18 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/images/xb_icon_cloudpan_sed.png" : (updateIndex == 6 ? "qrc:/images/xb_icon_cloudpan_sed.png" :"qrc:/images/xb_icon_cloudpan.png")
            }

            onClicked: {
                updateIndex = 6;
                sigSendFunctionKey(6);
            }

            onContainsMouseChanged: {
                if(containsMouse){
                    hoverTxt5.text = "云盘";
                }else{
                    hoverTxt5.text = " ";
                }
            }
        }

        Text {
            id: hoverTxt5
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
