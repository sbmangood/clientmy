import QtQuick 2.5
import QtQuick.Window 2.0
import "./Configuuration.js" as Cfg

Item {
    property string displayerText: "【编号450961】 语文/徐腾 (测试)";

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
        width: (12 * 3) * widthRate + 3 * 15 * widthRate
        height: parent.height
        anchors.right: parent.right

        Row{
            anchors.fill: parent
            spacing: 15 * widthRate
            MouseArea{
                width: 12 * widthRate
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                Image{
                    height: parent.width
                    width: parent.width
                    visible: false
                    source: "qrc:/images/zuixiaohua.png"
                    anchors.verticalCenter: parent.verticalCenter
                }
                onClicked: {
                    setMin();
                }
            }

            MouseArea{
                width: 12 * widthRate
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                Image{
                    id:maxButton
                    height: parent.width
                    width: parent.width
                    visible: false
                    source: "qrc:/images/zuidahua.png"
                    anchors.verticalCenter: parent.verticalCenter
                }
                onClicked: {
                    updateImageSize();
                    if(windowView.visibility == Window.Maximized){
                        windowView.visibility = Window.Windowed;
                        setMax();
                        maxButton.source = "qrc:/images/zuidahua.png"
                    }else if (windowView.visibility === Window.Windowed){
                        windowView.visibility = Window.Maximized;
                        maxButton.source = "qrc:/images/qiehuan.png"
                    }
                }
            }

            MouseArea{
                width: 12 * widthRate
                height: parent.height
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Image{
                    height: parent.width - 2
                    width: parent.width - 2
                    source: "qrc:/images/guanbi.png"
                    anchors.verticalCenter: parent.verticalCenter
                }
                onClicked: {
                    setClose();
                }
            }
        }
    }
}

