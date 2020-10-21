import QtQuick 2.0
import QtQuick.Controls 1.4
import "./Configuration.js" as Cfg
import QtQuick 2.5
import YMLessonManager 1.0

/***云盘首页***/
Item {
    id: cloudDiskView
    width: 472 * heightRate
    height: 325 * heightRate
    focus: true

    property int currentPageIndex: 0; //当前显示页的索引
    property var fileIdBufferList: [];//文件id索引列表

    signal sigCurrentBeOpenedCoursewareUrl(var imgUrlList, var fileId,var h5Url,var courswareType);//当前要打开的课件图片的UrlList 课件id
    signal sigCurrentBePlayedAudioUrl(var audioUrl, var fileId , var fileName);//当前需要被播放的音频的Url
    signal sigCurrentBePlayedVideoUrl(var videoUrl, var fileId , var fileName);//当前需要被播放的视频的Url

    signal sigAccept(var fileUrl); // 确定选择文件信号
    signal sigReject();            // 取消选择文件信号

    Image {
        anchors.fill: parent
        source: "qrc:/bigclassImage/kjbj.png"
    }

    MouseArea{
        anchors.fill: parent
        onClicked: {

        }
    }

    YMLoadingStatuesView {
        id:loadingView
        z: 100
        anchors.fill: parent
        visible: false
        onChangeVisible:{
            loadingView.visible=false;
        }
    }

    Item {
        id:headItem
        width: parent.width
        height: 42 * widthRate
        anchors.horizontalCenter: parent.horizontalCenter

        // 选择文件上传控件
        YMUploadFileControl {
            id: btnUplod
            visible: false
            width: 64 * widthRate
            height: 22 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 72 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 6 * heightRate
            onSigAccepted: {
                sigAccept(fileUrl);
            }
            onSigRejected: {
                sigReject();
            }
        }

        MouseArea{//关闭按钮
            id:mousOne
            width: 32 * widthRate
            height: 32 * widthRate
            anchors.right: parent.right
            anchors.rightMargin: 4 * widthRate
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            Image {
                source: "qrc:/bigclassImage/close.png"
                anchors.fill:parent
            }

            onClicked:{
                cloudDiskView.visible = false;
            }
        }

        MouseArea{//刷新
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            anchors.top: parent.top
            anchors.topMargin: -6 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 32 * widthRate
            width: 42 * widthRate
            height: 42 * widthRate

            onClicked:{
                enabled = false;
                loadIngItem.visible = true;
                refreshCloudDisk();
                enabled = true;
            }

            Image {
                source: "qrc:/bigclassImage/sx1.png"
                anchors.fill: parent
            }
        }

    }

    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Up:
            if(filckable.contentY > 0){
                filckable.contentY -= 20;
            }
            break;
        case Qt.Key_Down:
            if(button.y < scrollbar.height-button.height){
                filckable.contentY += 20;
            }
            break;
        default:
            return;
        }
        event.accepted = true
    }

    Flickable{
        id :filckable
        z: 1
        width: parent.width
        height: parent.height - headItem.height - 10 * widthRate
        contentWidth: width
        contentHeight:height// cloudViewModel.count * 25 * heightRate
        anchors.top: headItem.bottom

        ListView{
            id:lessonListView
            width: parent.width - 40 * heightRate
            height: parent.height - 10 * heightRate
            delegate: contentComponent
            model: cloudViewModel
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
        }
    }

    //网络显示提醒
    Rectangle{
        id: networkItem
        z: 86
        visible: false
        anchors.fill: parent
        radius: 12 * widthRate
        anchors.top: headItem.bottom
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
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 15 * heightRate
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
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 15 * heightRate
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

    //滚动条
    Rectangle {
        id: scrollbar
        z: 66
        width: 10
        height: parent.height - headItem.height
        anchors.top: headItem.bottom
        anchors.right: parent.right
        visible: false
        Rectangle{
            width: 2
            height: lessonListView.height
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: filckable.visibleArea.yPosition * scrollbar.height
            width: 6
            height: filckable.visibleArea.heightRatio * scrollbar.height ;
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
                    filckable.contentY = button.y / scrollbar.height * filckable.contentHeight
                }
            }
        }
    }

    ListModel{
        id: cloudViewModel
    }

    Component{
        id: contentComponent
        Item{
            height: 42 * widthRate
            width: lessonListView.width

            MouseArea{
                id:clickArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onDoubleClicked:{
                    var fileUrl;
                    var imgUrlList
                    if(suffix.indexOf("pdf") != -1 || suffix.indexOf("ppt") != -1)
                    {
                        //获取课件Url发送课件Url
                        coursewareType = 1;
                        imgUrlList = miniMgr.getCloudDiskFileInfo(fileId).data.images;
                        console.log("uffix.indexOf(pdf)",imgUrlList)
                        sigCurrentBeOpenedCoursewareUrl(imgUrlList,fileId,"",coursewareType);
                    }
                    else if(suffix.indexOf("h5") != -1){
                        coursewareType = 3;
                        //imgUrlList  = miniMgr.getCloudDiskFileInfo(fileId);
                        var h5Url = path;//imgUrlList.data.path;
                        console.log("==h5::data==",fileId,h5Url);
                        var coursewareList = [];
                        //console.log("=========",totalPage)
                        for(var i = 0; i < parseInt(totalPage); i++){//h5CoursewarePageTotal;i++){
                            coursewareList.push("");
                        }
                        //console.log("=====h5CoursewarePageTotal=====",h5CoursewarePageTotal,",currentPageIndex=",currentPageIndex);

                        sigCurrentBeOpenedCoursewareUrl(coursewareList,fileId,h5Url,coursewareType);
                    }
                    else if(suffix.indexOf("mp3") != -1 || suffix.indexOf("wma") != -1 || suffix.indexOf("wav") != -1)
                    {
                        //获取音频Url 发送出去
                        fileUrl = path;
                        console.log("mp3 path",fileUrl)
                        sigCurrentBePlayedAudioUrl(fileUrl,fileId,name);
                    }
                    else if(suffix.indexOf("mp4") != -1 || suffix.indexOf("avi") != -1 || suffix.indexOf("wmv") != -1 || suffix.indexOf("rmvb") != -1)
                    {
                        fileUrl = path;
                        sigCurrentBePlayedVideoUrl(fileUrl,fileId,name);
                    }

                }
            }

            Row {
                width: parent.width - 10 * heightRate
                height: 18 * widthRate
                spacing: 10 * widthRate
                anchors.verticalCenter: parent.verticalCenter

                Item {
                    width: 16 * heightRate
                    height: 18 * heightRate

                    Image {
                        anchors.fill: parent
                        source:  {
                            if(type == 0){
                                return "qrc:/images/xbk_window_file.png";
                            }
                            else{
                                if(suffix.indexOf("pdf") != -1)
                                {
                                    return "qrc:/images/xbk_window_pdf.png"
                                }
                                else if(suffix.indexOf("ppt") != -1)
                                {
                                    return "qrc:/images/xb_ppt.png"
                                }
                                else if(suffix.indexOf("mp3") != -1 || suffix.indexOf(".wma") != -1 || suffix.indexOf(".wav") != -1)
                                {
                                    return "qrc:/images/xb_yinpin.png"
                                }
                                else if(suffix.indexOf("mp4") != -1 || suffix.indexOf(".avi") != -1 || suffix.indexOf(".wmv") != -1 || suffix.indexOf(".rmvb") != -1)
                                {
                                    return "qrc:/images/xb_shipin.png"
                                }
                                else if(suffix.indexOf("h5") != -1){
                                    return "qrc:/images/h5bgimg.png";
                                }
                                return""
                            }
                        }
                        anchors.centerIn: parent
                    }
                }

                Item{
                    height: 12 * widthRate * 0.7
                    width: 260 * heightRate

                    Text {
                        text: name
                        width:parent.width -  5 * widthRate
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        color: clickArea.containsMouse ? "#ffffff" : "#999999"
                        elide:Text.ElideRight
                    }
                }

                Item{
                    height: 12 * widthRate * 0.7
                    width: 201 * heightRate

                    Text {
                        text: updateDate
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        color: clickArea.containsMouse ? "#ffffff" : "#999999"
                    }
                }

            }

            Rectangle{
                color: "#262731"
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
            }
        }
    }

    YMLoadingStatuesView{
        id:loadIngItem
        width: parent.width - 60 * heightRate
        height: parent.height - 20 * widthRate
        anchors.top:parent.top
        anchors.topMargin: 30 * widthRate
        anchors.horizontalCenter: parent.horizontalCenter
        z:100
    }

    function resetCloudDiskViewData(arrData){
        cloudViewModel.clear(); //重置数据
        //console.log("=========resetCloudDiskViewData::arrData=", JSON.stringify(arrData))
        for(var a = 0; a < arrData.length; a++){
            cloudViewModel.append(
                        {
                            "fileId": arrData[a].id,
                            "name": arrData[a].name,
                            "type": arrData[a].docType,
                            "suffix": arrData[a].docType,
                            "updateDate": arrData[a].date,
                            "totalPage": arrData[a].totalPage,
                            "path": arrData[a].path,
                        });
        }

        loadIngItem.visible = false;
    }
}

