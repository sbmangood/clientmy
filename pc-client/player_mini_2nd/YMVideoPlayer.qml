import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtAV 1.7
import "./Configuuration.js" as Cfg

Item{
    id: ymVideoPlayerManager

    property  double  zoomWidthRate: widthRate +  1.5;

    visible: false;

    property bool isPlaying: false;
    property  string bePlayedFileName: "";
    property  bool isFullScreen: false;
    property string filePath: "";
    property int playerTotleTime: 0;//播放总时间
    property string showTotleTime: "0";//显示总时间

    property int playTipContentTime: 0;//播放时间
    property string showCurrentPlayerTime: "00:00:00";//开始播放时间

    property int seekTime: 0;

    onPlayTipContentTimeChanged: {
        showCurrentPlayerTime =  getPlayerTime(playTipContentTime);
        //console.log("======video======",playTipContentTime,playerTotleTime);
//        if(parseInt(playTipContentTime /1000) >= parseInt(playerTotleTime / 1000) ){
//            mediaPlayer.stop();
//            ymVideoPlayerManager.visible = false;
//        }
    }

    onPlayerTotleTimeChanged: {
        showTotleTime =  getPlayerTime(playerTotleTime);
    }

    onVisibleChanged:{
        if(visible) {
            ymVideoPlayerManager.x = (parent.width-ymVideoPlayerManager.width) / 2;
            ymVideoPlayerManager.y = (parent.height-ymVideoPlayerManager.height) / 2;
        }else {
            isPlaying = false;
            mediaPlayer.stop();
        }
    }

    MouseArea  {
        anchors.fill: parent
        Rectangle{
            anchors.fill: parent
            color: "#3c3c3e"
            radius: 6 * widthRate
        }
    }

    //窗体移动
    MouseArea {
        id: dragRegion
        width: parent.width
        height: 45 * heightRate

        property point clickPos: "0,0"

        onPressed: {
            clickPos  = Qt.point(mouse.x,mouse.y)
        }

        onPositionChanged: {
            if(ymVideoPlayerManager.width!=ymVideoPlayerManager.parent.width) {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                ymVideoPlayerManager.x = (ymVideoPlayerManager.x + delta.x);
                ymVideoPlayerManager.y = (ymVideoPlayerManager.y + delta.y);
            }
        }

        Text {
            id: bePlayedFileNameText
            text: qsTr("")
            color: "#ffffff"
            font.family: Cfg.FONT_FAMILY
            font.pixelSize: 6.5 * zoomWidthRate
            anchors.centerIn: parent
        }

        //关闭按钮
        MouseArea {
            width: 18 * heightRate
            height: 18 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 4 * zoomWidthRate
            anchors.verticalCenter: parent.verticalCenter
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                isPlaying = false;
                mediaPlayer.stop();
                ymVideoPlayerManager.visible = false;
            }

            Image {
                anchors.fill: parent
                source: "qrc:/images/head_quit_sedtwox.png"
            }
        }
    }


    //播放视频区域
    Video {
        id: mediaPlayer
        width: parent.width
        height: parent.height - dragRegion.height - 60 * heightRate
        anchors.top: dragRegion.bottom
        source: filePath
        autoLoad: true
        autoPlay: true
        onPlaying: {
            //console.debug("playing")
        }
        onPaused: {
            //console.debug("paused")
        }
        onPositionChanged: {
            playTipContentTime = position;
            videoPlayslider.value = position;
            //console.debug("position changed",position)
        }
        onDurationChanged: {
            if(duration == 0){
                return;
            }

            videoPlayslider.maximumValue = duration;
            playerTotleTime = duration;
            //console.log("===duration===",duration);
        }

        onStatusChanged: {
            switch (status) {
            case MediaPlayer.NoMedia:
                //console.debug("status changed: NoMedia")
                break;
            case MediaPlayer.Loading:
                //console.debug("status changed: Loading")
                //console.debug("media duration:",duration)
                break;
            case MediaPlayer.Loaded:
                //mediaPlayer.play();
                console.debug("status changed: Loaded22",mediaPlayer.playbackState)
                break;
            case MediaPlayer.Buffering:
                //console.debug("status changed: Buffering")
                break;
            case MediaPlayer.Stalled:
                //console.debug("status changed: Stalled")
                break;
            case MediaPlayer.Buffered:
                //console.debug("status changed: Buffered")
                break;
            case MediaPlayer.EndOfMedia:
                isPlaying = false;
                seekTime = 0;
                //console.debug("status changed: EndOfMedia")
                break;
            case MediaPlayer.InvalidMedia:
                //console.debug("status changed: InvalidMedia")
                break;
            default:
                //console.debug("status changed: UnknownStatus")
                break;
            }
        }
        onPlaybackStateChanged: {
            switch (mediaPlayer.playbackState) {
            case MediaPlayer.PlayingState:
                //console.debug("the media is playing")
                mediaPlayer.seek(seekTime);
                break;
            case MediaPlayer.PausedState:
                console.debug("the media is paused")
                break;
            case MediaPlayer.StoppedState:
                //console.log("====this video media is stop===")
                break;
            default :
                console.debug("the media is default")
                break;
            }
        }
    }


    Item{//播放进度区域
        width: parent.width
        height: 60 * heightRate
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        //播放暂停操作
        MouseArea {
            id:startOrPushRectangle
            width: 18 * widthRate
            height: 18 * widthRate
            anchors.left: parent.left
            anchors.leftMargin: 10 * widthRate
            anchors.verticalCenter: parent.verticalCenter

            onClicked:{
                var  currentTime = parseInt(videoPlayslider.value /1000);
                if(isPlaying) {
                    mediaPlayer.pause();
                }else {
                    mediaPlayer.play();
                }
                isPlaying = !isPlaying;
            }

            Image {
                id: videoPlayOrPushImage
                anchors.fill: parent
                anchors.centerIn: parent
                source: isPlaying ? "qrc:/images/video_stopTwo.png" : "qrc:/images/video_startTwo.png"
            }
        }

        Item {
            width: parent.width - startOrPushRectangle.width
            height: parent.height
            anchors.left: startOrPushRectangle.right
            anchors.leftMargin: 10 * widthRate
            //当前播放的进度时间
            Item{
                id: bePlayedFileNowTimeRecatngle
                width: 40 * widthRate
                height: parent.height
                anchors.left: parent.left
                Text {
                    text: showCurrentPlayerTime
                    color: "#ffffff"
                    font.family: Cfg.FONT_FAMILY
                    font.pixelSize: 14 * heightRate
                    anchors.centerIn: parent
                }
            }

            Item{
                id:bePlayedFileSliderRectangle
                width: parent.width - 120 * widthRate - bePlayedFileNowTimeRecatngle.width
                height: parent.height
                anchors.left: bePlayedFileNowTimeRecatngle.right
                anchors.leftMargin: 10 * widthRate

                Rectangle{//slider颜色控制
                    width: parent.width
                    height: 2.5 * zoomWidthRate
                    color:"#ffffff";
                    anchors.centerIn: parent
                    radius: 4 * zoomWidthRate;

                    Rectangle {
                        id:hasPlayedvalue
                        width: videoPlayslider.width / videoPlayslider.maximumValue * videoPlayslider.value;
                        height: 2.5 * zoomWidthRate
                        color:"#ffccaa";
                        anchors.left: parent.left
                        radius: 4 * zoomWidthRate;
                    }
                }

                //拖动按钮
                Slider{
                    anchors.centerIn: parent
                    id: videoPlayslider
                    width: parent.width
                    height: 6 * heightRate
                    style:SliderStyle{
                        groove:Item {
                            implicitHeight:1.5 * zoomWidthRate
                            implicitWidth: videoPlayslider.width
                        }
                        handle: Image {
                            id: name
                            width: 10 * zoomWidthRate
                            height: 10 * zoomWidthRate
                            source: "qrc:/images/mbig.png"
                            anchors.centerIn: parent
                        }
                    }

                    onValueChanged: {
                        playTipContentTime = value;
                    }

                    onPressedChanged: {
                        var values = Math.floor(videoPlayslider.value / 1000);
                        if(!isPlaying){
                            isPlaying = true;
                        }
                        if(pressed == false){
                            mediaPlayer.play();
                            mediaPlayer.seek(videoPlayslider.value);
                        }else{
                            mediaPlayer.pause();
                        }
                    }
                }
            }

            Item{//当前播放的文件的总时间
                id: bePlayedFileAllTimeRecatngle
                width: 40 * widthRate
                height: parent.height
                anchors.left: bePlayedFileSliderRectangle.right
                anchors.leftMargin: 10 * widthRate

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

            //全屏按钮
            MouseArea {
                id: videoPlayerShowFullScreenOrNormalButton
                width: 10 * zoomWidthRate
                height: parent.height
                anchors.left: bePlayedFileAllTimeRecatngle.right
                anchors.leftMargin: 10 * widthRate

                cursorShape: Qt.PointingHandCursor
                Image {
                    id: screenImage
                    width: 18 * widthRate
                    height: 18 * widthRate
                    source: "qrc:/images/video_btn_fullscreenTwo.png"
                    anchors.centerIn: parent
                }

                onClicked: {
                    setVideoPalyerFullScreenORNormal();
                }
            }
        }
    }

    Component.onCompleted: {
        ymVideoPlayerManager.x = (parent.width - ymVideoPlayerManager.width) / 2;
        ymVideoPlayerManager.y = (parent.height - ymVideoPlayerManager.height) / 2;
    }

    function ymVideoPlayerManagerPlayFielByFileUrl(fileUrl,fileName,startPlayerTime) {
        mediaPlayer.stop();
        bePlayedFileNameText.text = fileName;
        filePath = fileUrl;
        isPlaying = true;                
        ymVideoPlayerManager.visible = true;        
        videoPlayslider.value = 0;
        playTipContentTime = 0;
        //console.log("==ymVideoPlayerManagerPlayFielByFileUrl==",fileUrl,startPlayerTime)
        if(parseInt(startPlayerTime)  > 0){
            seekTime = parseInt(startPlayerTime) * 1000;
        }
        mediaPlayer.play();
    }

    //设置全屏
    function setVideoPalyerFullScreenORNormal() {
        if(width == parent.width)
        {
            width = 200 * zoomWidthRate;
            height = 200 * 33 / 45 * zoomWidthRate;
            screenImage.source ="qrc:/images/video_btn_fullscreenTwo.png";
        }else {
            width = parent.width;
            height = parent.height;
            screenImage.source = "qrc:/images/video_smallscren@2x.png";
        }
        mediaPlayer.width = width;
        mediaPlayer.height = height - dragRegion.height - 28 * zoomWidthRate;
        ymVideoPlayerManager.x = (parent.width - ymVideoPlayerManager.width) / 2;
        ymVideoPlayerManager.y = (parent.height - ymVideoPlayerManager.height) / 2;
    }

    function closeVideo(){
        seekTime = 0;
        mediaPlayer.source = "";
        mediaPlayer.stop();
    }

    //将00:01:00转换为秒数
    function analysisTime(times){
        var timeList = times.split(":");
        var hours = Math.floor(timeList[0] * 60 * 60);//时
        var minutes = Math.floor(timeList[1] * 60);//分
        var seconds = Math.floor(timeList[2]);//秒
        return hours + minutes + seconds;
    }

    //将毫秒数转换为00:01:00
    function getPlayerTime(values){
        var time1 = Math.floor(values / 1000) ;
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
        return  time3s +":"+time2s + ":" +time1s;
    }
}

