import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuuration.js" as Cfg

/*
*ComboBox更改后的样式控件*
*/

ComboBox {
    id: comboBox
    width: parent.width
    height: parent.height
    font.family: Cfg.DEFAULT_FONT
    font.pixelSize: 13 * heightRate
    textRole: "values"

    delegate: ItemDelegate{
        id: comboBoxItem
        width: comboBox.width
        height: comboBox.height
        font.weight: comboBox.currentIndex === index ? Font.DemiBold : Font.Normal
        highlighted: comboBox.highlightedIndex == index

        MouseArea {
            id: itemArea
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                comboBox.currentIndex = index;
                comboBox.popup.close();
            }
        }

        Label{
            width: parent.width -5
            height: parent.height
            anchors.left: parent.left
            anchors.leftMargin: 10
            verticalAlignment: Text.AlignVCenter
            font.family: "Microsoft YaHei"
            font.pixelSize: 13 * heightRate
            text:  values
            color: itemArea.containsMouse ?  "#ff5000" : "black"
        }

        background: Rectangle {
            anchors.fill: parent
            color: comboBox.currentIndex === index ? "#e0e0e0" : itemArea.containsMouse ? "#f3f3f3" : "white"
        }
    }

    background: MouseArea{
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            comboBox.popup.open();
        }
    }

    indicator: Image{
        x: comboBox.width - width - comboBox.rightPadding
        y: comboBox.topPadding + (comboBox.availableHeight - height) / 2
        width: 8 * widthRates
        height: 6 * heightRates
        source: "qrc:/images/icon_selecttwosx.png"
    }
}
