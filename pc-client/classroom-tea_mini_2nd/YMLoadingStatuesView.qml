import QtQuick 2.0
import "./Configuuration.js" as Cfg

Rectangle{
    id: loadingsView
    width: parent.width
    height: parent.height
    radius:  12 * widthRate

    property string tips: "页面加载中"
    property bool opacityAnimation: true;//渐出属性
    signal changeVisible();
    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
    }

    onOpacityAnimationChanged: {
        animateOpacity.stop();
        animateOpacity.start();
    }

    onVisibleChanged: {
        if(visible){
            loadingsView.opacity = 1
            nameImage.source = "qrc:/images/loading.gif"
        }else
        {
            nameImage.source = ""
        }
    }

    //渐出动画
    NumberAnimation {
        id: animateOpacity
        target: loadingsView
        duration: 500
        properties: "opacity"
        from: 1.0
        to: 0.0
        onStopped: {
            loadingsView.visible = false;
            changeVisible();
        }
    }

    Rectangle{
        id: bodyItem
        z: 1
        width: 120 * widthRate
        height: 60 * heightRate
        color: "white"
        radius: 6
        anchors.centerIn: parent

        Row{
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            AnimatedImage{
                id: nameImage
                width: 22 * heightRate
                height: 22 * heightRate
                source: ""
                anchors.verticalCenter: parent.verticalCenter
                cache: true
            }

            Text {
                id: beShowedText
                height: parent.height
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 13 * widthRate
                text: tips
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
