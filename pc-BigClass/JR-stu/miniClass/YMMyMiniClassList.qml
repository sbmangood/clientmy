import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "./../Configuration.js" as Cfg

//我的课程
Rectangle {
    id:myMiniClassList
    anchors.fill: parent
    radius: 12
    border.color: "#e0e0e0"
    border.width: 1

    property var bufferJson: [];
    property string currentClassId: "";

    signal sigCourseCatalog(var id,var dataJson);
    signal sigRoback();

    //在"课程详情"页面, 点击返回按钮
    function goBack()
    {
        miniClassDetails.visible = false;
        myMiniClassList.visible = true;
        backArea.visible = false;
    }

    function resetPageView()
    {
        miniClassDetails.visible = false;
        selectRecord.visible = false;
    }

    function resetDataModel(lessonInfo)
    {
        talkCloudModel.clear();

        var data = lessonInfo.data;
        var lists = data.list;

        for(var i = 0; i < lists.length; i++){

            var teacher = lists[i].teachers;
            var name,headUrl;
            if(teacher.length == 0)
            {
                name = "";
                headUrl = "";
            }else
            {
                name = teacher[0].name;
                headUrl = teacher[0].headUrl;
            }
            talkCloudModel.append(
                        {
                            currentIndexs: (i + 1).toString(),
                            classId: lists[i].classId,
                            name: lists[i].name,
                            bigCoverUrl: lists[i].bigCoverUrl,
                            categoryName: lists[i].categoryName,
                            startTime: lists[i].startTime,
                            endTime: lists[i].endTime,
                            teachText: name,
                            headImagUrl: headUrl
                        });
        }
    }

    Timer {
        id:tipsTimer
        interval: 3000;
        repeat: false
        running: false
        onTriggered: {
            tips.visible = false
        }
    }

    Rectangle
    {
        id:tips
        width: 180 * widthRates
        height: 30 * widthRates
        z:1008
        color: "#fff9f6"
        anchors.centerIn: parent
        visible: false
        Text {
            anchors.centerIn: parent
            text: qsTr("暂不为家长开放此功能哦~~")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 12 * widthRates
            color: "#666666"
        }
        onVisibleChanged: {
            if(visible)
            {
                tipsTimer.start();
            }
        }
    }

    //录播页面
    YMMiniClassSelectRecord{
        id:selectRecord
        anchors.fill: parent
        z:1004
        visible: false
    }

    //课程详情
    YMMyMiniClassDetail
    {
        id:miniClassDetails
        anchors.fill: parent
        z:1003
        visible: false

        onGetListData:
        {
            miniClassDetails.resetDataBuffer(miniLessonManager.getMiniLessonMyLessonItemInfo(classId,type));
        }

        onGetRecorded:
        {
//            if(isStageEnvironment == false){//兼容拓课云录播如果自研上线则不需要此代码
//                var tData = miniLessonManager.getEnterClass(classId,"3").data;
//                selectRecord.resetModelData(tData,nameIndex,classname);
//                selectRecord.visible = true;
//                return;
//            }

            var tData = miniLessonManager.getPlayBack(classId);
            if(tData.platform == 2)
            {
                return;
            }
            selectRecord.resetModelData(tData.list,nameIndex,classname);
            console.log("==onGetRecorded==",JSON.stringify(tData),nameIndex,classname);
            selectRecord.visible = true;
        }

        onDoHomeWork:
        {
            if(!isStudentUser){
                tips.visible = true;
                return;
            }
        }

        onGoTest:
        {
            if(!isStudentUser){
                tips.visible = true;
                return;
            }
        }

        onEnterClass:
        {
            console.log("=======isStudentUser======",isStudentUser)
            if(!isStudentUser){
                tips.visible = true;
                return;
            }
            if(windowView.isPlatform == false){
               var jsonDataObj = miniLessonManager.getTalkEnterClass(classId,handleStatus);
                var path = jsonDataObj.data[0].path;
                coludWebviewT.visible = true;
                coludWebviewT.resetWebViewUrl(path);
                //Qt.openUrlExternally(path);
                return;
            }

            var tData = miniLessonManager.getEnterClass(classId);
            if(tData.path == "" || tData.path == undefined)
            {
                console.log("====tData.path====");
                return;
            }
            windowView.isMiniClassroom = true;
            coludWebviewT.visible = true;
            coludWebviewT.resetWebViewUrl(tData.path);
        }

        onGetCourse:{
            //classId 获取课件
            miniLessonManager.getLookCourse(classId);
        }
    }


    Rectangle {
        anchors.fill: parent
        color: "white"
        radius: 12
    }

    Rectangle{
        id:noLessonItem
        anchors.fill: parent
        color: "white"

        z:1000
        visible: talkCloudModel.count <= 0
        Item{
            width: parent.width * 0.5
            height: parent.height * 0.5
            anchors.centerIn: parent

            Image {
                id:noLessonImage
                width: 100 * widthRates
                height: 100 * widthRates * (362 / 280) //说明: 362 / 280  是png图片原始的宽度, 高度
                source: "qrc:/miniClassImg/xb_empty_nocontant@2x.png"
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.5 + 65 * heightRate - height
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                font.pixelSize: 14
                color: "#666666"
                text: "暂时没有课程哦"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top:noLessonImage.bottom
                anchors.topMargin: 16 * widthRates
            }
        }

    }

    MouseArea {
        anchors.fill: parent
        onClicked:{
            return;
        }
    }

    //返回按钮(现在这个已经不需要了, 隐藏掉)
    MouseArea{
        id: backRec
        width: 25 * widthRate
        height: 25 * widthRate
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 5 * widthRate
        anchors.leftMargin: 5 * widthRate
        visible: false        
        cursorShape: Qt.PointingHandCursor
        z:1002

        Image {
            anchors.fill: parent
            source: "qrc:/miniClassImg/xbk_btn_back@2x.png"
        }

        onClicked:{
            myMiniClassList.visible = false;
            rowBar.visible = true;
        }

    }

    //按键盘上下进行滚动页面
    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Up:
            if(talkCloudGridView.contentY > 0){
                talkCloudGridView.contentY -= 20;
            }
            break;
        case Qt.Key_Down:
            if(button.y < scrollbar.height - button.height){
                talkCloudGridView.contentY += 20;
            }
            break;
        default:
            return;
        }
        event.accepted = true
    }

    //滚动条
    Item {
        id: scrollbar
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 12 * heightRate
        width:10 * widthRate
        height: parent.height - 20 * heightRate
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
            y: talkCloudGridView.visibleArea.yPosition * scrollbar.height
            width: 4 * widthRate
            height: talkCloudGridView.visibleArea.heightRatio * scrollbar.height;
            color: "#cccccc"
            radius: 4 * widthRate
            opacity: 0.5
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
                    talkCloudGridView.contentY = button.y / scrollbar.height * talkCloudGridView.contentHeight
                }
            }
        }
    }

    GridView{
        id: talkCloudGridView
        width: parent.width * 0.29 * 3
        height: parent.height - 65 * widthRates
        //anchors.horizontalCenter: parent.horizontalCenter
        cellWidth: parent.width * 0.29
        cellHeight: cellWidth * 1.12
        model: talkCloudModel
        delegate: talkcomponent
        anchors.top: parent.top
        anchors.topMargin: 12 * widthRates //backRec.height + 8 * widthRates
        anchors.left: parent.left
        anchors.leftMargin: 62 * widthRates
        clip: true

        onContentYChanged: {
            if(contentY >= contentHeight - height ){
                tipsText.visible = true;
            }else{
                tipsText.visible = false;
            }
        }
    }

    Text {
        id: tipsText
        text: qsTr("没有更多课程了~~")
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 12 * widthRates
        color: "#333333"
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 5 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
    }

    ListModel{
        id: talkCloudModel
    }

    Component{
        id: talkcomponent
        Rectangle{
            width: talkCloudGridView.cellWidth - 20 * heightRate
            height: talkCloudGridView.cellHeight - 20 * heightRate
            radius: 4 * heightRate
            clip: true

            //点击按钮
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                //背景颜色
                Rectangle{
                    color: "#f9f9f9"
                    width: parent.width
                    height: parent.height
                    radius: 4 * heightRate
                    border.width: 2
                    border.color: parent.containsMouse ? "#e0e0e0" : "#f9f9f9"
                }

                onClicked: {
                    console.log("=========click=========");
                    var jsonData = {
                        "classId": classId,
                        "name": model.name,
                        "teachText": teachText,
                        "headImagUrl": headImagUrl,
                        "bigCoverUrl": bigCoverUrl,
                        "categoryName": categoryName,
                        "startTime": startTime,
                        "endTime":endTime,
                    }
                    sigCourseCatalog(classId,jsonData);
                    bufferJson = jsonData;
                    currentClassId = classId;
                    miniClassDetails.topItemDataBuffer = jsonData;
                    miniClassDetails.resetDataBuffer(miniLessonManager.getMiniLessonMyLessonItemInfo(classId,"0"));
                    miniClassDetails.visible = true;
                    backArea.visible = true; //点击了其中某一个item以后, 返回按钮的visible设置为true
                }
            }

            //课程图文
            Image{
                id: lessonImg
                asynchronous: true
                width: parent.width - 5 * widthRates
                height: width / 1.768
                source: bigCoverUrl
                anchors.top:parent.top
                anchors.topMargin: 3 * widthRates
                anchors.horizontalCenter: parent.horizontalCenter
                sourceSize.width: width
                sourceSize.height: height
            }

            Text{
                id: classText
                width: parent.width - 12 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: 15 * heightRate
                anchors.top: lessonImg.bottom
                anchors.topMargin: parent.height * 0.025
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * widthRates
                color: "#333333"
                text: model.name.length > 10 ? model.name.substring(0,13) + "..." : model.name
                wrapMode: Text.WordWrap
            }

            Column{
                width: parent.width - lessonImg.width - 20 * heightRate
                height: parent.height - 45 * heightRate
                anchors.top: classText.bottom
                anchors.topMargin: parent.height * 0.0387
                anchors.left: parent.left
                anchors.leftMargin: 15 * heightRate
                spacing: parent.height * 0.0352

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 12 * widthRates
                    text: qsTr("开课时间：") + categoryName
                    color: "#666666"
                }

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 12 * widthRates
                    text: qsTr("上课时段：") + startTime + "-" + endTime
                    color: "#666666"
                }

                //头像和老师名称
                Item{
                    id: headButton
                    width: 45 * heightRate
                    height: 45 * heightRate
                    visible: true

                    Rectangle{
                        id: rundItem
                        radius: 100
                        width: 45 * heightRate
                        height: 45 * heightRate
                        anchors.centerIn: parent
                    }

                    Image{
                        id: headImage
                        visible: false
                        width: 45 * heightRate
                        height: 45 * heightRate
                        anchors.centerIn: parent
                        source: headImagUrl == "" ? "qrc:/miniClassImg/defult_profile.png" : headImagUrl
                        smooth: false
                    }

                    OpacityMask{
                        anchors.fill: rundItem
                        source: headImage
                        maskSource: rundItem
                    }

                    Text{
                        text: teachText
                        anchors.left: rundItem.right
                        anchors.leftMargin: 10 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 10 * widthRates
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#666666"
                    }
                }
            }

        }
    }

    Component.onCompleted: {
        talkCloudModel.append(
                    {
                        currentIndexs: "",
                        classId: "",
                        name: "",
                        bigCoverUrl: "",
                        categoryName: "",
                        startTime: "",
                        endTime: "",
                        teachText: "",
                        headImagUrl: ""
                    });
    }


    function refreshPage(){
        if(miniClassDetails.visible == true){
            miniClassDetails.topItemDataBuffer = bufferJson;
            miniClassDetails.resetDataBuffer(miniLessonManager.getMiniLessonMyLessonItemInfo(currentClassId,"0"));
            lodingView.visible = false;
        }
        console.log("====MyMiniClasslist======");
    }

}
