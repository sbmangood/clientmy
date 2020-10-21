import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Rectangle {
    anchors.fill: parent
    color: "transparent"
    property double rates: heightRate //* 0.8;
    Rectangle
    {
        anchors.fill: parent
        color: "black"
        opacity: 0.4
    }
    MouseArea
    {
        anchors.fill: parent
        onClicked:
        {
            return;
        }
    }

    Rectangle
    {
        width: 375 * rates
        height: 403 * rates
        radius: 5 * rates
        color: "#FFFFFF"
        anchors.centerIn: parent

        Rectangle
        {
            width: parent.width
            height: 47 * rates
            color: "#EEEEEE"
            radius: 5 * rates
            Rectangle
            {
                width: parent.width
                height: 17 * rates
                color: "#EEEEEE"
                anchors.bottom: parent.bottom
            }
            Text {
                anchors.centerIn: parent
                font.family: "Microsoft YaHei"
                font.pixelSize: 17 * heightRate
                color: "#333333"
                text: "学习资料"
            }
        }
    }

}
