import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "./Configuuration.js" as Cfg

Rectangle {
    id: playerView
    color: "#3c3c3e"

    property bool playerStatus: false;
    property int sliderValue: 0;
    property int mediaTotalTimer: 0;

    property string startTimeText: "00:00:00";
    property string endTimeText: "00:00:00";

    signal playerMedia();//播放信号
    signal pauseMedia();//暂停播放
    signal sigPause();//操作暂停
    signal seekMedia(var position);

    onSliderValueChanged: {
        videoPlayslider.value  = sliderValue;
    }
    onMediaTotalTimerChanged: {
        videoPlayslider.maximumValue = mediaTotalTimer;
    }

    Rectangle{
        width: parent.width
        height: parent.height * 0.5
        color: "#3c3c3e"
    }

    MouseArea{
        id: playerButton
        width: 22 * widthRate
        height: 22 * widthRate
        anchors.left: parent.left
        anchors.leftMargin: 20 * widthRate
        anchors.verticalCenter: parent.verticalCenter

        Image{
            id: playerImg
            anchors.fill: parent
            source: playerStatus ? "qrc:/images/stop@2x.png" : "qrc:/images/start@2x.png"
        }
        onClicked: {
            if(!playerStatus){
                playerStatus = true;
                playerMedia();
            }else{
                pauseMedia();
                playerStatus = false;
            }
        }
    }

    Text{
        id: startText
        text: startTimeText
        color: "white"
        font.family: Cfg.FONT_FAMILY
        font.pixelSize: 13 * widthRate
        anchors.left: playerButton.right
        anchors.leftMargin: 20 * widthRate
        anchors.verticalCenter: parent.verticalCenter
    }

    Item{
        id: progressBar
        width: parent.width - playerButton.width - startText.width - 80 * widthRate - endText.width
        height:  parent.height
        anchors.left: startText.right
        anchors.leftMargin: 10 * widthRate

        Rectangle{//slider颜色控制
            width: parent.width
            height: 4 * widthRate
            color:"#ffffff";
            anchors.centerIn: parent
            radius: 6 * widthRate;

            Rectangle {
                id:hasPlayedvalue
                width: videoPlayslider.width / videoPlayslider.maximumValue * videoPlayslider.value;
                height: 4 * widthRate
                color:"#61A0FF"
                anchors.left: parent.left
                radius: 6 * widthRate;
            }
        }

        Slider{
            anchors.centerIn: parent
            id: videoPlayslider
            width: parent.width
            height: 6 * heightRate

            style:SliderStyle{
                groove:Item {
                    implicitHeight: 18 * widthRate
                    implicitWidth: videoPlayslider.width
                }
                handle: Rectangle {
                    id: name
                    width: 18 * widthRate
                    height: 18 * widthRate
                    color: "#9AACFF"
                    radius: 100
                    anchors.centerIn: parent
                }
            }

            onValueChanged: {
                //playTipContentTime = value;
            }

            onPressedChanged: {
                if(!playerStatus){
                    playerStatus = true;
                }
                if(pressed == false){
                    seekMedia(videoPlayslider.value);
                }else{
                    pauseMedia();
                }
            }
        }
    }

    Text{
        id: endText
        text: endTimeText
        color: "white"
        font.family: Cfg.FONT_FAMILY
        font.pixelSize: 13 * widthRate
        anchors.left: progressBar.right
        anchors.leftMargin: 10 * widthRate
        anchors.verticalCenter: parent.verticalCenter
    }
}

