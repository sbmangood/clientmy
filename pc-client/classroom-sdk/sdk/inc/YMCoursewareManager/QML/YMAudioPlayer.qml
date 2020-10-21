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
    property string fileId: "";
    property int playerTotleTime: 0;//播放总时间
    property string showTotleTime: "00:00:00";//显示总时间

    property int playTipContentTime: 0;//播放时间
    property string showCurrentPlayerTime: "00:00:00";//开始播放时间
    property int seekTime: 0;
    property string currentAudioName: "";


    //修复上课之前老师操作音视频 app端无法播放的bug
    property bool isStratClass: isStartLesson;

    onIsStratClassChanged:
    {
        if(isStratClass)
        {
            if(isPlaying)
            {
                mediaPlayer.seek(seekTime);
                sigPlayerMedia("audio","play",parseInt(seekTime / 1000),filePath,fileId)
            }
        }
    }

    //关闭音频信号
    signal sigClose(var vaType,var controlType,var times,var address,var fileId);

    //暂停信号
    signal sigPlayerMedia(var vaType,var controlType,var times,var address,var fileId)

    visible: false

    onVisibleChanged:{
        if(ymAudioPlayerManager.visible == false){
            mediaPlayer.stop();
            isPlaying = false;
        }
    }

    onPlayTipContentTimeChanged: {
        showCurrentPlayerTime = getPlayerTime(playTipContentTime);
        if(parseInt(playTipContentTime / 1000) >= parseInt(playerTotleTime / 1000)){
            if(playerTotleTime == 0){
                return;
            }

            audioPlayslider.value = 0;
            seekTime = 0;
            mediaPlayer.stop();
        }
    }

    onPlayerTotleTimeChanged: {
        showTotleTime = getPlayerTime(playerTotleTime);
    }

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        border.width: 1
        border.color: "#c3c6c9"
        radius: 6 * widthRate
    }

    MouseArea {
        id:startOrPushRectangle
        width: 50 * widthRate
        height: 40 * widthRate
        anchors.verticalCenter: parent.verticalCenter

        onClicked:{//更换播放图标
            var currentTime = analysisTime(showCurrentPlayerTime)
            seekTime = currentTime * 1000;
            if(isPlaying) {
                mediaPlayer.pause();
                sigPlayerMedia("audio","pause",currentTime,filePath,fileId);
            }
            else {
                mediaPlayer.play();
                sigPlayerMedia("audio","play",currentTime,filePath,fileId);
            }
            isPlaying = !isPlaying;
        }

        Image {
            id: audioPlayOrPushImage
            width: 20 * widthRate
            height: 20 * widthRate
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            source: isPlaying ? "qrc:/images/video_stop@2x.png" : "qrc:/images/video_start@2x.png"
        }
    }


    Video {//MediaPlayer
        id: mediaPlayer
        autoLoad: true
        autoPlay: true
        onPositionChanged: {
            audioPlayslider.value = position
            updatePlayerTime(parseInt(position /1000));
        }

        onBufferProgressChanged: {
            //console.log("=====bufferProgress======",bufferProgress)
        }

        onStatusChanged: {
            switch(status){
            case MediaPlayer.Loaded:
                break;
            case MediaPlayer.EndOfMedia:
                isPlaying = false;
                seekTime = 0;
                updatePlayerTime(0);
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
                sigPlayerMedia("audio","play",parseInt(seekTime / 1000),filePath,fileId);
                console.debug("the media is playing")
                break;
            case MediaPlayer.PausedState:
                console.debug("the media is paused")
                break;
            case MediaPlayer.StoppedState:
                sigPlayerMedia("audio","stop","0",filePath,fileId);
                console.debug("====the audio media is stop===")
                break;
            default :
                console.debug("the media is stopped")
                break;
            }
        }
    }
    //关闭按钮
    MouseArea {
        width: 24 * heightRate
        height: 24 * heightRate
        anchors.right: parent.right
        anchors.rightMargin: 6 * heightRate
        anchors.top:parent.top
        anchors.topMargin:  6 * heightRate
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            ymAudioPlayerManager.visible = false;
            mediaPlayer.stop();
            isPlaying = false;
            sigClose("audio","stop","0",filePath);
        }

        Image {
            id: closeimage
            anchors.fill: parent
            source: "qrc:/images/cr_btn_close.png"
        }
    }

    Item{//被播放文件的名字
        id:bePlayedFileNameRecatngle
        width: parent.width
        height: 18 * heightRate
        anchors.left: startOrPushRectangle.right
        anchors.top:parent.top
        anchors.topMargin:  4 * zoomWidthRate

        Text {
            id: bePlayedFileNameText
            text: qsTr(currentAudioName)
            color: "#3c3c3e"
            font.family: Cfg.font_family
            font.pixelSize: 14 * heightRate
            anchors.left: parent.left
        }
    }

    Item {
        width: parent.width- startOrPushRectangle.width
        height: 32 * heightRate
        anchors.left:startOrPushRectangle.right
        anchors.top: bePlayedFileNameRecatngle.bottom

        Item{//文件时长及播放进度
            width:  parent.width
            height: 10 * zoomWidthRate
            anchors.left:parent.left

            Item{//当前播放的进度时间
                id:bePlayedFileNowTimeRecatngle
                width: 40 * widthRate
                height:parent.height
                anchors.left:parent.left

                Text {
                    id: bePlayedFileNowTimeText
                    text:  showCurrentPlayerTime
                    color: "#222222"
                    font.family: Cfg.font_family
                    font.pixelSize: 14 * heightRate
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id:bePlayedFileSliderRectangle
                width: parent.width - bePlayedFileNowTimeRecatngle.width * 2 - 16 * zoomWidthRate
                height: parent.height
                anchors.left: bePlayedFileNowTimeRecatngle.right
                anchors.leftMargin: 10 * heightRate

                Rectangle{
                    width:parent.width
                    height: 6 * heightRate
                    color:"#e3e6e9";
                    anchors.centerIn: parent
                    radius: 4 * zoomWidthRate;
                    Rectangle {
                        id: hasPlayedvalue
                        width: parent.width / audioPlayslider.maximumValue * audioPlayslider.value
                        height: 1.8 * zoomWidthRate
                        color:"#ffccaa"
                        anchors.left: parent.left
                        radius: 4 * zoomWidthRate;
                    }
                }

                Slider {
                    id: audioPlayslider
                    width: parent.width
                    height: 25 * widthRate
                    anchors.centerIn: parent
                    style:SliderStyle{
                        groove:Item{
                            implicitHeight: 21 * heightRate
                            implicitWidth: 21 * heightRate
                        }

                        handle: Image{
                            id: name
                            width: 21 * heightRate
                            height: 21 * heightRate
                            anchors.centerIn: parent
                            source: "qrc:/images/mbig.png"
                        }
                    }

                    onValueChanged: {
                        playTipContentTime = value;
                    }

                    onPressedChanged: {
                        if(pressed == false){
                            //var values = Math.floor(audioPlayslider.value / 1000)//hasPlayedvalue.width / hasPlayedvalue.parent.width * mediaPlayer.duration;
                            if(!isPlaying){
                                isPlaying = true;
                            }
                            seekTime = audioPlayslider.value;
                            mediaPlayer.play();
                            //console.log("====audio=====",values)
                        }else{
                            mediaPlayer.pause();
                        }
                        console.log("======audio::pause=====",pressed);
                    }
                }
            }

            Item{//被播放文件的总时间
                id:bePlayedFileAllTimeRecatngle
                width: 40 * widthRate
                height:parent.height
                anchors.left:bePlayedFileSliderRectangle.right
                anchors.leftMargin: 10 * heightRate
                Text {
                    id: bePlayedFileAllimeText
                    text: showTotleTime
                    color: "#222222"
                    font.family: Cfg.font_family
                    font.pixelSize: 14 * heightRate
                    anchors.left: parent.left
                    anchors.centerIn: parent
                }
            }
        }
    }

    function ymAudioPlayerManagerPlayFileByUrl(fileUrl,fileName,startTime,audioPath,fileIds) {
        mediaPlayer.source = fileUrl;
        filePath = audioPath;
        fileId = fileIds;
        isPlaying = true;
        currentAudioName = fileName;
        ymAudioPlayerManager.visible = true;
        audioPlayslider.value = 0;
        playTipContentTime = 0;
        if(startTime > 0){
            seekTime = startTime * 1000;
        }
        setPlayerAudioBuffer(fileName);
    }

    function setPlayerAudioBuffer(fileName){
        if(audioPlayerBuffer.length == 0){
            audioPlayerBuffer.push({
                                       "fileName": fileName,
                                       "playerTimer": 0,
                                   });
            mediaPlayer.play();
            return;
        }

        var isAdd = true;
        for(var i = 0; i < audioPlayerBuffer.length;i++){
            if(audioPlayerBuffer[i].fileName == fileName){
                var playerTime = audioPlayerBuffer[i].playerTimer;
                sigPlayerMedia("audio","play",playerTime,filePath,fileId);
                seekTime = playerTime * 1000;
                mediaPlayer.play();
                isAdd = false;
                //console.log("===============",playerTime);
                break;
            }
        }
        if(isAdd){
            audioPlayerBuffer.push({
                                       "fileName": fileName,
                                       "playerTimer": 0,
                                   });
            seekTime = 0;
            mediaPlayer.play();
        }
    }

    function updatePlayerTime(currentTime){
        for(var i = 0; i < audioPlayerBuffer.length; i++){
            if(audioPlayerBuffer[i].fileName == currentAudioName){
                audioPlayerBuffer[i].playerTimer = currentTime;
                //console.log("**************",currentTime);
                break;
            }
        }
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

