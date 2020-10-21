import QtQuick 2.0
import "./Configuration.js" as Cfg

MouseArea{
    width: 60 * heightRate
    height: 60 * heightRate
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    property string number: "";
    property bool isSelected: false;

    signal sigAdd();//加信号
    signal sigSub();//减信号
    signal sigSelected(var mumber,var isCheckAnswer);

    visible: number == "" ? false : ((isStartTopic && (number == "+" || number == "一" )) ? false : true)

    Rectangle{
        anchors.fill: parent
        radius: 100
        border.width: 1
        border.color: parent.containsMouse ? "#4D90FF" : "#363847"
        color: isSelected ? "#4D90FF": "#363847"
    }

    Text {
        anchors.centerIn: parent
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 24 * heightRate
        text: number
        color: "#ffffff"
    }

    onClicked: {
        if(number == "+"){
            sigAdd();
            return;
        }
        if(number == "一"){
            sigSub();
            return;
        }
        var selected = !isSelected;
        sigSelected(number,selected);
    }
}
