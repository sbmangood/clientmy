import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../Configuration.js" as Cfg
import YMWorkOrderways 1.0
import QtGraphicalEffects 1.0
/*******工单******/

MouseArea {
    z: 8890
    anchors.fill: parent
    hoverEnabled: true
    focus: true
    property int mark: 0;// 0起始日期 1结束日期
    property int pageIndex: 1;
    property int pageSize: 10;
    property int totalPage: 1;

    property int currentIndex: 1;

    signal lcloseWorkOrder(var id);
    signal creatNewWorkOrderSheet();//新建工单信号
    signal lreCommitWorkOrder(var id,var lessonId);
    signal lshowImage(var imageList);
    //按键盘上下进行滚动页面
    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Up:
            if(teachListView.contentY > 0){
                teachListView.contentY -= 20;
            }
            break;
        case Qt.Key_Down:
            if(button.y < scrollbar.height - button.height){
                teachListView.contentY += 20;
            }
            break;
        default:
            return;
        }
        event.accepted = true
    }
    //    onRequstTimeOuted: {
    //        enterClassRoom = true;
    //        networkItem.visible = true;
    //    }

    YMWorkOrderDetailView
    {
        id:workOrderDetailViews
        anchors.fill: parent
        visible: false
        onCloseWorkerOrder:
        {
            lcloseWorkOrder(id);
        }
        onReCommitWorkOrder:
        {
            lreCommitWorkOrder(id,lessonId);
        }
        onShowImage:
        {
            lshowImage(imageUrl);
        }
    }

    YMWorkOrderways
    {
        id:workOrderway
    }

    YMLoadingStatuesView{
        id: loadingView
        z: 68
        anchors.fill: parent
        visible: false
    }

    //网络显示提醒
    Rectangle{
        id: networkItem
        z: 86
        visible: false
        anchors.fill: parent
        radius:  12 * widthRate
        anchors.top: listItem.top
        Image{
            id: netIco
            width: 60 * widthRate
            height: 60 * widthRate
            source: "qrc:/images/icon_nowifi.png"
            anchors.top: parent.top
            anchors.topMargin: (parent.height - (30 * heightRate) * 2 - (10 * heightRate) - height) * 0.5
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text{
            id: netText
            height: 30 * heightRate
            text: "网络不给力,请检查您的网络～"
            anchors.top: netIco.bottom
            anchors.topMargin: 10 * heightRate
            font.family: Cfg.LESSON_LIST_FAMILY
            font.pixelSize: (Cfg.LESSON_LIST_FONTSIZE - 4) * widthRate
            verticalAlignment: Text.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Rectangle{
            width: 80 * widthRate
            height: 30 * heightRate
            border.color: "#808080"
            border.width: 1
            radius: 4
            anchors.top: netText.bottom
            anchors.topMargin: 10 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            Text{
                text: "刷新"
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: Cfg.LESSON_LIST_FONTSIZE * heightRate
                anchors.centerIn: parent
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    refreshPage();
                }
            }
        }
    }

    //Rectangle
    //{
    //    width: parent.width - 10 * heightRate
    //    height: parent.height -  45 * heightRate
    //    color: "#f5f5f5"
    ////    anchors.top: headItem.bottom
    ////    //anchors.topMargin: 25 * heightRate
    ////    anchors.horizontalCenter: parent.horizontalCenter

    //}
    Rectangle{
        id: headItem
        width: parent.width - 40 * widthRate
        height: 45 * heightRate
        //        border.color: "#e3e6e9"
        //        border.width: 1
        radius: 5 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 25 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        color:  "transparent"
        Image {
            anchors.right: parent.right
            anchors.rightMargin: 10 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 10 * heightRate
            width: 33 * heightRate
            height: 33 * heightRate
            source: "qrc:/images/jishuzhichi@3x.png"
            MouseArea
            {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    console.log("click to creat new ")
                    creatNewWorkOrderSheet();
                }
            }
        }
        Row{
            width: 400 * widthRate
            height: parent.height
            anchors.centerIn: parent

            Rectangle{
                width: 130 * widthRate
                height: parent.height
                color: "transparent"
                Text{
                    text: "待处理"
                    color:currentIndex == 1 ? "#333333" : "#999999"
                    font.pixelSize: 18 * widthRate
                    anchors.centerIn: parent
                }

                //                Rectangle{
                //                    width: 10
                //                    height: 10
                //                    radius: 10
                //                    color: "#FF7E00"
                //                    anchors.right: parent.right
                //                    anchors.rightMargin: 20
                //                    anchors.top: parent.top
                //                    anchors.topMargin: 10
                //                    Text{
                //                        text: "5"
                //                        color: "white"
                //                        anchors.centerIn: parent
                //                    }
                //                }
                Rectangle{
                    width: 55 * widthRate
                    height: 4 * heightRate
                    visible: currentIndex == 1 ? true : false;
                    color: "#929292"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -15 * heightRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: 5 * heightRate
                }
                MouseArea
                {
                    anchors.fill: parent
                    onClicked:
                    {
                        currentIndex = 1;
                        analysisData(workOrderway.getWorkOrderList("WAIT",0));
                        pagtingControl.currentPage = 1;
                    }
                }
            }
            Rectangle{
                width: 130 * widthRate
                height: parent.height
                color: "transparent"
                Text{
                    text: "处理中"
                    font.pixelSize: 18 * widthRate
                    anchors.centerIn: parent
                    color: currentIndex == 2 ? "#333333" : "#999999"
                }
                Rectangle{
                    width: 55 * widthRate
                    height: 4 * heightRate
                    visible: currentIndex == 2 ? true : false;
                    color: "#929292"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -15 * heightRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: 5 * heightRate
                }
                MouseArea
                {
                    anchors.fill: parent
                    onClicked:
                    {
                        currentIndex = 2;
                        analysisData(workOrderway.getWorkOrderList("DOING",0));
                        pagtingControl.currentPage = 1;
                    }
                }
            }
            Rectangle{
                width: 130 * widthRate
                height: parent.height
                color: "transparent"
                Text{
                    text: "已处理"
                    font.pixelSize: 18 * widthRate
                    anchors.centerIn: parent
                    color: currentIndex == 3 ? "#333333" : "#999999"
                }
                Rectangle{
                    width: 55 * widthRate
                    height: 4 * heightRate
                    visible: currentIndex == 3 ? true : false;
                    color: "#929292"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -15 * heightRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: 5 * heightRate
                }
                MouseArea
                {
                    anchors.fill: parent
                    onClicked:
                    {
                        currentIndex = 3;
                        analysisData(workOrderway.getWorkOrderList("CLOSE",0));
                        pagtingControl.currentPage = 1;
                    }
                }
            }
        }
    }
    Rectangle{ //分割线
        width: parent.width
        height: 1
        color: "#f3f3f3"
        anchors.bottom: headItem.bottom
        anchors.bottomMargin: -15 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
    }

    //背景框
    Rectangle{
        id: listItem
        width: parent.width - 20 * widthRate
        height: parent.height - 180 * heightRate
        anchors.top: headItem.bottom
        anchors.topMargin: 10 * heightRate
        color: "transparent"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ListView{
        id: teachListView
        clip: true
        anchors.fill: listItem
        anchors.top: listItem.top
        anchors.topMargin: 12 * heightRate
        model: teachModel
        delegate: teachDelegate
    }

    //滚动条
    Item {
        id: scrollbar
        anchors.left: listItem.right
        anchors.top: listItem.top
        anchors.topMargin: 12 * heightRate
        width:10 * widthRate
        height:listItem.height
        z: 23
        visible: teachModel.count > 0
        Rectangle{
            width: 2
            height: parent.height
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: teachListView.visibleArea.yPosition * scrollbar.height
            width: 6 * widthRate
            height: teachListView.visibleArea.heightRatio * scrollbar.height;
            color: "#cccccc"
            radius: 4 * widthRate

            // 鼠标区域
            MouseArea {
                id: mouseArea
                anchors.fill: button
                drag.target: button
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: scrollbar.height - button.height
                cursorShape: Qt.PointingHandCursor
                // 拖动
                onMouseYChanged: {
                    teachListView.contentY = button.y / scrollbar.height * teachListView.contentHeight
                }
            }
        }
    }

    Image{
        id: backgImage
        width: listItem.width * 0.4
        height: listItem.height * 0.4
        anchors.centerIn: listItem
        visible: false
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/zanwugongdan@3x.png"
    }

    ListModel{
        id: teachModel
    }

    //翻页框
    YMPagingControl{
        id: pagtingControl
        anchors.bottom: parent.bottom
        onPageChanged: {
            //pageIndex = page;
            currentPage = page;
            queryData(currentPage - 1)
        }
        onPervPage: {
            //pageIndex -= 1;
            currentPage -= 1;
            queryData(currentPage - 1)
        }

        onNextPage: {
            // pageIndex += 1;
            currentPage += 1;
            queryData(currentPage - 1)
        }
    }

    Component{
        id: teachDelegate
        Item{
            id: dgItem
            width: teachListView.width
            height: 200 * heightRate
            Image {
                width: parent.width - 6 * widthRate
                height: parent.height - 10 * heightRate
                source: "qrc:/images/beijing1@2x.png"
                anchors.centerIn: parent
            }
//            Rectangle
//            {
//                id:shadow
//                width: parent.width - 18 * widthRate
//                height: parent.height - 8 * heightRate
//                color: "transparent"
//                border.color: "#e3e6e9"
//                border.width: 1
//                radius: 6 * heightRate
//                anchors.verticalCenter: parent.verticalCenter
//                anchors.horizontalCenter: parent.horizontalCenter
//            }
//            DropShadow {
//                   id: rectShadow;
//                   anchors.fill: source
//                   cached: true;
//                   horizontalOffset: 0;
//                   verticalOffset: 0;
//                   radius: 6 * heightRate
//                   samples: 20;
//                   color: "#60000000";
//                   smooth: true;
//                   source: shadow;
//               }
            Rectangle{//border
                id: contentItem
                width: parent.width - 20 * widthRate
                height: parent.height - 10 * heightRate
                color: "transparent"
                //border.color: "#e3e6e9"
                //border.width: 1
                radius: 6 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                z:100
//                Image {
//                    anchors.fill: parent
//                    source: "qrc:/images/beijing1@2x.png"
//                }
                Rectangle
                {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 3 * widthRate
                    width: parent.width //+ 10 *　widthRate
                    height: 35 * widthRate
                    color: "#f6f6f6"
                    radius: 8 * heightRate
                }
                Rectangle
                {
                    width: 8 * heightRate
                    height: 8 *　heightRate
                    color: "red"
                    radius: 4 * heightRate
                    anchors.top: parent.top
                    anchors.topMargin: 25 * heightRate
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * heightRate
                }

                Text{
                    id: sheetNumberText
                    text: "工单编号："
                    // width: 60 * heightRate
                    anchors.top: parent.top
                    anchors.topMargin: 15 * heightRate
                    anchors.left: parent.left
                    anchors.leftMargin: 32 * heightRate
                    font.family: Cfg.LESSON_LIST_FAMILY
                    font.pixelSize: 18 * heightRate
                    color: "#666666"
                }
                Text{
                    width: parent.width
                    text: sheetNumber
                    anchors.top: parent.top
                    anchors.topMargin: 15 * heightRate
                    anchors.left: sheetNumberText.right
                    anchors.leftMargin: 5 * heightRate
                    font.family: Cfg.LESSON_LIST_FAMILY
                    font.pixelSize: 18 * heightRate
                    color: "#333333"
                }
                Text{
                    id: creatTimeText
                    anchors.top: parent.top
                    anchors.topMargin: 18 * heightRate
                    anchors.right: parent.right
                    anchors.rightMargin: 10 * widthRate
                    font.family: Cfg.LESSON_LIST_FAMILY
                    font.pixelSize: 16 * heightRate
                    color: "#999999"
                    text: "发起时间：" + creatTime
                }
                Text{
                    id: problemDetialsText
                    width: parent.width - 20 * widthRate
                    anchors.top: parent.top
                    anchors.topMargin: 75 * heightRate
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * heightRate
                    font.family: Cfg.LESSON_LIST_FAMILY
                    font.pixelSize: 18 * heightRate
                    color: "#333333"
                    text: "问题详情："
                    elide: Text.ElideRight
                }
                Text{
                    id: lessonIdText
                    anchors.top: parent.top
                    anchors.topMargin: 110 * heightRate
                    anchors.left: parent.left
                    anchors.leftMargin: 40 * heightRate
                    font.family: Cfg.LESSON_LIST_FAMILY
                    font.pixelSize: 18 * heightRate
                    color: "#666666"
                    text: problemDetials
                    width: parent.width - 160 * heightRate
                    wrapMode: Text.WordWrap
                    onHeightChanged:
                    {
                        dgItem.height = 200 * heightRate + ( lessonIdText.height - 19 * heightRate ) * heightRate
                    }
                }
                //                Text{
                //                    id: lessonIdText
                //                    anchors.top: parent.top
                //                    anchors.topMargin: 125 * heightRate
                //                    anchors.left: parent.left
                //                    anchors.leftMargin: 15 * heightRate
                //                    font.family: Cfg.LESSON_LIST_FAMILY
                //                    font.pixelSize: 18 * heightRate
                //                    color: "#333333"
                //                    text: "课程编号：" + lessonId
                //                }
                Text{
                    id: showDetailsText
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20 * heightRate
                    anchors.right: parent.right
                    anchors.rightMargin: 15 * widthRate
                    font.family: Cfg.LESSON_LIST_FAMILY
                    font.pixelSize: 18 * heightRate
                    color: "#00BCEB"
                    text: "查看详情"
                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            workOrderDetailViews.showWorkOrderDetailView(orderId,currentIndex);
                        }
                        cursorShape: Qt.PointingHandCursor
                    }
                }


            }


        }
    }

    Component.onCompleted: {
        //var currentDate = getCurrentDate();
        // startTimeText.text = currentDate.replace("年","-").replace("月","-").replace("日","");;
        analysisData(workOrderway.getWorkOrderList("WAIT",0));
    }

    function refreshPage(){
        //queryData();
    }

    function analysisData(objectData){
        var tempobjectData = JSON.parse(objectData);
        var tempobjectDatas = tempobjectData.data;
        var  items = tempobjectDatas.items;
        if(items == null || items == [] || items == {}){
            console.log("===return====")
            networkItem.visible = true
            return;
        }

        networkItem.visible = false;
        teachModel.clear();
        for(var i = 0; i < items.length; i++){
            teachModel.append({
                                  "sheetNumber":items[i].orderNo,
                                  "creatTime":items[i].createdOn,
                                  "problemDetials":items[i].content,
                                  "lessonId":items[i].orderId.toString(),
                                  "orderId":items[i].orderId.toString()
                              })
        }
        totalPage = Math.ceil(tempobjectDatas.total / pageSize);
        pagtingControl.totalPage = totalPage;
        backgImage.visible = teachModel.count == 0 ? true : false;
    }




    function queryData(currentPage){
        loadingView.visible = true;
        if(currentIndex == 1)
        {
            analysisData(workOrderway.getWorkOrderList("WAIT",currentPage));
            loadingView.visible = false;
            return;
        }
        if(currentIndex == 2)
        {
            analysisData(workOrderway.getWorkOrderList("DOING",currentPage));
            loadingView.visible = false;
            return;
        }
        if(currentIndex == 3)
        {
            analysisData(workOrderway.getWorkOrderList("CLOSE",currentPage));
            loadingView.visible = false;
            return;
        }
        loadingView.visible = false;
    }
    function resetWorkOrderView()
    {
        pagtingControl.currentPage = 1;
        workOrderDetailViews.visible = false;
        queryData(0);
    }
    function resetWorkOrderDetail( isCommitSuccess )
    {
        workOrderDetailViews.resetWorkOrderDetail( isCommitSuccess );
    }
}

