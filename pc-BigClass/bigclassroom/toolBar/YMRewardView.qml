import QtQuick 2.0
import QtMultimedia 5.0
import "./Configuration.js" as Cfg

/*
*奖杯
*/

Item {
    id: rewardView
    width: parent.width
    height: parent.height

    onVisibleChanged: {
        if(visible){
            rewardAnimation.start();
            media.source = "";
            media.source = "qrc:/mp3/reward.mp3"
            media.play();
        }
    }

    MediaPlayer{
        id:media
    }

    Image{
        id: rewardImg
        width: 280 * heightRate
        height: 280 * heightRate
        source: "qrc:/redPackge/jb.png"
        anchors.centerIn: parent
    }

    NumberAnimation {
        id: rewardAnimation
        target: rewardImg
        property: "scale"
        duration: 2500
        from: 0.4
        to: 1
        easing.type: Easing.InOutQuad
        onStopped: {
            rewardView.visible = false;
            media.stop();
        }
    }

}
