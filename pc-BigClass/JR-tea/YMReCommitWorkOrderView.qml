import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import YMWorkOrderways 1.0
import "./Configuration.js" as Cfg

MouseArea {
    id: reCommitCreatOrder
    anchors.fill: parent

    property bool oneVisible: false;
    property bool towVisible: false;
    property bool threeVisible: false;
    signal creatWorkOrderFinished();
    property  string orderId: "" ;
    property string lessonIds: "" ;
    signal reNewWorkOrdrDetailView(bool isCommitSuccess);
    property string recommitText: "" ;
    onVisibleChanged:
    {
        if(visible)
        {
            reset();
            mainPanle.visible = true;
            showRecommitResultView.visible = false;
        }
    }

    YMWorkOrderways
    {
        id:workOrderway

    }

    Rectangle{
        anchors.fill: parent
        color: "black"
        opacity: 0.4
        radius: 12 * heightRate
    }

    Rectangle{
        id: mainPanle
        width: 380 * widthRate
        height:  350 * widthRate
        radius: 12 * widthRate
        color: "white"
        anchors.centerIn: parent

        //头
        Rectangle{
            id: headItem
            width: mainPanle.width
            height: 35 * heightRate
            color: "#f3f3f3"
            radius: 12 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle{
                width: parent.width
                height: 30
                anchors.top: parent.top
                anchors.topMargin: 10 * heightRate
                color: "#f3f3f3"
            }

            Text {
                //height: parent.height / 2
                text: qsTr("意见反馈")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * widthRate
                anchors.left: parent.left
                anchors.leftMargin: 10 * widthRate
                anchors.top: parent.top
                anchors.topMargin: 5 * widthRate
            }
            MouseArea{
                width: 15 * widthRate
                height: 15 * widthRate
                anchors.right: parent.right
                anchors.rightMargin: 10 * widthRate
                anchors.top: parent.top
                anchors.topMargin: 10 * widthRate
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: "qrc:/images/bar_btn_close.png"
                }
                onClicked: {
                    reCommitCreatOrder.visible = false;
                }
            }
        }

        //内容项
        Item {
            width: mainPanle.width - 20
            height: mainPanle.height - headItem.height
            anchors.top: headItem.bottom
            anchors.topMargin: 15 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            Text{
                id: headText
                text: "技术支持服务时间：09:00 - 21:00"
                width: parent.width
                height: 40
                color: "#ff5000"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 18 * heightRate
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Flickable {
                id: flickable
                width: parent.width
                height: 120 * heightRate
                anchors.top: headText.bottom
                anchors.topMargin: 20 * heightRate

                TextArea.flickable: TextArea {
                    id: inputTextArea
                    wrapMode: TextArea.Wrap
                    selectByMouse: true
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 16 * heightRate
                    selectionColor: "blue"
                    selectedTextColor: "#ffffff"
                    placeholderText: "请您对遇到的问题进行描述 (必填)"
                    background: Rectangle{
                        anchors.fill: parent
                        border.width: 1
                        border.color: "#cccccc"
                        radius: 6 * widthRate
                    }
                }
                ScrollBar.vertical: ScrollBar { }
            }
            //            TextArea{
            //                id: inputTextArea
            //                width: parent.width
            //                height: 120 * heightRate
            //                anchors.top: headText.bottom
            //                anchors.topMargin: 20 * heightRate
            //                placeholderText: "请您对遇到的问题进行描述 (必填)"
            //                selectByMouse: true
            //                font.family: Cfg.DEFAULT_FONT
            //                font.pixelSize: 16 * heightRate
            //                wrapMode: TextEdit.Wrap
            //                background: Rectangle{
            //                    anchors.fill: parent
            //                    border.width: 1
            //                    border.color: "#e0e0e0"
            //                    radius: 6 * widthRate

            //                }

            //            }

            Row{
                id: tipRow
                width: parent.width
                height: 40 * heightRate
                anchors.top: flickable.bottom
                anchors.topMargin: 30 * heightRate
                Text {
                    text: qsTr("添加图片")
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 11 * widthRate
                    width: parent.width - 120 * widthRate
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    text: qsTr("您最多可添加3张图片")
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 11 * widthRate
                    width: 100 * widthRate
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Row{
                id: addImgRow
                width: parent.width
                height: 120 * heightRate
                spacing: 10 * widthRate
                anchors.top: tipRow.bottom
                anchors.topMargin: 10 * heightRate

                property int columnWidth: parent.width / 3 - 10 * widthRate

                MouseArea{
                    height: parent.height
                    width: parent.columnWidth
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    //背景图
                    Image{
                        width: parent.width - 10 * heightRate
                        height: parent.height
                        source: "qrc:/images/tianjia@2x.png"
                        anchors.centerIn: parent
                    }

                    //删除图
                    Image{
                        z: 1
                        width: 12 * widthRate
                        height: 12 * widthRate
                        source: "qrc:/images/shanchu@3x.png"
                        visible:  oneImage.source != "" ? true : false
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                oneImage.source = "";
                            }
                        }
                    }

                    Image{
                        id: oneImage
                        width: parent.width - 20 * heightRate
                        height: parent.height - 10 * heightRate
                        anchors.centerIn: parent
                    }
                    onClicked: {
                        oneVisible = true;
                        towVisible = false;
                        threeVisible = false;
                        fileDialog.open();
                    }
                }

                MouseArea{
                    height: parent.height
                    width: parent.columnWidth
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    //背景图
                    Image{
                        width: parent.width - 10 * heightRate
                        height: parent.height
                        source: "qrc:/images/tianjia@2x.png"
                        anchors.centerIn: parent
                    }
                    //删除图
                    Image{
                        z: 1
                        width: 12 * widthRate
                        height: 12 * widthRate
                        source: "qrc:/images/shanchu@3x.png"
                        visible:  towImage.source != "" ? true : false
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                towImage.source = "";
                            }
                        }
                    }

                    Image{
                        id: towImage
                        width: parent.width - 20 * heightRate
                        height: parent.height - 10 * heightRate
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        oneVisible = false;
                        towVisible = true;
                        threeVisible = false;
                        fileDialog.open();
                    }
                }

                MouseArea{
                    height: parent.height
                    width: parent.columnWidth
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    //背景图
                    Image{
                        width: parent.width - 10 * heightRate
                        height: parent.height
                        source: "qrc:/images/tianjia@2x.png"
                        anchors.centerIn: parent
                    }
                    //删除图
                    Image{
                        z: 1
                        width: 12 * widthRate
                        height: 12 * widthRate
                        source: "qrc:/images/shanchu@3x.png"
                        visible:  threeImage.source != "" ? true : false
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                threeImage.source = "";
                            }
                        }
                    }

                    Image{
                        id: threeImage
                        width: parent.width - 20 * heightRate
                        height: parent.height - 10 * heightRate
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        oneVisible = false;
                        towVisible = false;
                        threeVisible = true;
                        fileDialog.open();
                    }
                }
            }

            //按钮
            Row{
                width: 180 * widthRate
                height: 40 * heightRate
                anchors.top: addImgRow.bottom
                anchors.topMargin: 40 * heightRate
                spacing: 10 * widthRate
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea{
                    width: parent.width * 0.5 - 10 * widthRate
                    height: parent.height
                    cursorShape: Qt.PointingHandCursor
                    Rectangle{
                        anchors.fill: parent
                        radius: 4 * widthRate
                        border.width: 1
                        border.color: "#c0c0c0"
                        color: "#f3f3f3"
                    }

                    Text {
                        text: qsTr("取消")
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        reset();
                        reCommitCreatOrder.visible = false;
                    }
                }

                MouseArea{
                    width: parent.width * 0.5 - 10 * widthRate
                    height: parent.height
                    cursorShape: Qt.PointingHandCursor
                    enabled: inputTextArea.text.length != 0
                    Rectangle{
                        anchors.fill: parent
                        radius: 4 * widthRate
                        border.width: 1
                        border.color: ( inputTextArea.text.length != 0 ) ? "transparent" : "#c0c0c0"
                        color: ( inputTextArea.text.length != 0 ) ? "#ff5000" : "#f3f3f3"
                    }

                    Text {
                        text: qsTr("确定")
                        color:  (inputTextArea.text.length != 0 ) ? "white" : "black"
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        reCreatWorkOrder();
                    }
                }

            }

        }

    }

    FileDialog{
        id: fileDialog
        nameFilters: [ "Image files (*.jpg *.png)"]
        title: "请选择图片"
        folder: shortcuts.home
        selectMultiple: false
        onAccepted: {
            console.log("You chose: " + fileDialog.fileUrl)
            if(oneVisible){
                oneImage.source = fileDialog.fileUrl
                return;
            }
            if(towVisible){
                towImage.source = fileDialog.fileUrl
                return;
            }
            if(threeVisible){
                threeImage.source = fileDialog.fileUrl
                return;
            }

        }
    }

    Rectangle{
        id:showRecommitResultView
        width: 300 * widthRate
        height: 150* widthRate
        color: "#ffffff"
        radius: 8 * heightRate
        anchors.centerIn: parent
        visible: false

        Rectangle{
            width: parent.width
            height: 50 * heightRate
            anchors.top: parent.top
            anchors.topMargin: -1

            anchors.left: parent.left
            anchors.leftMargin: 0
            color: "#f3f3f3"
            radius: 7 * heightRate
            Rectangle{
                width: parent.width
                height: parent.height / 2
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                color: "#f3f3f3"
            }

            Text{
                text: "关闭工单"
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 10 * heightRate
                anchors.leftMargin: 25 * heightRate
                font.family: Cfg.EXIT_FAMILY
                font.pixelSize: 20 * heightRate
                color:"#222222"
            }

            Rectangle
            {
                width: 40 * heightRate
                height: 30 * heightRate
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: -5 * heightRate
                color: "transparent"

                Text {
                    anchors.fill: parent
                    font.family: Cfg.EXIT_FAMILY
                    font.pixelSize: 40 * heightRate
                    text: qsTr("×")
                }
                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        showRecommitResultView.visible = false;
                        reCommitCreatOrder.visible = false;
                    }
                }
            }

        }
        Text {
            anchors.centerIn: parent
            text: recommitText
            font.family: Cfg.EXIT_FAMILY
            font.pixelSize: 22 * heightRate
            color: "#999999"

        }
        MouseArea{
            width: 82 * widthRate
            height: 48 * heightRate
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5 * heightRate
            Rectangle{
                width: 82 * widthRate
                height: 48 * heightRate
                border.color: "#96999c"
                border.width: 1
                anchors.centerIn: parent
                radius:4 * heightRate
                Text{
                    text: "确定"
                    anchors.centerIn: parent
                    font.family: Cfg.EXIT_FAMILY
                    font.pixelSize: Cfg.EXIT_BUTTON_FONTSIZE * heightRate
                    color:"#96999c"
                }
            }
            onClicked: {
                showRecommitResultView.visible = false;
                reCommitCreatOrder.visible = false;
            }
        }
    }

    function reset(){
        inputTextArea.text = "";
        oneImage.source = "";
        towImage.source = "";
        threeImage.source = "";
    }
    function showView(id,lessonId)
    {
        orderId = id;
        lessonIds = lessonId;
        reCommitCreatOrder.visible = true;
    }

    function reCreatWorkOrder()
    {
        //upload image
        var imgUrlLIst = [];
        var imgUrl = "";

        if(oneImage.source != ""){
            imgUrlLIst.push(workOrderway.uploadImage(oneImage.source,lessonIds))
        }
        if(towImage.source != ""){
            imgUrlLIst.push(workOrderway.uploadImage(towImage.source,lessonIds))
        }
        if(threeImage.source != ""){
            imgUrlLIst.push(workOrderway.uploadImage(threeImage.source,lessonIds))
        }
        // add image url
        for(var tempa = 0 ; tempa < imgUrlLIst.length ; tempa++)
        {
            imgUrl = imgUrl + imgUrlLIst[tempa];
            if(tempa + 1 != imgUrlLIst.length)
            {
                imgUrl = imgUrl + "@,";
            }
        }

        console.log("image url s add end ",imgUrl);
        // reCommitCreatOrder sheet
        if( workOrderway.reCommitWorkOrder(orderId,inputTextArea.text,imgUrl))
        {
            //renew
            reNewWorkOrdrDetailView(true);
            recommitText = "意见反馈成功"
        }else
        {
            reNewWorkOrdrDetailView(false);
            recommitText = "意见反馈失败，请重试"
        }
        mainPanle.visible = false;
        showRecommitResultView.visible = true;
        //workOrderway.creatWorkOrderSheet(lessonIdInput.text,sosCombox.currentText,inputTextArea.text,typeCombox.currentText,imgUrl);

    }

}
