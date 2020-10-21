import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQml.Models 2.2
import "Configuration.js" as Cfg
import QtGraphicalEffects 1.0
import QtQuick.Window 2.0

Item {
    id: navigationView

    property int activeIndex: -1;
    property int activeSubIndex: -1;
    property int checkNumber: 0;

    property string teacherName: "";
    property string headPicture: "";
    property double newRate: widthRate * 0.9

    property Component navigationItemDelegate: null
    property bool clearModel: false;

    signal showCloseOrderView(var id);
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

    Item{//左侧各界面导航区域
        id: listViewArea
        width: Cfg.NAV_LINE_HEIGHT * widthRate
        height: parent.height
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
                        font.pixelSize:  Cfg.Menu_MinPixelSize * heightRate
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

            ListView {
                id: navigationBarArea
                width: parent.width
                height: parent.height - logoItem.height - headButton.height
                clip: true
                anchors.top: logoItem.bottom
                boundsBehavior: ListView.StopAtBounds
                model: viewListModel
                delegate: navigationItemDelegate

                visible: false
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
                    //                    tempArray.push({"indexTitle":"课程列表",
                    //                                       "outIndex": 3});

                    //                    addView("小组课","qrc:/images/kecheng@2x.png",
                    //                            "qrc:/images/kechengselect@2x.png",tempArray,false);


                    //                    tempArray = [];
                    //                    tempArray.push({"indexTitle":"溢米教研",
                    //                                       "outIndex": 2});
                    //                    addView("教学助手","qrc:/images/zhushou@2x.png",
                    //                            "qrc:/images/zhushouselsect@2x.png",tempArray,false);

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
                    headImage.source = "qrc:/images/index_profile_defult@2x.png"
                }
            }

        }

        OpacityMask{
            anchors.fill: rundItem
            source: headImage
            maskSource: rundItem
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
            text: teacherName
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
//        MouseArea{
//            anchors.fill: parent
//            cursorShape: Qt.PointingHandCursor
//            onClicked: {
//                //老师端主程序	点击: 左下角图标, Mis链接
//                var url = URL_Mis + userName + "&pwd=" + password
//                console.log(url);
//                Qt.openUrlExternally(url);
//            }
//        }
    }


    Rectangle {//主界面加载其他跳转界面的区域
        id: loaderArea
        z: 98
        //border.color: "#e0e0e0"
        //border.width: 1
        //radius: 12 * heightRate
        width: parent.width / (1000 / 862) - 2 * newRate
        height: parent.height / (660 / 580)
        anchors.top: parent.top
        anchors.topMargin: 70 * newRate
        anchors.left: listViewArea.right
        anchors.leftMargin: 17 * widthRate
        //加载课程表
        Loader {
            id: lessonTableLoader
            width: parent.width - 2
            height: parent.height -2
            clip: true
            focus: true
            visible: false
        }
        //加载课程列表
        Loader{
            id: lessonListLoader
            width: parent.width - 2
            height: parent.height -2
            clip: true
            focus: true
            visible: false
        }
        Loader{
            id: ymResearchLoader
            width: parent.width -2
            height: parent.height -2
            clip: true
            focus: true
            visible: false
        }

        Loader {
            id: workOrderLoader
            width: parent.width - 2
            height: parent.height -2
            clip: true
            focus: true
            visible: false
            //source: "qrc:/workorder/YMWorkOrder.qml"
        }
        Connections
        {
            target: workOrderLoader.item

            onLcloseWorkOrder:
            {
                showCloseOrderView(id);
            }
            onCreatNewWorkOrderSheet:
            {
                creatWorkOrderView.visible = true;
            }
            onLreCommitWorkOrder:
            {
                reCommitWorkOrderView.showView(id,lessonId);
            }
            onLshowImage:
            {
                showWorkOrderImageView.onShowImage(imageList);
            }
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
            width: parent.width
            //设置左侧导航收起和被显示的时候的高度
            height: collapsed ? (Cfg.NAV_LINE_HEIGHT) * heightRate : (Cfg.NAV_LINE_HEIGHT * heightRate)* (choices.count + 1)

            interactive: false
            clip: true

            model: choices

            header: MouseArea {//设置头部导航条的样式
                width: parent.width
                height: parent.width
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                x: (parent.width - width) * 0.5
                //property bool selected: activeIndex == index && activeSubIndex == 0 && choices.count == 1

                Rectangle {
                    height: parent.height -2
                    width: parent.height - 4
                    anchors.centerIn: parent
                    color: "white"
                    visible: selected
                }

                Image{
                    id: collapsedImage
                    width: index == 2 ? 38 * heightRate : 26 * heightRate
                    height: index == 2 ? 22 * heightRate : 26 * heightRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: index == 2 ? 28 * heightRate : 24 * heightRate
                    source: selected ? selectedIcon : icon
                    smooth: true
                    fillMode: Image.Stretch
                    //fillMode: Image.PreserveAspectFit
                }

                Text {
                    id:navHeaderText
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

                onClicked: {
                    updateSelected(index);
                    setActiveView(index, 0);
                }
            }
            /* delegate: MouseArea {
                width: parent.width
                height: Cfg.NAV_LINE_HEIGHT * widthRate
                hoverEnabled: true
                visible: choices.count >= 1
                cursorShape: Qt.PointingHandCursor
                property bool selected: activeIndex == navIndex && activeSubIndex == index

                Rectangle {
                    width: parent.width - 20 * widthRate
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                   // radius: 6
                    // color: selected ? Cfg.NAV_SELECTED_CLR : parent.containsMouse ? Cfg.NAV_HOVERED_CLR : Cfg.NAV_BK_CLR
                    radius: 2
                    color: selected ? Cfg.NAV_SELECTED_CLR : parent.containsMouse ? Cfg.NAV_HOVERED_CLR : Cfg.NAV_BK_CLR

                    Image {
                        id: itemImage
                        width: 20 * heightRate
                        height: 20 * heightRate
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 14 * widthRate
                        source: selected ? icon : selectedIcon

                        fillMode: Image.PreserveAspectFit
                        y:(parent.height - 20 * heightRate) * 0.5
                    }

                    Text {
                        id:detialLessonNavText
                        anchors.left: itemImage.right
                        anchors.leftMargin: 10 * heightRate
                        anchors.top: parent.top
                        anchors.topMargin: 16 * heightRate
                        font.pixelSize:  Cfg.NAV_FONT_SIZE2 * heightRate
                        color: selected ? "#FFE6DE" : "#3c3c3e"
                        text: title

                    }
                }
                /*Rectangle {
                    width: 3
                    height: parent.height
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    color: Cfg.NAV_INDICATOR_CLR
                    visible: selected ? true : false
                }

                onClicked: {
                    setActiveView(navIndex, index);
                }
            }*/
        }
    }

    //课程表动画
    SequentialAnimation {
        id: tableAnimate
        running: false
        NumberAnimation { target: lessonListLoader; property: "opacity";from:1.0; to: 0.0; duration:150 }
        NumberAnimation { target: lessonTableLoader; property: "opacity"; from:0.0; to: 1.0; duration:150 }
        onStopped: {
            lessonListLoader.visible = false;
        }
    }

    //课程列表动画
    SequentialAnimation {
        id: tableListAnimate
        running: false
        NumberAnimation { target: lessonTableLoader; property: "opacity"; from:1.0; to: 0.0; duration:150 }
        NumberAnimation { target: lessonListLoader; property: "opacity";from:0.0; to: 1.0; duration:150 }
        onStopped: {
            lessonTableLoader.visible = false;
        }
    }

    //课程表, 课程列表, 溢米教研
    function addView(title, template,icons,selectedIcon){
        viewListModel.append(
                    {
                        "title": title,
                        "template": template,
                        "choices": [],
                        "collapsed": false,
                        "icon":icons,
                        "selectedIcon": selectedIcon,
                        "selected": false,
                    });
    }

    //没有使用到
    function addViewGroup(title, choices, templates, icons,selectedIcon){
        var temp = [];
        for (var i = 0; i < choices.length && i < templates.length; i++){
            temp.push({
                          "navIndex": viewListModel.count,
                          "title": choices[i],
                          "template": templates[i],
                          "icon": icons[i],
                          "selectedIcon": selectedIcon[i],
                      });
        }
        viewListModel.append(
                    {
                        "title": title,
                        "template": "",
                        "choices": temp,
                        "collapsed": true,
                    });
    }

    //点击左侧时,加载页面
    function setActiveView(index, subindex){
        console.log("setActiveView..." + index + subindex)
        if (activeIndex === index && activeSubIndex === subindex
                && exitRequest && workOrderLoader.visible != true){
            return;
        }
        if (viewListModel.count <= index){
            return;
        }//退出继续登录刷新数据
        var viewGroup = viewListModel.get(index).template;
        //console.log("viewGroup",viewGroup,index);
        activeIndex = index;
        activeSubIndex = subindex;
        viewListModel.get(index).collapsed = false;

        if(index == 1 && subindex == 0){
            //加载课程列表
            console.log("last first....")
            lessonListLoader.source = viewGroup;//viewGroup.get(subindex).template;
            lessonListLoader.visible = true;
            lessonListLoader.focus = true;
            lessonTableLoader.focus = false;
            workOrderLoader.focus = false;
            workOrderLoader.visible = false;
            ymResearchLoader.visible = false;
            newMiniClassLoader.visible = false;
            tableListAnimate.start();
            lessonListLoader.item.refreshPage();//刷新课程列表
        }
        if(index == 0 && subindex == 0){
            //加载课程表
            console.log("last second....")
            navigationMappingView.updateSelectIndex(index);
            lessonTableLoader.source = viewGroup;//viewGroup.get(subindex).template;
            if(!loadingStatus){
                //lessonTableLoader.item.contentDate = "";
            }
            lessonTableLoader.visible = true;
            lessonListLoader.focus = false;
            workOrderLoader.focus = false;
            workOrderLoader.visible = false;
            ymResearchLoader.visible = false;
            newMiniClassLoader.visible = false;
            lessonTableLoader.focus = true;
            tableAnimate.start();
            lessonTableLoader.item.refreshPage();
        }
        if(index == 2){
            ymResearchLoader.source = viewGroup;
            ymResearchLoader.visible = true;
            ymResearchLoader.focus = true;
            lessonListLoader.visible = false;
            lessonTableLoader.visible = false;
            workOrderLoader.visible = false;
            newMiniClassLoader.visible = false;
            ymResearchLoader.item.refreshPage();
        }

        if(index == 3){
            newMiniClassLoader.source = ":/../YMMiniHomePage/YMMiniMainView.qml";
            ymResearchLoader.visible = false;
            lessonListLoader.visible = false;
            lessonTableLoader.visible = false;
            workOrderLoader.visible = false;
            newMiniClassLoader.visible = true;
            newMiniClassLoader.focus = true;
            newMiniClassLoader.item.queryData();
        }

        //        if(index == 2 && subindex == 0){
        //            console.log(viewGroup,"dsfad")
        //            workOrderLoader.source = viewGroup;//viewGroup.get(subindex).template;
        //            workOrderLoader.visible = true;
        //            lessonListLoader.focus = false;
        //            lessonListLoader.visible = false;
        //            workOrderLoader.focus = true;
        //            lessonTableLoader.focus = false;
        //            lessonTableLoader.visible = false;
        //            //tableAnimate.start();
        //            // workOrderLoader.item.refreshPage();
        //        }

        loadingStatus = true;
        updateSelected(index);
    }

    function getActiveView(){
        if(activeIndex == 1 && activeSubIndex == 0){
            lessonListLoader.item.refreshPage();
            return;
        }
        if(activeIndex == 0 && activeSubIndex == 0){
            lessonTableLoader.item.refreshPage();
        }
        if(activeIndex == 2 ){
            ymResearchLoader.item.refreshPage();
        }
    }

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
    function showWorkOrderView()
    {
        workOrderLoader.source = "qrc:/workorder/YMWorkOrder.qml";//viewGroup.get(subindex).template;
        workOrderLoader.visible = true;
        lessonListLoader.focus = false;
        lessonListLoader.visible = false;
        workOrderLoader.focus = true;
        lessonTableLoader.focus = false;
        lessonTableLoader.visible = false;
        ymResearchLoader.visible = false;
    }

    function reSetWorkOrderView()
    {
        workOrderLoader.item.resetWorkOrderView();
    }

    function resetWorkOrderDetail( isCommitSuccess )
    {
        workOrderLoader.item.resetWorkOrderDetail(isCommitSuccess )
    }

}


