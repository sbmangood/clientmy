import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import "Configuration.js" as Cfg

//主程序, 右上角的"最小化", "最大化", "关闭"按钮
Item{
    width: 90 * widthRate
    height: 45 * heightRate

    property var window: null

    signal minimized();
    signal maximized();
    signal windowed();
    signal closed();
    signal refreshData();

    Row {
        width:  parent.width
        height: parent.height
        spacing: 0

        //最小化按钮
        YMButton {
            id: miniButton
            width: parent.height// * 0.35
            height: parent.height// * 0.35
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            pressedImage: "qrc:/images/btn_zuixiaohua_sed@2x.png"
            imageUrl:  "qrc:/images/btn_zuixiaohua@2x.png"
            onClicked: {
                window.visibility = Window.Minimized;
            }
        }

        //最大化按钮
        YMButton {
            id: maxButton
            width: parent.height// * 0.35
            height: parent.height// * 0.99// * 0.35
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            pressedImage:window.visibility == Window.Maximized ? "qrc:/images/btn_xiaopin_sed@2x.png" : "qrc:/images/btn_zuidahua_sed@2x.png"
            imageUrl: window.visibility == Window.Maximized ? "qrc:/images/btn_xiaopin@2x.png" :"qrc:/images/btn_zuidahua@2x.png"
            onClicked: {
                if (window.visibility === Window.Maximized){
                    window.visibility = Window.Windowed;
                }else if (window.visibility === Window.Windowed){
                    window.visibility = Window.Maximized;
                }
            }
        }

        //关闭按钮
        YMButton {
            id: closeButton
            width: parent.height// * 0.35
            height: parent.height// * 0.35
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            imageUrl: "qrc:/images/btn_guanbi@2x.png"
            pressedImage: "qrc:/images/btn_guanbi_sed@2x.png"
            onClicked: {
                closed();
            }
        }
    }
}


