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
            pressedImage: "qrc:/images/zuixaohua_pressed@2x.png"
            imageUrl:  "qrc:/images/zuixaohua_normal@2x.png"
            hoverImg: "qrc:/images/zuixaohua_focused@2x.png"
            onClicked: {
                window.visibility = Window.Minimized;
            }
        }

        //最大化按钮
        YMButton {
            id: maxButton
            width: parent.height + 4 * heightRate// * 0.35
            height: parent.height// * 0.99// * 0.35
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            pressedImage:window.visibility == Window.Maximized ? "qrc:/images/quanping_pressed2@2x.png" : "qrc:/images/quanping_pressed@2x.png"
            imageUrl: window.visibility == Window.Maximized ? "qrc:/images/quanping_normal2@2x.png" :"qrc:/images/quanping_normal@2x.png"
            hoverImg:window.visibility == Window.Maximized ? "qrc:/images/quanping_focused2@2x.png" :"qrc:/images/quanping_focused@2x.png"

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
            imageUrl: "qrc:/images/guanbi_normal@2x.png"
            pressedImage: "qrc:/images/guanbi_pressed@2x.png"
            hoverImg: "qrc:/images/guanbi_focused@2x.png"
            onClicked: {
                closed();
            }
        }
    }
}


