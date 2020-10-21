import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuuration.js" as Cfg

Item {
    id: toolbarsMainView
    width: 65 * heightRate
    height: 480 * heightRate

    property int updateIndex: -1;

    signal sigSendFunctionKey(var keys);//点击的按钮

    Image{
        anchors.fill: parent
        source: "qrc:/miniClassImage/gongjulan.png"
    }

    Column{
        width: parent.width - 12 * heightRate
        height: parent.height - 20 * heightRate
        anchors.top: parent.top
        anchors.topMargin:  22 * heightRate
        anchors.right: parent.right
        spacing: 0//20 * heightRate

        //移动
        MouseArea{
            width: 26 * heightRate
            height: 26 * heightRate
            hoverEnabled: true
            enabled: false
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_move_sed.png"  : (updateIndex == 1 ? "qrc:/miniClassImage/xb_icon_move_sed.png" :  "qrc:/miniClassImage/xb_icon_move.png")
            }

            onClicked: {
                updateIndex = 1;
            }
        }

        Text{
            id: hoverTxt
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }

        //指针
        MouseArea{
            width: 16 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_select_sed.png"  :  (updateIndex == 2 ? "qrc:/miniClassImage/xb_icon_select_sed.png" :"qrc:/miniClassImage/xb_icon_select.png")
            }

            onClicked: {
                updateIndex = 2;
                 sigSendFunctionKey(0);
            }
            onContainsMouseChanged: {
                if(containsMouse){
                    hoverTxt1.text = "点击";
                }else{
                    hoverTxt1.text = " ";
                }
            }
        }

        Text{
            id: hoverTxt1
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }


        //画笔
        MouseArea{
            width: 25 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                id: brushImg
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_brush_sed.png" : (updateIndex == 3 ? "qrc:/miniClassImage/xb_icon_brush_sed.png" : "qrc:/miniClassImage/xb_icon_brush.png")
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

        Text{
            id: hoverTxt2
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }

        //橡皮
        MouseArea{
            width: 28 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_erase_sed.png" : (updateIndex == 4 ? "qrc:/miniClassImage/xb_icon_erase_sed.png" :"qrc:/miniClassImage/xb_icon_erase.png")
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

        Text{
            id: hoverTxt3
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }

        //教鞭
        MouseArea{
            width: 26 * heightRate
            height: 26 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_magicwand_sed.png" : (updateIndex == 5 ? "qrc:/miniClassImage/xb_icon_magicwand_sed.png" :"qrc:/miniClassImage/xb_icon_magicwand.png")
            }

            onClicked: {
                updateIndex = 5;
                sigSendFunctionKey(5)
            }
            onContainsMouseChanged: {
                if(containsMouse){
                    hoverTxt4.text = "教鞭";
                }else{
                    hoverTxt4.text = " ";
                }
            }
        }

        Text{
            id: hoverTxt4
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }
        //云盘
        MouseArea{
            width: 26 * heightRate
            height: 18 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_cloudpan_sed.png" : (updateIndex == 6 ? "qrc:/miniClassImage/xb_icon_cloudpan_sed.png" :"qrc:/miniClassImage/xb_icon_cloudpan.png")
                //qrc:/miniClassImage/xb_icon_cloudpan_sed.png
            }

            onClicked: {
                //updateIndex = 6;
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

        Text{
            id: hoverTxt5
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }

        //工具箱
        MouseArea{
            width: 25 * heightRate
            height: 25 * heightRate
            enabled: true
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_tool_sed.png" : (updateIndex == 7 ? "qrc:/miniClassImage/xb_icon_tool_sed.png" : "qrc:/miniClassImage/xb_icon_tool.png")
                //qrc:/miniClassImage/xb_icon_tool_sed.png
            }

            onClicked: {
                //updateIndex = 7;
                sigSendFunctionKey(7);
            }

            onContainsMouseChanged: {
                if(containsMouse){
                    hoverTxt6.text = "工具箱";
                }else{
                    hoverTxt6.text = " ";
                }
            }
        }

        Text{
            id: hoverTxt6
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }

        //花名册
        MouseArea{
            width: 25 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_peoplebook_sed.png" : (updateIndex == 8 ? "qrc:/miniClassImage/xb_icon_peoplebook_sed.png" : "qrc:/miniClassImage/xb_icon_peoplebook.png")
            }

            onClicked: {
                //updateIndex = 8;
                sigSendFunctionKey(8);
            }

            onContainsMouseChanged: {
                if(containsMouse){
                    hoverTxt7.text = "花名册";
                }else{
                    hoverTxt7.text = " ";
                }
            }
        }

        Text{
            id: hoverTxt7
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }

        //问题反馈
        MouseArea{
            width: 25 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/feedback_sed.png" : (updateIndex == 10 ? "qrc:/miniClassImage/feedback_sed.png" : "qrc:/miniClassImage/feedback.png")
            }

            onClicked: {
                //updateIndex = 10;
                sigSendFunctionKey(10);
            }

            onContainsMouseChanged: {
                if(containsMouse){
                    hoverTxt8.text = "问题反馈";
                }else{
                    hoverTxt8.text = " ";
                }
            }
        }

        Text{
            id: hoverTxt8
            height: 20 * heightRate
            text: " "
            color: "#666666"
            font.pixelSize: 12 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.horizontalCenter: parent.horizontalCenter
        }

        //收起按钮
        MouseArea{
            width: parent.width
            height: 45 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            //横线
            Rectangle{
                width: parent.width - 8  * heightRate
                height: 2 * heightRate
                color: "#eeeeee"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 4 * heightRate
            }

            Image{
                width: 17 * heightRate
                height: 20 * heightRate
                anchors.top: parent.top
                anchors.topMargin: (parent.height - height) * 0.5 - 2 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_shouqi_sed.png" : "qrc:/miniClassImage/xb_icon_shouqi.png"
            }

            onClicked: {
                //updateIndex = 9;
                sigSendFunctionKey(9);
            }

            Text{
                visible: parent.containsMouse ? true : false
                text: "收起"
                color: "#666666"
                font.pixelSize: 12 * heightRate
                font.family: Cfg.DEFAULT_FONT
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }

    }

    function setSelectPointer()
    {
        updateIndex = 2;
        sigSendFunctionKey(0);
    }

}
