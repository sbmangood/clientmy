import QtQuick 2.6
import QtQuick.Window 2.2
import ToolBar 1.0
import YMLessonManager 1.0
import CurriculumData 1.0
import Trophy 1.0;
import Answer 1.0;

Window {
    id: mainview
    visible: true
    width: Screen.width
    height: Screen.height
    flags: Qt.Window | Qt.FramelessWindowHint
    title: qsTr("ClassRoom")

    //屏幕比例
    property double widthRate: Screen.width * 0.8 / 966.0;
    property double heightRate:widthRate / 1.5337;

    property int coursewareType: 1;//默认老课件
    property int h5CoursewarePageTotal: 0;//H5课件总页数
    property int playNumber: 0;

    //边框阴影
    property int borderShapeLen : (rightWidthX - midWidth - midWidthX) > 10 ? 10 : (rightWidthX - midWidth - midWidthX)

    property double currentImageHeight: 0.0;
    property double curOffsetY: 0.0;//当前滚动条的坐标,不能与CoursewareView.qml中的变量同名，故更名为curOffsetY

    property int loadImgWidth: 0;//加载图片宽度
    property int loadImgHeight: 0;//加载图片高度
    property bool isClipImage: false;//是否时截图课件
    property bool isUploadImage: false;//是否是传的图片
    property bool isLongImage: false;//是否是长图

    Rectangle {
        anchors.fill: parent
        // 背景
        Image{
            anchors.fill: parent
            fillMode: Image.Tile
            source: "qrc:/images/backgrundImg.png"
        }
        // 视频区域
        AudioVideoView {
            id: audiovideoview
            z: 1
            width: parent.width
            height: parent.height - whiteBoard.height - 10 * heightRate
            anchors.top: parent.top
            anchors.bottomMargin: 5 * heightRate

            // 设置用户授权
            onSigSetUserAuths: {
                console.log("====onSigSetUserAuths=",userId, up, trail, audio, video);
                toolbar.setUserAuth(userId, up, trail, audio, video);
            }

            // 全体禁言
            onSigUpdateAllMute: {
                toolbar.allMute(muteStatus);
            }
        }

        Rectangle {
            id: background
            width: midWidth
            height: midHeight
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter

            Trophy {
                id:trophy
                onSigDrawTrophy: {
                    console.log("1111112222222222");
                }
            }

            // 白板区域
            Answer {
                id:answer

                onSigDrawAnswer: {

                    console.log("---------111", itemId);
                }
            }

            // 白板区域
            WhiteBoard0 {
                id:whiteBoard
                z: 11
                clip: true
                anchors.fill: parent
                smooth: true
                visible: true
                enabled: false
            }
            // 课件区域
            CoursewareView {
                id: ymcourseware
                z: 10
                anchors.fill: parent
                visible: true
                onSigChangeCurrentPages: {
                    bottomToolbars.currentPage = pages;
                }
                onSigChangeTotalPages: {
                    bottomToolbars.totalPage = pages;
                }
                onSigGetOffsetImage: {
                    curOffsetY = currentCourseOffsetY;
                    toolbar.getOffsetImage(url, curOffsetY);
                }
                onSigSendH5PlayAnimation: {
                    toolbar.sendH5PlayAnimation(animationStepIndex);
                }
                Connections {
                    target: getOffSetImage
                    onReShowOffsetImage:
                    {
                        if(coursewareType== 3){
                            return;
                        }

                        var imgSource = "image://offsetImage/" + Math.random();
                        ymcourseware.setCoursewareSource("",coursewareType,imgSource,width,height,curriculumData.getCurrentToken());
                        loadImgHeight = height;
                        loadImgWidth = width;
                        isUploadImage = false;
                        isClipImage = false;
                        isLongImage = true;

                        console.log("===bmgImages.source===",coursewareType,imgSource,width,height,currentImageHeight);
                        scrollbar.visible = false;
                        if(currentImageHeight > background.height){
                            scrollbar.visible = true;
                        }
                    }
                }
            }
            //滚动条
            Item {
                id: scrollbar
                anchors.right: parent.right
                anchors.top: parent.top
                width: 8 * heightRate
                height: background.height
                visible: false
                z: 16

                // 按钮
                Rectangle {
                    id: button
                    width: parent.width
                    height: {
                        var mutilValue = currentImageHeight / background.height
                        if(mutilValue > 1){
                            return parent.height / mutilValue;
                        }
                        else{
                            return parent.height * mutilValue;
                        }
                    }
                    color: "#dddddd"
                    radius: 6 * heightRate

                    // 鼠标区域
                    MouseArea {
                        id: mouseArea
                        anchors.fill: button
                        drag.target: button
                        drag.axis: Drag.YAxis
                        drag.minimumY: 0
                        drag.maximumY: scrollbar.height - button.height
                        cursorShape: Qt.PointingHandCursor

                        onReleased: {
                            //currentOffsetY = 0;
                            var contentY =  (button.y / scrollbar.height * currentImageHeight / background.height);
                            toolbar.updataScrollMap(contentY);
                            whiteBoard.getOffSetImage(0.0,contentY,1.0);
                        }
                    }
                }
            }
        }

        // 数据类
        CurriculumData {
            id:curriculumData
            onSigListAllUserId: {
                var dataObject = curriculumData.getUserInfo(list[0]);
                var userId = list[0];
                audiovideoview.addSelfBaseInfo(userId, dataObject);
            }
        }

        //底部工具栏
        BottomToolbars {
            id: bottomToolbars
            width: midWidth
            z: 38
            visible: true
            height: 35  * widthRate
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: (parent.width + (leftMidWidth + 12.0 * leftMidWidth / 66) - (rightWidth + borderShapeLen) -width) * 0.5
            anchors.bottomMargin:  5  * heightRate
            //跳转页面
            onSigJumpPage: {
                //console.log("=====onSigJumpPage====",pages)
                toolbar.goCourseWarePage(1, pages, bottomToolbars.totalPage);
                ymcourseware.coursewareOperation(3, 4, pages,0);
            }
            // 上一页
            onSigPrePage: {
                //console.log("======onSigPrePage====");
                ymcourseware.coursewareOperation(3, 0, 0,0);
            }
            // 下一页
            onSigNext: {
                //console.log("======onSigNextPage====");
                ymcourseware.coursewareOperation(3,1,1,0);;
            }
            //增加页
            onSigAddPage: {
                toolbar.goCourseWarePage(2,bottomToolbars.currentPage,bottomToolbars.totalPage + 1);
                ymcourseware.coursewareOperation(coursewareType,2,bottomToolbars.currentPage,0);
            }
            //删除页
            onSigRemoverPage: {
                toolbar.goCourseWarePage(3,bottomToolbars.currentPage - 1,bottomToolbars.totalPage - 1);
            }
            //翻页首末页提醒
            onSigTipPage:  {
                if(message == "lastPage"){

                }
                if(message == "onePage"){

                }
            }
        }

        // 右侧工具栏
        RightToolbarsView {
            id: toolbarsView
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            ToolBar {
                id: toolbar
                onSigPromptInterface: {
                    if(interfaces == "opencarm"){
                        toolbar.initVideoChancel();
                        audiovideoview.setStartClassTimeData(100000);
                    }
                }
                onSigJoinroom: {
                    audiovideoview.addUserInfo(userId);
                }

                onSigCurrentImageHeight: {
                    currentImageHeight = imageHeight;
                    scrollbar.visible = false;
                    if(currentImageHeight > background.height){
                        scrollbar.visible = true;
                    }
                    if(currentImageHeight == 0){
                        return;
                    }
                    button.y = (scrollbar.height * curOffsetY * background.height / currentImageHeight);
                    whiteBoard.getOffSetImage(0,curOffsetY,1.0);
                }
            }
            onSigSendFunctionKey: {
                switch(keys)
                {
                case 0 :// 鼠标样式
                    toolbar.selectShape(0);
                    whiteBoard.enabled = false;
                    break;
                case 1: // 画笔
                    if( brushWidget.focus)
                        brushWidget.focus = false;
                    else
                        brushWidget.focus = true;
                    toolbar.selectShape(1);
                    whiteBoard.enabled = true;
                    break;
                case 4:  // 橡皮擦
                    if( eraserWidget.focus)
                        eraserWidget.focus = false;
                    else
                        eraserWidget.focus = true;
                    toolbar.selectShape(2);
                    whiteBoard.enabled = true;
                    break;
                case 5: // 教鞭
                    toolbar.selectShape(4);
                    whiteBoard.enabled = true;
                    break;
                case 6:   // 云盘(课件)
                    diskMainView.visible = true;
                    whiteBoard.enabled = true;
                    break;
                default:
                    break;
                }
            }
        }

        //画笔操作
        BrushWidget{
            id:brushWidget
            anchors.right: parent.right
            anchors.rightMargin: 50 * heightRate
            anchors.top:  parent.top
            anchors.topMargin: (parent.height - toolbarsView.height) * 0.5 + 10 * heightRate
            width: 200 * heightRate
            height: 220  * heightRate
            visible: false
            focus: false
            z:16
            onFocusChanged: {
                if(brushWidget.focus) {
                    brushWidget.visible = true;
                }else {
                    brushWidget.visible = false;
                }
            }
            onSendPenColor: {
                var obje = {"name" : 123};
                answer.sendAnswer("333", obje,"b", 20);
//                toobarWidget.handlBrushImageColor(penColors);
                //setBrushImage();
            }
            onSendPenWidth: {
                toolbar.setPaintSize(penWidths);
                //setBrushImage();

            }

        }

        //橡皮
        EraserWidget{
            id:eraserWidget
            anchors.right: parent.right
            anchors.rightMargin: 50 * heightRate
            anchors.top:  parent.top
            anchors.topMargin: (parent.height - toolbarsView.height) * 0.5 + 60 * heightRate
            width: 200 * heightRate
            height: 212  * heightRate
            z: 10
            visible: false
            focus: false
            onFocusChanged: {
                if(eraserWidget.focus) {
                    eraserWidget.visible = true;
                }else {
                    eraserWidget.visible = false;
                }
            }

            onSigSendEraserInfor: {
                toolbar.selectShape(types);
                toolbar.setErasersSize(eraserWidget.eraserSize);
            }

            onSigClearsCreeon: {
                if(types == 1){
                    toolbar.clearTrails();
                }else{
                    toolbar.undoTrail();
                }
            }
        }

        // 云盘
        YMCloudDiskMainView {
            id: diskMainView
            anchors.right: parent.right
            anchors.rightMargin: 42 * heightRate
            anchors.top: parent.top
            anchors.topMargin: (parent.height - toolbarsView.height) * 0.5 - 16 * heightRate
            visible: false
            z:16
            //当前被选择的 课件ImgList 和fileId  var ImgUrlList, var fileId
            onSigCurrentBeOpenedCoursewareUrl:
            {
                //console.log("=============onSigCurrentBeOpenedCoursewareUrl coursewareType=",coursewareType)
                if(coursewareType == 3){
                    ymcourseware.insertCourseWare(imgUrlList, fileId, h5Url, coursewareType,curriculumData.getCurrentToken());
                    console.log("========onSigCurrentBeOpenedCoursewareUrl========",h5Url,curriculumData.getCurrentToken());
                    //scrollbar.visible = false;
                }
                toolbar.insertCourseWare(imgUrlList,fileId,h5Url,coursewareType);

            }
            //当前被选择的音频的Url 及id   audioUrl  fileI
            onSigCurrentBePlayedAudioUrl:
            {

            }
            //当前被选择的视频的Url 及id  videoUrl  fileId
            onSigCurrentBePlayedVideoUrl:
            {

            }
        }

        YMLessonManager {
            id: miniMgr
            onSigCoursewareTotalPage: {
                h5CoursewarePageTotal = pageTotal;
            }
        }
    }

    // 最小化按钮
    Rectangle {
        id: minibtn
        z: 3
        anchors.topMargin: 10 * heightRate
        anchors.rightMargin: 10 * widthRate
        anchors.top: parent.top
        anchors.right: exitbtn.left
        width: 60 * widthRate
        height: 20 * heightRate
        border.color: "#aaaaaa"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                mainview.visibility = Window.Minimized;
            }
        }
        Text {
            anchors.fill: parent
            text: qsTr("最小化")
            color: "blue"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // 退出按钮
    Rectangle {
        id: exitbtn
        z: 3
        anchors.topMargin: 10 * heightRate
        anchors.rightMargin: 10 * widthRate
        anchors.top: parent.top
        anchors.right: parent.right
        width: 60 * widthRate
        height: 20 * heightRate
        border.color: "#aaaaaa"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                toolbar.uninit();
                toolbar.uploadLog();
                Qt.quit();
            }
        }
        Text {
            anchors.fill: parent
            text: qsTr("退出")
            color: "red"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Component.onCompleted: {
        curriculumData.getListAllUserId();
    }
}
