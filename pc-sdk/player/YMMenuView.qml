import QtQuick 2.5
import QtQuick.Window 2.0
import "./Configuuration.js" as Cfg

Item {
    property string displayerText: "";
    width: parent.width
    height: parent.height

    signal setMin();
    signal setMax();
    signal setClose();

    //显示当前内容
    Text{
        text: displayerText
        anchors.centerIn: parent
        font.family: Cfg.FONT_FAMILY
        font.pixelSize:  13 * widthRate
        color: "white"
    }

    Item{
        width: 120 * heightRate
        height: parent.height
        anchors.right: parent.right

        Row{
            anchors.fill: parent
            spacing: 6 * widthRate

            MouseArea{
                width: 54 * heightRate
                height: 54 * heightRate
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                Image{
                    anchors.fill: parent
                    source: parent.containsMouse ? "qrc:/images/zuixiaohua2.png" : "qrc:/images/zuixiaohua1.png"
                }
                onClicked: {
                    setMin();
                }
            }

            MouseArea{
                width: 54 * heightRate
                height: 54 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                visible: false

                Image{
                    id:maxButton
                    anchors.fill: parent
                    source: parent.containsMouse ? "qrc:/images/fangda2.png" : "qrc:/images/fangda1.png"
                }
                onClicked: {
                    //updateImageSize();
                    if(windowView.visibility == Window.Maximized){
                        windowView.visibility = Window.Windowed;
                        setMax();
                        maxButton.source = "qrc:/images/fangda3.png"
                    }else if (windowView.visibility === Window.Windowed){
                        windowView.visibility = Window.Maximized;
                        maxButton.source = "qrc:/images/fangda4.png"
                    }
                }
            }

            MouseArea{
                width: 54 * heightRate
                height: 54 * heightRate
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: parent.containsMouse ? "qrc:/images/guanbi2.png" : "qrc:/images/guanbi1.png"
                }
                onClicked: {
                    setClose();
                }
            }
        }
    }
}

