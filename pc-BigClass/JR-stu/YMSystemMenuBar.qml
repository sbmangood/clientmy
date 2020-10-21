import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import "Configuration.js" as Cfg

//主程序, 右上角的"最小化", "最大化", "关闭"按钮
Item{
    width: 90 * heightRate * 0.75
    height: 45 * heightRate * 0.75

    property var window: null

    signal minimized();
    signal maximized();
    signal windowed();
    signal closed();
    signal refreshData();

    Row {
        width:  parent.width
        height: parent.height
        spacing: 8 * heightRate * 0.75

        //最小化按钮
        YMButton {
            id: miniButton
            width: 25 * heightRate * 0.75
            height: 22 * heightRate * 0.75
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            pressedImage: "qrc:/JrImage/min.png"
            imageUrl:  "qrc:/JrImage/min.png"
            onClicked: {
                window.visibility = Window.Minimized;
            }
        }

        //最大化按钮
        YMButton {
            id: maxButton
            width: 25 * heightRate * 0.75
            height: 22 * heightRate * 0.75
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            pressedImage:window.visibility == Window.Maximized ? "qrc:/JrImage/big.png" : "qrc:/JrImage/big.png"
            imageUrl: window.visibility == Window.Maximized ? "qrc:/JrImage/big.png" :"qrc:/JrImage/big.png"
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
            width: 25 * heightRate * 0.75
            height: 22 * heightRate * 0.75
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            imageUrl: "qrc:/JrImage/close.png"
            pressedImage: "qrc:/JrImage/close.png"
            onClicked: {
                closed();
            }
        }
    }
}


