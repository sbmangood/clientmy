import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import LoadInforMation 1.0
import NetworkAccessManagerInfor 1.0
import  "./Configuuration.js" as Cfg

MouseArea {
    id: technicalTableView
    anchors.fill: parent

    property var typeModel: ["请选择（必填）","网络问题","声音问题","课件问题","其他问题"];
    property var urgentModel: ["请选择（必填）","十分紧急","紧急","一般"];

    property bool oneVisible: false;
    property bool towVisible: false;
    property bool threeVisible: false;
    property int uploadSum: 0;
    property int uploadCount: 0;

    property bool uploadOne: false;
    property bool uploadTow: false;
    property bool uploadTheer: false;


    property var imgUrlLIst: [];

    signal creatWorkOrderFinished();
    signal closeChanged();

    NetworkAccessManagerInfor{
        id: networkAccessMgr
    }

//    onVisibleChanged: {
//        if(visible){
//            reset();
//        }
//    }

    LoadInforMation{
        id: networkMgr
        onSigSendUrlHttp: {
            imgUrlLIst.push(urls);
            uploadCount++;
            if(uploadCount == uploadSum){
                creatWorkOrder();
                reset();
                return;
            }
        }
        onSigUploadFileIamge: {
            if(arrys && uploadOne){
                uploadOne = arrys;
            }
            if(arrys && uploadTow){
                uploadTow = arrys;
            }
            if(arrys && uploadTheer){
                uploadTheer = arrys;
            }
            if(arrys == false){
                uploadImages();
            }
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
        width: 320 * widthRate
        height:  450 * widthRate
        radius: 12 * widthRate
        color: "white"
        anchors.centerIn: parent

        /*Rectangle{
            id: backView
            z: 1
            visible: false
            anchors.fill: parent
            color: "black"
            opacity: 0.4
            radius: 12 * heightRate

            Text {
                text: qsTr("正在提交数据,请稍后....")
                color: "black"
                font.family:  Cfg.font_family
                font.pixelSize: 16 * widthRate
                anchors.centerIn: parent
            }
        }*/

        //头xx
        Rectangle{
            id: headItem
            width: mainPanle.width
            height: 35 * widthRate
            color: "#f3f3f3"
            radius: 12 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle{
                width: parent.width
                height: 30 * widthRate
                anchors.top: parent.top
                anchors.topMargin: 10 * heightRate
                color: "#f3f3f3"
            }

            Text {
                //height: parent.height / 2
                text: qsTr("技术支持表单")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * widthRate
                anchors.left: parent.left
                anchors.leftMargin: 10 * widthRate
                anchors.verticalCenter: parent.verticalCenter
            }
            MouseArea{
                width: 10 * widthRate
                height: 10 * widthRate
                anchors.right: parent.right
                anchors.rightMargin: 10 * widthRate
                anchors.verticalCenter: parent.verticalCenter
                cursorShape: Qt.PointingHandCursor
                Image{
                    anchors.fill: parent
                    source: "qrc:/images/head_quittwox.png"
                }
                onClicked: {
                    technicalTableView.visible = false;
                    closeChanged();
                }
            }
        }

        //内容项
        Item {
            width: mainPanle.width - 40
            height: mainPanle.height - headItem.height
            anchors.top: headItem.bottom
            anchors.topMargin: 10 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            Text{
                id: headText
                text: "技术支持服务时间：09:00 - 21:00"
                width: parent.width
                height: 35 * widthRate
                color: "#ff5000"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 12 * widthRate
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Row{
                id: typeRow
                anchors.top: headText.bottom
                anchors.topMargin: 10 * heightRate
                width: parent.width
                height: 36 * heightRate
                Text {
                    text: qsTr("问题类型")
                    width: 50 * widthRate
                    color: "#999999"
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
                    color: "#999999"
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
                height: 91 * widthRate
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

            Row{
                id: tipRow
                width: parent.width
                height: 40 * heightRate
                anchors.top: flickable.bottom//inputTextArea.bottom
                anchors.topMargin: 30 * heightRate
                Text {
                    text: qsTr("添加图片")
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 11 * widthRate
                    width: parent.width - 110 * widthRate
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
            //三张背景图
            Row{
                id: addImgRow
                width: parent.width - 30 * widthRate
                height: 115 * heightRate
                spacing: 10 * heightRate
                anchors.top: tipRow.bottom
                anchors.topMargin: 10 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter

                property int columnWidth: parent.width / 3 - 20 * heightRate

                MouseArea{
                    height: parent.height
                    width: parent.columnWidth
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    //背景图
                    Image{
                        width: parent.width
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
                        width: parent.width - 10 * heightRate
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
                        width: parent.width
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
                        width: parent.width - 10 * heightRate
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
                        width: parent.width
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
                        width: parent.width - 10 * heightRate
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
                        border.color: "#e2e2e2"
                        color: "#f2f2f2"
                    }

                    Text {
                        text: qsTr("重置")
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        anchors.centerIn: parent
                        color: "#666666"
                    }

                    onClicked: {
                        reset();
                    }
                }

                MouseArea{
                    width: parent.width * 0.5 - 10 * widthRate
                    height: parent.height
                    cursorShape: Qt.PointingHandCursor
                    enabled:   typeCombox.currentIndex != 0 && sosCombox.currentIndex != 0 && inputTextArea.text.length != 0
                    Rectangle{
                        anchors.fill: parent
                        radius: 4 * widthRate
                        border.width: 1
                        border.color: (typeCombox.currentIndex != 0 && sosCombox.currentIndex != 0 && inputTextArea.text.length != 0 ) ? "transparent" : "#c0c0c0"
                        color: (typeCombox.currentIndex != 0 && sosCombox.currentIndex != 0 && inputTextArea.text.length != 0 ) ? "#ff5000" : "#f3f3f3"
                    }

                    Text {
                        text: qsTr("确定")
                        color:  (typeCombox.currentIndex != 0 && sosCombox.currentIndex != 0 && inputTextArea.text.length != 0 ) ? "white" : "black"
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        imgUrlLIst.splice(0,imgUrlLIst.length);
                        uploadCount = 0;
                        uploadSum = 0;
                        uploadOne = false;
                        uploadTow = false;
                        uploadTheer = false;
                        //backView.visible = true;
                        uploadImages();
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
            //console.log("You chose: " + fileDialog.fileUrl)
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
    }

    function uploadImages(){
        var filePaht = "";
        if(oneImage.source != "" && !uploadOne){
            uploadSum++;
        }
        if(towImage.source!= "" && !uploadTow){
            uploadSum++;
        }
        if(threeImage.source!= "" && ! uploadTheer){
            uploadSum++;
        }

        if(oneImage.source != "" && !uploadOne){
            filePaht =oneImage.source;
            filePaht = filePaht.toString().replace("file:///","");
            networkMgr.uploadImage(filePaht);
            uploadOne = true;
        }
        if(towImage.source!= "" && !uploadTow){
            filePaht =towImage.source;
            filePaht = filePaht.toString().replace("file:///","");
            networkMgr.uploadImage(filePaht);
            uploadTow = true;
        }
        if(threeImage.source!= "" && ! uploadTheer){
            filePaht =threeImage.source;
            filePaht = filePaht.toString().replace("file:///","");
            networkMgr.uploadImage(filePaht);
            uploadTheer = true;
        }
        if(oneImage.source == "" && towImage.source == "" && threeImage.source == ""){
            creatWorkOrder();
            reset();
            return;
        }
    }

    function creatWorkOrder()
    {
        var imgUrl = "";
        for(var tempa = 0 ; tempa < imgUrlLIst.length ; tempa++) {
            imgUrl = imgUrl + imgUrlLIst[tempa];
            if(tempa + 1 != imgUrlLIst.length)
            {
                imgUrl = imgUrl + "@,";
            }
        }
        networkAccessMgr.addWorkOrder(typeCombox.currentText,sosCombox.currentText,inputTextArea.text,imgUrl);
        closeChanged();        
        creatWorkOrderFinished();
        technicalTableView.visible = false;
        //console.log("image url s add end ",imgUrl);
    }

}
