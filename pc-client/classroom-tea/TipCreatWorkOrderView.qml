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

    property bool isCreateWorkOrder: false;
    property var imgUrlLIst: [];

    signal creatWorkOrderFinished();
    signal closeChanged();

    onVisibleChanged: {
        if(visible){
            isCreateWorkOrder = false;
        }else{
            reset();
        }
    }

    NetworkAccessManagerInfor{
        id: networkAccessMgr
    }

    LoadInforMation{
        id: networkMgr
        onSigSendUrlHttp: {
            imgUrlLIst.push(urls);
            uploadCount++;
            if(uploadCount == uploadSum){
                creatWorkOrder();
                console.log("=====+++++11======")
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
        color: "#111111"
        opacity: 0.8
        radius: 12 * heightRate
    }

    Rectangle{
        id: mainPanle
        width: 360 * heightRates
        height:  626 * heightRates
        radius: 10 * widthRate
        color: "white"
        anchors.centerIn: parent

        //头xx
        Rectangle{
            id: headItem
            width: mainPanle.width
            height: 35 * widthRate
            color: "white"
            radius: 12 * heightRate
            anchors.top:parent.top
            anchors.topMargin: 10 * heightRates
            Rectangle{
                width: parent.width
                height: 30 * widthRate
                anchors.top: parent.top
                anchors.topMargin: 10 * heightRate
                color: "white"
            }

            Text {
                //height: parent.height / 2
                text: qsTr("技术支持表单")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 12 * widthRate
                anchors.centerIn: parent
            }

            Text{
                text: "技术支持服务时间：09:00 - 21:00"
                color: "#ff5000"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 10 * widthRate
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -15 * heightRates
            }

            MouseArea{
                width: 8 * widthRate
                height: 8 * widthRate
                anchors.right: parent.right
                anchors.rightMargin: 6 * widthRate
                anchors.top: parent.top
                anchors.topMargin: -1 * widthRate
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
                height: 15 * widthRate
                color: "#ff5000"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 12 * widthRate
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                visible: false
            }

            Column{
                id: typeRow
                anchors.top: headText.bottom
                anchors.topMargin: 10 * heightRate
                width: parent.width
                height: 36 * heightRate
                spacing: 15 * heightRates
                Text {
                    text: qsTr("问题类型")
                    width: 50 * widthRate
                    color: "#999999"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 16 * heightRate
                }
                YMComboBoxControl{
                    id: typeCombox
                    width: parent.width - 10 * widthRate
                    height: parent.height
                    model: typeModel
                    showType: 2
                }

            }


            Rectangle
            {
                width: parent.width
                height: 1
                color: "#DDDDDD"
                anchors.top: typeRow.bottom
                anchors.topMargin: 50 * heightRate
            }

            Column{
                id: sosRow
                width: parent.width
                height: 35 * heightRate
                anchors.top: typeRow.bottom
                anchors.topMargin: 70 * heightRate
                spacing: 15 * heightRates
                Text {
                    text: qsTr("紧急程度")
                    width: 50 * widthRate
                    color: "#999999"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 16 * heightRate
                }
                YMComboBoxControl{
                    id: sosCombox
                    width: parent.width - 10 * widthRate
                    height: parent.height
                    model: urgentModel
                    showType: 2
                }
            }

            Rectangle
            {
                width: parent.width
                height: 1
                color: "#DDDDDD"
                anchors.top: sosRow.bottom
                anchors.topMargin: 50 * heightRate
            }

            Flickable {
                id: flickable
                width: parent.width
                height: 91 * widthRate
                anchors.top: sosRow.bottom
                anchors.topMargin: 70 * heightRate

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
                        radius: 4 * widthRate
                    }
                }
                ScrollBar.vertical: ScrollBar { }
            }

            Row{
                id: tipRow
                width: parent.width
                height: 40 * heightRate
                anchors.top: flickable.bottom//inputTextArea.bottom
                anchors.topMargin: 20 * heightRate
                Text {
                    text: qsTr("添加图片")
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 11 * widthRate
                    width: parent.width - 110 * widthRate
                    verticalAlignment: Text.AlignVCenter
                    color: "#999999"
                }

                Text {
                    text: qsTr("您最多可添加3张图片")
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 11 * widthRate
                    width: 100 * widthRate
                    verticalAlignment: Text.AlignVCenter
                    visible: false
                }
            }
            //三张背景图
            Row{
                id: addImgRow
                width: parent.width - 8 * widthRate
                height: 115 * heightRate
                spacing: 10 * heightRate
                anchors.top: tipRow.bottom
                //anchors.topMargin: 10 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter

                property int columnWidth: parent.width / 3 - 20 * heightRate

                MouseArea{
                    height: 100 * heightRates
                    width: height
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
                    height: 100 * heightRates
                    width: height
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
                    height: 100 * heightRates
                    width: height
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
                width: parent.width
                height: 40 * heightRate
                anchors.top: addImgRow.bottom
                anchors.topMargin: 30 * heightRate
                spacing: 10 * widthRate
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea{
                    width: 158 * heightRates
                    height: 34 * heightRates
                    cursorShape: Qt.PointingHandCursor
                    Rectangle{
                        anchors.fill: parent
                        radius: 4 * widthRate
                        border.width: 1
                        border.color: "#999999"
                        color: "#FFFFFF"
                    }

                    Text {
                        text: qsTr("重置")
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        anchors.centerIn: parent
                        color: "#333333"
                    }

                    onClicked: {
                        reset();
                    }
                }

                MouseArea{
                    id: commitButton
                    width: 158 * heightRates
                    height: 34 * heightRates
                    cursorShape: Qt.PointingHandCursor
                    enabled: (typeCombox.currentIndex != 0 && sosCombox.currentIndex != 0 && inputTextArea.text.length != 0) ? true : false
                    Rectangle{
                        anchors.fill: parent
                        radius: 4 * widthRate
                        border.width: 1
                        border.color: (typeCombox.currentIndex != 0 && sosCombox.currentIndex != 0 && inputTextArea.text.length != 0 ) ? "transparent" : "#c0c0c0"
                        color: (commitButton.enabled && typeCombox.currentIndex != 0 && sosCombox.currentIndex != 0 && inputTextArea.text.length != 0 ) ? "#ff5000" : "#CCCCCC"
                    }

                    Text {
                        text: qsTr("确定")
                        color: "white" //commitButton.enabled ? ((typeCombox.currentIndex != 0 && sosCombox.currentIndex != 0 && inputTextArea.text.length != 0 ) ? "white" : "white") : "white"
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
            return;
        }
    }

    function creatWorkOrder()
    {
        if(isCreateWorkOrder){
            return;
        }

        var imgUrl = "";
        for(var tempa = 0 ; tempa < imgUrlLIst.length ; tempa++) {
            imgUrl = imgUrl + imgUrlLIst[tempa];
            if(tempa + 1 != imgUrlLIst.length)
            {
                imgUrl = imgUrl + "@,";
            }
        }

        networkAccessMgr.addWorkOrder(typeCombox.currentText,sosCombox.currentText,inputTextArea.text,imgUrl);
        isCreateWorkOrder = true;
        closeChanged();
        creatWorkOrderFinished();
        technicalTableView.visible = false;
        reset();
        //console.log("image url s add end ",imgUrl);
    }

}
