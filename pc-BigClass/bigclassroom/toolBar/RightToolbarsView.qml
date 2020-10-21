import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuration.js" as Cfg

Item {
    id: toolbarsMainView
    width: 135 * heightRate

    property int updateIndex: -1;
    property int buttonWidth: 42;
    property int itemValue: 10;//9个选项

    height: itemValue * buttonWidth * heightRate + 20 * heightRate + itemValue * 4 * heightRate;

    signal sigSendFunctionKey(var keys);//点击的按钮

    Image{
        width: 58 * heightRate
        height: parent.height
        anchors.left: parent.left
        source: "qrc:/toolBarImage/gjbj1@2x.png"
    }

    Column {
        width: parent.width
        height: parent.height - 10 * heightRate
        spacing: 4 * heightRate
        anchors.verticalCenter: parent.verticalCenter

        //指针
        Item{
            width: parent.width
            height: buttonWidth * heightRate

            MouseArea {
                id: btn1
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.left: parent.left
                anchors.leftMargin: (54 * heightRate - width) * 0.5

                Image {
                    anchors.fill: parent
                    source: parent.containsMouse ? "qrc:/toolBarImage/dianji3@2x.png"  :  (updateIndex == 2 ? "qrc:/toolBarImage/dianji3@2x.png" :"qrc:/toolBarImage/dianji1@2x.png")
                }

                onClicked: {
                    updateIndex = 2;
                    sigSendFunctionKey(0);
                }

            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn1.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    id: hoverTxt1
                    height: 20 * heightRate
                    text: "点击"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }

        //画笔
        Item{
            width: parent.width
            height: buttonWidth * heightRate

            MouseArea {
                id: btn2
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.left: parent.left
                anchors.leftMargin: (54 * heightRate - width) * 0.5

                onClicked: {
                    updateIndex = 3;
                    sigSendFunctionKey(1);
                }

                Image {
                    anchors.fill: parent
                    source: btn2.containsMouse ? "qrc:/toolBarImage/huabi3@2x.png" : (updateIndex == 3 ? "qrc:/toolBarImage/huabi3@2x.png" : "qrc:/toolBarImage/huabi2@2x.png")
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn2.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "画笔"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }

        //橡皮
        Item{
            width: parent.width
            height: buttonWidth * heightRate

            MouseArea {
                id: btn3
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.left: parent.left
                anchors.leftMargin: (54 * heightRate - width) * 0.5

                onClicked: {
                    updateIndex = 4;
                    sigSendFunctionKey(4);
                }

                Image {
                    anchors.fill: parent
                    source: btn3.containsMouse ? "qrc:/toolBarImage/xiangpi3@2x.png" : (updateIndex == 4 ? "qrc:/toolBarImage/xiangpi3@2x.png" : "qrc:/toolBarImage/xiangpi1@2x.png")
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn3.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "橡皮"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }
        //教鞭
        Item{
            width: parent.width
            height: buttonWidth * heightRate

            MouseArea {
                id: btn4
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.left: parent.left
                anchors.leftMargin: (54 * heightRate - width) * 0.5

                Image {
                    anchors.fill: parent
                    source: btn4.containsMouse ? "qrc:/toolBarImage/jiaobian3@2x.png" : (updateIndex == 5 ? "qrc:/toolBarImage/jiaobian3@2x.png" :"qrc:/toolBarImage/jiaobian1@2x.png")
                }

                onClicked: {
                    updateIndex = 5;
                    sigSendFunctionKey(5)
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn4.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "教鞭"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }
        }
        //云盘
        Item{
            width: parent.width
            height: buttonWidth * heightRate

            MouseArea {
                id: btn5
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.left: parent.left
                anchors.leftMargin: (54 * heightRate - width) * 0.5

                Image{
                    anchors.fill: parent
                    source: btn5.containsMouse ? "qrc:/toolBarImage/kejian3@2x.png" : (updateIndex == 6 ? "qrc:/toolBarImage/kejian3@2x.png" :"qrc:/toolBarImage/kejian1@2x.png")
                }

                onClicked: {
                    sigSendFunctionKey(6);
                }
            }
            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn5.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "云盘"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }

        //答题器
        Item{
            width: parent.width
            height: buttonWidth * heightRate

            MouseArea {
                id: btn6
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.left: parent.left
                anchors.leftMargin: (54 * heightRate - width) * 0.5

                Image{
                    anchors.fill: parent
                    source: parent.containsMouse ? "qrc:/toolBarImage/datiqi3@2x.png" : (updateIndex == 7 ? "qrc:/toolBarImage/datiqi3@2x.png" :"qrc:/toolBarImage/datiqi1@2x.png")
                }

                onClicked: {
                    sigSendFunctionKey(7);
                }
            }
            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: buttonWidth * heightRate + 16 * heightRate
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
            width: parent.width
            height: buttonWidth * heightRate

            MouseArea {
                id: btn7
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.left: parent.left
                anchors.leftMargin: (54 * heightRate - width) * 0.5

                Image{
                    anchors.fill: parent
                    source: btn7.containsMouse ? "qrc:/toolBarImage/jishiqi3@2x.png" : "qrc:/toolBarImage/jishiqi1@2x.png"
                }

                onClicked: {
                    sigSendFunctionKey(8);
                }
            }
            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: buttonWidth * heightRate + 16 * heightRate
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
        //红包雨
        Item{
            width: parent.width
            height: buttonWidth * heightRate

            MouseArea {
                id: btn8
                width: buttonWidth * heightRate + 8
                height: buttonWidth * heightRate + 8
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.left: parent.left
                anchors.leftMargin: (54 * heightRate - width) * 0.5

                onClicked: {
                    sigSendFunctionKey(9);
                }

                Image{
                    width: buttonWidth * heightRate
                    height: buttonWidth * heightRate
                    anchors.centerIn: parent
                    source: btn8.containsMouse ? "qrc:/toolBarImage/hongbaoyu3@2x.png" : "qrc:/toolBarImage/hongbaoyu1@2x.png"
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn8.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "红包雨"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }

        //奖杯
        Item{
            width: parent.width
            height: buttonWidth * heightRate + 6

            MouseArea {
                id: btn9
                width: buttonWidth * heightRate + 6
                height: buttonWidth * heightRate + 6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.left: parent.left
                anchors.leftMargin: (54 * heightRate - width) * 0.5

                Image{
                    anchors.fill: parent
                    source: btn9.containsMouse ? "qrc:/toolBarImage/jiangbei3@2x.png" : "qrc:/toolBarImage/jiangbei1@2x.png"
                }

                onClicked: {
                    sigSendFunctionKey(10);
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn9.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "奖杯"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }

        //收缩
        Item{
            width: parent.width
            height: buttonWidth * heightRate

            MouseArea {
                id: btn10
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.left: parent.left
                anchors.leftMargin: (54 * heightRate - width) * 0.5

                Image{
                    anchors.fill: parent
                    source: btn10.containsMouse ? "qrc:/bigclassImage/fanhui2.png" : "qrc:/bigclassImage/fanhui1.png"
                }

                onClicked: {
                    sigSendFunctionKey(11);
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn10.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "隐藏"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }

    }
}
