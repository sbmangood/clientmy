import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuuration.js" as Cfg

Item {
    width: 72 * heightRate
    height: 150 * heightRate

    property int clockValue: 0;//当前显示的值
    property int maxValue: 9;//最大显示多少
    property bool isVisible: true;//是否显示加减 默认：true 显示 ; false：不显示
    property bool isStart: false;//启动以后不可以点击加减

    signal sigAdd();//加信号
    signal sigLess();//减信号

    Column{
        width: parent.width
        height: parent.height

        MouseArea{
            width: parent.width
            height: parent.height * 0.2
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: isVisible ? (isStart ? false : true) : false

            Image {
                id: addButton
                width: 15 * heightRate
                height: 15 * heightRate
                anchors.centerIn: parent
                visible: isVisible
                source: parent.containsMouse ? "qrc:/miniClassImage/xbk_icon_jia_dianji.png" : "qrc:/miniClassImage/xbk_icon_jia.png"
            }

            onClicked: {
                console.log("===clockValue::maxValue===",clockValue,maxValue);
                if(clockValue >= maxValue){
                    return;
                }
                clockValue += 1;
                sigAdd();
            }
        }

        Item{
            width: parent.width
            height: parent.height * 0.6

            Rectangle{
                anchors.fill: parent
                color: "#000000"
                radius: 4 * heightRate
                opacity: 0.12
            }

            Text {
                z: 1
                text: clockValue
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 72 * heightRate
                color: "#666666"
                anchors.centerIn: parent
            }
        }

        MouseArea{
            width: parent.width
            height: parent.height * 0.2
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            visible: isVisible
            enabled:  isVisible ? (isStart ? false : true) : false

            Image{
                id: lessButton
                width: 15 * heightRate
                height: 2 * heightRate
                source: parent.containsMouse ? "qrc:/miniClassImage/xbk_icon_jian_dianji.png" : "qrc:/miniClassImage/xbk_icon_jian.png"
                anchors.centerIn: parent
            }

            onClicked: {
                if(clockValue == 0){
                    return;
                }
                clockValue -= 1;
                sigLess();
            }
        }

    }
}
