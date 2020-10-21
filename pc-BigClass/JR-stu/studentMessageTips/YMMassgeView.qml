import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import YMMassgeRemindManager 1.0
import "../Configuration.js" as Cfg

Item {
    focus: true;

    property int pageIndex: 1;
    property string keywords: "";//搜索传递参数，必须要
    signal transferPage(var pram);//页面传值信号，必须要


    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Up:
            if(msgListView.contentY > 0){
                msgListView.contentY -= 20;
            }
            break;
        case Qt.Key_Down:
            if(button.y<scrollbar.height-button.height) {
                msgListView.contentY += 20;
            }
            break;
        default:
            return;
        }
        event.accepted = true
    }

    //点击空白隐藏日历和退出菜单
    MouseArea{
        anchors.fill: parent
        onClicked: {
            updatePwdView.visible = false;
            exitButton.visible = false;
        }
    }
    YMLoadingStatuesView{
        id: lodingView
        z:88
        anchors.fill: parent
        visible: false
    }
    //网络显示提醒
    YMInterNetView{
        id:netRequest
        z: 89
        visible: false
        anchors.fill: parent
    }

    YMMassgeRemindManager{
        id: remindMgr
        onRemindChange: {
            if(remindData.remindList == undefined || remindData == null){
                msgModel.clear();
                lodingView.startFadeOut();
                netRequest.visible = true;
                return;
            }
            tipsView.currentData = remindData;
            netRequest.visible = false;
            analysisRemind(remindData);
        }
    }

    Image{
        id: backgImage
        width: parent.width/2.5
        height: parent.height/2.5
        anchors.centerIn: parent
        visible: false
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/meiyoutixing3x.png"
    }
    Rectangle{
        id: headItemOne
        width: parent.width - 80 * widthRate
        height: 80 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 40 * widthRate
        anchors.top:parent.top
        anchors.topMargin:10* heightRate
        Text{
            id: headText
            width: 60 * widthRate
            height: parent.height - 10 * heightRate
            text: "提醒"
            font.family:  Cfg.HEAD_FAMILY
            font.pixelSize: Cfg.TIPS_HEAD_FONTSIZE * heightRate
            color: "#3c3c3e"
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle{
            width: parent.width
            height: 1
            color: "#e3e6e9"
            anchors.bottom: parent.bottom
        }

        MouseArea{
            width: 90 * widthRate
            height: 35 * heightRate
            hoverEnabled: true
            anchors.right: allMarkButton.left
            anchors.rightMargin: 20 * widthRate
            anchors.verticalCenter: parent.verticalCenter
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                anchors.fill: parent
                border.width: 1
                border.color: "#c3c6c9"
                radius: 4 * heightRate
                color:"#fafafa"
            }

            Text{
                text: "标记为已读"
                anchors.centerIn: parent
                font.family: Cfg.TIPS_FONT_FAMILY
                font.pixelSize: Cfg.TIPS_FONT_SIZE * heightRate
                color:"#222222"
            }

            onClicked: {
                updateReady();
            }
        }

        MouseArea{
            id: allMarkButton
            width: 120 * widthRate
            height: 35 * heightRate
            hoverEnabled: true
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                anchors.fill: parent
                border.width: 1
                border.color: "#96999c"
                radius: 4 * heightRate
                color:"#fafafa"
            }

            Text{
                text: "全部标记为已读"
                anchors.centerIn: parent
                font.family: Cfg.TIPS_FONT_FAMILY
                font.pixelSize: Cfg.TIPS_FONT_SIZE * heightRate
                color:"#222222"
            }

            onClicked: {
                allCheckBox.checked = true;
                updateAllReady()
            }
        }
    }

    Rectangle{
        id: headItemTow
        width: parent.width - 80 * widthRate
        height: 40 * heightRate
        anchors.top: headItemOne.bottom
        anchors.topMargin: 20 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 40 * widthRate
        color: "#f3f6f9"

        Row{
            anchors.fill: parent
            anchors.left: parent.left
            anchors.leftMargin: 10 * widthRate
            spacing: 10 * widthRate

            CheckBox{
                id: allCheckBox
                width: 16 * heightRate
                height: 16 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                style: CheckBoxStyle{
                    indicator: Rectangle{
                        implicitHeight: 16 *heightRate
                        implicitWidth: 16 * heightRate
                        border.color: control.activeFocus ? "blue" : "gray"
                        border.width: 1
                        Image {
                            visible: control.checked
                            source: "qrc:/images/login_btn_right.png"
                            anchors.fill: parent
                        }
                    }
                }

                //y: (parent.height - height)  *  0.48
                onCheckedChanged: {
                    updateCheck(checked);
                }
            }
            Text{
                width: 175 * widthRate
                height: parent.height
                text: "日期"
                verticalAlignment: Text.AlignVCenter
                font.family: Cfg.TIPS_FONT_FAMILY
                font.pixelSize: Cfg.TIPS_FONT_SIZE * heightRate
                color: Cfg.TIPS_HEAD_FONT_COLOR
            }
            Text{
                height: parent.height
                text: "内容"
                verticalAlignment: Text.AlignVCenter
                font.family: Cfg.TIPS_FONT_FAMILY
                font.pixelSize: Cfg.TIPS_FONT_SIZE * heightRate
                color: Cfg.TIPS_HEAD_FONT_COLOR
            }
        }
    }

    ListView{
        id: msgListView
        clip: true
        width: parent.width - 80* widthRate
        height: parent.height - 200* heightRate
        anchors.top: headItemTow.bottom
        anchors.left: parent.left
        anchors.leftMargin: 40* widthRate
        model: msgModel
        delegate: msgComponent
    }
    //滚动条
    Item {
        id: scrollbar
        width: 8
        visible: msgModel.count > 8 ? true : false
        height: msgListView.height
        anchors.top: headItemTow.bottom
        anchors.right: parent.right

        // 按钮
        Rectangle {
            id: button
            y: msgListView.visibleArea.yPosition * scrollbar.height
            width: 6
            radius: 4 * widthRate
            height: msgListView.visibleArea.heightRatio * scrollbar.height;
            color: "#cccccc"

            // 鼠标区域
            MouseArea {
                id: mouseArea
                anchors.fill: button
                drag.target: button
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: scrollbar.height - button.height

                // 拖动
                onMouseYChanged: {
                    msgListView.contentY = button.y / scrollbar.height * msgListView.contentHeight
                }
            }
        }
    }

    ListModel{
        id: msgModel
    }

    Component{
        id: msgComponent
        MouseArea{
            width: msgListView.width
            height: 60 * heightRate
            hoverEnabled: true

            onClicked: {
                updateSelected(index);
            }

            Rectangle{
                anchors.fill: parent
                color: selected ? "#fafafa" : "white"
                Row{
                    anchors.fill: parent
                    anchors.left: parent.left
                    anchors.leftMargin: 10 * widthRate
                    spacing: 5*widthRate

                    property bool selecte: checkeds;

                    onSelecteChanged: {
                        checkBoxButton.checked = selecte
                    }

                    CheckBox{
                        id: checkBoxButton
                        width: 20 * heightRate
                        height: 20 * heightRate
                        checked: checkeds
                        anchors.verticalCenter: parent.verticalCenter
                        //y: (parent.height - height)  *  0.565
                        style: CheckBoxStyle{
                            indicator: Rectangle{
                                implicitHeight: 16 *heightRate
                                implicitWidth: 16 * heightRate
                                border.color: control.activeFocus ? "blue" : "gray"
                                border.width: 1
                                Image {
                                    visible: control.checked
                                    source: "qrc:/images/login_btn_right.png"
                                    anchors.fill: parent
                                }
                            }
                        }
                        onClicked: {
                            updateModel(index,checked);
                        }
                    }
                    Text{
                        width: 180 * widthRate
                        height: parent.height
                        text: remindTime
                        font.bold: remindStatus == 0 ? true : false
                        verticalAlignment: Text.AlignVCenter
                        font.family: Cfg.TIPS_FONT_FAMILY
                        font.pixelSize: Cfg.TIPS_FONT_SIZE *heightRate
                        color: remindStatus == 0 ? Cfg.TIPS_FONT_COLOR : Cfg.TIPS_FONT_HOVER
                    }
                    Text{
                        width: parent.width - 290 *widthRate
                        height: parent.height
                        text: content
                        verticalAlignment: Text.AlignVCenter
                        font.family: Cfg.TIPS_FONT_FAMILY
                        font.pixelSize: Cfg.TIPS_FONT_SIZE *heightRate
                        color: remindStatus == 0 ? Cfg.TIPS_FONT_COLOR : Cfg.TIPS_FONT_HOVER
                    }
                    MouseArea{
                        width: 60 *widthRate
                        height: parent.height
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        Text{
                            text: "请查看"
                            color: Cfg.TIPS_LINK_COLOR
                            font.underline: true
                            anchors.centerIn: parent
                            font.family: Cfg.TIPS_FONT_FAMILY
                            font.pixelSize: (Cfg.TIPS_FONT_SIZE -1) *heightRate
                        }
                        onClicked: {
                            if(remindStatus ==0){
                                var idList = [];
                                idList.push(remindId);
                                remindMgr.getRemindTag(idList);
                                navigation.messageCount-=1;
                            }
                            transferPage(lessonId);
                            windowView.transferPage(1,0);
                        }
                    }
                }

                Rectangle{
                    width: parent.width - 10
                    height: 1
                    color: "#cccccc"
                    opacity: 0.3
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    YMPagingControl{
           id: pageControl
           anchors.bottom: parent.bottom
           onPageChanged: {
               pageIndex = page;
               currentPage = pageIndex;
               allCheckBox.checked = false;
               queryData();
           }
           onPervPage: {
               pageIndex -= 1;
               allCheckBox.checked = false;
               currentPage = pageIndex;
               queryData();
           }
           onNextPage: {
               pageIndex += 1;
               currentPage = pageIndex;
               allCheckBox.checked = false;
               queryData();
           }
       }

    function refreshPage(){
        lodingView.visible = true;
        lodingView.tips = "页面加载中"
        netRequest.visible = false;
        remindMgr.getRemind(2,pageIndex);
    }

    function queryData(){
        lodingView.visible = true;
        lodingView.tips = "页面加载中"
        netRequest.visible = false;
        remindMgr.getRemind(2,pageIndex);
    }

    //解析提醒消息数据
    function analysisRemind(data){
        var remindList = data.remindList;
        //lodingView.visible = false;
        lodingView.startFadeOut();
        msgModel.clear();
        backgImage.visible=false;
        pageControl.visible=false;
        for(var i = 0; i < remindList.length; i++){
            msgModel.append(
                        {
                            "checkeds": false,
                            "lessonId": remindList[i].lessonId,
                            "remindStatus": remindList[i].remindStatus,
                            "remindType": remindList[i].remindType,
                            "remindId": remindList[i].remindId,
                            "content": addLessonText(remindList[i].content),
                            "remindTime": analysisTime(remindList[i].remindTime),
                            "selected": false,
                        });
        }
        pageControl.totalPage = Math.ceil(data.total / 10);
        if(msgModel.count<=0)
        {
            backgImage.visible=true;
            pageControl.visible=false;
        }else
        {
            backgImage.visible=false;
             pageControl.visible=true;
        }
    }

    function addLessonText(contentText){
        var textSplit = contentText.split('(');
        return textSplit[0] + "(课程编号:" + textSplit[1];
    }

    //解析时间格式
    function analysisTime(time){
        var dataTime = new Date(time);
        var month = Cfg.addZero(dataTime.getMonth() + 1);
        var day = Cfg.addZero(dataTime.getDate());

        var hours = Cfg.addZero(dataTime.getHours());
        var minute = Cfg.addZero(dataTime.getMinutes());

        var currentData = month + "-" + day + " " + hours + ":" + minute
        return currentData;
    }

    function updateModel(index,checked){
        msgModel.get(index).checkeds = checked;
    }

    //全选或全不选
    function updateCheck(checked){
        for(var i = 0; i < msgModel.count; i++){
            msgModel.get(i).checkeds = checked
        }
    }

    function updateReady(){
        var idList = []
        for(var i = 0; i < msgModel.count; i++){
            if(msgModel.get(i).checkeds && msgModel.get(i).remindStatus == 0){
                navigation.messageCount-=1;
                msgModel.get(i).remindStatus = 1;
                idList.push(msgModel.get(i).remindId);
            }
        }
        if(idList.length > 0){
            remindMgr.getRemindTag(idList);
        }
    }

    //全部已读
    function updateAllReady(){
        var idList = []
        for(var i = 0; i < msgModel.count; i++){
            if(msgModel.get(i).checkeds && msgModel.get(i).remindStatus == 0){
                msgModel.get(i).remindStatus = 1;
                navigation.messageCount-=1;
                idList.push(msgModel.get(i).remindId);
            }
        }
        if(idList.length > 0 ){
            remindMgr.getRemindTag(idList);
        }
    }

    //选中状态颜色
    function updateSelected(index){
        for(var i = 0 ; i < msgModel.count;i++){
            if(i == index ){
                msgModel.get(i).selected = true;
            }else{
                msgModel.get(i).selected = false;
            }
        }
    }
}

