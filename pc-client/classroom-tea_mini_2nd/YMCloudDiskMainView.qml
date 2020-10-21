import QtQuick 2.0
import QtQuick.Controls 1.4
import "./Configuuration.js" as Cfg
import QtQuick 2.5

/***云盘首页***/

Item {
    id: cloudDiskView
    width: 694 * widthRate * 0.8
    height: 419 * widthRate * 0.8
    focus: true

    property int currentPageIndex: 0; //当前显示页的索引
    property var fileIdBufferList: [];//文件id索引列表

    signal sigCurrentBeOpenedCoursewareUrl(var imgUrlList, var fileId,var h5Url,var courswareType);//当前要打开的课件图片的UrlList 课件id
    signal sigCurrentBePlayedAudioUrl(var audioUrl, var fileId , var fileName);//当前需要被播放的音频的Url
    signal sigCurrentBePlayedVideoUrl(var videoUrl, var fileId , var fileName);//当前需要被播放的视频的Url

    property bool  hasInitMainViewData: false;//是否已经初始化index数据

    onVisibleChanged:
    {
        if(visible && !hasInitMainViewData)
        {
            hasInitMainViewData = true;
            loadIngItem.visible = true;
            var initData = miniMgr.getCloudDiskInitFileInfo();
            resetCloudDiskViewData(initData,"0",true);
        }
    }

    MouseArea{
        anchors.fill: parent
    }

    Image {
        anchors.fill: parent
        source: "qrc:/miniClassImage/yunpan.png"
    }

    YMLoadingStatuesView{
        id:loadingView
        z: 100
        anchors.fill: parent
        visible: false
        onChangeVisible:
        {
            loadingView.visible=false;
        }
    }

    Item{
        id:headItem
        width: parent.width - 25 * widthRate
        height: 50 * widthRate
        anchors.top:parent.top
        anchors.topMargin: 12 * widthRate
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            text: qsTr("我的云盘")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 15 * heightRate
            color: "#666666"
            anchors.left: parent.left
            anchors.leftMargin: 10 * widthRate
            anchors.top:parent.top
            anchors.topMargin: 5 * widthRate
        }

        Image {
            width: 8 * widthRate
            height: 8 * widthRate
            source: "qrc:/miniClassImage/xbk_btn_close.png"
            anchors.right: parent.right
            anchors.rightMargin: 10 * widthRate
            anchors.top:parent.top
            anchors.topMargin: 8 * widthRate
            MouseArea
            {
                id:mousOne
                anchors.fill:parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked:
                {
                    cloudDiskView.visible = false;
                }
            }
        }

        Text {
            text: qsTr("重新加载")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 13 * heightRate
            color: "#666666"
            anchors.right: parent.right
            anchors.rightMargin: 35 * widthRate
            anchors.top:parent.top
            anchors.topMargin: 5 * widthRate
            MouseArea
            {
                anchors.fill: parent

                onClicked:
                {
                    //reload

                }
            }
        }

        Image {
            width: 16 * widthRate * 0.5
            height: 17 * widthRate * 0.5
            source: "qrc:/miniClassImage/xbk_icon_refresh.png"
            anchors.right: parent.right
            anchors.rightMargin: 75 * widthRate
            anchors.top:parent.top
            anchors.topMargin: 7 * widthRate
            MouseArea
            {
                anchors.fill:parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked:
                {
                    enabled = false;
                    loadIngItem.visible = true;
                    if(currentPageIndex == 0 || fileIdBufferList[currentPageIndex] == "0")
                    {                        
                        resetCloudDiskViewData(miniMgr.getCloudDiskInitFileInfo(),"0",false)
                    }else
                    {
                        resetCloudDiskViewData(miniMgr.getCloudDiskFolderInfo(fileIdBufferList[currentPageIndex]), fileIdBufferList[currentPageIndex],false );
                    }
                    enabled = true;
                }
            }
        }

        Rectangle{
            width: parent.width
            height: 1
            color: "#EEEEEE"
            anchors.centerIn: parent
        }

        Row{
            width: 80 * widthRate
            height: 10 * widthRate
            spacing: 8 * widthRates
            anchors.left: parent.left
            anchors.leftMargin: 5 * widthRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8 * widthRate
            Image {
                width: 11 * widthRate * 0.7
                height: 12 * widthRate * 0.7
                source: "qrc:/miniClassImage/backMika@3x.png"
                MouseArea
                {
                    anchors.fill:parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    enabled: currentPageIndex > 0
                    onClicked:
                    {
                        --currentPageIndex;
                        loadIngItem.visible = true;
                        if(currentPageIndex == 0 || fileIdBufferList[currentPageIndex] == "0")
                        {                            
                            resetCloudDiskViewData(miniMgr.getCloudDiskInitFileInfo(),"0",false)
                        }else
                        {
                            resetCloudDiskViewData(miniMgr.getCloudDiskFolderInfo(fileIdBufferList[currentPageIndex]), fileIdBufferList[currentPageIndex],false );
                        }
                    }
                }
            }

            Rectangle{
                height: 12 * widthRate * 0.7
                width: 31 * widthRate
                Text {
                    text: qsTr("我的云盘")
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 13 * heightRate
                    color: "#999999"
                    anchors.centerIn: parent
                }
            }

            Image {
                width: 11 * widthRate * 0.7
                height: 12 * widthRate * 0.7
                source: "qrc:/miniClassImage/nextMika@3x.png"
                MouseArea
                {
                    anchors.fill:parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    enabled: fileIdBufferList.length > 1 && (currentPageIndex != fileIdBufferList.length -1)
                    onClicked:
                    {
                        ++currentPageIndex;
                        loadIngItem.visible = true;
                        resetCloudDiskViewData(miniMgr.getCloudDiskFolderInfo(fileIdBufferList[currentPageIndex]), fileIdBufferList[currentPageIndex],false );
                    }
                }
            }

        }

        Text {
            text: qsTr("共") + cloudViewModel.count + "项"
            height: 10 * widthRate
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 12 * heightRate
            color: "#999999"
            anchors.right: parent.right
            anchors.rightMargin: 10 * widthRates
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8 * widthRate
        }

    }

    Row{
        width: cloudDiskView.width
        height: 10 * widthRate
        spacing: 8 * widthRates
        anchors.left: parent.left
        anchors.leftMargin: 21 * widthRate
        anchors.top: headItem.bottom
        //anchors.topMargin: 5 * widthRate
        z:2
        Item {
            height: 20 * widthRate * 0.7
            width: 30 * widthRate

            Text {
                text: "文件名字"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 13 * heightRate
                color: "#333333"
            }
        }

        Item{
            height: 12 * widthRate * 0.7
            width: 261 * widthRate
        }

        Item{
            height: 12 * widthRate * 0.7
            width: 101 * widthRate
            Text {
                text: "大小"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 13 * heightRate
                color: "#333333"
            }
        }

        Item{
            height: 12 * widthRate * 0.7
            width: 201 * widthRate
            Text {
                text: "修改日期"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 13 * heightRate
                color: "#333333"
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
        height: parent.height - headItem.height - 20 * widthRate
        contentWidth: width
        contentHeight:height// cloudViewModel.count * 25 * heightRate
        anchors.top: headItem.bottom
        anchors.topMargin: 18 * heightRates

        ListView{
            id:lessonListView
            width: parent.width - 60 * heightRate
            height: parent.height - 28 * heightRate
            delegate: contentComponent
            model: cloudViewModel
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
            cacheBuffer: 10000
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
        Rectangle
        {
            height: 25 * widthRate
            width: lessonListView.width
            color: clickArea.containsMouse ? "#EEEEEE" : "white"
            MouseArea
            {
                id:clickArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onDoubleClicked:
                {
                    if(type == 0)//文件夹类型
                    {
                        loadIngItem.visible = true;
                        //缓存当前页数据 fileid
                        resetCloudDiskViewData( miniMgr.getCloudDiskFolderInfo(fileId), fileId ,true);

                    }else if(type == 1)//文件类型
                    {
                        if(isStartLesson == false){
                            openCoursewareView.visible = true;
                            openCoursewareView.suffix = suffix;
                            openCoursewareView.fileId = fileId;
                            return;
                        }
                        selecteCourseware(suffix,fileId);
                    }
                }
            }

            Row {
                width: parent.width
                height: 10 * widthRate
                spacing: 8 * widthRates
                anchors.left: parent.left
                anchors.leftMargin: 15 * widthRate
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8 * widthRate
                Rectangle
                {

                    height: 20 * widthRate * 0.7
                    width: 10 * widthRate
                    color: "transparent"
                    Image {
                        width: 20 * widthRate * 0.5
                        height: 19 * widthRate * 0.5
                        source:  {
                            if(type == 0)
                            {
                                return "qrc:/miniClassImage/xbk_window_file.png";
                            }else
                            {
                                if(suffix.indexOf("pdf") != -1)
                                {
                                    return "qrc:/miniClassImage/xbk_window_pdf.png"
                                }else if(suffix.indexOf("ppt") != -1)
                                {
                                    return "qrc:/miniClassImage/xb_ppt.png"
                                }else if(suffix.indexOf("mp3") != -1 || suffix.indexOf(".wma") != -1 || suffix.indexOf(".wav") != -1)
                                {
                                    return "qrc:/miniClassImage/xb_yinpin.png"
                                }else if(suffix.indexOf("mp4") != -1 || suffix.indexOf(".avi") != -1 || suffix.indexOf(".wmv") != -1 || suffix.indexOf(".rmvb") != -1)
                                {
                                    return "qrc:/miniClassImage/xb_shipin.png"
                                }else if(suffix.indexOf("h5") != -1){
                                    return "qrc:/miniClassImage/h5bgimg.png";
                                }
                                return""
                            }
                        }
                        anchors.centerIn: parent

                    }
                }

                Rectangle{
                    height: 12 * widthRate * 0.7
                    width: 281 * widthRate
                    color: "transparent"
                    Text {
                        text: name
                        width:parent.width -  5 * widthRate
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 13 * heightRate
                        color: "#666666"
                        elide:Text.ElideRight
                    }
                }

                Rectangle{
                    height: 12 * widthRate * 0.7
                    width: 101 * widthRate
                    color: "transparent"
                    Text {
                        text: sizeHuman
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 13 * heightRate
                        color: "#666666"
                    }
                }

                Rectangle{
                    height: 12 * widthRate * 0.7
                    width: 201 * widthRate
                    color: "transparent"
                    Text {
                        text:
                        {
                            var allTime = new Date(updateDate);
                            return allTime.toLocaleString().replace("年","-").replace("月","-").replace("日","");
                        }
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 13 * heightRate
                        color: "#999999"
                    }
                }
            }
        }
    }
    YMLoadingStatuesView
    {
        id:loadIngItem
        width: parent.width - 60 * heightRate
        height: parent.height - 20 * widthRates
        anchors.top:parent.top
        anchors.topMargin: 30 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter
        z:100
    }

    function selecteCourseware(suffix,fileId){
        var fileUrl;
        var imgUrlList
        if(suffix.indexOf("pdf") != -1 || suffix.indexOf("ppt") != -1)
        {
            //获取课件Url发送课件Url
            coursewareType = 1;
            imgUrlList = miniMgr.getCloudDiskFileInfo(fileId).data.images;
            console.log("uffix.indexOf(pdf)",imgUrlList)
            sigCurrentBeOpenedCoursewareUrl(imgUrlList,fileId,"",coursewareType);
        }else if(suffix.indexOf("h5") != -1){
            coursewareType = 3;
            imgUrlList  = miniMgr.getCloudDiskFileInfo(fileId);
            var h5Url = imgUrlList.data.path;
            console.log("==h5::data==",fileId,h5Url);
            var coursewareList = [];
            for(var i = 0; i < h5CoursewarePageTotal;i++){
                coursewareList.push("");
            }
            console.log("=====h5CoursewarePageTotal=====",h5CoursewarePageTotal);
            sigCurrentBeOpenedCoursewareUrl(coursewareList,fileId,h5Url,coursewareType);
        }else if(suffix.indexOf("mp3") != -1 || suffix.indexOf("wma") != -1 || suffix.indexOf("wav") != -1)
        {
            //获取音频Url 发送出去
            var obj = miniMgr.getCloudDiskFileInfo(fileId).data;
            if(obj == undefined || obj.path == undefined){
                return;
            }
            fileUrl = obj.path;
            console.log("mp3 path",fileUrl)
            sigCurrentBePlayedAudioUrl(fileUrl,fileId,obj.name);
        }else if(suffix.indexOf("mp4") != -1 || suffix.indexOf("avi") != -1 || suffix.indexOf("wmv") != -1 || suffix.indexOf("rmvb") != -1)
        {
            //获取视频Url 发送出去
            var objs = miniMgr.getCloudDiskFileInfo(fileId).data;
            if(objs == undefined || objs.path == undefined){
                return;
            }
            fileUrl = objs.path;
            sigCurrentBePlayedVideoUrl(fileUrl,fileId,objs.name);
        }
    }

    function resetCloudDiskViewData(arrData,fileId,isNewFolder)
    {
        //isNewFolder 为true是通过点击文件夹来来获取文件详情的 为false 是通过back forward 来获取数据的

        //如果是文件夹被打开 要判断这次打开的文件夹 是不是新的文件夹 还是之前已经打开过的文件夹
        //如果是新的被打开过的文件夹 且其同级目录之前被打开过 就用现在打开的文件夹替代之前打开的
        //如果这次打开的文件夹 是上一次打开的文件夹 不做替换
        if(isNewFolder)
        {
            //判断是否存在
            var hasExit = 0;
            for(var b = 0; b < fileIdBufferList.length; b++)
            {
                if(fileId == fileIdBufferList[b])
                {
                    currentPageIndex = b;
                    hasExit = 1;
                    break
                }
            }
            if(hasExit == 0)
            {
                //判断当前的index 进行文件夹路线清理 只清理当前级以后的文件路径
                var tempList = [];
                for(var c = 0; c < currentPageIndex + 1; c++)
                {
                    if(fileIdBufferList.length - 1 >= c)
                    {
                        tempList.push(fileIdBufferList[c])
                    }
                }
                fileIdBufferList = tempList;
                fileIdBufferList.push(fileId);
                currentPageIndex = fileIdBufferList.length - 1;

            }else
            {

            }

        }else
        {

        }

        cloudViewModel.clear();

        //数据暂存

        //重置数据
        console.log("resetCloudDiskViewData",fileIdBufferList.length,currentPageIndex,JSON.stringify(arrData))
        for(var a = 0; a<arrData.length; a++)
        {
            var sizeHuman ;
            if(arrData[a].sizeHuman == "")
            {
                sizeHuman = "";
            }else
            {
                sizeHuman = arrData[a].sizeHuman;
            }

            cloudViewModel.append(
                        {
                            "fileId": arrData[a].fileId,
                            "name": arrData[a].name,
                            "suffix": arrData[a].suffix,
                            "sizeHuman": sizeHuman,
                            "type": arrData[a].type,
                            "updateDate": arrData[a].updateDate,
                        })

        }
//        cloudViewModel.append(
//                    {
//                        "fileId": "88888888",
//                        "name": "h5课件测试",
//                        "suffix": "html",
//                        "sizeHuman": "666KB",
//                        "type": 1,
//                        "updateDate": "2019-06-06",
//                        "h5Url": "http://sit01-kejian.yimifudao.com/appPreview",
//                    })
        loadIngItem.visible = false;
    }

}

