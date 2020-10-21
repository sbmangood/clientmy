import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtWebEngine 1.4
import QtWebView 1.1
import "Configuuration.js" as Cfg
import QtGraphicalEffects 1.0
import YMHomeworkWrittingBoard 1.0

/* 试听课的课堂报告 */
Rectangle {
    id:itemView
    color: "transparent"
    property var statusTexts: 0;

    property var curentIsFinishClip: 0;//判断当前截图有没有被全部上传成功 全部上传成功之后发socket命令出去

    property var urlImgList : [];

    signal sendReportImgSocket(var imgarry);//发送当前的需要导入课堂的图片

    signal hideCurrentView();

    property bool reportHasPublic: false;

    property var insertRoomButtonText:"";

    signal startClipHMImg();//开始生成作业截图

    signal finishedClipHmImg();//生成作业截图结束

    property bool currentIsClippingImg: false;
    onVisibleChanged:
    {
        if(visible)
        {
            webViewOne.reload();
            webViewTwo.reload();
            webViewTh.reload();
            webViewF.reload();
            webViewFive.reload();
        }
    }


    MouseArea{
        anchors.fill: parent
    }

    Rectangle
    {
        id:noReportView
        width: parent.width - 4 * widthRates
        height: parent.height //- 4 * widthRates
        anchors.centerIn: parent
        color: "white"
        z:2000
        visible:!hasExistListenReport;
        Image {
            id:emptyImgs
            width: 296 * heightRates * 0.5
            height: 380 * heightRates * 0.5
            source: "qrc:/newStyleImg/pc_status_empty@2x.png"
            anchors.centerIn: parent
        }
        MouseArea
        {
            anchors.fill: parent
            onClicked:
            {
                return
            }
        }

        Text {
            text:canImportReportImgs ? qsTr("暂时没有试听课报告哦~") : qsTr("学生端版本过低，不支持试听课报告导入哦~")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 14 * heightRate
            color: "#666666"
            anchors.top: emptyImgs.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    ScrollView {
        id:scroll
        width: parent.width
        height: parent.height - 50 * widthRates
        //verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        style: ScrollViewStyle
        {
            handle: Rectangle {
                implicitWidth: 5 * widthRate
                implicitHeight: 30 * widthRate
                width: 30 * widthRate
                color: "#cccccc"
                radius: 4 * widthRate
                anchors.left: parent.left
                anchors.leftMargin: 8 * widthRate
            }
            scrollBarBackground:Rectangle
            {
                width: 15 * widthRate
                color: "transparent"
            }

            decrementControl: Rectangle {}
            incrementControl: Rectangle {}
        }

        Rectangle {
            id:rect
            width: parent.width
            height: rect1.height + rect2.height + rect3.height + rect4.height + rect5.height
            Rectangle {
                id: rect1
                anchors.top: rect.top
                width: currentIsClippingImg ? trailBoardBackground.width : itemView.width
                height: webViewOne.height + title1.height + 10 * heightRates
                color: "transparent"
                Rectangle
                {
                    id:title1
                    width: parent.width - 10 * widthRates
                    height: 40 * widthRates
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "transparent"

                    Image {
                        width: 30 * widthRates
                        height: 30 * widthRates
                        source: "qrc:/auditionLessonImage/hs_course_report_info@3x.png"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin:  15 * widthRates
                    }
                    Text {
                        text: qsTr("课程信息")
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 18 * heightRate
                        anchors.left: parent.left
                        anchors.leftMargin:  55 * widthRates
                    }

                    CheckBox
                    {
                        id: checkBoxOne
                        width: 10 * widthRates
                        height: 10 * widthRates
                        anchors.right: parent.right
                        anchors.rightMargin: 30 * widthRates
                        anchors.verticalCenter: parent.verticalCenter
                        text: "选择"
                        z: 5
                        visible: false
                        opacity: 0.5

                        onCheckedChanged:
                        {
                            if(checked)
                            {
                                ++statusTexts;
                            }else
                            {
                                --statusTexts;
                            }
                        }
                    }
                    MouseArea
                    {
                        width: 20 * widthRates
                        height: 20 * widthRates
                        anchors.right: parent.right
                        anchors.rightMargin: 30 * widthRates
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor
                        visible: !currentIsClippingImg
                        z:100
                        onClicked:
                        {
                            checkBoxOne.checked =  !checkBoxOne.checked;
                        }

                        Image {
                            anchors.fill: parent
                            source: checkBoxOne.checked ? "qrc:/auditionLessonImage/th_popwindow_btn_selected.png" : "qrc:/auditionLessonImage/th_popwindow_btn_unselect.png"
                        }
                    }
                }


                WebEngineView {
                    id:webViewOne
                    width: itemView.width - 10 *widthRates
                    height: 400 * widthRates
                    activeFocusOnPress: false
                    anchors.left: parent.left
                    anchors.leftMargin: 5 * widthRates
                    enabled: false
                    anchors.top: title1.bottom
                    anchors.topMargin: 10 *heightRates
                    url:loadInforMation.getAuditionReportView( "1" )
                    property int timesss: 0;

                    //右键的时候, 不弹出右键菜单
                    onContextMenuRequested: function(request) {
                        request.accepted = true;
                    }

                    onLoadProgressChanged:
                    {
                        if(webViewOne.loadProgress == 100)
                        {
                            if(webViewOne.height < 1000 )
                            {
                                // webViewOne.height = webViewOne.contentsSize.height;
                            }
                        }
                    }
                    onContentsSizeChanged:
                    {
                        if(webViewOne.contentsSize.height > 50 * widthRates)
                        {
                            ++timesss;
                            if(timesss > 150)
                            {
                                return;
                            }

                            webViewOne.height = webViewOne.contentsSize.height;
                        }
                    }
                }

            }

            Rectangle {
                id: rect2
                anchors.top: rect1.bottom
                width: currentIsClippingImg ? trailBoardBackground.width : itemView.width
                height: webViewTwo.height + 50 * heightRates
                color: "transparent"
                Rectangle
                {
                    id:title2
                    width: parent.width - 10 * widthRates
                    height: 40 * widthRates
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "transparent"

                    Image {
                        width: 30 * widthRates
                        height: 30 * widthRates
                        source: "qrc:/auditionLessonImage/hs_course_report_detail@3x.png"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin:  15 * widthRates
                    }
                    Text {
                        text: qsTr("本次课堂用时详情")
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 18 * heightRate
                        anchors.left: parent.left
                        anchors.leftMargin:  55 * widthRates
                    }
                    MouseArea
                    {
                        width: 20 * widthRates
                        height: 20 * widthRates
                        anchors.right: parent.right
                        anchors.rightMargin: 30 * widthRates
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor
                        visible: !currentIsClippingImg
                        z:100
                        onClicked:
                        {
                            checkBoxTwo.checked =  !checkBoxTwo.checked;
                        }

                        Image {
                            anchors.fill: parent
                            source: checkBoxTwo.checked ? "qrc:/auditionLessonImage/th_popwindow_btn_selected.png" : "qrc:/auditionLessonImage/th_popwindow_btn_unselect.png"
                        }
                    }

                    CheckBox
                    {
                        id: checkBoxTwo
                        width: 10 * widthRates
                        height: 10 * widthRates
                        anchors.right: parent.right
                        anchors.rightMargin: 30 * widthRates
                        anchors.verticalCenter: parent.verticalCenter
                        text: "选择"
                        z: 5
                        visible: false
                        opacity: 0.5
                        onCheckedChanged:
                        {
                            if(checked)
                            {
                                ++statusTexts;
                            }else
                            {
                                --statusTexts;
                            }
                        }
                    }

                }


                WebEngineView {
                    id:webViewTwo
                    width: currentIsClippingImg ? trailBoardBackground.width : itemView.width - 10 *widthRates
                    height: 400 * widthRates
                    //activeFocusOnPress: false
                    anchors.left: parent.left
                    anchors.leftMargin: 5 * widthRates
                    anchors.top:title2.bottom
                    anchors.topMargin: 10 *heightRates
                   // enabled: false
                    url:loadInforMation.getAuditionReportView( "2" )
                    property int webViewTwoTimes: 0;

                    //右键的时候, 不弹出右键菜单
                    onContextMenuRequested: function(request) {
                        request.accepted = true;
                    }

                    onLoadProgressChanged:
                    {
                        if(webViewTwo.loadProgress == 100)
                        {
                            if(webViewTwo.height < 1000 )
                            {
                                //webViewTwo.height = webViewTwo.contentsSize.height;
                            }
                        }
                    }

                    onContentsSizeChanged:
                    {
                        if(webViewTwo.contentsSize.height > 50 * widthRates )
                        {
                            ++webViewTwoTimes;
                            if(webViewTwoTimes > 150)
                            {
                                return;
                            }
                            webViewTwo.height = webViewTwo.contentsSize.height;
                        }
                    }

                }

            }

            Rectangle {
                id: rect3
                anchors.top: rect2.bottom
                width: currentIsClippingImg ? trailBoardBackground.width : itemView.width
                height: webViewTh.height + 50 * heightRates
                color: "transparent"
                Rectangle
                {
                    id:title3
                    width: parent.width - 10 * widthRates
                    height: 40 * widthRates
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "transparent"

                    Image {
                        width: 30 * widthRates
                        height: 30 * widthRates
                        source: "qrc:/auditionLessonImage/hs_course_report_analysis@3x.png"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin:  15 * widthRates
                    }
                    Text {
                        text: qsTr("课堂练习错因分析")
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 18 * heightRate
                        anchors.left: parent.left
                        anchors.leftMargin:  55 * widthRates
                    }

                    MouseArea
                    {
                        width: 20 * widthRates
                        height: 20 * widthRates
                        anchors.right: parent.right
                        anchors.rightMargin: 30 * widthRates
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor
                        visible: !currentIsClippingImg
                        z:100
                        onClicked:
                        {
                            checkBoxTh.checked =  !checkBoxTh.checked;
                        }

                        Image {
                            anchors.fill: parent
                            source: checkBoxTh.checked ? "qrc:/auditionLessonImage/th_popwindow_btn_selected.png" : "qrc:/auditionLessonImage/th_popwindow_btn_unselect.png"
                        }
                    }

                    CheckBox
                    {
                        id: checkBoxTh
                        width: 10 * widthRates
                        height: 10 * widthRates
                        anchors.right: parent.right
                        anchors.rightMargin: 30 * widthRates
                        anchors.verticalCenter: parent.verticalCenter
                        text: "选择"
                        z: 5
                        visible: false
                        opacity: 0.5
                        onCheckedChanged:
                        {
                            if(checked)
                            {
                                ++statusTexts;
                            }else
                            {
                                --statusTexts;
                            }
                        }
                    }


                }

                WebEngineView {
                    id:webViewTh
                    width: currentIsClippingImg ? trailBoardBackground.width : itemView.width - 10 *widthRates
                    height: 400 * widthRates
                    //activeFocusOnPress: false
                    anchors.left: parent.left
                    anchors.leftMargin: 5 * widthRates
                    anchors.top:title3.bottom
                    anchors.topMargin: 10 * heightRates
                    //enabled: false
                    url:loadInforMation.getAuditionReportView( "3" )
                    property int webViewThTimes: 0;

                    //右键的时候, 不弹出右键菜单
                    onContextMenuRequested: function(request) {
                        request.accepted = true;
                    }

                    onLoadProgressChanged:
                    {
                        if(webViewTh.loadProgress == 100)
                        {
                            if(webViewTh.height < 1000 )
                            {
                                //webViewTh.height = webViewTh.contentsSize.height;
                            }
                        }
                    }

                    onContentsSizeChanged:
                    {
                        if(webViewTh.contentsSize.height > 50 * widthRates )
                        {
                            ++webViewThTimes;
                            if(webViewThTimes > 150)
                            {
                                return;
                            }
                            webViewTh.height = webViewTh.contentsSize.height;
                        }
                    }
                }

            }

            Rectangle {
                id: rect4
                anchors.top: rect3.bottom
                width: currentIsClippingImg ? trailBoardBackground.width : itemView.width// - 5 *widthRates
                height: webViewF.height + 50 * heightRates
                color: "transparent"

                Rectangle
                {
                    id:title4
                    width: parent.width - 10 * widthRates
                    height: 40 * widthRates
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "transparent"

                    Image {
                        width: 30 * widthRates
                        height: 30 * widthRates
                        source: "qrc:/auditionLessonImage/hs_course_report_remark@3x.png"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin:  15 * widthRates
                    }
                    Text {
                        text: qsTr("教师评价")
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 18 * heightRate
                        anchors.left: parent.left
                        anchors.leftMargin:  55 * widthRates
                    }
                    MouseArea
                    {
                        width: 20 * widthRates
                        height: 20 * widthRates
                        anchors.right: parent.right
                        anchors.rightMargin: 30 * widthRates
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor
                        visible: !currentIsClippingImg
                        z:100
                        onClicked:
                        {
                            checkBoxF.checked =  !checkBoxF.checked;
                        }

                        Image {
                            anchors.fill: parent
                            source: checkBoxF.checked ? "qrc:/auditionLessonImage/th_popwindow_btn_selected.png" : "qrc:/auditionLessonImage/th_popwindow_btn_unselect.png"
                        }
                    }
                    CheckBox
                    {
                        id: checkBoxF
                        width: 10 * widthRates
                        height: 10 * widthRates
                        anchors.right: parent.right
                        anchors.rightMargin: 30 * widthRates
                        anchors.verticalCenter: parent.verticalCenter
                        text: "选择"
                        visible: false
                        z: 5
                        opacity: 0.5

                        onCheckedChanged:
                        {
                            if(checked)
                            {
                                ++statusTexts;
                            }else
                            {
                                --statusTexts;
                            }
                        }
                    }

                }


                WebEngineView {
                    id:webViewF
                    width: currentIsClippingImg ? trailBoardBackground.width : itemView.width - 10 *widthRates
                    height: 500 * widthRates
                    //activeFocusOnPress: false
                    anchors.left: parent.left
                    anchors.leftMargin: 5 * widthRates
                    anchors.top: title4.bottom
                    anchors.topMargin: 10 * heightRates
                    //enabled: false
                    url:loadInforMation.getAuditionReportView( "4" )
                    property int webViewFTimes: 0;

                    //右键的时候, 不弹出右键菜单
                    onContextMenuRequested: function(request) {
                        request.accepted = true;
                    }

                    onLoadProgressChanged:
                    {
                        if(webViewF.loadProgress == 100)
                        {
                            if(webViewF.height < 1000 )
                            {
                                //webViewF.height = webViewF.contentsSize.height;
                            }
                        }
                    }

                    onContentsSizeChanged:
                    {
                        if(webViewF.contentsSize.height > 50 * widthRates )
                        {
                            ++webViewFTimes;
                            if(webViewFTimes > 150)
                            {
                                return;
                            }
                            webViewF.height = webViewF.contentsSize.height;
                        }
                    }
                }

            }

            Rectangle {
                id: rect5
                anchors.top: rect4.bottom
                width: currentIsClippingImg ? trailBoardBackground.width : itemView.width
                height: webViewF.height + 50 * heightRates
                color: "transparent"

                Rectangle
                {
                    id:title5
                    width: parent.width - 10 * widthRates
                    height: 40 * widthRates
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "transparent"

                    Image {
                        width: 30 * widthRates
                        height: 30 * widthRates
                        source: "qrc:/auditionLessonImage/hs_course_report_plan@3x.png"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin:  15 * widthRates
                    }
                    Text {
                        text: qsTr("学科课课程规划")
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 18 * heightRate
                        anchors.left: parent.left
                        anchors.leftMargin:  55 * widthRates
                    }

                    MouseArea
                    {
                        width: 20 * widthRates
                        height: 20 * widthRates
                        anchors.right: parent.right
                        anchors.rightMargin: 30 * widthRates
                        anchors.verticalCenter: parent.verticalCenter
                        cursorShape: Qt.PointingHandCursor
                        visible: !currentIsClippingImg
                        z:100
                        onClicked:
                        {
                            checkBoxFive.checked =  !checkBoxFive.checked;
                        }

                        Image {
                            anchors.fill: parent
                            source: checkBoxFive.checked ? "qrc:/auditionLessonImage/th_popwindow_btn_selected.png" : "qrc:/auditionLessonImage/th_popwindow_btn_unselect.png"
                        }
                    }

                    CheckBox
                    {
                        id: checkBoxFive
                        width: 10 * widthRates
                        height: 10 * widthRates
                        anchors.right: parent.right
                        anchors.rightMargin: 30 * widthRates
                        anchors.verticalCenter: parent.verticalCenter
                        text: "选择"
                        z: 5
                        visible: false
                        opacity: 0.5

                        onCheckedChanged:
                        {
                            if(checked)
                            {
                                ++statusTexts;
                            }else
                            {
                                --statusTexts;
                            }
                        }
                    }

                }


                WebEngineView {
                    id:webViewFive
                    width: itemView.width - 10 *widthRates
                    height: 400 * widthRates
                    //activeFocusOnPress: false
                    anchors.left: parent.left
                    anchors.leftMargin: 5 * widthRates
                    anchors.top:title5.bottom
                    anchors.topMargin: 10 * heightRates
                    //enabled: false
                    url:loadInforMation.getAuditionReportView( "5" )
                    property int webViewFiveTimes: 0;

                    //右键的时候, 不弹出右键菜单
                    onContextMenuRequested: function(request) {
                        request.accepted = true;
                    }

                    onLoadProgressChanged:
                    {
                        if(webViewFive.loadProgress == 100)
                        {
                            if(webViewFive.height < 1000 )
                            {
                                //webViewFive.height = webViewFive.contentsSize.height;
                            }
                        }
                    }

                    onContentsSizeChanged:
                    {
                        if(webViewFive.contentsSize.height > 50 * widthRates )
                        {
                            ++webViewFiveTimes;
                            if(webViewFiveTimes > 150)
                            {
                                return;
                            }
                            webViewFive.height = webViewFive.contentsSize.height;
                        }
                    }
                }

            }

        }
    }

    MouseArea
    {
        width: 20 * widthRates
        height: 20 * widthRates
        cursorShape: Qt.PointingHandCursor
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15 * heightRates
        anchors.left: parent.left
        anchors.leftMargin: 15 * heightRates
        visible: !currentIsClippingImg
        z:100
        onClicked:
        {
            checkBoxAll.checked =  !checkBoxAll.checked;
        }

        Image {
            anchors.fill: parent
            source: checkBoxAll.checked ? "qrc:/auditionLessonImage/th_popwindow_btn_selected.png" : "qrc:/auditionLessonImage/th_popwindow_btn_unselect.png"
        }
    }

    CheckBox
    {
        id:checkBoxAll
        width: 20 * widthRates
        height: 30 * widthRates
        visible: false
        text: "全选"
        z: 5
        opacity: 0.5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15 * heightRates
        anchors.left: parent.left
        anchors.leftMargin: 15 * heightRates
        onCheckedChanged:
        {
            if(checked)
            {
                checkBoxOne.checked = true;
                checkBoxTwo.checked = true;
                checkBoxTh.checked = true;
                checkBoxF.checked = true;
                checkBoxFive.checked = true;

                statusTexts = 5;
            }else
            {
                checkBoxOne.checked = false;
                checkBoxTwo.checked = false;
                checkBoxTh.checked = false;
                checkBoxF.checked = false;
                checkBoxFive.checked = false;

                statusTexts = 0;
            }
        }

    }


    Text {
        id:selectAll
        text: "全选"
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 14 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18 * heightRates
        anchors.left: parent.left
        anchors.leftMargin: 48 * heightRates
        color: "#666666"
    }

    Text {
        id:hasSelectOne
        text: "已选择"
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 14 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18 * heightRates
        anchors.left: selectAll.right
        anchors.leftMargin: 15 * heightRates
        color: "#666666"
    }

    Text {
        id:hasSelectNumber
        text: statusTexts
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 14 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18 * heightRates
        anchors.left: hasSelectOne.right
        color: "#FF6633"
    }

    Text {
        text: "道题"
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 14 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18 * heightRates
        anchors.left: hasSelectNumber.right
        color: "#666666"
    }

    Rectangle{
        id:insertRoomButton
        height: 30 * widthRates
        width: height * 5.2
        color:  statusTexts != 0 ? "#ff5000" : "#cccccc"
        radius: 5 * widthRates
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 7 * heightRates
        anchors.right: parent.right
        anchors.rightMargin: 15 * heightRates

        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 14 * heightRate
            text:  statusTexts == 0 ? qsTr("导入课堂") : (!insertRoomButton.enabled ? "正在导入课堂..." : "导入课堂" )
            color: "white"
            anchors.centerIn: parent
        }
        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                currentIsClippingImg = true;
                insertRoomButton.enabled = false;
                curentIsFinishClip = statusTexts;

                startClipHMImg();

                urlImgList = [];

                if(checkBoxOne.checked == true)
                {
                    clipImage(rect1);
                }

                if(checkBoxTwo.checked == true)
                {
                    clipImage(rect2);
                }

                if( checkBoxTh.checked == true)
                {
                    clipImage(rect3);
                }

                if( checkBoxF.checked == true)
                {
                    clipImage(rect4);
                }

                if( checkBoxFive.checked == true)
                {
                    clipImage(rect5);
                }
            }
        }
    }



    //截图处理
    YMHomeworkWrittingBoard{
        id: drawImageBoard
        onSigBeSavedGrapAnswer: {
            console.log("===== ::imageUrl====", imageUrl,imageUrl.split("/"))

            var imageNameArr = imageUrl.split("/");
            var imageName = imageNameArr[imageNameArr.length - 1];
            urlImgList.push(
                        {
                            "height": imgHeight.toString(),
                            "width": imgWidth .toString(),
                            //                            "height": "1.000000",
                            //                            "width": "1.000000",
                            "imageUrl": loadInforMation.uploadQuestionImgOSS("135920","135920","135920",imageName, imageUrl.toString())

                        })

            --curentIsFinishClip;

            console.log("=====::imagsseUrl====111");
            if(curentIsFinishClip == 0 && urlImgList.length > 0)
            {
                //发socket出去

                for(var a = 0; a < urlImgList.length; a++)
                {
                    console.log("=====::imagsseUrl====",urlImgList[a].imageUrl);
                }

                sendReportImgSocket(urlImgList);
                insertRoomButton.enabled = true;
                hideCurrentView();
                finishedClipHmImg();//生成作业截图结束
                currentIsClippingImg = false;
            }

        }
    }




    function clipImage(object){
        drawImageBoard.grapItemImage(object);
    }

    Component.onCompleted:
    {
        reportHasPublic = loadInforMation;

        endLessonH5Url = loadInforMation.getEndLessonH5Url();
    }
}
