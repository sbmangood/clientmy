import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQml.Models 2.2
import "Configuration.js" as Cfg
import QtGraphicalEffects 1.0

Item {
    id: navigationView

    property int activeIndex: -1;
    property int activeSubIndex: -1;
    property int checkNumber: 0;

    property string teacherName: "";
    property string headPicture: "qrc:/images/index_profile_defult@2x.png";

    property Component navigationItemDelegate: null
    property bool clearModel: false;
    property double   widthRate : windowView.widthRate;
    property double   heightRate : windowView.heightRate;

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
        width: 169 * heightRate * 0.75
        height: 1163 * heightRate * 0.75
        anchors.left: parent.left
        anchors.leftMargin:  24 * heightRate * 0.75
        anchors.top:parent.top
        anchors.topMargin: 106 * heightRate * 0.75
        Item{
            width: parent.width
            height: parent.height
            anchors.centerIn: parent

            Image{//背景图
                anchors.fill: parent
                source: "qrc:/images/index_bg_leftbar@2x.png"
            }

            //学生头像信息
            Item{
                id: headButton
                width: 139 * heightRate * 0.75
                height: width
                anchors.top: parent.top
                anchors.topMargin:  36 * heightRate * 0.75
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle{
                    id: rundItem
                    color: "transparent"
                    radius: 10
                    anchors.fill: parent
                    border.color: "#ff5000"
                    border.width: 0
                    anchors.centerIn: parent
                    Image{
                        anchors.fill: parent
                        source: "qrc:/images/index_profile_defult@2x.png"
                    }
                }

                Image{
                    id: headImage
                    visible: false
                    anchors.fill: parent
                    anchors.centerIn: parent
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
                    anchors.top:  headImage.bottom
                    anchors.topMargin: 10 * heightRate
                    font.bold: Cfg.Menu_bold
                    font.family: Cfg.Menu_family
                    font.pixelSize: Cfg.Menu_pixelSize * heightRate
                    color: Cfg.Menu_defaultColor
                    text: teacherName
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            ListView {
                id: navigationBarArea
                width: parent.width
                height: parent.height  - headButton.height
                clip: true
                anchors.top: headButton.bottom
                anchors.topMargin: 36 * heightRate * 0.75
                boundsBehavior: ListView.StopAtBounds
                model: viewListModel
                delegate: navigationItemDelegate
            }

        }
    }

    Rectangle {//主界面加载其他跳转界面的区域
        id: loaderArea
        z: 98
        border.color: "#e0e0e0"
        border.width: 1
        radius: 12 * heightRate
        width: parent.width - listViewArea.width - 55 * heightRate
        height: parent.height -Cfg.TB_HEIGHT * heightRate - 30 * heightRate
        anchors.left: parent.left
        anchors.leftMargin:  214 * heightRate * 0.75
        anchors.top:parent.top
        anchors.topMargin: 109 * heightRate * 0.75
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
            onSigInvalidTokens:{

                loginView.tips = "登录已过期,请重新登录!"
                navigation.clearModel = false;
                tipsControl.visible = false;
                exitRequest = false;
                showLoginWindow();
           }
        }

        Loader {
            id: lessonTableLoader
            width: parent.width - 2 * heightRate
            height: parent.height -2
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
            focus: true
            visible: false
        }

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
                    width:  26 * heightRate
                    height: 26 * heightRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 24 * heightRate
                    source: selected ? selectedIcon : icon
                    smooth: true
                    fillMode: Image.PreserveAspectFit
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
                    console.log("onClicked.onClicked");
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

    //选中时加载的页面
    function setActiveView(index, subindex){
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
            lessonListLoader.source = viewGroup;//viewGroup.get(subindex).template;
            lessonListLoader.visible = true;
            lessonListLoader.focus = true;
            lessonTableLoader.focus = false;
            workOrderLoader.focus = false;
            workOrderLoader.visible = false;
            ymResearchLoader.visible = false;
            tableListAnimate.start();
            lessonListLoader.item.refreshPage();
        }
        if(index == 0 && subindex == 0){
            lessonTableLoader.source = viewGroup;//viewGroup.get(subindex).template;
            lessonTableLoader.visible = true;
            lessonListLoader.focus = false;
            workOrderLoader.focus = false;
            workOrderLoader.visible = false;
            ymResearchLoader.visible = false;
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
            ymResearchLoader.item.refreshPage();
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


