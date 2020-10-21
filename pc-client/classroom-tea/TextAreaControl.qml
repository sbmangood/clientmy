import QtQuick 2.0
import QtQuick.Controls 2.0
import "Configuuration.js" as Cfg

TextField {
    font.family: Cfg.font_family
    font.pixelSize: 16 * heightRate
    background: Rectangle{
        radius: 4 * heightRate
        border.color: "#c0c0c0"//length == maximumLength ? "red" : "#c0c0c0"
        border.width: 0
    }
    focus: true
    wrapMode: TextInput.WrapAnywhere
    selectByMouse: true
    verticalAlignment: Text.AlignLeft
}

