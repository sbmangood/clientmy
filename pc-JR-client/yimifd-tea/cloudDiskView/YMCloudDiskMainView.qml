import QtQuick 2.0
import QtQuick.Controls 1.4
import "./Configuration.js" as Cfg
import QtQuick 2.5
import YMLessonManagerAdapter 1.0

/***云盘首页***/
Item {
    id: cloudDiskView
    width: 510 * widthRate
    height: 404 * heightRate
    focus: true

    property int currentPageIndex: 0; //当前显示页的索引
    property var fileIdBufferList: [];//文件id索引列表
    property var upFileMarkBufferList: [];//上传成功文件列表
    property bool isBigScreen: true;

    signal sigCurrentBeOpenedCoursewareUrl(var imgUrlList, var fileId,var h5Url,var courswareType);//当前要打开的课件图片的UrlList 课件id
    signal sigCurrentBePlayedAudioUrl(var audioUrl, var fileId , var fileName);//当前需要被播放的音频的Url
    signal sigCurrentBePlayedVideoUrl(var videoUrl, var fileId , var fileName);//当前需要被播放的视频的Url
    signal sigCurrentBeOpendImageUrl(var imageUrl, var fileId, var fileName);// 当前需要显示的图片url

    signal sigAccept(var fileUrl); // 确定选择文件信号
    signal sigReject();            // 取消选择文件信号

    signal sigDelFile(var fileId);// 删除文件信号

    property bool isAllSelected: false;// 是否全部选中

    property bool canDelete: false;// 是否有可删除选项
    property var deleteFileIdList: [];// 待删除文件Id列表
    property string coursewareIdValue: "";// 上传到API后得到的课件Id

    onDeleteFileIdListChanged:{
        if(deleteFileIdList.length == 0){
            canDelete = false;
        }
        else{
            canDelete = true;
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

    // 单项选中或单项取消选择信号(内部使用)
    signal sigSelectDelItem(var fileId, bool isSelected);

    onSigSelectDelItem: {
        for(var i = 0; i < cloudViewModel.count; i++){
            if(cloudViewModel.get(i).fileId == fileId){
                if(isSelected){
                    cloudViewModel.get(i).isChecked = "1";
                }
                else{
                    cloudViewModel.get(i).isChecked = "0";
                }
            }
        }
    }

    Image {
        anchors.fill: parent
        id: backImage
        source: "qrc:/cloudDiskImages/bg_pop_netdisc.png"
    }

    Item {
        width: 500 * widthRate
        height: parent.height

        YMLoadingStatuesView {
            id:loadingView
            z: 100
            anchors.fill: parent
            visible: false
            onChangeVisible:{
                loadingView.visible=false;
            }
        }

        // 头部bar
        Item {
            id: headItem
            width: parent.width
            height: 36 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter

            Item {// "课件"title
                width: 36 * widthRate
                height: 36 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: 34 * widthRate
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    width: 36 * widthRate
                    height: 18 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("课件")
                    color: "#FFFFFF"
                    font.pixelSize: 18 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                }
            }

            MouseArea {// 关闭按钮
                id:mousOne
                width: 36 * widthRate
                height: 36 * widthRate
                anchors.right: parent.right
                cursorShape: Qt.PointingHandCursor
                anchors.top: parent.top
                anchors.topMargin: -5 * widthRate
                hoverEnabled: true
                Image {
                    anchors.fill: parent
                    source: "qrc:/cloudDiskImages/btn_pop_close.png"
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked:{
                    cloudDiskView.visible = false;
                }
            }

            MouseArea {// 刷新
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 36 * widthRate
                width: 36 * widthRate
                height: 36 * heightRate
                onClicked:{
                    enabled = false;
                    loadIngItem.visible = true;
                    refreshCloudDisk();
                    enabled = true;
                }
                Image {
                    width: 36 * widthRate
                    height: 36 * widthRate
                    source: "qrc:/cloudDiskImages/btn_pop_refresh.png"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Items栏
        Item {
            id: contentItem
            width: parent.width
            height: {
                   if (isBigScreen)
                       return 30 * heightRate;
                    else
                       return 60 * heightRate;
            }
            anchors.top: headItem.bottom
            // 选择按钮
            Item {
                id: selectBtn
                width: 20 * widthRate
                height: 20 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 14 * widthRate
                Image {
                    anchors.fill: parent
                    id: selectBtnImg
                    source: isAllSelected ? "qrc:/cloudDiskImages/btn_selected.png" : "qrc:/cloudDiskImages/btn_unselected.png"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        var isAllEmpty = true;
                        for(var a = 0; a < cloudViewModel.count; a++){
                            if("" != cloudViewModel.get(a).fileId)
                            {
                                isAllEmpty = false;
                                break;
                            }
                        }
                        if(isAllEmpty)
                        {
                            return;
                        }
                        isAllSelected = !isAllSelected;
                        if(isAllSelected) {
                            for(var i = 0; i < cloudViewModel.count; i++){
                                if("" != cloudViewModel.get(i).fileId)
                                {
                                    deleteFileIdList.push(cloudViewModel.get(i).fileId);
                                }
                                cloudViewModel.get(i).isChecked = "1";
                            }
                        }
                        else {
                            deleteFileIdList = [];
                            for(var j = 0; j < cloudViewModel.count; j++){
                                cloudViewModel.get(j).isChecked = "0";
                            }
                        }
                        canDelete = deleteFileIdList.length != 0;
                    }
                }
            }
            // 文件名称
            Item {
                id: fileNameItem
                width: 52 * widthRate
                height: 13 * heightRate
                anchors.left: selectBtn.right
                anchors.leftMargin: 3 * widthRate
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    id: fileName
                    text: qsTr("文件名称")
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    anchors.left: parent.left
                    color: "#FFFFFF"
                    font.pixelSize: 13 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                }
            }
            // 状态
            Item {
                id: statusItem
                width: 26 * widthRate
                height: 13 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: 258 * widthRate
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    id: statusName
                    text: qsTr("状态")
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    anchors.left: parent.left
                    color: "#FFFFFF"
                    font.pixelSize: 13 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                }
            }
            // 修改日期
            Item {
                id: dateItem
                width: 52 * widthRate
                height: 13 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: 379 * widthRate
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    id: dateName
                    anchors.fill: parent
                    text: qsTr("修改日期")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    color: "#FFFFFF"
                    font.pixelSize: 13 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                }
            }
        }

        // 列表
        Flickable {
            id: filckable
            z: 1
            width: parent.width
            height: 296 * heightRate
            contentWidth: width
            contentHeight: height
            anchors.top: contentItem.bottom
            ListView {
                id: lessonListView
                width: parent.width
                height: parent.height
                delegate: contentComponent
                model: cloudViewModel
                //anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                clip: true
            }
        }

        // 底部bar
        Item {
            width: parent.width
            height: 42 * heightRate
            anchors.bottom: parent.bottom

            // 选择文件上传控件
            YMUploadFileControl {
                id: btnUplod
                z: 10
                width: 116 * widthRate
                height: 32 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin:  10 * widthRate
                onSigAccepted: {
                    sigAccept(fileUrl);
                }
                onSigRejected: {
                    sigReject();
                }
            }
            // 删除文件按钮
            Rectangle {
                id: delBtn
                width: 116 * widthRate
                height: 32 * heightRate
                anchors.left: btnUplod.right
                anchors.leftMargin: 8 * widthRate
                anchors.verticalCenter: parent.verticalCenter
                color: canDelete ? "#39C5A8" : "#424458"
                enabled: canDelete
                radius: 2 * heightRate
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        var fileId = "";
                        sigDelFile(fileId);
                    }
                }
                Text {
                    id: delTxt
                    text: qsTr("删除")
                    anchors.centerIn: parent
                    color: canDelete ? "#FFFFFF" : "#636682"
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 16 * heightRate
                }
            }
            //文件支持类型
            Rectangle{
                id: fileInfoBtn
                width: 110 * widthRate
                height: 32 * heightRate
                anchors.left: delBtn.right
                anchors.leftMargin: 120 * widthRate
                anchors.verticalCenter: parent.verticalCenter
                color: "#39C5A8"
                radius: 2 * heightRate
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: {
                        fileInfoTxt.color = "#4D90FF";
                        fileInfo.visible = true;

                    }
                    onExited: {
                        fileInfoTxt.color = "#ffffff";
                        fileInfo.visible = false;
                    }
                }
                Text {
                    id: fileInfoTxt
                    text: qsTr("文件支持类型")
                    anchors.centerIn: parent
                    color:"#636682"
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 16 * heightRate
                }
        }
        }
        //网络显示提醒
        Rectangle {
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

        ListModel {
            id: cloudViewModel
        }

        Component {
            id: contentComponent
            Item {
                height: upFileMark != 1 ? 42 * widthRate : 0
                width: cloudDiskView.width
                visible: upFileMark != 1
                enabled: upFileMark != 1

                Rectangle {
                    id: item_background
                    height: parent.height
                    width: 500 * widthRate
                    color: "#39C5A8"
                    visible: false
                }

                Item {
                    width: parent.width
                    height: 20 * widthRate
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        id: clickArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onDoubleClicked:{
                            courseListManager.runCourse(currentLessonInfo);
                        }

                        onEntered: {
                            item_background.visible = true;
                        }

                        onExited: {
                            item_background.visible = false;
                        }
                    }

                    // 选择控件
                    Item {
                        id: selItem
                        width: 20 * widthRate
                        height: 20 * heightRate
                        anchors.left: parent.left
                        anchors.leftMargin: 14 * widthRate
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            anchors.fill: parent
                            id: selectBtnImg
                            source: (isAllSelected || isChecked == "1") ? "qrc:/cloudDiskImages/btn_selected.png" : "qrc:/cloudDiskImages/btn_unselected.png"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                var isSelected = false;
                                if(isChecked == "0"){
                                    isSelected = true;
                                }
                                else{
                                    isSelected = false;
                                }
                                if(isSelected){
                                    console.log("=====isSelected=====", fileId)
                                    deleteFileIdList.push(fileId);
                                }
                                else {
                                    console.log("=====cancelSelected=====", fileId)
                                    var index = deleteFileIdList.indexOf(fileId);
                                    if (index > -1) {
                                        deleteFileIdList.splice(index, 1);
                                    }
                                }
                                canDelete = deleteFileIdList.length != 0;
                                sigSelectDelItem(fileId, isSelected);
                            }
                            onEntered: {
                                item_background.visible = true;
                            }

                            onExited: {
                                item_background.visible = false;
                            }
                        }
                    }
                    // 文件类型图标
                    Item {
                        id: typeImg
                        width: 20 * widthRate
                        height: 20 * heightRate
                        anchors.left: selItem.right
                        anchors.leftMargin: 4 * widthRate
                        Image {
                            anchors.fill: parent
                            source:  {
                                var suffix_lower = suffix.toLowerCase();
                                if(suffix_lower.indexOf("pdf") != -1){
                                  return "qrc:/cloudDiskImages/ico_pop_pdf.png"
                                }else if(suffix_lower.indexOf("ppt") != -1){
                                  return "qrc:/cloudDiskImages/ico_pop_ppt.png"
                                }else if(suffix_lower.indexOf("doc") != -1){
                                  return "qrc:/cloudDiskImages/ico_pop_word.png"
                                }else if(suffix_lower.indexOf("h5") != -1) {
                                  return "qrc:/cloudDiskImages/ico_pop_h5.png"
                                }else if (suffix_lower.indexOf("mp3") != -1){
                                  return "qrc:/cloudDiskImages/ico_pop_mp3.png"
                                }else if (suffix_lower.indexOf("mp4") != -1){
                                  return "qrc:/cloudDiskImages/ico_pop_view.png"
                                } else {
                                  return "qrc:/cloudDiskImages/ico_pop_photo.png"
                                }
                            }
                            anchors.centerIn: parent
                        }
                    }

                    // 文件名称
                    Item {
                        id: fileNameItem
                        height: parent.height
                        width: 155 * heightRate
                        anchors.left: typeImg.right
                        anchors.leftMargin: 18 * widthRate
                        Text {
                            text: name
                            anchors.fill: parent
                            anchors.left: parent.left
                            font.family: Cfg.DEFAULT_FONT
                            font.pixelSize: 12 * heightRate
                            color: clickArea.containsMouse ? "#ffffff" : "#999999"
                            elide:Text.ElideRight
                        }
                    }
                    // 状态
                    Item {
                        id: statusItem
                        height: 13 * widthRate
                        width: 52 * heightRate
                        anchors.left: parent.left
                        anchors.leftMargin: 258 * widthRate
                        Text {
                            anchors.fill: parent
                            anchors.left: parent.left
                            text: status == 0 ? "上传中...":status == 1 ? "上传成功" : "上传失败"
                            font.family: Cfg.DEFAULT_FONT
                            font.pixelSize: 12 * heightRate
                            color: clickArea.containsMouse ? "white" :( status == 0 ? "#FFD800":status == 1 ? "#35D0B0" : "#FF5959")
                        }
                    }
                    // 日期
                    Item {
                        id: dateItem
                        height: 12 * widthRate
                        width: 109 * heightRate
                        anchors.left: parent.left
                        anchors.leftMargin: 379 * widthRate
                        Text {
                            anchors.fill: parent
                            anchors.left: parent.left
                            text: updateDate
                            font.family: Cfg.DEFAULT_FONT
                            font.pixelSize: 12 * heightRate
                            color: clickArea.containsMouse ? "#ffffff" : "#999999"
                        }
                    }
                }

                Rectangle {
                    color: "#4E5067"
                    width: parent.width
                    height: 1
                    anchors.bottom: parent.bottom
                }
            }
        }

        YMLoadingStatuesView {
            id:loadIngItem
            width: parent.width - 60 * heightRate
            height: parent.height - 20 * widthRate
            anchors.top:parent.top
            anchors.topMargin: 30 * widthRate
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    YMLessonManagerAdapter
    {
        id:courseListManager
        onSigCloudDiskInfo: {
            console.log("\n====ClassInfoManager::onSigCloudDiskInfo====", JSON.stringify(clouddiskInfo),"\n")
            diskMainView.resetCloudDiskViewData(clouddiskInfo)
        }

        onSigSaveResourceSuccess: {
            diskMainView.addUpFileMarkToBufferList(upFileMark);
            // 如果不是ppt/pptx、pdf、doc/docx格式则直接刷新云盘，无需轮询转换状态
            var suffix_lower = suffix.toLowerCase();// 文件后缀名有可能是大写，这里统一转成小写处理，防止遗漏大写后缀名文件
            if(!(suffix_lower.indexOf("ppt") != -1 || suffix_lower.indexOf("pdf") != -1 || suffix_lower.indexOf("doc") != -1)){
                refreshCloudDisk();
                return;
            }
            coursewareIdValue = coursewareId;
            findStatusTimer.start();
        }

        onSigSaveResourceFailed: {
            diskMainView.updateUpLoadingStatus(upFileMark, 2);
            setTips("上传资源失败");
        }

        onSigFindFileStatus: {// status 转换状态 0-转换中 1-成功 2-失败
            if(status == 0){
                refreshCloudDisk();// 查询到转换中也刷新一下云盘，云盘才能显示出"上传中"状态
            }
            else if(status == 1 || status == 2){
                if(status == 1){
                    setTips("上传资源成功");
                }
                else if(status == 2){
                    setTips("上传资源失败");
                }

                findStatusTimer.stop();
                refreshCloudDisk();// 查询到课件转码成功或失败结果后，则停止轮询，再刷新一下云盘列表，云盘显示出"上传成功"或"上传失败"状态
            }
        }

        onSigDeleteResult: {// 课件删除结果
            if(isSuccess){// 删除成功从云盘删除，避免API返回列表数据仍存在
                diskMainView.removeCourseware(coursewareId);
                diskMainView.clearDeletingFileList();
            }
            else {
                setTips("课件删除失败!");
            }
        }
    }
    // 轮询上传课件转码状态定时器
    Timer {
        id: findStatusTimer
        interval: 2000
        running: false
        repeat: true
        onTriggered: {
            var apiUrl = "";
            var appId = "";
            courseListManager.findFileStatus(coursewareIdValue, apiUrl, appId);
        }
    }
    function getCloudDiskList(roomId,isRefreshCloudDisk)
    {
        courseListManager.getCloudDiskList(roomId,"","",isRefreshCloudDisk);
    }
    function resetCloudDiskViewData(arrData){
        var hasUpFile = false;
        for(var b = 0; b < cloudViewModel.count; b++)
        {
            //console.log("resetcloudViewModel:",cloudViewModel.get(b).upFileMark);

            if(cloudViewModel.get(b).upFileMark == ""){
                cloudViewModel.get(b).upFileMark = "1";
                continue;
            }else if("" != cloudViewModel.get(b).upFileMark && "1" != cloudViewModel.get(b).upFileMark)//有正在上传的文件
            {
                hasUpFile = true;
                for(var c = 0; c < upFileMarkBufferList.length; c++)
                {
                    if(cloudViewModel.get(b).upFileMark == upFileMarkBufferList[c])
                    {
                        cloudViewModel.get(b).upFileMark = "1";
                        break;
                    }
                }
            }
        }

        if(!hasUpFile)
        {
            cloudViewModel.clear();
        }

        //cloudViewModel.clear(); //clear重置数据,只能重置字段对应的值，无法重置字段，ListModel必须始终保持相同数量和名字的字段
        //console.log("===111====",JSON.stringify(arrData))
        for(var a = 0; a < arrData.length; a++){
            cloudViewModel.append(
                        {
                            "fileId": arrData[a].id,
                            "name": arrData[a].name,
                            "docType": arrData[a].docType,
                            "suffix": arrData[a].docType,
                            "updateDate": arrData[a].date,
                            "upFileMark":"",
                            "totalPage": arrData[a].type == 2 ? arrData[a].endPage : arrData[a].type == 3 ? arrData[a].endPage: arrData[a].totalPage,
                                                                                                            "path": arrData[a].path,// "http://sit01-kejian.yimifudao.com/appPreview?courseware=110&appid=kiFBIeLYvxOuWFgwWOy1XFFFehdA2ovo&type=5&roomid=355666076073201664",//arrData[a].path,
                                                                                                            "type": arrData[a].type, // 资源类型（0：h5资源，1：音视频资源（mp3、mp4），2：静态资源（pdf、word），3：动态资源（ppt），4：图片
                                                                                                            "status": arrData[a].status,// 转换状态 0-转换中 1-成功 2-失败
                                                                                                            "isChecked": "0"// 是否被选中，0：未选中，1：选中
                        });
        }
        loadIngItem.visible = false;
    }

    // 添加上传文件到列表中
    function addUpLoadingFile(fileName, suffix, status, upFileMark){
        var resourceType = 0;
        var suffix_lower = suffix.toLowerCase();
        if(suffix_lower.indexOf("mp3") != -1 || suffix_lower.indexOf("mp4") != -1){
            resourceType = 1;
        }
        else if(suffix_lower.indexOf("pdf") != -1 || suffix_lower.indexOf("word") != -1){
            resourceType = 2;
        }
        else if(suffix_lower.indexOf("ppt") != -1){
            resourceType = 3;
        }
        else{
            resourceType = 4;
        }

        cloudViewModel.insert(0,
                              {
                                  "fileId": "",
                                  "name": fileName,
                                  "docType": suffix,
                                  "suffix": suffix,
                                  "updateDate": "---", // 正在上传的文件显示"--"
                                  "totalPage": 0,
                                  "path": "",
                                  "type": resourceType, // 资源类型（0：h5资源，1：音视频资源（mp3、mp4），2：静态资源（pdf、word），3：动态资源（ppt），4：图片
                                  "status": status,
                                  "upFileMark":upFileMark,
                                  "isChecked": "0"// 是否被选中，0：未选中，1：选中
                              });
    }

    // 获取当前时间
    function getCurrentTime(){
        var myDate = new Date();
        var myYear = myDate.getFullYear();
        var myMonth = myDate.getMonth() + 1 < 10 ? "0" + (myDate.getMonth() + 1) : (myDate.getMonth() + 1);
        var myDay =  myDate.getDate() < 10 ? "0" + myDate.getDate() : myDate.getDate();
        var myHour = myDate.getHours() < 10 ? "0" + myDate.getHours() : myDate.getHours();
        var myMinutes = myDate.getMinutes() < 10 ? "0" + myDate.getMinutes() : myDate.getMinutes();
        var mySeconds = myDate.getSeconds() < 10 ? "0" + myDate.getSeconds() : myDate.getSeconds();
        var timeStr = myYear + "-" + myMonth + "-" + myDay + " " + myHour + ":" + myMinutes + ":" + mySeconds;
        return timeStr;
    }

    // 更新上传文件状态
    function updateUpLoadingStatus(upFileMark, status){
        for(var i = 0; i < cloudViewModel.count; i++){
            if(cloudViewModel.get(i).upFileMark == upFileMark){
                //console.log("=======updateUpLoadingStatus=====",upFileMark,status)
                cloudViewModel.get(i).status = status;
                break;
            }
        }
    }

    // 得到待删除文件Id列表
    function getDeletingFileList(){
        return deleteFileIdList;
    }

    // 清空待删除列表
    function clearDeletingFileList(){
        deleteFileIdList = [];
        isAllSelected = false;
    }


    // 去除删除的课件
    function removeCourseware(coursewareId){
        for(var i = 0; i < cloudViewModel.count; i++){
            if(cloudViewModel.get(i).fileId == coursewareId){
                cloudViewModel.remove(i);
            }
        }
    }

    function addUpFileMarkToBufferList(upFileMark)
    {
        upFileMarkBufferList.push(upFileMark);
    }

    function deleteCourseware(fileIdList, lessonId, apiUrl, appId)
    {
        courseListManager.deleteCourseware(fileIdList, lessonId, apiUrl, appId);
    }

    function upLoadCourseware(upFileMark, roomId, userId, fileUrl, fileSize, apiUrl, appId)
    {
        courseListManager.upLoadCourseware(upFileMark, roomId, userId, fileUrl, fileSize, apiUrl, appId);
    }
    // 刷新云盘
    function refreshCloudDisk(){
        var classroomId = currentClassroomId;
        var apiUrl = "";
        var appId = "";
        courseListManager.getCloudDiskList(classroomId, apiUrl, appId);
    }
}


