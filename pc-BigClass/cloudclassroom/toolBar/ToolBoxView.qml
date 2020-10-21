import QtQuick 2.0
import "./Configuration.js" as Cfg

Item {


    property int updateIndex: -1;
    property int buttonWidth: 42;
    property int itemValue: 2;

    signal sigSendBoxFunctionKey(var keys);//点击的按钮


    width: itemValue * buttonWidth * heightRate + 20 * heightRate + itemValue * 4 * heightRate;
    height: 52 * heightRate

    Image {
        id: bg
        anchors.fill: parent
        source: "qrc:/classImage/bg_pop_toolbox.png"
    }

    Row {
        z: 91
        width: parent.width  - 10 * heightRate
        height: parent.height
        spacing: 4 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 6 * heightRate
        anchors.verticalCenter: parent.verticalCenter

        //答题器
        Item{
            width: buttonWidth * heightRate
            height: width
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                id: btn6
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.centerIn: parent

                Image{
                    anchors.fill: parent
                    source: updateIndex == 7 ? "qrc:/classImage/but_menu_answer_pressed.png" :  (parent.containsMouse ? "qrc:/classImage/but_menu_answer_focused.png" : "qrc:/classImage/but_menu_answer_normal.png")
                }

                onClicked: {
                    updateIndex = 7;
                    sigSendBoxFunctionKey(7);
                }
            }
            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn6.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "答题器"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }
        //计时器
        Item{
            width: buttonWidth * heightRate
            height: width
            anchors.verticalCenter: parent.verticalCenter
            MouseArea {
                id: btn7
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.centerIn: parent

                Image{
                    anchors.fill: parent
                    source: updateIndex == 8 ? "qrc:/classImage/but_menu_timer_pressed.png" :   (btn7.containsMouse ? "qrc:/classImage/but_menu_timer_focused.png" : "qrc:/classImage/but_menu_timer_normal.png")
                }

                onClicked: {
                    updateIndex = 8;
                    sigSendBoxFunctionKey(8);
                }
            }
            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn7.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "计时器"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }
    }


}
