import QtQuick 2.7
import QtGraphicalEffects 1.0
import CurriculumData 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import VideoRender 1.0
import ExternalCallChanncel 1.0


/*
  * 视频工具栏
  */
Rectangle {
    id:videoToolBackground

    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    signal sigRequestVideoSpans();

    //边框阴影
    property int borderShapeLens: (rightWidthX - midWidth - midWidthX) > 10 ? 10 : (rightWidthX - midWidth - midWidthX)
    color: "#00000000"

    property int networkStatus: 3;//无线还是有线网状态
    property int networkValue: 3; //3 优 2良 1 差 0 无网络
    property int pingValue: 3;//当前ping值

    //总长度时间
    property int  totalLengthTime:0
    //当前时间的长度
    property int  currentLengthTime: 0
    property  int serverClassTime: 0;
    property var currentTimeInLocal: ;

    //当前时间的字符串
    property string  currentLengthTimeStr:""

    //是否加载数据
    property bool  loadDataStatus: false

    property int  loadDataStatusInt: 0

    //按键操作
    property bool  audioVideoHandl: false
    //计时器循环次数
    property int runTimes: 0;
    //关闭界面
    signal sigCloseWidget();
    //学生类型
    property  string  studentType: curriculumData.getCurrentUserType()

    property string timeProgressBarsTexts: "" ;
    //关闭本地摄像头
    signal sigOperationVideoOrAudio(string userId , string videos , string audios,var pingValue);

    //老师是否在线
    property bool teacherIsOnline: false;

    //切换通道失败信号
    signal sigCreatRoomFails();

    //切换通道成功
    signal sigCreatRoomSuccess();


    //设置留在教室
    function setStayInclassroom(){
        testTime.stop();
        audioVideoHandl = false;
    }
    //关闭视频
    function closeVideo(){
        externalCallChanncel.setStayInclassroom();
    }

    //获得音频的图片路径
    function getImagePath(paths){

        var volumeh =  parseInt(paths) ;
        if(volumeh >= 7) {
            return "qrc:/images/videocall7sd.png";
        }
        if(volumeh == 6) {
            return "qrc:/images/videocall6sd.png";
        }
        if(volumeh == 5) {
            return "qrc:/images/videocall5sd.png";
        }
        if(volumeh == 4) {
            return "qrc:/images/videocall4sd.png";
        }
        if(volumeh == 3) {
            return "qrc:/images/videocall3sd.png";
        }
        if(volumeh == 2) {
            return "qrc:/images/videocall2sd.png";
        }
        if(volumeh <= 1) {
            return "qrc:/images/videocall1sd.png";
        }

    }
    function classOverViewReset()
    {
        for(var j = 0 ; j < listModel.count ;j++){
            listModel.setProperty(j,"userOnline","0");
        }
    }
    //处理操作界面
    function handlPromptInterfaceHandl( inforces){

        //在线离线状态
        if(inforces == "51") {
            for(var j = 0 ; j < listModel.count ;j++){
                listModel.setProperty(j,"userOnline",curriculumData.justUserOnline( listModel.get(j).userId ));
            }
            teacherIsOnline = curriculumData.justTeacherOnline();
            //console.log("inforces ==  51515151511 ",inforces, teacherIsOnline);
            return;
        }
        //改变频道跟音频
        if(inforces == "61") {
            // console.log("inforces ==",inforces);

            externalCallChanncel.changeChanncel();
            for(var j = 0 ; j < listModel.count ;j++){
                listModel.setProperty(j,"isVideo",curriculumData.getIsVideo());
                listModel.setProperty(j,"supplier",curriculumData.getUserChanncel());
                if(listModel.get(j).userId  == "0") {
                    var audios = listModel.get(j).userAudio;
                    var videos = listModel.get(j).userVideo;
                    videoToolBackground.sigOperationVideoOrAudio( "0" ,  videos ,  audios , pingValue);
                }
            }
            return;
        }
        //改变权限
        if(inforces == "62") {
            for(var j = 0 ; j < listModel.count ;j++){
                listModel.setProperty(j,"userAuth",curriculumData.getUserIdBrushPermissions( listModel.get(j).userId ));
            }

            return;
        }

        //音视频状态
        if(inforces == "68") {
            for(var j = 0 ; j < listModel.count ;j++){
                listModel.setProperty(j,"userVideo",curriculumData.getUserCamcera( listModel.get(j).userId ));
                listModel.setProperty(j,"userAudio",curriculumData.getUserPhone( listModel.get(j).userId ));
            }

            return;
        }

    }

    //设置开始上课
    function setStartClassTimeData(times){
        //console.log("times ==",times);
        serverClassTime =  parseInt(times);
        var data = new Date();
        currentTimeInLocal = data.getTime() / 1000 ;
        currentLengthTime = parseInt(times) / 60 ;
        externalCallChanncel.initVideoChancel();
        for(var j = 0 ; j < listModel.count ;j++){
            listModel.setProperty(j,"isVideo",curriculumData.getIsVideo());
            listModel.setProperty(j,"supplier",curriculumData.getUserChanncel());
        }
        testTime.start();
        for(var j = 0 ; j < listModel.count ;j++){
            listModel.setProperty(j,"userVideo",curriculumData.getUserCamcera( listModel.get(j).userId ));
            listModel.setProperty(j,"userAudio",curriculumData.getUserPhone( listModel.get(j).userId ));
        }
        audioVideoHandl = true;

    }

    onCurrentLengthTimeChanged: {
        currentLengthTimeStr = "";
        var timelh = parseInt( currentLengthTime / 60 ) ;
        if(timelh > 9) {
            currentLengthTimeStr = timelh.toString() + ":";
        }else {
            currentLengthTimeStr = "0"+timelh.toString() + ":";
        }

        var timelm = Math.round( currentLengthTime % 60);
        if(timelm > 9) {
            currentLengthTimeStr += timelm.toString() ;
        }else {
            currentLengthTimeStr += "0"+timelm.toString() ;
        }

    }


    //边框阴影
    Rectangle{
        id:borderShapes
        width: borderShapeLens
        height: parent.height
        anchors.left: parent.left
        anchors.top: parent.top
        color: "#00000000"
        Image {
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            source: "qrc:/images/rectangletwothree.png"
        }
        //        LinearGradient{
        //            anchors.fill: parent;
        //            z:4

        //            gradient: Gradient{
        //                GradientStop{
        //                    position: 0.0;
        //                    color:  "#ffffffff";

        //                }

        //                GradientStop{
        //                    position: 1.0;
        //                    color: "#80000000";
        //                }
        //            }
        //            start:Qt.point(0, 0);
        //            end: Qt.point(parent.width, 0);
        //        }
    }
    //背景
    Rectangle{
        id:videoToolBackgroundColor
        width: parent.width - borderShapeLens
        height: parent.height
        anchors.left: borderShapes.right
        anchors.top: parent.top
        color: "#ffffff"
        z:2

        //图标
        //        Image {
        //            id: tagImage
        //            width: 13 * fullWidths / 1440
        //            height: 17  * fullHeights / 900
        //            anchors.left: parent.left
        //            anchors.top: parent.top
        //            anchors.leftMargin: 10 * fullWidths / 1440
        //            anchors.topMargin:  16  * fullHeights / 900
        //            source: "qrc:/images/icon_time.png"
        //        }
        //网络图标
        MouseArea{
            width: 32 * widthRates
            height: 24  * widthRates
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 3 * widthRates
            anchors.topMargin:  16  * heightRates
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onEntered:
            {
                networkView.updateNetworkStatus(networkValue,networkStatus,pingValue);
                console.log("=======networkValue======",networkValue,networkStatus)
                networkView.open();
            }

            Image{
                id: networkImg
                anchors.fill: parent
            }

        }

        Text {
            id: courseNamea
            //width: 56 * fullWidths / 1440
            height: 20  * fullHeights / 900
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 38 * fullWidths / 1440
            anchors.topMargin:  8  * fullHeights / 900
            font.pixelSize: 14 * fullHeights / 900
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"

        }

        Text {
            id: courseNameId
            width: 68 * fullWidths / 1440
            height: 20  * fullHeights / 900
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 38 * fullWidths / 1440
            anchors.topMargin:  30  * fullHeights / 900
            font.pixelSize: 14 * fullHeights / 900
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"

        }

        //课程类型
        Image {
            width: 33 * fullWidths / 1440
            height: 16  * fullHeights / 900
            anchors.left: courseNamea.right
            anchors.top: parent.top
            anchors.leftMargin: 5 * fullWidths / 1440
            anchors.topMargin:  10  * fullHeights / 900
            fillMode: Image.PreserveAspectFit
            source: (subjectId == 0) ? "qrc:/images/icon_yanshi@2x.png" : (lessonType == 10 ? "qrc:/images/icon_dingdan.png" : "qrc:/images/icon_shiting.jpg")
            //lessonType 0,1    试听课
            //lessonType 10     订单课
            //subjectId  0      演示课
        }

        //关闭按钮
        Rectangle{
            id:colseBtn
            width: 33 * heightRate
            height: 30 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 5 * widthRate
            color: "#00000000"
            Image {
                id: colseBtnImage
                anchors.left: parent.left
                anchors.top: parent.top
                width: parent.width
                height: parent.height
                source: closeMouseArea.containsMouse ? "qrc:/newStyleImg/pc_btn_close_sed@2x.png" : "qrc:/newStyleImg/pc_btn_close_sed copy@2x.png"
            }
            MouseArea{
                id:closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onPressed: {
                    videoToolBackground.focus = true;
                }
                onReleased: {
                    sigCloseWidget();
                }
            }
        }


        //时间进度
        ProgressBar{
            id:timeProgressBar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin:54 * heightRates
            height: 5  * heightRates
            width: parent.width
            maximumValue: totalLengthTime
            minimumValue: 0
            value: currentLengthTime >= totalLengthTime ? totalLengthTime : currentLengthTime
            style:  ProgressBarStyle {
                background: Rectangle {
                    color: "#dddddd"
                    implicitWidth: timeProgressBar.width
                    implicitHeight: timeProgressBar.height
                    Rectangle{
                        width: timeProgressBar.height / 2
                        height: timeProgressBar.height
                        color: "#ff9000"
                    }
                    //                    Text {
                    //                        anchors.right: parent.right
                    //                        anchors.top: parent.top
                    //                        width: 80 * fullWidths / 1440
                    //                        height: parent.height
                    //                        horizontalAlignment: Text.AlignHCenter
                    //                        verticalAlignment: Text.AlignVCenter
                    //                        anchors.rightMargin: 5 * fullWidths / 1440
                    //                        font.pixelSize: 9  * fullHeights / 900
                    //                        color: "#ffffff"
                    //                        wrapMode:Text.WordWrap
                    //                        font.family: "Microsoft YaHei"
                    //                        text: timeProgressBarsTexts
                    //                    }
                }
                progress: Rectangle {
                    id:timeProgressBars
                    color: "#ff9000"
                    radius: timeProgressBar.height / 2
                    //                    Text {
                    //                        id:timeProgressBarsText
                    //                        anchors.right: parent.right
                    //                        anchors.top: parent.top
                    //                        width: 25 * fullWidths / 1440
                    //                        height: parent.height
                    //                        horizontalAlignment: Text.AlignHCenter
                    //                        verticalAlignment: Text.AlignVCenter
                    //                        font.pixelSize: 9  * fullHeights / 900
                    //                        anchors.rightMargin: 2 * fullWidths / 1440
                    //                        visible: timeProgressBars.width > timeProgressBarsText.width ? true : false
                    //                        color: "#ffffff"
                    //                        wrapMode:Text.WordWrap
                    //                        font.family: "Microsoft YaHei"
                    //                        text: currentLengthTimeStr
                    //                    }
                }

            }
        }

        Rectangle{
            color: "#f6f6f6"
            width: parent.width
            height: 18 * heightRate
            anchors.top: timeProgressBar.bottom

            Text {
                height: parent.height
                anchors.left: parent.left
                anchors.leftMargin: 5 * heightRate
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 13  * heightRate
                color: "#ff5000"
                wrapMode:Text.WordWrap
                font.family: "Microsoft YaHei"
                text: currentLengthTimeStr
            }

            Text {
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                anchors.right: parent.right
                anchors.rightMargin: 5 * widthRate
                font.pixelSize: 13  * heightRate
                wrapMode:Text.WordWrap
                font.family: "Microsoft YaHei"
                text: timeProgressBarsTexts
                color: "#666666"
            }
        }



        ListView{
            id:videoListView
            anchors.top: timeProgressBar.bottom
            anchors.topMargin: 10 * heightRates
            anchors.left:parent.left
            width: videoToolBackgroundColor.width
            anchors.bottom: parent.bottom
            delegate: listViewDelegate
            model: listModel
            clip: true
        }

        ListModel{
            id:listModel

        }


        Component{
            id:listViewDelegate
            Rectangle {
                id:itemDelegate
                color: "#00000000"
                width: videoToolBackgroundColor.width  //200 * widthRates
                height: 255 * heightRates
                Rectangle{
                    id:itemDelegateBackGround
                    width: 180 * widthRates
                    height: 212 * heightRates
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: (videoToolBackgroundColor.width  - 180 * widthRates ) / 2
                    anchors.topMargin: 10 * widthRates
                    color: "#ffffff"
                    //   border.color: "black"
                    //   border.width: 1
                    //视频显示
                    VideoRender{
                        id:videoRender
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 180 * widthRates
                        height: 180 * heightRates
                        imageId:userId
                        z:1
                        visible: false
                        //visible:isVideo == "1" ?  true : false
                    }

                    Rectangle{
                        id: maskView
                        anchors.fill: parent
                        radius: 6 * heightRates
                        visible: false
                    }
                    Rectangle{
                        id: videoMaskView
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 180 * widthRates
                        height: 180 * heightRates
                        radius: 6 * heightRates
                        visible: false
                        Rectangle
                        {
                            width: parent.width
                            height: 10 * heightRates
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                        }
                    }
                    //视频展示遮罩层
                    OpacityMask{
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 180 * widthRates
                        height: 180 * heightRates
                        source: videoRender
                        maskSource: videoMaskView
                        visible:isVideo == "1" ?  true : false
                        z:6
                        cached: true
                    }

                    //背景椭圆遮罩层
                    OpacityMask{
                        anchors.fill: parent
                        source: videoRenderBackGround
                        maskSource: maskView
                        z:6
                        visible: isteacher == 1 ? ( userOnline == "1" ? ( isVideo == "1" ? (userVideo == "1" ?   false : true) : true ) : true) : teacherIsOnline ? ( userOnline == "1" ? ( isVideo == "1" ? (userVideo == "1" ?   false : true) : true ) : true) : true;

                    }

                    //底部信息显示
                    Rectangle{
                        id:videoRenderBorder
                        anchors.left: parent.left
                        anchors.top: videoRender.bottom
                        width: parent.width
                        height: 55 * heightRates
                        radius: 6 * heightRates
                        Rectangle
                        {
                            width: parent.width
                            height: 10 * heightRates
                            anchors.left: parent.left
                            anchors.top: parent.top
                            color: "#F6F6F6"
                        }

                        z:7
                        color: "#F6F6F6"

                        Rectangle {
                            id: videoRenderBorderImage
                            clip: true
                            color: "#00000000"
                            anchors.left: parent.left
                            anchors.top: parent.top
                            width: 40 * heightRates
                            height: 40 * heightRates
                            anchors.leftMargin: 7 * widthRates
                            anchors.topMargin:  7 * heightRates
                            radius: 9 * ratesRates
                            Image {
                                id:userPhotoView
                                anchors.left: parent.left
                                anchors.top: parent.top
                                width: parent.width
                                height: parent.height
                                source: imagePath == "" ? "qrc:/images/index_profile_defult@2x.png" : imagePath
                                visible: false

                                onStatusChanged: {
                                    if(status == Image.Error){
                                        imagePath = "qrc:/images/index_profile_defult@2x.png"
                                    }
                                }
                            }

                            Rectangle{
                                id: photoView
                                width: 40 * heightRates
                                height: 40 * heightRates
                                radius: 6 * heightRates
                                visible: false
                            }
                            OpacityMask{
                                anchors.left: parent.left
                                anchors.top: parent.top
                                width: parent.width
                                height: parent.height
                                source: userPhotoView
                                maskSource: photoView
                                cached: true
                                z:2
                            }

                            Image {
                                width: 10 * ratesRates
                                height: 10 * ratesRates
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                // anchors.bottomMargin: 3 * ratesRates
                                //   anchors.rightMargin:  3 * ratesRates
                                //visible: isteacher == "1"? false :  true //( userId == "0"? (userOnline == "1" ? true : false) : false )
                                source: userOnline == "1"? "qrc:/images/dot_zaixian.png":"qrc:/images/dot_lixian.png"
                                z:3
                            }
                        }
                        Text {
                            anchors.left: videoRenderBorderImage.right
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 22 * ratesRates
                            anchors.leftMargin: 3 * widthRates
                            color:"#ABABAB";
                            wrapMode:Text.WordWrap
                            font.family: "Microsoft YaHei"
                            text: userName
                        }
                        Rectangle{
                            anchors.right: parent.right
                            anchors.top: parent.top
                            width: 84 * heightRates * 0.6
                            height: 40 * heightRates * 0.6
                            anchors.rightMargin: 5 * widthRates
                            anchors.topMargin: 16 * heightRates
                            color: "#00000000"
                            visible:  isteacher != "1" ?  ( userOnline == "1" ? true  : false ) : false

                            Image {
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit
                                source: isteacher != "1" ? (userAuth == "1"? "qrc:/newStyleImg/icon_shouquan@2x.png":"qrc:/newStyleImg/icon_weishouquan@2x.png" ) :(userOnline == "1"? "qrc:/images/icon_zaixian.png":"qrc:/images/icon_lixian.png" )
                            }

                        }

                    }

                    //本地音频控制按钮
                    Rectangle{
                        id:audioBtn
                        anchors.left: videoRender.left
                        anchors.bottom: videoRender.bottom
                        anchors.leftMargin: 115 * widthRates
                        anchors.bottomMargin: 5 * heightRates
                        width: 30 * ratesRates
                        height: 30 * ratesRates
                        color: "#00000000"
                        //  radius: 15 * ratesRates
                        visible:  userId == "0"?  true : false
                        z:15
                        Image {
                            id: audioBtnImage
                            anchors.fill: parent
                            source: audioVideoHandl ? (   userAudio == "1" ? "qrc:/newStyleImg/pcsd_tool_macrio_on@2x.png" : "qrc:/newStyleImg/pcsd_tool_macrio_off@2x.png" ) : "qrc:/newStyleImg/pcsd_tool_macrio_disable@2x.png"
                        }
                        MouseArea{
                            anchors.fill: parent
                            enabled: audioVideoHandl
                            onClicked: {
                                videoToolBackground.focus = true;
                                for(var j = 0 ; j < listModel.count ;j++){
                                    if(listModel.get(j).userId  == "0") {
                                        var audios = listModel.get(j).userAudio;
                                        if(audios == "1") {
                                            listModel.setProperty(j,"userAudio","0");
                                            videoToolBackground.sigOperationVideoOrAudio( userId ,  userVideo ,  "0" , pingValue);
                                            externalCallChanncel.closeAudio("0");

                                        }else {
                                            listModel.setProperty(j,"userAudio","1");
                                            videoToolBackground.sigOperationVideoOrAudio( userId ,  userVideo ,  "1" , pingValue);
                                            externalCallChanncel.closeAudio("1");

                                        }

                                    }
                                }

                            }
                        }

                    }

                    //本地视频控制按钮
                    Rectangle{
                        id:videoBtn
                        anchors.left: audioBtn.right
                        anchors.bottom: videoRender.bottom
                        anchors.leftMargin: 5 * widthRates
                        anchors.bottomMargin: 5 * heightRates
                        width: 30 * ratesRates
                        height: 30 * ratesRates
                        color: "#00000000"
                        // radius: 15 * ratesRates
                        visible:  userId == "0"?  (isVideo == "1" ? true : false ) : false
                        z:15
                        Image {
                            id: videoBtnImage
                            anchors.fill: parent
                            source:audioVideoHandl ? (  userVideo == "1" ? "qrc:/newStyleImg/pcsd_tool_video_on@2x.png": "qrc:/newStyleImg/pcsd_tool_video_off@2x.png" ) : "qrc:/newStyleImg/pcsd_tool_video_disable@2x.png"

                        }
                        MouseArea{
                            anchors.fill: parent
                            enabled: audioVideoHandl
                            onClicked: {
                                videoToolBackground.focus = true;
                                for(var j = 0 ; j < listModel.count ;j++){
                                    if(listModel.get(j).userId  == "0") {
                                        var videos = listModel.get(j).userVideo;
                                        if(videos == "1") {
                                            listModel.setProperty(j,"userVideo","0");
                                            videoToolBackground.sigOperationVideoOrAudio( userId ,  "0" , userAudio , pingValue);
                                            externalCallChanncel.closeVideo("0");
                                        }else {
                                            listModel.setProperty(j,"userVideo","1");
                                            videoToolBackground.sigOperationVideoOrAudio( userId ,  "1" , userAudio , pingValue);
                                            externalCallChanncel.closeVideo("1");
                                        }

                                    }
                                }


                            }
                        }
                    }

                    //操作背景
                    Rectangle{
                        id:videoRenderBackGround
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 180 * widthRates
                        height: 180 * heightRates
                        z:5
                        color: "#ffffff"


                        visible: false //isteacher == 1 ? ( userOnline == "1" ? ( isVideo == "1" ? (userVideo == "1" ?   false : true) : true ) : true) : teacherIsOnline ? ( userOnline == "1" ? ( isVideo == "1" ? (userVideo == "1" ?   false : true) : true ) : true) : true;
                        /*

                        //visible: 手动格式化一下后, 如下:
                        visible: isteacher == 1 ?
                                 (userOnline == "1" ? (isVideo == "1" ? (userVideo == "1" ? false : true) : true ) : true)
                                 :

                                 teacherIsOnline ?
                                 (userOnline == "1" ? (isVideo == "1" ? (userVideo == "1" ? false : true) : true ) : true)
                                 : true;
*/
                        Image {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            width: parent.width
                            height: parent.height
                            source:userOnline == "1" ? "qrc:/images/auvodio_sd_bg_onlinetwox.png" : "qrc:/images/auvodio_sd_bg_offlinetwox.png"
                        }

                        Image {
                            id: volumeImage
                            width: 40 *  widthRates
                            height: 40 * heightRates
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: parent.width / 2 - 20 *  widthRates
                            anchors.topMargin: parent.height / 2 - 20 *  heightRates
                            visible: userId == "0" ? false : ( userOnline == "1" ? (isVideo == "1" ?  false : (supplier == "1" ? true : false)) :false )
                            z:2
                            source: getImagePath(volumes)
                        }

                        //点击窗口图片的时候, 打印当前的属性状态, 方便调试
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                console.log("**********videoRenderBackGround*************",userId ,isteacher, userOnline, isVideo, userVideo, teacherIsOnline);
                            }
                        }

                    }

                    //通话状态显示
                    Item{
                        z: 15
                        height:  40 * heightRates
                        width: parent.width
                        visible: (userOnline =="1" && audioVideoHandl && index == 0)
                        Rectangle
                        {
                            anchors.fill: parent
                            color: "#505050"
                            opacity: 0.225
                            radius: 6 * heightRates
                        }

                        Row{
                            z: 6
                            anchors.fill: parent
                            anchors.left: parent.left
                            anchors.leftMargin: 5 * heightRates
                            anchors.verticalCenter: parent.verticalCenter
                            spacing:  6 * widthRates

                            Image{
                                z: 7
                                asynchronous: true
                                width: 20 * widthRates
                                height: 20 * widthRates
                                anchors.verticalCenter: parent.verticalCenter
                                source: isVideo == "0" ? "qrc:/newStyleImg/pc_dot_green@2x.png" : "qrc:/newStyleImg/pc_dot_orage@2x.png"
                            }

                            Text{
                                text: userOnline =="1" && audioVideoHandl ? (isVideo == "0" ? "正在音频对话" : "正在视频对话")  : (userId =="0"? "在线中..." : (userOnline =="1" ? "在线中" :"离线中"))
                                height: parent.height * 0.5
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 14 * widthRates
                                font.family: "Microsoft YaHei"
                                color: "#FFFFFF"
                            }
                        }
                    }
                }

            }
        }

    }

    //======================================= >>>
    //增加以下方法, 是为了让其他的qml文件中, 不再使用对象: curriculumData, curriculumData对象, 保持只有唯一,
    //为了信号: onSigListAllUserId, 只在当前的qml文件中, 才会收到
    function isAutoDisconnectServer(){
        return curriculumData.isAutoDisconnectServer()
    }

    function isUserPagePermissions(){
        return curriculumData.isUserPagePermissions()
    }

    function getStartClassTimelen(){
        return curriculumData.getStartClassTimelen()
    }

    function getUserBrushPermissions(){
        return curriculumData.getUserBrushPermissions()
    }

    function justTeacherOnline(){
        return curriculumData.justTeacherOnline()
    }

    function getCurrentUserType(){
        return curriculumData.getCurrentUserType();
    }

    function isTeacher(usrid){
        return curriculumData.isTeacher(usrid);
    }

    function getUserName(usrid){
        return curriculumData.getUserName(usrid);
    }

    function getIsVideo(){
        return curriculumData.getIsVideo();
    }

    function getUserType(ids){
        return curriculumData.getUserType(ids);
    }

    function getAuthType(){
        return curriculumData.getAuthType();
    }

    function getListAllUserId(){
        return curriculumData.getListAllUserId()
    }
    // <<<=======================================

    CurriculumData{
        id:curriculumData
        onSigListAllUserId:{
            listModel.clear();

            //            console.log("list[i] ==AAA", JSON.stringify(list))
            for(var j = 0; j < list.length ; j++) {
                /*
                console.log("list[i] ==BBB", j,
                            list[j],
                            curriculumData.getUserName( list[j] ),
                            curriculumData.justUserOnline( list[j] ),
                            curriculumData.getUserIdBrushPermissions( list[j] ),
                            curriculumData.getIsVideo(),
                            curriculumData.getUserPhone( list[j] ),
                            curriculumData.getUserCamcera( list[j] ),
                            curriculumData.getUserUrl( list[j] ),
                            curriculumData.isTeacher(list[j]),
                            curriculumData.getUserChanncel()
                            )
*/
                listModel.append( {   "userId":list[j]
                                     , "userName":curriculumData.getUserName( list[j] )
                                     , "userOnline":curriculumData.justUserOnline( list[j] )
                                     , "userAuth":curriculumData.getUserIdBrushPermissions( list[j] )
                                     , "isVideo":curriculumData.getIsVideo()
                                     , "userAudio":curriculumData.getUserPhone( list[j] )
                                     , "userVideo":curriculumData.getUserCamcera( list[j] )
                                     , "imagePath":curriculumData.getUserUrl( list[j] )
                                     , "isteacher":curriculumData.isTeacher(list[j])
                                     , "supplier":curriculumData.getUserChanncel()
                                     , "volumes":"0"
                                 }
                                 );
            }
        }
    }
    //操作视频
    ExternalCallChanncel{
        id:externalCallChanncel

        onSigAudioVolumeIndication:{

            var uids = uid.toString();
            var totalVolumes = totalVolume.toString();

            for(var j = 0 ; j < listModel.count ;j++){
                if(listModel.get(j).userId == uids) {
                    listModel.setProperty(j,"volumes",totalVolumes );
                }

            }

        }

        onSigRequestVideoSpan: {
            sigRequestVideoSpans();
        }

        onCreateRoomFail:
        {
            //popupWidget.setPopupWidget("createRoomFail");
            sigCreatRoomFails();
        }

        onCreateRoomSucess:
        {
            sigCreatRoomSuccess();

            var userAudio = curriculumData.getUserPhone( "0" );
            var userVideo = curriculumData.getUserCamcera( "0" );
            //更改回原来音视频的状态
            if(userAudio == "1")
            {
                externalCallChanncel.closeAudio("1");
            }else
            {
                externalCallChanncel.closeAudio("0");
            }

            if(userVideo == "1")
            {
                externalCallChanncel.closeVideo("1")
            }else
            {
                externalCallChanncel.closeVideo("0")
            }
        }
    }

    MouseArea{
        anchors.fill: parent
        z:1
        onClicked: {
            videoToolBackground.focus = true;
        }
    }

    Timer{
        id:testTime
        running: false
        interval: 10000;
        repeat: true
        onTriggered: {
            var tempdate = new Date();
            currentLengthTime=   (tempdate.getTime() / 1000 - currentTimeInLocal + serverClassTime ) / 60

            //          currentLengthTime++;
            //            if(currentLengthTime > totalLengthTime) {
            //                currentLengthTime = 0;
            //            }
            // console.log("currentLengthTime ==",currentLengthTime);
            //  console.log("totalLengthTime ==",totalLengthTime);
            ++runTimes;
            if(6 == runTimes)
            {
                for(var j = 0 ; j < listModel.count ;j++){
                    if(listModel.get(j).userId  == "0") {
                        var audios = listModel.get(j).userAudio;
                        var videos = listModel.get(j).userVideo;
                        videoToolBackground.sigOperationVideoOrAudio( "0" ,  videos ,  audios , pingValue);
                    }
                }
                runTimes = 0;
            }
        }
    }

    Component.onCompleted: {
        if(loadDataStatus) {
            return;
        }

        loadDataStatus = true;
        curriculumData.getListAllUserId();
        totalLengthTime = curriculumData.courseTimeTotalLength;
        courseNameId.text = curriculumData.curriculumId;
        courseNamea.text = curriculumData.curriculumName;
        timeProgressBarsTexts = curriculumData.startToEndTime;
        lessonType = curriculumData.lessonType;
        applicationType = curriculumData.applicationType;
        subjectId = curriculumData.subjectId;
        console.log("====updateNetworkStatus====", lessonType, applicationType, subjectId)
    }

    //修改网络图标
    function updateNetworkStatus(status,netValue){
        console.log("====updateNetworkStatus====",status,netValue)
        networkValue = status;
        pingValue = netValue == undefined ? 0 : netValue;
        if(networkStatus == 3){
            if(status == 3){
                networkImg.source = "qrc:/networkImage/cr_goodwifi.png";
                return;
            }
            if(status == 2){
                networkImg.source =  "qrc:/networkImage/cr_lowwifi.png";
                return;
            }
            if(status == 1){
                networkImg.source =  "qrc:/networkImage/badwifi.png";
                return;
            }
            if(status == 0){
                networkImg.source =  "qrc:/networkImage/cr_nowifi.png";
                return;
            }
        }else{
            if(status == 3){
                networkImg.source =  "qrc:/networkImage/cr_goodsignal.png";
                return;
            }
            if(status == 2){
                networkImg.source =  "qrc:/networkImage/cr_lowsignal.png";
                return;
            }
            if(status == 1){
                networkImg.source =  "qrc:/networkImage/cr_badsignal.png";
                return;
            }
            if(status == 0){
                networkImg.source =  "qrc:/networkImage/cr_nosignal.png";
                return;
            }
        }
    }

    function updateVideoSpan(videoSpan)
    {
        externalCallChanncel.enterChannelV2(videoSpan);
    }

}

