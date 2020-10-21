import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "Configuration.js" as Cfg

ComboBox {
    id: comboBox
//    height: 35
//    width: 200
//    anchors.right: parent.right
//    anchors.rightMargin: contentRightMargin
//    anchors.verticalCenter: parent.verticalCenter
    style:ComboBoxStyle{
        background: Rectangle {
            anchors.fill: comboBox
            //implicitWidth: comboBox.width
            //implicitHeight: comboBox.height
            //border.color: "#E0E0E0"
            //border.width: 1
            color: comboBox.pressed ? Cfg.TR_SELECTED_CLR : comboBox.hovered ? Cfg.TR_HOVERED_CLR : "white"
        }
    }
}
