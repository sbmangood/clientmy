import QtQuick 2.0
import "Configuration.js" as Cfg

Rectangle{
    id: loadingView
    anchors.fill: parent
    color: "white"
    radius:  12 * widthRate

    property string tips: ""
    onVisibleChanged:
    {
        if(loadingView.visible == true)
        {
            nameImage.source="qrc:/images/loading.gif"
        }else
        {
            nameImage.source = "";
        }
    }
    MouseArea{
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            // console.log("===loding::check===")
        }
    }

    //渐出动画
    NumberAnimation {
        id: animateOpacity
        target: loadingView
        duration: 1000
        properties: "opacity"
        from: 1.0
        to: 0.0
        onStopped: {
            loadingView.visible = false;
            loadingView.opacity = 1;
        }
    }

    Rectangle{
        id: bodyItem
        width: 120 * widthRate
        height: 60 * heightRate
        color: "white"
        radius: 6 * heightRate
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
                font.family: Cfg.LODING_FAMILY
                font.pixelSize: Cfg.LODING_FONTSIZE * widthRate
                text: tips
                verticalAlignment: Text.AlignVCenter
            }
        }
    }


    //切换使用者身份的时候的提示逻辑
    Timer{
        id: timer
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            parent.visible=false;
            if(tips.toString().indexOf("家长") != -1){
                isParentRemindHadShowed ? parentRemindView.visible=false : parentRemindView.visible=true;
            }
            tips = "";
        }
    }

    function changeUser(beShowedTextWhenChange)
    {
        tips=beShowedTextWhenChange;
        loadingView.visible=true;
        timer.start();
    }

    function startFadeOut()
    {
        animateOpacity.stop();
        animateOpacity.start();
        //  visible=false;
    }
}
