import QtQuick 2.0
import QtQml 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtMultimedia 5.5
import QtAV 1.7
import "./Configuuration.js" as Cfg

MouseArea{
    id:ymAudioPlayerManager
    property  double  zoomWidthRate: widthRate + 1.5;
    property bool isPlaying: false;
    property string filePath: "";

    property int playerTotleTime: 0;//播放总时间
    property string showTotleTime: "00:00:00";//显示总时间

    property int playTipContentTime: 0;//播放时间
    property string showCurrentPlayerTime: "00:00:00";//开始播放时间
    property int seekTime: 0;
    property string currentAudioName: "";

    visible: false
    width: 450 * widthRate
    height: 80 * heightRate

    onVisibleChanged:{
        if(ymAudioPlayerManager.visible == false){
            mediaPlayer.stop();
            isPlaying = false;
            console.log("===audio::Visible====")
        }
    }

    onPlayTipContentTimeChanged: {
        showCurrentPlayerTime = getPlayerTime(playTipContentTime);
        //console.log("============",playTipContentTime,playerTotleTime);
//        if(parseInt(playTipContentTime /1000) >= parseInt(playerTotleTime / 1000) ){
//            mediaPlayer.stop();
//            ymAudioPlayerManager.visible = false;
//        }
    }

    onPlayerTotleTimeChanged: {
        showTotleTime = getPlayerTime(playerTotleTime);
    }

    Rectangle {
        anchors.fill: parent
        color: "#3D3F4E"
    }

    MouseArea {
        id:startOrPushRectangle
        width: 14 * widthRate
        height: 14 * widthRate
        anchors.left: parent.left
        anchors.leftMargin: 20 * widthRate
        anchors.top: parent.top
        anchors.topMargin: (parent.height - height ) * 0.62

        onClicked:{//更换播放图标
            var currentTime = analysisTime(showCurrentPlayerTime)
            if(isPlaying) {
                mediaPlayer.pause();
            }
            else {
                mediaPlayer.play();
            }
            isPlaying = !isPlaying;
        }

        Image {
            id: audioPlayOrPushImage
            anchors.fill: parent
            source: isPlaying ? "qrc:/images/stop@2x.png" : "qrc:/images/start.png"
        }
    }


    Item {
        width: parent.width-startOrPushRectangle.width
        height: parent.height
        anchors.left:startOrPushRectangle.right
        anchors.leftMargin:10 * widthRate
        Item{//被播放文件的名字
            id:bePlayedFileNameRecatngle
            width: 200 * zoomWidthRate
            height: 16 * heightRate
            anchors.left:parent.left
            anchors.leftMargin: 8 * zoomWidthRate
            anchors.top:parent.top
            anchors.topMargin:  5 * zoomWidthRate
            Text {
                id: bePlayedFileNameText
                text: qsTr(currentAudioName)
                color: "#3c3c3e"
                font.pixelSize: 6.5*zoomWidthRate
                anchors.left: parent.left
            }
        }

        Item{//文件时长及播放进度
            width: parent.width
            height: 10 * zoomWidthRate
            anchors.top: bePlayedFileNameRecatngle.bottom
            //anchors.verticalCenter: parent.verticalCenter

            Item{//当前播放的进度时间
                id:bePlayedFileNowTimeRecatngle
                width: 40 * widthRate
                height:parent.height
                anchors.left:parent.left
                Text {
                    id: bePlayedFileNowTimeText
                    text:  showCurrentPlayerTime
                    color: "#ffffff"
                    font.family: Cfg.FONT_FAMILY
                    font.pixelSize: 14 * heightRate
                    anchors.centerIn: parent
                }
            }

            Item {
                id:bePlayedFileSliderRectangle
                width: parent.width - 140 * widthRate
                height: parent.height
                anchors.left: bePlayedFileNowTimeRecatngle.right
                anchors.leftMargin: 5 * widthRate
                Rectangle{
                    width:parent.width
                    height: 1.5 * zoomWidthRate
                    color:"#e3e6e9";
                    anchors.centerIn: parent
                    radius: 4 * zoomWidthRate;
                    Rectangle {
                        id: hasPlayedvalue
                        width: parent.width / audioPlayslider.maximumValue * audioPlayslider.value
                        height: 1.8 * zoomWidthRate
                        color:"#61A0FF";
                        anchors.left: parent.left
                        radius: 4 * zoomWidthRate;
                    }
                }

                Video {//MediaPlayer
                    id: mediaPlayer
                    autoLoad: true
                    autoPlay: true
                    onPositionChanged: {
                        playTipContentTime = position
                        audioPlayslider.value = position
                    }

                    onStatusChanged: {
                        switch(status){
                        case MediaPlayer.Loaded:                            
                            break;
                        case MediaPlayer.EndOfMedia:
                            isPlaying = false;
                            seekTime = 0;
                            break;
                        }
                    }

                    onDurationChanged: {
                        audioPlayslider.maximumValue = duration;
                        playerTotleTime = duration;
                    }

                    onPlaybackStateChanged: {
                        switch (mediaPlayer.playbackState) {
                        case MediaPlayer.PlayingState:
                            mediaPlayer.seek(seekTime);
                            //console.debug("the media is playing")
                            break;
                        case MediaPlayer.PausedState:
                            //console.debug("the media is paused")
                            break;
                        case MediaPlayer.StoppedState:
                            //console.debug("====the audio media is stop===")
                            break;
                        default :
                            //console.debug("the media is stopped")
                            break;
                        }
                    }
                }

                Slider {
                    anchors.centerIn: parent
                    id: audioPlayslider
                    width:parent.width
                    height: 5 * zoomWidthRate

                    style:SliderStyle{
                        groove:Item{
                            implicitHeight: 10 * zoomWidthRate;
                            implicitWidth: audioPlayslider.width;
                        }

                        handle: Rectangle{
                            id: name
                            width: 6 * zoomWidthRate
                            height: 6 * zoomWidthRate
                            radius: 100
                            anchors.centerIn: parent
                            color: "#9AACFF"
                        }
                    }

                    onValueChanged: {
                        playTipContentTime = value;
                    }

                    onPressedChanged:{
                        if(pressed == false){
                            var values = hasPlayedvalue.width / hasPlayedvalue.parent.width * mediaPlayer.duration;
                            if(!isPlaying){
                                isPlaying = true;
                            }

                            mediaPlayer.play();
                            mediaPlayer.seek(values);

                        }else{
                            mediaPlayer.pause();
                        }
                    }
                }
            }

            Item{//被播放文件的总时间
                id:bePlayedFileAllTimeRecatngle
                width: 40 * widthRate
                height:parent.height
                anchors.left:bePlayedFileSliderRectangle.right
                anchors.leftMargin: 5 * widthRate
                Text {
                    id: bePlayedFileAllimeText
                    text: showTotleTime
                    color: "#ffffff"
                    font.family: Cfg.FONT_FAMILY
                    font.pixelSize: 14 * heightRate
                    anchors.left: parent.left
                    anchors.centerIn: parent
                }
            }
        }        
    }

    MouseArea {
        width: 6 * zoomWidthRate
        height: 6 * zoomWidthRate
        anchors.right: parent.right
        anchors.rightMargin: 3 * zoomWidthRate
        anchors.top:parent.top
        anchors.topMargin:  3 * zoomWidthRate
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            ymAudioPlayerManager.visible = false;
            mediaPlayer.stop();
            isPlaying = false;
        }

        Image {
            id: closeimage
            anchors.fill: parent
            source: "qrc:/images/video_close@2x.png"
        }
    }

    function ymAudioPlayerManagerPlayFileByUrl(fileUrl,fileName,startTime,controlType) {
        mediaPlayer.stop();
        mediaPlayer.source = fileUrl;
        filePath = fileUrl;
        isPlaying = true;
        currentAudioName = fileName;
        ymAudioPlayerManager.visible = true;
        if(startTime > 0){
            seekTime = startTime * 1000;
        }
        //console.log("====seekTime=====",seekTime);
        if(controlType == "pause"){
            mediaPlayer.pause();
            return;
        }
        if(controlType == "stop"){
            mediaPlayer.stop();
            return;
        }

        mediaPlayer.play();
    }

    function closeAudio(){
        seekTime = 0;
        mediaPlayer.source = "";
        mediaPlayer.stop();
    }


    function analysisTime(times){
        var timeList = times.split(":");
        var hours = Math.floor(timeList[0] * 60 * 60);//时
        var minutes = Math.floor(timeList[1] * 60);//分
        var seconds = Math.floor(timeList[2]);//秒
        return hours + minutes + seconds;
    }

    function getPlayerTime(values){
        var time1 = 0;
        time1 = Math.floor( values / 1000);
        var time1a =  time1 % 60;
        var time1s = "";
        if(time1a > 9) {
            time1s = time1a.toString();
        }else {
            time1s = "0"+ time1a.toString();
        }

        var time2 = 0;
        time2 = Math.floor( time1 / 60 );
        var time2a =  time2 % 60;
        var time2s = "";

        if(time2a > 9) {
            time2s = time2a.toString();
        }else {
            time2s = "0"+ time2a.toString();
        }

        var time3 = 0;
        time3 = Math.floor(time1 / 3600 );
        var time3a =  time3 % 60;
        var time3s = "";

        if(time3a > 9) {
            time3s = time3a.toString();
        }else {
            time3s = "0"+ time3a.toString();
        }
        return  time3s +":"+time2s + ":" + time1s;
    }

}

