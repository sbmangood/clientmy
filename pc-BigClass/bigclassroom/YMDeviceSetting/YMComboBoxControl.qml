import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Private 1.0
import "./Configuration.js" as Cfg
import QtGraphicalEffects 1.0
/**ComboBox更改后的样式控件**/

ComboBox {
    id:combox
    width: parent.width
    height: parent.height
    style: ComboBoxStyle{
        background: Rectangle{
            width: combox.width
            height: combox.height
            color:  "#494B60"
            radius: 4 * heightRate
            Image {
                width: 20 * heightRate
                height: parent.height * 0.4
                anchors.right: parent.right
                source: "qrc:/networkImage/UPDOWN@2x.png"
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 5 * widthRate
            }

        }
        label: Text {
            verticalAlignment: Text.AlignVCenter
            font.family: Cfg.COMBOX_FAMILY
            font.pixelSize: Cfg.COMBOX_FONTSIZIE * heightRate
            font.capitalization: Font.SmallCaps
            color: "#8B8FBD"
            text: control.currentText
            elide: Text.ElideRight
        }

        property Component __dropDownStyle: MenuStyle {
            __menuItemType: "comboboxitem"

            frame: Rectangle {
                color: "#494B60"
            }

            itemDelegate.label: Item{
                width: parent.width
                height: 28 * heightRate
                Text {
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Cfg.COMBOX_FAMILY
                    font.pixelSize: Cfg.COMBOX_FONTSIZIE * heightRate
                    font.capitalization: Font.SmallCaps
                    color: styleData.selected ? "#ffffff" : "#8B8FBD"
                    text: styleData.text
                }
            }

            itemDelegate.background: Rectangle {  // selection of an item
                color: styleData.selected ? "#494B60" : "transparent"
            }
        }
    }
}
