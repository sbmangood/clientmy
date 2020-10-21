import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../Configuration.js" as Cfg
import YMWorkOrderways 1.0
/*******工单详情******/

Rectangle {
    z: 24
    anchors.fill: parent
    focus: true
    id:workOrderDetailView
    radius: 12 * heightRate

    signal closeWorkerOrder( var id );
    signal reCommitWorkOrder( var id ,var lessonId);
    property var orderIds: ;
    property var lessonIds: ;
    property int workOrderShowType: -1;
    signal showImage(var imageUrl);

    signal closeWorkerOrderSuccess();

    property string recommitText: "" ;
    //    border.color: "#e0e0e0"
    //    border.width: 1
    //color: "red"
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

    Rectangle{
        id: headItem
        width: parent.width - 40 * widthRate
        height: 45 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 5 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 10 * heightRate
            width: 33 * heightRate
            height: 33 * heightRate
            font.family: Cfg.LESSON_LIST_FAMILY
            font.pixelSize: 16 * widthRate
            verticalAlignment: Text.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
            text: "< 工单详情"
            MouseArea
            {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    workOrderDetailView.visible = false;
                }
            }
        }
    }

    //背景框
    Rectangle{
        id: listItem
        width: parent.width - 20 * widthRate
        height: parent.height - 100 * heightRate
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

    Row
    {
        visible: teachListView.atYEnd
        width: 200 * heightRate
        height:  50 * heightRate
        anchors.top: teachListView.bottom
        anchors.topMargin: -25 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 30 * heightRate
        spacing: 10 * heightRate
        Rectangle
        {
            width: 120 * heightRate
            height: parent.height
            color: "#FF5000"
            radius: 10 * heightRate
            visible:  workOrderShowType == 1
            Text {
                anchors.centerIn: parent
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: 12 * widthRate
                text:"继续反馈"
                color: "#ffffff"
            }
            MouseArea
            {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    console.log("click reCommit ");
                    reCommitWorkOrder(orderIds,lessonIds);
                }
            }
        }
        Rectangle
        {
            width: 120 * heightRate
            height: parent.height
            color: "#dcdcde"
            border.width: 1
            border.color: "#dbdbdb"
            radius: 10 * heightRate
            visible: workOrderShowType != 3
            Text {
                anchors.centerIn: parent
                font.family: Cfg.LESSON_LIST_FAMILY
                font.pixelSize: 12 * widthRate
                text:"关闭工单"
                color: "#666666"
            }
            MouseArea
            {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    console.log("click close")
                    closeWorkerOrder(orderIds);
                }
            }
        }
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


    ListModel{
        id: teachModel
    }

    ListModel{
        id: teachDelModel
    }
    Component{
        id: teachDelegate
        Item{
            width: teachListView.width
            height: 1000 * heightRate


            Rectangle{//border
                id: contentItem
                width: parent.width - 20 * widthRate
                height: 300 * heightRate
                color: "transparent"
//                border.color: "#e3e6e9"
//                border.width: 1
                radius: 6 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    width: parent.width + 14 * widthRate
                    height: parent.height + 15 * heightRate
                    source: "qrc:/images/beijing1@2x.png"
                    anchors.centerIn: parent
                }
                Rectangle
                {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width
                    height: 35 * widthRate
                    color: "#f6f6f6"
                    radius: 6 * heightRate
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
                    id: lessonIdText
                    text: "课程编号："
                    anchors.top: parent.top
                    anchors.topMargin: 15 * heightRate
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width / 2.4
                    font.family: Cfg.LESSON_LIST_FAMILY
                    font.pixelSize: 18 * heightRate
                    color: "#666666"
                }
                Text{
                    text: lessonId
                    anchors.top: parent.top
                    anchors.topMargin: 15 * heightRate
                    anchors.left: lessonIdText.right
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
                    font.pixelSize: 15 * heightRate
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
                    id: problemDetialsDescribeText
                    width: parent.width - 160 * heightRate
                    anchors.top: parent.top
                    anchors.topMargin: 110 * heightRate
                    anchors.left: parent.left
                    anchors.leftMargin: 40 * heightRate
                    font.family: Cfg.LESSON_LIST_FAMILY
                    font.pixelSize: 18 * heightRate
                    color: "#666666"
                    text: problemDetials
                    wrapMode: Text.WordWrap
                    onHeightChanged:
                    {
                        contentItem.height = 300 * heightRate + ( problemDetialsDescribeText.height - 19 * heightRate ) * heightRate
                    }
                }
                Row
                {
                    width: 300 * heightRate
                    height: 100 * heightRate
                    spacing: 20 * heightRate
                    anchors.top: problemDetialsDescribeText.bottom
                    anchors.topMargin: 20 * heightRate
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * heightRate
                    Image {
                        width: 100 * heightRate
                        height: 100 * heightRate
                        source: (describeImage1 == undefined || describeImage1 == "") ? "qrc:/images/tu@2x.png" : describeImage1
                        enabled: describeImage1 != ""
                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked:
                            {
                                var tempurlList= [];
                                if(describeImage1 != "")
                                {
                                    tempurlList.push(describeImage1);
                                }
                                if(describeImage2 != "")
                                {
                                    tempurlList.push(describeImage2);
                                }
                                if(describeImage3 != "")
                                {
                                    tempurlList.push(describeImage3);
                                }

                                showImage(tempurlList);
                            }
                        }
                    }
                    Image {
                        width: 100 * heightRate
                        height: 100 * heightRate
                        source: (describeImage2 == undefined || describeImage2 == "") ? "qrc:/images/tu@2x.png" : describeImage2
                        enabled: describeImage2 != ""
                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked:
                            {
                                 var tempurlList= [];
                                if(describeImage2 != "")
                                {
                                    tempurlList.push(describeImage2);
                                }
                                if(describeImage3 != "")
                                {
                                    tempurlList.push(describeImage3);
                                }
                                if(describeImage1 != "")
                                {
                                    tempurlList.push(describeImage1);
                                }
                                showImage(tempurlList);
                            }
                        }
                    }
                    Image {
                        width: 100 * heightRate
                        height: 100 * heightRate
                        source: (describeImage3 == undefined || describeImage3 == "") ? "qrc:/images/tu@2x.png" : describeImage3
                        enabled: describeImage3 != ""
                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked:
                            {
                                 var tempurlList= [];

                                if(describeImage3 != "")
                                {
                                    tempurlList.push(describeImage3);
                                }
                                if(describeImage1 != "")
                                {
                                    tempurlList.push(describeImage1);
                                }
                                if(describeImage2 != "")
                                {
                                    tempurlList.push(describeImage2);
                                }
                                showImage(tempurlList);
                            }
                        }
                    }

                }

                Rectangle{
                    width: 152 * widthRate
                    height: 30 * heightRate
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20 * heightRate
                    anchors.right: parent.right
                    anchors.rightMargin: 20 * widthRate
                    color: "#e5e5e5"
                    radius: 10 * heightRate
                    Text{
                        id: sponsorNameText
                        anchors.centerIn: parent
                        font.family: Cfg.LESSON_LIST_FAMILY
                        font.pixelSize: 16 * heightRate
                        color: "#666666"
                        text: "问题发起人：" + sponsorName
                    }
                }
            }

            //处理意见
            Rectangle{
                id: contentItems
                width: parent.width - 20 * widthRate
                height: 630 * heightRate
                color: "transparent"
                border.color: "#e3e6e9"
                border.width: 1
                radius: 6 * heightRate
                anchors.top: contentItem.bottom
                anchors.topMargin: 20 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle
                {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width
                    height: 35 * widthRate
                    color: "#f6f6f6"
                    radius: 6 * heightRate
                }
                Text{
                    id: sheetNumberTexts
                    width: parent.width
                    text: "处理意见"
                    anchors.top: parent.top
                    anchors.topMargin: 15 * heightRate
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * heightRate
                    font.family: Cfg.LESSON_LIST_FAMILY
                    font.pixelSize: 18 * heightRate
                    color: "#333333"
                }





                ListView {
                    width: parent.width - 30 * heightRate
                    height: 500 * heightRate
                    anchors.top: parent.top
                    anchors.topMargin: 80 * heightRate
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * heightRate
                    model: teachDelModel
                    clip: true

                    delegate:  //反馈意见
                               Rectangle
                    {
                        id: delTextDelegate
                        width: parent.width
                        height: 270 * heightRate
                        clip: false
                        Rectangle
                        {
                            id:grayItem
                            width: 11 * heightRate
                            height: 11 *　heightRate
                            color: "#999999"
                            radius: 6 * heightRate
                            anchors.top: parent.top
                            anchors.topMargin: 25 * heightRate
                            anchors.left: parent.left
                            anchors.leftMargin: 15 * heightRate
                        }
                        Rectangle
                        {
                            width: 1
                            height: 270 * heightRate
                            anchors.top: grayItem.bottom
                            anchors.topMargin: 10 * heightRate
                            anchors.left: parent.left
                            anchors.leftMargin: 20 * heightRate
                            color: "#f6f6f6"
                        }

                        Column
                        {
                            spacing: 15 * heightRate
                            width: parent.width
                            height: 255 * heightRate
                            anchors.left: parent.left
                            anchors.leftMargin: 50 * heightRate
                            anchors.top: parent.top
                            anchors.topMargin: 18 * heightRate
                            Text{
                                width: 100 * heightRate
                                height: 30 * heightRate
                                font.family: Cfg.LESSON_LIST_FAMILY
                                font.pixelSize: 18 * heightRate
                                color: "#666666"
                                text:creatorType == "T" ? "反馈意见  " + createdOn :"处理意见  " + createdOn
                            }
                            Row
                            {
                                width: 300 * heightRate
                                height: 100 * heightRate
                                spacing: 20 * heightRate
                                anchors.topMargin: 20 * heightRate
                                anchors.left: parent.left
                                anchors.leftMargin: 15 * heightRate
                                Image {
                                    width: 100 * heightRate
                                    height: 100 * heightRate
                                    source: (describeImage4 == undefined || describeImage4 == "") ? "qrc:/images/tu@2x.png" : describeImage4
                                    enabled: describeImage4 != ""
                                    MouseArea
                                    {
                                        anchors.fill: parent
                                        onClicked:
                                        {
                                             var tempurlList= [];
                                            if(describeImage4 != "")
                                            {
                                                tempurlList.push(describeImage4);
                                            }
                                            if(describeImage5 != "")
                                            {
                                                tempurlList.push(describeImage5);
                                            }
                                            if(describeImage6 != "")
                                            {
                                                tempurlList.push(describeImage6);
                                            }

                                            showImage(tempurlList);
                                        }
                                    }
                                }
                                Image {
                                    width: 100 * heightRate
                                    height: 100 * heightRate
                                    source: (describeImage5 == undefined || describeImage5 == "") ? "qrc:/images/tu@2x.png" : describeImage5
                                    enabled: describeImage5 != ""
                                    MouseArea
                                    {
                                        anchors.fill: parent
                                        onClicked:
                                        {
                                             var tempurlList= [];

                                            if(describeImage5 != "")
                                            {
                                                tempurlList.push(describeImage5);
                                            }
                                            if(describeImage6 != "")
                                            {
                                                tempurlList.push(describeImage6);
                                            }
                                            if(describeImage4 != "")
                                            {
                                                tempurlList.push(describeImage4);
                                            }
                                            showImage(tempurlList);
                                        }
                                    }
                                }
                                Image {
                                    width: 100 * heightRate
                                    height: 100 * heightRate
                                    source: (describeImage6 == undefined || describeImage6 == "") ? "qrc:/images/tu@2x.png" : describeImage6
                                    enabled: describeImage6 != ""
                                    MouseArea
                                    {
                                        anchors.fill: parent
                                        onClicked:
                                        {
                                             var tempurlList= [];
                                            if(describeImage6 != "")
                                            {
                                                tempurlList.push(describeImage6);
                                            }
                                            if(describeImage4 != "")
                                            {
                                                tempurlList.push(describeImage4);
                                            }
                                            if(describeImage5 != "")
                                            {
                                                tempurlList.push(describeImage5);
                                            }
                                            showImage(tempurlList);
                                        }
                                    }
                                }

                            }
                            Rectangle{
                                id: delRectangItem
                                width: parent.width - 40 * widthRate
                                height: 80 * heightRate
                                clip: true
                                color: "#f9f9f9"
                                radius: 10 * heightRate
                                border.width: 1
                                border.color: "#eaeaee"
                                Text{
                                    id: sponsorNameTexts
                                    // anchors.fill: parent
                                    font.family: Cfg.LESSON_LIST_FAMILY
                                    font.pixelSize: 18 * heightRate
                                    color: "#666666"
                                    text: content
                                    width: parent.width - 30 * widthRate
                                    wrapMode: Text.WordWrap
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20 * heightRate
                                    anchors.top:parent.top
                                    anchors.topMargin: 10 * heightRate
                                    onHeightChanged:
                                    {
                                        delRectangItem.height = 80 * heightRate + ( sponsorNameTexts.height - 19  ) * heightRate
                                        delTextDelegate.height = 270 * heightRate + ( sponsorNameTexts.height - 19  ) * heightRate
                                    }
                                }
                            }

                        }
                    }
                }






            }
        }
    }

    //    Rectangle{
    //        id:showRecommitResultView
    //        width: 300 * widthRate
    //        height: 150* widthRate
    //        color: "#ffffff"
    //        radius: 8 * heightRate
    //        anchors.centerIn: parent
    //        visible: false

    //        Rectangle{
    //            width: parent.width
    //            height: 50 * heightRate
    //            anchors.top: parent.top
    //            anchors.topMargin: -1

    //            anchors.left: parent.left
    //            anchors.leftMargin: 0
    //            color: "#f3f3f3"
    //            radius: 7 * heightRate
    //            Rectangle{
    //                width: parent.width
    //                height: parent.height / 2
    //                anchors.left: parent.left
    //                anchors.bottom: parent.bottom
    //                color: "#f3f3f3"
    //            }

    //            Text{
    //                text: "关闭工单"
    //                anchors.left: parent.left
    //                anchors.top: parent.top
    //                anchors.topMargin: 10 * heightRate
    //                anchors.leftMargin: 25 * heightRate
    //                font.family: Cfg.EXIT_FAMILY
    //                font.pixelSize: 20 * heightRate
    //                color:"#222222"
    //            }

    //            Rectangle
    //            {
    //                width: 40 * heightRate
    //                height: 30 * heightRate
    //                anchors.right: parent.right
    //                anchors.top: parent.top
    //                anchors.topMargin: -5 * heightRate
    //                color: "transparent"

    //                Text {
    //                    anchors.fill: parent
    //                    font.family: Cfg.EXIT_FAMILY
    //                    font.pixelSize: 40 * heightRate
    //                    text: qsTr("×")
    //                }
    //                MouseArea
    //                {
    //                    anchors.fill: parent
    //                    cursorShape: Qt.PointingHandCursor
    //                    onClicked:
    //                    {
    //                        showRecommitResultView.visible = false;
    //                    }
    //                }
    //            }

    //        }
    //        Text {
    //            anchors.centerIn: parent
    //            text: recommitText
    //            font.family: Cfg.EXIT_FAMILY
    //            font.pixelSize: 22 * heightRate
    //            color: "#999999"

    //        }
    //        MouseArea{
    //            width: 82 * widthRate
    //            height: 48 * heightRate
    //            cursorShape: Qt.PointingHandCursor
    //            anchors.horizontalCenter: parent.horizontalCenter
    //            anchors.bottom: parent.bottom
    //            anchors.bottomMargin: 5 * heightRate
    //            Rectangle{
    //                width: 82 * widthRate
    //                height: 48 * heightRate
    //                border.color: "#96999c"
    //                border.width: 1
    //                anchors.centerIn: parent
    //                radius:4 * heightRate
    //                Text{
    //                    text: "确定"
    //                    anchors.centerIn: parent
    //                    font.family: Cfg.EXIT_FAMILY
    //                    font.pixelSize: Cfg.EXIT_BUTTON_FONTSIZE * heightRate
    //                    color:"#96999c"
    //                }
    //            }
    //            onClicked: {
    //                showRecommitResultView.visible = false;
    //            }
    //        }
    //    }
    Component.onCompleted: {

    }

    function showWorkOrderDetailView(orderId,showType)
    {
        workOrderShowType = showType;
        orderIds = orderId;
        workOrderDetailView.visible = true;
        var tempobjectData = JSON.parse( workOrderway.getWorkOrderListDetails(orderId) ).data;//obj
        lessonIds = tempobjectData.lessonFid.toString();
        var picture1 = tempobjectData.imgs;
        var comment = tempobjectData.comment;//处理意见

        for ( var tempi = 0; tempi < 3 ; tempi++ )
        {
            if(picture1[tempi] == undefined || picture1[tempi] == "")
            {
                picture1[tempi] = ""
            }
        }


        teachModel.clear();
        teachModel.append({
                              "sheetNumber":tempobjectData.orderNo,
                              "creatTime":tempobjectData.createdOn,
                              "problemDetials":tempobjectData.content,
                              "lessonId":tempobjectData.lessonFid.toString(),
                              "orderId":tempobjectData.orderId.toString(),
                              "sponsorFid":tempobjectData.sponsorFid,
                              "sponsorType":tempobjectData.sponsorType,
                              "describeImage1":picture1[0],
                              "describeImage2":picture1[1],
                              "describeImage3":picture1[2],
                              "sponsorName":tempobjectData.sponsorName,
                          })

        teachDelModel.clear();
        for(var tempInt = 0; tempInt < comment.length ; tempInt ++)
        {
            var picture2 = comment[tempInt].imgs
            for ( var tempis = 0; tempis < 3 ; tempis++ )
            {
                if(picture2[tempis] == undefined || picture2[tempis] == "")
                {
                    picture2[tempis] = ""
                }
            }
            teachDelModel.append({
                                     "describeImage4":picture2[0],
                                     "describeImage5":picture2[1],
                                     "describeImage6":picture2[2],
                                     "creatorType": comment[tempInt].creatorType,
                                     "createdBy": comment[tempInt].createdBy,
                                     "createdOn": comment[tempInt].createdOn,
                                     "content": comment[tempInt].content
                                 })
        }
    }
    function resetWorkOrderDetail( isCommitSuccess )
    {
        if(isCommitSuccess)
        {
            //recommitText = "意见反馈成功"
            showWorkOrderDetailView(orderIds,workOrderShowType);
        }else
        {
            // recommitText = "意见反馈失败，请重试"
        }
        // showRecommitResultView.visible = true;
    }

}
