import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuration.js" as Cfg

Item {
    id: toolbarsMainView
    width: 135 * heightRate

    property int updateIndex: -1;
    property int buttonWidth: 42;
    property int itemValue: userRole == 0 ? 11 : 6;
    property bool isEnableBtn: true;

    height: itemValue * buttonWidth * heightRate + 20 * heightRate + itemValue * 4 * heightRate;

    signal sigSendFunctionKey(var keys);//点击的按钮

    Image{
        width: 58 * heightRate
        height: parent.height
        anchors.right: parent.right
        source: "qrc:/classImage/bg_menu.png"
    }

    Column {
        width: parent.width
        height: buttonWidth * heightRate * itemValue
        spacing: 4 * heightRate
        anchors.top: parent.top
        anchors.topMargin:  15 * heightRate

        //指针
        Item{
            width: parent.width
            height: buttonWidth * heightRate
            visible: userRole == 0 ? true : false

            MouseArea {
                id: btn1
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.right: parent.right
                anchors.rightMargin: (54 * heightRate - width) * 0.5
                enabled: isEnableBtn

                Image {
                    anchors.fill: parent
                    source: parent.containsMouse ? "qrc:/classImage/but_menu_click_focused.png"  :  (updateIndex == 2 ? "qrc:/classImage/but_menu_click_focused.png" :"qrc:/classImage/but_menu_click_normal.png")
                }

                onClicked: {
                    updateIndex = 2;
                    sigSendFunctionKey(0);
                }

            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
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

        //教鞭
        Item{
            width: parent.width
            height: buttonWidth * heightRate
            visible: userRole == 0 ? true : false

            MouseArea {
                id: btn4
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.right: parent.right
                anchors.rightMargin: (54 * heightRate - width) * 0.5
                enabled: isEnableBtn

                Image {
                    anchors.fill: parent
                    source: btn4.containsMouse ? "qrc:/classImage/but_menu_whip_focused.png" : (updateIndex == 5 ? "qrc:/classImage/but_menu_whip_focused.png" :"qrc:/classImage/but_menu_whip_normal.png")
                }

                onClicked: {
                    updateIndex = 5;
                    sigSendFunctionKey(5)
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
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
                anchors.right: parent.right
                anchors.rightMargin: (54 * heightRate - width) * 0.5
                enabled: isEnableBtn

                onClicked: {
                    updateIndex = 3;
                    sigSendFunctionKey(1);
                }

                Image {
                    anchors.fill: parent
                    source: btn2.containsMouse ? "qrc:/classImage/but_menu_pen_focused.png" : (updateIndex == 3 ? "qrc:/classImage/but_menu_pen_focused.png" : "qrc:/classImage/but_menu_pen_normal.png")
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
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

        //图形
        Item{
            width: parent.width
            height: buttonWidth * heightRate

            MouseArea {
                id: btn12
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.right: parent.right
                anchors.rightMargin: (54 * heightRate - width) * 0.5
                enabled: isEnableBtn

                onClicked: {
                    updateIndex = 12;
                    sigSendFunctionKey(12);
                }

                Image {
                    anchors.fill: parent
                    source: btn12.containsMouse ? "qrc:/classImage/but_menu_shape_focused.png" : (updateIndex == 12 ? "qrc:/classImage/but_menu_shape_focused.png" : "qrc:/classImage/but_menu_shape_normal.png")
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn12.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "图形"
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
                anchors.right: parent.right
                anchors.rightMargin: (54 * heightRate - width) * 0.5
                enabled: isEnableBtn

                onClicked: {
                    updateIndex = 4;
                    sigSendFunctionKey(4);
                }

                Image {
                    anchors.fill: parent
                    source: btn3.containsMouse ? "qrc:/classImage/but_menu_rubber_focused.png" : (updateIndex == 4 ? "qrc:/classImage/but_menu_rubber_focused.png" : "qrc:/classImage/but_menu_rubber_normal.png")
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
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

        //选中
        Item{
            width: parent.width
            height: buttonWidth * heightRate

            MouseArea {
                id: btn13
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.right: parent.right
                anchors.rightMargin: (54 * heightRate - width) * 0.5
                enabled: isEnableBtn

                onClicked: {
                    updateIndex = 13;
                    sigSendFunctionKey(13);
                }

                Image {
                    anchors.fill: parent
                    source: btn13.containsMouse ? "qrc:/classImage/but_menu_wy_focused.png" : (updateIndex == 13 ? "qrc:/classImage/but_menu_wy_focused.png" : "qrc:/classImage/but_menu_wy_normal.png")
                }

                Image{
                    width: buttonWidth * heightRate
                    height: 2 * heightRate
                    anchors.top: parent.bottom
                    anchors.topMargin: 1 * heightRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "qrc:/classImage/di_item.png"
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn13.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "选中"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }

        //保存板书
        Item{
            width: parent.width
            height: buttonWidth * heightRate
            visible: userRole == 0 ? true : false

            MouseArea {
                id: btn14
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.right: parent.right
                anchors.rightMargin: (54 * heightRate - width) * 0.5
                enabled: isEnableBtn

                onClicked: {
//                    updateIndex = 14;
                    sigSendFunctionKey(14);
                }

                Image {
                    anchors.fill: parent
                    source: btn14.containsMouse ? "qrc:/classImage/but_menu_save_focused.png" : (updateIndex == 14 ? "qrc:/classImage/but_menu_save_focused.png" : "qrc:/classImage/but_menu_save_normal.png")
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn14.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "保存板书"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }

        }

        //上传图片
        Item{
            width: parent.width
            height: buttonWidth * heightRate

            MouseArea {
                id: btn15
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.right: parent.right
                anchors.rightMargin: (54 * heightRate - width) * 0.5
                enabled: isEnableBtn

                onClicked: {
                    updateIndex = 15;
                    sigSendFunctionKey(15);
                }

                Image {
                    anchors.fill: parent
                    source: btn15.containsMouse ? "qrc:/classImage/but_menu_uploadimage_focused.png" : (updateIndex == 15 ? "qrc:/classImage/but_menu_uploadimage_focused.png" : "qrc:/classImage/but_menu_uploadimage_normal.png")
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn15.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "上传图片"
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
            visible: userRole == 0 ? true : false

            MouseArea {
                id: btn5
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.right: parent.right
                anchors.rightMargin: (54 * heightRate - width) * 0.5
                enabled: isEnableBtn

                Image{
                    anchors.fill: parent
                    source: btn5.containsMouse ? "qrc:/classImage/but_menu_netdisc_focused.png" : (updateIndex == 6 ? "qrc:/classImage/but_menu_netdisc_focused.png" :"qrc:/classImage/but_menu_netdisc_normal.png")
                }

                onClicked: {
                    sigSendFunctionKey(6);
                }
            }
            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
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

            Image{
                z: 101
                id: boardTips
                width: 169 * heightRate
                height: 38 * heightRate
                anchors.right: btn5.left
                anchors.rightMargin: 10 * heightRate
                visible: false
                source: "qrc:/classImage/img_pop_bszzlo.png"
            }

        }

        //工具箱
        Item{
            width: parent.width
            height: buttonWidth * heightRate
            visible: userRole == 0 ? true : false

            MouseArea {
                id: btn16
                width: buttonWidth * heightRate
                height: buttonWidth * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.right: parent.right
                anchors.rightMargin: (54 * heightRate - width) * 0.5
                enabled: isEnableBtn

                Image{
                    anchors.fill: parent
                    source: btn16.containsMouse ? "qrc:/classImage/but_menu_tool_focused.png" : (updateIndex == 16 ? "qrc:/classImage/but_menu_tool_focused.png" :"qrc:/classImage/but_menu_tool_normal.png")
                }

                onClicked: {
                    updateIndex = 16;
                    sigSendFunctionKey(16);
                }
            }
            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
                color: "#353746"
                visible: btn16.containsMouse ? true : false
                anchors.verticalCenter: parent.verticalCenter
                radius: 4 * heightRate

                Text {
                    height: 20 * heightRate
                    text: "工具箱"
                    color: "#ffffff"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    anchors.centerIn: parent
                }
            }
        }


//        //答题器
//        Item{
//            width: parent.width
//            height: buttonWidth * heightRate

//            MouseArea {
//                id: btn6
//                width: buttonWidth * heightRate
//                height: buttonWidth * heightRate
//                hoverEnabled: true
//                cursorShape: Qt.PointingHandCursor
//                anchors.right: parent.right
//                anchors.rightMargin: (54 * heightRate - width) * 0.5

//                Image{
//                    anchors.fill: parent
//                    source: parent.containsMouse ? "qrc:/toolBarImage/datiqi3@2x.png" : (updateIndex == 7 ? "qrc:/toolBarImage/datiqi3@2x.png" :"qrc:/toolBarImage/datiqi1@2x.png")
//                }

//                onClicked: {
//                    sigSendFunctionKey(7);
//                }
//            }
//            Rectangle{
//                width: 68 * heightRate
//                height: 26 * heightRate
//                anchors.right: parent.right
//                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
//                color: "#353746"
//                visible: btn6.containsMouse ? true : false
//                anchors.verticalCenter: parent.verticalCenter
//                radius: 4 * heightRate

//                Text {
//                    height: 20 * heightRate
//                    text: "答题器"
//                    color: "#ffffff"
//                    font.pixelSize: 16 * heightRate
//                    font.family: Cfg.DEFAULT_FONT
//                    anchors.centerIn: parent
//                }
//            }

//        }
//        //计时器
//        Item{
//            width: parent.width
//            height: buttonWidth * heightRate

//            MouseArea {
//                id: btn7
//                width: buttonWidth * heightRate
//                height: buttonWidth * heightRate
//                hoverEnabled: true
//                cursorShape: Qt.PointingHandCursor
//                anchors.right: parent.right
//                anchors.rightMargin: (54 * heightRate - width) * 0.5

//                Image{
//                    anchors.fill: parent
//                    source: btn7.containsMouse ? "qrc:/toolBarImage/jishiqi3@2x.png" : "qrc:/toolBarImage/jishiqi1@2x.png"
//                }

//                onClicked: {
//                    sigSendFunctionKey(8);
//                }
//            }
//            Rectangle{
//                width: 68 * heightRate
//                height: 26 * heightRate
//                anchors.right: parent.right
//                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
//                color: "#353746"
//                visible: btn7.containsMouse ? true : false
//                anchors.verticalCenter: parent.verticalCenter
//                radius: 4 * heightRate

//                Text {
//                    height: 20 * heightRate
//                    text: "计时器"
//                    color: "#ffffff"
//                    font.pixelSize: 16 * heightRate
//                    font.family: Cfg.DEFAULT_FONT
//                    anchors.centerIn: parent
//                }
//            }

//        }
//        //红包雨
//        Item{
//            width: parent.width
//            height: buttonWidth * heightRate

//            MouseArea {
//                id: btn8
//                width: buttonWidth * heightRate + 8
//                height: buttonWidth * heightRate + 8
//                hoverEnabled: true
//                cursorShape: Qt.PointingHandCursor
//                anchors.right: parent.right
//                anchors.rightMargin: (54 * heightRate - width) * 0.5

//                onClicked: {
//                    sigSendFunctionKey(9);
//                }

//                Image{
//                    width: buttonWidth * heightRate
//                    height: buttonWidth * heightRate
//                    anchors.centerIn: parent
//                    source: btn8.containsMouse ? "qrc:/toolBarImage/hongbaoyu3@2x.png" : "qrc:/toolBarImage/hongbaoyu1@2x.png"
//                }
//            }

//            Rectangle{
//                width: 68 * heightRate
//                height: 26 * heightRate
//                anchors.right: parent.right
//                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
//                color: "#353746"
//                visible: btn8.containsMouse ? true : false
//                anchors.verticalCenter: parent.verticalCenter
//                radius: 4 * heightRate

//                Text {
//                    height: 20 * heightRate
//                    text: "红包雨"
//                    color: "#ffffff"
//                    font.pixelSize: 16 * heightRate
//                    font.family: Cfg.DEFAULT_FONT
//                    anchors.centerIn: parent
//                }
//            }

//        }

//        //奖杯
//        Item{
//            width: parent.width
//            height: buttonWidth * heightRate + 6

//            MouseArea {
//                id: btn9
//                width: buttonWidth * heightRate + 6
//                height: buttonWidth * heightRate + 6
//                hoverEnabled: true
//                cursorShape: Qt.PointingHandCursor
//                anchors.right: parent.right
//                anchors.rightMargin: (54 * heightRate - width) * 0.5

//                Image{
//                    anchors.fill: parent
//                    source: btn9.containsMouse ? "qrc:/toolBarImage/jiangbei3@2x.png" : "qrc:/toolBarImage/jiangbei1@2x.png"
//                }

//                onClicked: {
//                    sigSendFunctionKey(10);
//                }
//            }

//            Rectangle{
//                width: 68 * heightRate
//                height: 26 * heightRate
//                anchors.right: parent.right
//                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
//                color: "#353746"
//                visible: btn9.containsMouse ? true : false
//                anchors.verticalCenter: parent.verticalCenter
//                radius: 4 * heightRate

//                Text {
//                    height: 20 * heightRate
//                    text: "奖杯"
//                    color: "#ffffff"
//                    font.pixelSize: 16 * heightRate
//                    font.family: Cfg.DEFAULT_FONT
//                    anchors.centerIn: parent
//                }
//            }

//        }

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
                anchors.right: parent.right
                anchors.rightMargin: (54 * heightRate - width) * 0.5

                Image{
                    anchors.fill: parent
                    source: btn10.containsMouse ? "qrc:/classImage/but_menu_collapse_focused.png" : "qrc:/classImage/but_menu_collapse_normal.png"
                }

                onClicked: {
                    sigSendFunctionKey(11);
                }

                Image{
                    width: buttonWidth * heightRate
                    height: 2 * heightRate
                    anchors.top: parent.top
                    anchors.topMargin: -1 * heightRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "qrc:/classImage/di_item.png"
                }
            }

            Rectangle{
                width: 68 * heightRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: buttonWidth * heightRate + 16 * heightRate
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
    Timer{
        id: saveBoardTipsTime
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            boardTips.visible = false;
        }
    }
    //击中红包 packgeId: 红包的编号
    function saveBoardsSuccessTip(){
        boardTips.visible = true;
        saveBoardTipsTime.restart();
    }
}
