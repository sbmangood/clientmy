import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import YMWorkOrderways 1.0
import "./Configuration.js" as Cfg

MouseArea {
    id: technicalTableView
    anchors.fill: parent

    property var typeModel: ["请选择（必填）","网络问题","声音问题","课件问题","其他问题"];
    property var urgentModel: ["请选择（必填）","十分紧急","紧急","一般"];

    property bool oneVisible: false;
    property bool towVisible: false;
    property bool threeVisible: false;
    signal creatWorkOrderFinished();

    property bool isUploadingImage: false;
    onVisibleChanged:
    {
        if(visible)
        {
            reset();
        }
    }

    YMWorkOrderways
    {
        id:workOrderway
        onCreatWorkOrderSuccessOrFail:
        {
            creatWorkOrderFinished();
            technicalTableView.visible = false;
        }
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
        height:  450 * widthRate
        radius: 12 * widthRate
        color: "white"
        anchors.centerIn: parent

        //头xx
        Rectangle{
            id: headItem
            width: mainPanle.width
            height: 35 * heightRate
            color: "transparent"
            radius: 12 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle{
                width: parent.width
                height: 30
                anchors.top: parent.top
                anchors.topMargin: 10 * heightRate
                color: "transparent"
            }

            Text {
                //height: parent.height / 2
                text: qsTr("技术支持表单")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 12 * widthRate
                anchors.left: parent.left
                anchors.leftMargin: 10 * widthRate
                anchors.top: parent.top
                anchors.topMargin: 5 * widthRate
            }
            MouseArea{
                width: 13 * widthRate
                height: 13 * widthRate
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
                    technicalTableView.visible = false;
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

            Row{
                id: lessonIdRow
                anchors.top: headText.bottom
                anchors.topMargin: 10 * heightRate
                width: parent.width
                height: 35 * heightRate
                Text {
                    text: qsTr("课程编号")
                    width: 50 * widthRate
                    color: "gray"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 16 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextField{
                    id: lessonIdInput
                    placeholderText: "请输入课程编号"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 16 * heightRate
                    width: parent.width - 50 * widthRate
                    height: parent.height
                    validator: RegExpValidator { regExp: /^\d{10}$/ }
                    background: Rectangle{
                        anchors.fill: parent
                        border.width: 1
                        border.color: "#e0e0e0"
                        radius: 4 * heightRate

                    }
                }
            }
            Row{
                id: typeRow
                anchors.top: lessonIdRow.bottom
                anchors.topMargin: 10 * heightRate
                width: parent.width
                height: 35 * heightRate
                Text {
                    text: qsTr("问题类型")
                    width: 50 * widthRate
                    color: "gray"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 16 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                }
                YMComboBoxControl{
                    id: typeCombox
                    width: parent.width - 50 * widthRate
                    height: parent.height
                    model: typeModel

                }
            }
            Row{
                id: sosRow
                width: parent.width
                height: 35 * heightRate
                anchors.top: typeRow.bottom
                anchors.topMargin: 10 * heightRate
                Text {
                    text: qsTr("紧急程度")
                    width: 50 * widthRate
                    color: "gray"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 16 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                }
                YMComboBoxControl{
                    id: sosCombox
                    width: parent.width - 50 * widthRate
                    height: parent.height
                    model: urgentModel
                }
            }
            Flickable {
                id: flickable
                width: parent.width
                height: 120 * heightRate
                anchors.top: sosRow.bottom
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
            //                anchors.top: sosRow.bottom
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
                        text: qsTr("重置")
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        reset();
                    }
                }

                MouseArea{
                    width: parent.width * 0.5 - 10 * widthRate
                    height: parent.height
                    cursorShape: Qt.PointingHandCursor
                    enabled: isUploadingImage == false && lessonIdInput.text.length >0 &&  typeCombox.currentIndex != 0 && sosCombox.currentIndex != 0 && inputTextArea.text.length != 0
                    Rectangle{
                        anchors.fill: parent
                        radius: 4 * widthRate
                        border.width: 1
                        border.color: (lessonIdInput.text.length >0 &&  typeCombox.currentIndex != 0 && sosCombox.currentIndex != 0 && inputTextArea.text.length != 0 ) ? "transparent" : "#c0c0c0"
                        color: ( isUploadingImage == false && lessonIdInput.text.length >0 && typeCombox.currentIndex != 0 && sosCombox.currentIndex != 0 && inputTextArea.text.length != 0 ) ? "#ff5000" : "#f3f3f3"
                    }

                    Text {
                        text: isUploadingImage ? qsTr("提交中..."): qsTr("确定")
                        color:  (isUploadingImage == false && lessonIdInput.text.length >0 && typeCombox.currentIndex != 0 && sosCombox.currentIndex != 0 && inputTextArea.text.length != 0 ) ? "white" : "black"
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        isUploadingImage = true;
                        creatWorkOrder();
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

    function reset(){
        typeCombox.currentIndex = 0;
        sosCombox.currentIndex = 0;
        inputTextArea.text = "";
        oneImage.source = "";
        towImage.source = "";
        threeImage.source = "";
        lessonIdInput.text = "";
    }
    function creatWorkOrder()
    {
        //upload image
        var imgUrlLIst = [];
        var imgUrl = "";

        if(oneImage.source != ""){
            imgUrlLIst.push(workOrderway.uploadImage(oneImage.source,lessonIdInput.text))
        }
        if(towImage.source != ""){
            imgUrlLIst.push(workOrderway.uploadImage(towImage.source,lessonIdInput.text))
        }
        if(threeImage.source != ""){
            imgUrlLIst.push(workOrderway.uploadImage(threeImage.source,lessonIdInput.text))
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
        // creatWorkOrder sheet
        workOrderway.creatWorkOrderSheet(lessonIdInput.text,sosCombox.currentText,inputTextArea.text,typeCombox.currentText,imgUrl);
        isUploadingImage = false;
    }



}
