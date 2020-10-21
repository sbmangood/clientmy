import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "../Configuration.js" as Cfg

//课程目录
Item {
    id:detailItem
    anchors.fill: parent

    property var topItemDataBuffer;

    signal sigCourseCatalog(var id,var dataJson);
    signal getListData(var type,var classId);//1 获取课表  2作业列表数据
    signal enterClass(var classId,var handleStatus);//进入教室 信号
    signal getRecorded(var classId,var nameIndex,var classname);//查看录播
    signal doHomeWork(var classId ,var classIndex, var classNameTitle);//开始做答
    signal goTest(var classId,var classIndex, var classNameTitle);//去考试
    signal getCourse(var classId);

    signal sigRoback();
    property int currentIndexsss: 1;

    property var tipDatas:({
                               isShow:false,
                               executionPlanId:"",
                               handleStatus:""
                           });
    property bool isShowTips: false;

    // handleStatus	"int,操作状态 1：进入教室  2：录播视频未生成 3：录播视频生成 4：待开课 10：待考试 11：未测试 12：去考试 13：已测试 20：开始作答 21：已作答 22：待布置 23：未作答
    function resetDataBuffer(topDataBuffer)
    {

        var listDatas = topDataBuffer.data.list;
        var topDatas = topDataBuffer.data.tops;

        if(listDatas == undefined )
        {
            return;
        }

        var borderCorlor = "";
        courseModel.clear();
        homeworkModel.clear();
        if(!detailItem.visible)
        {
            currentIndexsss = 1;
        }
        for(var b = 0; b < topDatas.length; b++)
        {
            var handleStatusText = "";
            var textColor = "";
            var bgGround = "";
            borderCorlor = "";

            var hs = topDatas[b].handleStatus;
            var buttonEnable = false;
            if( hs == 1 )
            {
                handleStatusText = "进入教室"
                buttonEnable = true;
                textColor = "#ffffff";
                bgGround = "#ff6666";
            }else if( hs == 2 || hs == 3 )
            {
                handleStatusText = "录播生成中"
                textColor = "#aaaaaa";
                bgGround = "#ffffff";
                borderCorlor = "#aaaaaa";
                if(hs == 3)
                {
                    handleStatusText = "查看录播"
                    textColor = "#ff6633";
                    bgGround = "#ffffff";
                    buttonEnable = true;
                    borderCorlor = "#ff6633";
                }
            }else if( hs == 4 )
            {
                handleStatusText = "待开课"
                textColor = "#ff6633";
                bgGround = "#fff9f6";
            }else if( hs == 10 )
            {
                handleStatusText = "待考试"
                textColor = "#773fc6";
                bgGround = "#f9f6ff";
            }else if( hs == 11 )
            {
                handleStatusText = "未考试"
                textColor = "#a888d7";
                bgGround = "#f7f4ff";
            }else if( hs == 12 )
            {
                handleStatusText = "去考试"
                textColor = "#ffffff";
                bgGround = "#ff6666";
                buttonEnable = true;
            }else if( hs == 13 )
            {
                textColor = "#a3a9af";
                bgGround = "#f3f6f9";
                handleStatusText = "已考试"
            }else if( hs == 5 )
            {
                textColor = "#a3a9af";
                bgGround = "#f3f6f9";
                handleStatusText = "已结课"
            }else if( hs == 20 )
            {
                handleStatusText = "开始作答"
                textColor = "#ffffff";
                bgGround = "#ff6666";
                buttonEnable = true;
            }else if( hs == 21 )
            {
                handleStatusText = "已作答"
                textColor = "#80c000";
                bgGround = "#f6ffe3";
            }else if( hs == 22 )
            {
                handleStatusText = "待布置"
                textColor = "#ff6633";
                bgGround = "#fff9f6";
            }else if( hs == 23 )
            {
                handleStatusText = "未作答"
                textColor = "#8d9ccc";
                bgGround = "#f3f6f9";
            }
            if(topDataBuffer.requestType == 0)
            {
                courseModel.append(
                            {
                                highlight: true,
                                classIndex: topDatas[b].className,
                                classNameTitle: topDatas[b].title,
                                startTime:topDatas[b].startTime,
                                endTime: topDatas[b].endTime,
                                executionPlanId: topDatas[b].executionPlanId,
                                isCourseware: topDatas[b].isCourseware,
                                handleStatus: hs,
                                buttonText:handleStatusText,
                                buttonEnable:buttonEnable,
                                tips: topDatas[b].tips,
                                textColor:textColor,
                                bgGround:bgGround,
                                bordersColor:borderCorlor
                            });
            }else
            {
                homeworkModel.append({
                                         highlight: true,
                                         classIndex: topDatas[b].className,
                                         classNameTitle: topDatas[b].title,
                                         startTime:topDatas[b].startTime,
                                         endTime: topDatas[b].endTime,
                                         executionPlanId: topDatas[b].executionPlanId,
                                         isCourseware: topDatas[b].isCourseware,
                                         handleStatus: hs,
                                         buttonText:handleStatusText,
                                         buttonEnable:buttonEnable,
                                         tips: topDatas[b].tips,
                                         textColor:textColor,
                                         bgGround:bgGround,
                                         bordersColor:borderCorlor
                                     });
            }
        }



        for(var a = 0; a < listDatas.length; a++)
        {
            var handleStatusTexts = "";
            var hss = listDatas[a].handleStatus;
            var buttonEnables = false;
            var textColors = "";
            var bgGrounds = "";
            borderCorlor = "";

            if( hss == 1 )
            {
                handleStatusTexts = "进入教室"
                buttonEnables = true;
                textColors = "#ffffff";
                bgGrounds = "#ff6666";
            }else if( hss == 2 || hss == 3 )
            {
                handleStatusTexts = "录播生成中"
                textColors = "#8d9ccc";
                bgGrounds = "#ffffff";
                borderCorlor = "#aaaaaa";
                if(hss == 3)
                {
                    handleStatusTexts = "查看录播"
                    textColors = "#ff6633";
                    bgGrounds = "#ffffff";
                    buttonEnables = true;
                    borderCorlor = "#ff6633";
                }
            }else if( hss == 4 )
            {
                handleStatusTexts = "待开课"
                textColors = "#ff6633";
                bgGrounds = "#fff9f6";
            }else if( hss == 10 )
            {
                handleStatusTexts = "待考试"
                textColors = "#773fc6";
                bgGrounds = "#f9f6ff";
            }else if( hss == 11 )
            {
                handleStatusTexts = "未考试"
                textColors = "#a888d7";
                bgGrounds = "#f7f4ff";
            }else if( hss == 12 )
            {
                handleStatusTexts = "去考试"
                textColors = "#ffffff";
                bgGrounds = "#ff6666";
                buttonEnables = true;
            }else if( hss == 13 )
            {
                handleStatusTexts = "已考试"
                textColors = "#a3a9af";
                bgGrounds = "#f3f6f9";
            }else if( hss == 5 )
            {
                handleStatusTexts = "已结课"
                textColors = "#a3a9af";
                bgGrounds = "#f3f6f9";
            }else if( hss == 20 )
            {
                handleStatusTexts = "开始作答"
                textColors = "#ffffff";
                bgGrounds = "#ff6666";
                buttonEnables = true;
            }else if( hss == 21 )
            {
                handleStatusTexts = "已作答"
                textColors = "#80c000";
                bgGrounds = "#f6ffe3";
            }else if( hss == 22 )
            {
                handleStatusTexts = "待布置"
                textColors = "#ff6633";
                bgGrounds = "#fff9f6";
            }else if( hss == 23 )
            {
                handleStatusTexts = "未作答"
                textColors = "#8d9ccc";
                bgGrounds = "#f3f6f9";
            }
            if(topDataBuffer.requestType == 0)
            {
                courseModel.append(
                            {
                                highlight: false,
                                classIndex: listDatas[a].className,
                                classNameTitle: listDatas[a].title,
                                startTime:listDatas[a].startTime,
                                endTime: listDatas[a].endTime,
                                executionPlanId: listDatas[a].executionPlanId,
                                isCourseware: listDatas[a].isCourseware,
                                handleStatus: hss,
                                buttonText:handleStatusTexts,
                                buttonEnable:buttonEnables,
                                tips: listDatas[a].tips,
                                textColor:textColors,
                                bgGround:bgGrounds,
                                bordersColor:borderCorlor
                            });
                //console.log("ddddddddddddd",courseModel.count,hss)
            }else
            {
                homeworkModel.append({
                                         highlight: false,
                                         classIndex: listDatas[a].className,
                                         classNameTitle: listDatas[a].title,
                                         startTime:listDatas[a].startTime,
                                         endTime: listDatas[a].endTime,
                                         executionPlanId: listDatas[a].executionPlanId,
                                         isCourseware: listDatas[a].isCourseware,
                                         handleStatus: hss,
                                         buttonText:handleStatusTexts,
                                         buttonEnable:buttonEnables,
                                         tips: listDatas[a].tips,
                                         textColor:textColors,
                                         bgGround:bgGrounds,
                                         bordersColor:borderCorlor
                                     })
            }
        }


    }

    onVisibleChanged:
    {
        if(visible)
        {
            //==========================
            //返回按钮, 置为true
            //点击"我的"以后, 如果当前页面的内容是"课程详情", 那么返回按钮的visible, 设置为true
            backArea.visible = true;

            //==========================
            tTtmer.start();
            tipDatas = ({
                            isShow:false,
                            executionPlanId:"",
                            handleStatus:""
                        });
            isShowTips = false;
            var tdata = miniLessonManager.getDoHomeWorkTips(topItemDataBuffer.classId);
            isShowTips = tdata.isShow;
        }else
        {
            tTtmer.stop();
        }
    }

    Timer {
        id:tTtmer
        interval: 300000;
        running: false;
        repeat: true
        onTriggered:
        {
            if(currentIndexsss == 1)
            {
                getListData("0",topItemDataBuffer.classId);
            }else if(currentIndexsss == 2)
            {
                getListData("1",topItemDataBuffer.classId);
            }

            var  tdata = miniLessonManager.getDoHomeWorkTips(topItemDataBuffer.classId);
            isShowTips = tdata.isShow;
        }
    }

    Rectangle
    {
        anchors.fill: parent
        color: "white"
        radius: 12
    }
    MouseArea
    {
        anchors.fill: parent
        onClicked:
        {
            return;
        }
    }

    //返回按钮(现在这个已经不需要了, 隐藏掉)
    Rectangle
    {
        id: backRec
        width: 25 * widthRate
        height: 25 * widthRate
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 5 * widthRate
        anchors.leftMargin: 5 * widthRate
        visible: false

        Image {
            anchors.fill: parent
            source: "qrc:/miniClassImg/xbk_btn_back@2x.png"
        }
        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                parent.parent.visible = false;
            }
        }
    }

    Rectangle
    {
        width: parent.width * 0.9
        height: parent.height * 0.924
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:parent.top
        anchors.topMargin: 5 * widthRate //backRec.height + 8 * widthRates
        //color: "lightblue"

        Item{//头内容展示
            id: headRec
            width: parent.width
            height: parent.height * 0.165

            Image {
                id: lessonImg
                width: height * 1.756
                height: parent.height
                anchors.left: parent.left
                anchors.leftMargin: 10 * heightRate
                source: topItemDataBuffer.bigCoverUrl == undefined ? "" : topItemDataBuffer.bigCoverUrl
                anchors.verticalCenter: parent.verticalCenter
                sourceSize.width: width
                sourceSize.height: height
                asynchronous: true
            }

            Text{
                id: classText
                anchors.top: parent.top
                //anchors.topMargin: 5 * heightRate
                anchors.left: lessonImg.right
                anchors.leftMargin: 20 * heightRate
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 17 * widthRates
                text: topItemDataBuffer.name == undefined ? "" : topItemDataBuffer.name
            }

            Column{
                width: parent.width * 0.4
                height: parent.height - 20 * heightRate
                anchors.left: lessonImg.right
                anchors.leftMargin: 20 * heightRate
                anchors.top: classText.bottom
                anchors.topMargin: 22 * heightRate
                spacing: 15 * heightRate

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 17 * heightRate
                    text: qsTr("开课时间：") + topItemDataBuffer.categoryName
                    color: "#666666"
                }

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 17 * heightRate
                    text: qsTr("上课时段：") + topItemDataBuffer.startTime + "-" + topItemDataBuffer.endTime
                    color: "#666666"
                }
            }

            //头像和老师名称
            Item{
                id: headButton
                width: 55 * heightRate
                height: 55 * heightRate
                visible: true
                anchors.right: parent.right
                anchors.rightMargin: 130 * widthRates
                anchors.bottom: parent.bottom
                //anchors.bottomMargin: 10 *widthRates

                Rectangle{
                    id: rundItem
                    radius: 100
                    width: 55 * heightRate
                    height: 55 * heightRate
                    anchors.centerIn: parent
                }

                Image{
                    id: headImage
                    visible: false
                    width: 55 * heightRate
                    height: 55 * heightRate
                    sourceSize.width: 55 * heightRate
                    sourceSize.height: 55 * heightRate
                    anchors.centerIn: parent
                    source: topItemDataBuffer.headImagUrl == "" ? "qrc:/miniClassImg/defult_profile.png" : topItemDataBuffer.headImagUrl
                    smooth: false
                }

                OpacityMask{
                    anchors.fill: rundItem
                    source: headImage
                    maskSource: rundItem
                }

                Text{
                    text: topItemDataBuffer.teachText
                    anchors.left: rundItem.right
                    anchors.leftMargin: 10 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 10 * widthRates
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#666666"
                }
            }

        }

        Image {
            id:tipsImgs
            width: 100 * widthRates
            height: width / 3.611
            source: "qrc:/miniClassImg/xbk_stats_hint.png"
            anchors.top: headRec.bottom
            anchors.topMargin: 15 * widthRates
            anchors.left: parent.left
            anchors.leftMargin: rowsOne.width / 3
            visible: isShowTips
            Text {
                anchors.centerIn: parent
                text: qsTr("有作业等待做答哦~")
                color: "white"
                font.family: Cfg.LEAVE_FAMILY
                font.pixelSize: 10 * widthRates
                height: parent.height /1.4
            }
        }
        Row {
            id:rowsOne
            height: 20 * widthRates
            width: parent.width * 0.427
            spacing: 2 * widthRates
            anchors.top:headRec.bottom
            anchors.topMargin: 40 * widthRates

            Rectangle
            {
                width: parent.width * 0.3
                height:width * 0.363
                Text {
                    id:text2
                    text: qsTr("课表")
                    color:currentIndexsss == 1 ? "#ff6633" : "#666666"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: 13 * widthRates
                }

                Rectangle
                {
                    width: 26 * widthRates
                    height: 2 * widthRates
                    anchors.top: text2.bottom
                    anchors.topMargin: 5 * widthRates
                    color: currentIndexsss == 1 ? "#ff6633" : "transparent"
                }

                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {

                        if(currentIndexsss != 1)
                        {
                            getListData("0",topItemDataBuffer.classId);
                        }

                        currentIndexsss = 1;
                    }
                }

            }

            Rectangle
            {
                width: parent.width * 0.3
                height:width * 0.363
                Text {
                    id:text3
                    text: qsTr("作业")
                    color:currentIndexsss == 2 ? "#ff6633" : "#666666"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: 13 * widthRates
                }
                Rectangle
                {
                    width: 26 * widthRates
                    height: 2 * widthRates
                    anchors.top: text3.bottom
                    anchors.topMargin: 5 * widthRates
                    color: currentIndexsss == 2 ? "#ff6633" : "transparent"
                }
                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        if(currentIndexsss != 2)
                        {
                            getListData("1",topItemDataBuffer.classId);
                        }
                        currentIndexsss = 2;
                    }
                }

            }

        }        

        Rectangle{
            width: parent.width
            height: 1
            anchors.top: rowsOne.bottom
            anchors.topMargin: 5 * widthRates
            color: "#eeeeee"
        }

        ListView{
            id: courseView
            clip: true
            width: parent.width
            height: parent.height - headRec.height - rowsOne.height - 60 * widthRates
            anchors.top: rowsOne.bottom
            anchors.topMargin: 10 * widthRates
            model: courseModel
            delegate: courseComponent
            visible: currentIndexsss == 1
        }

        ListView{
            id: homeWorkView
            clip: true
            width: parent.width
            height: parent.height - headRec.height - rowsOne.height - 60 * widthRates
            anchors.top: rowsOne.bottom
            //anchors.topMargin: 20 * widthRates
            model: homeworkModel
            delegate: homeWorkComponent
            visible: currentIndexsss == 2
        }

        Rectangle
        {
            id:noLessonItem
            width: parent.width - 20 * widthRates
            height: parent.height - headRec.height - rowsOne.height - 100 * widthRates
            anchors.top: rowsOne.bottom
            anchors.topMargin: 20 * widthRates
            color: "white"
            radius: 12
            z:100
            visible: currentIndexsss == 2 && homeworkModel.count <= 0
            Rectangle
            {
                color: "transparent"
                width: parent.width * 0.5
                height: parent.height * 0.5
                anchors.centerIn: parent

                Image {
                    id:noLessonImage
                    width: 161 * widthRates
                    height: 161 * widthRates * (300 / 342) //342 和 300是图片: bg_kong.png 对应的实际宽度高度
                    source: "qrc:/miniClassImg/bg_kong.png"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 17 * heightRate
                    color: "#666666"
                    text: "暂时没有作业哦~~"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top:noLessonImage.bottom
                    anchors.topMargin: -15 * widthRates
                }
            }
        }
    }

    ListModel{
        id: courseModel
    }

    ListModel{
        id: homeworkModel
    }

    Component{
        id: courseComponent
        Item{
            width: courseView.width
            height: 130 * heightRate

            Rectangle{
                anchors.fill: parent
                color: "#fffef9"
                visible: highlight
            }

            Text {
                id: numberText
                color: highlight ? "#ff6633" : "#bbbbbb"
                text: classIndex
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 18 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: 20 * heightRate
                anchors.verticalCenter: parent.verticalCenter
            }

            Row{
                id: rowOne
                width: parent.width * 0.5
                anchors.left: numberText.right
                anchors.leftMargin: 35 * heightRate
                anchors.top: parent.top
                anchors.topMargin: 35 * heightRate
                spacing: 10 * heightRate


                Image{
                    id: examImg
                    width: 25 * heightRate * (276 / 88) //276 和 88 是图片: xbk_icon_commingsoon.png对应的实际的宽高
                    height: 25 * heightRate
                    visible: index == 0 && handleStatus == 1
                    source: handleStatus == 1 ? "qrc:/miniClassImg/xbk_icon_commingsoon.png" : ""
                }

                Text {
                    text: classNameTitle
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 18 * heightRate
                }
            }

            Text {
                text: analysisTime(startTime,endTime)
                color: "#666666"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 15 * heightRate
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 30 * heightRate
                anchors.left: numberText.right
                anchors.leftMargin: 35 * heightRate
            }

            MouseArea{
                width: 120 * heightRate
                height: 42 * heightRate
                anchors.right: parent.right
                //anchors.rightMargin: 120 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                cursorShape: Qt.PointingHandCursor
                enabled: buttonEnable

                onClicked:
                {
                    console.log("===handleStatus===",handleStatus);
                    miniLessonManager.setQosStartTime(startTime,endTime);
                    if(handleStatus == 1)
                    {
                        windowView.isMiniClassroom = true;
                        enterClass(executionPlanId,handleStatus);
                    }else if(handleStatus == 3)
                    {
                        getRecorded(executionPlanId,classIndex,classNameTitle)
                    }else if(handleStatus == 12)
                    {
                        goTest(executionPlanId,classIndex,classNameTitle)
                    }
                }

                Rectangle{
                    anchors.fill: parent
                    color: bgGround
                    radius: 24 * heightRate
                    border.width: bordersColor == "" ? 0 : 1
                    border.color: bordersColor
                }

                Image {
                    visible: handleStatus == 3
                    height: parent.height * 0.5
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 7 * widthRates
                    source: "qrc:/miniClassImg/xbk_inco_play.png"
                }

                Text {
                    text: buttonText
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 16 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: handleStatus == 3 ? 12 * widthRates : (parent.width - width ) / 2
                    z:5
                    color: textColor
                }
            }

            MouseArea{
                width: 120 * heightRate
                height: 42 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: 150 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                cursorShape: Qt.PointingHandCursor
                enabled: isCourseware
                visible: handleStatus == 4
                Rectangle{
                    anchors.fill: parent
                    color:  "white"
                    radius: 24 * heightRate
                    // border.color: ""
                }
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    source: "qrc:/miniClassImg/xbk_inco_checkfile@2x.png"
                }
                Text {
                    text: "查看课件"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 16 * heightRate
                    anchors.centerIn: parent
                    color: "#ff6633"//isCourseware ? "white" : "#8d9ccc"
                }

                onClicked:
                {
                    console.log("isCourseware",isCourseware)
                    getCourse(executionPlanId);
                }

            }

            Rectangle
            {
                width: parent.width
                height: 1
                color: "#f3f6f9"
                anchors.bottom: parent.bottom

            }
        }
    }

    Component{
        id: homeWorkComponent
        Item{
            width: courseView.width
            height: 130 * heightRate

            Rectangle{
                anchors.fill: parent
                color: "#fffef9"
                visible: highlight
            }

            Text {
                id: numberText
                color: highlight ? "#ff6633" : "#bbbbbb"
                text: classIndex
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 18 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: 20 * heightRate
                anchors.verticalCenter: parent.verticalCenter
            }

            Row{
                id: rowOne
                width: parent.width * 0.5
                anchors.left: numberText.right
                anchors.leftMargin: 35 * heightRate
                anchors.top: parent.top
                anchors.topMargin: 35 * heightRate
                spacing: 10 * heightRate


                Image{
                    id: examImg
                    width: 52 * heightRate
                    height: 25 * heightRate
                    visible: index == 0 && handleStatus == 10
                    source: "qrc:/miniClassImg/xbk_icon_exam.png"
                }

                Text {
                    text: classNameTitle
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 18 * heightRate
                }
            }

            Text {
                text: analysisTime(startTime,endTime)
                color: "#666666"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 15 * heightRate
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 30 * heightRate
                anchors.left: numberText.right
                anchors.leftMargin: 35 * heightRate
            }

            MouseArea{
                width: 120 * heightRate
                height: 42 * heightRate
                anchors.right: parent.right
                //anchors.rightMargin: 120 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                cursorShape: Qt.PointingHandCursor
                enabled: buttonEnable

                Rectangle{
                    anchors.fill: parent
                    color: bgGround
                    radius: 24 * heightRate
                    border.width: bordersColor == "" ? 0 : 1
                    border.color: bordersColor
                }

                Text {
                    text: buttonText
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 15 * heightRate
                    anchors.centerIn: parent
                    color: textColor
                }

                onClicked:
                {
                    if(handleStatus == 20)
                    {
                        doHomeWork(executionPlanId,classIndex,classNameTitle);
                    }
                }

            }

            Rectangle
            {
                width: parent.width
                height: 1
                color: "#f3f6f9"
                anchors.bottom: parent.bottom

            }
        }
    }
    function analysisDate(startTime){
        var currentStartDate = new Date(startTime);
        var year = currentStartDate.getFullYear();
        var month = Cfg.addZero(currentStartDate.getMonth() + 1);
        var day = Cfg.addZero(currentStartDate.getDate());
        var tepmW = currentStartDate.getDay() ;
        var week;
        if(tepmW == 0)
        {
            week = "周日"
        }else if(tepmW == 1)
        {
            week = "周一"
        }else if(tepmW == 2)
        {
            week = "周二"
        }else if(tepmW == 3)
        {
            week = "周三"
        }else if(tepmW == 4)
        {
            week = "周四"
        }else if(tepmW == 5)
        {
            week = "周五"
        }else if(tepmW == 6)
        {
            week = "周六"
        }

        return year + "年" + month + "月" + day + "日  " + week + " ";
    }

    function analysisTime(startTime,endTime){
        var date = analysisDate(startTime);
        var currentStartDate = new Date(startTime);
        var currentEndDate = new Date(endTime);
        var sTime = Cfg.addZero(currentStartDate.getHours()) + ":" + Cfg.addZero(currentStartDate.getMinutes());
        var eTime = Cfg.addZero(currentEndDate.getHours()) + ":" + Cfg.addZero(currentEndDate.getMinutes());
        return date + " " + sTime + "-" + eTime;
    }

    Component.onCompleted: {
        for(var i = 0; i < 10; i++){

            if(i == 0)
            {
                topItemDataBuffer = (
                            {
                                "bigCoverUrl":"",
                                "name":"l啦啦啦啦拉拉风的减肥了肯定送积分金飞达",
                                "categoryName":"20180115",
                                "startTime":"sssssfd",
                                "endTime":"sddddqww",
                                "headImagUrl":"",
                                "teachText":""
                            }
                            )
            }

        }
    }

}
