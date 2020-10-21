import QtQuick 2.0

MouseArea {
    id: lessonDescribeView
    hoverEnabled: true
    onWheel: {
        return;
    }

    Rectangle{
        color: "black"
        opacity: 0.4
        radius:  12 * widthRate
        anchors.fill: parent
    }

    //淡入效果
    NumberAnimation{
        id: animateInOpacity
        target: lessonDescribeView
        duration: 500
        properties: "opacity"
        from: 0.0
        to: 1.0
    }

    //淡出效果
    NumberAnimation{
        id: animateOutOpactiy
        target: lessonDescribeView
        duration: 500
        properties: "opacity"
        from: 1.0
        to: 0.0
        onStopped: {
            lessonDescribeView.visible = false;
        }
    }

    Rectangle{
        id: contentItem
        width: 500*widthRate
        height: 580*heightRate
        radius: 14*heightRate
        color: "white"
        anchors.centerIn: parent

        Image{
            anchors.fill: parent
            fillMode: Image.Stretch
            source: "qrc:/images/use.png"
        }

        MouseArea{
            id: closeButton
            z: 2
            width: 25*widthRate
            height: 25*widthRate
            hoverEnabled: true
            anchors.top: parent.top
            anchors.topMargin: 10*heightRate
            anchors.right: parent.right
            anchors.rightMargin: 10*heightRate
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                anchors.fill: parent
                radius: 100
                color: "#e3e6e9"

                Text{
                    text: "×"
                    font.bold: true
                    font.pixelSize: 30*heightRate
                    color: "white"
                    anchors.centerIn: parent
                }
            }
            onClicked: {
                animateOutOpactiy.stop();
                animateOutOpactiy.start();
            }
        }
    }

    function startAnimate(){
        lessonDescribeView.visible = true;
        animateInOpacity.stop();
        animateInOpacity.start();
    }
}

