import QtQuick 2.0
import "./Configuration.js" as Cfg

Item {
    property int currentUserType: 0;    //当前用户角色 0=老师，1=学生，2=助教
    property int mywidth:  300          // 宽度
    property int myheight: 200          // 高度
    property bool isEnableScale: true   // 是否可缩放
    property bool isEnableDrag: true    // 是否可拖拽

    property var h5coursewareId: "";// 当前课件Id
    property int currentPage: 0;

    property string coursewareName: ""

    property double widthRate: fullWidths / 1440.0
    property double heightRate: fullHeights / 900.0

    signal sigCMVUserAuth(var userRole);
    signal sigCMVGetOffsetImage(var url, double currentCourseOffsetY);
    signal sigCMVWhiteboardGetOffSetImage(double offsetX, double offsetY, double zoomRate);
    signal sigCMVCoursewareOffsetY(double offsetY);
    signal sigCMVSendH5PlayAnimation(var animationStepIndex);
    signal sigCMVSendH5ThumbnailPage(var pageIndex, var totalPage);
    signal sigCMVLoadsCoursewareSuccess(var currentUrl);// 课件加载成功信号
    signal sigCMVIsCouserware();// 删除的是否为课件
    signal sigCMVJumpPages(var pages, var totalPage);
    signal sigCMVRemoverPages(var currentPage, var totalPage);
    signal sigCMVAddPages(var currentPage, var totalPage);
    signal sigCMVTipPages(var message);
    signal sigCMVCurrentCoursewareId(var coursewareId);// 当前课件Id
    signal sigCMVStuCurrentPage();

    signal sigCMVChangeWindow(var courseId, var type, var recWidth, var recHeight, var recX, var recY);   // 改变窗口：操作类型"type":"move"-移动,"min"-最小化,"close"-关闭,"max"-最大化"
    signal sigCMVWindowUpdates(var windowUpdateInfos);// 窗口信息更新

    signal sigCoursewareWindowInfo(var recWidth, var recHeight, var recX, var recY);

    signal sigH5GetScrolls(var scrollValue);// H5页面滚动百分比

    signal sigSelecteWhiteBoard(var widths,var heights,var leftMaginValue,var topMaginValue);//选中白板
    signal sigCMVVisualizeH5Courseware();// 设置课件区域课件


    id: coursewareview
    width: mywidth
    height: myheight

    property int detectedSize: 10;      // 鼠标的检测区域尺寸
    property var mousePressedPos;       // 鼠标按下时的坐标
    property var mouseMovedPos;         // 鼠标移动时的坐标
    property bool isClicked: false;     // 是否点击
    property int mouseState: 0;         // 鼠标状态

    /*
    MouseArea {
        z: 11
        id: mouse_area
        enabled: currentUserType == 0
        hoverEnabled: coursewareview.focus
        anchors.fill: coursewareview

        onClicked: {
            ymcourseware.goNextAnimationSteps();
        }

        onPressed:{
            coursewareview.focus = true;
            coursewareview.isClicked = true;
            mousePressedPos = parent.mapToItem(parent.parent, mouseX, mouseY);
            mouse.accepted = true;
        }
        onReleased:{
            coursewareview.isClicked = false;
            mouse.accepted = true;
            sigCMVChangeWindow(h5coursewareId, "move", coursewareview.width, coursewareview.height, coursewareview.x, coursewareview.y);
        }
        onPositionChanged: {
            if(coursewareview.isClicked){
                mouseMovedPos = parent.mapToItem(parent.parent, mouseX, mouseY);
                switch(mouseState){
                case 0:
                case 5:
                    if(isEnableDrag){
                        var moveX = coursewareview.x + mouseMovedPos.x - mousePressedPos.x;
                        var moveY = coursewareview.y + mouseMovedPos.y - mousePressedPos.y;
                        var moveWidth = coursewareview.parent.width - coursewareview.width;
                        var moveHeight = coursewareview.parent.height - coursewareview.height;

                        if( moveX > 0 && moveX < moveWidth) {
                            coursewareview.x = coursewareview.x + mouseMovedPos.x - mousePressedPos.x;
                        }
                        else{
                            var loactionX = moveX < 0 ? 0 : (moveX > moveWidth ? moveWidth : moveX);
                            coursewareview.x = loactionX;
                        }

                        if(moveY  > 0 && moveY < moveHeight){
                            coursewareview.y = coursewareview.y + mouseMovedPos.y - mousePressedPos.y;
                        }
                        else{
                            coursewareview.y = moveY < 0 ? 0 : (moveY > moveHeight ? moveHeight : moveY);
                        }
                    }
                    break;

                case 1:
                    coursewareview.width = coursewareview.width - mouseMovedPos.x + mousePressedPos.x;
                    coursewareview.height = coursewareview.height - mouseMovedPos.y + mousePressedPos.y;
                    if(coursewareview.width > 25){
                        coursewareview.x = coursewareview.x + mouseMovedPos.x - mousePressedPos.x;
                    }
                    if(coursewareview.height > 25){
                        coursewareview.y = coursewareview.y + mouseMovedPos.y - mousePressedPos.y;
                    }
                    break;

                case 2:
                    coursewareview.width = coursewareview.width - mouseMovedPos.x + mousePressedPos.x;
                    if(coursewareview.width > 25){
                        coursewareview.x = coursewareview.x + mouseMovedPos.x - mousePressedPos.x;
                    }
                    break;

                case 3:
                    coursewareview.width = coursewareview.width - mouseMovedPos.x + mousePressedPos.x;
                    coursewareview.height = coursewareview.height + mouseMovedPos.y - mousePressedPos.y;
                    if(coursewareview.width > 25){
                        coursewareview.x = coursewareview.x + mouseMovedPos.x - mousePressedPos.x;
                    }
                    break;

                case 4:
                    coursewareview.height = coursewareview.height - mouseMovedPos.y + mousePressedPos.y;
                    if(coursewareview.height > 25){
                        coursewareview.y = coursewareview.y + mouseMovedPos.y - mousePressedPos.y;
                    }
                    break;

                case 6:
                    coursewareview.height = coursewareview.height + mouseMovedPos.y - mousePressedPos.y;
                    break;

                case 7:
                    coursewareview.height = coursewareview.height - mouseMovedPos.y + mousePressedPos.y;
                    coursewareview.width = coursewareview.width + mouseMovedPos.x - mousePressedPos.x;
                    if(coursewareview.height > 25){
                        coursewareview.y = coursewareview.y + mouseMovedPos.y - mousePressedPos.y;
                    }
                    break;

                case 8:
                    coursewareview.width = coursewareview.width + mouseMovedPos.x - mousePressedPos.x;
                    break;

                case 9:
                    coursewareview.width = coursewareview.width + mouseMovedPos.x - mousePressedPos.x;
                    coursewareview.height = coursewareview.height + mouseMovedPos.y - mousePressedPos.y;
                    break;

                default:
                    break;
                }
                if(coursewareview.width <= 25){
                    coursewareview.width = 25;
                }
                if(coursewareview.height <= 25){
                    coursewareview.height = 25;
                }

                mousePressedPos = mouseMovedPos;
            }
            else {
                if(isEnableScale){
                    if(mouseX < detectedSize && mouseX >= 0){
                        if(0 <= mouseY  && mouseY < detectedSize){
                            mouseState = 1;
                            mouse_area.cursorShape = Qt.SizeFDiagCursor;
                        }
                        else if(detectedSize <= mouseY && mouseY <= coursewareview.height - detectedSize){
                            mouseState = 2;
                            mouse_area.cursorShape = Qt.SizeHorCursor;
                        }
                        else if((coursewareview.height - detectedSize) < mouseY && mouseY <= coursewareview.height){
                            mouseState = 3;
                            mouse_area.cursorShape = Qt.SizeBDiagCursor;
                        }
                    }
                    else if(coursewareview.width - detectedSize < mouseX && mouseX <= coursewareview.width){
                        if(0 <= mouseY && mouseY < detectedSize){
                            mouseState = 7;
                            mouse_area.cursorShape = Qt.SizeBDiagCursor;
                        }
                        else if((coursewareview.height - detectedSize) < mouseY && mouseY <= coursewareview.height){
                            mouseState = 9;
                            mouse_area.cursorShape = Qt.SizeFDiagCursor;
                        }
                        else if(detectedSize <= mouseY  && mouseY <= coursewareview.height - detectedSize){
                            mouseState = 8;
                            mouse_area.cursorShape = Qt.SizeHorCursor;
                        }
                    }
                    else if(coursewareview.width - detectedSize >= mouseX && mouseX >= detectedSize){
                        if(0 <= mouseY && mouseY < detectedSize){
                            mouseState = 4;
                            mouse_area.cursorShape = Qt.SizeVerCursor;
                        }
                        else if((coursewareview.height - detectedSize) < mouseY && mouseY <= coursewareview.height){
                            mouseState = 6;
                            mouse_area.cursorShape = Qt.SizeVerCursor;
                        }
                        else if(detectedSize <= mouseY&&mouseY <= coursewareview.height - detectedSize){
                            mouseState = 5;
                            mouse_area.cursorShape = Qt.ArrowCursor;
                        }
                    }
                }
            }
            mouse.accepted = true;
            //sigCMVChangeWindow("move", coursewareview.width, coursewareview.height, coursewareview.x, coursewareview.y);
        }
    }
    */

    // 点击课件区域
    MouseArea {
        id: click_area
        z: 12
        width: (courseRect.width - scrollbar.width) > (courseRect.height/9)*16 ? (courseRect.height/9)*16 : (courseRect.width - scrollbar.width)
        height: (width/16)*9
        anchors.centerIn: courseRect
        visible: true
        enabled: currentUserType == 0 ? true : false
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            ymcourseware.goNextAnimationSteps();
        }
    }

    Rectangle {
        id: topToolbar
        width: parent.width
        height: 26 * heightRate
        color: "#363744"
        enabled: currentUserRole == 0
        z: 102
        anchors.top: parent.top
        // 课件名称
        Item {
            z: 1
            anchors.fill: parent
            Text {
                id: name
                anchors.horizontalCenter: parent.horizontalCenter
                text: coursewareName
                font.pixelSize: 14 * heightRate
                wrapMode: Text.WordWrap
                font.family: Cfg.DEFAULT_FONT
                color:"#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // 拖拽区域
        MouseArea {
            anchors.fill: parent
            z:2
            onPressed:{
                coursewareview.focus = true;
                coursewareview.isClicked = true;
                mousePressedPos = parent.mapToItem(parent.parent, mouseX, mouseY);
                mouse.accepted = true;
            }
            onReleased:{
                coursewareview.isClicked = false;
                mouse.accepted = true;
                sigCMVChangeWindow(h5coursewareId, "move", coursewareview.width, coursewareview.height, coursewareview.x, coursewareview.y);

            }
            onPositionChanged: {
                if(isEnableDrag){
                    mouseMovedPos = parent.mapToItem(parent.parent, mouseX, mouseY);
                    var moveX = coursewareview.x + mouseMovedPos.x - mousePressedPos.x;
                    var moveY = coursewareview.y + mouseMovedPos.y - mousePressedPos.y;
                    var moveWidth = coursewareview.parent.width - coursewareview.width;
                    var moveHeight = coursewareview.parent.height - coursewareview.height;

                    if( moveX > 0 && moveX < moveWidth) {
                        coursewareview.x = coursewareview.x + mouseMovedPos.x - mousePressedPos.x;
                    }
                    else{
                        var loactionX = moveX < 0 ? 0 : (moveX > moveWidth ? moveWidth : moveX);
                        coursewareview.x = loactionX;
                    }

                    if(moveY  > 0 && moveY < moveHeight){
                        coursewareview.y = coursewareview.y + mouseMovedPos.y - mousePressedPos.y;
                    }
                    else{
                        coursewareview.y = moveY < 0 ? 0 : (moveY > moveHeight ? moveHeight : moveY);
                    }
                    sigCoursewareWindowInfo(ymcourseware.width, ymcourseware.height, ymcourseware.x, ymcourseware.y);
                }
            }
        }

        // 右上角
        Rectangle {
            id: rightTopToolbar
            width: 82 * widthRate
            height: 26 * heightRate
            anchors.right: parent.right
            anchors.top: parent.top
            color: "#363744"
            z: 2
            visible: currentUserRole == 0
            // 关闭按钮
            Item {
                width: 26 * widthRate
                height: 26 * heightRate
                anchors.right: parent.right
                Image {
                    anchors.fill: parent
                    source: "qrc:/cvimages/pop_close_normal.png"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sigCMVChangeWindow(h5coursewareId,"close", coursewareview.width, coursewareview.height, coursewareview.x, coursewareview.y);
                    }
                }
            }
            // 最大化
            Item {
                width: 26 * widthRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: 28 * widthRate
                Image {
                    anchors.fill: parent
                    source: "qrc:/cvimages/pop_zoom_normal.png"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if(coursewareview.width == coursewareview.parent.width && coursewareview.height == coursewareview.parent.height){
                            sigCMVChangeWindow(h5coursewareId, "recover", coursewareview.width, coursewareview.height, coursewareview.x, coursewareview.y);
                        }
                        else{
                            sigCMVChangeWindow(h5coursewareId, "max", coursewareview.width, coursewareview.height, coursewareview.x, coursewareview.y);
                        }
                    }
                }
            }
            // 最小化
            Item {
                width: 26 * widthRate
                height: 26 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: 56 * widthRate
                Image {
                    anchors.fill: parent
                    source: "qrc:/cvimages/pop_narrow_normal.png"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sigCMVChangeWindow(h5coursewareId, "min", coursewareview.width, coursewareview.height, coursewareview.x, coursewareview.y);
                    }
                }
            }
        }
    }

    Rectangle {
        id: courseRect
        width: parent.width
        enabled: currentUserType == 0
        height: parent.height - coursewareBottomBar.height - topToolbar.height
        anchors.top: topToolbar.bottom
        color: "#000000"

    }

    // 白板区域
    WhiteBoard0 {
        id: whiteCMVBoard
        z: 12
        clip: true
        width: (courseRect.width - scrollbar.width) > (courseRect.height/9)*16 ? (courseRect.height/9)*16 : (courseRect.width - scrollbar.width)
        height: (width/16)*9
        anchors.centerIn: courseRect
        smooth: true
        visible: true
        enabled: currentUserType != 0 ? false : true
        onSigMouseReleases: {
            sigSelecteWhiteBoard(whiteCMVBoard.width,whiteCMVBoard.height,(parent.width - whiteCMVBoard.width) / 2,topToolbar.height);
        }
    }

    // 课件区域
    CoursewareView {
        id: ymcourseware
        z: 10
        width: (courseRect.width - scrollbar.width) > (courseRect.height/9)*16 ? (courseRect.height/9)*16 : (courseRect.width - scrollbar.width)
        height: (width/16)*9
        anchors.centerIn: courseRect
        visible: true
        userRole: currentUserType == 0 ? "tea" : (currentUserType == 1 ? "stu" : "assistant")
        enabled: currentUserType == 0 ? true : false

        onSigH5GoPages: {
            sigCMVStuCurrentPage();
            // 此信号学生端才收到
            coursewareBottomBar.currentPage = currentPage + 1;
            coursewareBottomBar.totalPage = totalPage;
        }

        onSigChangeCurrentPages: {
            currentPage = pages;
            coursewareBottomBar.currentPage = pages;
        }
        onSigChangeTotalPages: {
            coursewareBottomBar.totalPage = pages;
        }
        onSigGetOffsetImage: {
            curOffsetY = currentCourseOffsetY;
            sigCMVGetOffsetImage(url, curOffsetY);
        }
        onSigSendH5PlayAnimation: {
            sigCMVSendH5PlayAnimation(animationStepIndex);
        }
        onSigSendH5ThumbnailPage: {
            sigCMVStuCurrentPage();
            sigCMVSendH5ThumbnailPage(pageIndex, coursewareBottomBar.totalPage);
        }
        onSigLoadsCoursewareSuccess: {
            sigCMVLoadsCoursewareSuccess(currentUrl);
        }
        onSigIsCouserware: {
            sigCMVIsCouserware();
        }
        onSigCurrentCoursewareId: {
            sigCMVCurrentCoursewareId(coursewareId);
            h5coursewareId = coursewareId;
        }
        onSigWindowUpdates: {
            sigCMVWindowUpdates(windowInfo);
        }

        onSigVisualizeH5Courseware: {
            sigCMVVisualizeH5Courseware();
        }
        onSigH5GetScroll: {
            sigH5GetScrolls(scrollValue);
        }
    }

    //滚动条
    Item {
        id: scrollbar
        anchors.left: ymcourseware.right
        anchors.top: courseRect.top
        width: 8 * heightRate
        height: coursewareview.height
        visible: false
        z: 16

        // 按钮
        Rectangle {
            id: button
            width: parent.width
            height: {
                var mutilValue = currentImageHeight / coursewareview.height
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
                    var contentY =  (button.y / scrollbar.height * currentImageHeight / coursewareview.height);
                    toolbar.updataScrollMap(contentY);
                    whiteBoard.getOffSetImage(0.0,contentY,1.0);
                }
            }
        }
    }

    CoursewareBottomBar {
        z: 102
        id: coursewareBottomBar
        //enabled: currentUserType == 0
        width: parent.width
        height: 28 * heightRate //currentUserType == 0 ? 30 * widthRate : 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2 * heightRate

        //跳转页面
        onSigCMVJumpPage: {
            sigCMVJumpPages(pages, coursewareBottomBar.totalPage);
//            if(currentUserType == 0 && isPrevOrNext){
//                return;
//            }
            console.log("=====onSigJumpPage====",pages)
            coursewareMainView.coursewareOperation(3, 4, pages,0);
        }
        // 上一页
        onSigCMVPrePage: {
            console.log("======onSigPrePage====");
            coursewareMainView.coursewareOperation(3, 0, 0,0);
        }
        // 下一页
        onSigCMVNext: {
            console.log("======onSigNextPage====");
            coursewareMainView.coursewareOperation(3,1,1,0);;
        }
        //增加页
        onSigCMVAddPage: {
            sigCMVAddPages(coursewareBottomBar.currentPage, coursewareBottomBar.totalPage + 1);
            coursewareMainView.coursewareOperation(coursewareType,2,coursewareBottomBar.currentPage,0);
        }
        //删除页
        onSigCMVRemoverPage: {
            sigCMVRemoverPages(coursewareBottomBar.currentPage - 1,coursewareBottomBar.totalPage - 1);
        }
        //翻页首末页提醒
        onSigCMVTipPage:  {
            sigCMVTipPages(message);
        }

        // 右下角-H5课件控制台测试按钮
        MouseArea {
            z: 999
            width: 28 * widthRate
            height: 28 * heightRate
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                click_area.enabled = !click_area.enabled;
            }
        }
    }

    function insertCourseWare(imgUrlList,fileId,h5Url,coursewareType,token){
        if(coursewareType == 3){
            ymcourseware.setCoursewareSource("",coursewareType,h5Url,parent.width,parent.height,token);
        }
    }

    function coursewareOperation(coursewareType, operationType, operationIndex,step){
        ymcourseware.coursewareOperation(coursewareType,operationType,operationIndex,step);
    }

    function setEnableWhiteBoard(isEnable){
        whiteCMVBoard.enabled = isEnable;
    }

    function setWhiteBoardId(whiteBoardId){
        whiteCMVBoard.setWhiteBoardId(whiteBoardId);
    }
}
