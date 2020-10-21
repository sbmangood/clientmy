﻿import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQml.Models 2.2
import QtGraphicalEffects 1.0
import "Configuration.js" as Cfg
import QtQuick.Window 2.0

//主教室, 右侧, "课程表", "全部课程", 直播课, "提醒", "学生头像"
Item {
    id: navigationView

    property int activeIndex: -1;
    property int activeSubIndex: -1;
    property int checkNumber: 0;

    property bool clearModel: false;
    property var linkManData: [];

    property string keyWord: "-1";
    property string teacherName: "老师账号";
    property int messageCount: 0;
    property string headPicture: "qrc:/images/index_profile_defult@2x.png";

    property double  widthRate : windowView.widthRate;
    property double   heightRate : windowView.heightRate;
    property double newRate: widthRate * 0.9
    signal sigExitMiniClass(var index);

    onClearModelChanged: {
        if(clearModel){
            viewListModel.clear();
        }
    }

    Timer{
        id: stageTimer
        interval: 1500
        running: false
        onTriggered: {
            checkNumber = 0;
        }
    }

    Item{
        id: listViewArea
        width: (Cfg.NAV_LINE_HEIGHT) * widthRate
        height: parent.height
        anchors.left: parent.left

        Item{
            width: 118 * newRate
            height: windowView.width == Screen.width ? parent.height * 0.725 : parent.height * 0.71
            anchors.left: parent.left
            anchors.top:parent.top
            anchors.leftMargin: 7 * newRate
            anchors.topMargin: 201 * newRate

            Image{//背景图
                anchors.fill: parent
                source: "qrc:/images/index_bg_leftbar@2x.png"
            }
            //显示版本和logo
            Item{
                id: logoItem
                width: parent.width
                height: Cfg.NAV_LINE_HEIGHT * heightRate
                visible: false
                Image{
                    id: logoImg
                    width:  45 * heightRate
                    height: 45 * heightRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: (parent.height - height - 20 * heightRate) * 0.5
                    source: "qrc:/images/classlogo.png"
                }
                MouseArea{
                    width: parent.width
                    height: 32 * heightRate
                    anchors.top:  logoImg.bottom
                    anchors.topMargin: 8

                    Text{
                        text: title
                        width: parent.width
                        font.family: Cfg.Menu_family
                        font.pixelSize:  (Cfg.Menu_MinPixelSize -1) * heightRate
                        color: Cfg.Menu_defaultColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: {
                        stageTimer.restart();
                        checkNumber++;
                        if(checkNumber >= 5){
                            stagePwdView.visible = true;
                            checkNumber = 0;
                        }
                    }
                }
            }

            Rectangle
            {
                width: parent.width * 0.35
                height: width / 2
                anchors.bottom: navigationBarArea.top
                color: "transparent"
                anchors.horizontalCenter: parent.horizontalCenter
                z:100
                visible: false// navigationBarArea.height < navigationBarArea.contentHeight
                Image {
                    anchors.fill: parent
                    source: mous.containsMouse ? "qrc:/miniClassImg/leftbar_btn_up_hover.png" :"qrc:/miniClassImg/leftbar_btn_up.png"
                }
                MouseArea
                {
                    id:mous
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked:
                    {
                        console.log(navigationBarArea.contentY,navigationBarArea.contentHeight,navigationBarArea.height)
                        if(navigationBarArea.height >=navigationBarArea.contentHeight)
                        {
                            return;
                        }
                        navigationBarArea.contentY = navigationBarArea.contentY + 20;
                    }

                }
            }

            YMNavigationMappingView
            {
                id:navigationMappingView
                visible: mainView.visible
                width: parent.width -  10 * heightRate
                height: parent.height - logoItem.height - headButton.height
                clip: true
                anchors.top: parent.top
                anchors.topMargin: 15 * widthRate
                anchors.horizontalCenter: parent.horizontalCenter
                onShowCurrentClickView:
                {
                    navigation.setActiveView(currentView,0);
                }

                Component.onCompleted:
                {
                    var tempArray = [];
                    tempArray.push({"indexTitle":"课程表",
                                       "outIndex": 0});
                    tempArray.push({"indexTitle":"课程列表",
                                       "outIndex": 1});
                    addView("1对1辅导","qrc:/images/yiduiyi@2x.png",
                            "qrc:/images/yiduiyiSelect@2x.png",tempArray,true);


//                    tempArray = [];
//                    tempArray.push({"indexTitle":"选课",
//                                       "outIndex": 3});
//                    tempArray.push({"indexTitle":"课程列表",
//                                       "outIndex": 7});

//                    addView("小组课","qrc:/images/kecheng@2x.png",
//                            "qrc:/images/kechengselect@2x.png",tempArray,false);

//                    tempArray = [];
//                    tempArray.push({"indexTitle":"选课",
//                                       "outIndex": 2});
//                    addView("公开课","qrc:/images/gongkaike@2x.png",
//                            "qrc:/images/gongkaikeselect@2x.png",tempArray,false);

//                    tempArray = [];
//                    tempArray.push({"indexTitle":"提醒",
//                                       "outIndex": 4});
//                    tempArray.push({"indexTitle":"SQ学商",
//                                       "outIndex": 5});
//                    tempArray.push({"indexTitle":"课程规划",
//                                       "outIndex": 6});
//                    addView("学习助手","qrc:/images/zhushou@2x.png",
//                            "qrc:/images/zhushouselsect@2x.png",tempArray,false);

                }
            }

            ListView {
                id: navigationBarArea
                width: parent.width
                height: parent.height - logoItem.height - headButton.height
                clip: true
                anchors.top: logoItem.bottom
                anchors.topMargin: 10 * widthRate
                boundsBehavior: ListView.StopAtBounds
                model: viewListModel
                delegate: navigationItemDelegate
                visible: false
            }

            Rectangle
            {
                width: parent.width * 0.35
                height: width / 2
                anchors.top: navigationBarArea.bottom
                color: "transparent"
                anchors.horizontalCenter: parent.horizontalCenter
                z:100
                visible: false// navigationBarArea.height < navigationBarArea.contentHeight
                Image {
                    anchors.fill: parent
                    source: mouss.containsMouse ? "qrc:/miniClassImg/lefttoolbar_btn_down_sed.png" :"qrc:/miniClassImg/leftbar_btn_down.png"
                }
                MouseArea
                {
                    id:mouss
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked:
                    {
                        console.log(navigationBarArea.contentY)
                        if(navigationBarArea.contentY <= 0)
                        {
                            navigationBarArea.contentY = 0;
                            return;
                        }
                        navigationBarArea.contentY = navigationBarArea.contentY - 20;
                    }

                }
            }

        }
    }

    //学生头像信息
    Item{
        id: headButton
        width: 118 * newRate
        height: 150 * newRate
        anchors.left: parent.left
        anchors.top:parent.top
        anchors.leftMargin: 6 * newRate
        anchors.topMargin: 64 * newRate

        Image{//背景图
            anchors.fill: parent
            source: "qrc:/images/index_bg_leftbar@2x.png"
        }

        Rectangle{
            id: rundItem
            radius: 100
            width: 76 * newRate
            height: width
            anchors.top: parent.top
            anchors.topMargin: 22 * newRate
            anchors.horizontalCenter: parent.horizontalCenter
            Image{
                anchors.fill: parent
                source: "qrc:/images/index_profile_defult@2x.png"
            }
        }

        Image{
            id: headImage
            visible: false
            width: 76 * newRate
            height: width
            anchors.top: parent.top
            anchors.topMargin: 22 * newRate
            anchors.horizontalCenter: parent.horizontalCenter
            source: headPicture == "" ? "qrc:/images/index_profile_defult@2x.png" : headPicture
            smooth: false

            onStatusChanged: {
                if(status == Image.Error){
                    headPicture = "qrc:/images/index_profile_defult@2x.png"
                    towImg.visible = false;
                }
                if(status == Image.Loading){
                    towImg.visible = true;
                }
            }

            onProgressChanged: {
                if(headPicture != "" && progress == 0){
                    towImg.visible = true;
                }
                if(headPicture != "" && progress == 1){
                    towImg.visible = false;
                }
            }

            Image{
                id: towImg
                anchors.fill: parent
                source: "qrc:/images/index_profile_defult@2x.png"
            }
        }

        OpacityMask{
            cached: true
            anchors.fill: rundItem
            source: headImage
            maskSource: rundItem
            antialiasing: true
        }

        Text {
            id: userNameText
            height: 10 * heightRate
            width: parent.width * 0.8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 31 * newRate
            font.bold: Cfg.Menu_bold
            font.family: Cfg.Menu_family
            font.pixelSize: Cfg.Menu_pixelSize * heightRate
            color: Cfg.Menu_defaultColor
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            text: isStudentUser ? teacherName : teacherName  + "家长"
        }
    }



    Rectangle {
        id: loaderArea
        z: 99998
        //border.color: "red"
        //border.width: 1
        //radius: 12
        width: parent.width / (1000 / 862) - 2 * newRate
        height: parent.height / (660 / 580)
        anchors.top: parent.top
        anchors.topMargin: 70 * newRate
        anchors.left: listViewArea.right
        anchors.leftMargin: 17 * widthRate

        Loader {
            id: mainViewLoader
            asynchronous: false
            width: parent.width - 2
            height: parent.height -2
            anchors.centerIn: parent
            clip: true
        }

        Connections{
            target: mainViewLoader.item
            onTransferPage: {
                requstStatus = true
                keyWord = pram
            }
        }

        Loader {
            id: loaderCoach
            asynchronous: false
            width: parent.width - 2
            height: parent.height -2
            anchors.centerIn: parent
            clip: true
        }
        Connections{
            target: loaderCoach.item
            onTransferPage: {
                requstStatus = true
                keyWord = pram
            }
        }

        Loader {
            id: loaderMassge
            asynchronous: false
            width: parent.width - 2
            height: parent.height -2
            anchors.centerIn: parent
            clip: true
        }
                Connections{
                    target: loaderMassge.item
                    onTransferPage: {
                        requstStatus = true
                        keyWord = pram
                    }
                }

        Loader{
            id: sqLoader
            asynchronous: false
            width: parent.width - 2
            height: parent.height -2
            anchors.centerIn: parent
            clip: true
        }

        Loader{
            id: miniClassLoader
            asynchronous: false
            width: parent.width - 2
            height: parent.height -2
            anchors.centerIn: parent
            clip: true
        }

        Loader{
            id: newMiniClassLoader
            asynchronous: false
            width: parent.width - 2
            height: parent.height -2
            anchors.centerIn: parent
            clip: true
        }

    }

    ListModel {
        id: viewListModel
    }

    Component {
        id: navigationItemDelegate

        ListView {
            id: navigationListView
            width: parent.width
            //设置左侧导航收起和被显示的时候的高度
            height: collapsed ? (Cfg.NAV_LINE_HEIGHT *heightRate) : (Cfg.NAV_LINE_HEIGHT * heightRate) * (choices.count + 1)
            interactive: false
            clip: true
            model: choices

            header: MouseArea {
                width: parent.width
                height: parent.width//Cfg.NAV_LINE_HEIGHT
                hoverEnabled:  true
                cursorShape: Qt.PointingHandCursor
                x: (parent.width - width) * 0.5

                Rectangle{
                    height: parent.height -2
                    width: parent.height - 4
                    anchors.centerIn: parent
                    color: "white"
                    visible: selected
                }

                Image{
                    id: collapsedImage
                    width:  26 * heightRate
                    height:   26 * heightRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 24 * heightRate
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    source: selected ? selectedIcon  : icon
                }

                Text {
                    id: headText
                    height: 30 * heightRate
                    anchors.top:  collapsedImage.bottom
                    anchors.topMargin:  8 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.bold: Cfg.Menu_bold
                    font.family: Cfg.Menu_family
                    font.pixelSize: Cfg.Menu_pixelSize * heightRate
                    color:  selected ? Cfg.Menu_selecteColor :  Cfg.Menu_defaultColor
                    text: title
                }

                Image{
                    z: 3
                    width: 25 * heightRate
                    height: 18 * heightRate
                    anchors.left: collapsedImage.left
                    anchors.leftMargin: collapsedImage.width * 0.45 * widthRate
                    anchors.bottom: collapsedImage.bottom
                    anchors.bottomMargin:  20 * heightRate
                    smooth: true
                    source: "qrc:/images/index_msg_reddot@2x.png"
                    visible:  index == 4 ?  (messageCount > 0 ? true : false) : false
                }
                Text{
                    z: 4
                    text: messageCount
                    width:  25 * heightRate
                    height: 15 * heightRate
                    color: "white"
                    font.family: Cfg.DEFAULT_FONT
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.left: collapsedImage.left
                    anchors.leftMargin: collapsedImage.width * 0.45 * widthRate
                    anchors.bottom: collapsedImage.bottom
                    anchors.bottomMargin:  22 * heightRate
                    font.pixelSize: 8 * widthRate
                    visible: index == 4 ?  (messageCount > 0 ? true : false) : false
                    onVisibleChanged: {
                        if(visible == false && index == 4){
                            tipsView.visible = false;
                        }
                    }
                }

                onClicked: {
                    if(isMiniClassroom){
                        if(activeIndex == index){
                            return;
                        }

                        sigExitMiniClass(index);
                        return;
                    }
                    updateSelected(index);
                    setActiveView(index,0);
                }
            }
        }
    }

    //垂直显示
    function addView(title, template,icons,selectedIcon){
        viewListModel.append(
                    {
                        "title": title,
                        "template": template,
                        "choices": [],
                        "collapsed": false,
                        "icon": icons,
                        "selectedIcon": selectedIcon,
                        "selected": false,
                    });
    }

    //树形显示
    function addViewGroup(title, choices, templates, icons){
        var temp = [];
        for (var i = 0; i < choices.length && i < templates.length; i++){
            temp.push({
                          "navIndex": viewListModel.count,
                          "title": choices[i],
                          "template": templates[i],
                          "icon": icons[i],
                      });
        }

        viewListModel.append(
                    {
                        "title": title,
                        "template": "",
                        "choices": temp,
                        "collapsed": true,
                        "icon": "",
                    });
    }

    //设置选中子节点
    function setActiveView(index, subindex){
        console.log("setActiveView1",index,activeIndex,subindex,activeSubIndex);

        if(index == 2 && subindex == 0 ){
            //直播课
            var url = URL_LiveLesson;
            console.log(url);
            Qt.openUrlExternally(url)
        }

        if(index == 6 && subindex == 0 ){//上线的时候去掉 stage-
            //课程规划
            var url = URL_Plan + userId + "&token=" + token;
            console.log(url);
            Qt.openUrlExternally(url)
        }

        if (activeIndex === index && activeSubIndex === subindex
                && exitRequest){
            console.log("setActiveView1");
            if(index != 1 || subindex != 0 || requstStatus != true )
            {
                return;
            }
        }
        if (viewListModel.count <= index){
            console.log("setActiveView2");
            return;
        }
        //var viewGroup = viewListModel.get(index).choices;
        console.log("viewGroup:",index,subindex,exitRequest)
        activeIndex = index;
        activeSubIndex = subindex;
        viewListModel.get(index).collapsed = false;


        if(index == 1 && subindex == 0){
            //课程列表
            loaderCoach.source = "qrc:/studentcoach/YMStudentCoachView.qml"
            loaderCoach.item.keywords = keyWord
            loaderCoach.item.currentDate = Cfg.getCurrentDate();
            loaderCoach.item.pageIndex = 1;
            console.log("requstStatus",requstStatus,keyWord,loaderCoach.item.pageIndex);
            if(requstStatus){
                loaderCoach.item.currentDate = "";
                loaderCoach.item.currentEndDate = "";
                loaderCoach.item.queryPeriod = "ALL";
            }
            loaderCoach.visible = true;
            loaderMassge.visible = false;
            mainViewLoader.visible = false;
            sqLoader.visible = false;
            miniClassLoader.visible = false;
            miniClassLoader.focus = false;
            newMiniClassLoader.visible = false;
            loaderCoach.focus = true;
            loaderMassge.focus = false;
            mainViewLoader.focus = false;
            requstStatus = false;
            loaderCoach.item.queryData();
        }
        if(index == 4 && subindex == 0){
            loaderMassge.source = "qrc:/studentMessageTips/YMMassgeView.qml"
            loaderMassge.visible = true;
            loaderCoach.visible = false;
            mainViewLoader.visible = false;
            mainViewLoader.focus = false;
            loaderMassge.focus = true;
            loaderCoach.focus = false;
            sqLoader.visible = false;
            newMiniClassLoader.visible = false;
            miniClassLoader.visible = false;
            miniClassLoader.focus = false;
            loaderMassge.item.queryData();
        }
        if(index == 0 && subindex == 0){
            //课程表
            navigationMappingView.updateSelectIndex(index);
            mainViewLoader.source = ":/../JRMainView/YMMiniMainView.qml"
            mainViewLoader.visible = true;
            mainViewLoader.focus=true;
            loaderCoach.visible = false;
            loaderMassge.visible = false;
            loaderCoach.focus=false;
            loaderMassge.focus=false;
            sqLoader.visible = false;
            newMiniClassLoader.visible = false;
            miniClassLoader.visible = false;
            miniClassLoader.focus = false;
            if(!exitRequest){
                mainViewLoader.item.currentDate = Cfg.getCurrentDates();
            }
            mainViewLoader.item.queryData();
        }

        //SQ学商
        if(index == 5){
            sqLoader.visible = true;
            loaderCoach.visible = false;
            loaderMassge.visible = false;
            loaderCoach.focus=false;
            loaderMassge.focus=false;
            newMiniClassLoader.visible = false;
            miniClassLoader.visible = false;
            miniClassLoader.focus = false;

            sqLoader.source =  viewListModel.get(index).template;
            sqLoader.item.queryData();
        }

        //"小班课"
        if(index == 3){
            miniClassLoader.source = "qrc:/miniClass/YMMiniClassList.qml"
            loaderMassge.visible = false;
            loaderCoach.visible = false;
            mainViewLoader.visible = false;
            mainViewLoader.focus = false;
            loaderMassge.focus = false;
            loaderCoach.focus = false;
            sqLoader.visible = false;
            newMiniClassLoader.visible = false;
            miniClassLoader.visible = true;
            miniClassLoader.focus = true;
            miniClassLoader.item.queryData();
        }

        if(index == 7){
            newMiniClassLoader.source = ":/../YMMiniHomePage/YMMiniMainView.qml"
            loaderMassge.visible = false;
            loaderCoach.visible = false;
            mainViewLoader.visible = false;
            mainViewLoader.focus = false;
            loaderMassge.focus = false;
            loaderCoach.focus = false;
            sqLoader.visible = false;
            miniClassLoader.visible = false;
            newMiniClassLoader.visible = true;
            newMiniClassLoader.focus = true;
            newMiniClassLoader.item.queryData()
        }

        updateSelected(index);
        keyWord = "";
    }

    //根据当前项来刷新页面数据
    function getActiveView(){
        if(activeIndex == 0 && activeSubIndex == 0){ //课程表
            mainViewLoader.item.refreshPage();
            return;
        }

        if(activeIndex == 1 && activeSubIndex == 0){ //全部课程
            loaderCoach.item.refreshPage();
            return;
        }

        if(activeIndex == 3 && activeSubIndex == 0){ //小班课
            miniClassLoader.item.refreshPage();
            return;
        }

        if(activeIndex == 4){ //提醒
            loaderMassge.item.refreshPage();
            return;
        }

        if(activeIndex == 5){//SQ学商
            sqLoader.item.refreshPage();
            return;
        }
        if(activeIndex == 7){
            newMiniClassLoader.item.refreshPage();
            return;
        }
    }

    //页面跳转传参
    function pageTransferParm(index,subIndex){
        setActiveView(index,subIndex)
        console.log("pageTransferParm",index,subIndex);
    }
    //展开折叠
    function updateCollasped(index){
        for(var i = 0; i < viewListModel.count;i++){
            if(i === index){
                var collapsed = viewListModel.get(i).collapsed;
                if(collapsed === true){
                    collapsed = false;
                }else{
                    collapsed = true;
                }
                viewListModel.get(i).collapsed = collapsed;
                break;
            }
        }
    }
    //选中状态
    function updateSelected(index){
        for(var i = 0; i < viewListModel.count;i++){
            if(i === index){
                viewListModel.get(i).selected = true;
            }else{
                viewListModel.get(i).selected = false;
            }
        }
    }
}


