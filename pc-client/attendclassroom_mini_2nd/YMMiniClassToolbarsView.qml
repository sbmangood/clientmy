import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuration.js" as Cfg

Item {
    id: toolbarsMainView
    width: 54 * heightRate
    height: 6 * 52 * heightRate

    property int updateIndex: -1;
    property bool disableButton: true;

    signal sigSendFunctionKey(var keys);//点击的按钮

    Image{
        anchors.fill: parent
        source: "qrc:/miniClassImage/shadowback.png"
    }

    Column{
        width: parent.width - 12 * heightRate
        height: parent.height - 40 * heightRate
        anchors.top: parent.top
        anchors.topMargin:  22 * heightRate
        anchors.right: parent.right
        spacing: 21 * heightRate

        //移动
        MouseArea{
            width: 26 * heightRate
            height: 26 * heightRate
            hoverEnabled: true
            enabled: false//disableButton
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_move_sed.png"  : (updateIndex == 1 ? "qrc:/miniClassImage/xb_icon_move_sed.png" :  "qrc:/miniClassImage/xb_icon_move.png")
            }

            onClicked: {
                updateIndex = 1;
                sigSendFunctionKey(1);
            }
        }

        //指针
        MouseArea{
            width: 16 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            enabled: disableButton
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_select_sed.png"  :  (updateIndex == 2 ? "qrc:/miniClassImage/xb_icon_select_sed.png" :"qrc:/miniClassImage/xb_icon_select.png")
            }

            onClicked: {
                updateIndex = 2;
                sigSendFunctionKey(2);
            }
        }

        //画笔
        MouseArea{
            width: 25 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            enabled: disableButton
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                id: brushImg
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_brush_sed.png" : (updateIndex == 3 ? "qrc:/miniClassImage/xb_icon_brush_sed.png" : "qrc:/miniClassImage/xb_icon_brush.png")
            }

            onClicked: {
                updateIndex = 3;
                sigSendFunctionKey(3);
            }
        }

        //橡皮
        MouseArea{
            width: 28 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            enabled: disableButton
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
        }

        /*
        //工具箱
        MouseArea{
            width: 25 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            enabled: false//disableButton
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_tool_sed.png" : (updateIndex == 7 ? "qrc:/miniClassImage/xb_icon_tool_sed.png" : "qrc:/miniClassImage/xb_icon_tool.png")
                //qrc:/miniClassImage/xb_icon_tool_sed.png
            }

            onClicked: {
                updateIndex = 7;
                sigSendFunctionKey(7);
            }
        }*/

        //花名册
        MouseArea{
            width: 25 * heightRate
            height: 25 * heightRate
            hoverEnabled: true
            enabled: disableButton
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_peoplebook_sed.png" : (updateIndex == 8 ? "qrc:/miniClassImage/xb_icon_peoplebook_sed.png" : "qrc:/miniClassImage/xb_icon_peoplebook.png")
                //
            }

            onClicked: {
                updateIndex = 8;
                sigSendFunctionKey(8);
            }
        }

        //收起按钮
        MouseArea{
            width: parent.width
            height: 42 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter

            //横线
            Rectangle{
                width: parent.width - 8 * heightRate
                height: 2 * heightRate
                color: "#eeeeee"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 4 * heightRate
            }


            Image{
                width: 17 * heightRate
                height: 20 * heightRate
                anchors.centerIn: parent
                source: parent.containsMouse ? "qrc:/miniClassImage/xb_icon_shouqi_sed.png" : "qrc:/miniClassImage/xb_icon_shouqi.png"
            }

            onClicked: {
                updateIndex = 9;
                sigSendFunctionKey(9);
            }
        }

    }

}
