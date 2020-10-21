import QtQuick 2.0
import "../../Configuration.js" as Cfg

Rectangle{
    id: loadingView
    radius:  12 * widthRate
    anchors.fill: parent

    property string tips: "页面加载中"
    property bool opacityAnimation: true;//渐出属性

    MouseArea{
        anchors.fill: parent
        z:1000
        onClicked:
        {
            return;
        }
    }

    onOpacityAnimationChanged: {
        animateOpacity.stop();
        animateOpacity.start();
    }

    onVisibleChanged: {
        if(visible){
            loadingView.opacity = 1
            nameImage.source = "qrc:/images/loading.gif"
        }else
        {
            nameImage.source = ""
        }
    }

    //渐出动画
    NumberAnimation {
        id: animateOpacity
        target: loadingView
        duration: 500
        properties: "opacity"
        from: 1.0
        to: 0.0
        onStopped: {
            loadingView.visible = false;
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
                width: 18 * heightRate
                height: 18 * heightRate
                source: ""
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: beShowedText
                height: parent.height
                font.family: Cfg.LOADING_FAMILY
                font.pixelSize: Cfg.LOADING_FONTSIZE * widthRate
                text: tips
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
