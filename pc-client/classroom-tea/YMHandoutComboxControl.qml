import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import "./Configuuration.js" as Cfg

/*
*ComboBox更改后的样式控件*
*/

ComboBox {
    id: comboBox
    width: parent.width
    height: parent.height
    font.family: Cfg.DEFAULT_FONT
    font.pixelSize: 14 * heightRate
    textRole: "key"

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
                if(index == 0){
                    return;
                }

                comboBox.currentIndex = index;
                comboBox.popup.close();
            }
        }

        Label{
            width: parent.width - 5
            height: parent.height
            anchors.left: parent.left
            anchors.leftMargin: 10
            verticalAlignment: Text.AlignVCenter
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 14 * heightRate
            text:  key
            color: itemArea.containsMouse ?  "#ff5000" : "black"
        }

        background: Rectangle {
            anchors.fill: parent
            color: comboBox.currentIndex === index ? "#e0e0e0" : itemArea.containsMouse ? "#f3f3f3" : "white"
        }
    }

    background: Rectangle{
        anchors.fill: parent
        color: "white"
        radius: 6 * heightRate
        border.width: 1
        border.color: "#e0e0e0"
    }

    indicator: Image{
        x: comboBox.width - width - comboBox.rightPadding
        y: comboBox.topPadding + (comboBox.availableHeight - height) / 2
        width: 8 * widthRates
        height: 6 * heightRates
        source: "qrc:/images/icon_selecttwosx.png"
    }

    contentItem:  Item{
        height: parent.height
        width: parent.width
        Text{
            width: parent.width - 10 * widthRate
            height: parent.height
            font.family: Cfg.font_family
            font.pixelSize: 12 * widthRates
            verticalAlignment: Text.AlignVCenter
            text: comboBox.textAt(comboBox.currentIndex)
            elide: Text.ElideRight
        }
    }

}
