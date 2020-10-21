import QtQuick 2.0
import "./Configuration.js" as Cfg

/*
*课程表使用说明
*/

MouseArea {
    id: lessonDescribeView
    hoverEnabled: true
    onWheel: {
        return;
    }

    Rectangle{
        color: "black"
        width: parent.width
        height: parent.height
        radius:  12 * widthRate
        opacity: 0.4
    }

    Rectangle{
        id: contentItem
        width: 500 * widthRate
        height: 580 * heightRate
        radius: 14 * heightRate
        color: "white"
        anchors.centerIn: parent
clip: true
        Text{
            id: tipsText
            width: 380 *widthRate
            height: 80 *heightRate
            text: "课程表使用说明"
            font.family: Cfg.LESSONINFO_FAMILY
            font.pixelSize:  (Cfg.LESSONINFO_FONTSIZE + 20) * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 20 * widthRate
            anchors.top:parent.top
            anchors.topMargin: 25*heightRate
            verticalAlignment: Text.AlignVCenter
        }

        Image{
            width: parent.width
            height: parent.height - 115*heightRate
            fillMode: Image.Stretch
            source: "qrc:/images/use.png"
            anchors.top: tipsText.bottom
        }

        MouseArea{
            id: closeButton
            z: 2
            width: 20 * widthRate
            height: 20 * widthRate
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
                    font.pixelSize: 20 * heightRate
                    color: "white"
                    anchors.centerIn: parent
                }
            }
            onClicked: {
                animateOpacityFadeout.start();
            }
        }
    }

    //动画过渡
    NumberAnimation {
        id: animateOpacity
        target: lessonDescribeView
        duration: 500
        properties: "opacity"
        from: 0.0
        to: 1.0
        onStopped: {
        }
    }
    NumberAnimation {
        id: animateOpacityFadeout
        target: lessonDescribeView
        duration: 500
        properties: "opacity"
        from: 1.0
        to: 0.0
        onStopped: {
            lessonDescribeView.visible = false;
        }
    }
    function startFadeOut()
    {
        lessonDescribeView.visible = true;
        animateOpacity.stop();
        animateOpacity.start();
        // animation.restart();
       // animationHeight.restart();
    }

}

