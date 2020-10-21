import QtQuick 2.0
import "Configuration.js" as Cfg

MouseArea {
    width: parent.width
    height: parent.height
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true

    property string displayerText: "";
    property bool visibleLin: true;

    Text{
        text: displayerText
        color: parent.containsMouse ? Cfg.MENU_SETTING_HOVECOLOR : Cfg.MENU_SETTING_COLOR
        anchors.centerIn: parent
        font.family: Cfg.MENU_SETTING_FAMILY
        font.pixelSize: Cfg.MENU_SETTING_FONTSIZE * heightRate
    }

    Rectangle{
        width: parent.width
        height: 1
        visible: visibleLin
        color: "#e3e6e9"
        anchors.bottom: parent.bottom
    }
}

