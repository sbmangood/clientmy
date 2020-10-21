import QtQuick 2.0

Item {
    id: tipsView
    z: 565
    anchors.fill: parent
    property string tips: "还未开始上课，暂时无法旁听!"

    Rectangle{
        anchors.fill: parent
        color: "black"
        opacity: 0.4
        radius: 12 * heightRate
    }

    onVisibleChanged: {
        if(visible){
            timers.start();
        }
    }

    Timer{
        id: timers
        running: false
        interval: 2000
        onTriggered: {
            tipsView.visible = false;
        }
    }

    Rectangle{
        color: "#ffffff"
        radius: 6
        width: 300 * widthRate
        height: 60 * heightRate
        anchors.centerIn: parent

        Item{
            id: tipsItem
            width: parent.width
            height: 40 * heightRate
            anchors.centerIn: parent
            Text{
                text: tips
                anchors.centerIn: parent
                font.pixelSize: 20 * heightRate
                color: "#666666"
            }
        }
    }
}

