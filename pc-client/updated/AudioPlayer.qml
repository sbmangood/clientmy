import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtMultimedia 5.8
/*
 *音频播放器
 */

Rectangle {
    id:audioPlayer


    property double sliderLength: 0.0
    property bool  playStatues: false

    //播放音乐的内容
    property string playTipContents: ""

    //结束时间
    property int endtimeContentTime: 0

    //播放时间
    property int playTipContentTime: 0

    //播放时间
    property int playTipContentTimes: 0

    signal closeTheWidget();

    color: "#ff8000"

    signal  sigVideoStream(string types ,string staues,string times , string address);

    //停止视频
    function stopVideo(){
        playStatues= false;
        audio.stop();
    }


    //先暂停
    function pauseVideo(){
         audio.pause();
    }


    //设置波让内容
    function setPlayTipContents(contents){
        audioPlayer.playTipContents = contents;

    }

    //设置音频播放的url
    function setAudioUrl(urls){
        audioPlayer.playStatues = false;

        if(audio.source != urls){
            audioPlayer.endtimeContentTime = 0;
            //console.log("urls ==",urls);
            audioPlayer.playTipContentTime = 0;
            audio.source = "";
            audio.source = urls;

            times.start();
        }else {
            times.start();

        }


    }

    function setVideoContents( contents ,  names) {
        setPlayTipContents(names);
        setAudioUrl(contents);

    }

    onEndtimeContentTimeChanged: {
    }

    onPlayTipContentTimeChanged: {
        if(playTipContentTime >= audioPlayer.endtimeContentTime) {
            audioPlayer.playStatues = false;
        }

    }

    onPlayStatuesChanged: {
        if(playStatues) {
            audio.play();
        }else {
            audio.pause();
        }
    }



    Audio{
        id:audio
        volume: 1
        autoLoad: true
        onBufferProgressChanged: {
        }
        onDurationChanged: {
            audioPlayer.endtimeContentTime = duration;
            //  console.log("audioPlayer.endtimeContentTime ==",audioPlayer.endtimeContentTime);
        }

        onPositionChanged: {
            audioPlayer.playTipContentTime =  position;

        }
    }


    Timer{
        id:times
        interval: 100;
        running: false;
        repeat: false
        onTriggered:{
            times.stop()
            if(audioPlayer.playTipContentTimes <  audioPlayer.endtimeContentTime && audioPlayer.endtimeContentTime  > 0) {
                audio.seek(audioPlayer.playTipContentTimes);
                audioPlayer.playStatues = true;

            }else {
                times.start();
            }

        }
    }

}
