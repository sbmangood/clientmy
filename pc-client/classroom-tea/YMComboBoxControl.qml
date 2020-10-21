import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Private 1.0
import "./Configuuration.js" as Cfg

/**ComboBox更改后的样式控件**/
ComboBox {
    id: combox
    width: parent.width
    height: parent.height

    property var showType: 1;

    style: ComboBoxStyle{
        background: Rectangle{
            color: showType == 1 ? Cfg.COMBOX_BACK_COLOR : "transparent"
            border.color: showType == 1 ? Cfg.COMBOX_BODER_COLOR : "transparent"
            border.width: 0
            radius: 4 * heightRate
            Image {
                width:  showType == 1 ? parent.height * 0.4 : parent.height * 0.3
                height:  showType == 1 ? parent.height * 0.4 : parent.height * 0.3
                anchors.right: parent.right
                source: combox.pressed ? "qrc:/newStyleImg/th_btn_cuo_arrowup@2x.png" : "qrc:/newStyleImg/th_btn_cuo_arrowdown@2x.png"
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 3 * widthRate
            }
        }
        label: Item{
            width: combox.width
            height: combox.height
            Text {
                width: parent.width - 15 * heightRate
                verticalAlignment: Text.AlignVCenter
                font.family: Cfg.COMBOX_FAMILY
                font.pixelSize: Cfg.COMBOX_FONTSIZIE * heightRate
                font.capitalization: Font.SmallCaps
                color: Cfg.COMBOX_FONT_COLOR
                text: control.currentText
                elide: Text.ElideRight
            }
        }

        property Component __dropDownStyle: MenuStyle {
            __menuItemType: "comboboxitem"

            frame: Rectangle {
                color: "#fff"
                border.width: 0.5
                border.color: "#d3d8dc"
                radius: 5 * heightRates
                clip: true
            }

            itemDelegate.label: Item{
                width: combox.width
                height: {
                    if(styleData.text.length < 7){
                        return 28 * heightRate;
                    }else{
                        return 52 * heightRate
                    }
                }
                Text {
                    width: parent.width - 6 * heightRate
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10 * heightRate
                    font.family: Cfg.COMBOX_FAMILY
                    font.pixelSize: Cfg.COMBOX_FONTSIZIE * heightRate
                    font.capitalization: Font.SmallCaps
                    color: styleData.selected ? Cfg.COMBOX_FONT_HOVER : Cfg.COMBOX_FONT_COLOR
                    text: styleData.text
                    wrapMode: Text.WordWrap
                }
            }

            itemDelegate.background: Rectangle {  // selection of an item
                id:backgroundItem
                color: styleData.selected ? Cfg.COMBOX_BACK_COLOR : "transparent"
            }
        }
    }

    function setShowType( showTypes )
    {
       showType = showTypes;
    }
}
