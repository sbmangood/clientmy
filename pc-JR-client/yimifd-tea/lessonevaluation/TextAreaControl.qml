import QtQuick 2.0
import QtQuick.Controls 2.0
import "Configuration.js" as Cfg

TextField {
    font.family: Cfg.DEFAULT_FONT
    font.pixelSize: 16 * heightRate
    background: Rectangle{
        radius: 4 * heightRate
//        border.color: "#37394C"//length == maximumLength ? "red" : "#37394C"
        border.width: 0
        color: "#37394C"
    }
    focus: true
    wrapMode: TextInput.WrapAnywhere
    selectByMouse: true
    verticalAlignment: Text.AlignLeft
}

