import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
//import QtMultimedia 5.8
import QtAV 1.7
/*
 *视频播放
 */

Rectangle {
    id:mediaPlayer


    property double widthRates: mediaPlayer.width / 450.0
    property double heightRates: mediaPlayer.height / 330.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property double sliderLength: 0.0
    property bool  playStatues: false


    property int xPressedPosition: 0
    property int yPressedPosition: 0

    property  bool playbackStateIsStop: true;
    radius: 10 * mediaPlayer.ratesRates
    //全屏状态
    property bool fullScreenStatus:false
    //播放音乐的内容
    property string playTipContents: ""

    //起始时间
    property string statTimeContents: "00:00:00"

    //总时间
    property string endtimeContents: "00:00:00"

    //总时间长度
    property int endtimeContentTime: 0

    //播放时间
    property int playTipContentTime: 0

    //播放时间
    property int playTipContentTimes: 0

    signal closeTheWidget();

    color: "#3c3c3e"

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


    //设置播放内容
    function setPlayTipContents(contents){
        mediaPlayer.playTipContents = contents;

    }

    //全屏播放
    onFullScreenStatusChanged:{
        if(fullScreenStatus) {
            //fullScreenImage.source = "qrc:/images/video_btn_fullscreenTwo.png";
            mediaPlayer.width = fullWidths;
            mediaPlayer.height = fullHeights;
            mediaPlayer.radius =  0 * mediaPlayer.ratesRates

            xPressedPosition =  mediaPlayer.x
            yPressedPosition =  mediaPlayer.y
            mediaPlayer.x = 0;
            mediaPlayer.y = 0;

        }else {
            //fullScreenImage.source = "qrc:/images/video_smallscrenTwo.png";
            mediaPlayer.width = 450 * fullWidths / 1440;
            mediaPlayer.height = 330 * fullHeights / 900;
            mediaPlayer.radius =  10 * mediaPlayer.ratesRates

            mediaPlayer.x = xPressedPosition;
            mediaPlayer.y = yPressedPosition;
        }
    }

    //设置视频的url
    function setAudioUrl(urls){

        mediaPlayer.playStatues = false;

        if(audio.source != urls  ){
            mediaPlayer.endtimeContentTime = 0;
            console.log("urls ==",urls);
            mediaPlayer.playTipContentTime = 0;

            audio.source = "";
            audio.source = urls;

            times.start();
        }else {
            //  audio.source = urls;
            if(playbackStateIsStop)
            {
                //console.log(audio.playbackState,"mediaPlayer.playStatues")
                mediaPlayer.endtimeContentTime = 0;
                mediaPlayer.playTipContentTime = 0;
                audio.source = "";
                audio.source = urls;
            }
            times.start();
        }


    }


    //设置视频的url跟名称
    function setVideoContents( contents ,  names) {
        mediaPlayer.visible = true;
        setPlayTipContents(names);
        setAudioUrl(contents);

    }

    //设置总时间
    onEndtimeContentTimeChanged: {
        var time1 = 0;
        time1 = Math.floor(endtimeContentTime / 1000 );
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
        time3 = Math.floor( time1 / 3600 );
        var time3a =  time3 % 60;
        var time3s = "";

        if(time3a > 9) {
            time3s = time3a.toString();

        }else {
            time3s = "0"+ time3a.toString();
        }
        mediaPlayer.endtimeContents =  time3s +":"+time2s + ":" + time1s;

    }

    //设置播放时间
    onPlayTipContentTimeChanged: {
        var time1 = 0;
        time1 = Math.floor( playTipContentTime / 1000);
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
        mediaPlayer.statTimeContents =  time3s +":"+time2s + ":" + time1s;
        // console.log("mediaPlayer.playTipContentTime ==",mediaPlayer.playTipContentTime ,"mediaPlayer.endtimeContentTime ==",mediaPlayer.endtimeContentTime)

        if(mediaPlayer.playTipContentTime >= mediaPlayer.endtimeContentTime && mediaPlayer.endtimeContentTime > 0) {
            mediaPlayer.playStatues = false;
        }
    }

    onPlayStatuesChanged: {
        console.log("playStatues ==",playStatues)
        if(playStatues) {
            audio.play();
        }else {
            audio.pause();
        }
    }

    Text {
        id:playContentName
        width: 380 * mediaPlayer.widthRates
        height:  20 * mediaPlayer.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 15 * mediaPlayer.widthRates
        anchors.topMargin:  8 * mediaPlayer.heightRates
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 17 * mediaPlayer.ratesRates
        clip: true
        elide: Text.ElideMiddle
        font.family: "Microsoft YaHei"
        color: "#ffffff"
        text: mediaPlayer.playTipContents
    }

    Rectangle{
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        color: "#00000000"
        z:4
        MouseArea{
            anchors.fill:  parent
            onPositionChanged: {
                if(fullScreenStatus) {
                    return;
                }
                mediaPlayer.x  +=  mouseX - xPressedPosition;
                mediaPlayer.y  +=  mouseY - yPressedPosition;


            }
            onPressed: {
                if(!fullScreenStatus) {
                    console.log("xPressedPosition===",xPressedPosition)
                    xPressedPosition = mouseX;
                    yPressedPosition = mouseY;

                }



            }
        }
    }

    //播放视频
    Video{
        id:audio
        volume: 1
        width:parent.width
        height:  250 * mediaPlayer.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 0 * mediaPlayer.widthRates
        anchors.topMargin:  32 * mediaPlayer.heightRates
       // fillMode: VideoOutput.Stretch
        autoLoad: true
        //autoPlay: false
        z:3
        onBufferProgressChanged: {
        }

        onStatusChanged:
        {
            console.log("11qwerds",MediaPlayer.NoMedia,MediaPlayer.Loading,MediaPlayer.Loaded,MediaPlayer.Buffering);
            console.log("11qwerds",MediaPlayer.Stalled,MediaPlayer.Buffered,MediaPlayer.EndOfMedia,MediaPlayer.InvalidMedia,MediaPlayer.UnknownStatus);

            console.log("media player  status ",audio.status);
        }

        onDurationChanged: {
            if(duration != 0)
            {
                mediaPlayer.endtimeContentTime = duration;
            }
            console.log("mediaPlayer.endtimeContentTime ==",mediaPlayer.endtimeContentTime);
        }

        onPositionChanged: {
            mediaPlayer.playTipContentTime =  position;

        }
        onPlaybackStateChanged:
        {
            playbackState != 0 ? playbackStateIsStop = false : playbackStateIsStop = true;
            console.log( playbackStateIsStop," playbackStateIsStop");
        }
    }


    //全屏按钮
    Rectangle{
        id:fullScreenBtn
        width:48 * mediaPlayer.ratesRates
        height: 48 * mediaPlayer.ratesRates
        anchors.right:  parent.right
        anchors.top: audio.bottom
        radius: 10 * mediaPlayer.ratesRates
        color: "#3c3c3e"
        z:5
        Image {
            id: fullScreenImage
            width: 25 * mediaPlayer.heightRates
            height: 25 * mediaPlayer.heightRates
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin:  parent.height / 2 - 15 * mediaPlayer.heightRates
            anchors.leftMargin:   parent.height / 2 - 15 * mediaPlayer.heightRates
            source: !fullScreenStatus ? "qrc:/images/video_btn_fullscreenTwo.png": "qrc:/images/video_smallscrenTwo.png"
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(mediaPlayer.fullScreenStatus == false) {
                    mediaPlayer.fullScreenStatus = true;
                }else {
                    mediaPlayer.fullScreenStatus = false;
                }
            }
        }

    }



    //时间显示
    Rectangle{
        id:playContent
        width: parent.width - 48 * mediaPlayer.ratesRates - fullScreenBtn.width
        height:  48 * mediaPlayer.ratesRates
        anchors.left: parent.left
        anchors.leftMargin:48 * mediaPlayer.ratesRates
        anchors.bottom:  parent.bottom
        color: "#3c3c3e"
        z:3

        Text {
            id: statTimeLabel
            width: 60 * mediaPlayer.widthRates
            height:  20 * mediaPlayer.heightRates
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 12 *  mediaPlayer.heightRates
            anchors.leftMargin:playContent.width / 2 - 60 * mediaPlayer.widthRates
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14 * mediaPlayer.ratesRates
            // clip: true
            font.family: "Microsoft YaHei"
            color: "#ffffff"
            text: mediaPlayer.statTimeContents
        }

        Text {
            id: endtimeLabel
            width: 60 * mediaPlayer.widthRates
            height:  20 * mediaPlayer.heightRates
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin:playContent.width / 2
            anchors.topMargin:  12 * mediaPlayer.heightRates
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14 * mediaPlayer.ratesRates
            //  clip: true
            font.family: "Microsoft YaHei"
            color: "#ffffff"
            text: "/"+ mediaPlayer.endtimeContents
        }

    }

    //记忆播放视频
    Timer{
        id:times
        interval: 100;
        running: false;
        repeat: false
        onTriggered:{
            times.stop()
            if(mediaPlayer.playTipContentTimes <   mediaPlayer.endtimeContentTime && mediaPlayer.endtimeContentTime  > 0) {
                audio.play();
                audio.seek(mediaPlayer.playTipContentTimes);
                mediaPlayer.playStatues = true;

            }else {
                times.start();
            }

        }
    }

    Component.onCompleted: {
        mediaPlayer.x = xPressedPosition;
        mediaPlayer.y = yPressedPosition;
    }

}
