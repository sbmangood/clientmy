import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Private 1.0
import "../../Configuration.js" as Cfg

/**ComboBox更改后的样式控件**/

ComboBox {
    id: comboBox
    width: parent.width
    height: parent.height

    property color focus_borderColor: "lightsalmon"

    style: ComboBoxStyle{
        background: Rectangle{
            anchors.fill: parent
            border.color: comboBox.pressed ? "#FF5500" : "#EEEEEE"
            border.width: 1
            radius: 4 * heightRate
            Image {
                width: parent.height*0.4
                height: parent.height*0.4
                anchors.right:parent.right
                source: "qrc:/images/UPDOWN@2x.png"
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 5*widthRate
            }
        }
        label: Text {
            verticalAlignment: Text.AlignVCenter
            font.family: Cfg.LESSON_LIST_FAMILY
            font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * widthRates
            font.capitalization: Font.SmallCaps
            color: "#666666"
            anchors.left: parent.left
            anchors.leftMargin: 6 * heightRate
            text: control.currentText
        }

        property Component __dropDownStyle: MenuStyle {
            __menuItemType: "comboboxitem"

            frame: Rectangle {
                color: "#fff"
                border.width: 1 * widthRates
                border.color: comboBox.pressed ? "#FF5500" : "#EEEEEE"
                radius: 2 * widthRates
            }

            itemDelegate.label: Item{
                width: parent.width
                height: 28 * heightRate
                Text {
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Cfg.LESSON_LIST_FAMILY
                    font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * widthRates
                    font.capitalization: Font.SmallCaps
                    color: styleData.selected ? "white" : "#757575"
                    text: styleData.text
                    anchors.left: parent.left
                    anchors.leftMargin: 10 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            itemDelegate.background: Rectangle {  // selection of an item
                color: styleData.selected ? "#FF5500" : "transparent"
//                radius: 2 * widthRates
            }
        }
    }
}


