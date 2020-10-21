import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtAV 1.7
import "./Configuuration.js" as Cfg

Item{
    id: ymVideoPlayerManager
    visible: false;

    property bool isPlaying: false;
    property  string bePlayedFileName: "";
    property  bool isFullScreen: false;
    property string filePath: "";
    property string currentFileName: "";
    property int playerTotleTime: 0;//播放总时间
    property string showTotleTime: "0";//显示总时间

    property int playTipContentTime: 0;//播放时间
    property string showCurrentPlayerTime: "00:00:00";//开始播放时间

    property int seekTime: 0;

    property bool isStratClass: isStartLesson;

    onIsStratClassChanged:
    {
        if(isStratClass)
        {
            if(isPlaying)
            {
                //mediaPlayer.seek(seekTime);
                //sigPlayerMedia("video","play",parseInt(seekTime / 1000),filePath)
            }
        }
    }

    //关闭视频信号
    signal sigClose(var vaType,var controlType,var times,var address);

    //暂停信号
    signal sigPlayerMedia(var vaType,var controlType,var times,var address)

    onPlayTipContentTimeChanged: {
        showCurrentPlayerTime =  getPlayerTime(playTipContentTime);
        if(parseInt(playTipContentTime / 1000) >= parseInt(playerTotleTime / 1000)){
            if(playTipContentTime != 0 && playerTotleTime !=0){
                seekTime = 0;
                videoPlayslider.value = 0;
                mediaPlayer.stop();
            }
            console.log("====stop====",seekTime)
        }
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
            //startTime.stop();
            mediaPlayer.stop();
            sigClose("video","stop","0",filePath);
        }
    }

    MouseArea  {
        anchors.fill: parent
        Rectangle{
            anchors.fill: parent
            color: "#3c3c3e"
            radius: 12 * widthRate
        }
    }

    //窗体移动
    MouseArea {
        id: dragRegion
        width: parent.width
        height:  50 * heightRate

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
            font.pixelSize:  14 * widthRate
            anchors.centerIn: parent
        }

        //关闭按钮
        MouseArea {
            width: 13 * widthRate
            height: 13 * widthRate
            anchors.right: parent.right
            anchors.rightMargin: 5 * widthRate
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
        height: parent.height - dragRegion.height - playerItem.height
        anchors.top: dragRegion.bottom
        source: filePath
        autoLoad: true

        onPlaying: {
            console.debug("playing")
        }
        onPaused: {
            //console.debug("paused")
        }
        onPositionChanged: {
            videoPlayslider.value = position;
            updatePlayerTime(parseInt(position / 1000));
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
                break;
            case MediaPlayer.Loaded:
                //startTime.restart();
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
                updatePlayerTime(0);
                console.debug("status changed: EndOfMedia")
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
                mediaPlayer.seek(seekTime);
                sigPlayerMedia("video","play",parseInt(seekTime / 1000),filePath)
                console.debug("the media is playing",seekTime)
                break;
            case MediaPlayer.PausedState:
                console.debug("the media is paused")
                break;
            case MediaPlayer.StoppedState:
                sigPlayerMedia("video","stop","0",filePath);
                //console.log("====this video media is stop===")
                break;
            default :
                //console.debug("the media is default")
                break;
            }
        }
    }


    Item{//播放进度区域
        id: playerItem
        width: parent.width
        height: 74 * heightRate
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        MouseArea {
            id:startOrPushRectangle
            width: 20 * widthRate
            height: 20 * widthRate
            anchors.left: parent.left
            anchors.leftMargin: 10 * widthRate
            anchors.verticalCenter: parent.verticalCenter
            //播放暂停操作
            onClicked:{
                var  currentTime = parseInt(videoPlayslider.value /1000);
                seekTime = videoPlayslider.value;
                if(isPlaying) {
                    sigPlayerMedia("video","pause",currentTime,filePath)
                    mediaPlayer.pause();
                }else {
                    sigPlayerMedia("video","play",currentTime,filePath);
                    mediaPlayer.play();
                }
                isPlaying = !isPlaying;
            }

            Image {
                id: videoPlayOrPushImage
                anchors.fill: parent
                source: isPlaying ? "qrc:/images/video_stopTwo.png" : "qrc:/images/video_startTwo.png"
            }
        }

        Item {
            width: parent.width - startOrPushRectangle.width
            height: parent.height
            anchors.left: startOrPushRectangle.right
            anchors.leftMargin: 5 * widthRate

            Item{//当前播放的进度时间
                id: bePlayedFileNowTimeRecatngle
                width: 60 * widthRate
                height: parent.height
                anchors.left: parent.left
                Text {
                    text: showCurrentPlayerTime
                    color: "#ffffff"
                    font.pixelSize: 14 * widthRate
                    anchors.centerIn: parent
                }
            }

            Item{
                id:bePlayedFileSliderRectangle
                width: parent.width - 120 * widthRate - 80 * widthRate
                height: parent.height
                anchors.left: bePlayedFileNowTimeRecatngle.right
                anchors.leftMargin:  10 * widthRate

                Rectangle{//slider颜色控制
                    width: parent.width
                    height: 6 * heightRate
                    color:"#ffffff";
                    anchors.centerIn: parent
                    radius: 4 * widthRate;

                    Rectangle {
                        id:hasPlayedvalue
                        width: videoPlayslider.width / videoPlayslider.maximumValue * videoPlayslider.value;
                        height: parent.height
                        color:"#ffccaa";
                        anchors.left: parent.left
                        radius: 4 * widthRate;
                    }
                }

                //拖动按钮
                Slider{
                    anchors.centerIn: parent
                    id: videoPlayslider
                    width: parent.width
                    height: 25 * heightRate
                    style:SliderStyle{
                        groove:Item {
                            implicitHeight: 15 * heightRate
                            implicitWidth: videoPlayslider.width
                        }
                        handle: Image {
                            id: name
                            width: 32 * heightRate
                            height: 32 * heightRate
                            source: "qrc:/images/mbig.png"
                            anchors.centerIn: parent
                        }
                    }

                    onValueChanged: {
                        playTipContentTime = value;
                    }

                    onPressedChanged: {
                        //var values = Math.floor(videoPlayslider.value / 1000);
                        if(!isPlaying){
                            isPlaying = true;
                        }
                        if(pressed == false){
                            seekTime = videoPlayslider.value;
                            mediaPlayer.play();
                            //console.log("=========video::values=====",seekTime);
                            //mediaPlayer.seek(videoPlayslider.value);

                            //updatePlayerTime(values);
                            //sigPlayerMedia("video","play",values,filePath)
                        }else{
                            mediaPlayer.pause();
                        }
                    }
                }
            }

            Item{//当前播放的文件的总时间
                id: bePlayedFileAllTimeRecatngle
                width: 60 * widthRate
                height: parent.height
                anchors.left: bePlayedFileSliderRectangle.right
                anchors.leftMargin: 10 * widthRate

                Text {
                    id: bePlayedFileAllimeText
                    text: showTotleTime
                    color: "#ffffff"
                    font.pixelSize: 14 * widthRate
                    anchors.left: parent.left
                    anchors.centerIn: parent
                }
            }

            MouseArea {//show fill screen
                id: videoPlayerShowFullScreenOrNormalButton
                width: 20 * widthRate
                height: 20 * widthRate
                anchors.left: bePlayedFileAllTimeRecatngle.right
                anchors.leftMargin: 10 * heightRate
                anchors.verticalCenter: parent.verticalCenter

                cursorShape: Qt.PointingHandCursor
                Image {
                    id: screenImage
                    width: parent.width
                    height: parent.width
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
        bePlayedFileNameText.text = fileName;
        filePath = fileUrl;
        ymVideoPlayerManager.visible = true;        
        videoPlayslider.value = 0;
        playTipContentTime = 0;
        currentFileName = fileName;

        if( parseInt(startPlayerTime) > 0){
            seekTime = parseInt(startPlayerTime) * 1000;
            playTipContentTime = parseInt(startPlayerTime) * 1000;
             console.log("==startPlayerTime==",startPlayerTime,seekTime,playTipContentTime);
        }

        setPlayerTimerBuffer(fileName);        
        isPlaying = true;
    }

    //设置当前播放时间
    function updatePlayerTime(currentTime){
        for(var i = 0; i < videoPlayerBuffer.length; i++){
            if(videoPlayerBuffer[i].fileName == currentFileName){
                videoPlayerBuffer[i].playerTimer = currentTime;
                break;
            }
        }
    }

    //播放时间缓存
    function setPlayerTimerBuffer(fileName){
        if(videoPlayerBuffer.length == 0){
            videoPlayerBuffer.push({
                                      "fileName": fileName,
                                      "playerTimer": 0,
                                  });
            mediaPlayer.play();
            return;
        }

        var isAdd = true;
        for(var i = 0; i < videoPlayerBuffer.length;i++){
            if(videoPlayerBuffer[i].fileName == fileName){
                var playerTime = videoPlayerBuffer[i].playerTimer;
                sigPlayerMedia("video","play",playerTime,filePath);
                seekTime = playerTime * 1000;
                mediaPlayer.play();
                isAdd = false;
                break;
            }
        }
        if(isAdd){
            videoPlayerBuffer.push({
                                      "fileName": fileName,
                                      "playerTimer": 0,
                                  });
            seekTime = 0;
            mediaPlayer.play();
        }
    }

    /*Timer{
        id: startTime
        interval: 2000
        repeat: false
        running: false
        onTriggered: {
            mediaPlayer.play();
            mediaPlayer.seek(seekTime);
            sigPlayerMedia("video","play",parseInt(seekTime / 1000),filePath)
        }
    }*/


    //设置全屏
    function setVideoPalyerFullScreenORNormal() {
        if(width == parent.width)
        {
            width = 600 * widthRates
            height = 430 * heightRates
            screenImage.source ="qrc:/images/video_btn_fullscreenTwo.png";
        }else {
            width = parent.width;
            height = parent.height;
            screenImage.source = "qrc:/images/video_smallscrenTwo.png";
        }
        mediaPlayer.width = width;
        mediaPlayer.height = height - dragRegion.height - playerItem.height;
        ymVideoPlayerManager.x = (parent.width - ymVideoPlayerManager.width) / 2;
        ymVideoPlayerManager.y = (parent.height - ymVideoPlayerManager.height) / 2;
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

